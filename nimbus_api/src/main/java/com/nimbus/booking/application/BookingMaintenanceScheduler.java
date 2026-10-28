package com.nimbus.booking.application;

import com.nimbus.booking.domain.repository.BookingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;

/**
 * Booking maintenance jobs (guide §25).
 *
 * <p>Expires stale seat holds: a HELD booking older than the hold window
 * is moved to EXPIRED and the seats return to availability. Runs every
 * minute; the seat-hold window comes from configuration (default 5 min).</p>
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class BookingMaintenanceScheduler {

    private final BookingRepository bookingRepository;

    @Value("${nimbus.booking.seat-hold-minutes:5}")
    private int seatHoldMinutes;

    /**
     * Expired holds job — runs every minute.
     */
    @Scheduled(fixedDelay = 60_000)
    @Transactional
    public void expireStaleSeatHolds() {
        Instant cutoff = Instant.now().minus(Duration.ofMinutes(seatHoldMinutes));
        int expired = bookingRepository.expireStaleHolds(cutoff);
        if (expired > 0) {
            log.info("Expired {} stale seat holds (older than {} min)", expired, seatHoldMinutes);
        }
    }
}
