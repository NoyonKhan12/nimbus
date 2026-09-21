package com.nimbus.safety.application;

import jakarta.validation.constraints.NotNull;
import lombok.*;

/**
 * SOS safety alert request.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class SosRequest {

    @NotNull(message = "Ride ID is required")
    private String rideId;

    private Double latitude;
    private Double longitude;

    private String description;
}
