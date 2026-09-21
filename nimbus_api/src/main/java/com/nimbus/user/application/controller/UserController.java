package com.nimbus.user.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.user.application.*;
import com.nimbus.user.application.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * User profile and saved location management endpoints.
 */
@RestController
@RequestMapping("/me")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * Get current user profile.
     */
    @GetMapping
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser() {
        UserResponse user = userService.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .success(true)
                .data(user)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Update current user profile.
     */
    @PutMapping
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(@Valid @RequestBody UpdateUserRequest request) {
        UserResponse user = userService.updateProfile(request);
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .success(true)
                .data(user)
                .message("Profile updated successfully")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Get all saved locations for the current user.
     */
    @GetMapping("/locations")
    public ResponseEntity<ApiResponse<List<SavedLocationResponse>>> getSavedLocations() {
        List<SavedLocationResponse> locations = userService.getSavedLocations();
        return ResponseEntity.ok(ApiResponse.<List<SavedLocationResponse>>builder()
                .success(true)
                .data(locations)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Save a new location.
     */
    @PostMapping("/locations")
    public ResponseEntity<ApiResponse<SavedLocationResponse>> saveLocation(@Valid @RequestBody SaveLocationRequest request) {
        SavedLocationResponse location = userService.saveLocation(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<SavedLocationResponse>builder()
                        .success(true)
                        .data(location)
                        .message("Location saved successfully")
                        .timestamp(java.time.Instant.now().toString())
                        .build());
    }
}