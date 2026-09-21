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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Safety service for SOS alerts and safety incident handling.
 *
 * <p>SOS alerts are broadcast via WebSocket to the safety team for immediate
 * response. Trip sharing allows users to share their live location during a ride.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SafetyService {

    private final SafetyEventRepository safetyEventRepository;
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;

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
        if (!ride.getCreator().getId().equals(userId)) {
            // Check if user is a passenger
            boolean isPassenger = bookingRepository.findByRideId(ride.getId()).stream()
                    .anyMatch(b -> b.getPassenger().getId().equals(userId));
            if (!isPassenger) {
                throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
            }
        }

        SafetyEvent event = SafetyEvent.builder()
                .ride(ride)
                .user(user)
                .eventType(SafetyEvent.EventType.SOS)
                .latitude(request.getLatitude() != null ? BigDecimal.valueOf(request.getLatitude()) : null)
                .longitude(request.getLongitude() != null ? BigDecimal.valueOf(request.getLongitude()) : null)
                .description(request.getDescription())
                .status(SafetyEvent.EventStatus.OPEN)
                .createdAt(Instant.now())
                .build();

        SafetyEvent saved = safetyEventRepository.save(event);
        log.warn("SOS alert triggered: ride={} user={}", ride.getId(), userId);

        // In production, broadcast via WebSocket to safety team
        // and trigger SMS/call escalation

        return saved;
    }

    /**
     * Start trip sharing for a ride.
     */
    @Transactional
    public void startTripShare(UUID userId, TripShareRequest request) {
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

        SafetyEvent tripShare = SafetyEvent.builder()
                .ride(ride)
                .user(user)
                .eventType(SafetyEvent.EventType.TRIP_SHARE)
                .description("Trip sharing started for " + request.getDurationMinutes() + " minutes")
                .status(SafetyEvent.EventStatus.OPEN)
                .createdAt(Instant.now())
                .build();

        safetyEventRepository.save(tripShare);
        log.info("Trip sharing started: ride={} user={}", ride.getId(), userId);
    }

    /**
     * List safety events for a ride.
     */
    @Transactional(readOnly = true)
    public List<SafetyEvent> getRideSafetyEvents(UUID rideId) {
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
    public void updateSafetyEventStatus(UUID eventId, SafetyEvent.EventStatus status) {
        SafetyEvent event = safetyEventRepository.findById(eventId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));

        event.updateStatus(status);
        safetyEventRepository.save(event);
    }
}
