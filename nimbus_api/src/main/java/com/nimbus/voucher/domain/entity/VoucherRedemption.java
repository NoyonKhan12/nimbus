package com.nimbus.voucher.domain.entity;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Records voucher redemption for audit and usage tracking.
 */
@Entity
@Table(name = "voucher_redemptions", indexes = {
    @Index(name = "idx_voucher_redemptions_voucher_id", columnList = "voucher_id"),
    @Index(name = "idx_voucher_redemptions_user_id", columnList = "user_id"),
    @Index(name = "idx_voucher_redemptions_booking_id", columnList = "booking_id")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VoucherRedemption {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "voucher_id", nullable = false, foreignKey = @ForeignKey(name = "fk_redemption_voucher"))
    private Voucher voucher;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", foreignKey = @ForeignKey(name = "fk_redemption_user"))
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", foreignKey = @ForeignKey(name = "fk_redemption_booking"))
    private Booking booking;

    @Column(name = "discount_amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal discountAmount;

    @Column(name = "fare_amount", precision = 18, scale = 2)
    private BigDecimal fareAmount;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RedemptionStatus status = RedemptionStatus.REDEEMED;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    public enum RedemptionStatus {
        REDEEMED,   // Successfully applied
        FAILED,     // Failed to apply
        REVERSED    // Reversed (e.g., booking cancelled)
    }
}
