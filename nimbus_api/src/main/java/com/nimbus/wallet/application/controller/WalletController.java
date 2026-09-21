package com.nimbus.wallet.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import com.nimbus.wallet.application.WalletResponse;
import com.nimbus.wallet.application.WalletTransactionResponse;
import com.nimbus.wallet.application.service.LedgerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Wallet balance and transaction endpoints.
 */
@RestController
@RequestMapping("/wallet")
@RequiredArgsConstructor
public class WalletController {

    private final LedgerService ledgerService;

    /**
     * Get wallet balance.
     * GET /wallet
     */
    @GetMapping
    public ResponseEntity<ApiResponse<WalletResponse>> getWallet() {
        UUID userId = getCurrentUserId();
        WalletResponse response = WalletResponse.builder()
                .ownerId(userId)
                .balance(ledgerService.getWalletBalance(userId))
                .currency("BDT")
                .build();
        return ResponseEntity.ok(ApiResponse.<WalletResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Get wallet transaction history.
     * GET /wallet/transactions
     */
    @GetMapping("/transactions")
    public ResponseEntity<ApiResponse<List<WalletTransactionResponse>>> getTransactions() {
        UUID userId = getCurrentUserId();
        List<WalletTransactionResponse> transactions = ledgerService.getLedgerEntries(userId).stream()
                .map(entry -> WalletTransactionResponse.builder()
                        .id(entry.getId())
                        .amount(entry.getAmount())
                        .type(entry.getEntryType().name())
                        .referenceType(entry.getReferenceType())
                        .referenceId(entry.getReferenceId())
                        .description(entry.getDescription())
                        .createdAt(entry.getCreatedAt())
                        .build())
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.<List<WalletTransactionResponse>>builder()
                .success(true)
                .data(transactions)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
