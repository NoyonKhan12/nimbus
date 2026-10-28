package com.nimbus.kernel.infrastructure.config;

import com.nimbus.kernel.domain.repository.RoleRepository;
import com.nimbus.kernel.infrastructure.security.JwtAuthenticationFilter;
import com.nimbus.kernel.infrastructure.security.StaffAuthorizationManager;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.*;
import org.springframework.security.authentication.*;
import org.springframework.security.config.annotation.web.builders.*;
import org.springframework.security.config.annotation.web.configuration.*;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.*;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Spring Security configuration with JWT-based authentication.
 */
@Configuration
@EnableWebSecurity
@org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final StaffAuthorizationManager staffAuthorizationManager;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter,
                          RoleRepository roleRepository) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
        this.staffAuthorizationManager = new StaffAuthorizationManager(roleRepository);
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authorizeHttpRequests(auth -> auth
                // Public endpoints. Note /auth/logout and /auth/sessions are
                // intentionally NOT public — they fall through to the
                // catch-all and require authentication (guide §18).
                .requestMatchers(
                    "/auth/send-otp",
                    "/auth/verify-otp",
                    "/auth/refresh",
                    "/admin/auth/**",
                    "/v3/api-docs/**",
                    "/swagger-ui.html",
                    "/swagger-ui/**",
                    "/actuator/health",
                    "/actuator/info",
                    "/ws/**",
                    // Public profile-photo objects (guide §15 /me/photo).
                    // NOTE: /uploads/documents/** is NOT public — driver
                    // documents are private (V15) and served only through
                    // the ownership-checked document endpoints below.
                    "/uploads/profile/**",
                    // Trip-share links are capability-token based (guide §19).
                    "/safety/share/*",
                    // Payment provider callbacks authenticate via provider
                    // signatures, not JWTs (guide §12).
                    "/payments/webhooks/**"
                ).permitAll()

                // Private document objects must never be served statically.
                .requestMatchers("/uploads/documents/**").denyAll()

                // Protected endpoints
                .requestMatchers(
                    "/me/**",
                    "/rides/**",
                    "/bookings/**",
                    "/drivers/**",
                    "/vehicles/**",
                    "/wallet/**",
                    "/payments/**",
                    "/ratings/**",
                    "/complaints/**",
                    "/safety/**",
                    "/notifications/**"
                ).authenticated()

                // Staff portal endpoints — any staff role (dynamic), not app users
                .requestMatchers(
                    "/admin/**",
                    "/internal/**"
                ).access(staffAuthorizationManager)

                .anyRequest().authenticated()
            )
            .httpBasic(AbstractHttpConfigurer::disable)
            .formLogin(AbstractHttpConfigurer::disable)
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((request, response, authException) -> {
                    // Missing/invalid token must be 401 (not 403) so clients can
                    // distinguish "refresh your token" from "not allowed".
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.setContentType("application/json");
                    response.getWriter().write(
                            "{\"success\":false,\"error\":{\"code\":\"UNAUTHORIZED\","
                            + "\"message\":\"Authentication required\"}}");
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    // Authenticated but the staff role lacks the capability.
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType("application/json");
                    response.getWriter().write(
                            "{\"success\":false,\"error\":{\"code\":\"FORBIDDEN\","
                            + "\"message\":\"You do not have permission for this action\"}}");
                }))
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new Argon2PasswordEncoder(16, 32, 4, 7680, 1);
    }
}