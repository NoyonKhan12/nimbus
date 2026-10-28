package com.nimbus.ride.application;

import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

/**
 * Materializes the next instance of every active recurring ride template
 * (guide §2/§25). A template is a RECURRING ride with parentRideId null;
 * each materialized instance is a concrete PUBLISHED ride pointing back at
 * its template. One instance is created per cycle ahead of the template's
 * slot; the instance carries the same route/seats/constraints.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RecurringRideMaterializer {

    private final RideRepository rideRepository;

    @Scheduled(cron = "${nimbus.recurring.cron:0 17 * * * *}")
    @Transactional
    public void materializeNextInstances() {
        Instant now = Instant.now();
        List<Ride> templates = rideRepository.findActiveRecurringTemplates(now);
        int created = 0;
        for (Ride template : templates) {
            if (template.getScheduledAt() == null) continue;
            try {
                if (createNextInstance(template, now)) created++;
            } catch (Exception e) {
                log.error("Failed to materialize instance for template {}: {}",
                        template.getId(), e.getMessage());
            }
        }
        if (created > 0) {
            log.info("Recurring materializer created {} ride instances", created);
        }
    }

    /** Creates the next occurrence of the template if not already present. */
    private boolean createNextInstance(Ride template, Instant now) {
        Instant slot = nextSlotAfter(template, now);
        if (slot == null) return false;
        if (template.getRecurrenceUntil() != null && slot.isAfter(template.getRecurrenceUntil())) {
            return false;
        }
        if (rideRepository.existsByParentRideIdAndScheduledAtIsGreaterThanEqual(
                template.getId(), slot.minusSeconds(60))) {
            return false;
        }

        Ride instance = Ride.builder()
                .creator(template.getCreator())
                .driver(template.getDriver())
                .vehicleId(template.getVehicleId())
                .type(Ride.RideType.SCHEDULED)
                .scheduledAt(slot)
                .recurrenceType(Ride.RecurrenceType.NONE)
                .parentRideId(template.getId())
                .status(Ride.RideStatus.PUBLISHED)
                .originLocation(template.getOriginLocation())
                .originAddress(template.getOriginAddress())
                .destinationLocation(template.getDestinationLocation())
                .destinationAddress(template.getDestinationAddress())
                .availableSeats(template.getAvailableSeats())
                .maxDetourMeters(template.getMaxDetourMeters())
                .maxWaitSeconds(template.getMaxWaitSeconds())
                .notes(template.getNotes())
                .routeVersion(0)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        rideRepository.save(instance);
        log.info("Materialized recurring ride {} from template {} at {}",
                instance.getId(), template.getId(), slot);
        return true;
    }

    /** Next template slot strictly after {@code now} (never more than one period back). */
    private Instant nextSlotAfter(Ride template, Instant now) {
        Duration period = template.getRecurrenceType() == Ride.RecurrenceType.WEEKLY
                ? Duration.ofDays(7) : Duration.ofDays(1);
        Instant slot = template.getScheduledAt();
        // Advance until the slot is in the future, bounded to avoid loops on
        // very old templates.
        int guard = 0;
        while (!slot.isAfter(now) && guard++ < 400) {
            slot = slot.plus(period);
        }
        return slot.isAfter(now) ? slot : null;
    }
}
