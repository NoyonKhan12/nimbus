package com.nimbus.driver.application.controller;

import com.nimbus.driver.application.CreateVehicleRequest;
import com.nimbus.driver.application.VehicleResponse;
import com.nimbus.driver.application.service.DriverService;
import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Vehicle management endpoints (guide §15 /vehicles). The nested
 * /drivers/vehicles routes remain for the existing mobile clients.
 */
@RestController
@RequestMapping("/vehicles")
@RequiredArgsConstructor
public class VehicleController {

    private final DriverService driverService;

    /**
     * List the current driver's vehicles.
     * GET /vehicles
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<VehicleResponse>>> listVehicles() {
        UUID userId = getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.<List<VehicleResponse>>builder()
                .success(true)
                .data(driverService.getVehicles(userId))
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Register a vehicle (starts PENDING until operations approves it).
     * POST /vehicles
     */
    @PostMapping
    public ResponseEntity<ApiResponse<VehicleResponse>> createVehicle(
            @Valid @RequestBody CreateVehicleRequest request) {
        UUID userId = getCurrentUserId();
        VehicleResponse response = driverService.createVehicle(userId,
                request.getRegistrationNumber(), request.getType(), request.getModel(),
                request.getYear(), request.getColor(), request.getSeatCapacity());
        return ResponseEntity.status(org.springframework.http.HttpStatus.CREATED)
                .body(ApiResponse.<VehicleResponse>builder()
                        .success(true)
                        .data(response)
                        .message("Vehicle registered — pending approval")
                        .timestamp(Instant.now().toString())
                        .build());
    }

    /**
     * Vehicle details (owner only).
     * GET /vehicles/{vehicleId}
     */
    @GetMapping("/{vehicleId}")
    public ResponseEntity<ApiResponse<VehicleResponse>> getVehicle(@PathVariable UUID vehicleId) {
        UUID userId = getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.<VehicleResponse>builder()
                .success(true)
                .data(driverService.getVehicle(userId, vehicleId))
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Update vehicle details (owner only; registration/type are immutable).
     * PUT /vehicles/{vehicleId}
     */
    @PutMapping("/{vehicleId}")
    public ResponseEntity<ApiResponse<VehicleResponse>> updateVehicle(
            @PathVariable UUID vehicleId,
            @RequestBody Map<String, Object> body) {
        UUID userId = getCurrentUserId();
        VehicleResponse response = driverService.updateVehicle(userId, vehicleId,
                stringOrNull(body.get("model")),
                intOrNull(body.get("year")),
                stringOrNull(body.get("color")),
                intOrNull(body.get("seatCapacity")));
        return ResponseEntity.ok(ApiResponse.<VehicleResponse>builder()
                .success(true)
                .data(response)
                .message("Vehicle updated")
                .timestamp(Instant.now().toString())
                .build());
    }

    private String stringOrNull(Object value) {
        return value != null ? value.toString() : null;
    }

    private Integer intOrNull(Object value) {
        if (value == null) return null;
        try {
            return Integer.valueOf(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
