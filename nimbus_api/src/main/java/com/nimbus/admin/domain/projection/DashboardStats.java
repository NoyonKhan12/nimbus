package com.nimbus.admin.domain.projection;

import java.util.List;

/**
 * Aggregated dashboard statistics computed in a single database query.
 * totalRevenue is a String (not BigDecimal) to avoid Jackson serialization issues
 * with GenericJackson2JsonRedisSerializer in Redis cache.
 */
public record DashboardStats(
    long totalUsers,
    long totalDrivers,
    long activeRides,
    long totalRides,
    long totalPayments,
    long pendingSettlements,
    String totalRevenue,
    List<RecentRide> recentRides
) {
}