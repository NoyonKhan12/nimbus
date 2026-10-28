package com.nimbus.driver.domain.repository;

import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.admin.domain.projection.DriverAdminProjection;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.*;

/**
 * Repository for driver profile operations.
 */
@Repository
public interface DriverProfileRepository extends JpaRepository<DriverProfile, UUID> {
    Optional<DriverProfile> findByUserId(UUID userId);
    boolean existsByUserId(UUID userId);
    List<DriverProfile> findByDueAmountGreaterThan(java.math.BigDecimal dueAmount);

    @Deprecated(forRemoval = true)
    List<DriverProfile> findByUserPhoneContainingOrUserEmailContaining(String phone, String email, Pageable pageable);

    @Deprecated(forRemoval = true)
    List<DriverProfile> findByApprovalStatus(DriverProfile.ApprovalStatus status, Pageable pageable);

    // ── Optimized admin queries ──────────────────────────────────────────

    /**
     * Fetch drivers joined with user in a single query to avoid N+1.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.DriverAdminProjection(" +
           "d.id, d.user.id, d.user.phone, d.user.email, CAST(d.approvalStatus AS string), " +
           "CAST(d.driverStatus AS string), d.licenseNumber, d.rating, d.totalRides, " +
           "d.totalEarnings, d.dueAmount, d.createdAt, p.firstName, p.lastName) " +
           "FROM DriverProfile d JOIN d.user u LEFT JOIN UserProfile p ON p.user.id = d.user.id " +
           "WHERE (:search IS NULL OR u.phone LIKE %:search% OR u.email LIKE %:search%) " +
           "AND (:approvalStatus IS NULL OR d.approvalStatus = :approvalStatus) " +
           "ORDER BY d.createdAt DESC")
    Page<DriverAdminProjection> findAdminDrivers(
            @Param("search") String search,
            @Param("approvalStatus") DriverProfile.ApprovalStatus approvalStatus,
            Pageable pageable
    );

    /**
     * Fetch driver by ID joined with user to avoid lazy loading.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.DriverAdminProjection(" +
           "d.id, d.user.id, d.user.phone, d.user.email, CAST(d.approvalStatus AS string), " +
           "CAST(d.driverStatus AS string), d.licenseNumber, d.rating, d.totalRides, " +
           "d.totalEarnings, d.dueAmount, d.createdAt, p.firstName, p.lastName) " +
           "FROM DriverProfile d JOIN d.user u LEFT JOIN UserProfile p ON p.user.id = d.user.id WHERE d.id = :id")
    Optional<DriverAdminProjection> findByIdProjection(@Param("id") UUID id);
}
