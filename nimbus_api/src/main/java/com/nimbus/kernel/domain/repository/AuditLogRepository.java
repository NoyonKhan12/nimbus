package com.nimbus.kernel.domain.repository;

import com.nimbus.kernel.domain.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Repository for audit log operations.
 */
@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, UUID> {

    /** Retention purge (guide §25): removes logs past the cutoff. */
    long deleteByCreatedAtBefore(java.time.Instant cutoff);

    List<AuditLog> findByActorUserId(UUID actorUserId);
    List<AuditLog> findByAction(String action);
    List<AuditLog> findByEntityTypeAndEntityId(String entityType, UUID entityId);

    @Query("SELECT a FROM AuditLog a WHERE a.createdAt BETWEEN :start AND :end")
    List<AuditLog> findByCreatedAtBetween(@Param("start") Instant start, @Param("end") Instant end);
}
