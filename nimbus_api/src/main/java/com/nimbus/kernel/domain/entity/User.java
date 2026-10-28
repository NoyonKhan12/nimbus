package com.nimbus.kernel.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.Where;

import java.time.Instant;
import java.util.UUID;

/**
 * Core identity entity. A user can be a passenger, driver, or admin.
 */
@Entity
@Table(name = "users")
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
@SQLDelete(sql = "UPDATE users SET deleted_at = NOW() WHERE id = ?")
@Where(clause = "deleted_at IS NULL")
public class User {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(length = 20, nullable = false, unique = true)
    private String phone;

    @Column(length = 255)
    private String email;

    @Column(name = "password_hash", length = 255)
    private String passwordHash;

    @Column(length = 20, nullable = false)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private UserStatus status = UserStatus.PENDING;

    /**
     * Role name (references the dynamic \`roles\` table). Fixed system values
     * keep their historical names: PASSENGER, DRIVER, ADMIN, OPERATIONS,
     * FINANCE, SUPPORT, SAFETY. Custom staff roles are managed in Settings.
     */
    @Column(length = 64, nullable = false)
    @Builder.Default
    private String role = "PASSENGER";

    @Column(name = "phone_verified", nullable = false)
    @Builder.Default
    private boolean phoneVerified = false;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @Column(name = "deleted_at")
    private Instant deletedAt;

    public enum UserStatus {
        PENDING, ACTIVE, SUSPENDED, BANNED
    }

    public boolean isActive() {
        return status == UserStatus.ACTIVE;
    }
}