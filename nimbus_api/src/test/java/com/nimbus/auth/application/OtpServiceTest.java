package com.nimbus.auth.application;

import com.nimbus.auth.application.service.OtpService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.*;

import java.time.Duration;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OtpServiceTest {

    @Mock
    private StringRedisTemplate redisTemplate;

    @Mock
    private ValueOperations<String, String> valueOperations;

    private OtpService otpService;

    @BeforeEach
    void setUp() {
        otpService = new OtpService(redisTemplate, 6, 5, 3, 5);
    }

    @Test
    void storeOtp_generatesValidOtp() {
        String phone = "+8801712345678";

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);

        String otp = otpService.storeOtp(phone);

        assertNotNull(otp);
        assertEquals(6, otp.length());
        assertTrue(otp.matches("\\d{6}"));

        verify(valueOperations, times(1)).set(
                eq("nimbus:otp:" + phone),
                eq(otp),
                any(Duration.class)
        );
        verify(redisTemplate, times(1)).delete("nimbus:otp:attempts:" + phone);
    }

    @Test
    void validateOtp_correctOtp_returnsTrue() {
        String phone = "+8801712345678";
        String otp = "123456";

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("nimbus:otp:" + phone)).thenReturn(otp);

        boolean result = otpService.validateOtp(phone, otp);

        assertTrue(result);
        verify(redisTemplate).delete("nimbus:otp:" + phone);
        verify(redisTemplate).delete("nimbus:otp:attempts:" + phone);
    }

    @Test
    void validateOtp_wrongOtp_returnsFalse() {
        String phone = "+8801712345678";
        String otp = "999999";

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("nimbus:otp:" + phone)).thenReturn("123456");
        when(valueOperations.get("nimbus:otp:attempts:" + phone)).thenReturn(null);

        boolean result = otpService.validateOtp(phone, otp);

        assertFalse(result);
        verify(valueOperations, times(1)).increment(eq("nimbus:otp:attempts:" + phone));
    }

    @Test
    void validateOtp_noStoredOtp_returnsFalse() {
        String phone = "+8801712345678";
        String otp = "123456";

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("nimbus:otp:" + phone)).thenReturn(null);

        boolean result = otpService.validateOtp(phone, otp);

        assertFalse(result);
    }

    @Test
    void isRateLimited_withinLimit_returnsFalse() {
        String phone = "+8801712345678";

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("nimbus:otp:rate:" + phone)).thenReturn(null);

        assertFalse(otpService.isRateLimited(phone));
    }

    @Test
    void isRateLimited_exceedsLimit_returnsTrue() {
        String phone = "+8801712345678";

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("nimbus:otp:rate:" + phone)).thenReturn("6");

        assertTrue(otpService.isRateLimited(phone));
    }

    @Test
    void clearOtp_deletesKeys() {
        String phone = "+8801712345678";

        otpService.clearOtp(phone);

        verify(redisTemplate).delete("nimbus:otp:" + phone);
        verify(redisTemplate).delete("nimbus:otp:attempts:" + phone);
    }
}
