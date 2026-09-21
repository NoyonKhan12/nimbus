package com.nimbus.ride.domain.entity;

import com.nimbus.booking.domain.entity.Booking;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Represents a stop along a ride's route.
 * Stops are ordered by sequence and include pickup and dropoff locations
 * for each passenger booking.
 *
 * <p>Stops are created during route optimization and become locked
 * when the route is finalized before execution.</p>
 */
@Entity
@Table(name = "ride_stops", indexes = {
    @Index(name = "idx_ride_stops_ride_seq", columnList = "ride_id, stop_sequence"),
    @Index(name = "idx_ride_stops_booking_id", columnList = "booking_id")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RideStop {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ride_id", nullable = false, foreignKey = @ForeignKey(name = "fk_stop_ride"))
    private Ride ride;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", foreignKey = @ForeignKey(name = "fk_stop_booking"))
    private Booking booking;

    @Column(name = "stop_sequence", nullable = false)
    private Integer sequence;

    @Column(name = "stop_type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private StopType stopType;

    @Column(name = "location", columnDefinition = "GEOMETRY(Point, 4326)")
    private String location;

    @Column(name = "address", length = 500)
    private String address;

    @Column(name = "planned_time")
    private Instant plannedTime;

    @Column(name = "actual_time")
    private Instant actualTime;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private StopStatus status = StopStatus.PENDING;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum StopType {
        PICKUP, DROPOFF, ORIGIN, DESTINATION
    }

    public enum StopStatus {
        PENDING,        // Stop not yet reached
        ARRIVING,       // Approaching the stop
        ARRIVED,        // Reached the stop
        COMPLETED       // Passenger picked up/dropped off
    }

    /**
     * Mark this stop as arrived at the actual time.
     */
    public void markArrived() {
        this.status = StopStatus.ARRIVED;
        this.actualTime = Instant.now();
    }

    /**
     * Mark this stop as completed.
     */
    public void markCompleted() {
        this.status = StopStatus.COMPLETED;
        if (this.actualTime == null) {
            this.actualTime = Instant.now();
        }
    }
}
