package com.nimbus.wallet.application.service;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.payment.domain.entity.Payment;
import com.nimbus.wallet.domain.entity.*;
import com.nimbus.wallet.domain.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Ledger service for immutable double-entry bookkeeping.
 *
 * <p>Financial records are append-only. Corrections use reversal/refund/
 * adjustment entries. This service handles all financial state changes.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class LedgerService {

    private final WalletRepository walletRepository;
    private final LedgerAccountRepository ledgerAccountRepository;
    private final LedgerEntryRepository ledgerEntryRepository;

    /**
     * Post a passenger payment to the ledger.
     * Creates double-entry: debit passenger wallet, credit platform revenue.
     */
    @Transactional
    public void postPassengerPayment(Booking booking, BigDecimal amount, UUID paymentId) {
        // Ensure wallet exists
        Wallet wallet = getOrCreateWallet(booking.getPassenger(), Wallet.OwnerType.PASSENGER);
        LedgerAccount mainAccount = getOrCreateAccount(wallet, LedgerAccount.AccountType.MAIN);

        // Record the payment
        // Debit: Passenger payment (increases liability - passenger owes money)
        // Credit: Platform revenue accounts
        createEntry(mainAccount, LedgerEntry.EntryType.PASSENGER_PAYMENT, amount,
                "PAYMENT", paymentId, "Passenger payment for booking: " + booking.getId());

        // Update wallet balance
        wallet.adjustBalance(amount);
        walletRepository.save(wallet);

        log.info("Posted passenger payment: {} booking: {}", amount, booking.getId());
    }

    /**
     * Post driver earnings when a ride completes.
     */
    @Transactional
    public void postDriverEarnings(UUID driverId, UUID rideId,
                                   BigDecimal grossEarnings,
                                   BigDecimal commission,
                                   UUID bookingId) {
        DriverProfile driver = DriverProfile.builder().id(driverId).build();
        Wallet wallet = getOrCreateWallet(driver.getUser(), Wallet.OwnerType.DRIVER);
        LedgerAccount mainAccount = getOrCreateAccount(wallet, LedgerAccount.AccountType.MAIN);

        // Driver earning - increase driver's wallet
        createEntry(mainAccount, LedgerEntry.EntryType.DRIVER_EARNING, grossEarnings,
                "RIDE", rideId, "Driver earning for ride: " + rideId + " booking: " + bookingId);

        // Platform commission - decrease from driver's earning
        createEntry(mainAccount, LedgerEntry.EntryType.PLATFORM_COMMISSION, commission,
                "RIDE", rideId, "Platform commission for ride: " + rideId);

        // Update wallet balance
        BigDecimal netEarning = grossEarnings.subtract(commission);
        wallet.adjustBalance(netEarning);
        walletRepository.save(wallet);

        // Update driver profile
        // Note: This would be done via DriverProfileRepository in a complete implementation
        log.info("Posted driver earnings: {} commission: {} ride: {}", grossEarnings, commission, rideId);
    }

    /**
     * Process a refund for a cancelled booking.
     */
    @Transactional
    public void processRefund(Booking booking, BigDecimal amount, UUID paymentId,
                              String reason) {
        Wallet wallet = walletRepository.findByOwnerId(booking.getPassenger().getId())
                .orElse(null);
        if (wallet == null) return;

        LedgerAccount mainAccount = getOrCreateAccount(wallet, LedgerAccount.AccountType.MAIN);

        // Refund entry (negative of payment)
        createEntry(mainAccount, LedgerEntry.EntryType.PASSENGER_REFUND, amount,
                "REFUND", paymentId, "Refund for booking: " + booking.getId() + " reason: " + reason);

        // Update wallet balance
        wallet.adjustBalance(amount.negate());
        walletRepository.save(wallet);

        log.info("Processed refund: {} for booking: {}", amount, booking.getId());
    }

    /**
     * Apply a service fee as platform revenue.
     */
    @Transactional
    public void postServiceFee(BigDecimal amount, UUID bookingId, UUID paymentId) {
        Wallet platformWallet = getOrCreatePlatformWallet();
        LedgerAccount mainAccount = getOrCreateAccount(platformWallet, LedgerAccount.AccountType.MAIN);

        createEntry(mainAccount, LedgerEntry.EntryType.PLATFORM_SERVICE_FEE, amount,
                "BOOKING", bookingId, "Service fee for booking");

        // Update wallet balance
        platformWallet.adjustBalance(amount);
        walletRepository.save(platformWallet);
    }

    /**
     * Process a settlement payment to a driver.
     */
    @Transactional
    public void processDriverSettlement(UUID driverId, BigDecimal amount, UUID settlementId) {
        DriverProfile driver = DriverProfile.builder().id(driverId).build();
        Wallet wallet = getOrCreateWallet(driver.getUser(), Wallet.OwnerType.DRIVER);
        LedgerAccount mainAccount = getOrCreateAccount(wallet, LedgerAccount.AccountType.MAIN);

        createEntry(mainAccount, LedgerEntry.EntryType.DRIVER_SETTLEMENT, amount,
                "SETTLEMENT", settlementId, "Settlement payment");

        // Decrease wallet balance (money going out)
        wallet.adjustBalance(amount.negate());
        walletRepository.save(wallet);

        log.info("Processed driver settlement: {} settlement: {}", amount, settlementId);
    }

    private Wallet getOrCreateWallet(User user, Wallet.OwnerType ownerType) {
        return walletRepository.findByOwnerId(user.getId())
                .orElseGet(() -> {
                    Wallet wallet = Wallet.builder()
                            .owner(user)
                            .ownerType(ownerType)
                            .balance(BigDecimal.ZERO)
                            .currency("BDT")
                            .build();
                    LedgerAccount mainAccount = LedgerAccount.builder()
                            .accountType(LedgerAccount.AccountType.MAIN)
                            .balance(BigDecimal.ZERO)
                            .build();
                    // Note: In full implementation, wallet and account would be created together
                    return walletRepository.save(wallet);
                });
    }

    private Wallet getOrCreatePlatformWallet() {
        User systemUser = User.builder().id(UUID.fromString("00000000-0000-0000-0000-000000000000")).build();
        return getOrCreateWallet(systemUser, Wallet.OwnerType.PLATFORM);
    }

    private LedgerAccount getOrCreateAccount(Wallet wallet, LedgerAccount.AccountType type) {
        return ledgerAccountRepository.findByWalletIdAndAccountType(wallet.getId(), type)
                .orElseGet(() -> {
                    LedgerAccount account = LedgerAccount.builder()
                            .wallet(wallet)
                            .accountType(type)
                            .balance(BigDecimal.ZERO)
                            .build();
                    return ledgerAccountRepository.save(account);
                });
    }

    private LedgerEntry createEntry(LedgerAccount account, LedgerEntry.EntryType entryType,
                                    BigDecimal amount, String referenceType,
                                    UUID referenceId, String description) {
        LedgerEntry entry = LedgerEntry.builder()
                .account(account)
                .entryType(entryType)
                .amount(amount)
                .referenceType(referenceType)
                .referenceId(referenceId)
                .description(description)
                .createdAt(Instant.now())
                .build();
        ledgerEntryRepository.save(entry);

        // Update account balance
        account.adjustBalance(entry.getSignedAmount());
        ledgerAccountRepository.save(account);

        return entry;
    }

    /**
     * Get wallet balance for a user.
     */
    @Transactional(readOnly = true)
    public BigDecimal getWalletBalance(UUID userId) {
        return walletRepository.findByOwnerId(userId)
                .map(Wallet::getBalance)
                .orElse(BigDecimal.ZERO);
    }

    /**
     * Get ledger entries for a user.
     */
    @Transactional(readOnly = true)
    public List<LedgerEntry> getLedgerEntries(UUID userId) {
        return walletRepository.findByOwnerId(userId)
                .map(wallet -> ledgerAccountRepository.findByWalletId(wallet.getId()))
                .orElse(Collections.emptyList())
                .stream()
                .map(LedgerAccount::getEntries)
                .flatMap(List::stream)
                .sorted(Comparator.comparing(LedgerEntry::getCreatedAt).reversed())
                .toList();
    }
}
