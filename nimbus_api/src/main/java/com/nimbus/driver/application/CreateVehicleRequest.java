package com.nimbus.driver.application;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

/**
 * Request to register an additional vehicle for a driver.
 */
@Getter @Setter
public class CreateVehicleRequest {
    @NotBlank(message = "Registration number is required")
    private String registrationNumber;
    @NotBlank(message = "Vehicle type is required")
    private String type;
    private String model;
    private Integer year;
    private String color;
    @NotNull(message = "Seat capacity is required")
    private Integer seatCapacity;
}
