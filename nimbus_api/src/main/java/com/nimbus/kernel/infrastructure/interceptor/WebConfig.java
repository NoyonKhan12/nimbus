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
    private final String uploadDir;

    public WebConfig(IdempotencyInterceptor idempotencyInterceptor,
                     RateLimitInterceptor rateLimitInterceptor,
                     @org.springframework.beans.factory.annotation.Value("${app.upload.dir:./data/uploads}") String uploadDir) {
        this.idempotencyInterceptor = idempotencyInterceptor;
        this.rateLimitInterceptor = rateLimitInterceptor;
        this.uploadDir = uploadDir;
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

    /**
     * Serves profile-photo uploads from the local storage dir. In
     * production these move to object storage behind a CDN (guide §4).
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String dir = java.nio.file.Path.of(uploadDir).toAbsolutePath().normalize().toString();
        registry.addResourceHandler("/uploads/profile/**")
                .addResourceLocations("file:" + dir + "/profile/");
    }
}
