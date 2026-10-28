package com.nimbus.booking.infrastructure;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.UUID;

/**
 * Redis mirror of DB seat holds (guide §14: ride:seat-hold:{rideId}:{bookingId},
 * TTL = hold duration). Redis is not the source of truth — the bookings table
 * drives the expiry job — but the TTL mirror gives operations a fast view of
 * live holds and auto-cleans on confirmation/cancel.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class SeatHoldStore {

    private final StringRedisTemplate redisTemplate;

    private static final String KEY_PREFIX = "ride:seat-hold:";

    /** Mirrors a new HELD booking into Redis with a hold-duration TTL. */
    public void hold(UUID rideId, UUID bookingId, Duration ttl) {
        try {
            redisTemplate.opsForValue().set(KEY_PREFIX + rideId + ":" + bookingId,
                    "HELD", ttl);
        } catch (Exception e) {
            log.warn("Seat-hold mirror write failed (DB remains authoritative): {}", e.getMessage());
        }
    }

    /** Removes the mirror once the hold is converted or released. */
    public void release(UUID rideId, UUID bookingId) {
        try {
            redisTemplate.delete(KEY_PREFIX + rideId + ":" + bookingId);
        } catch (Exception e) {
            log.warn("Seat-hold mirror delete failed: {}", e.getMessage());
        }
    }
}
