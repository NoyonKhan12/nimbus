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

    // Not @NotNull: the nested POST /rides/{rideId}/bookings takes it from
    // the path; the flat POST /bookings requires it (enforced in the
    // service, since bean validation runs before the controller body).
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

    @NotBlank(message = "Fare quote is required")
    private String fareQuoteId;
}
