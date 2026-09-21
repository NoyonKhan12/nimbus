package com.nimbus.wallet.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Ledger account entity within a wallet.
 *
 * <p>Supports double-entry bookkeeping with multiple account types:
 * MAIN, LIABILITY, REVENUE, EXPENSE for the platform;
 * MAIN for passenger/driver wallets.</p>
 */
@Entity
@Table(name = "ledger_accounts", indexes = {
    @Index(name = "idx_ledger_accounts_wallet_id", columnList = "wallet_id"),
    @Index(name = "idx_ledger_accounts_type", columnList = "account_type")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LedgerAccount {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false, foreignKey = @ForeignKey(name = "fk_account_wallet"))
    private Wallet wallet;

    @Column(name = "account_type", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private AccountType accountType;

    @Column(name = "balance", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal balance = BigDecimal.ZERO;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @OneToMany(mappedBy = "account", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<LedgerEntry> entries = new ArrayList<>();

    public enum AccountType {
        MAIN,           // Primary balance account
        LIABILITY,      // Amounts owed to users
        REVENUE,        // Platform revenue
        EXPENSE,        // Platform expenses
        HOLDING         // Temporarily held funds
    }

    /**
     * Apply a balance change from a ledger entry.
     */
    public void adjustBalance(BigDecimal amount) {
        this.balance = this.balance.add(amount);
        this.updatedAt = Instant.now();
    }
}
