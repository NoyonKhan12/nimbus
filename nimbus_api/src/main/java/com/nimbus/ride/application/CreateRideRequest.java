package com.nimbus.ride.application;

import jakarta.validation.constraints.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Request to create a new ride.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateRideRequest {

    @NotBlank(message = "Ride type is required")
    @Pattern(regexp = "SCHEDULED|INSTANT|RECURRING", message = "Invalid ride type")
    private String rideType;

    private Instant scheduledAt;

    private UUID vehicleId;

    @NotNull(message = "Origin location is required")
    private Double[] origin; // [longitude, latitude]

    @Size(max = 500, message = "Origin address must not exceed 500 characters")
    private String originAddress;

    @NotNull(message = "Destination location is required")
    private Double[] destination; // [longitude, latitude]

    @Size(max = 500, message = "Destination address must not exceed 500 characters")
    private String destinationAddress;

    @NotNull(message = "Available seats is required")
    @Positive(message = "Available seats must be positive")
    private Integer availableSeats;

    @PositiveOrZero(message = "Max detour must be non-negative")
    private Integer maxDetourMeters;

    @PositiveOrZero(message = "Max wait must be non-negative")
    private Integer maxWaitSeconds;

    @Size(max = 1000, message = "Notes must not exceed 1000 characters")
    private String notes;
}
