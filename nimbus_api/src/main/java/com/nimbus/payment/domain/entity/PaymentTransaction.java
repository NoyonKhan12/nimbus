package com.nimbus.payment.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Immutable payment transaction log for audit and reconciliation.
 *
 * <p>Every event from payment providers is recorded here.
 * Used for reconciliation and handling duplicate webhooks.</p>
 */
@Entity
@Table(name = "payment_transactions", indexes = {
    @Index(name = "idx_payment_transactions_payment_id", columnList = "payment_id"),
    @Index(name = "idx_payment_transactions_provider_status", columnList = "provider_status")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentTransaction {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_id", nullable = false, foreignKey = @ForeignKey(name = "fk_txn_payment"))
    private Payment payment;

    @Column(name = "provider", nullable = false, length = 50)
    private String provider;

    @Column(name = "provider_status", length = 50)
    private String providerStatus;

    @Column(name = "amount", precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(name = "raw_response", columnDefinition = "text")
    private String rawResponse;

    /**
     * Provider's own event/callback reference — unique per provider for
     * webhook dedupe (guide §12: duplicate callbacks are harmless).
     */
    @Column(name = "provider_event_ref", length = 255)
    private String providerEventRef;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();
}
