package com.nimbus.admin.application.service;

import com.nimbus.audit.application.service.AuditService;
import com.nimbus.kernel.domain.entity.SystemConfiguration;
import com.nimbus.kernel.domain.repository.SystemConfigurationRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * Admin configuration operations (guide §20): fare/commission/voucher/
 * detour/wait settings read and maintained by operations, with audit and
 * cache eviction. Fare-rule versions live in fare_rules; these are the
 * operational system_configurations keys.
 */
@Service
@Slf4j
public class AdminConfigService {

    private final SystemConfigurationRepository configRepository;
    private final AuditService auditService;

    public AdminConfigService(SystemConfigurationRepository configRepository,
                              AuditService auditService) {
        this.configRepository = configRepository;
        this.auditService = auditService;
    }

    public List<SystemConfiguration> listConfiguration() {
        return configRepository.findAll();
    }

    @Transactional
    public SystemConfiguration upsert(String key, String value, String description) {
        var existing = configRepository.findByConfigKey(key);
        String oldValue = existing.map(SystemConfiguration::getConfigValue).orElse(null);

        SystemConfiguration config = existing.orElseGet(() -> SystemConfiguration.builder()
                .configKey(key)
                .configType(SystemConfiguration.ConfigType.DECIMAL)
                .build());
        config.setConfigValue(value);
        if (description != null) {
            config.setDescription(description);
        }
        SystemConfiguration saved = configRepository.save(config);

        auditService.logAction(currentUserIdOrNull(), "CONFIG_CHANGED", "SYSTEM_CONFIGURATION",
                saved.getId(), "value=" + oldValue, "value=" + value);
        log.info("Configuration {} updated by admin", key);
        return saved;
    }

    private UUID currentUserIdOrNull() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }
}
