package com.nimbus.complaint.application.controller;

import com.nimbus.complaint.application.ComplaintRequest;
import com.nimbus.complaint.application.service.ComplaintService;
import com.nimbus.complaint.domain.entity.Complaint;
import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Complaint management endpoints.
 */
@RestController
@RequestMapping("/complaints")
@RequiredArgsConstructor
public class ComplaintController {

    private final ComplaintService complaintService;

    /**
     * Submit a new complaint.
     * POST /complaints
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Void>> createComplaint(@Valid @RequestBody ComplaintRequest request) {
        UUID userId = getCurrentUserId();
        complaintService.createComplaint(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<Void>builder()
                        .success(true)
                        .message("Complaint submitted successfully")
                        .timestamp(java.time.Instant.now().toString())
                        .build());
    }

    /**
     * Get user's complaints.
     * GET /complaints
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Complaint>>> getUserComplaints() {
        UUID userId = getCurrentUserId();
        List<Complaint> complaints = complaintService.getUserComplaints(userId);
        return ResponseEntity.ok(ApiResponse.<List<Complaint>>builder()
                .success(true)
                .data(complaints)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Get a specific complaint.
     * GET /complaints/{complaintId}
     */
    @GetMapping("/{complaintId}")
    public ResponseEntity<ApiResponse<Complaint>> getComplaint(@PathVariable UUID complaintId) {
        Complaint complaint = complaintService.getComplaint(
                complaintId, getCurrentUserId(), isStaff());
        return ResponseEntity.ok(ApiResponse.<Complaint>builder()
                .success(true)
                .data(complaint)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Update complaint status (admin/operations/support only — guide §20).
     * PATCH /complaints/{complaintId}/status
     */
    @PatchMapping("/{complaintId}/status")
    @org.springframework.security.access.prepost.PreAuthorize(
            "hasAnyRole('ADMIN','OPERATIONS','SUPPORT')")
    public ResponseEntity<ApiResponse<Void>> updateComplaintStatus(
            @PathVariable UUID complaintId,
            @RequestParam Complaint.ComplaintStatus status,
            @RequestParam(required = false) String resolution) {
        complaintService.updateComplaintStatus(complaintId, status, resolution);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Complaint status updated")
                .timestamp(java.time.Instant.now().toString())
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
