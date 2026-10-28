package com.nimbus.audit.application.service;

import com.nimbus.kernel.domain.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

/**
 * Retention job (guide §25): purges audit logs past the approved retention
 * window. Disabled while the retention window is non-positive.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RetentionScheduler {

    private final AuditLogRepository auditLogRepository;

    @Value("${app.retention.audit-days:365}")
    private int auditRetentionDays;

    @Scheduled(cron = "${app.retention.cron:0 0 4 1 * *}")
    @Transactional
    public void purgeExpiredAuditLogs() {
        if (auditRetentionDays <= 0) {
            return; // retention policy not approved yet
        }
        Instant cutoff = Instant.now().minus(auditRetentionDays, ChronoUnit.DAYS);
        long removed = auditLogRepository.deleteByCreatedAtBefore(cutoff);
        if (removed > 0) {
            log.info("Retention: purged {} audit logs older than {} days", removed, auditRetentionDays);
        }
    }
}
