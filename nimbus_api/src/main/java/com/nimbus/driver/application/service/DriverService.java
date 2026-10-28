package com.nimbus.driver.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.driver.application.DriverApplicationRequest;
import com.nimbus.driver.application.DriverEarningsResponse;
import com.nimbus.driver.application.DriverProfileResponse;
import com.nimbus.driver.application.VehicleResponse;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.entity.Vehicle;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.driver.domain.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Driver onboarding and management service.
 */
@Service
@RequiredArgsConstructor
public class DriverService {

    private final UserRepository userRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final VehicleRepository vehicleRepository;
    private final DriverEligibilityService driverEligibilityService;

    /**
     * Apply as a driver - creates driver profile and vehicle.
     */
    @Transactional
    public DriverProfileResponse applyAsDriver(UUID userId, DriverApplicationRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (driverProfileRepository.existsByUserId(userId)) {
            throw new NimbusException(ErrorCode.CONFLICT,
                    "Driver profile already exists", HttpStatus.CONFLICT);
        }

        // Create driver profile
        DriverProfile profile = DriverProfile.builder()
                .user(user)
                .driverStatus(DriverProfile.DriverStatus.OFFLINE)
                .approvalStatus(DriverProfile.ApprovalStatus.PENDING)
                .licenseNumber(request.getLicenseNumber())
                .licenseExpiry(request.getLicenseExpiry())
                .rating(BigDecimal.ZERO)
                .reliabilityScore(BigDecimal.ONE)
                .commissionRate(BigDecimal.valueOf(10.00))
                .totalRides(0)
                .totalEarnings(BigDecimal.ZERO)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        driverProfileRepository.save(profile);

        return toDriverProfileResponse(profile);
    }

    /**
     * Get driver profile for a user.
     */
    @Transactional(readOnly = true)
    public DriverProfileResponse getDriverProfile(UUID userId) {
        DriverProfile profile = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));
        return toDriverProfileResponse(profile);
    }

    /**
     * Check if driver is eligible to create rides. Delegates to the
     * unified eligibility service (guide §5) so the rules can never
     * diverge from the ride-create/publish/matching paths.
     */
    @Transactional(readOnly = true)
    public boolean isEligible(UUID userId) {
        return driverEligibilityService.isEligible(userId);
    }

    /**
     * Get all vehicles for a driver.
     */
    /**
     * Earnings summary for the driver app's earnings screen.
     */
    @Transactional(readOnly = true)
    public DriverEarningsResponse getEarnings(UUID userId) {
        DriverProfile profile = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        return DriverEarningsResponse.builder()
                .totalEarnings(profile.getTotalEarnings())
                .totalRides(profile.getTotalRides())
                .rating(profile.getRating())
                .reliabilityScore(profile.getReliabilityScore())
                .commissionRate(profile.getCommissionRate())
                .currency("BDT")
                .build();
    }

    /**
     * Toggles the driver's online/offline availability.
     */
    @Transactional
    public DriverProfileResponse updateStatus(UUID userId, String driverStatus) {
        DriverProfile profile = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));
        profile.setDriverStatus(DriverProfile.DriverStatus.valueOf(driverStatus.toUpperCase()));
        driverProfileRepository.save(profile);
        return toDriverProfileResponse(profile);
    }

    /**
     * Registers an additional vehicle for the driver (starts PENDING —
     * operations approves it like any other vehicle).
     */
    @Transactional
    public VehicleResponse createVehicle(UUID userId, String registrationNumber, String type,
                                         String model, Integer year, String color, Integer seatCapacity) {
        DriverProfile profile = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        Vehicle vehicle = Vehicle.builder()
                .driver(profile)
                .registrationNumber(registrationNumber)
                .type(Vehicle.VehicleType.valueOf(type.toUpperCase()))
                .model(model)
                .year(year)
                .color(color)
                .seatCapacity(seatCapacity)
                .status(Vehicle.VehicleStatus.PENDING)
                .build();
        vehicle = vehicleRepository.save(vehicle);
        return toVehicleResponse(vehicle);
    }

    public List<VehicleResponse> getVehicles(UUID userId) {
        DriverProfile profile = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        return vehicleRepository.findByDriverId(profile.getId()).stream()
                .map(this::toVehicleResponse)
                .collect(Collectors.toList());
    }

    /**
     * Vehicle details with ownership enforcement (guide §15).
     */
    @Transactional(readOnly = true)
    public VehicleResponse getVehicle(UUID userId, UUID vehicleId) {
        Vehicle vehicle = ownedVehicle(userId, vehicleId);
        return toVehicleResponse(vehicle);
    }

    /**
     * Update one of the driver's own vehicles (guide §15 PUT
     * /vehicles/{vehicleId}). Registration number and type are immutable —
     * those changes go through operations with new documents.
     */
    @Transactional
    public VehicleResponse updateVehicle(UUID userId, UUID vehicleId,
                                         String model, Integer year, String color,
                                         Integer seatCapacity) {
        Vehicle vehicle = ownedVehicle(userId, vehicleId);
        if (model != null) vehicle.setModel(model);
        if (year != null) vehicle.setYear(year);
        if (color != null) vehicle.setColor(color);
        if (seatCapacity != null && seatCapacity > 0) vehicle.setSeatCapacity(seatCapacity);
        return toVehicleResponse(vehicleRepository.save(vehicle));
    }

    private Vehicle ownedVehicle(UUID userId, UUID vehicleId) {
        DriverProfile profile = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));
        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND));
        if (vehicle.getDriver() == null || !vehicle.getDriver().getId().equals(profile.getId())) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        return vehicle;
    }

    private VehicleResponse toVehicleResponse(Vehicle vehicle) {
        return VehicleResponse.builder()
                .id(vehicle.getId())
                .driverId(vehicle.getDriver() != null ? vehicle.getDriver().getId() : null)
                .registrationNumber(vehicle.getRegistrationNumber())
                .type(vehicle.getType() != null ? vehicle.getType().name() : null)
                .model(vehicle.getModel())
                .year(vehicle.getYear())
                .color(vehicle.getColor())
                .seatCapacity(vehicle.getSeatCapacity())
                .status(vehicle.getStatus() != null ? vehicle.getStatus().name() : null)
                .build();
    }

    private DriverProfileResponse toDriverProfileResponse(DriverProfile profile) {
        return DriverProfileResponse.builder()
                .id(profile.getId())
                .userId(profile.getUser().getId())
                .driverStatus(profile.getDriverStatus())
                .approvalStatus(profile.getApprovalStatus())
                .licenseNumber(profile.getLicenseNumber())
                .licenseExpiry(profile.getLicenseExpiry())
                .rating(profile.getRating())
                .reliabilityScore(profile.getReliabilityScore())
                .totalRides(profile.getTotalRides())
                .totalEarnings(profile.getTotalEarnings())
                .commissionRate(profile.getCommissionRate())
                .createdAt(profile.getCreatedAt())
                .updatedAt(profile.getUpdatedAt())
                .build();
    }
}
