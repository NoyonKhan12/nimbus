package com.nimbus.settlement.application;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Flat settlement response (guide §16): settlements are returned as DTOs,
 * never as raw entities — the entity graph (driver → user → profile)
 * serializes to hundreds of KB and broke JSON validity.
 */
@Getter
@Builder
public class SettlementResponse {
    private UUID id;
    private UUID driverId;
    private Instant periodStart;
    private Instant periodEnd;
    private BigDecimal grossEarnings;
    private BigDecimal commission;
    private BigDecimal adjustments;
    private BigDecimal refunds;
    private BigDecimal driverCredits;
    private BigDecimal payable;
    private String status;
    private String paymentReference;
    private Instant createdAt;
}
