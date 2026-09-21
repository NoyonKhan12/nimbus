package com.nimbus.kernel.infrastructure.interceptor;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

/**
 * Web configuration for registering interceptors.
 *
 * <p>Registers:
 * - IdempotencyInterceptor: protects payment and critical state-changing operations
 * - RateLimitInterceptor: distributed rate limiting using Redis sliding window</p>
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final IdempotencyInterceptor idempotencyInterceptor;
    private final RateLimitInterceptor rateLimitInterceptor;

    public WebConfig(IdempotencyInterceptor idempotencyInterceptor,
                     RateLimitInterceptor rateLimitInterceptor) {
        this.idempotencyInterceptor = idempotencyInterceptor;
        this.rateLimitInterceptor = rateLimitInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // Rate limiting on all endpoints
        registry.addInterceptor(rateLimitInterceptor);

        // Idempotency protection on critical payment and booking endpoints
        registry.addInterceptor(idempotencyInterceptor)
                .addPathPatterns("/payments/**")
                .addPathPatterns("/bookings/**");
    }
}
