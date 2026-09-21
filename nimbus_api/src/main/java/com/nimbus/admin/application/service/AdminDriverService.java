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

    public AdminDriverService(DriverProfileRepository driverProfileRepository, AdminCacheService cacheService) {
        this.driverProfileRepository = driverProfileRepository;
        this.cacheService = cacheService;
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
        driver.setApprovalStatus(DriverProfile.ApprovalStatus.APPROVED);
        driverProfileRepository.save(driver);
        cacheService.invalidateDrivers();
        cacheService.invalidateDashboardStats();
    }

    public void rejectDriver(String id) {
        UUID driverId = UUID.fromString(id);
        DriverProfile driver = driverProfileRepository.findById(driverId)
            .orElseThrow(() -> new RuntimeException("Driver not found"));
        driver.setApprovalStatus(DriverProfile.ApprovalStatus.REJECTED);
        driverProfileRepository.save(driver);
        cacheService.invalidateDrivers();
    }

    public void updateDriverStatus(String id, String status) {
        UUID driverId = UUID.fromString(id);
        DriverProfile driver = driverProfileRepository.findById(driverId)
            .orElseThrow(() -> new RuntimeException("Driver not found"));
        driver.setDriverStatus(DriverProfile.DriverStatus.valueOf(status.toUpperCase()));
        driverProfileRepository.save(driver);
        cacheService.invalidateDrivers();
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
