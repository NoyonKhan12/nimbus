package com.nimbus.settlement.domain.repository;

import com.nimbus.admin.domain.projection.SettlementAdminProjection;
import com.nimbus.settlement.domain.entity.Settlement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.*;
import java.util.*;

@Repository
public interface SettlementRepository extends JpaRepository<Settlement, UUID> {
    List<Settlement> findByDriverIdAndPeriodStartBetween(UUID driverId, Instant start, Instant end);
    List<Settlement> findByStatus(Settlement.SettlementStatus status);
    Page<Settlement> findByStatus(Settlement.SettlementStatus status, Pageable pageable);
    Optional<Settlement> findByDriverIdAndPeriodStartAndPeriodEnd(UUID driverId, Instant periodStart, Instant periodEnd);
    long countByStatus(Settlement.SettlementStatus status);
    List<Settlement> findByPeriodStartBetween(Instant start, Instant end);

    // ── Optimized admin queries ──────────────────────────────────────────

    /**
     * Fetch settlements as projections to avoid lazy loading and N+1.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.SettlementAdminProjection(" +
           "s.id, d.user.id, s.periodStart, s.periodEnd, s.grossEarnings, " +
           "s.commission, s.payable, CAST(s.status AS string), s.createdAt, s.paymentReference) " +
           "FROM Settlement s JOIN s.driver d " +
           "WHERE (:status IS NULL OR s.status = :status) " +
           "ORDER BY s.createdAt DESC")
    Page<SettlementAdminProjection> findAdminSettlements(
            @Param("status") Settlement.SettlementStatus status,
            Pageable pageable
    );

    /**
     * Fetch settlement by ID as projection.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.SettlementAdminProjection(" +
           "s.id, d.user.id, s.periodStart, s.periodEnd, s.grossEarnings, " +
           "s.commission, s.payable, CAST(s.status AS string), s.createdAt, s.paymentReference) " +
           "FROM Settlement s JOIN s.driver d WHERE s.id = :id")
    Optional<SettlementAdminProjection> findByIdProjection(@Param("id") UUID id);
}
