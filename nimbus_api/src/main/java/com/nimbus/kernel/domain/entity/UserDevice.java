package com.nimbus.kernel.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Tracks user devices for push notifications and session management.
 */
@Entity
@Table(name = "user_devices")
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDevice {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "device_id", length = 255, nullable = false)
    private String deviceId;

    @Column(length = 20, nullable = false)
    @Enumerated(EnumType.STRING)
    private Platform platform;

    @Column(name = "push_token", columnDefinition = "TEXT")
    private String pushToken;

    @Column(name = "app_version", length = 50)
    private String appVersion;

    @Column(name = "last_seen_at")
    private Instant lastSeenAt;

    @Column(length = 20, nullable = false)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private DeviceStatus status = DeviceStatus.ACTIVE;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum Platform {
        ANDROID, IOS, WEB
    }

    public enum DeviceStatus {
        ACTIVE, INACTIVE
    }

    public void markAsSeen() {
        lastSeenAt = Instant.now();
        status = DeviceStatus.ACTIVE;
    }
}