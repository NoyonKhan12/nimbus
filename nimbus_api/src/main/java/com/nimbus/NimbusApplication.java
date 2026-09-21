package com.nimbus;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Nimbus Platform - Bangladesh Commuter Ride-Pooling Platform Backend.
 *
 * Modular monolith architecture with clear domain boundaries.
 * Backend is authoritative for all critical business decisions.
 */
@SpringBootApplication
@EnableAsync
@EnableScheduling
public class NimbusApplication {
    public static void main(String[] args) {
        SpringApplication.run(NimbusApplication.class, args);
    }
}