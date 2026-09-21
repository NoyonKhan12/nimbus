package com.nimbus.fare.application.service;

import com.nimbus.fare.application.FareQuoteRequest;
import com.nimbus.fare.application.FareQuoteResponse;
import com.nimbus.fare.domain.entity.FareQuote;
import com.nimbus.fare.domain.repository.FareQuoteRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.infrastructure.config.ConfigurationService;
import com.nimbus.kernel.domain.repository.SystemConfigurationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.UUID;

/**
 * Fare calculation service implementing the fare formula:
 * Final Fare = Base Fare + Distance Charge + Time Charge + Service Fee + Tax - Discount
 *
 * <p>Fare quotes are persisted with version information (fare_rule_version,
 * route_version) to ensure reproducibility. Once created, a fare quote
 * is never recalculated using current rates.</p>
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FareService {

    private final FareQuoteRepository fareQuoteRepository;
    private final SystemConfigurationRepository configRepository;
    private final ConfigurationService configurationService;

    /**
     * Generate a fare quote for a potential booking.
     *
     * @param request Contains ride ID, booking ID, distance, duration, seats
     * @return Persisted fare quote response with all components
     */
    @Transactional
    public FareQuoteResponse generateQuote(FareQuoteRequest request) {
        // Read fare configuration from system_configurations
        BigDecimal baseFare = configRepository.getDecimalValue("DEFAULT_BASE_FARE_BDT", BigDecimal.valueOf(25));
        BigDecimal perKmRate = configRepository.getDecimalValue("DEFAULT_PER_KM_FARE_BDT", BigDecimal.valueOf(12));
        BigDecimal perMinRate = configRepository.getDecimalValue("DEFAULT_PER_MINUTE_FARE_BDT", BigDecimal.valueOf(0.50));
        BigDecimal serviceFee = configRepository.getDecimalValue("DEFAULT_SERVICE_FEE_BDT", BigDecimal.valueOf(5));
        BigDecimal minFare = configRepository.getDecimalValue("DEFAULT_MINIMUM_FARE_BDT", BigDecimal.valueOf(50));
        BigDecimal taxRate = configRepository.getDecimalValue("TAX_RATE_PERCENT", BigDecimal.ZERO);

        // Calculate distance charge
        BigDecimal distanceMeters = BigDecimal.valueOf(request.getDistanceMeters());
        BigDecimal distanceKm = distanceMeters.divide(BigDecimal.valueOf(1000), 4, RoundingMode.HALF_UP);
        BigDecimal distanceCharge = perKmRate.multiply(distanceKm);

        // Calculate time charge
        BigDecimal durationSeconds = BigDecimal.valueOf(request.getDurationSeconds());
        BigDecimal durationMinutes = durationSeconds.divide(BigDecimal.valueOf(60), 4, RoundingMode.HALF_UP);
        BigDecimal timeCharge = perMinRate.multiply(durationMinutes);

        // Calculate gross fare
        BigDecimal grossFare = baseFare.add(distanceCharge).add(timeCharge).add(serviceFee);

        // Apply tax
        BigDecimal tax = grossFare.multiply(taxRate).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);

        // Apply discount (voucher discount if any)
        BigDecimal discount = BigDecimal.ZERO;
        if (request.getVoucherCode() != null && !request.getVoucherCode().isBlank()) {
            discount = applyVoucherDiscount(request.getVoucherCode(), grossFare);
        }

        // Calculate final payable
        BigDecimal finalPayable = grossFare.add(tax).subtract(discount);

        // Apply minimum fare
        if (finalPayable.compareTo(minFare) < 0) {
            finalPayable = minFare;
        }

        // Currency-specific rounding
        finalPayable = finalPayable.setScale(2, RoundingMode.HALF_UP);

        // Persist the quote with version info
        int quoteExpiryMinutes = configurationService.getIntOrDefault("FARE_QUOTE_EXPIRY_MINUTES", 5);
        FareQuote quote = FareQuote.builder()
                .bookingId(request.getBookingId() != null ? request.getBookingId() : null)
                .ruleVersion("v1") // Would be configurable in production
                .routeVersion(request.getRouteVersion() != null ? request.getRouteVersion() : 0)
                .distanceMeters(request.getDistanceMeters())
                .durationSeconds(request.getDurationSeconds())
                .baseFare(baseFare.setScale(2, RoundingMode.HALF_UP))
                .distanceCharge(distanceCharge.setScale(2, RoundingMode.HALF_UP))
                .timeCharge(timeCharge.setScale(2, RoundingMode.HALF_UP))
                .serviceFee(serviceFee.setScale(2, RoundingMode.HALF_UP))
                .tax(tax)
                .discount(discount)
                .grossFare(grossFare.setScale(2, RoundingMode.HALF_UP))
                .finalPayable(finalPayable)
                .currency("BDT")
                .expiresAt(Instant.now().plusSeconds(quoteExpiryMinutes * 60L))
                .build();

        FareQuote saved = fareQuoteRepository.save(quote);

        return toResponse(saved);
    }

    /**
     * Retrieve a fare quote by booking ID.
     */
    public FareQuoteResponse getQuoteByBookingId(UUID bookingId) {
        FareQuote quote = fareQuoteRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new NimbusException(ErrorCode.FARE_QUOTE_EXPIRED,
                        "No fare quote found for booking", HttpStatus.NOT_FOUND));
        return toResponse(quote);
    }

    /**
     * Validate that a quote is still valid.
     */
    public boolean isQuoteValid(UUID quoteId) {
        return fareQuoteRepository.findById(quoteId)
                .map(FareQuote::isValid)
                .orElse(false);
    }

    /**
     * Apply voucher discount to the fare.
     * In a complete implementation, this would validate the voucher
     * against business rules.
     */
    private BigDecimal applyVoucherDiscount(String voucherCode, BigDecimal fare) {
        // Voucher validation is handled by the voucher module
        // Here we just return zero if no valid voucher applies
        return BigDecimal.ZERO;
    }

    private FareQuoteResponse toResponse(FareQuote quote) {
        return FareQuoteResponse.builder()
                .quoteId(quote.getId())
                .bookingId(quote.getBookingId())
                .fareRuleVersion(quote.getRuleVersion())
                .routeVersion(quote.getRouteVersion())
                .distanceMeters(quote.getDistanceMeters())
                .durationSeconds(quote.getDurationSeconds())
                .baseFare(quote.getBaseFare())
                .distanceCharge(quote.getDistanceCharge())
                .timeCharge(quote.getTimeCharge())
                .serviceFee(quote.getServiceFee())
                .tax(quote.getTax())
                .grossFare(quote.getGrossFare())
                .discount(quote.getDiscount())
                .finalPayable(quote.getFinalPayable())
                .currency(quote.getCurrency())
                .expiresAt(quote.getExpiresAt())
                .build();
    }
}
