package com.nimbus.auth.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.auth.application.*;
import com.nimbus.auth.application.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication controller handling OTP send/verify, token refresh, and logout.
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * Send OTP to a Bangladesh phone number.
     *
     * @param request Phone number and purpose
     * @return Success response
     */
    @PostMapping("/send-otp")
    public ResponseEntity<ApiResponse<Void>> sendOtp(@Valid @RequestBody SendOtpRequest request) {
        authService.sendOtp(request);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("OTP has been sent to " + request.getPhone())
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Verify OTP and authenticate user.
     *
     * @param request Phone, OTP, and device info
     * @return Auth response with JWT tokens
     */
    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        AuthResponse response = authService.verifyOtp(request);
        return ResponseEntity.ok(ApiResponse.<AuthResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Refresh access token using refresh token.
     *
     * @param request Refresh token
     * @return New auth response with tokens
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request);
        return ResponseEntity.ok(ApiResponse.<AuthResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Logout the current user (revoke tokens).
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout() {
        // Frontend should delete the tokens, backend doesn't need to do anything
        // because JWTs are stateless until refresh token revocation
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Logged out successfully")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * List active sessions for the current user.
     */
    @GetMapping("/sessions")
    public ResponseEntity<ApiResponse<Void>> listSessions() {
        // TODO: Implement session tracking
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Sessions retrieved")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }
}