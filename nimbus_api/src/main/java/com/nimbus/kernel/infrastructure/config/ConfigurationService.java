package com.nimbus.kernel.infrastructure.config;

import com.nimbus.kernel.domain.entity.SystemConfiguration;
import com.nimbus.kernel.domain.repository.SystemConfigurationRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Service for retrieving system configuration values.
 * Values are cached for performance.
 */
@Service
@Slf4j
public class ConfigurationService {

    private final SystemConfigurationRepository configRepository;

    public ConfigurationService(SystemConfigurationRepository configRepository) {
        this.configRepository = configRepository;
    }

    /**
     * Get a configuration value as Integer.
     */
    @Cacheable(value = "config", key = "#key")
    public Integer getInt(String key) {
        return getConfig(key).map(SystemConfiguration::asInteger).orElse(null);
    }

    /**
     * Get a configuration value as Double.
     */
    @Cacheable(value = "config", key = "#key")
    public Double getDouble(String key) {
        return getConfig(key).map(SystemConfiguration::asDouble).orElse(null);
    }

    /**
     * Get a configuration value as String.
     */
    @Cacheable(value = "config", key = "#key")
    public String getString(String key) {
        return getConfig(key).map(SystemConfiguration::getConfigValue).orElse(null);
    }

    /**
     * Get a configuration value as Boolean.
     */
    @Cacheable(value = "config", key = "#key")
    public Boolean getBoolean(String key) {
        return getConfig(key).map(SystemConfiguration::asBoolean).orElse(null);
    }

    /**
     * Get configuration entity by key.
     */
    private Optional<SystemConfiguration> getConfig(String key) {
        return configRepository.findByConfigKey(key);
    }

    /**
     * Get integer with default fallback.
     */
    public int getIntOrDefault(String key, int defaultValue) {
        Integer value = getInt(key);
        return value != null ? value : defaultValue;
    }

    /**
     * Get double with default fallback.
     */
    public double getDoubleOrDefault(String key, double defaultValue) {
        Double value = getDouble(key);
        return value != null ? value : defaultValue;
    }
}