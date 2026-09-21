package com.nimbus.voucher.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Voucher entity for discounts and promotions.
 *
 * <p>Supports percentage and fixed discounts with usage limits,
 * per-user limits, and validity periods.</p>
 */
@Entity
@Table(name = "vouchers", indexes = {
    @Index(name = "idx_vouchers_code", columnList = "code"),
    @Index(name = "idx_vouchers_validity", columnList = "valid_from, valid_to, is_active")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Voucher {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "code", nullable = false, unique = true, length = 50)
    private String code;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "discount_type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private DiscountType discountType;

    @Column(name = "discount_value", nullable = false, precision = 18, scale = 2)
    private BigDecimal discountValue;

    @Column(name = "min_fare", precision = 18, scale = 2)
    private BigDecimal minFare;

    @Column(name = "max_discount", precision = 18, scale = 2)
    private BigDecimal maxDiscount;

    @Column(name = "usage_limit")
    private Integer usageLimit;

    @Column(name = "per_user_limit", nullable = false)
    @Builder.Default
    private Integer perUserLimit = 1;

    @Column(name = "valid_from", nullable = false)
    private Instant validFrom;

    @Column(name = "valid_to", nullable = false)
    private Instant validTo;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private boolean active = true;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @OneToMany(mappedBy = "voucher", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<VoucherRedemption> redemptions = new ArrayList<>();

    public enum DiscountType {
        PERCENTAGE,  // Percentage of fare
        FIXED        // Fixed amount off
    }

    /**
     * Check if voucher is valid at the current time.
     */
    public boolean isValidAt(Instant now) {
        return active &&
               validFrom.isBefore(now) &&
               validTo.isAfter(now);
    }

    /**
     * Calculate discount amount for a given fare.
     */
    public BigDecimal calculateDiscount(BigDecimal fare) {
        if (minFare != null && fare.compareTo(minFare) < 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal discount;
        if (discountType == DiscountType.PERCENTAGE) {
            discount = fare.multiply(discountValue).divide(BigDecimal.valueOf(100));
        } else {
            discount = discountValue;
        }

        if (maxDiscount != null && discount.compareTo(maxDiscount) > 0) {
            discount = maxDiscount;
        }

        return discount.min(fare); // Can't discount more than the fare
    }

    /**
     * Count redemptions for a user.
     */
    public long countUserRedemptions(UUID userId) {
        return redemptions.stream()
                .filter(r -> userId.equals(r.getUser() != null ? r.getUser().getId() : null))
                .count();
    }

    /**
     * Check if user has reached their redemption limit.
     */
    public boolean isUserLimitReached(UUID userId) {
        return countUserRedemptions(userId) >= perUserLimit;
    }
}
