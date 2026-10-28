package com.nimbus.ride.application;

import com.nimbus.booking.application.service.BookingService;
import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.notification.application.service.NotificationService;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.*;

/**
 * Ride reminder job (guide §25): notifies the driver and all confirmed
 * passengers ~30 minutes before a scheduled ride departs. Deduplicated
 * in-memory per ride (a restart may re-notify once — harmless).
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RideReminderScheduler {

    private final RideRepository rideRepository;
    private final BookingService bookingService;
    private final NotificationService notificationService;

    private final Set<String> reminded = Collections.synchronizedSet(new HashSet<>());

    @Scheduled(fixedDelay = 60_000)
    @Transactional(readOnly = true)
    public void sendRideReminders() {
        Instant now = Instant.now();
        Instant windowEnd = now.plus(Duration.ofMinutes(30));
        List<Ride> upcoming = rideRepository.findByStatusAndScheduledAfter(
                Ride.RideStatus.PUBLISHED, now);

        for (Ride ride : upcoming) {
            if (ride.getScheduledAt() == null || ride.getScheduledAt().isAfter(windowEnd)) continue;
            if (ride.getCreator() == null) continue;

            String key = "ride:" + ride.getId();
            if (!reminded.add(key)) continue;

            try {
                List<UUID> recipients = new ArrayList<>();
                recipients.add(ride.getCreator().getId());
                if (ride.getDriver() != null && ride.getDriver().getUser() != null) {
                    recipients.add(ride.getDriver().getUser().getId());
                }
                for (Booking b : bookingService.getRideBookingEntities(ride.getId())) {
                    if (b.getPassenger() != null) recipients.add(b.getPassenger().getId());
                }
                for (UUID userId : new LinkedHashSet<>(recipients)) {
                    notificationService.sendNotification(userId,
                            com.nimbus.notification.domain.entity.Notification.NotificationType.RIDE_REMINDER,
                            "Ride starting soon",
                            "Your ride departs at " + ride.getScheduledAt()
                                    + ". Get ready for pickup.",
                            java.util.Map.of("rideId", ride.getId().toString()));
                }
                log.info("Sent ride reminders for ride {} to {} recipients",
                        ride.getId(), recipients.size());
            } catch (Exception e) {
                log.warn("Failed to send reminders for ride {}: {}",
                        ride.getId(), e.getMessage());
            }
        }
    }
}
