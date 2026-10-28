package com.nimbus.voucher.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.voucher.application.VoucherValidateRequest;
import com.nimbus.voucher.application.VoucherValidateResponse;
import com.nimbus.voucher.domain.entity.Voucher;
import com.nimbus.voucher.domain.entity.VoucherRedemption;
import com.nimbus.voucher.domain.repository.VoucherRedemptionRepository;
import com.nimbus.voucher.domain.repository.VoucherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Voucher validation and redemption service.
 *
 * <p>Vouchers are validated against:
 * - Validity period (valid_from, valid_to)
 * - Usage limits (global and per-user)
 * - Minimum fare requirement
 * - Active status
 *
 * <p>Redemption is recorded immutably for audit purposes.</p>
 */
@Service
@RequiredArgsConstructor
public class VoucherService {

    private final VoucherRepository voucherRepository;
    private final VoucherRedemptionRepository redemptionRepository;
    private final UserRepository userRepository;

    /**
     * Validate a voucher for a specific user and fare.
     */
    @Transactional(readOnly = true)
    public VoucherValidateResponse validateVoucher(UUID userId, VoucherValidateRequest request) {
        Voucher voucher = voucherRepository.findByCode(request.getCode())
                .orElseThrow(() -> new NimbusException(ErrorCode.VOUCHER_NOT_FOUND, HttpStatus.NOT_FOUND));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        Instant now = Instant.now();

        // Check if voucher is active
        if (!voucher.isActive()) {
            throw new NimbusException(ErrorCode.VOUCHER_NOT_ACTIVE,
                    "Voucher is not active", HttpStatus.BAD_REQUEST);
        }

        // Check validity period
        if (!voucher.isValidAt(now)) {
            throw new NimbusException(ErrorCode.VOUCHER_EXPIRED,
                    "Voucher is not valid at this time", HttpStatus.BAD_REQUEST);
        }

        // Check per-user limit
        long userRedemptions = redemptionRepository.countByVoucherIdAndUserId(voucher.getId(), userId);
        if (userRedemptions >= voucher.getPerUserLimit()) {
            throw new NimbusException(ErrorCode.VOUCHER_USER_LIMIT_REACHED,
                    "You have reached the usage limit for this voucher", HttpStatus.CONFLICT);
        }

        // Check global usage limit
        if (voucher.getUsageLimit() != null) {
            long redemptionCount = redemptionRepository.countByVoucherId(voucher.getId());
            if (redemptionCount >= voucher.getUsageLimit()) {
                throw new NimbusException(ErrorCode.VOUCHER_USAGE_LIMIT_EXCEEDED,
                        "Voucher usage limit has been reached", HttpStatus.CONFLICT);
            }
        }

        BigDecimal fare = request.getFare() != null ? request.getFare() : BigDecimal.ZERO;

        // Calculate discount
        BigDecimal discount = voucher.calculateDiscount(fare);

        return VoucherValidateResponse.builder()
                .voucherCode(voucher.getCode())
                .discountType(voucher.getDiscountType())
                .discountAmount(discount)
                .discountedFare(fare.subtract(discount))
                .description(voucher.getDescription())
                .message("Voucher is valid")
                .build();
    }

    /**
     * Record a voucher redemption after successful validation.
     */
    /**
     * Voucher discount for fare quoting — never throws and never marks the
     * caller's transaction rollback-only (REQUIRES_NEW): an invalid voucher
     * simply discounts nothing.
     *
     * @return the discount amount, or empty when the voucher is invalid.
     */
    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.REQUIRES_NEW)
    public java.util.Optional<java.math.BigDecimal> quietDiscount(UUID userId, String code, BigDecimal fare) {
        try {
            VoucherValidateRequest req = VoucherValidateRequest.builder()
                    .code(code)
                    .userId(userId)
                    .fare(fare)
                    .build();
            VoucherValidateResponse res = validateVoucher(userId, req);
            return java.util.Optional.ofNullable(res.getDiscountAmount())
                    .filter(d -> d.signum() > 0);
        } catch (Exception e) {
            return java.util.Optional.empty();
        }
    }

    public void recordRedemption(UUID userId, String code, BigDecimal fare, BigDecimal discount) {
        recordRedemption(userId, code, fare, discount, null);
    }

    /**
     * Record a redemption bound to a booking. Called from the booking
     * transaction at confirm time so usage/per-user limits become real.
     * The (voucher, booking, REDEEMED) unique index makes this idempotent —
     * a re-confirm after retry does not double-count.
     */
    public void recordRedemption(UUID userId, String code, BigDecimal fare,
                                 BigDecimal discount, UUID bookingId) {
        if (code == null || code.isBlank() || discount == null || discount.signum() <= 0) {
            return;
        }
        if (bookingId != null && !redemptionRepository.findByBookingId(bookingId).isEmpty()) {
            return; // already redeemed for this booking
        }
        Voucher voucher = voucherRepository.findByCode(code)
                .orElseThrow(() -> new NimbusException(ErrorCode.VOUCHER_NOT_FOUND, HttpStatus.NOT_FOUND));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        VoucherRedemption redemption = VoucherRedemption.builder()
                .voucher(voucher)
                .user(user)
                .booking(bookingId != null
                        ? com.nimbus.booking.domain.entity.Booking.builder().id(bookingId).build()
                        : null)
                .fareAmount(fare)
                .discountAmount(discount)
                .createdAt(Instant.now())
                .build();
        redemptionRepository.save(redemption);
    }

    /**
     * Reverse the redemption tied to a cancelled booking. The discount
     * history stays immutable (status flips to REVERSED); the freed
     * booking link means the voucher can be applied to a future booking.
     */
    @Transactional
    public void reverseRedemptionForBooking(UUID bookingId) {
        redemptionRepository.findByBookingId(bookingId).stream()
                .filter(r -> r.getStatus() == VoucherRedemption.RedemptionStatus.REDEEMED)
                .forEach(r -> {
                    r.setStatus(VoucherRedemption.RedemptionStatus.REVERSED);
                    redemptionRepository.save(r);
                });
    }

    /**
     * Get voucher by code (admin only).
     */
    @Transactional(readOnly = true)
    public Optional<Voucher> getVoucherByCode(String code) {
        return voucherRepository.findByCode(code);
    }

    /**
     * List redemptions for a user.
     */
    @Transactional(readOnly = true)
    public List<VoucherRedemption> getUserRedemptions(UUID userId) {
        return redemptionRepository.findByUserId(userId);
    }
}
