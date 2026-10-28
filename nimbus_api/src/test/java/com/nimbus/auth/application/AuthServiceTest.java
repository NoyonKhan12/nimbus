package com.nimbus.auth.application;

import com.nimbus.auth.application.service.AuthService;
import com.nimbus.auth.application.service.OtpService;
import com.nimbus.auth.application.service.RefreshSessionService;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.auth.application.*;
import com.nimbus.kernel.domain.entity.*;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.*;
import com.nimbus.kernel.infrastructure.security.JwtTokenUtil;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock private OtpService otpService;
    @Mock private JwtTokenUtil jwtTokenUtil;
    @Mock private UserRepository userRepository;
    @Mock private UserProfileRepository userProfileRepository;
    @Mock private UserDeviceRepository userDeviceRepository;
    @Mock private AuditLogRepository auditLogRepository;
    @Mock private RefreshSessionService refreshSessionService;
    @Mock private com.nimbus.auth.application.port.SmsProvider smsProvider;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(
                otpService,
                jwtTokenUtil,
                userRepository,
                userProfileRepository,
                userDeviceRepository,
                auditLogRepository,
                refreshSessionService,
                Optional.of(smsProvider));
    }

    @Test
    void sendOtp_success() {
        SendOtpRequest request = SendOtpRequest.builder()
                .phone("+8801712345678")
                .purpose("REGISTRATION")
                .build();

        when(otpService.isRateLimited("+8801712345678")).thenReturn(false);
        when(otpService.storeOtp("+8801712345678")).thenReturn("123456");

        assertDoesNotThrow(() -> authService.sendOtp(request));

        verify(otpService, times(1)).storeOtp("+8801712345678");
    }

    @Test
    void sendOtp_rateLimited_throwsException() {
        SendOtpRequest request = SendOtpRequest.builder()
                .phone("+8801712345678")
                .purpose("REGISTRATION")
                .build();

        when(otpService.isRateLimited("+8801712345678")).thenReturn(true);

        NimbusException ex = assertThrows(NimbusException.class,
                () -> authService.sendOtp(request));

        assertEquals(ErrorCode.AUTH_OTP_LIMIT_EXCEEDED, ex.getErrorCode());
        assertEquals(HttpStatus.TOO_MANY_REQUESTS, ex.getHttpStatus());
        verify(otpService, never()).storeOtp(anyString());
    }

    @Test
    void verifyOtp_success_newUser() {
        VerifyOtpRequest request = VerifyOtpRequest.builder()
                .phone("+8801712345678")
                .otp("123456")
                .deviceId("device-123")
                .platform("ANDROID")
                .build();

        when(otpService.validateOtp("+8801712345678", "123456")).thenReturn(true);
        when(userRepository.findByPhone("+8801712345678")).thenReturn(Optional.empty());

        User savedUser = User.builder()
                .id(UUID.randomUUID())
                .phone("+8801712345678")
                .status(User.UserStatus.ACTIVE)
                .role("PASSENGER")
                .phoneVerified(true)
                .build();

        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(jwtTokenUtil.generateAccessToken(any(User.class))).thenReturn("access-token");
        when(refreshSessionService.createSession(any(UUID.class), any(), any())).thenReturn("session-1");
        when(jwtTokenUtil.generateRefreshToken(any(User.class), eq("session-1"))).thenReturn("refresh-token");
        when(jwtTokenUtil.getAccessTokenExpirationMs()).thenReturn(900000L);

        AuthResponse response = authService.verifyOtp(request);

        assertNotNull(response);
        assertEquals("access-token", response.getAccessToken());
        assertEquals("refresh-token", response.getRefreshToken());
        assertEquals(900, response.getExpiresIn()); // 900000ms / 1000 = 900s
    }

    @Test
    void verifyOtp_invalidOtp_throwsException() {
        VerifyOtpRequest verifyRequest = VerifyOtpRequest.builder()
                .phone("+8801712345678")
                .otp("999999")
                .build();

        when(otpService.validateOtp("+8801712345678", "999999")).thenReturn(false);

        NimbusException ex = assertThrows(NimbusException.class,
                () -> authService.verifyOtp(verifyRequest));

        assertEquals(ErrorCode.AUTH_INVALID_OTP, ex.getErrorCode());
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getHttpStatus());
    }

    @Test
    void verifyOtp_existingUser_success() {
        VerifyOtpRequest request = VerifyOtpRequest.builder()
                .phone("+8801712345678")
                .otp("123456")
                .build();

        User existingUser = User.builder()
                .id(UUID.randomUUID())
                .phone("+8801712345678")
                .status(User.UserStatus.ACTIVE)
                .role("PASSENGER")
                .phoneVerified(true)
                .build();

        when(otpService.validateOtp("+8801712345678", "123456")).thenReturn(true);
        when(userRepository.findByPhone("+8801712345678")).thenReturn(Optional.of(existingUser));
        when(jwtTokenUtil.generateAccessToken(any(User.class))).thenReturn("access-token");
        when(refreshSessionService.createSession(any(UUID.class), any(), any())).thenReturn("session-1");
        when(jwtTokenUtil.generateRefreshToken(any(User.class), eq("session-1"))).thenReturn("refresh-token");
        when(jwtTokenUtil.getAccessTokenExpirationMs()).thenReturn(900000L);

        AuthResponse response = authService.verifyOtp(request);

        assertNotNull(response);
        assertEquals("access-token", response.getAccessToken());
    }
}
