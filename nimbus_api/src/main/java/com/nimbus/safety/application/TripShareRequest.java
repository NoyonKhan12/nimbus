package com.nimbus.safety.application;

import jakarta.validation.constraints.NotNull;
import lombok.*;

/**
 * Trip sharing request for safety.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class TripShareRequest {

    @NotNull(message = "Ride ID is required")
    private String rideId;

    private Integer durationMinutes;
}
