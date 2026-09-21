package com.nimbus.notification.domain.entity;

import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.*;

/**
 * Notification entity for push/in-app notifications.
 *
 * <p>Supports delivery retry queue for transient failures.
 * Notifications are stored for user history.</p>
 */
@Entity
@Table(name = "notifications", indexes = {
    @Index(name = "idx_notifications_user_id", columnList = "user_id"),
    @Index(name = "idx_notifications_is_read", columnList = "is_read"),
    @Index(name = "idx_notifications_created_at", columnList = "created_at DESC")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_notification_user"))
    private User user;

    @Column(name = "type", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private NotificationType type;

    @Column(name = "title", length = 255)
    private String title;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "is_read", nullable = false)
    @Builder.Default
    private boolean read = false;

    @Column(name = "metadata", columnDefinition = "JSONB")
    private String metadata;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @OneToMany(mappedBy = "notification", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<NotificationDelivery> deliveries = new ArrayList<>();

    public enum NotificationType {
        OTP,                  // OTP verification
        RIDE_REMINDER,        // Upcoming scheduled ride
        MATCHING,             // Ride matched successfully
        BOOKING_CONFIRMED,    // Booking confirmed
        PICKUP_REMINDER,      // Driver approaching pickup
        DRIVER_ASSIGNMENT,    // Driver assigned
        PAYMENT_RECEIVED,     // Payment processed
        SETTLEMENT_READY,     // Settlement processed
        SETTLEMENT_REMINDER,  // Settlement reminder
        SOS,                  // Safety alert
        TRIP_SHARE,           // Trip sharing activated
        COMPLAINT_STATUS,     // Complaint status update
        SYSTEM_ANNOUNCEMENT,  // General announcements
        VOUCHER,              // Voucher offer/expiry
        RATING_REQUEST        // Post-trip rating request
    }

    /**
     * Mark notification as read.
     */
    public void markAsRead() {
        this.read = true;
    }

    /**
     * Add a delivery attempt.
     */
    public void addDelivery(NotificationDelivery delivery) {
        deliveries.add(delivery);
    }
}
