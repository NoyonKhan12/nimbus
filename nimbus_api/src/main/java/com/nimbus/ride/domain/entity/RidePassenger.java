package com.nimbus.ride.domain.entity;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Tracks a passenger's presence on a ride.
 * One passenger can have one booking per ride.
 *
 * <p>Manages the passenger's journey status through the ride lifecycle:
 * PENDING → BOARDING → COMPLETED / CANCELLED</p>
 */
@Entity
@Table(name = "ride_passengers", indexes = {
    @Index(name = "idx_ride_passengers_ride_id", columnList = "ride_id"),
    @Index(name = "idx_ride_passengers_passenger_id", columnList = "passenger_id")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RidePassenger {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ride_id", nullable = false, foreignKey = @ForeignKey(name = "fk_passenger_ride"))
    private Ride ride;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passenger_id", nullable = false, foreignKey = @ForeignKey(name = "fk_passenger_user"))
    private User passenger;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", foreignKey = @ForeignKey(name = "fk_passenger_booking"))
    private Booking booking;

    @Column(name = "seats", nullable = false)
    @Builder.Default
    private Integer seats = 1;

    @Column(name = "journey_status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private JourneyStatus journeyStatus = JourneyStatus.PENDING;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum JourneyStatus {
        PENDING,     // Waiting for pickup
        BOARDING,    // Being picked up
        COMPLETED,   // Dropped off
        CANCELLED    // Did not complete
    }

    /**
     * Transition the passenger's journey status.
     */
    public void transitionTo(JourneyStatus newStatus) {
        // State machine validation could be added here
        this.journeyStatus = newStatus;
        this.updatedAt = Instant.now();
    }
}
