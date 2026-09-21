package com.nimbus.wallet.application;

import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Wallet transaction response.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletTransactionResponse {
    private UUID id;
    private UUID accountId;
    private String type;
    private BigDecimal amount;
    private String referenceType;
    private UUID referenceId;
    private String description;
    private Instant createdAt;
}
