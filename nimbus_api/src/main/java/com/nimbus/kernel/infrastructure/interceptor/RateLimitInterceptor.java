package com.nimbus.kernel.infrastructure.interceptor;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.domain.ErrorCode;
import jakarta.servlet.http.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.*;

import java.time.Duration;
import java.util.*;

/**
 * Rate limiting interceptor for API protection.
 *
 * <p>Uses Redis for distributed rate limiting with sliding window.
 * Limits are configurable per endpoint and user/IP.</p>
 */
@Component
@Slf4j
public class RateLimitInterceptor implements HandlerInterceptor {

    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    // Default rate limits
    private static final int DEFAULT_REQUESTS_PER_MINUTE = 100;

    public RateLimitInterceptor(StringRedisTemplate redisTemplate, ObjectMapper objectMapper) {
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String clientKey = getClientKey(request);
        String endpoint = request.getRequestURI();

        // Get rate limit for endpoint (default 100/min)
        int rateLimit = getRateLimitForEndpoint(endpoint);
        String redisKey = "rate-limit:" + clientKey + ":" + endpoint;

        // Use sliding window counter
        long count = incrementAndGet(redisKey, Duration.ofMinutes(1));
        if (count > rateLimit) {
            log.warn("Rate limit exceeded for {} at {}", clientKey, endpoint);
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            ApiResponse<Void> error = ApiResponse.<Void>builder()
                    .success(false)
                    .message("Rate limit exceeded. Please try again later.")
                    .timestamp(java.time.Instant.now().toString())
                    .build();
            response.getWriter().write(objectMapper.writeValueAsString(error));
            return false;
        }

        // Set rate limit headers
        response.setHeader("X-RateLimit-Limit", String.valueOf(rateLimit));
        response.setHeader("X-RateLimit-Remaining", String.valueOf(Math.max(0, rateLimit - count)));

        return true;
    }

    private String getClientKey(HttpServletRequest request) {
        // Use authenticated user ID if available, otherwise IP
        String userId = (String) request.getAttribute("userId");
        if (userId != null) return "user:" + userId;

        String ip = request.getRemoteAddr();
        if (ip == null) ip = "unknown";
        return "ip:" + ip;
    }

    private int getRateLimitForEndpoint(String endpoint) {
        // Endpoint-specific rate limits
        if (endpoint.contains("/auth/send-otp")) {
            return 5; // 5 OTP requests per minute
        }
        if (endpoint.contains("/auth/verify-otp")) {
            return 10; // 10 verify attempts per minute
        }
        if (endpoint.contains("/payments/webhooks")) {
            return 100; // High limit for webhook endpoints
        }
        if (endpoint.contains("/rides/search")) {
            return 30; // 30 search requests per minute
        }
        return DEFAULT_REQUESTS_PER_MINUTE;
    }

    private long incrementAndGet(String key, Duration ttl) {
        Long count = redisTemplate.opsForValue().increment(key);
        if (count != null && count == 1) {
            redisTemplate.expire(key, ttl);
        }
        return count != null ? count : 0;
    }
}
