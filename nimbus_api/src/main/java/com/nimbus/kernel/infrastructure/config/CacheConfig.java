package com.nimbus.kernel.infrastructure.config;

import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.*;
import org.springframework.data.redis.cache.*;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.*;

import java.time.Duration;

/**
 * Redis cache configuration.
 * Defines cache TTLs for different domains:
 * - System config: 30 min (rarely changes, long TTL)
 * - Fare rules: 1 hour (updated occasionally)
 * - Admin dashboard stats: 2 min (aggregates, acceptable staleness)
 * - Admin listings: 5 min (paginated data)
 * - Default: 10 min (generic fallback)
 *
 * Note: GenericJackson2JsonRedisSerializer already includes type information
 * via @class property, so we don't need activateDefaultTyping on the ObjectMapper.
 * Using both causes serialization conflicts with records and BigDecimal.
 */
@Configuration
@EnableCaching
public class CacheConfig {

    /**
     * ObjectMapper for Redis serialization.
     * GenericJackson2JsonRedisSerializer adds @class type info itself,
     * so we only need to register JavaTimeModule for Instant serialization.
     * Do NOT activate default typing - it conflicts with the serializer's built-in type handling.
     */
    private ObjectMapper cacheObjectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        return mapper;
    }

    @Bean
    public RedisCacheConfiguration cacheConfiguration() {
        GenericJackson2JsonRedisSerializer serializer = new GenericJackson2JsonRedisSerializer(cacheObjectMapper());

        return RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(10))
                .serializeKeysWith(
                        RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer())
                )
                .serializeValuesWith(
                        RedisSerializationContext.SerializationPair.fromSerializer(serializer)
                )
                .disableCachingNullValues();
    }

    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration defaultConfig = cacheConfiguration();

        // Short TTL for config values (with periodic refresh)
        RedisCacheConfiguration systemConfigConfig = defaultConfig.entryTtl(Duration.ofMinutes(30));

        // Fare rules - cached for 1 hour
        RedisCacheConfiguration fareRulesConfig = defaultConfig.entryTtl(Duration.ofHours(1));

        // Admin dashboard stats - cached for 2 minutes (aggregates)
        RedisCacheConfiguration adminStatsConfig = defaultConfig.entryTtl(Duration.ofMinutes(2));

        // Admin listings - cached for 5 minutes
        RedisCacheConfiguration adminListingsConfig = defaultConfig.entryTtl(Duration.ofMinutes(5));

        return RedisCacheManager.RedisCacheManagerBuilder
                .fromConnectionFactory(factory)
                .withCacheConfiguration("config", systemConfigConfig)
                .withCacheConfiguration("fare-rules", fareRulesConfig)
                .withCacheConfiguration("admin-dashboard-stats", adminStatsConfig)
                .withCacheConfiguration("admin-users", adminListingsConfig)
                .withCacheConfiguration("admin-drivers", adminListingsConfig)
                .withCacheConfiguration("admin-rides", adminListingsConfig)
                .withCacheConfiguration("admin-payments", adminListingsConfig)
                .withCacheConfiguration("admin-settlements", adminListingsConfig)
                .build();
    }
}