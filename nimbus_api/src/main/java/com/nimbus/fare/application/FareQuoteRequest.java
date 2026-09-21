package com.nimbus.fare.application;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;

import java.util.UUID;

/**
 * Request to generate a fare quote for a booking.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class FareQuoteRequest {

    @NotNull(message = "Ride ID is required")
    private UUID rideId;

    private UUID bookingId;

    private Integer routeVersion;

    @Positive(message = "Distance must be positive")
    private Integer distanceMeters;

    @Positive(message = "Duration must be positive")
    private Integer durationSeconds;

    private Integer seats;

    private String voucherCode;
}
