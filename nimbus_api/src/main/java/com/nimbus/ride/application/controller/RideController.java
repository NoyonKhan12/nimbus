package com.nimbus.ride.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.ride.application.CreateRideRequest;
import com.nimbus.ride.application.RideResponse;
import com.nimbus.ride.application.service.RideService;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.*;

/**
 * Ride management endpoints.
 */
@RestController
@RequestMapping("/rides")
@RequiredArgsConstructor
public class RideController {

    private final RideService rideService;

    /**
     * Create a new ride.
     * POST /rides
     */
    @PostMapping
    public ResponseEntity<ApiResponse<RideResponse>> createRide(@Valid @RequestBody CreateRideRequest request) {
        UUID userId = getCurrentUserId();
        RideResponse response = rideService.createRide(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<RideResponse>builder()
                        .success(true)
                        .data(response)
                        .message("Ride created successfully")
                        .timestamp(Instant.now().toString())
                        .build());
    }

    /**
     * Get ride details.
     * GET /rides/{rideId}
     */
    @GetMapping("/{rideId}")
    public ResponseEntity<ApiResponse<RideResponse>> getRide(@PathVariable UUID rideId) {
        RideResponse response = rideService.getRide(rideId);
        return ResponseEntity.ok(ApiResponse.<RideResponse>builder()
                .success(true)
                .data(response)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * List rides for current user (as driver or creator).
     * GET /rides
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<RideResponse>>> listRides(
            @RequestParam(required = false) String status) {
        UUID userId = getCurrentUserId();
        List<RideResponse> rides = rideService.listRides(userId, status);
        return ResponseEntity.ok(ApiResponse.<List<RideResponse>>builder()
                .success(true)
                .data(rides)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Update a ride (only when in DRAFT state).
     * PUT /rides/{rideId}
     */
    @PutMapping("/{rideId}")
    public ResponseEntity<ApiResponse<RideResponse>> updateRide(
            @PathVariable UUID rideId, @Valid @RequestBody CreateRideRequest request) {
        UUID userId = getCurrentUserId();
        RideResponse response = rideService.updateRide(rideId, userId, request);
        return ResponseEntity.ok(ApiResponse.<RideResponse>builder()
                .success(true)
                .data(response)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Publish a ride (make it searchable).
     * POST /rides/{rideId}/publish
     */
    @PostMapping("/{rideId}/publish")
    public ResponseEntity<ApiResponse<RideResponse>> publishRide(@PathVariable UUID rideId) {
        UUID userId = getCurrentUserId();
        RideResponse response = rideService.publishRide(rideId, userId);
        return ResponseEntity.ok(ApiResponse.<RideResponse>builder()
                .success(true)
                .data(response)
                .message("Ride published successfully")
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Search for rides.
     * GET /rides/search
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<RideResponse>>> searchRides(
            @RequestParam Double originLat,
            @RequestParam Double originLng,
            @RequestParam Double destLat,
            @RequestParam Double destLng,
            @RequestParam(required = false) Instant time) {
        List<RideResponse> rides = rideService.searchRides(originLat, originLng, destLat, destLng, time);
        return ResponseEntity.ok(ApiResponse.<List<RideResponse>>builder()
                .success(true)
                .data(rides)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Cancel a ride.
     * POST /rides/{rideId}/cancel
     */
    @PostMapping("/{rideId}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelRide(@PathVariable UUID rideId) {
        UUID userId = getCurrentUserId();
        rideService.cancelRide(rideId, userId);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Ride cancelled successfully")
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Lock the route before execution.
     * POST /rides/{rideId}/route-lock
     */
    @PostMapping("/{rideId}/route-lock")
    public ResponseEntity<ApiResponse<RideResponse>> lockRoute(@PathVariable UUID rideId) {
        UUID userId = getCurrentUserId();
        RideResponse response = rideService.lockRoute(rideId, userId);
        return ResponseEntity.ok(ApiResponse.<RideResponse>builder()
                .success(true)
                .data(response)
                .message("Route locked successfully")
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Start a ride (transition to IN_PROGRESS).
     * POST /rides/{rideId}/start
     */
    @PostMapping("/{rideId}/start")
    public ResponseEntity<ApiResponse<RideResponse>> startRide(@PathVariable UUID rideId) {
        UUID userId = getCurrentUserId();
        RideResponse response = rideService.startRide(rideId, userId);
        return ResponseEntity.ok(ApiResponse.<RideResponse>builder()
                .success(true)
                .data(response)
                .message("Ride started successfully")
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Complete a ride.
     * POST /rides/{rideId}/complete
     */
    @PostMapping("/{rideId}/complete")
    public ResponseEntity<ApiResponse<RideResponse>> completeRide(@PathVariable UUID rideId) {
        UUID userId = getCurrentUserId();
        RideResponse response = rideService.completeRide(rideId, userId);
        return ResponseEntity.ok(ApiResponse.<RideResponse>builder()
                .success(true)
                .data(response)
                .message("Ride completed successfully")
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Update driver location (real-time GPS tracking).
     * PUT /rides/{rideId}/driver-location
     */
    @PostMapping("/{rideId}/driver-location")
    public ResponseEntity<ApiResponse<Void>> updateDriverLocation(
            @PathVariable UUID rideId,
            @RequestParam Double lat,
            @RequestParam Double lng) {
        UUID userId = getCurrentUserId();
        rideService.updateDriverLocation(userId, rideId, lat, lng);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Driver location updated")
                .timestamp(Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
