package com.nimbus.driver.application.controller;

import com.nimbus.driver.application.CreateVehicleRequest;
import com.nimbus.driver.application.DriverApplicationRequest;
import com.nimbus.driver.application.DriverStatusRequest;
import com.nimbus.driver.application.DriverEarningsResponse;
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
import org.springframework.web.multipart.MultipartFile;

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
    private final com.nimbus.settlement.application.SettlementService settlementService;
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
     * Earnings summary.
     * GET /drivers/earnings
     */
    @GetMapping("/earnings")
    public ResponseEntity<ApiResponse<DriverEarningsResponse>> getEarnings() {
        UUID userId = getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.<DriverEarningsResponse>builder()
                .success(true)
                .data(driverService.getEarnings(userId))
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Settlement history for the current driver (guide §15).
     * GET /drivers/settlements
     */
    @GetMapping("/settlements")
    public ResponseEntity<ApiResponse<List<com.nimbus.settlement.application.SettlementResponse>>> getSettlements() {
        UUID userId = getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.<List<com.nimbus.settlement.application.SettlementResponse>>builder()
                .success(true)
                .data(settlementService.getSettlementsForDriver(userId))
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Settlement action: request payout of a PENDING settlement (guide §15).
     * POST /drivers/settlements/{settlementId}/request-payout
     */
    @PostMapping("/settlements/{settlementId}/request-payout")
    public ResponseEntity<ApiResponse<com.nimbus.settlement.application.SettlementResponse>> requestPayout(
            @PathVariable UUID settlementId) {
        UUID userId = getCurrentUserId();
        var settlement = settlementService.requestPayout(settlementId, userId);
        return ResponseEntity.ok(ApiResponse.<com.nimbus.settlement.application.SettlementResponse>builder()
                .success(true)
                .data(settlement)
                .message("Payout requested")
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Toggle driver online/offline availability.
     * POST /drivers/status
     */
    @PostMapping("/status")
    public ResponseEntity<ApiResponse<DriverProfileResponse>> updateStatus(
            @Valid @RequestBody DriverStatusRequest request) {
        UUID userId = getCurrentUserId();
        DriverProfileResponse response = driverService.updateStatus(userId, request.getDriverStatus());
        return ResponseEntity.ok(ApiResponse.<DriverProfileResponse>builder()
                .success(true)
                .data(response)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Register an additional vehicle.
     * POST /drivers/vehicles
     */
    @PostMapping("/vehicles")
    public ResponseEntity<ApiResponse<VehicleResponse>> createVehicle(
            @Valid @RequestBody CreateVehicleRequest request) {
        UUID userId = getCurrentUserId();
        VehicleResponse response = driverService.createVehicle(userId,
                request.getRegistrationNumber(), request.getType(), request.getModel(),
                request.getYear(), request.getColor(), request.getSeatCapacity());
        return ResponseEntity.ok(ApiResponse.<VehicleResponse>builder()
                .success(true)
                .data(response)
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
    public ResponseEntity<ApiResponse<List<com.nimbus.driver.application.DriverDocumentResponse>>> getDriverDocuments() {
        UUID userId = getCurrentUserId();
        List<com.nimbus.driver.application.DriverDocumentResponse> documents = documentService.getDriverDocuments(userId);
        return ResponseEntity.ok(ApiResponse.<List<com.nimbus.driver.application.DriverDocumentResponse>>builder()
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
    public ResponseEntity<ApiResponse<com.nimbus.driver.application.DriverDocumentResponse>> uploadDriverDocument(
            @RequestParam DriverDocument.DocumentType type,
            @RequestParam String documentNumber,
            @RequestParam(required = false) Instant expiresAt,
            @RequestParam String documentUrl) {
        UUID userId = getCurrentUserId();
        com.nimbus.driver.application.DriverDocumentResponse document =
                documentService.uploadDriverDocument(userId, type, documentNumber, expiresAt, documentUrl);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<com.nimbus.driver.application.DriverDocumentResponse>builder()
                        .success(true)
                        .data(document)
                        .message("Document uploaded successfully")
                        .timestamp(Instant.now().toString())
                        .build());
    }

    /**
     * Upload a driver document file (multipart).
     * POST /drivers/documents/upload
     */
    @PostMapping(value = "/documents/upload",
            consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<com.nimbus.driver.application.DriverDocumentResponse>> uploadDriverDocumentFile(
            @RequestParam DriverDocument.DocumentType type,
            @RequestParam String documentNumber,
            @RequestParam(required = false) Instant expiresAt,
            @RequestParam("file") MultipartFile file) {
        UUID userId = getCurrentUserId();
        com.nimbus.driver.application.DriverDocumentResponse document =
                documentService.uploadDriverDocumentFile(userId, type, documentNumber, expiresAt, file);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<com.nimbus.driver.application.DriverDocumentResponse>builder()
                        .success(true)
                        .data(document)
                        .message("Document uploaded successfully")
                        .timestamp(Instant.now().toString())
                        .build());
    }

    /**
     * Download an uploaded driver document. Owner or staff only.
     * GET /drivers/documents/{documentId}/file
     */
    @GetMapping("/documents/{documentId}/file")
    public ResponseEntity<org.springframework.core.io.Resource> getDriverDocumentFile(
            @PathVariable UUID documentId) {
        var file = documentService.getDriverDocumentFile(
                documentId, getCurrentUserId(), isStaff());
        return ResponseEntity.ok()
                .contentType(org.springframework.http.MediaType.parseMediaType(file.contentType()))
                .body(file.resource());
    }

    /**
     * Upload a vehicle document (ownership enforced).
     * POST /drivers/vehicles/{vehicleId}/documents
     */
    @PostMapping("/vehicles/{vehicleId}/documents")
    public ResponseEntity<ApiResponse<com.nimbus.driver.application.VehicleDocumentResponse>> uploadVehicleDocument(
            @PathVariable UUID vehicleId,
            @RequestParam VehicleDocument.DocumentType type,
            @RequestParam String documentNumber,
            @RequestParam(required = false) Instant expiresAt,
            @RequestParam String documentUrl) {
        UUID userId = getCurrentUserId();
        com.nimbus.driver.application.VehicleDocumentResponse document =
                documentService.uploadVehicleDocument(vehicleId, userId, type,
                        documentNumber, expiresAt, documentUrl);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<com.nimbus.driver.application.VehicleDocumentResponse>builder()
                        .success(true)
                        .data(document)
                        .message("Vehicle document uploaded successfully")
                        .timestamp(Instant.now().toString())
                        .build());
    }

    /**
     * List vehicle documents.
     * GET /drivers/vehicles/{vehicleId}/documents
     */
    @GetMapping("/vehicles/{vehicleId}/documents")
    public ResponseEntity<ApiResponse<List<com.nimbus.driver.application.VehicleDocumentResponse>>> getVehicleDocuments(@PathVariable UUID vehicleId) {
        List<com.nimbus.driver.application.VehicleDocumentResponse> documents =
                documentService.getVehicleDocuments(vehicleId, getCurrentUserId(), isStaff());
        return ResponseEntity.ok(ApiResponse.<List<com.nimbus.driver.application.VehicleDocumentResponse>>builder()
                .success(true)
                .data(documents)
                .timestamp(Instant.now().toString())
                .build());
    }

    /**
     * Upload a vehicle document file (multipart, ownership enforced).
     * POST /drivers/vehicles/{vehicleId}/documents/upload
     */
    @PostMapping(value = "/vehicles/{vehicleId}/documents/upload",
            consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<com.nimbus.driver.application.VehicleDocumentResponse>> uploadVehicleDocumentFile(
            @PathVariable UUID vehicleId,
            @RequestParam VehicleDocument.DocumentType type,
            @RequestParam String documentNumber,
            @RequestParam(required = false) Instant expiresAt,
            @RequestParam("file") MultipartFile file) {
        var document = documentService.uploadVehicleDocumentFile(
                vehicleId, getCurrentUserId(), type, documentNumber, expiresAt, file);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<com.nimbus.driver.application.VehicleDocumentResponse>builder()
                        .success(true)
                        .data(document)
                        .message("Vehicle document uploaded successfully")
                        .timestamp(Instant.now().toString())
                        .build());
    }

    /**
     * Download an uploaded vehicle document. Owner or staff only.
     * GET /drivers/vehicles/{vehicleId}/documents/{documentId}/file
     */
    @GetMapping("/vehicles/{vehicleId}/documents/{documentId}/file")
    public ResponseEntity<org.springframework.core.io.Resource> getVehicleDocumentFile(
            @PathVariable UUID vehicleId,
            @PathVariable UUID documentId) {
        var file = documentService.getVehicleDocumentFile(
                vehicleId, documentId, getCurrentUserId(), isStaff());
        return ResponseEntity.ok()
                .contentType(org.springframework.http.MediaType.parseMediaType(file.contentType()))
                .body(file.resource());
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

    /**
     * Verify a vehicle document (admin/operations only).
     * POST /drivers/vehicles/{vehicleId}/documents/{documentId}/verify
     */
    @PostMapping("/vehicles/{vehicleId}/documents/{documentId}/verify")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATIONS', 'SUPPORT')")
    public ResponseEntity<ApiResponse<com.nimbus.driver.application.VehicleDocumentResponse>> verifyVehicleDocument(
            @PathVariable UUID vehicleId,
            @PathVariable UUID documentId,
            @RequestParam boolean approved,
            @RequestParam(required = false) String rejectionReason) {
        var document = documentService.verifyVehicleDocument(documentId, approved, rejectionReason);
        return ResponseEntity.ok(ApiResponse.<com.nimbus.driver.application.VehicleDocumentResponse>builder()
                .success(true)
                .data(document)
                .message("Vehicle document verification updated")
                .timestamp(Instant.now().toString())
                .build());
    }

    private boolean isStaff() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getAuthorities() == null) return false;
        return auth.getAuthorities().stream().anyMatch(a -> {
            String role = a.getAuthority();
            return "ROLE_ADMIN".equals(role) || "ROLE_OPERATIONS".equals(role)
                    || "ROLE_SUPPORT".equals(role) || "ROLE_SAFETY".equals(role);
        });
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
