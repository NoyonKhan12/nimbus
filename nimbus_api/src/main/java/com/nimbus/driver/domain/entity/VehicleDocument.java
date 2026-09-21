package com.nimbus.driver.domain.entity;

import com.nimbus.driver.domain.entity.Vehicle;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Vehicle document entity (registration, insurance, etc.).
 */
@Entity
@Table(name = "vehicle_documents", indexes = {
    @Index(name = "idx_vehicle_documents_vehicle_id", columnList = "vehicle_id"),
    @Index(name = "idx_vehicle_documents_type", columnList = "document_type"),
    @Index(name = "idx_vehicle_documents_expires_at", columnList = "expires_at")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VehicleDocument {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id", nullable = false, foreignKey = @ForeignKey(name = "fk_vdoc_vehicle"))
    private Vehicle vehicle;

    @Column(name = "document_type", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private DocumentType documentType;

    @Column(name = "document_number", length = 255)
    private String documentNumber;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private DocumentStatus status = DocumentStatus.PENDING;

    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(name = "is_verified", nullable = false)
    @Builder.Default
    private boolean verified = false;

    @Column(name = "document_url", columnDefinition = "TEXT")
    private String documentUrl;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum DocumentType {
        REGISTRATION,
        INSURANCE,
        FITNESS_CERTIFICATE,
        TAX_TOKEN,
        OTHER
    }

    public enum DocumentStatus {
        PENDING,
        APPROVED,
        REJECTED,
        EXPIRED
    }

    public boolean isExpired() {
        return expiresAt != null && Instant.now().isAfter(expiresAt);
    }

    public boolean isValid() {
        return status == DocumentStatus.APPROVED && !isExpired();
    }
}
