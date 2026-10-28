package com.nimbus.auth.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.auth.application.*;
import com.nimbus.user.application.UserResponse;
import com.nimbus.kernel.domain.entity.*;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.*;
import com.nimbus.kernel.infrastructure.security.JwtTokenUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Authentication service handling OTP verification, session management,
 * and token generation.
 */
@Service
@Slf4j
public class AuthService {

    private final OtpService otpService;
    private final JwtTokenUtil jwtTokenUtil;
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserDeviceRepository userDeviceRepository;
    private final AuditLogRepository auditLogRepository;
    private final RefreshSessionService refreshSessionService;
    private final java.util.Optional<com.nimbus.auth.application.port.SmsProvider> smsProvider;

    @Autowired
    public AuthService(
            OtpService otpService,
            JwtTokenUtil jwtTokenUtil,
            UserRepository userRepository,
            UserProfileRepository userProfileRepository,
            UserDeviceRepository userDeviceRepository,
            AuditLogRepository auditLogRepository,
            RefreshSessionService refreshSessionService,
            java.util.Optional<com.nimbus.auth.application.port.SmsProvider> smsProvider) {
        this.otpService = otpService;
        this.jwtTokenUtil = jwtTokenUtil;
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.userDeviceRepository = userDeviceRepository;
        this.auditLogRepository = auditLogRepository;
        this.refreshSessionService = refreshSessionService;
        this.smsProvider = smsProvider;
    }

    /**
     * Send OTP to phone number for verification.
     * Rate limited to prevent abuse.
     *
     * @param request Contains phone number and purpose
     * @return Success response
     */
    public void sendOtp(SendOtpRequest request) {
        String phone = request.getPhone();

        if (otpService.isRateLimited(phone)) {
            log.warn("OTP rate limited for phone: {}", phone);
            throw new NimbusException(
                ErrorCode.AUTH_OTP_LIMIT_EXCEEDED,
                "OTP request rate limit exceeded. Please try again later.",
                HttpStatus.TOO_MANY_REQUESTS
            );
        }
        // Count this request. The counter was previously only read, so the
        // per-phone limit could never be reached (guide §18).
        otpService.incrementRateLimit(phone);

        String otp = otpService.storeOtp(phone);

        // Guide §12: providers sit behind adapters. The default console
        // provider records the dispatch; real providers are a drop-in.
        String message = "Your Nimbus verification code is: " + otp;
        smsProvider.ifPresentOrElse(
                p -> {
                    try {
                        p.send(phone, message);
                    } catch (Exception e) {
                        log.warn("SMS dispatch failed for {}: {}", phone, e.getMessage());
                    }
                },
                () -> log.warn("OTP generated for phone {} but no SMS provider is configured", phone));
    }

    /**
     * Verify OTP and authenticate/register user.
     *
     * @param request Contains phone, OTP, and device info
     * @return AuthResponse with JWT tokens
     */
    @Transactional
    public AuthResponse verifyOtp(VerifyOtpRequest request) {
        String phone = request.getPhone();
        String otp = request.getOtp();

        if (!otpService.validateOtp(phone, otp)) {
            throw new NimbusException(ErrorCode.AUTH_INVALID_OTP, HttpStatus.UNAUTHORIZED);
        }

        // Find or create user
        Optional<User> userOpt = userRepository.findByPhone(phone);
        User user;

        if (userOpt.isPresent()) {
            user = userOpt.get();
        } else {
            // Create new user. OTP verification IS the phone verification
            // step, so the account starts ACTIVE — the JWT filter only
            // authenticates ACTIVE users, and a PENDING status here made
            // every request after login return 403.
            user = User.builder()
                    .phone(phone)
                    .status(User.UserStatus.ACTIVE)
                    .role("PASSENGER")
                    .phoneVerified(true)
                    .build();
            user = userRepository.save(user);

            // Create empty profile
            UserProfile profile = UserProfile.builder()
                    .user(user)
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();
            userProfileRepository.save(profile);

            // Log registration
            logAudit(user.getId(), "REGISTER", "USER", user.getId(), null, phone);
        }

        // Update phone verification if needed
        if (!user.isPhoneVerified()) {
            user.setPhoneVerified(true);
            userRepository.save(user);
            logAudit(user.getId(), "PHONE_VERIFIED", "USER", user.getId(), null, phone);
        }

        // Update device
        if (request.getDeviceId() != null && request.getPlatform() != null) {
            Optional<UserDevice> deviceOpt = userDeviceRepository
                    .findByUserIdAndDeviceId(user.getId(), request.getDeviceId());

            UserDevice device;
            if (deviceOpt.isPresent()) {
                device = deviceOpt.get();
                if (request.getPushToken() != null) {
                    device.setPushToken(request.getPushToken());
                }
                device.markAsSeen();
            } else {
                device = UserDevice.builder()
                        .user(user)
                        .deviceId(request.getDeviceId())
                        .platform(UserDevice.Platform.valueOf(request.getPlatform().toUpperCase()))
                        .pushToken(request.getPushToken())
                        .appVersion(request.getAppVersion())
                        .lastSeenAt(Instant.now())
                        .status(UserDevice.DeviceStatus.ACTIVE)
                        .build();
            }
            userDeviceRepository.save(device);
        }

        // Create a refresh session and bind it to the refresh token so it can
        // be rotated and revoked server-side (guide §14 auth:refresh:{sessionId}).
        String sessionId = refreshSessionService.createSession(
                user.getId(), request.getDeviceId(), request.getPlatform());

        // Generate tokens
        String accessToken = jwtTokenUtil.generateAccessToken(user);
        String refreshToken = jwtTokenUtil.generateRefreshToken(user, sessionId);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(jwtTokenUtil.getAccessTokenExpirationMs() / 1000)
                .user(toUserResponse(user))
                .build();
    }

