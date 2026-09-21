package com.nimbus.driver.application.controller;

import com.nimbus.driver.application.DriverApplicationRequest;
import com.nimbus.driver.application.DriverProfileResponse;
import com.nimbus.driver.application.VehicleResponse;
import com.nimbus.driver.application.service.DriverService;
import com.nimbus.driver.application.service.DocumentService;
import com.nimbus.driver.domain.entity.DriverDocument;
import com.nimbus.driver.domain.entity.VehicleDocument;
import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.*;

/**
 * Driver profile and application management endpoints.
 */
@RestController
@RequestMapping("/drivers")
@RequiredArgsConstructor
public class DriverController {

    private final DriverService driverService;
    private final DocumentService documentService;

    /**
     * Apply as a driver.
     * POST /drivers/apply
     */
    @PostMapping("/apply")
    public ResponseEntity<ApiResponse<DriverProfileResponse>> applyAsDriver(
            @Valid @RequestBody DriverApplicationRequest request) {
        UUID userId = getCurrentUserId();
        DriverProfileResponse response = driverService.applyAsDriver(userId, request);
        return ResponseEntity.ok(ApiResponse.<DriverProfileResponse>builder()
                .success(true)
                .data(response)
                .message("Driver application submitted successfully")
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Get driver profile.
     * GET /drivers/profile
     */
    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<DriverProfileResponse>> getProfile() {
        UUID userId = getCurrentUserId();
        DriverProfileResponse response = driverService.getDriverProfile(userId);
        return ResponseEntity.ok(ApiResponse.<DriverProfileResponse>builder()
                .success(true)
                .data(response)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Check driver eligibility.
     * GET /drivers/eligibility
     */
    @GetMapping("/eligibility")
    public ResponseEntity<ApiResponse<Boolean>> checkEligibility() {
        UUID userId = getCurrentUserId();
        boolean eligible = driverService.isEligible(userId);
        return ResponseEntity.ok(ApiResponse.<Boolean>builder()
                .success(true)
                .data(eligible)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * List driver's vehicles.
     * GET /drivers/vehicles
     */
    @GetMapping("/vehicles")
    public ResponseEntity<ApiResponse<List<VehicleResponse>>> getVehicles() {
        UUID userId = getCurrentUserId();
        List<VehicleResponse> vehicles = driverService.getVehicles(userId);
        return ResponseEntity.ok(ApiResponse.<List<VehicleResponse>>builder()
                .success(true)
                .data(vehicles)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * List driver's documents.
     * GET /drivers/documents
     */
    @GetMapping("/documents")
    public ResponseEntity<ApiResponse<List<DriverDocument>>> getDriverDocuments() {
        UUID userId = getCurrentUserId();
        List<DriverDocument> documents = documentService.getDriverDocuments(userId);
        return ResponseEntity.ok(ApiResponse.<List<DriverDocument>>builder()
                .success(true)
                .data(documents)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Upload a driver document.
     * POST /drivers/documents
     */
    @PostMapping("/documents")
    public ResponseEntity<ApiResponse<DriverDocument>> uploadDriverDocument(
            @RequestParam DriverDocument.DocumentType type,
            @RequestParam String documentNumber,
            @RequestParam Instant expiresAt,
            @RequestParam String documentUrl) {
        UUID userId = getCurrentUserId();
        DriverDocument document = documentService.uploadDriverDocument(userId, type, documentNumber, expiresAt, documentUrl);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<DriverDocument>builder()
                        .success(true)
                        .data(document)
                        .message("Document uploaded successfully")
                        .timestamp(Instant.now().toString())
                        .build());
    }

    /**
     * List vehicle documents.
     * GET /drivers/vehicles/{vehicleId}/documents
     */
    @GetMapping("/vehicles/{vehicleId}/documents")
    public ResponseEntity<ApiResponse<List<VehicleDocument>>> getVehicleDocuments(@PathVariable UUID vehicleId) {
        List<VehicleDocument> documents = documentService.getVehicleDocuments(vehicleId);
        return ResponseEntity.ok(ApiResponse.<List<VehicleDocument>>builder()
                .success(true)
                .data(documents)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Verify a document (admin/operations only).
     * POST /drivers/documents/{documentId}/verify
     */
    @PostMapping("/documents/{documentId}/verify")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATIONS', 'SUPPORT')")
    public ResponseEntity<ApiResponse<Void>> verifyDocument(
            @PathVariable UUID documentId,
            @RequestParam boolean approved,
            @RequestParam(required = false) String rejectionReason) {
        documentService.verifyDocument(documentId, approved, rejectionReason);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Document verification updated")
                .timestamp(Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
