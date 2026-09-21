package com.nimbus.complaint.domain.entity;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Complaint entity with operational status and resolution audit.
 */
@Entity
@Table(name = "complaints", indexes = {
    @Index(name = "idx_complaints_user_id", columnList = "user_id"),
    @Index(name = "idx_complaints_booking_id", columnList = "booking_id"),
    @Index(name = "idx_complaints_status", columnList = "status")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Complaint {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", foreignKey = @ForeignKey(name = "fk_complaint_booking"))
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_complaint_user"))
    private User user;

    @Column(name = "category", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private ComplaintCategory category;

    @Column(name = "description", nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private ComplaintStatus status = ComplaintStatus.OPEN;

    @Column(name = "resolution", columnDefinition = "TEXT")
    private String resolution;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum ComplaintCategory {
        DRIVER_BEHAVIOR,
        SAFETY,
        CLEANLINESS,
        DELAY,
        OVERCHARGING,
        APP_ISSUE,
        OTHER
    }

    public enum ComplaintStatus {
        OPEN,        // New complaint
        IN_PROGRESS, // Being reviewed
        RESOLVED,    // Resolved
        CLOSED       // Closed without action
    }

    /**
     * Update complaint status.
     */
    public void updateStatus(ComplaintStatus newStatus, String resolution) {
        this.status = newStatus;
        this.resolution = resolution;
        this.updatedAt = Instant.now();
    }
}
