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
import java.util.Map;
import java.util.UUID;

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

    /**
     * Update a saved location (guide §15).
     */
    @PutMapping("/locations/{locationId}")
    public ResponseEntity<ApiResponse<SavedLocationResponse>> updateLocation(
            @PathVariable UUID locationId,
            @RequestBody SaveLocationRequest request) {
        SavedLocationResponse location = userService.updateLocation(locationId, request);
        return ResponseEntity.ok(ApiResponse.<SavedLocationResponse>builder()
                .success(true)
                .data(location)
                .message("Location updated")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Delete a saved location (guide §15).
     */
    @DeleteMapping("/locations/{locationId}")
    public ResponseEntity<ApiResponse<Void>> deleteLocation(@PathVariable UUID locationId) {
        userService.deleteLocation(locationId);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Location deleted")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Upload a profile photo (guide §15 POST /me/photo).
     */
    @PostMapping("/photo")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadPhoto(
            @RequestParam("file") org.springframework.web.multipart.MultipartFile file) {
        String url = userService.updateProfilePhoto(file);
        return ResponseEntity.ok(ApiResponse.<Map<String, String>>builder()
                .success(true)
                .data(Map.of("photoUrl", url))
                .message("Photo uploaded")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Recent journey history: bookings as passenger + rides as driver
     * (guide §15 GET /me/history).
     */
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getHistory() {
        return ResponseEntity.ok(ApiResponse.<List<Map<String, Object>>>builder()
                .success(true)
                .data(userService.getHistory())
                .timestamp(java.time.Instant.now().toString())
                .build());
    }
}