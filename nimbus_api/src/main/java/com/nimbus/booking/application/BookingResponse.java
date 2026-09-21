package com.nimbus.booking.application;

import com.nimbus.booking.domain.entity.Booking;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Booking response DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    private UUID id;
    private UUID rideId;
    private UUID passengerId;
    private Integer seats;
    private Booking.BookingStatus status;
    private Double pickupLatitude;
    private Double pickupLongitude;
    private String pickupAddress;
    private Double dropoffLatitude;
    private Double dropoffLongitude;
    private String dropoffAddress;
    private Instant pickupPlannedTime;
    private Instant dropoffPlannedTime;
    private Instant pickedUpAt;
    private Instant droppedOffAt;
    private UUID fareQuoteId;
    private Integer plannedDistanceMeters;
    private Integer plannedDurationSeconds;
    private java.math.BigDecimal finalPayable;
    private Instant createdAt;
    private Instant updatedAt;
}
