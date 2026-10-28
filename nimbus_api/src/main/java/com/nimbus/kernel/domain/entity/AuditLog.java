package com.nimbus.kernel.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.net.InetAddress;
import java.time.Instant;
import java.util.UUID;

/**
 * Immutable audit trail for sensitive operations.
 */
@Entity
@Table(name = "audit_logs")
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuditLog {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_user_id")
    private User actorUser;

    @Column(name = "actor_role", length = 50)
    private String actorRole;

    @Column(length = 100, nullable = false)
    private String action;

    @Column(name = "entity_type", length = 50)
    private String entityType;

    @Column(name = "entity_id")
    private UUID entityId;

    @Column(name = "old_value", columnDefinition = "text")
    private String oldValue;

    @Column(name = "new_value", columnDefinition = "text")
    private String newValue;

    /**
     * Mapped as {@link InetAddress} so Hibernate 6 binds the JDBC parameter
     * with the PostgreSQL {@code inet} type; a plain String is sent as
     * varchar and rejected by the column ("column is of type inet but
     * expression is of type character varying") — even for NULL values.
     */
    @Column(name = "ip_address", columnDefinition = "inet")
    private InetAddress ipAddress;

    @Column(name = "device_id", length = 255)
    private String deviceId;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();
}