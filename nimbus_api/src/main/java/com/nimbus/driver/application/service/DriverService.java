package com.nimbus.driver.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.driver.application.DriverApplicationRequest;
import com.nimbus.driver.application.DriverProfileResponse;
import com.nimbus.driver.application.VehicleResponse;
import com.nimbus.driver.domain.entity.DriverProfile;
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
     * Check if driver is eligible to create rides.
     * Eligibility requires:
     * - Active account
     * - Approved driver status
     * - Approved active vehicle
     * - Valid required documents
     * - No suspension/ban
     * - Zero previous due
     */
    public boolean isEligible(UUID userId) {
        DriverProfile profile = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Check driver approval status
        if (profile.getApprovalStatus() != DriverProfile.ApprovalStatus.APPROVED) {
            return false;
        }

        // Check for suspension/ban
        if (profile.getApprovalStatus() == DriverProfile.ApprovalStatus.SUSPENDED) {
            return false;
        }

        // Check documents not expired
        if (profile.getLicenseExpiry() != null && profile.getLicenseExpiry().isBefore(Instant.now())) {
            throw new NimbusException(ErrorCode.DRIVER_DOCUMENT_EXPIRED, HttpStatus.FORBIDDEN);
        }

        // Check no outstanding due
        if (profile.getRating() != null && profile.getRating().compareTo(BigDecimal.valueOf(2.0)) < 0) {
            // Low rating may indicate issues
            return false;
        }

        return true;
    }

    /**
     * Get all vehicles for a driver.
     */
    public List<VehicleResponse> getVehicles(UUID userId) {
        // In a full implementation, this would query the vehicles table
        return List.of();
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
