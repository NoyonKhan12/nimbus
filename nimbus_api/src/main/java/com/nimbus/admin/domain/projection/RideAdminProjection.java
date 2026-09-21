package com.nimbus.admin.domain.projection;

import java.time.Instant;
import java.util.UUID;

/**
 * Projection for admin ride listing - avoids lazy loading of driver/creator.
 */
public record RideAdminProjection(
    UUID id,
    UUID driverId,
    UUID userId,
    String status,
    String originAddress,
    String destinationAddress,
    Instant scheduledAt,
    Instant actualStartAt,
    Instant actualEndAt,
    Instant createdAt
) {
}
