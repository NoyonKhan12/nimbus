package com.nimbus.admin.domain.projection;

/**
 * Projection for a recent ride in dashboard stats.
 */
public record RecentRide(
    String id,
    String userId,
    String driverId,
    String status,
    String originAddress,
    String destinationAddress,
    java.time.Instant createdAt,
    String originLocation,
    String destinationLocation
) {
}
