package com.nimbus.auth.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.kernel.infrastructure.security.JwtTokenUtil;
import com.nimbus.auth.application.AdminLoginRequest;
import com.nimbus.auth.application.AdminAuthResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Admin authentication service handling email/password login.
 * Only users with ADMIN role can authenticate via this service.
 */
@Service
@Slf4j
public class AdminAuthService {

    private final UserRepository userRepository;
    private final JwtTokenUtil jwtTokenUtil;
    private final PasswordEncoder passwordEncoder;
    private final long adminAccessTokenExpirationMs;

    public AdminAuthService(UserRepository userRepository,
                            JwtTokenUtil jwtTokenUtil,
                            PasswordEncoder passwordEncoder,
                            @Value("${app.jwt.admin-access-token-expiration-ms:86400000}") long adminAccessTokenExpirationMs) {
        this.userRepository = userRepository;
        this.jwtTokenUtil = jwtTokenUtil;
        this.passwordEncoder = passwordEncoder;
        this.adminAccessTokenExpirationMs = adminAccessTokenExpirationMs;
    }

    /**
     * Authenticate an admin user by email and password.
     *
     * @param request Contains email and password
     * @return AdminAuthResponse with JWT tokens
     */
    public AdminAuthResponse login(AdminLoginRequest request) {
        String email = request.getEmail();
        String password = request.getPassword();

        // Find user by email
        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isEmpty()) {
            log.warn("Admin login failed: user not found with email {}", email);
            throw new NimbusException(
                ErrorCode.AUTH_UNAUTHORIZED,
                "Invalid email or password",
                HttpStatus.UNAUTHORIZED
            );
        }

        User user = userOpt.get();

        // Verify ADMIN role
        if (user.getRole() != User.UserRole.ADMIN) {
            log.warn("Admin login denied: user {} is not an admin (role={})", email, user.getRole());
            throw new NimbusException(
                ErrorCode.AUTH_UNAUTHORIZED,
                "Access denied: admin privileges required",
                HttpStatus.FORBIDDEN
            );
        }

        // Verify password
        if (user.getPasswordHash() == null || !passwordEncoder.matches(password, user.getPasswordHash())) {
            log.warn("Admin login failed: invalid password for {}", email);
            throw new NimbusException(
                ErrorCode.AUTH_UNAUTHORIZED,
                "Invalid email or password",
                HttpStatus.UNAUTHORIZED
            );
        }

        // Check user is active
        if (!user.isActive()) {
            log.warn("Admin login denied: user {} is not active (status={})", email, user.getStatus());
            throw new NimbusException(
                ErrorCode.AUTH_UNAUTHORIZED,
                "Account is not active",
                HttpStatus.FORBIDDEN
            );
        }

        // Generate tokens — admin tokens have longer expiration (24h default)
        String accessToken = jwtTokenUtil.generateAccessToken(user, adminAccessTokenExpirationMs);
        String refreshToken = jwtTokenUtil.generateRefreshToken(user);

        log.info("Admin login successful: {}", email);

        return AdminAuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(adminAccessTokenExpirationMs / 1000)
                .build();
    }
}