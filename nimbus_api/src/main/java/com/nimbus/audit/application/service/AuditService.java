package com.nimbus.audit.application.service;

import com.nimbus.kernel.domain.entity.AuditLog;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.repository.AuditLogRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.UUID;

/**
 * Service for recording audit trail entries for sensitive operations.
 */
@Service
@Slf4j
public class AuditService {

    private final AuditLogRepository auditLogRepository;

    public AuditService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    /**
     * Record an audit event for a sensitive operation.
     *
     * @param actorId  The user performing the action
     * @param action   The action performed (e.g., DRIVER_APPROVED)
     * @param entityType The type of entity (e.g., DRIVER, RIDE)
     * @param entityId The entity ID affected
     * @param oldValue The old value (JSON string, optional)
     * @param newValue The new value (JSON string, optional)
     * @param request  The HTTP request (for IP and device tracking)
     */
    public void logAction(UUID actorId, String action, String entityType, UUID entityId,
                          String oldValue, String newValue, HttpServletRequest request) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .actorUser(actorId != null ? User.builder().id(actorId).build() : null)
                    .actorRole(null)
                    .action(action)
                    .entityType(entityType)
                    .entityId(entityId)
                    .oldValue(maskSensitiveData(oldValue))
                    .newValue(maskSensitiveData(newValue))
                    .ipAddress(getClientIp(request))
                    .deviceId(null) // Could extract from headers
                    .createdAt(Instant.now())
                    .build();

            auditLogRepository.save(auditLog);
            log.info("Audit logged: action={}, entityType={}, entityId={}", action, entityType, entityId);
        } catch (Exception e) {
            log.error("Failed to log audit event: {}", e.getMessage(), e);
        }
    }

    /**
     * Mask sensitive data in JSON strings before logging.
     */
    private String maskSensitiveData(String json) {
        if (json == null) return null;
        return json
                .replaceAll("\"(phone|otp|password|token|cardNumber|nid)[^\"]*\":\"[^\"]*\"",
                        "\"$1\":\"***MASKED***\"");
    }

    /**
     * Extract client IP address from request.
     */
    private String getClientIp(HttpServletRequest request) {
        if (request == null) return null;

        String xf = request.getHeader("X-Forwarded-For");
        if (xf != null && !xf.isEmpty() && !"unknown".equalsIgnoreCase(xf)) {
            return xf.split(",")[0].trim();
        }

        String hl = request.getHeader("X-Real-IP");
        if (hl != null && !hl.isEmpty() && !"unknown".equalsIgnoreCase(hl)) {
            return hl;
        }

        return request.getRemoteAddr();
    }
}