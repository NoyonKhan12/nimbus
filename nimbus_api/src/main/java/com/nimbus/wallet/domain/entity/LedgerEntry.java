package com.nimbus.wallet.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Immutable ledger entry for double-entry bookkeeping.
 *
 * <p>Financial history is append-only. Corrections use reversal or adjustment
 * entries, never updates to existing entries.</p>
 */
@Entity
@Table(name = "ledger_entries", indexes = {
    @Index(name = "idx_ledger_entries_account_id", columnList = "account_id"),
    @Index(name = "idx_ledger_entries_reference", columnList = "reference_type, reference_id"),
    @Index(name = "idx_ledger_entries_created_at", columnList = "created_at")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LedgerEntry {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id", nullable = false, foreignKey = @ForeignKey(name = "fk_ledger_account"))
    private LedgerAccount account;

    @Column(name = "entry_type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private EntryType entryType;

    @Column(name = "amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(name = "reference_type", length = 50)
    private String referenceType;

    @Column(name = "reference_id")
    private UUID referenceId;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    /**
     * Ledger entry types following double-entry principles.
     * Each entry type is either a DEBIT (increases assets/liabilities/revenue)
     * or CREDIT (decreases them, or increases expenses).
     */
    public enum EntryType {
        // Passenger-side entries
        PASSENGER_PAYMENT,       // DEBIT: Amount collected/owed by passenger
        PASSENGER_REFUND,        // CREDIT: Passenger refund (negative payment)

        // Driver-side entries
        DRIVER_EARNING,          // CREDIT: Driver gross earning
        DRIVER_SETTLEMENT,       // DEBIT: Settlement paid to driver
        DRIVER_CREDIT,           // DEBIT: Platform-funded driver credit

        // Platform entries
        PLATFORM_COMMISSION,     // DEBIT: Commission earned
        PLATFORM_SERVICE_FEE,    // DEBIT: Service fee revenue
        PLATFORM_SUBSIDY,        // CREDIT: Platform-funded adjustment (discount)
        PLATFORM_REVERSAL,       // Reversal of previous entry

        // Voucher
        VOUCHER_DISCOUNT,        // CREDIT: Voucher-funded discount

        // General
        MANUAL_ADJUSTMENT,       // Controlled finance correction
        CHARGEBACK,              // CREDIT: Payment dispute/reversal
        CANCELLATION_FEE         // DEBIT: Cancellation charge
    }

    /**
     * Determine if this entry type is a debit (increases balance).
     */
    public boolean isDebit() {
        return switch (entryType) {
            case PASSENGER_PAYMENT, DRIVER_CREDIT,
                 PLATFORM_COMMISSION, PLATFORM_SERVICE_FEE,
                 VOUCHER_DISCOUNT, CANCELLATION_FEE, MANUAL_ADJUSTMENT -> true;
            default -> false;
        };
    }

    /**
     * Get signed amount (debit = positive, credit = negative).
     */
    public BigDecimal getSignedAmount() {
        return isDebit() ? amount : amount.negate();
    }
}
