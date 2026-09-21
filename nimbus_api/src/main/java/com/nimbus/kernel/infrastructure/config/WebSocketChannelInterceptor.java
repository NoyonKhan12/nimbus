package com.nimbus.kernel.infrastructure.config;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.*;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.*;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * Channel interceptor for WebSocket authorization.
 *
 * <p>Validates that the authenticated user can access the requested ride topic.
 * Subscribers are authorized based on their role in the ride (driver or passenger).</p>
 */
@Component
@Slf4j
public class WebSocketChannelInterceptor implements ChannelInterceptor {

    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;

    public WebSocketChannelInterceptor(RideRepository rideRepository,
                                       BookingRepository bookingRepository) {
        this.rideRepository = rideRepository;
        this.bookingRepository = bookingRepository;
    }

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);

        if (accessor == null) return message;

        String destination = accessor.getDestination();
        if (destination == null) return message;

        // Check subscription to ride topics
        if (destination.startsWith("/topic/ride/")) {
            String rideIdStr = destination.substring("/topic/ride/".length()).split("/")[0];
            try {
                UUID rideId = UUID.fromString(rideIdStr);
                String userIdStr = (String) accessor.getSessionAttributes().get("userId");
                if (userIdStr != null) {
                    UUID userId = UUID.fromString(userIdStr);
                    if (!isAuthorizedForRide(rideId, userId)) {
                        log.warn("Unauthorized WebSocket access: user={} ride={}", userId, rideId);
                        throw new IllegalArgumentException("Not authorized for this ride");
                    }
                }
            } catch (IllegalArgumentException e) {
                log.warn("Invalid ride ID in WebSocket destination: {}", rideIdStr);
            }
        }

        return message;
    }

    private boolean isAuthorizedForRide(UUID rideId, UUID userId) {
        // Check if user is the ride creator (driver)
        Optional<Ride> rideOpt = rideRepository.findById(rideId);
        if (rideOpt.isPresent()) {
            Ride ride = rideOpt.get();
            if (ride.getCreator() != null && ride.getCreator().getId().equals(userId)) {
                return true;
            }
            if (ride.getDriver() != null && ride.getDriver().getUser().getId().equals(userId)) {
                return true;
            }
        }

        // Check if user is a passenger on this ride
        List<Booking> bookings = bookingRepository.findByRideId(rideId);
        return bookings.stream()
                .anyMatch(b -> b.getPassenger().getId().equals(userId));
    }
}
