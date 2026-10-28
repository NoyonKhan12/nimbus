package com.nimbus.safety.application.service;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import com.nimbus.safety.application.SosRequest;
import com.nimbus.safety.application.TripShareRequest;
import com.nimbus.safety.domain.entity.SafetyEvent;
import com.nimbus.safety.domain.repository.SafetyEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.*;

/**
 * Safety service for SOS alerts and safety incident handling.
 *
 * <p>SOS alerts record the full journey context (ride, booking, driver,
 * vehicle, GPS — guide §19), broadcast SOS_TRIGGERED to the safety topic
 * and the ride topic in real time, and require escalation and operational
 * visibility. Trip sharing issues a public share token exposing minimum
 * required journey data only.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SafetyService {

    private static final String SAFETY_TOPIC = "/topic/safety/admin";

    private final SafetyEventRepository safetyEventRepository;
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final org.springframework.data.redis.core.StringRedisTemplate redisTemplate;
    private final com.nimbus.kernel.domain.repository.UserProfileRepository userProfileRepository;
    private final com.nimbus.audit.application.service.AuditService auditService;

    /**
     * Trigger an SOS alert for a ride.
     */
    @Transactional
    public SafetyEvent triggerSos(UUID userId, SosRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        Ride ride = rideRepository.findById(UUID.fromString(request.getRideId()))
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Authorization: only participants can trigger SOS
        List<Booking> rideBookings = bookingRepository.findByRideId(ride.getId());
        Booking callerBooking = rideBookings.stream()
                .filter(b -> b.getPassenger().getId().equals(userId))
                .findFirst()
                .orElse(null);
        boolean isDriver = ride.getCreator().getId().equals(userId);
        if (!isDriver && callerBooking == null) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        SafetyEvent event = SafetyEvent.builder()
                .ride(ride)
                .booking(callerBooking)
                .driver(ride.getDriver())
                .vehicleId(ride.getVehicleId())
                .user(user)
                .eventType(SafetyEvent.EventType.SOS)
                .latitude(request.getLatitude() != null ? BigDecimal.valueOf(request.getLatitude()) : null)
                .longitude(request.getLongitude() != null ? BigDecimal.valueOf(request.getLongitude()) : null)
                .description(request.getDescription())
                .status(SafetyEvent.EventStatus.OPEN)
                .createdAt(Instant.now())
                .build();

        SafetyEvent saved = safetyEventRepository.save(event);
        log.warn("SOS alert triggered: ride={} user={} event={}", ride.getId(), userId, saved.getId());

        // Real-time escalation visibility (guide §17/§19): safety topic for
        // operations plus the ride topic for everyone on the journey.
        broadcastSos(saved);

        return saved;
    }

    /** Pushes the SOS to the safety team topic and the ride topic. */
    private void broadcastSos(SafetyEvent event) {
        try {
            var payload = new HashMap<String, Object>();
            payload.put("event", "SOS_TRIGGERED");
            payload.put("safetyEventId", event.getId().toString());
            payload.put("rideId", event.getRide().getId().toString());
            payload.put("data", Map.of(
                    "userId", event.getUser().getId().toString(),
                    "latitude", event.getLatitude() != null ? event.getLatitude() : "unknown",
                    "longitude", event.getLongitude() != null ? event.getLongitude() : "unknown",
                    "description", event.getDescription() != null ? event.getDescription() : ""));
            payload.put("timestamp", Instant.now().toString());
            messagingTemplate.convertAndSend(SAFETY_TOPIC, payload);
            messagingTemplate.convertAndSend("/topic/ride/" + event.getRide().getId(), payload);
        } catch (Exception e) {
            log.error("Failed to broadcast SOS {}: {}", event.getId(), e.getMessage());
        }
    }

    /**
     * Start trip sharing for a ride. Issues a public share token valid for
     * the requested duration (default 60 minutes).
     */
    @Transactional
    public SafetyEvent startTripShare(UUID userId, TripShareRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        Ride ride = rideRepository.findById(UUID.fromString(request.getRideId()))
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Authorization
        boolean isDriver = ride.getCreator().getId().equals(userId);
        boolean isPassenger = bookingRepository.findByRideId(ride.getId()).stream()
                .anyMatch(b -> b.getPassenger().getId().equals(userId));
        if (!isDriver && !isPassenger) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        int durationMinutes = request.getDurationMinutes() != null
                && request.getDurationMinutes() > 0 ? request.getDurationMinutes() : 60;

        byte[] bytes = new byte[24];
        new SecureRandom().nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);

        SafetyEvent tripShare = SafetyEvent.builder()
                .ride(ride)
                .driver(ride.getDriver())
                .vehicleId(ride.getVehicleId())
                .user(user)
                .eventType(SafetyEvent.EventType.TRIP_SHARE)
                .description("Trip sharing started for " + durationMinutes + " minutes")
                .status(SafetyEvent.EventStatus.OPEN)
                .shareToken(token)
                .expiresAt(Instant.now().plusSeconds(durationMinutes * 60L))
                .createdAt(Instant.now())
                .build();

        SafetyEvent saved = safetyEventRepository.save(tripShare);
        log.info("Trip sharing started: ride={} user={} token issued", ride.getId(), userId);
        return saved;
    }

    /**
     * Minimal public journey data behind a trip-share token (guide §19:
     * expose minimum required journey data). No personal contact data.
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getTripShare(String token) {
        SafetyEvent share = safetyEventRepository.findByShareToken(token)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND,
                        "Trip share not found or expired", HttpStatus.NOT_FOUND));
        if (share.getExpiresAt() != null && share.getExpiresAt().isBefore(Instant.now())) {
            throw new NimbusException(ErrorCode.NOT_FOUND,
                    "Trip share has expired", HttpStatus.NOT_FOUND);
        }

        Ride ride = share.getRide();
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("rideId", ride.getId().toString());
        data.put("status", ride.getStatus().name());
        data.put("origin", ride.getOriginAddress());
        data.put("destination", ride.getDestinationAddress());
        data.put("scheduledAt", ride.getScheduledAt());
        if (ride.getDriver() != null && ride.getDriver().getUser() != null) {
            var profile = userProfileRepository
                    .findByUserId(ride.getDriver().getUser().getId()).orElse(null);
            data.put("driverName", profile != null && profile.getFirstName() != null
                    ? profile.getFirstName() : "Driver");
        }
        if (ride.getVehicleId() != null) {
            data.put("vehicleId", ride.getVehicleId().toString());
        }
        // Latest driver position (Redis first, driver profile fallback).
        String location = null;
        try {
            location = redisTemplate.opsForValue().get("ride:location:" + ride.getId());
        } catch (Exception ignored) { }
        if (location == null && ride.getDriver() != null
                && ride.getDriver().getCurrentLocation() != null) {
            location = ride.getDriver().getCurrentLocation();
        }
        data.put("driverLocation", location);
        data.put("updatedAt", Instant.now().toString());
        return data;
    }

    /**
     * One safety event — participant or operations roles only.
     */
    @Transactional(readOnly = true)
    public SafetyEvent getEvent(UUID eventId, UUID userId, boolean isOperationalRole) {
        SafetyEvent event = safetyEventRepository.findById(eventId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));
        if (isOperationalRole) return event;

        boolean participant = event.getUser().getId().equals(userId)
                || (event.getRide().getCreator() != null
                    && event.getRide().getCreator().getId().equals(userId))
                || bookingRepository.findByRideId(event.getRide().getId()).stream()
                    .anyMatch(b -> b.getPassenger().getId().equals(userId));
        if (!participant) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        return event;
    }

    /**
     * List safety events for a ride. Participants or operational roles
     * only — SOS events carry the reporter's location (guide §19).
     */
    @Transactional(readOnly = true)
    public List<SafetyEvent> getRideSafetyEvents(UUID rideId, UUID userId,
                                                 boolean operationalRole) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));
        if (!operationalRole) {
            boolean participant = ride.getCreator() != null
                    && ride.getCreator().getId().equals(userId)
                    || bookingRepository.findByRideId(rideId).stream()
                        .anyMatch(b -> b.getPassenger().getId().equals(userId));
            if (!participant) {
                throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
            }
        }
        return safetyEventRepository.findByRideId(rideId);
    }

    /**
     * Get open safety events for monitoring.
     */
    @Transactional(readOnly = true)
    public List<SafetyEvent> getOpenSafetyEvents() {
        return safetyEventRepository.findByStatus(SafetyEvent.EventStatus.OPEN);
    }

    /**
     * Update safety event status.
     */
    @Transactional
    public SafetyEvent updateSafetyEventStatus(UUID eventId, SafetyEvent.EventStatus status) {
        SafetyEvent event = safetyEventRepository.findById(eventId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));

        String oldStatus = event.getStatus() != null ? event.getStatus().name() : null;
        event.updateStatus(status);
        safetyEventRepository.save(event);

        auditService.logAction(currentUserIdOrNull(), "SAFETY_EVENT_STATUS_CHANGED",
                "SAFETY_EVENT", event.getId(), "status=" + oldStatus, "status=" + status.name());

        if (event.getEventType() == SafetyEvent.EventType.SOS) {
            try {
                messagingTemplate.convertAndSend("/topic/ride/" + event.getRide().getId(),
                        Map.of(
                                "event", "SOS_STATUS_CHANGED",
                                "safetyEventId", event.getId().toString(),
                                "data", Map.of("status", status.name()),
                                "timestamp", Instant.now().toString()));
            } catch (Exception e) {
                log.warn("Failed to broadcast SOS status: {}", e.getMessage());
            }
        }
        return event;
    }

    private UUID currentUserIdOrNull() {
        var auth = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }

    /** True when the caller holds an operations role (admin/ops/safety/support). */
    public static boolean callerHasOperationalRole() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) return false;
        return auth.getAuthorities().stream().anyMatch(a ->
                a.getAuthority().equals("ROLE_ADMIN")
                        || a.getAuthority().equals("ROLE_OPERATIONS")
                        || a.getAuthority().equals("ROLE_SAFETY")
                        || a.getAuthority().equals("ROLE_SUPPORT"));
    }
}
