package com.nimbus.driver.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Driver document entity (license, NID, etc.).
 *
 * <p>Documents are stored in controlled object storage.
 * Verification is handled by the operations team.
 * Documents have expiry dates that must be tracked for eligibility.</p>
 */
@Entity
@Table(name = "driver_documents", indexes = {
    @Index(name = "idx_driver_documents_driver_id", columnList = "driver_id"),
    @Index(name = "idx_driver_documents_type", columnList = "document_type"),
    @Index(name = "idx_driver_documents_expires_at", columnList = "expires_at"),
    @Index(name = "idx_driver_documents_status", columnList = "status")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverDocument {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = false, foreignKey = @ForeignKey(name = "fk_doc_driver"))
    private DriverProfile driver;

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

    /** Opaque storage key (relative path) for an uploaded file. */
    @Column(name = "storage_key", length = 255)
    private String storageKey;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    public enum DocumentType {
        DRIVER_LICENSE,
        NATIONAL_ID,
        VEHICLE_REGISTRATION,
        INSURANCE,
        ROAD_PERMIT,
        OTHER
    }

    public enum DocumentStatus {
        PENDING,    // Awaiting review
        APPROVED,   // Verified and valid
        REJECTED,   // Invalid/rejected
        EXPIRED     // Past expiry date
    }

    /**
     * Check if document is expired.
     */
    public boolean isExpired() {
        return expiresAt != null && Instant.now().isAfter(expiresAt);
    }

    /**
     * Check if document is valid (approved and not expired).
     */
    public boolean isValid() {
        return status == DocumentStatus.APPROVED && !isExpired();
    }
}
