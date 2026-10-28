package com.nimbus.kernel.domain.entity;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Where;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

/**
 * Dynamically managed staff role. System roles are seeded by migration
 * and cannot be deleted; permissions map capability keys to access
 * levels (FULL / VIEW / NONE) and are persisted as JSON.
 */
@Entity
@Table(name = "roles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Where(clause = "deleted_at IS NULL")
public class Role {

    /** Capability keys shared with the admin portal (must match lib/permissions.ts). */
    public static final String[] CAPABILITY_KEYS = {
        "users", "passengers", "drivers", "vehicles", "rides",
        "payments", "settlements", "complaints", "safety", "config",
    };

    @Id
    @GeneratedValue
    private UUID id;

    /** Immutable uppercase identifier (e.g. ADMIN, SUPPORT, SUPERVISOR). */
    @Column(length = 64, nullable = false, unique = true)
    private String name;

    @Column
    private String description;

    @Column(name = "is_system", nullable = false)
    @Builder.Default
    private boolean system = false;

    /** JSON object: { "<capabilityKey>": "FULL" | "VIEW" | "NONE" } */
    @Column(columnDefinition = "TEXT")
    @Builder.Default
    private String permissions = "{}";

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @Column(name = "deleted_at")
    private Instant deletedAt;

    private static final ObjectMapper MAPPER = new ObjectMapper();

    public Map<String, String> permissions() {
        try {
            return MAPPER.readValue(permissions == null ? "{}" : permissions,
                    new TypeReference<Map<String, String>>() {});
        } catch (Exception e) {
            return Map.of();
        }
    }

    public void setPermissions(Map<String, String> map) {
        try {
            this.permissions = MAPPER.writeValueAsString(map == null ? Map.of() : map);
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid permissions object");
        }
    }
}
