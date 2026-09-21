package com.nimbus.safety.application.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.*;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.Map;

/**
 * WebSocket controller for real-time ride updates and location sharing.
 *
 * <p>
 * Clients subscribe to /topic/ride/{rideId} for real-time updates.
 * </p>
 */
@Controller
public class WebSocketController {

    private final SimpMessagingTemplate messagingTemplate;

    @Autowired
    public WebSocketController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    /**
     * Broadcast location updates to all subscribers of a ride.
     *
     * @param rideId  The ride ID
     * @param location Location data (latitude, longitude, etc.)
     */
    public void broadcastLocationUpdate(String rideId, Map<String, Object> location) {
        messagingTemplate.convertAndSend("/topic/ride/" + rideId,
                Map.of(
                        "event", "RIDE_LOCATION_UPDATED",
                        "rideId", rideId,
                        "data", location,
                        "timestamp", java.time.Instant.now().toString()
                ));
    }

    /**
     * Broadcast ride status changes.
     */
    public void broadcastStatusChange(String rideId, Map<String, Object> data) {
        messagingTemplate.convertAndSend("/topic/ride/" + rideId,
                Map.of(
                        "event", "RIDE_STATUS_CHANGED",
                        "rideId", rideId,
                        "data", data,
                        "timestamp", java.time.Instant.now().toString()
                ));
    }

    /**
     * Broadcast SOS events with high priority.
     */
    public void broadcastSOS(String rideId, Map<String, Object> data) {
        messagingTemplate.convertAndSend("/topic/ride/" + rideId,
                Map.of(
                        "event", "SOS_TRIGGERED",
                        "rideId", rideId,
                        "data", data,
                        "timestamp", java.time.Instant.now().toString()
                ));

        // Also broadcast to safety team
        messagingTemplate.convertAndSend("/topic/safety/sos",
                Map.of(
                        "event", "SOS_TRIGGERED",
                        "rideId", rideId,
                        "data", data,
                        "timestamp", java.time.Instant.now().toString()
                ));
    }

    /**
     * Send a direct message to a specific user.
     */
    public void sendToUser(String userId, Map<String, Object> message) {
        messagingTemplate.convertAndSend("/topic/user/" + userId,
                message);
    }
}
