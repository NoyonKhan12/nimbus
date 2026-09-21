package com.nimbus.driver.application;

import jakarta.validation.constraints.*;
import lombok.*;

/**
 * Request to apply as a driver.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverApplicationRequest {

    @NotBlank(message = "License number is required")
    @Size(max = 100, message = "License number too long")
    private String licenseNumber;

    @Future(message = "License expiry must be in the future")
    private java.time.Instant licenseExpiry;

    @NotBlank(message = "Vehicle registration is required")
    @Size(max = 100)
    private String vehicleRegistrationNumber;

    @NotBlank(message = "Vehicle type is required")
    @Pattern(regexp = "SEDAN|SUV|PICKUP|VAN|BIKE|TRUCK|OTHER", message = "Invalid vehicle type")
    private String vehicleType;

    @Size(max = 100)
    private String vehicleModel;

    @Min(value = 1900, message = "Invalid year")
    @Max(value = 2100, message = "Invalid year")
    private Integer vehicleYear;

    @Size(max = 50)
    private String vehicleColor;

    @NotNull(message = "Seat capacity is required")
    @Min(value = 1, message = "Seat capacity must be at least 1")
    private Integer seatCapacity;
}
