package com.nimbus.admin.application.service;

import com.nimbus.admin.domain.projection.DriverAdminProjection;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.kernel.application.dto.PagedResponse;
import com.nimbus.kernel.application.dto.PagedResponse.PageMeta;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;

/**
 * Service for admin driver operations.
 * Caching at the service layer to avoid ResponseEntity serialization issues.
 */
@Service
@Slf4j
public class AdminDriverService {

    private final DriverProfileRepository driverProfileRepository;
    private final AdminCacheService cacheService;
    private final com.nimbus.audit.application.service.AuditService auditService;

    public AdminDriverService(DriverProfileRepository driverProfileRepository, AdminCacheService cacheService,
                              com.nimbus.audit.application.service.AuditService auditService) {
        this.driverProfileRepository = driverProfileRepository;
        this.cacheService = cacheService;
        this.auditService = auditService;
    }

    public PagedResponse<DriverAdminProjection> listDrivers(int page, int size, String search, String status) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        DriverProfile.ApprovalStatus approvalStatus = null;
        if (status != null && !status.isEmpty()) {
            approvalStatus = DriverProfile.ApprovalStatus.valueOf(status.toUpperCase());
        }

        Page<DriverAdminProjection> driverPage = driverProfileRepository.findAdminDrivers(search, approvalStatus, pageable);
        return toPagedResponse(driverPage);
    }

    public Optional<DriverAdminProjection> getDriverById(String id) {
        UUID driverId = UUID.fromString(id);
        return driverProfileRepository.findByIdProjection(driverId);
    }

    public void approveDriver(String id) {
        UUID driverId = UUID.fromString(id);
        DriverProfile driver = driverProfileRepository.findById(driverId)
            .orElseThrow(() -> new RuntimeException("Driver not found"));
        String oldStatus = driver.getApprovalStatus() != null ? driver.getApprovalStatus().name() : null;
        driver.setApprovalStatus(DriverProfile.ApprovalStatus.APPROVED);
        driverProfileRepository.save(driver);
        cacheService.invalidateDrivers();
        cacheService.invalidateDashboardStats();
        auditService.logAction(currentUserIdOrNull(), "DRIVER_APPROVED", "DRIVER",
                driverId, "approval=" + oldStatus, "approval=APPROVED");
    }

    public void rejectDriver(String id) {
        UUID driverId = UUID.fromString(id);
        DriverProfile driver = driverProfileRepository.findById(driverId)
            .orElseThrow(() -> new RuntimeException("Driver not found"));
        String oldStatus = driver.getApprovalStatus() != null ? driver.getApprovalStatus().name() : null;
        driver.setApprovalStatus(DriverProfile.ApprovalStatus.REJECTED);
        driverProfileRepository.save(driver);
        cacheService.invalidateDrivers();
        auditService.logAction(currentUserIdOrNull(), "DRIVER_REJECTED", "DRIVER",
                driverId, "approval=" + oldStatus, "approval=REJECTED");
    }

    /**
     * Suspension / reinstatement via approval status (guide §20). A
     * suspended driver fails the unified eligibility check for new rides;
     * confirmed rides are not silently cancelled — operations reassigns.
     */
    public void setApprovalStatus(String id, String status) {
        UUID driverId = UUID.fromString(id);
        DriverProfile driver = driverProfileRepository.findById(driverId)
            .orElseThrow(() -> new RuntimeException("Driver not found"));
        DriverProfile.ApprovalStatus newStatus =
                DriverProfile.ApprovalStatus.valueOf(status.toUpperCase());
        String oldStatus = driver.getApprovalStatus() != null ? driver.getApprovalStatus().name() : null;
        driver.setApprovalStatus(newStatus);
        driverProfileRepository.save(driver);
        cacheService.invalidateDrivers();
        auditService.logAction(currentUserIdOrNull(), "DRIVER_APPROVAL_STATUS_CHANGED", "DRIVER",
                driverId, "approval=" + oldStatus, "approval=" + newStatus.name());
    }

    public void updateDriverStatus(String id, String status) {
        UUID driverId = UUID.fromString(id);
        DriverProfile driver = driverProfileRepository.findById(driverId)
            .orElseThrow(() -> new RuntimeException("Driver not found"));
        driver.setDriverStatus(DriverProfile.DriverStatus.valueOf(status.toUpperCase()));
        driverProfileRepository.save(driver);
        cacheService.invalidateDrivers();
    }

    private UUID currentUserIdOrNull() {
        var auth = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }

    private <T> PagedResponse<T> toPagedResponse(Page<T> page) {
        PageMeta meta = new PageMeta(
            page.getNumber(),
            page.getSize(),
            page.getTotalElements(),
            page.getTotalPages()
        );
        return PagedResponse.<T>builder()
            .success(true)
            .data(page.getContent())
            .meta(meta)
            .timestamp(Instant.now().toString())
            .build();
    }
}
