package com.nimbus.auth.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import com.nimbus.auth.application.*;
import com.nimbus.auth.application.service.AuthService;
import com.nimbus.auth.application.service.RefreshSessionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

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
     * Logout the current user by revoking their refresh session. Accepts an
     * optional refresh token (revokes that session) — when omitted but the
     * caller is authenticated, every session of the user is revoked.
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestBody(required = false) RefreshTokenRequest request) {
        UUID userId = currentUserIdOrNull();
        int revoked = authService.logout(request != null ? request.getRefreshToken() : null, userId);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message(revoked > 0
                        ? "Logged out successfully (" + revoked + " session" + (revoked == 1 ? "" : "s") + " revoked)"
                        : "Logged out successfully")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * List active sessions for the current user.
     */
    @GetMapping("/sessions")
    public ResponseEntity<ApiResponse<List<RefreshSessionService.SessionInfo>>> listSessions() {
        UUID userId = currentUserIdOrNull();
        if (userId == null) {
            throw new NimbusException(ErrorCode.AUTH_UNAUTHORIZED, HttpStatus.UNAUTHORIZED);
        }
        List<RefreshSessionService.SessionInfo> sessions = authService.listSessions(userId);
        return ResponseEntity.ok(ApiResponse.<List<RefreshSessionService.SessionInfo>>builder()
                .success(true)
                .data(sessions)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Revoke one of the current user's sessions.
     */
    @DeleteMapping("/sessions/{sessionId}")
    public ResponseEntity<ApiResponse<Void>> revokeSession(@PathVariable String sessionId) {
        UUID userId = currentUserIdOrNull();
        if (userId == null) {
            throw new NimbusException(ErrorCode.AUTH_UNAUTHORIZED, HttpStatus.UNAUTHORIZED);
        }
        boolean revoked = authService.revokeSession(userId, sessionId);
        if (!revoked) {
            throw new NimbusException(ErrorCode.AUTH_UNAUTHORIZED,
                    "Session not found or not owned by you", HttpStatus.NOT_FOUND);
        }
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Session revoked")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /** Resolves the authenticated user id, or null for anonymous callers. */
    private UUID currentUserIdOrNull() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth instanceof UserAuthenticationToken userAuth) {
            return userAuth.getUserId();
        }
        return null;
    }
}