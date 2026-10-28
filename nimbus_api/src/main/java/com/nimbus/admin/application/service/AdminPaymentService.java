package com.nimbus.admin.application.service;

import com.nimbus.admin.domain.projection.PaymentAdminProjection;
import com.nimbus.kernel.application.dto.PagedResponse;
import com.nimbus.kernel.application.dto.PagedResponse.PageMeta;
import com.nimbus.payment.domain.entity.Payment;
import com.nimbus.payment.domain.repository.PaymentRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;

/**
 * Service for admin payment operations.
 * Caching at the service layer to avoid ResponseEntity serialization issues.
 */
@Service
@Slf4j
public class AdminPaymentService {

    private final PaymentRepository paymentRepository;
    private final AdminCacheService cacheService;
    private final com.nimbus.wallet.application.service.LedgerService ledgerService;
    private final com.nimbus.audit.application.service.AuditService auditService;

    public AdminPaymentService(PaymentRepository paymentRepository, AdminCacheService cacheService,
                               com.nimbus.wallet.application.service.LedgerService ledgerService,
                               com.nimbus.audit.application.service.AuditService auditService) {
        this.paymentRepository = paymentRepository;
        this.cacheService = cacheService;
        this.ledgerService = ledgerService;
        this.auditService = auditService;
    }

    public PagedResponse<PaymentAdminProjection> listPayments(int page, int size, String status) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        Payment.PaymentStatus statusEnum = null;
        if (status != null && !status.isEmpty()) {
            statusEnum = Payment.PaymentStatus.valueOf(status.toUpperCase());
        }

        Page<PaymentAdminProjection> paymentPage = paymentRepository.findAdminPayments(statusEnum, pageable);
        return toPagedResponse(paymentPage);
    }

    public Optional<PaymentAdminProjection> getPaymentById(String id) {
        UUID paymentId = UUID.fromString(id);
        return paymentRepository.findByIdProjection(paymentId);
    }

    public void refundPayment(String id) {
        UUID paymentId = UUID.fromString(id);
        Payment payment = paymentRepository.findById(paymentId)
            .orElseThrow(() -> new RuntimeException("Payment not found"));

        if (!payment.canBeRefunded()) {
            throw new RuntimeException("Payment cannot be refunded: " + payment.getStatus());
        }

        payment.setStatus(Payment.PaymentStatus.REFUNDED);
        paymentRepository.save(payment);

        // Refunds produce correct financial entries (guide §31): the
        // passenger's wallet is credited as app credit and an immutable
        // REFUND entry is posted.
        ledgerService.postRefund(payment.getBooking(), payment.getAmount(), paymentId);

        cacheService.invalidatePayments();
        cacheService.invalidateDashboardStats();

        auditService.logAction(currentUserIdOrNull(), "PAYMENT_REFUNDED", "PAYMENT",
                paymentId, "status=SUCCESS", "status=REFUNDED amount=" + payment.getAmount());
    }

    private UUID currentUserIdOrNull() {
        var auth = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }

    private <T> PagedResponse<T> toPagedResponse(Page<T> page) {
        PageMeta meta = new PageMeta(
            page.getNumber(),
            page.getSize(),
            page.getTotalElements(),
            page.getTotalPages()
        );
        return PagedResponse.<T>builder()
            .success(true)
            .data(page.getContent())
            .meta(meta)
            .timestamp(Instant.now().toString())
            .build();
    }
}
