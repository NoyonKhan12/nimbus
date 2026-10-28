package com.nimbus.notification.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.notification.application.NotificationResponse;
import com.nimbus.notification.domain.entity.Notification;
import com.nimbus.notification.domain.entity.NotificationDelivery;
import com.nimbus.notification.domain.repository.NotificationDeliveryRepository;
import com.nimbus.notification.domain.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Notification service for sending push notifications, SMS, and in-app messages.
 *
 * <p>Notifications are persisted first, then dispatched via the appropriate
 * channel. Delivery status is tracked for audit purposes.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationDeliveryRepository deliveryRepository;
    private final UserRepository userRepository;

    /**
     * Send a notification to a user.
     */
    // NESTED uses a savepoint: a notification failure rolls back only the
    // notification, never the payment/booking transaction that called it.
    // Notifications are best-effort and must not undo a financial commit.
    @Transactional(propagation = Propagation.NESTED)
    public NotificationResponse sendNotification(UUID userId, Notification.NotificationType type,
                                                  String title, String body, Map<String, Object> data) {
        Optional<User> recipient = userRepository.findById(userId);
        if (recipient.isEmpty()) {
            // A soft-deleted/missing recipient is not an error for the
            // caller; skip delivery and keep the business transaction intact.
            log.warn("Skipping notification {} for missing user {}", type, userId);
            return null;
        }
        User user = recipient.get();

        Notification notification = Notification.builder()
                .user(user)
                .type(type)
                .title(title)
                .content(body)
                .metadata(data != null ? data.toString() : null)
                .createdAt(Instant.now())
                .build();

        Notification saved = notificationRepository.save(notification);

        // Dispatch notification
        dispatchNotification(saved);

        return toResponse(saved);
    }

    /**
     * Send notification to multiple users.
     */
    @Transactional
    public List<NotificationResponse> sendBulkNotification(List<UUID> userIds,
                                                            Notification.NotificationType type,
                                                            String title, String body) {
        return userIds.stream()
                .map(userId -> sendNotification(userId, type, title, body, null))
                .collect(Collectors.toList());
    }

    /**
     * Get user's notifications (recent).
     */
    @Transactional(readOnly = true)
    public List<NotificationResponse> getUserNotifications(UUID userId, int limit) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .limit(limit)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Mark notification as read.
     */
    @Transactional
    public void markAsRead(UUID notificationId, UUID userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!notification.getUser().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        notification.markAsRead();
        notificationRepository.save(notification);
    }

    /**
     * Dispatch notification via appropriate channel.
     */
    private void dispatchNotification(Notification notification) {
        NotificationDelivery delivery = NotificationDelivery.builder()
                .notification(notification)
                .deliveryStatus(NotificationDelivery.DeliveryStatus.PENDING)
                .channel(NotificationDelivery.DeliveryChannel.IN_APP)
                .createdAt(Instant.now())
                .build();

        try {
            // Determine delivery channel based on type
            switch (notification.getType()) {
                case OTP -> delivery.setChannel(NotificationDelivery.DeliveryChannel.SMS);
                case SYSTEM_ANNOUNCEMENT, VOUCHER -> delivery.setChannel(NotificationDelivery.DeliveryChannel.FCM);
                default -> delivery.setChannel(NotificationDelivery.DeliveryChannel.IN_APP);
            }

            if (delivery.getChannel() == NotificationDelivery.DeliveryChannel.IN_APP) {
                // In-app is inherently delivered: clients poll
                // GET /notifications. External channels (FCM/SMS) stay
                // PENDING until a provider adapter delivers them, and the
                // retry job (guide §25) re-attempts transient failures.
                delivery.markSent(null);
            } else {
                log.info("Notification {} queued on channel {} for external dispatch",
                        notification.getId(), delivery.getChannel());
            }
        } catch (Exception e) {
            log.error("Failed to send notification: {}", notification.getId(), e);
            delivery.markFailed();
        }

        deliveryRepository.save(delivery);
    }

    /**
     * Retry transiently-failed external deliveries (guide §25). Called by
     * the notification retry scheduler; FCM/SMS provider adapters hook in
     * here when they replace the queue-and-retry placeholder.
     *
     * @return number of deliveries re-attempted
     */
    @Transactional
    public int retryPendingDeliveries() {
        var deliverables = deliveryRepository.findByDeliveryStatusIn(List.of(
                NotificationDelivery.DeliveryStatus.PENDING,
                NotificationDelivery.DeliveryStatus.RETRYING));
        int attempted = 0;
        for (NotificationDelivery delivery : deliverables) {
            // No external provider is wired yet: each retry pass marks the
            // attempt and eventually fails it out after 3 tries.
            delivery.markFailed();
            deliveryRepository.save(delivery);
            attempted++;
        }
        if (attempted > 0) {
            log.info("Notification retry pass: {} deliveries re-attempted", attempted);
        }
        return attempted;
    }

    private NotificationResponse toResponse(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .userId(notification.getUser() != null ? notification.getUser().getId() : null)
                .type(notification.getType().name())
                .title(notification.getTitle())
                .content(notification.getContent())
                .isRead(notification.isRead())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
