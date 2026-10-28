package com.nimbus.payment.application;

import com.nimbus.payment.domain.entity.Payment;
import com.nimbus.payment.domain.repository.PaymentRepository;
import com.nimbus.wallet.domain.repository.LedgerEntryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;

/**
 * Payment reconciliation job (guide §25): every successful payment must
 * have a corresponding immutable ledger entry. Mismatches are alerted for
 * manual reconciliation — financial records are never silently mutated.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class PaymentReconciliationScheduler {

    private final PaymentRepository paymentRepository;
    private final LedgerEntryRepository ledgerEntryRepository;

    @Scheduled(fixedDelay = 600_000)
    public void reconcilePayments() {
        List<Payment> successful = paymentRepository.findByStatus(Payment.PaymentStatus.SUCCESS);
        int mismatches = 0;
        for (Payment payment : successful) {
            if (payment.getCreatedAt() != null
                    && payment.getCreatedAt().isBefore(Instant.now().minus(java.time.Duration.ofHours(24)))) {
                continue; // reconcile the last 24 h only
            }
            boolean posted = !ledgerEntryRepository
                    .findByReferenceTypeAndReferenceId("PAYMENT", payment.getId())
                    .isEmpty();
            if (!posted) {
                mismatches++;
                log.warn("RECONCILIATION: successful payment {} (booking {}, ৳{}) has no ledger entry",
                        payment.getId(), payment.getBooking().getId(), payment.getAmount());
            }
        }
        if (mismatches > 0) {
            log.warn("RECONCILIATION: {} successful payments missing ledger entries", mismatches);
        }
    }
}
