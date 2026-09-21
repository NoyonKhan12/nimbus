package com.nimbus.auth.application.controller;

import com.nimbus.auth.application.AdminLoginRequest;
import com.nimbus.auth.application.AdminAuthResponse;
import com.nimbus.auth.application.service.AdminAuthService;
import com.nimbus.kernel.application.dto.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

/**
 * Admin authentication controller handling email/password login.
 */
@RestController
@RequestMapping("/admin/auth")
@RequiredArgsConstructor
public class AdminAuthController {

    private final AdminAuthService adminAuthService;

    /**
     * Authenticate an admin user with email and password.
     *
     * @param request Email and password
     * @return Auth response with JWT tokens
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AdminAuthResponse>> login(@Valid @RequestBody AdminLoginRequest request) {
        AdminAuthResponse response = adminAuthService.login(request);
        return ResponseEntity.ok(ApiResponse.<AdminAuthResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }
}