package com.nimbus.driver.domain.entity;

import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Driver profile extending the base user with driver-specific attributes.
 *
 * <p>Driver eligibility requires:
 * - Active account
 * - Approved driver status
 * - Approved active vehicle
 * - Valid required documents
 * - No suspension/ban
 * - Zero previous due (cleared via settlement)</p>
 */
@Entity
@Table(name = "driver_profiles", indexes = {
    @Index(name = "idx_driver_profiles_user_id", columnList = "user_id"),
    @Index(name = "idx_driver_profiles_approval_status", columnList = "approval_status"),
    @Index(name = "idx_driver_profiles_driver_status", columnList = "driver_status")
})
// Note: current_location is stored as WKT string for simplicity in this implementation
// In production, use proper PostGIS geometry type
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverProfile {

    @Id
    @GeneratedValue
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true, foreignKey = @ForeignKey(name = "fk_driver_profile_user"))
    private User user;

    @Column(name = "driver_status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private DriverStatus driverStatus = DriverStatus.OFFLINE;

    @Column(name = "approval_status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private ApprovalStatus approvalStatus = ApprovalStatus.PENDING;

    @Column(name = "license_number", length = 100)
    private String licenseNumber;

    @Column(name = "license_expiry")
    private Instant licenseExpiry;

    @Column(name = "rating", precision = 3, scale = 2)
    @Builder.Default
    private BigDecimal rating = BigDecimal.ZERO;

    @Column(name = "reliability_score", precision = 5, scale = 4)
    @Builder.Default
    private BigDecimal reliabilityScore = BigDecimal.ONE;

    @Column(name = "current_location", columnDefinition = "GEOMETRY(Point, 4326)")
    private String currentLocation;

    @Column(name = "current_location_updated_at")
    private Instant currentLocationUpdatedAt;

    @Column(name = "total_rides")
    @Builder.Default
    private Integer totalRides = 0;

    @Column(name = "total_earnings", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal totalEarnings = BigDecimal.ZERO;

    @Column(name = "commission_rate", precision = 5, scale = 2)
    private BigDecimal commissionRate;

    @Column(name = "due_amount", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal dueAmount = BigDecimal.ZERO;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @OneToMany(mappedBy = "driver", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<DriverDocument> documents = new ArrayList<>();

    @OneToMany(mappedBy = "driver", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Vehicle> vehicles = new ArrayList<>();

    public enum DriverStatus {
        OFFLINE, ONLINE, DRIVING, AWAY
    }

    public enum ApprovalStatus {
        PENDING, APPROVED, REJECTED, SUSPENDED
    }

    /**
     * Check if driver is eligible to operate.
     */
    public boolean isEligible() {
        return approvalStatus == ApprovalStatus.APPROVED &&
               driverStatus != DriverStatus.OFFLINE &&
               dueAmount.compareTo(BigDecimal.ZERO) == 0 &&
               !hasExpiredDocuments();
    }

    /**
     * Check if any required documents are expired.
     */
    private boolean hasExpiredDocuments() {
        return documents.stream().anyMatch(doc -> doc.isExpired());
    }

    /**
     * Get primary approved vehicle.
     */
    public Optional<Vehicle> getPrimaryVehicle() {
        return vehicles.stream()
                .filter(v -> v.getStatus() == Vehicle.VehicleStatus.APPROVED)
                .findFirst();
    }
}
