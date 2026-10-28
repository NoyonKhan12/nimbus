package com.nimbus.fare.application.service;

import com.nimbus.fare.application.FareQuoteRequest;
import com.nimbus.voucher.application.VoucherValidateRequest;
import com.nimbus.voucher.application.VoucherValidateResponse;
import com.nimbus.fare.application.FareQuoteResponse;
import com.nimbus.fare.domain.entity.FareQuote;
import com.nimbus.fare.domain.entity.FareRule;
import com.nimbus.fare.domain.repository.FareQuoteRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.infrastructure.config.ConfigurationService;
import com.nimbus.kernel.domain.repository.SystemConfigurationRepository;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
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
    private final RideRepository rideRepository;
    private final FareRuleProvider fareRuleProvider;
    private final com.nimbus.voucher.application.service.VoucherService voucherService;

    /** Average city speed used to estimate trip duration (~18 km/h Dhaka). */
    private static final double AVG_SPEED_KMH = 18.0;

    /**
     * Generate a fare quote for a potential booking.
     *
     * @param request Contains ride ID, booking ID, distance, duration, seats
     * @return Persisted fare quote response with all components
     */
    @Transactional
    public FareQuoteResponse generateQuote(FareQuoteRequest request, UUID userId) {
        // Rates come from the active versioned fare rule (fare_rules); when
        // no rule row exists yet, fall back to system_configurations.
        FareRule rule = fareRuleProvider.getActiveRule();
        String ruleVersion;
        BigDecimal baseFare, perKmRate, perMinRate, serviceFee, minFare, taxRate;
        if (rule != null) {
            ruleVersion = rule.getVersion();
            baseFare = rule.getBaseFare();
            perKmRate = rule.getPerKmRate();
            perMinRate = rule.getPerMinuteRate();
            serviceFee = rule.getServiceFee();
            minFare = rule.getMinimumFare();
            taxRate = rule.getTaxRatePercent();
        } else {
            ruleVersion = "config";
            baseFare = configRepository.getDecimalValue("DEFAULT_BASE_FARE_BDT", BigDecimal.valueOf(25));
            perKmRate = configRepository.getDecimalValue("DEFAULT_PER_KM_FARE_BDT", BigDecimal.valueOf(12));
            perMinRate = configRepository.getDecimalValue("DEFAULT_PER_MINUTE_FARE_BDT", BigDecimal.valueOf(0.50));
            serviceFee = configRepository.getDecimalValue("DEFAULT_SERVICE_FEE_BDT", BigDecimal.valueOf(5));
            minFare = configRepository.getDecimalValue("DEFAULT_MINIMUM_FARE_BDT", BigDecimal.valueOf(50));
            taxRate = configRepository.getDecimalValue("TAX_RATE_PERCENT", BigDecimal.ZERO);
        }

        // The backend owns pricing inputs (guide §5/§11). Never trust
        // client-supplied distance/duration: derive the segment from the
        // passenger's chosen pickup/drop-off, falling back to the ride's
        // stored endpoints for older clients. The selected segment is
        // persisted on the quote and re-checked when the quote is consumed.
        Ride ride = rideRepository.findById(request.getRideId())
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND,
                        "Ride not found", HttpStatus.NOT_FOUND));
        if (ride.getStatus() != Ride.RideStatus.PUBLISHED
                && ride.getStatus() != Ride.RideStatus.ROUTE_LOCKED) {
            throw new NimbusException(ErrorCode.RIDE_NOT_BOOKABLE,
                    "Ride is not bookable", HttpStatus.BAD_REQUEST);
        }
        double[] pickup = parseRequestPoint(request.getPickupLocation(), "pickup");
        double[] dropoff = parseRequestPoint(request.getDropoffLocation(), "drop-off");
        if (pickup == null || dropoff == null) {
            double[] rideOrigin = parsePoint(ride.getOriginLocation());
            double[] rideDestination = parsePoint(ride.getDestinationLocation());
            if (rideOrigin == null || rideDestination == null) {
                throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                        "Ride has no usable origin/destination coordinates", HttpStatus.BAD_REQUEST);
            }
            if (pickup == null) pickup = rideOrigin;
            if (dropoff == null) dropoff = rideDestination;
        }
        int[] estimate = estimateSegment(pickup, dropoff);
        int requestedMeters = estimate[0];
        int requestedSeconds = estimate[1];

        BigDecimal distanceMeters = BigDecimal.valueOf(requestedMeters);
        BigDecimal distanceKm = distanceMeters.divide(BigDecimal.valueOf(1000), 4, RoundingMode.HALF_UP);
        BigDecimal distanceCharge = perKmRate.multiply(distanceKm);

        // Calculate time charge
        BigDecimal durationSeconds = BigDecimal.valueOf(requestedSeconds);
        BigDecimal durationMinutes = durationSeconds.divide(BigDecimal.valueOf(60), 4, RoundingMode.HALF_UP);
        BigDecimal timeCharge = perMinRate.multiply(durationMinutes);

        // Calculate gross fare
        BigDecimal grossFare = baseFare.add(distanceCharge).add(timeCharge).add(serviceFee);

        // Apply tax
        BigDecimal tax = grossFare.multiply(taxRate).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);

        // Apply discount (voucher discount if any). Delegates to the voucher
        // module: active/validity/usage-limit checks happen there. The
        // redemption itself is recorded when the booking is confirmed.
        BigDecimal discount = BigDecimal.ZERO;
        String appliedVoucherCode = null;
        if (request.getVoucherCode() != null && !request.getVoucherCode().isBlank()) {
            discount = applyVoucherDiscount(userId, request.getVoucherCode(), grossFare);
            if (discount.signum() > 0) {
                appliedVoucherCode = request.getVoucherCode();
            }
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
                // A quote is bound to its passenger and ride. The booking is
                // attached when the quote is consumed, not before.
                .rideId(ride.getId())
                .userId(userId)
                .bookingId(null)
                .ruleVersion(ruleVersion)
                .routeVersion(ride.getRouteVersion() != null ? ride.getRouteVersion() : 0)
                .pickupLatitude(pickup[0])
                .pickupLongitude(pickup[1])
                .dropoffLatitude(dropoff[0])
                .dropoffLongitude(dropoff[1])
                .distanceMeters(requestedMeters)
                .durationSeconds(requestedSeconds)
                .baseFare(baseFare.setScale(2, RoundingMode.HALF_UP))
                .distanceCharge(distanceCharge.setScale(2, RoundingMode.HALF_UP))
                .timeCharge(timeCharge.setScale(2, RoundingMode.HALF_UP))
                .serviceFee(serviceFee.setScale(2, RoundingMode.HALF_UP))
                .tax(tax)
                .discount(discount)
                .voucherCode(appliedVoucherCode)
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
    private BigDecimal applyVoucherDiscount(UUID userId, String voucherCode, BigDecimal fare) {
        // quietDiscount runs in its own transaction: an invalid voucher must
        // not roll back the quote.
        return voucherService.quietDiscount(userId, voucherCode, fare)
                .map(d -> d.min(fare))
                .orElse(BigDecimal.ZERO);
    }

    private FareQuoteResponse toResponse(FareQuote quote) {
        return FareQuoteResponse.builder()
                .quoteId(quote.getId())
                .bookingId(quote.getBookingId())
                .fareRuleVersion(quote.getRuleVersion())
                .routeVersion(quote.getRouteVersion())
                .pickupLatitude(quote.getPickupLatitude())
                .pickupLongitude(quote.getPickupLongitude())
                .dropoffLatitude(quote.getDropoffLatitude())
                .dropoffLongitude(quote.getDropoffLongitude())
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

    /**
     * Estimates trip distance/duration for a passenger segment. Distance is
     * straight-line haversine with a 1.3 road factor; duration uses
     * {@link #AVG_SPEED_KMH}.
     *
     * @return int[]{distanceMeters, durationSeconds}
     */
    private int[] estimateSegment(double[] pickup, double[] dropoff) {
        double meters = haversineMeters(pickup[0], pickup[1], dropoff[0], dropoff[1]) * 1.3;
        if (meters < 1.0) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Pickup and drop-off must be different locations", HttpStatus.BAD_REQUEST);
        }
        int distanceMeters = (int) Math.round(meters);
        int durationSeconds = Math.max(60,
                (int) Math.round(meters / 1000.0 / AVG_SPEED_KMH * 3600));
        return new int[]{distanceMeters, durationSeconds};
    }

    /**
     * Parses a request coordinate array in GeoJSON order
     * ({@code [longitude, latitude]}) and returns {@code [lat, lng]}.
     */
    private double[] parseRequestPoint(Double[] point, String label) {
        if (point == null || point.length < 2 || point[0] == null || point[1] == null) {
            return null;
        }
        double lng = point[0];
        double lat = point[1];
        if (!Double.isFinite(lat) || !Double.isFinite(lng)
                || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Invalid " + label + " coordinates", HttpStatus.BAD_REQUEST);
        }
        return new double[]{lat, lng};
    }

    /** Parses {@code POINT(lng lat)} WKT as stored by the ride module. */
    private double[] parsePoint(String wkt) {
        if (wkt == null || !wkt.startsWith("POINT(")) return null;
        try {
            String coords = wkt.substring(6, wkt.length() - 1);
            String[] parts = coords.trim().split("\\s+");
            return new double[]{Double.parseDouble(parts[1]), Double.parseDouble(parts[0])}; // lat, lng
        } catch (Exception e) {
            return null;
        }
    }

    private double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
        double r = 6371000.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }
}
