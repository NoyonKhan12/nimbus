package com.nimbus.settlement.application;

import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.settlement.domain.entity.Settlement;
import com.nimbus.settlement.domain.repository.SettlementRepository;
import com.nimbus.wallet.application.service.LedgerService;
import com.nimbus.wallet.domain.entity.*;
import com.nimbus.wallet.domain.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

/**
 * Settlement service — the single implementation of driver settlement
 * (guide §13/§25).
 *
 * <p>Settlement expression:
 * payable = gross passenger collections − platform commission
 *           − platform-funded adjustments − refunds + driver credits,
 * with every feeder summed from immutable ledger entries for the period so
 * history stays reproducible.</p>
 *
 * <p>Previous-day driver due blocks new eligibility until cleared: cash
 * fares leave the platform commission as driver due (written when the ride
 * settles); payout clears the due.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SettlementService {

    private final SettlementRepository settlementRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final WalletRepository walletRepository;
    private final LedgerAccountRepository ledgerAccountRepository;
    private final LedgerEntryRepository ledgerEntryRepository;
    private final LedgerService ledgerService;
    private final com.nimbus.audit.application.service.AuditService auditService;

    /**
     * Close the given UTC day for every driver wallet: create a PENDING
     * Settlement per driver with period activity (idempotent per
     * driver+period). Called by the daily job and the admin trigger.
     *
     * @return number of settlement rows created
     */
    @Transactional
    public int settlePeriod(LocalDate day) {
        Instant start = day.atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant end = day.plusDays(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        int created = 0;

        List<Wallet> wallets = walletRepository.findAll();
        for (Wallet wallet : wallets) {
            if (wallet.getOwnerType() != Wallet.OwnerType.DRIVER) continue;

            DriverProfile profile = driverProfileRepository.findByUserId(wallet.getOwner().getId())
                    .orElse(null);
            if (profile == null) continue;

            var existing = settlementRepository.findByDriverIdAndPeriodStartAndPeriodEnd(
                    profile.getId(), start, end);
            if (existing.isPresent()) continue;

            Settlement settlement = buildPeriodSettlement(profile, wallet, start, end);
            if (settlement == null) continue;

            settlementRepository.save(settlement);
            created++;
            log.info("Settlement created: driver {} period {} payable {}",
                    profile.getId(), day, settlement.getPayable());
        }
        return created;
    }

    /** Sums the driver's ledger activity for the period into a Settlement. */
    private Settlement buildPeriodSettlement(DriverProfile profile, Wallet wallet,
                                             Instant start, Instant end) {
        LedgerAccount main = ledgerAccountRepository
                .findByWalletIdAndAccountType(wallet.getId(), LedgerAccount.AccountType.MAIN)
                .orElse(null);
        if (main == null) return null;

        BigDecimal gross = BigDecimal.ZERO;
        BigDecimal commission = BigDecimal.ZERO;
        BigDecimal adjustments = BigDecimal.ZERO;
        BigDecimal refunds = BigDecimal.ZERO;
        BigDecimal driverCredits = BigDecimal.ZERO;

        for (LedgerEntry e : ledgerEntryRepository.findByAccountId(main.getId())) {
            if (e.getCreatedAt() == null
                    || e.getCreatedAt().isBefore(start) || !e.getCreatedAt().isBefore(end)) continue;
            switch (e.getEntryType()) {
                case DRIVER_EARNING -> gross = gross.add(e.getAmount());
                case PLATFORM_COMMISSION -> commission = commission.add(e.getAmount());
                // Platform-funded discounts/subsidies reduce what the
                // driver receives for the affected rides.
                case PLATFORM_SUBSIDY, VOUCHER_DISCOUNT ->
                        adjustments = adjustments.add(e.getAmount());
                // Manual corrections: signed by their amount.
                case MANUAL_ADJUSTMENT -> adjustments = adjustments.add(e.getAmount());
                case CHARGEBACK -> refunds = refunds.add(e.getAmount());
                case DRIVER_CREDIT -> driverCredits = driverCredits.add(e.getAmount());
                default -> { /* settlement entries themselves are ignored */ }
            }
        }

        // A pure-cash day posts no earnings (the driver holds the gross),
        // but its commission is recorded as driver due — without a
        // settlement row that due could never clear and the driver would be
        // blocked forever (guide §13: due blocks eligibility "until
        // cleared"). Emit a payable-0 settlement so the netting has a
        // record and the payout path can clear the due.
        boolean noLedgerActivity =
                gross.signum() <= 0 && commission.signum() <= 0;
        BigDecimal outstandingDue = profile.getDueAmount() != null
                ? profile.getDueAmount() : BigDecimal.ZERO;
        if (noLedgerActivity && outstandingDue.signum() <= 0) return null;

        BigDecimal payable = gross.subtract(commission)
                .subtract(adjustments)
                .subtract(refunds)
                .add(driverCredits)
                .max(BigDecimal.ZERO)
                .setScale(2, java.math.RoundingMode.HALF_UP);

        return Settlement.builder()
                .driver(profile)
                .periodStart(start)
                .periodEnd(end)
                .grossEarnings(gross.setScale(2, java.math.RoundingMode.HALF_UP))
                .commission(commission.setScale(2, java.math.RoundingMode.HALF_UP))
                .adjustments(adjustments.setScale(2, java.math.RoundingMode.HALF_UP))
                .refunds(refunds.setScale(2, java.math.RoundingMode.HALF_UP))
                .driverCredits(driverCredits.setScale(2, java.math.RoundingMode.HALF_UP))
                .payable(payable)
                .status(Settlement.SettlementStatus.PENDING)
                .build();
    }

    /**
     * Driver action: request payout of a PENDING settlement
     * (guide §15 POST /drivers/settlements).
     */
    @Transactional
    public SettlementResponse requestPayout(UUID settlementId, UUID driverUserId) {
        Settlement settlement = settlementRepository.findById(settlementId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND,
                        "Settlement not found", HttpStatus.NOT_FOUND));

        if (!settlement.getDriver().getUser().getId().equals(driverUserId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        if (settlement.getStatus() != Settlement.SettlementStatus.PENDING) {
            throw new NimbusException(ErrorCode.CONFLICT,
                    "Settlement is " + settlement.getStatus() + ", only PENDING can be requested",
                    HttpStatus.CONFLICT);
        }
        settlement.setStatus(Settlement.SettlementStatus.PROCESSING);
        settlement.setUpdatedAt(Instant.now());
        return toResponse(settlementRepository.save(settlement));
    }

    /**
     * Process a settlement (pay the driver): posts the immutable
     * DRIVER_SETTLEMENT entry, marks PAID, and clears any previous-day
     * due that was blocking eligibility (guide §5/§13).
     */
    @Transactional
    public SettlementResponse processSettlement(UUID settlementId) {
        Settlement settlement = settlementRepository.findById(settlementId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND,
                        "Settlement not found", HttpStatus.NOT_FOUND));

        if (settlement.getStatus() == Settlement.SettlementStatus.PAID) {
            return toResponse(settlement); // idempotent
        }
        if (settlement.getStatus() == Settlement.SettlementStatus.ON_HOLD) {
            throw new NimbusException(ErrorCode.CONFLICT,
                    "Settlement is ON_HOLD", HttpStatus.CONFLICT);
        }

        DriverProfile driver = settlement.getDriver();

        // Cash commission due is offset against this payout. Only the
        // cleared portion is forgiven; any shortfall remains on the driver
        // so eligibility stays blocked (guide §5/§13).
        BigDecimal payable = settlement.getPayable() != null
                ? settlement.getPayable() : BigDecimal.ZERO;
        BigDecimal due = driver.getDueAmount() != null
                ? driver.getDueAmount() : BigDecimal.ZERO;
        if (due.signum() > 0 && payable.signum() > 0) {
            BigDecimal applied = payable.min(due);
            payable = payable.subtract(applied);
            driver.setDueAmount(due.subtract(applied));
            settlement.setPayable(payable);
        }

        if (payable.signum() > 0) {
            ledgerService.processDriverSettlement(driver.getId(), payable, settlementId);
        }

        settlement.setStatus(Settlement.SettlementStatus.PAID);
        settlement.setPaymentReference("SETTLEMENT-" + settlementId.toString().substring(0, 8));
        settlement.setUpdatedAt(Instant.now());
        settlementRepository.save(settlement);

        driverProfileRepository.save(driver);

        auditService.logAction(currentUserIdOrNull(), "SETTLEMENT_PAID", "SETTLEMENT",
                settlementId, "status=" + Settlement.SettlementStatus.PROCESSING,
                "status=PAID payable=" + settlement.getPayable());

        log.info("Settlement processed: {} payable {} driver {}",
                settlementId, settlement.getPayable(), driver.getId());
        return toResponse(settlement);
    }

    private UUID currentUserIdOrNull() {
        var auth = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }

    /**
     * Settlement history for a driver (guide §15 GET /drivers/settlements).
     */
    @Transactional(readOnly = true)
    public List<SettlementResponse> getSettlementsForDriver(UUID driverUserId) {
        DriverProfile profile = driverProfileRepository.findByUserId(driverUserId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND,
                        HttpStatus.NOT_FOUND));
        return settlementRepository.findByDriverIdOrderByPeriodStartDesc(profile.getId()).stream()
                .map(this::toResponse)
                .toList();
    }

    /** Flat response mapping — entities never leave the service. */
    public SettlementResponse toResponse(Settlement s) {
        return SettlementResponse.builder()
                .id(s.getId())
                .driverId(s.getDriver() != null ? s.getDriver().getId() : null)
                .periodStart(s.getPeriodStart())
                .periodEnd(s.getPeriodEnd())
                .grossEarnings(s.getGrossEarnings())
                .commission(s.getCommission())
                .adjustments(s.getAdjustments())
                .refunds(s.getRefunds())
                .driverCredits(s.getDriverCredits())
                .payable(s.getPayable())
                .status(s.getStatus() != null ? s.getStatus().name() : null)
                .paymentReference(s.getPaymentReference())
                .createdAt(s.getCreatedAt())
                .build();
    }

    /**
     * Drivers with an outstanding due — used by the reminder job and admin.
     */
    @Transactional(readOnly = true)
    public List<DriverProfile> findDriversWithDue() {
        return driverProfileRepository.findByDueAmountGreaterThan(BigDecimal.ZERO);
    }
}
