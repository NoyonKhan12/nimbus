package com.nimbus.driver.application;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Driver earnings summary built from the driver profile.
 */
@Getter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverEarningsResponse {
    private BigDecimal totalEarnings;
    private Integer totalRides;
    private BigDecimal rating;
    private BigDecimal reliabilityScore;
    private BigDecimal commissionRate;
    private String currency;
}
