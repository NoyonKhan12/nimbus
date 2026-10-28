package com.nimbus.fare.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Immutable fare quote entity.
 *
 * <p>Stores all fare components with version information (fare_rule_version,
 * route_version) to ensure reproducibility of historical pricing decisions.
 * Once created, a fare quote is never recalculated using current rates -
 * it is referenced by bookings and payments to ensure auditability.</p>
 */
@Entity
@Table(name = "fare_quotes", indexes = {
    @Index(name = "idx_fare_quotes_booking_id", columnList = "booking_id")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FareQuote {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "booking_id")
    private UUID bookingId;

    /** Ride this quote was priced for; enforced when the booking consumes it. */
    @Column(name = "ride_id")
    private UUID rideId;

    /** Passenger who requested the quote; prevents cross-user quote reuse. */
    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "rule_version", nullable = false, length = 50)
    private String ruleVersion;

    @Column(name = "route_version", nullable = false)
    private Integer routeVersion;

    /**
     * Passenger segment this quote was priced for. Booking creation must
     * match these coordinates so a short quote cannot cover a long trip.
     */
    @Column(name = "pickup_latitude")
    private Double pickupLatitude;

    @Column(name = "pickup_longitude")
    private Double pickupLongitude;

    @Column(name = "dropoff_latitude")
    private Double dropoffLatitude;

    @Column(name = "dropoff_longitude")
    private Double dropoffLongitude;

    @Column(name = "distance_meters", nullable = false)
    private Integer distanceMeters;

    @Column(name = "duration_seconds", nullable = false)
    private Integer durationSeconds;

    @Column(name = "base_fare", nullable = false, precision = 18, scale = 2)
    private BigDecimal baseFare;

    @Column(name = "distance_charge", nullable = false, precision = 18, scale = 2)
    private BigDecimal distanceCharge;

    @Column(name = "time_charge", nullable = false, precision = 18, scale = 2)
    private BigDecimal timeCharge;

    @Column(name = "service_fee", nullable = false, precision = 18, scale = 2)
    private BigDecimal serviceFee;

    @Column(name = "tax", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal tax = BigDecimal.ZERO;

    @Column(name = "discount", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal discount = BigDecimal.ZERO;

    /** Voucher code applied when this quote was priced (null if none). */
    @Column(name = "voucher_code", length = 50)
    private String voucherCode;

    @Column(name = "gross_fare", nullable = false, precision = 18, scale = 2)
    private BigDecimal grossFare;

    @Column(name = "final_payable", nullable = false, precision = 18, scale = 2)
    private BigDecimal finalPayable;

    @Column(name = "currency", nullable = false, length = 10)
    @Builder.Default
    private String currency = "BDT";

    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    /**
     * Check if this quote is still valid (not expired).
     */
    public boolean isValid() {
        return expiresAt == null || Instant.now().isBefore(expiresAt);
    }
}
