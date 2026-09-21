package com.nimbus.settlement.application;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.settlement.domain.entity.Settlement;
import com.nimbus.settlement.domain.repository.SettlementRepository;
import com.nimbus.wallet.application.service.LedgerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.*;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Settlement service for calculating and processing driver payments.
 *
 * <p>Settlement expression:
 * driver payable = gross passenger collections - platform commission
 *                 - platform-funded adjustments - refunds + driver credits
 *
 * <p>Previous-day driver due blocks new eligibility until cleared.
 * Daily settlement job closes the prior financial period.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SettlementService {

    private final SettlementRepository settlementRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final BookingRepository bookingRepository;
    private final LedgerService ledgerService;

    /**
     * Calculate settlement for a driver for a given period.
     */
    @Transactional(readOnly = true)
    public Settlement calculateSettlement(UUID driverId, Instant periodStart, Instant periodEnd) {
        DriverProfile driver = driverProfileRepository.findByUserId(driverId)
                .orElseThrow(() -> new IllegalArgumentException("Driver not found: " + driverId));

        // Check for existing settlement for this period
        Optional<Settlement> existing = settlementRepository
                .findByDriverIdAndPeriodStartAndPeriodEnd(driverId, periodStart, periodEnd);
        if (existing.isPresent()) {
            return existing.get();
        }

        // Calculate gross earnings from completed bookings in the period
        BigDecimal grossEarnings = calculateGrossEarnings(driver.getId(), periodStart, periodEnd);

        // Calculate commission
        BigDecimal commissionRate = driver.getCommissionRate() != null ?
                driver.getCommissionRate() : BigDecimal.valueOf(10.00);
        BigDecimal commission = grossEarnings.multiply(commissionRate)
                .divide(BigDecimal.valueOf(100), 2, BigDecimal.ROUND_HALF_UP);

        // Calculate adjustments, refunds, credits
        BigDecimal adjustments = calculateAdjustments(driver.getId(), periodStart, periodEnd);
        BigDecimal refunds = calculateRefunds(driver.getId(), periodStart, periodEnd);
        BigDecimal driverCredits = calculateDriverCredits(driver.getId(), periodStart, periodEnd);

        // Calculate payable
        BigDecimal payable = grossEarnings
                .subtract(commission)
                .subtract(adjustments)
                .subtract(refunds)
                .add(driverCredits);

        return Settlement.builder()
                .driver(driver)
                .periodStart(periodStart)
                .periodEnd(periodEnd)
                .grossEarnings(grossEarnings)
                .commission(commission)
                .adjustments(adjustments)
                .refunds(refunds)
                .driverCredits(driverCredits)
                .payable(payable)
                .status(Settlement.SettlementStatus.PENDING)
                .build();
    }

    /**
     * Process settlement (transfer money to driver).
     */
    @Transactional
    public void processSettlement(UUID settlementId) {
        Settlement settlement = settlementRepository.findById(settlementId)
                .orElseThrow(() -> new IllegalArgumentException("Settlement not found: " + settlementId));

        if (!settlement.isReady()) {
            throw new IllegalStateException("Settlement is not ready: " + settlement.getStatus());
        }

        settlement.setStatus(Settlement.SettlementStatus.PROCESSING);
        settlementRepository.save(settlement);

        try {
            // Transfer money to driver's wallet
            ledgerService.processDriverSettlement(
                    settlement.getDriver().getId(),
                    settlement.getPayable(),
                    settlementId
            );

            settlement.setStatus(Settlement.SettlementStatus.PAID);
            settlement.setPaymentReference("SETTLEMENT-" + settlementId.toString().substring(0, 8));
            settlementRepository.save(settlement);

            // Clear driver's due amount
            updateDriverDueAmount(settlement.getDriver().getId(), BigDecimal.ZERO);

            log.info("Settlement processed: {} amount: {}", settlementId, settlement.getPayable());
        } catch (Exception e) {
            settlement.setStatus(Settlement.SettlementStatus.FAILED);
            settlementRepository.save(settlement);
            throw new RuntimeException("Failed to process settlement: " + settlementId, e);
        }
    }

    /**
     * Daily settlement job - process all settlements for the previous day.
     */
    @Transactional
    public void dailySettlement() {
        LocalDate yesterday = LocalDate.now(ZoneId.of("Asia/Dhaka")).minusDays(1);
        Instant periodStart = yesterday.atStartOfDay(ZoneId.of("Asia/Dhaka")).toInstant();
        Instant periodEnd = yesterday.plusDays(1).atStartOfDay(ZoneId.of("Asia/Dhaka")).toInstant();

        // Find all drivers with completed rides yesterday
        List<DriverProfile> driversWithEarnings = findDriversWithEarnings(periodStart, periodEnd);

        for (DriverProfile driver : driversWithEarnings) {
            try {
                Settlement settlement = calculateSettlement(
                        driver.getUser().getId(), periodStart, periodEnd);
                settlementRepository.save(settlement);
            } catch (Exception e) {
                log.error("Failed to calculate settlement for driver: {}",
                        driver.getId(), e);
            }
        }

        log.info("Daily settlement job completed. Period: {} to {}", periodStart, periodEnd);
    }

    private BigDecimal calculateGrossEarnings(UUID driverId, Instant periodStart, Instant periodEnd) {
        // Sum final_payable from completed bookings for this driver's rides
        return BigDecimal.ZERO; // Would query bookings joined with rides
    }

    private BigDecimal calculateAdjustments(UUID driverId, Instant periodStart, Instant periodEnd) {
        // Sum platform-funded adjustments from ledger
        return BigDecimal.ZERO;
    }

    private BigDecimal calculateRefunds(UUID driverId, Instant periodStart, Instant periodEnd) {
        // Sum refunds from ledger
        return BigDecimal.ZERO;
    }

    private BigDecimal calculateDriverCredits(UUID driverId, Instant periodStart, Instant periodEnd) {
        // Sum driver credits from ledger
        return BigDecimal.ZERO;
    }

    private void updateDriverDueAmount(UUID driverId, BigDecimal newDue) {
        // Update driver's due amount
    }

    private List<DriverProfile> findDriversWithEarnings(Instant periodStart, Instant periodEnd) {
        // Would query drivers with completed bookings in period
        return Collections.emptyList();
    }

    /**
     * Get pending settlements for a driver.
     */
    @Transactional(readOnly = true)
    public List<Settlement> getDriverSettlements(UUID driverId) {
        return settlementRepository.findByDriverIdAndPeriodStartBetween(
                driverId, Instant.MIN, Instant.MAX);
    }
}
