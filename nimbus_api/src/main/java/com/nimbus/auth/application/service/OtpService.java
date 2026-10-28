package com.nimbus.auth.application.service;

import org.springframework.beans.factory.annotation.*;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Service for OTP generation, storage, and validation.
 * Uses Redis for temporary OTP storage with configurable TTL.
 */
@Service
public class OtpService {

    private final StringRedisTemplate redisTemplate;
    private final int otpLength;
    private final int otpTtlMinutes;
    private final int maxAttempts;
    private final int rateLimitPer15Min;

    @Autowired
    public OtpService(
            StringRedisTemplate redisTemplate,
            @Value("${app.otp.code-length:6}") int otpLength,
            @Value("${app.otp.expiration-minutes:5}") int otpTtlMinutes,
            @Value("${app.otp.max-attempts:3}") int maxAttempts,
            @Value("${app.otp.rate-limit-per-15min:5}") int rateLimitPer15Min) {
        this.redisTemplate = redisTemplate;
        this.otpLength = otpLength;
        this.otpTtlMinutes = otpTtlMinutes;
        this.maxAttempts = maxAttempts;
        this.rateLimitPer15Min = rateLimitPer15Min;
    }

    private String otpKey(String phone) {
        return "otp:" + phone;
    }

    private String attemptsKey(String phone) {
        return "otp:attempts:" + phone;
    }

    /**
     * Generate a random numeric OTP of configured length.
     */
    private String generateOtp() {
        long min = (long) Math.pow(10, otpLength - 1);
        long max = (long) Math.pow(10, otpLength) - 1;
        long random = min + ThreadLocalRandom.current().nextLong(max - min + 1);
        return String.format("%0" + otpLength + "d", random);
    }

    /**
     * Store OTP in Redis with TTL and clear attempt counter.
     * Returns the OTP for sending (in production, this would be sent via SMS provider).
     */
    public String storeOtp(String phone) {
        String otp = generateOtp();
        redisTemplate.opsForValue().set(otpKey(phone), otp, Duration.ofMinutes(otpTtlMinutes));
        redisTemplate.delete(attemptsKey(phone));
        return otp;
    }

    /**
     * Validate OTP for the given phone number.
     * Returns true if valid and not expired, false otherwise.
     */
    public boolean validateOtp(String phone, String otp) {
        String storedOtp = redisTemplate.opsForValue().get(otpKey(phone));
        String attemptsStr = redisTemplate.opsForValue().get(attemptsKey(phone));
        int attempts = attemptsStr != null ? Integer.parseInt(attemptsStr) : 0;

        if (storedOtp == null) {
            return false;
        }

        if (attempts >= maxAttempts) {
            redisTemplate.delete(otpKey(phone));
            return false;
        }

        if (!storedOtp.equals(otp)) {
            // Increment attempts
            redisTemplate.opsForValue().increment(attemptsKey(phone));
            redisTemplate.expire(attemptsKey(phone), Duration.ofMinutes(otpTtlMinutes));
            return false;
        }

        // OTP verified - clear it and attempts
        redisTemplate.delete(otpKey(phone));
        redisTemplate.delete(attemptsKey(phone));
        return true;
    }

    /**
     * Clear OTP for a phone (after successful verification or timeout).
     */
    public void clearOtp(String phone) {
        redisTemplate.delete(otpKey(phone));
        redisTemplate.delete(attemptsKey(phone));
    }

    /**
     * Increment the rate limit counter for OTP requests.
     * Returns the current count.
     */
    public long incrementRateLimit(String phone) {
        String key = "otp:rate:" + phone;
        Long count = redisTemplate.opsForValue().increment(key, 1);
        if (count != null && count == 1) {
            redisTemplate.expire(key, Duration.ofMinutes(15));
        }
        return count != null ? count : 0;
    }

    /**
     * Check if the phone has exceeded OTP request rate limit.
     */
    public boolean isRateLimited(String phone) {
        String key = "otp:rate:" + phone;
        String countStr = redisTemplate.opsForValue().get(key);
        int count = countStr != null ? Integer.parseInt(countStr) : 0;
        return count >= rateLimitPer15Min;
    }
}