package com.nimbus.wallet.application;

import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Wallet balance response.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletResponse {
    private UUID id;
    private UUID ownerId;
    private String ownerType;
    private BigDecimal balance;
    private String currency;
    private Instant createdAt;
    private Instant updatedAt;
}
