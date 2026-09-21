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

    @Autowired
    public AuthService(
            OtpService otpService,
            JwtTokenUtil jwtTokenUtil,
            UserRepository userRepository,
            UserProfileRepository userProfileRepository,
            UserDeviceRepository userDeviceRepository,
            AuditLogRepository auditLogRepository) {
        this.otpService = otpService;
        this.jwtTokenUtil = jwtTokenUtil;
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.userDeviceRepository = userDeviceRepository;
        this.auditLogRepository = auditLogRepository;
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

        String otp = otpService.storeOtp(phone);
        log.debug("OTP generated for phone {}: {} (for production, this would be sent via SMS)", phone, otp);

        // TODO: In production, integrate with an SMS provider (e.g., bKash, custom SMS gateway)
        // smsProvider.send(phone, "Your verification code is: " + otp);
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
            // Create new user
            user = User.builder()
                    .phone(phone)
                    .status(User.UserStatus.PENDING)
                    .role(User.UserRole.PASSENGER)
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
                        .appVersion(request.getPlatform())
                        .lastSeenAt(Instant.now())
                        .status(UserDevice.DeviceStatus.ACTIVE)
                        .build();
            }
            userDeviceRepository.save(device);
        }

        // Generate tokens
        String accessToken = jwtTokenUtil.generateAccessToken(user);
        String refreshToken = jwtTokenUtil.generateRefreshToken(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(jwtTokenUtil.getAccessTokenExpirationMs() / 1000)
                .user(toUserResponse(user))
                .build();
    }

    /**
     * Refresh access token using refresh token.
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

            String newAccessToken = jwtTokenUtil.generateAccessToken(user);
            String newRefreshToken = jwtTokenUtil.generateRefreshToken(user);

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