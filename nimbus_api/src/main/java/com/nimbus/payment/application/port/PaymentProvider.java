package com.nimbus.payment.application.port;

import com.nimbus.payment.domain.entity.*;

import java.math.BigDecimal;
import java.util.*;

/**
 * Port interface for payment provider adapters.
 *
 * <p>Implementations must handle provider-specific logic for payment intents,
 * webhook/callback verification, and idempotency.</p>
 *
 * <p>Supported providers for Bangladesh:
 * - bKash (primary mobile money)
 * - Nagad (alternative mobile money)
 * - Rocket (alternative mobile money)
 * - Cards (credit/debit via gateway)
 */
public interface PaymentProvider {

    /**
     * Get the provider name (e.g., "BKASH", "NAGAD", "CARD").
     */
    String getProviderName();

    /**
     * Create a payment intent with the provider.
     * Must include an idempotency key to prevent duplicate processing.
     *
     * @param bookingId       The booking being paid for
     * @param amount          Amount to charge
     * @param idempotencyKey  Unique key for idempotent requests
     * @return PaymentIntent with provider reference
     */
    PaymentIntent createPaymentIntent(UUID bookingId, BigDecimal amount, String idempotencyKey);

    /**
     * Verify and process a provider callback/webhook.
     * Must independently validate amount and booking.
     *
     * @param rawPayload  The raw webhook payload
     * @param signature   The webhook signature for verification
     * @return Processed result
     */
    WebhookResult processWebhook(String rawPayload, String signature);

    /**
     * Refund a payment.
     *
     * @param paymentId   The payment to refund
     * @param amount      Amount to refund (null for full refund)
     * @return Refund result
     */
    RefundResult refundPayment(UUID paymentId, BigDecimal amount);

    /**
     * Get the current status of a payment from the provider.
     *
     * @param providerReference The provider's payment reference
     * @return Payment status
     */
    PaymentStatusResult getPaymentStatus(String providerReference);

    /**
     * Payment intent created by the provider.
     */
    record PaymentIntent(
            String providerReference,
            String clientSecret,
            String paymentUrl,
            boolean requiresRedirect
    ) {}

    /**
     * Result of processing a webhook. providerEventRef is the provider's
     * dedupe key for the callback; implementations must verify the
     * signature BEFORE returning a result.
     */
    record WebhookResult(
            UUID paymentId,
            Payment.PaymentStatus status,
            BigDecimal amount,
            String providerReference,
            boolean isDuplicate,
            String providerEventRef
    ) {
        /** Backward-compatible constructor for providers without event refs. */
        public WebhookResult(UUID paymentId, Payment.PaymentStatus status, BigDecimal amount,
                             String providerReference, boolean isDuplicate) {
            this(paymentId, status, amount, providerReference, isDuplicate, null);
        }
    }

    /**
     * Result of a refund operation.
     */
    record RefundResult(
            UUID paymentId,
            UUID refundPaymentId,
            Payment.PaymentStatus newStatus,
            BigDecimal refundedAmount,
            String refundReference
    ) {}

    /**
     * Payment status result from provider.
     */
    record PaymentStatusResult(
            Payment.PaymentStatus status,
            BigDecimal amount,
            String providerReference
    ) {}
}
