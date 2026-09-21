package com.nimbus.safety.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import com.nimbus.safety.application.SosRequest;
import com.nimbus.safety.application.TripShareRequest;
import com.nimbus.safety.application.service.SafetyService;
import com.nimbus.safety.domain.entity.SafetyEvent;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Safety management endpoints.
 */
@RestController
@RequestMapping("/safety")
@RequiredArgsConstructor
public class SafetyController {

    private final SafetyService safetyService;

    /**
     * Trigger an SOS alert for a ride.
     * POST /safety/sos
     */
    @PostMapping("/sos")
    public ResponseEntity<ApiResponse<SafetyEvent>> triggerSos(@Valid @RequestBody SosRequest request) {
        UUID userId = getCurrentUserId();
        SafetyEvent event = safetyService.triggerSos(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<SafetyEvent>builder()
                        .success(true)
                        .data(event)
                        .message("SOS alert triggered")
                        .timestamp(java.time.Instant.now().toString())
                        .build());
    }

    /**
     * Start trip sharing for a ride.
     * POST /safety/trip-share
     */
    @PostMapping("/trip-share")
    public ResponseEntity<ApiResponse<Void>> startTripShare(@Valid @RequestBody TripShareRequest request) {
        UUID userId = getCurrentUserId();
        safetyService.startTripShare(userId, request);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Trip sharing started")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Get safety events for a ride.
     * GET /safety/events/rides/{rideId}
     */
    @GetMapping("/events/rides/{rideId}")
    public ResponseEntity<ApiResponse<List<SafetyEvent>>> getRideSafetyEvents(@PathVariable UUID rideId) {
        List<SafetyEvent> events = safetyService.getRideSafetyEvents(rideId);
        return ResponseEntity.ok(ApiResponse.<List<SafetyEvent>>builder()
                .success(true)
                .data(events)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Get all open safety events (admin/safety team).
     * GET /safety/events/open
     */
    @GetMapping("/events/open")
    public ResponseEntity<ApiResponse<List<SafetyEvent>>> getOpenSafetyEvents() {
        List<SafetyEvent> events = safetyService.getOpenSafetyEvents();
        return ResponseEntity.ok(ApiResponse.<List<SafetyEvent>>builder()
                .success(true)
                .data(events)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
