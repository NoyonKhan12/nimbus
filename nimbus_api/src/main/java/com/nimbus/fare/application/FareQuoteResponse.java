package com.nimbus.fare.application;

import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Fare quote response as defined in the API contract.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class FareQuoteResponse {
    private UUID quoteId;
    private UUID bookingId;
    private String fareRuleVersion;
    private int routeVersion;
    private Double pickupLatitude;
    private Double pickupLongitude;
    private Double dropoffLatitude;
    private Double dropoffLongitude;
    private int distanceMeters;
    private int durationSeconds;
    private BigDecimal baseFare;
    private BigDecimal distanceCharge;
    private BigDecimal timeCharge;
    private BigDecimal serviceFee;
    private BigDecimal tax;
    private BigDecimal grossFare;
    private BigDecimal discount;
    private BigDecimal finalPayable;
    private String currency;
    private Instant expiresAt;
}
