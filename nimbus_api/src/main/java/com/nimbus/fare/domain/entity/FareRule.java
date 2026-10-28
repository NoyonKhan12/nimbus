package com.nimbus.fare.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Versioned fare rule (rate card).
 *
 * <p>Each active rule version is the single source of fare parameters for
 * quotes created while it is active. Quotes persist the rule version so any
 * historical fare can be reproduced without recalculating at today's rates
 * (guide §11).</p>
 */
@Entity
@Table(name = "fare_rules", indexes = {
    @Index(name = "idx_fare_rules_active", columnList = "is_active, effective_from")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FareRule {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "version", nullable = false, unique = true, length = 50)
    private String version;

    @Column(name = "base_fare", nullable = false, precision = 18, scale = 2)
    private BigDecimal baseFare;

    @Column(name = "per_km_rate", nullable = false, precision = 18, scale = 2)
    private BigDecimal perKmRate;

    @Column(name = "per_minute_rate", nullable = false, precision = 18, scale = 2)
    private BigDecimal perMinuteRate;

    @Column(name = "service_fee", nullable = false, precision = 18, scale = 2)
    private BigDecimal serviceFee;

    @Column(name = "minimum_fare", nullable = false, precision = 18, scale = 2)
    private BigDecimal minimumFare;

    @Column(name = "tax_rate_percent", nullable = false, precision = 5, scale = 2)
    @Builder.Default
    private BigDecimal taxRatePercent = BigDecimal.ZERO;

    /** Platform commission percentage taken from driver gross earnings. */
    @Column(name = "commission_percent", nullable = false, precision = 5, scale = 2)
    @Builder.Default
    private BigDecimal commissionPercent = BigDecimal.valueOf(20);

    @Column(name = "currency", nullable = false, length = 10)
    @Builder.Default
    private String currency = "BDT";

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private boolean active = true;

    @Column(name = "effective_from", nullable = false)
    @Builder.Default
    private Instant effectiveFrom = Instant.now();

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();
}
