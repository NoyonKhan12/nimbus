package com.nimbus.driver.application;

import lombok.*;

import java.util.UUID;

/**
 * Vehicle response DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class VehicleResponse {
    private UUID id;
    private UUID driverId;
    private String registrationNumber;
    private String type;
    private String model;
    private Integer year;
    private String color;
    private Integer seatCapacity;
    private String status;
}
