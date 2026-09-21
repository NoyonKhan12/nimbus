package com.nimbus.admin.domain.projection;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Projection for admin driver listing - joins user in a single query to avoid N+1.
 */
public record DriverAdminProjection(
    UUID id,
    UUID userId,
    String phone,
    String email,
    String approvalStatus,
    String driverStatus,
    String licenseNumber,
    BigDecimal rating,
    Integer totalRides,
    BigDecimal totalEarnings,
    BigDecimal dueAmount,
    Instant createdAt
) {
}
