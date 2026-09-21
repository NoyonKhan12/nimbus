package com.nimbus.payment.application;

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

    /**
     * Create a payment intent for a booking.
     * Uses idempotency key to prevent duplicate processing.
     */
    @Transactional
    public PaymentResponse createPayment(PaymentRequest request, UUID userId) {
        // Validate booking
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new NimbusException(ErrorCode.BOOKING_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Validate user is the passenger
        if (!booking.getPassenger().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        // Check for existing payment with same idempotency key
        Optional<Payment> existingPayment = paymentRepository.findByIdempotencyKey(request.getIdempotencyKey());
        if (existingPayment.isPresent()) {
            return toResponse(existingPayment.get());
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
                .amount(request.getAmount())
                .method(Payment.PaymentMethod.valueOf(request.getMethod()))
                .status(Payment.PaymentStatus.PENDING)
                .idempotencyKey(request.getIdempotencyKey())
                .build();

        // Create payment intent with provider
        PaymentProvider.PaymentIntent intent = provider.createPaymentIntent(
                request.getBookingId(), request.getAmount(), request.getIdempotencyKey());

        payment.setProviderReference(intent.providerReference());
        payment = paymentRepository.save(payment);

        // Record transaction
        PaymentTransaction transaction = PaymentTransaction.builder()
                .payment(payment)
                .provider(provider.getProviderName())
                .providerStatus("PENDING")
                .amount(request.getAmount())
                .build();
        transactionRepository.save(transaction);

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

        // Verify and process webhook
        PaymentProvider.WebhookResult result = paymentProvider.processWebhook(rawPayload, signature);

        if (result.isDuplicate()) {
            log.info("Duplicate webhook from provider: {} for payment: {}",
                    provider, result.paymentId());
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

        // Update payment status
        payment.updateStatus(result.status());
        paymentRepository.save(payment);

        // Record transaction
        PaymentTransaction transaction = PaymentTransaction.builder()
                .payment(payment)
                .provider(provider)
                .providerStatus(result.status().name())
                .amount(result.amount())
                .rawResponse(rawPayload)
                .build();
        transactionRepository.save(transaction);

        // If successful, update ledger
        if (result.status() == Payment.PaymentStatus.SUCCESS) {
            processSuccessfulPayment(payment);
        }

        log.info("Payment webhook processed: {} status: {}",
                payment.getId(), result.status());
    }

    /**
     * Process a successful payment by creating ledger entries.
     */
    private void processSuccessfulPayment(Payment payment) {
        try {
            // Post to passenger's wallet ledger
            ledgerService.postPassengerPayment(
                    payment.getBooking(),
                    payment.getAmount(),
                    payment.getId()
            );

            // Update booking status
            Booking booking = payment.getBooking();
            // Booking status is updated elsewhere in the booking service

        } catch (Exception e) {
            log.error("Failed to process ledger for payment: {}", payment.getId(), e);
            // Don't throw - payment is already recorded as successful
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
