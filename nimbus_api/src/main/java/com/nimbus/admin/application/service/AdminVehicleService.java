package com.nimbus.admin.application.service;

import com.nimbus.driver.domain.entity.Vehicle;
import com.nimbus.driver.domain.repository.VehicleRepository;
import com.nimbus.kernel.application.dto.PagedResponse;
import com.nimbus.kernel.application.dto.PagedResponse.PageMeta;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.audit.application.service.AuditService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Admin vehicle operations (guide §20): approval, rejection, suspension and
 * document-expiry driven review. Every status change is audited.
 */
@Service
@Slf4j
public class AdminVehicleService {

    private final VehicleRepository vehicleRepository;
    private final AdminCacheService cacheService;
    private final AuditService auditService;

    public AdminVehicleService(VehicleRepository vehicleRepository,
                               AdminCacheService cacheService,
                               AuditService auditService) {
        this.vehicleRepository = vehicleRepository;
        this.cacheService = cacheService;
        this.auditService = auditService;
    }

    /** Vehicle row for admin lists — avoids lazy-loading traps. */
    public record VehicleAdminRow(
            UUID id, UUID driverId, String registrationNumber, String type,
            String model, Integer year, String color, Integer seatCapacity,
            String status) {}

    public PagedResponse<VehicleAdminRow> listVehicles(int page, int size, String status) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Vehicle> vehicles;
        if (status != null && !status.isEmpty()) {
            Vehicle.VehicleStatus vehicleStatus = Vehicle.VehicleStatus.valueOf(status.toUpperCase());
            vehicles = vehicleRepository.findByStatus(vehicleStatus, pageable);
        } else {
            vehicles = vehicleRepository.findAll(pageable);
        }
        Page<VehicleAdminRow> rows = vehicles.map(this::toRow);
        PageMeta meta = new PageMeta(rows.getNumber(), rows.getSize(),
                rows.getTotalElements(), rows.getTotalPages());
        return PagedResponse.<VehicleAdminRow>builder()
                .success(true)
                .data(rows.getContent())
                .meta(meta)
                .timestamp(Instant.now().toString())
                .build();
    }

    public VehicleAdminRow getVehicle(String id) {
        return vehicleRepository.findById(UUID.fromString(id))
                .map(this::toRow)
                .orElseThrow(() -> new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND));
    }

    @Transactional
    public VehicleAdminRow updateVehicleStatus(String id, String status) {
        Vehicle vehicle = vehicleRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND));
        Vehicle.VehicleStatus newStatus = Vehicle.VehicleStatus.valueOf(status.toUpperCase());
        String oldStatus = vehicle.getStatus() != null ? vehicle.getStatus().name() : null;
        vehicle.setStatus(newStatus);
        vehicleRepository.save(vehicle);
        cacheService.invalidateDrivers();
        cacheService.invalidateDashboardStats();

        auditService.logAction(currentUserIdOrNull(), "VEHICLE_STATUS_CHANGED", "VEHICLE",
                vehicle.getId(), "status=" + oldStatus, "status=" + newStatus.name());
        log.info("Vehicle {} status: {} -> {}", vehicle.getId(), oldStatus, newStatus);
        return toRow(vehicle);
    }

    private VehicleAdminRow toRow(Vehicle vehicle) {
        return new VehicleAdminRow(
                vehicle.getId(),
                vehicle.getDriver() != null ? vehicle.getDriver().getId() : null,
                vehicle.getRegistrationNumber(),
                vehicle.getType() != null ? vehicle.getType().name() : null,
                vehicle.getModel(), vehicle.getYear(), vehicle.getColor(),
                vehicle.getSeatCapacity(),
                vehicle.getStatus() != null ? vehicle.getStatus().name() : null);
    }

    private UUID currentUserIdOrNull() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }
}
