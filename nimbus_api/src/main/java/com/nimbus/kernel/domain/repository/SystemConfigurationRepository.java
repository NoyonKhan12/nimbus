package com.nimbus.kernel.domain.repository;

import com.nimbus.kernel.domain.entity.SystemConfiguration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for system configuration operations.
 */
@Repository
public interface SystemConfigurationRepository extends JpaRepository<SystemConfiguration, UUID> {
    Optional<SystemConfiguration> findByConfigKey(String configKey);
    boolean existsByConfigKey(String configKey);

    default String getStringValue(String key, String defaultValue) {
        return findByConfigKey(key)
                .map(SystemConfiguration::getConfigValue)
                .orElse(defaultValue);
    }

    default int getIntValue(String key, int defaultValue) {
        return findByConfigKey(key)
                .map(SystemConfiguration::getConfigValue)
                .map(Integer::parseInt)
                .orElse(defaultValue);
    }

    default long getLongValue(String key, long defaultValue) {
        return findByConfigKey(key)
                .map(SystemConfiguration::getConfigValue)
                .map(Long::parseLong)
                .orElse(defaultValue);
    }

    default BigDecimal getDecimalValue(String key, BigDecimal defaultValue) {
        return findByConfigKey(key)
                .map(SystemConfiguration::getConfigValue)
                .map(BigDecimal::new)
                .orElse(defaultValue);
    }
}