package com.nimbus.kernel.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Stores business configuration values in the database.
 * Allows runtime configuration without code changes.
 */
@Entity
@Table(name = "system_configurations")
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class SystemConfiguration {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "config_key", length = 100, nullable = false, unique = true)
    private String configKey;

    @Column(name = "config_value", columnDefinition = "TEXT")
    private String configValue;

    @Column(name = "config_type", length = 50, nullable = false)
    @Enumerated(EnumType.STRING)
    private ConfigType configType;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_encrypted", nullable = false)
    @Builder.Default
    private boolean encrypted = false;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum ConfigType {
        STRING, INTEGER, DECIMAL, BOOLEAN, JSON
    }

    public Integer asInteger() {
        if (configValue == null) return null;
        try { return Integer.parseInt(configValue); } catch (NumberFormatException e) { return null; }
    }

    public Double asDouble() {
        if (configValue == null) return null;
        try { return Double.parseDouble(configValue); } catch (NumberFormatException e) { return null; }
    }

    public Boolean asBoolean() {
        if (configValue == null) return null;
        return Boolean.parseBoolean(configValue);
    }
}