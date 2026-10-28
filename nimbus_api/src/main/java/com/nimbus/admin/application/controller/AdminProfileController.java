package com.nimbus.admin.application.controller;

import com.nimbus.admin.application.dto.AdminProfileResponse;
import com.nimbus.admin.application.dto.ChangePasswordRequest;
import com.nimbus.admin.application.dto.UpdateProfileRequest;
import com.nimbus.admin.application.service.AdminProfileService;
import com.nimbus.kernel.application.dto.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.NoSuchElementException;

/**
 * Self-service profile endpoints for the signed-in administrator.
 * All require the ADMIN role (covered by /admin/** security rules).
 */
@RestController
@RequestMapping("/admin/profile")
@RequiredArgsConstructor
public class AdminProfileController {

    private final AdminProfileService adminProfileService;

    /**
     * GET /admin/profile — the current admin's profile.
     */
    @GetMapping
    public ResponseEntity<ApiResponse<AdminProfileResponse>> getProfile() {
        return ResponseEntity.ok(ApiResponse.success(adminProfileService.getProfile()));
    }

    /**
     * PATCH /admin/profile — update own name/email.
     */
    @PatchMapping
    public ResponseEntity<ApiResponse<AdminProfileResponse>> updateProfile(
            @RequestBody UpdateProfileRequest request) {
        try {
            AdminProfileResponse updated = adminProfileService.updateProfile(
                    request.getEmail(), request.getFirstName(), request.getLastName());
            return ResponseEntity.ok(ApiResponse.success(updated, "Profile updated"));
        } catch (NoSuchElementException e) {
            return ResponseEntity.status(404).body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(401).body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * PATCH /admin/profile/password — change own password
     * (requires the current password).
     */
    @PatchMapping("/password")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @Valid @RequestBody ChangePasswordRequest request) {
        try {
            adminProfileService.changePassword(request.getCurrentPassword(), request.getNewPassword());
            return ResponseEntity.ok(ApiResponse.success(null, "Password changed"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(401).body(ApiResponse.error(e.getMessage()));
        }
    }
}
