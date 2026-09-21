package com.nimbus.admin.domain.projection;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Projection for admin settlement listing - avoids lazy loading of driver.
 */
public record SettlementAdminProjection(
    UUID id,
    UUID driverId,
    Instant periodStart,
    Instant periodEnd,
    BigDecimal grossEarnings,
    BigDecimal commission,
    BigDecimal payable,
    String status,
    Instant createdAt,
    String paymentReference
) {
}
