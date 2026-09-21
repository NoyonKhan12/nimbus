package com.nimbus.notification.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Notification delivery record for audit and retry.
 *
 * <p>Tracks delivery status across channels (FCM, SMS, Email, In-App).
 * Failed deliveries are retried via scheduled job.</p>
 */
@Entity
@Table(name = "notification_deliveries", indexes = {
    @Index(name = "idx_notification_deliveries_notification_id", columnList = "notification_id"),
    @Index(name = "idx_notification_deliveries_status", columnList = "delivery_status"),
    @Index(name = "idx_notification_deliveries_created_at", columnList = "created_at")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDelivery {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "notification_id", nullable = false, foreignKey = @ForeignKey(name = "fk_delivery_notification"))
    private Notification notification;

    @Column(name = "channel", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private DeliveryChannel channel;

    @Column(name = "provider_reference", length = 255)
    private String providerReference;

    @Column(name = "delivery_status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private DeliveryStatus deliveryStatus = DeliveryStatus.PENDING;

    @Column(name = "retry_count", nullable = false)
    @Builder.Default
    private Integer retryCount = 0;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum DeliveryChannel {
        FCM,      // Firebase Cloud Messaging (push)
        SMS,      // SMS provider
        EMAIL,    // Email provider
        IN_APP    // In-app notification
    }

    public enum DeliveryStatus {
        PENDING,      // Waiting to be sent
        SENT,         // Successfully sent
        DELIVERED,    // Confirmed delivered
        FAILED,       // Failed delivery
        RETRYING      // Retry in progress
    }

    /**
     * Record a delivery attempt.
     */
    public void markSent(String providerReference) {
        this.providerReference = providerReference;
        this.deliveryStatus = DeliveryStatus.SENT;
        this.updatedAt = Instant.now();
    }

    /**
     * Record delivery failure and increment retry count.
     */
    public void markFailed() {
        this.retryCount++;
        this.deliveryStatus = retryCount < 3 ? DeliveryStatus.RETRYING : DeliveryStatus.FAILED;
        this.updatedAt = Instant.now();
    }
}
