package com.nimbus.payment.application;

import com.nimbus.booking.application.service.BookingService;
import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.payment.application.port.PaymentProvider;
import com.nimbus.payment.application.port.PaymentProviderRegistry;
import com.nimbus.payment.domain.entity.*;
import com.nimbus.payment.domain.repository.*;
import com.nimbus.wallet.domain.entity.*;
import com.nimbus.wallet.domain.repository.*;
import com.nimbus.wallet.application.service.LedgerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Payment service handling payment intents, provider routing,
 * webhook processing, and idempotency.
 *
 * <p>Key principles:
 * - Never trust client-side 'payment successful' flags
 * - Payment callbacks are verified and idempotent
 * - Backend is authoritative for payment state
 * - Financial updates are transactional where possible</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final PaymentTransactionRepository transactionRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final PaymentProviderRegistry providerRegistry;
    private final WalletRepository walletRepository;
    private final LedgerAccountRepository ledgerAccountRepository;
    private final LedgerEntryRepository ledgerEntryRepository;
    private final LedgerService ledgerService;
    private final BookingService bookingService;
    private final com.nimbus.notification.application.service.NotificationService notificationService;

    /**
     * Create a payment intent for a booking.
     * Uses idempotency key to prevent duplicate processing.
     */
    @Transactional
    public PaymentResponse createPayment(PaymentRequest request, UUID userId) {
        // Lock the booking row: two concurrent payment attempts with
        // different idempotency keys must not both charge the passenger.
        Booking booking = bookingRepository.findByIdForUpdate(request.getBookingId())
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Validate user is the passenger
        if (!booking.getPassenger().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        // Check for existing payment with same idempotency key
        Optional<Payment> existingPayment = paymentRepository.findByIdempotencyKey(request.getIdempotencyKey());
        if (existingPayment.isPresent()) {
            Payment existing = existingPayment.get();
            // An idempotency key is client-supplied. Never let a caller
            // retrieve another passenger's payment by reusing their key.
            if (!existing.getPayer().getId().equals(userId)
                    || !existing.getBooking().getId().equals(booking.getId())) {
                throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
            }
            return toResponse(existing);
        }

        // Reusing an idempotency key is not the only retry path: the app may
        // retry with a fresh key after a network timeout. Never take a second
        // payment for a booking that is already paid.
        Optional<Payment> completedPayment = paymentRepository
                .findFirstByBookingIdAndStatusOrderByCreatedAtDesc(
                        booking.getId(), Payment.PaymentStatus.SUCCESS);
        if (completedPayment.isPresent()) {
            return toResponse(completedPayment.get());
        }

        // Payments are only valid while the seat hold is live. Once the hold
        // has expired or the booking was cancelled, taking money would strand
        // the passenger without a seat (guide §5/§12).
        if (booking.getStatus() != Booking.BookingStatus.HELD) {
            throw new NimbusException(ErrorCode.BOOKING_EXPIRED,
                    "Booking is no longer payable (status " + booking.getStatus() + ")",
                    HttpStatus.CONFLICT);
        }

        // The backend is authoritative for amounts (guide §5/§12): never
        // trust the client's amount, and never accept a payment for a booking
        // that has no server-priced fare.
        BigDecimal payable = booking.getFinalPayable();
        if (payable == null || payable.signum() <= 0) {
            throw new NimbusException(ErrorCode.PAYMENT_FAILED,
                    "Booking has no server-priced fare", HttpStatus.CONFLICT);
        }
        if (request.getAmount() == null || request.getAmount().compareTo(payable) != 0) {
            throw new NimbusException(ErrorCode.PAYMENT_FAILED,
                    "Amount does not match the booking fare (expected "
                            + payable + ")", HttpStatus.BAD_REQUEST);
        }

        // Get payment provider
        PaymentProvider provider = providerRegistry.getProvider(request.getMethod());
        if (provider == null) {
            throw new NimbusException(ErrorCode.PAYMENT_FAILED,
                    "Payment method not supported: " + request.getMethod(), HttpStatus.BAD_REQUEST);
        }

        // Create payment record
        Payment payment = Payment.builder()
                .booking(booking)
                .payer(booking.getPassenger())
                .amount(payable)
                .method(Payment.PaymentMethod.valueOf(request.getMethod().toUpperCase()))
                .status(Payment.PaymentStatus.PENDING)
                .idempotencyKey(request.getIdempotencyKey())
                .build();

        // Create payment intent with provider
        PaymentProvider.PaymentIntent intent = provider.createPaymentIntent(
                request.getBookingId(), payable, request.getIdempotencyKey());

        payment.setProviderReference(intent.providerReference());
        payment = paymentRepository.save(payment);

        // Record transaction
        PaymentTransaction transaction = PaymentTransaction.builder()
                .payment(payment)
                .provider(provider.getProviderName())
                .providerStatus("PENDING")
                .amount(payable)
                .build();
        transactionRepository.save(transaction);

        // Mock providers have no real gateway — complete instantly so the
        // booking flow can proceed (the client still confirms the booking
        // via its own endpoint).
        if (provider instanceof com.nimbus.payment.infrastructure.provider.MockPaymentProvider) {
            payment.updateStatus(Payment.PaymentStatus.SUCCESS);
            payment = paymentRepository.save(payment);
            transaction.setProviderStatus(Payment.PaymentStatus.SUCCESS.name());
            transactionRepository.save(transaction);
            processSuccessfulPayment(payment);
            log.info("Mock payment completed instantly: {} for booking: {}", payment.getId(),
                    request.getBookingId());
        }

        // Send audit log
        log.info("Payment created: {} for booking: {} method: {}", payment.getId(),
                request.getBookingId(), request.getMethod());

        return toResponse(payment, intent);
    }

    /**
     * Process provider webhook callback.
     * Verifies the webhook and updates payment state idempotently.
     */
    @Transactional
    public void processWebhook(String provider, String rawPayload, String signature) {
        PaymentProvider paymentProvider = providerRegistry.getProvider(provider.toUpperCase());
        if (paymentProvider == null) {
            log.warn("Unknown payment provider: {}", provider);
            throw new NimbusException(ErrorCode.PAYMENT_FAILED,
                    "Unknown payment provider", HttpStatus.BAD_REQUEST);
        }

        // Verify signature and parse callback (providers must verify the
        // signature before trusting any content — guide §12/§18).
        PaymentProvider.WebhookResult result = paymentProvider.processWebhook(rawPayload, signature);

        // One normalized provider key for both the dedupe lookup and the
        // stored row — a casing mismatch here would silently defeat dedupe.
        String providerKey = provider != null ? provider.toUpperCase() : "";

        // Server-side dedupe (guide §12: process duplicate callbacks
        // idempotently) — a provider event ref we've already recorded is a
        // replay regardless of what the payload says.
        if (result.providerEventRef() != null
                && transactionRepository.existsByProviderAndProviderEventRef(
                        providerKey, result.providerEventRef())) {
            log.info("Duplicate webhook (event ref {}) from provider: {} for payment: {}",
                    result.providerEventRef(), provider, result.paymentId());
            return;
        }

        if (result.isDuplicate()) {
            log.info("Duplicate webhook from provider: {} for payment: {}",
                    providerKey, result.paymentId());
            return;
        }

        // Find and update payment
        Payment payment = paymentRepository.findById(result.paymentId())
                .orElseThrow(() -> {
                    log.error("Payment not found: {}", result.paymentId());
                    return new NimbusException(ErrorCode.PAYMENT_FAILED,
                            "Payment not found", HttpStatus.NOT_FOUND);
                });

        // Verify amount matches
        if (payment.getAmount().compareTo(result.amount()) != 0) {
            log.error("Amount mismatch: payment={} provider={}",
                    payment.getAmount(), result.amount());
            throw new NimbusException(ErrorCode.PAYMENT_FAILED,
                    "Payment amount mismatch", HttpStatus.CONFLICT);
        }

        // An already-terminal payment must not re-process (defence in depth
        // alongside the event-ref dedupe above).
        if (payment.getStatus() == Payment.PaymentStatus.SUCCESS
                || payment.getStatus() == Payment.PaymentStatus.REFUNDED) {
            recordTransaction(payment, providerKey, result, rawPayload);
            log.info("Webhook for already-processed payment {} recorded without side effects",
                    payment.getId());
            return;
        }

        // Update payment status
        payment.updateStatus(result.status());
        paymentRepository.save(payment);

        recordTransaction(payment, providerKey, result, rawPayload);

        // If successful, update ledger
        if (result.status() == Payment.PaymentStatus.SUCCESS) {
            processSuccessfulPayment(payment);
        }

        log.info("Payment webhook processed: {} status: {}",
                payment.getId(), result.status());
    }

    private void recordTransaction(Payment payment, String provider,
                                   PaymentProvider.WebhookResult result, String rawPayload) {
        PaymentTransaction transaction = PaymentTransaction.builder()
                .payment(payment)
                .provider(provider)
                .providerStatus(result.status().name())
                .amount(result.amount())
                .rawResponse(rawPayload)
                .providerEventRef(result.providerEventRef())
                .build();
        transactionRepository.save(transaction);
    }

    /**
     * Process a successful payment by creating ledger entries.
     */
    private void processSuccessfulPayment(Payment payment) {
        Booking booking = payment.getBooking();

        // Ledger failures must roll the whole transaction back. Leaving a
        // payment SUCCESS while its ledger entry is missing corrupts the
        // passenger wallet and settlement totals (guide §12/§13).
        ledgerService.postPassengerPayment(
                booking,
                payment.getAmount(),
                payment.getId(),
                payment.getMethod()
        );

        // A successful payment commits the seat. The client may still call
        // the confirm endpoint (it is idempotent), but the booking must never
        // be left HELD with the passenger's money already collected.
        if (booking.getStatus() == Booking.BookingStatus.HELD) {
            bookingService.confirmBooking(booking.getId(), booking.getPassenger().getId());
        } else if (booking.getStatus() != Booking.BookingStatus.CONFIRMED) {
            throw new NimbusException(ErrorCode.BOOKING_EXPIRED,
                    "Payment received after booking became " + booking.getStatus()
                            + "; refund/reconciliation required",
                    HttpStatus.CONFLICT);
        }

        // Receipt notification to the passenger. Notifications are not part
        // of the financial transaction, so a delivery failure must not undo
        // a successful payment.
        try {
            notificationService.sendNotification(
                    payment.getPayer().getId(),
                    com.nimbus.notification.domain.entity.Notification.NotificationType.PAYMENT_RECEIVED,
                    "Payment received",
                    "We received your payment of " + payment.getAmount() + " BDT.",
                    java.util.Map.of("paymentId", payment.getId().toString(),
                            "bookingId", booking.getId().toString()));
        } catch (Exception notifyError) {
            log.warn("Payment notification failed: {}", notifyError.getMessage());
        }
    }

    /**
     * Get payment status.
     */
    @Transactional(readOnly = true)
    public PaymentStatusResponse getPaymentStatus(UUID paymentId, UUID userId) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new NimbusException(ErrorCode.PAYMENT_FAILED,
                        "Payment not found", HttpStatus.NOT_FOUND));

        // Authorization: payer or ride driver can view
        if (!payment.getPayer().getId().equals(userId) &&
            !payment.getBooking().getRide().getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        return PaymentStatusResponse.builder()
                .paymentId(payment.getId())
                .bookingId(payment.getBooking().getId())
                .amount(payment.getAmount())
                .method(payment.getMethod())
                .status(payment.getStatus())
                .providerReference(payment.getProviderReference())
                .createdAt(payment.getCreatedAt())
                .updatedAt(payment.getUpdatedAt())
                .build();
    }

    private PaymentResponse toResponse(Payment payment) {
        return toResponse(payment, null);
    }

    private PaymentResponse toResponse(Payment payment, PaymentProvider.PaymentIntent intent) {
        return PaymentResponse.builder()
                .paymentId(payment.getId())
                .bookingId(payment.getBooking().getId())
                .amount(payment.getAmount())
                .method(payment.getMethod())
                .status(payment.getStatus())
                .clientSecret(intent != null ? intent.clientSecret() : null)
                .paymentUrl(intent != null ? intent.paymentUrl() : null)
                .requiresRedirect(intent != null && intent.requiresRedirect())
                .providerReference(payment.getProviderReference())
                .expiresAt(Instant.now().plusSeconds(300)) // 5 min expiry
                .build();
    }
}
