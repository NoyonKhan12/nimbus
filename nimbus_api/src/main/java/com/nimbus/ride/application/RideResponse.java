package com.nimbus.ride.application;

import com.nimbus.ride.domain.entity.Ride;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Ride response DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class RideResponse {
    private UUID id;
    private UUID driverId;
    private UUID creatorId;
    private Ride.RideType type;
    private Instant scheduledAt;
    private Instant actualStartAt;
    private Instant actualEndAt;
    private Ride.RideStatus status;
    private Double originLatitude;
    private Double originLongitude;
    private String originAddress;
    private Double destinationLatitude;
    private Double destinationLongitude;
    private String destinationAddress;
    private Integer availableSeats;
    private Integer maxDetourMeters;
    private Integer maxWaitSeconds;
    private Integer routeVersion;
    private String fareRuleVersion;
    private Ride.RecurrenceType recurrenceType;
    private Instant recurrenceUntil;
    private UUID parentRideId;
    private String notes;
    private Instant createdAt;
    private Instant updatedAt;
}
