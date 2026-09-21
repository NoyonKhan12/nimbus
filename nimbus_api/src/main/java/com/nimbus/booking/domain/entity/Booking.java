package com.nimbus.booking.domain.entity;

import com.nimbus.kernel.domain.entity.User;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.entity.RideStop;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Booking entity representing a passenger's seat reservation on a ride.
 *
 * <p>State lifecycle: HELD → CONFIRMED → PICKED_UP → COMPLETED
 * Can be CANCELLED or EXPIRED from any pre-completion state.
 * FINANCIAL states (REFUND_PENDING, REFUNDED) are used after payment.</p>
 *
 * <p>Seat holds last 5 minutes. Seat allocation is transactional and prevents
 * concurrent overbooking via row locking in the repository/service layer.</p>
 */
@Entity
@Table(name = "bookings", indexes = {
    @Index(name = "idx_bookings_ride_id", columnList = "ride_id"),
    @Index(name = "idx_bookings_ride_id_status", columnList = "ride_id, status"),
    @Index(name = "idx_bookings_passenger_id_created_at", columnList = "passenger_id, created_at")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Booking {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ride_id", nullable = false, foreignKey = @ForeignKey(name = "fk_booking_ride"))
    private Ride ride;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passenger_id", nullable = false, foreignKey = @ForeignKey(name = "fk_booking_passenger"))
    private User passenger;

    @Column(name = "seats", nullable = false)
    @Builder.Default
    private Integer seats = 1;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private BookingStatus status = BookingStatus.HELD;

    @Column(name = "pickup_location", columnDefinition = "GEOMETRY(Point, 4326)")
    private String pickupLocation;

    @Column(name = "pickup_address", length = 500)
    private String pickupAddress;

    @Column(name = "dropoff_location", columnDefinition = "GEOMETRY(Point, 4326)")
    private String dropoffLocation;

    @Column(name = "dropoff_address", length = 500)
    private String dropoffAddress;

    @Column(name = "pickup_stop_id")
    private UUID pickupStopId;

    @Column(name = "dropoff_stop_id")
    private UUID dropoffStopId;

    @Column(name = "pickup_planned_time")
    private Instant pickupPlannedTime;

    @Column(name = "dropoff_planned_time")
    private Instant dropoffPlannedTime;

    @Column(name = "picked_up_at")
    private Instant pickedUpAt;

    @Column(name = "dropped_off_at")
    private Instant droppedOffAt;

    @Column(name = "fare_quote_id")
    private UUID fareQuoteId;

    @Column(name = "planned_distance_meters")
    private Integer plannedDistanceMeters;

    @Column(name = "planned_duration_seconds")
    private Integer plannedDurationSeconds;

    @Column(name = "final_payable", precision = 18, scale = 2)
    private BigDecimal finalPayable;

    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @Column(name = "cancelled_by")
    private UUID cancelledBy;

    @Column(name = "cancellation_reason", length = 500)
    private String cancellationReason;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum BookingStatus {
        HELD,          // Temporary 5-minute seat hold
        CONFIRMED,     // Committed seat
        PICKED_UP,     // Passenger boarded
        COMPLETED,     // Dropped off
        CANCELLED,     // Cancelled by passenger or driver
        EXPIRED,       // Hold expired
        REFUND_PENDING, // Refund in progress
        REFUNDED       // Refund completed
    }

    /**
     * Check if the booking is in an active state (can participate in ride).
     */
    public boolean isActive() {
        return status == BookingStatus.HELD ||
               status == BookingStatus.CONFIRMED ||
               status == BookingStatus.PICKED_UP;
    }

    /**
     * Check if the booking can be cancelled.
     */
    public boolean canBeCancelled() {
        return status == BookingStatus.HELD ||
               status == BookingStatus.CONFIRMED;
    }

    /**
     * Get the seat hold expiry time (5 minutes from creation).
     */
    public Instant getHoldExpiryTime() {
        return createdAt.plusSeconds(300); // 5 minutes
    }

    /**
     * Check if the seat hold has expired.
     */
    public boolean isHoldExpired() {
        return status == BookingStatus.HELD &&
               Instant.now().isAfter(getHoldExpiryTime());
    }

    /**
     * Transition booking status with validation.
     */
    public void transitionTo(BookingStatus newStatus) {
        validateTransition(this.status, newStatus);
        this.status = newStatus;
        this.updatedAt = Instant.now();
    }

    /**
     * Validate state transitions.
     */
    private void validateTransition(BookingStatus current, BookingStatus target) {
        if (current == target) {
            return;
        }

        Set<BookingStatus> allowedTransitions = switch (current) {
            case HELD -> Set.of(BookingStatus.CONFIRMED, BookingStatus.CANCELLED,
                               BookingStatus.EXPIRED, BookingStatus.REFUNDED);
            case CONFIRMED -> Set.of(BookingStatus.PICKED_UP, BookingStatus.CANCELLED,
                                   BookingStatus.REFUND_PENDING);
            case PICKED_UP -> Set.of(BookingStatus.COMPLETED, BookingStatus.REFUND_PENDING);
            case COMPLETED -> Set.of(BookingStatus.REFUND_PENDING);
            case CANCELLED, EXPIRED, REFUND_PENDING -> Set.of(BookingStatus.REFUNDED);
            case REFUNDED -> Set.of();
        };

        if (!allowedTransitions.contains(target)) {
            throw new IllegalStateException(
                "Cannot transition booking from " + current + " to " + target);
        }
    }
}