    /**
     * Refresh access token using refresh token.
     *
     * <p>Implements rotation with revocation: when the token carries a
     * session id, the session must still exist in Redis (a revoked or
     * reused session is rejected) and is swapped for a fresh one. Legacy
     * tokens without a session id are adopted into a tracked session.</p>
     */
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();

        try {
            if (!jwtTokenUtil.isRefreshToken(refreshToken)) {
                throw new NimbusException(ErrorCode.AUTH_REFRESH_TOKEN_INVALID, HttpStatus.UNAUTHORIZED);
            }

            UUID userId = jwtTokenUtil.getUserIdFromToken(refreshToken);
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

            if (!user.isActive()) {
                throw new NimbusException(ErrorCode.AUTH_UNAUTHORIZED, HttpStatus.UNAUTHORIZED);
            }

            String oldSessionId = jwtTokenUtil.getSessionIdFromToken(refreshToken);
            String newSessionId;
            if (oldSessionId != null) {
                // Rotation: fails with 401 if the session was revoked/expired.
                newSessionId = refreshSessionService.rotate(oldSessionId, userId);
            } else {
                // Legacy token minted before session tracking.
                newSessionId = refreshSessionService.createSession(userId, null, null);
            }

            String newAccessToken = jwtTokenUtil.generateAccessToken(user);
            String newRefreshToken = jwtTokenUtil.generateRefreshToken(user, newSessionId);

            return AuthResponse.builder()
                    .accessToken(newAccessToken)
                    .refreshToken(newRefreshToken)
                    .expiresIn(jwtTokenUtil.getAccessTokenExpirationMs() / 1000)
                    .user(toUserResponse(user))
                    .build();

        } catch (NimbusException e) {
            throw e;
        } catch (Exception e) {
            log.error("Token refresh failed: {}", e.getMessage());
            throw new NimbusException(ErrorCode.AUTH_TOKEN_INVALID, HttpStatus.UNAUTHORIZED);
        }
    }

    /**
     * Logout: revoke the refresh session bound to the presented refresh
     * token. When no refresh token is supplied but the caller is
     * authenticated, all of the user's sessions are revoked.
     *
     * @return number of sessions revoked
     */
    public int logout(String refreshToken, UUID authenticatedUserId) {
        if (refreshToken != null && !refreshToken.isBlank()
                && jwtTokenUtil.isRefreshToken(refreshToken)) {
            UUID userId = jwtTokenUtil.getUserIdFromToken(refreshToken);
            String sessionId = jwtTokenUtil.getSessionIdFromToken(refreshToken);
            if (sessionId != null && refreshSessionService.revoke(sessionId, userId)) {
                logAudit(userId, "LOGOUT", "USER", userId, null, "session=" + sessionId);
                return 1;
            }
            return 0;
        }
        if (authenticatedUserId != null) {
            long count = refreshSessionService.listForUser(authenticatedUserId).size();
            refreshSessionService.revokeAllForUser(authenticatedUserId);
            if (count > 0) {
                logAudit(authenticatedUserId, "LOGOUT_ALL", "USER", authenticatedUserId,
                        null, "sessions=" + count);
            }
            return (int) count;
        }
        return 0;
    }

    /**
     * List active refresh sessions for the current user.
     */
    public List<RefreshSessionService.SessionInfo> listSessions(UUID userId) {
        return refreshSessionService.listForUser(userId);
    }

    /**
     * Revoke one of the current user's sessions.
     */
    public boolean revokeSession(UUID userId, String sessionId) {
        boolean revoked = refreshSessionService.revoke(sessionId, userId);
        if (revoked) {
            logAudit(userId, "SESSION_REVOKED", "USER", userId, null, "session=" + sessionId);
        }
        return revoked;
    }

    /**
     * Get current authenticated user.
     */
    public User getCurrentUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));
    }

    /**
     * Convert User entity to response DTO.
     */
    private UserResponse toUserResponse(User user) {
        UserProfile profile = userProfileRepository.findByUserId(user.getId()).orElse(null);

        UserResponse.UserProfileResponse profileResponse = null;
        if (profile != null) {
            profileResponse = UserResponse.UserProfileResponse.builder()
                    .firstName(profile.getFirstName())
                    .lastName(profile.getLastName())
                    .profilePhotoUrl(profile.getProfilePhotoUrl())
                    .emergencyContactName(profile.getEmergencyContactName())
                    .emergencyContactPhone(profile.getEmergencyContactPhone())
                    .build();
        }

        return UserResponse.builder()
                .id(user.getId().toString())
                .phone(user.getPhone())
                .email(user.getEmail())
                .status(user.getStatus())
                .role(user.getRole())
                .phoneVerified(user.isPhoneVerified())
                .profile(profileResponse)
                .build();
    }

    /**
     * Log an audit event.
     */
    private void logAudit(UUID userId, String action, String entityType, UUID entityId,
                          String oldValue, String newValue) {
        AuditLog auditLog = AuditLog.builder()
                .actorUser(User.builder().id(userId).build())
                .actorRole(null)
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .oldValue(oldValue)
                .newValue(newValue)
                .createdAt(Instant.now())
                .build();
        auditLogRepository.save(auditLog);
    }
}