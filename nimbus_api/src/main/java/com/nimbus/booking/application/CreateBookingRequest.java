package com.nimbus.booking.application;

import jakarta.validation.constraints.*;
import lombok.*;

import java.util.UUID;

/**
 * Request to create a booking on a ride.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateBookingRequest {

    @NotNull(message = "Ride ID is required")
    private UUID rideId;

    @NotNull(message = "Seat count is required")
    @Positive(message = "Seat count must be positive")
    private Integer seats;

    @NotNull(message = "Pickup location is required")
    private Double[] pickupLocation; // [longitude, latitude]

    @Size(max = 500, message = "Pickup address must not exceed 500 characters")
    private String pickupAddress;

    @NotNull(message = "Dropoff location is required")
    private Double[] dropoffLocation; // [longitude, latitude]

    @Size(max = 500, message = "Dropoff address must not exceed 500 characters")
    private String dropoffAddress;

    private String fareQuoteId;
}
