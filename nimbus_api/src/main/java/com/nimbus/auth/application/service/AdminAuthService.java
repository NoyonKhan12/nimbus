package com.nimbus.auth.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.RoleRepository;
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
 * Staff-portal authentication service handling email/password login.
 * Any dynamic staff role (ADMIN, OPERATIONS, FINANCE, SUPPORT, SAFETY, or a
 * custom role) may authenticate; PASSENGER and DRIVER may not.
 */
@Service
@Slf4j
public class AdminAuthService {

    private final UserRepository userRepository;
    private final com.nimbus.auth.application.service.RefreshSessionService refreshSessionService;
    private final RoleRepository roleRepository;
    private final JwtTokenUtil jwtTokenUtil;
    private final PasswordEncoder passwordEncoder;
    private final long adminAccessTokenExpirationMs;

    public AdminAuthService(UserRepository userRepository,
                            RoleRepository roleRepository,
                            JwtTokenUtil jwtTokenUtil,
                            PasswordEncoder passwordEncoder,
                            com.nimbus.auth.application.service.RefreshSessionService refreshSessionService,
                            @Value("${app.jwt.admin-access-token-expiration-ms:86400000}") long adminAccessTokenExpirationMs) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.jwtTokenUtil = jwtTokenUtil;
        this.passwordEncoder = passwordEncoder;
        this.refreshSessionService = refreshSessionService;
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

        // Staff roles are dynamic (Settings → Roles). PASSENGER and DRIVER
        // are app-only roles and must never reach the staff portal; any role
        // registered in the roles table is a staff role.
        String role = user.getRole();
        boolean staffRole = role != null
                && !"PASSENGER".equals(role)
                && !"DRIVER".equals(role)
                && roleRepository.existsByName(role);
        if (!staffRole) {
            log.warn("Admin login denied: user {} has no staff role (role={})", email, role);
            throw new NimbusException(
                ErrorCode.AUTH_UNAUTHORIZED,
                "Access denied: staff privileges required",
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
        // Staff refresh tokens are session-backed too, so they can be revoked
            // via DELETE /auth/sessions like any other session (guide §18).
            String sessionId = refreshSessionService.createSession(user.getId(), "staff-portal", "WEB");
            String refreshToken = jwtTokenUtil.generateRefreshToken(user, sessionId);

        log.info("Admin login successful: {}", email);

        return AdminAuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(adminAccessTokenExpirationMs / 1000)
                .build();
    }
}