package com.nimbus.kernel.infrastructure.config;

import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.kernel.infrastructure.security.JwtTokenUtil;
import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.*;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.*;
import org.springframework.stereotype.Component;

import java.util.UUID;

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
    private final JwtTokenUtil jwtTokenUtil;
    private final UserRepository userRepository;

    public WebSocketChannelInterceptor(RideRepository rideRepository,
                                       BookingRepository bookingRepository,
                                       JwtTokenUtil jwtTokenUtil,
                                       UserRepository userRepository) {
        this.rideRepository = rideRepository;
        this.bookingRepository = bookingRepository;
        this.jwtTokenUtil = jwtTokenUtil;
        this.userRepository = userRepository;
    }

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);

        if (accessor == null) return message;

        // Authenticate on CONNECT: the JWT arrives in the `authorization`
        // STOMP header; stash the verified userId in the session attributes
        // so the SUBSCRIBE authorization below is enforced. Without this,
        // any socket could subscribe to any ride topic.
        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            String auth = accessor.getFirstNativeHeader("authorization");
            if (auth != null && auth.startsWith("Bearer ")) {
                try {
                    String token = auth.substring(7).trim();
                    if (jwtTokenUtil.isAccessToken(token)) {
                        UUID userId = jwtTokenUtil.getUserIdFromToken(token);
                        userRepository.findById(userId).ifPresent(user ->
                                accessor.getSessionAttributes().put("userId", userId.toString()));
                    }
                } catch (Exception e) {
                    log.warn("WebSocket CONNECT with invalid token: {}", e.getMessage());
                }
            }
            if (accessor.getSessionAttributes() == null
                    || !accessor.getSessionAttributes().containsKey("userId")) {
                log.warn("WebSocket CONNECT rejected: no valid authorization header");
                throw new IllegalArgumentException("Authentication required");
            }
            return message;
        }

        String destination = accessor.getDestination();
        if (destination == null) return message;

        // Check subscription to ride topics
        if (destination.startsWith("/topic/ride/")) {
            String rideIdStr = destination.substring("/topic/ride/".length()).split("/")[0];
            UUID rideId;
            try {
                rideId = UUID.fromString(rideIdStr);
            } catch (IllegalArgumentException e) {
                log.warn("Invalid ride ID in WebSocket destination: {}", rideIdStr);
                throw new IllegalArgumentException("Invalid destination");
            }
            String userIdStr = (String) accessor.getSessionAttributes().get("userId");
            if (userIdStr == null || !isAuthorizedForRide(rideId,
                    UUID.fromString(userIdStr))) {
                log.warn("Unauthorized WebSocket access: user={} ride={}", userIdStr, rideId);
                throw new IllegalArgumentException("Not authorized for this ride");
            }
        }

        // Private topics are strictly self-serve (guide §17/§18): a user is
        // only ever subscribed to their own driver/user topic.
        if (destination.startsWith("/topic/driver/") || destination.startsWith("/topic/user/")) {
            String targetIdStr = destination.substring(destination.lastIndexOf('/') + 1);
            String userIdStr = (String) accessor.getSessionAttributes().get("userId");
            if (userIdStr == null || !userIdStr.equalsIgnoreCase(targetIdStr)) {
                log.warn("Unauthorized WebSocket access: user={} target={}", userIdStr, targetIdStr);
                throw new IllegalArgumentException("Not authorized for this topic");
            }
        }

        // Safety topics carry live SOS broadcasts with the reporter's
        // location — operational roles only (guide §19/§20).
        if (destination.startsWith("/topic/safety")) {
            String userIdStr = (String) accessor.getSessionAttributes().get("userId");
            boolean ops = false;
            if (userIdStr != null) {
                ops = userRepository.findById(UUID.fromString(userIdStr))
                        .map(u -> switch (u.getRole()) {
                            case ADMIN, OPERATIONS, SAFETY -> true;
                            default -> false;
                        })
                        .orElse(false);
            }
            if (!ops) {
                log.warn("Unauthorized WebSocket access to safety topic: user={}", userIdStr);
                throw new IllegalArgumentException("Not authorized for this topic");
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
