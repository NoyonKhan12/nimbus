package com.nimbus.safety.domain.entity;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.ride.domain.entity.Ride;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Safety event entity for SOS alerts and safety incidents.
 *
 * <p>Records ride/booking, GPS coordinates, and timestamp.
 * Requires escalation and operational visibility.</p>
 */
@Entity
@Table(name = "safety_events", indexes = {
    @Index(name = "idx_safety_events_ride_id", columnList = "ride_id"),
    @Index(name = "idx_safety_events_user_id", columnList = "user_id"),
    @Index(name = "idx_safety_events_status", columnList = "status")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SafetyEvent {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ride_id", foreignKey = @ForeignKey(name = "fk_safety_ride"))
    private Ride ride;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", foreignKey = @ForeignKey(name = "fk_safety_booking"))
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_safety_user"))
    private User user;

    @Column(name = "event_type", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private EventType eventType;

    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private EventStatus status = EventStatus.OPEN;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum EventType {
        SOS,            // Emergency SOS alert
        SAFETY_CHECK,   // Automated safety check
        INCIDENT,       // Safety incident report
        TRIP_SHARE      // Trip sharing activated
    }

    public enum EventStatus {
        OPEN,        // New event
        IN_PROGRESS, // Being responded to
        RESOLVED,    // Resolved
        ESCALATED    // Escalated to authorities
    }

    /**
     * Update event status.
     */
    public void updateStatus(EventStatus newStatus) {
        this.status = newStatus;
        this.updatedAt = Instant.now();
    }
}
