package com.nimbus.admin.domain.projection;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Projection for admin payment listing - avoids lazy loading of booking/payer.
 */
public record PaymentAdminProjection(
    UUID id,
    UUID bookingId,
    UUID userId,
    BigDecimal amount,
    String paymentMethod,
    String status,
    String providerReference,
    String idempotencyKey,
    Instant createdAt,
    Instant updatedAt
) {
}
