package com.nimbus.notification.application;

import com.nimbus.notification.application.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Notification retry job (guide §25): re-attempts transiently failed
 * external deliveries (FCM/SMS) on their way to a terminal FAILED state.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationRetryScheduler {

    private final NotificationService notificationService;

    @Scheduled(cron = "${nimbus.notifications.retry-cron:0 */15 * * * *}")
    public void retryPendingDeliveries() {
        notificationService.retryPendingDeliveries();
    }
}
