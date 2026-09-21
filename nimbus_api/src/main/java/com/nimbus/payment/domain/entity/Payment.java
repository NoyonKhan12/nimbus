package com.nimbus.payment.domain.entity;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Payment entity representing a payment for a booking.
 *
 * <p>Payment lifecycle: PENDING → SUCCESS / FAILED / REFUNDED
 * Uses idempotency keys to prevent duplicate processing.
 * Backend verifies all payment callbacks independently.</p>
 */
@Entity
@Table(name = "payments", indexes = {
    @Index(name = "idx_payments_booking_id", columnList = "booking_id"),
    @Index(name = "idx_payments_payer_id", columnList = "payer_id"),
    @Index(name = "idx_payments_status", columnList = "status"),
    @Index(name = "idx_payments_idempotency_key", columnList = "idempotency_key")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Payment {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false, foreignKey = @ForeignKey(name = "fk_payment_booking"))
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payer_id", nullable = false, foreignKey = @ForeignKey(name = "fk_payment_payer"))
    private User payer;

    @Column(name = "amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(name = "method", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private PaymentMethod method;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private PaymentStatus status = PaymentStatus.PENDING;

    @Column(name = "provider_reference", length = 255)
    private String providerReference;

    @Column(name = "idempotency_key", length = 255, unique = true)
    private String idempotencyKey;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @OneToMany(mappedBy = "payment", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<PaymentTransaction> transactions = new ArrayList<>();

    public enum PaymentMethod {
        BKASH,            // bKash mobile money
        NAGAD,            // Nagad mobile money
        ROCKET,           // Rocket mobile money
        CARD,             // Credit/debit card
        WALLET,           // Nimbus wallet
        CASH,             // Cash on delivery
        BANK_TRANSFER     // Bank transfer
    }

    public enum PaymentStatus {
        PENDING,       // Initial state
        SUCCESS,       // Payment completed
        FAILED,        // Payment failed
        REFUNDED,      // Payment refunded
        PARTIALLY_REFUNDED // Partial refund
    }

    /**
     * Check if payment can be refunded.
     */
    public boolean canBeRefunded() {
        return status == PaymentStatus.SUCCESS;
    }

    /**
     * Record a payment status change.
     */
    public void updateStatus(PaymentStatus newStatus) {
        this.status = newStatus;
        this.updatedAt = Instant.now();
    }
}
