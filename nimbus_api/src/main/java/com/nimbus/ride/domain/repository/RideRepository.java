package com.nimbus.ride.domain.repository;

import com.nimbus.admin.domain.projection.DashboardStats;
import com.nimbus.admin.domain.projection.RecentRide;
import com.nimbus.admin.domain.projection.RideAdminProjection;
import com.nimbus.ride.domain.entity.Ride;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.*;

/**
 * Repository for ride operations with spatial and temporal query support.
 */
@Repository
public interface RideRepository extends JpaRepository<Ride, UUID> {

    List<Ride> findByCreatorId(UUID creatorId);

    List<Ride> findByCreatorIdAndStatus(UUID creatorId, Ride.RideStatus status);

    List<Ride> findByStatus(Ride.RideStatus status);
    long countByStatusIn(Collection<Ride.RideStatus> statuses);
    Page<Ride> findByStatus(Ride.RideStatus status, Pageable pageable);

    List<Ride> findByDriverIdAndStatus(UUID driverId, Ride.RideStatus status);

    @Query("SELECT r FROM Ride r WHERE r.status = :status AND r.scheduledAt >= :after " +
           "ORDER BY r.scheduledAt ASC")
    List<Ride> findByStatusAndScheduledAfter(
            @Param("status") Ride.RideStatus status,
            @Param("after") Instant after
    );

    @Query("SELECT r FROM Ride r WHERE r.driver.id = :driverId AND r.status IN (:statuses) " +
           "ORDER BY r.scheduledAt DESC")
    List<Ride> findByDriverIdAndStatusIn(
            @Param("driverId") UUID driverId,
            @Param("statuses") Collection<Ride.RideStatus> statuses
    );

    @Query("SELECT r FROM Ride r WHERE r.status = PUBLISHED " +
           "AND (:status IS NULL OR r.status = :status) " +
           "AND (:type IS NULL OR r.type = :type) " +
           "AND r.deletedAt IS NULL " +
           "ORDER BY r.scheduledAt ASC")
    List<Ride> findSearchableRides(
            @Param("status") Ride.RideStatus status,
            @Param("type") Ride.RideType type
    );

    // ── Optimized admin queries ──────────────────────────────────────────

    /**
     * Fetch rides as projections to avoid lazy loading issues and N+1.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.RideAdminProjection(" +
           "r.id, d.user.id, u.id, CAST(r.status AS string), r.originAddress, r.destinationAddress, " +
           "r.scheduledAt, r.actualStartAt, r.actualEndAt, r.createdAt) " +
           "FROM Ride r LEFT JOIN r.driver d LEFT JOIN r.creator u " +
           "WHERE (:status IS NULL OR r.status = :status) " +
           "ORDER BY r.createdAt DESC")
    Page<RideAdminProjection> findAdminRides(
            @Param("status") Ride.RideStatus status,
            Pageable pageable
    );

    /**
     * Fetch ride by ID as projection.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.RideAdminProjection(" +
           "r.id, d.user.id, u.id, CAST(r.status AS string), r.originAddress, r.destinationAddress, " +
           "r.scheduledAt, r.actualStartAt, r.actualEndAt, r.createdAt) " +
           "FROM Ride r LEFT JOIN r.driver d LEFT JOIN r.creator u WHERE r.id = :id")
    Optional<RideAdminProjection> findByIdProjection(@Param("id") UUID id);

    /**
     * Fetch recent rides for dashboard, returning projection DTOs.
     * Single JOIN query avoids N+1 on driver/creator.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.RecentRide(" +
           "CAST(r.id AS string), CAST(u.id AS string), CAST(d.user.id AS string), " +
           "CAST(r.status AS string), r.originAddress, r.destinationAddress, CAST(r.createdAt AS string)) " +
           "FROM Ride r LEFT JOIN r.driver d LEFT JOIN r.creator u " +
           "ORDER BY r.createdAt DESC")
    List<RecentRide> findRecentRides(Pageable pageable);
}
