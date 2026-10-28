package com.nimbus.kernel.infrastructure.config;

import com.fasterxml.jackson.datatype.hibernate6.Hibernate6Module;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Jackson configuration. Registers the Hibernate6 module so entities
 * returned by controllers serialize cleanly: uninitialized lazy proxies
 * become null instead of blowing up with ByteBuddyInterceptor
 * "no serializer" errors (seen on SafetyEvent → Ride → DriverProfile →
 * User chains). Loaded associations still serialize normally.
 */
@Configuration
public class JacksonConfig {

    @Bean
    public Hibernate6Module hibernate6Module() {
        return new Hibernate6Module();
    }
}
