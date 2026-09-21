package com.nimbus.wallet.domain.entity;

import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Wallet entity for tracking user balances.
 *
 * <p>Balances are maintained as NUMERIC(18,2) to avoid floating point
 * precision issues. Wallet is a read model updated by ledger entries.</p>
 */
@Entity
@Table(name = "wallets", indexes = {
    @Index(name = "idx_wallets_owner", columnList = "owner_id")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Wallet {

    @Id
    @GeneratedValue
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false, foreignKey = @ForeignKey(name = "fk_wallet_owner"))
    private User owner;

    @Column(name = "owner_type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private OwnerType ownerType;

    @Column(name = "balance", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal balance = BigDecimal.ZERO;

    @Column(name = "currency", nullable = false, length = 10)
    @Builder.Default
    private String currency = "BDT";

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @OneToMany(mappedBy = "wallet", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<LedgerAccount> accounts = new ArrayList<>();

    public enum OwnerType {
        PASSENGER, DRIVER, PLATFORM
    }

    /**
     * Get the main ledger account for this wallet.
     */
    public Optional<LedgerAccount> getMainAccount() {
        return accounts.stream()
                .filter(a -> a.getAccountType() == LedgerAccount.AccountType.MAIN)
                .findFirst();
    }

    /**
     * Apply a balance change to the wallet.
     */
    public void adjustBalance(BigDecimal amount) {
        this.balance = this.balance.add(amount);
        this.updatedAt = Instant.now();
    }
}
