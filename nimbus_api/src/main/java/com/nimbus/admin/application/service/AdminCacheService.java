package com.nimbus.admin.application.service;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

/**
 * Service for cache invalidation in admin operations.
 * Evicts caches when data changes so admin views stay fresh.
 * Also clears all caches on startup to prevent stale data from previous deployments.
 */
@Service
@Slf4j
public class AdminCacheService {

    private final CacheManager cacheManager;

    public AdminCacheService(CacheManager cacheManager) {
        this.cacheManager = cacheManager;
    }

    /**
     * Clear all admin caches on application startup.
     * This prevents deserialization errors when record structures change
     * between deployments (e.g., BigDecimal → String field type changes).
     */
    @PostConstruct
    public void clearCachesOnStartup() {
        invalidateAll();
        log.info("Admin caches cleared on startup");
    }

    /**
     * Invalidate all admin-related caches.
     * Called after any mutation that affects dashboard stats or listings.
     */
    public void invalidateAll() {
        evictCache("admin-dashboard-stats");
        evictCache("admin-users");
        evictCache("admin-drivers");
        evictCache("admin-rides");
        evictCache("admin-payments");
        evictCache("admin-settlements");
        log.debug("Invalidated all admin caches");
    }

    /**
     * Invalidate only the dashboard stats cache.
     * More granular than invalidateAll when only stats are affected.
     */
    public void invalidateDashboardStats() {
        evictCache("admin-dashboard-stats");
    }

    public void invalidateUsers() { evictCache("admin-users"); }
    public void invalidateDrivers() { evictCache("admin-drivers"); }
    public void invalidateRides() { evictCache("admin-rides"); }
    public void invalidatePayments() { evictCache("admin-payments"); }
    public void invalidateSettlements() { evictCache("admin-settlements"); }

    private void evictCache(String cacheName) {
        var cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.clear();
        }
    }
}