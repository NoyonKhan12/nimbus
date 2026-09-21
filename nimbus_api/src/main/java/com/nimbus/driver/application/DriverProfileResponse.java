package com.nimbus.driver.application;

import com.nimbus.driver.domain.entity.DriverProfile;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Driver profile response DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverProfileResponse {
    private UUID id;
    private UUID userId;
    private DriverProfile.DriverStatus driverStatus;
    private DriverProfile.ApprovalStatus approvalStatus;
    private String licenseNumber;
    private Instant licenseExpiry;
    private BigDecimal rating;
    private BigDecimal reliabilityScore;
    private Integer totalRides;
    private BigDecimal totalEarnings;
    private BigDecimal commissionRate;
    private Instant createdAt;
    private Instant updatedAt;
}
