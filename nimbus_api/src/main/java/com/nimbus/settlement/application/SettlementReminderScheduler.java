package com.nimbus.settlement.application;

import com.nimbus.notification.application.service.NotificationService;
import com.nimbus.notification.domain.entity.Notification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

/**
 * Settlement reminder job (guide §25): notifies drivers whose outstanding
 * due blocks new eligibility until it is cleared (guide §5/§13).
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class SettlementReminderScheduler {

    private final SettlementService settlementService;
    private final NotificationService notificationService;

    @Scheduled(cron = "${nimbus.settlement.reminder-cron:0 0 8 * * *}", zone = "Asia/Dhaka")
    @Transactional
    public void remindDriversWithDue() {
        var drivers = settlementService.findDriversWithDue();
        for (var driver : drivers) {
            try {
                notificationService.sendNotification(
                        driver.getUser().getId(),
                        Notification.NotificationType.SETTLEMENT_REMINDER,
                        "Outstanding due",
                        "You have an outstanding due of " + driver.getDueAmount()
                                + " BDT. Please clear it to continue accepting rides.",
                        Map.of("dueAmount", driver.getDueAmount().toString()));
            } catch (Exception e) {
                log.warn("Settlement reminder failed for driver {}: {}",
                        driver.getId(), e.getMessage());
            }
        }
        if (!drivers.isEmpty()) {
            log.info("Settlement reminders sent to {} drivers", drivers.size());
        }
    }
}
