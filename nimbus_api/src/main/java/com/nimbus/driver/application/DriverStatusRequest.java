package com.nimbus.driver.application;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * Request to update driver availability.
 */
@Getter @Setter
public class DriverStatusRequest {
    @NotBlank(message = "Driver status is required")
    private String driverStatus;
}
