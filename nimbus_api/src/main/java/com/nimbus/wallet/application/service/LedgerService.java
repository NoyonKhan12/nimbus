package com.nimbus.wallet.application.service;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
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
    private final DriverProfileRepository driverProfileRepository;

    /**
     * Post a passenger payment to the ledger.
     * Creates double-entry: debit passenger wallet, credit platform revenue.
     */
    @Transactional
    public void postPassengerPayment(Booking booking, BigDecimal amount, UUID paymentId,
                                     Payment.PaymentMethod method) {
        // Ensure wallet exists
        Wallet wallet = getOrCreateWallet(booking.getPassenger(), Wallet.OwnerType.PASSENGER);

        // Wallet balances are a hard floor: never let a payment succeed and
        // push the passenger into debt (guide §13).
        if (method == Payment.PaymentMethod.WALLET
                && wallet.getBalance().compareTo(amount) < 0) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.WALLET_INSUFFICIENT_BALANCE,
                    org.springframework.http.HttpStatus.CONFLICT);
        }

        LedgerAccount mainAccount = getOrCreateAccount(wallet, LedgerAccount.AccountType.MAIN);

        // Immutable ledger record of the collected fare.
        createEntry(mainAccount, LedgerEntry.EntryType.PASSENGER_PAYMENT, amount,
                "PAYMENT", paymentId, "Passenger payment for booking: " + booking.getId());

        // Balance handling depends on the funding source:
        //  - WALLET: the passenger pays from their balance → DEBIT it.
        //  - bkash/nagad/cash: money moves outside the wallet (gateway/driver)
        //    → the ledger records it, but the wallet balance must NOT change.
        if (method == Payment.PaymentMethod.WALLET) {
            wallet.adjustBalance(amount.negate());
            walletRepository.save(wallet);
        }

        log.info("Posted passenger payment: {} booking: {} method: {}",
                amount, booking.getId(), method);
    }

    /**
     * Refunds a cancelled booking: credits the passenger's wallet as app
     * credit and records the immutable REFUND entry.
     */
    @Transactional
    public void postRefund(Booking booking, BigDecimal amount, UUID paymentId) {
        Wallet wallet = getOrCreateWallet(booking.getPassenger(), Wallet.OwnerType.PASSENGER);
        LedgerAccount mainAccount = getOrCreateAccount(wallet, LedgerAccount.AccountType.MAIN);

        createEntry(mainAccount, LedgerEntry.EntryType.PASSENGER_REFUND, amount,
                "PAYMENT", paymentId, "Refund for cancelled booking: " + booking.getId());

        wallet.adjustBalance(amount);
        walletRepository.save(wallet);
        log.info("Posted refund: {} booking: {}", amount, booking.getId());
    }

    /**
     * Records a cancellation fee for a booking cancelled mid-trip. The fee
     * is a ledger charge only — it is collected via the normal settlement.
     */
    @Transactional
    public void postCancellationFee(Booking booking, BigDecimal amount) {
        Wallet wallet = getOrCreateWallet(booking.getPassenger(), Wallet.OwnerType.PASSENGER);
        LedgerAccount mainAccount = getOrCreateAccount(wallet, LedgerAccount.AccountType.MAIN);

        createEntry(mainAccount, LedgerEntry.EntryType.CANCELLATION_FEE, amount,
                "BOOKING", booking.getId(), "Cancellation fee for booking: " + booking.getId());
        log.info("Posted cancellation fee: {} booking: {}", amount, booking.getId());
    }

    /**
     * Post driver earnings when a ride completes.
     */
    @Transactional
    public void postDriverEarnings(UUID driverId, UUID rideId,
                                   BigDecimal grossEarnings,
                                   BigDecimal commission,
                                   UUID bookingId) {
        DriverProfile driver = driverProfileRepository.findById(driverId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Driver profile not found: " + driverId));
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
     * Process a settlement payment to a driver. The payout is an external
     * transfer, so the driver's wallet must be debited by the same amount
     * that was credited at ride completion. Without the debit the driver
     * could spend the earnings in-app and still receive the bank payout.
     */
    @Transactional
    public void processDriverSettlement(UUID driverId, BigDecimal amount, UUID settlementId) {
        if (amount == null || amount.signum() <= 0) return;

        DriverProfile driver = driverProfileRepository.findById(driverId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Driver profile not found: " + driverId));
        Wallet wallet = getOrCreateWallet(driver.getUser(), Wallet.OwnerType.DRIVER);

        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.WALLET_INSUFFICIENT_BALANCE,
                    "Driver wallet balance is lower than the settlement payout",
                    org.springframework.http.HttpStatus.CONFLICT);
        }

        LedgerAccount mainAccount = getOrCreateAccount(wallet, LedgerAccount.AccountType.MAIN);

        createEntry(mainAccount, LedgerEntry.EntryType.DRIVER_SETTLEMENT, amount,
                "SETTLEMENT", settlementId, "Settlement payout");

        wallet.adjustBalance(amount.negate());
        walletRepository.save(wallet);

        log.info("Processed driver settlement: {} settlement: {} driver: {}",
                amount, settlementId, driverId);
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
