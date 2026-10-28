package com.nimbus.payment.infrastructure.provider;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nimbus.payment.application.port.PaymentProvider;
import com.nimbus.payment.domain.entity.Payment;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;

/**
 * Mock payment provider for the MVP — simulates bKash/Nagad/wallet/cash
 * behind the PaymentProvider port so the end-to-end booking flow works
 * without a real gateway (guide §12: keep providers behind adapters).
 *
 * <p>Webhooks must present a valid HMAC-SHA256 signature of the raw body
 * keyed with the provider webhook secret (guide §18: webhook signature
 * verification) — the same verification flow a real bKash/Nagad IPN goes
 * through. Replace with real provider adapters before production.</p>
 */
public class MockPaymentProvider implements PaymentProvider {

    private final String name;
    private final byte[] webhookSecret;

    public MockPaymentProvider(String name, String webhookSecret) {
        this.name = name.toLowerCase();
        this.webhookSecret = (webhookSecret != null ? webhookSecret : "mock-webhook-secret")
                .getBytes(StandardCharsets.UTF_8);
    }

    @Override
    public String getProviderName() {
        return name;
    }

    @Override
    public PaymentIntent createPaymentIntent(UUID bookingId, BigDecimal amount, String idempotencyKey) {
        return new PaymentIntent(
                "mock-" + name + "-" + idempotencyKey,
                null,
                null,
                false
        );
    }

    @Override
    public WebhookResult processWebhook(String rawPayload, String signature) {
        // Verify signature first — unsigned or forged callbacks are rejected
        // before any state is read (guide §12/§18).
        if (signature == null || !verifySignature(rawPayload, signature)) {
            throw new SecurityException("Invalid webhook signature for provider " + name);
        }
        try {
            JsonNode node = new ObjectMapper().readTree(rawPayload);
            UUID paymentId = UUID.fromString(node.get("paymentId").asText());
            BigDecimal amount = new BigDecimal(node.get("amount").asText());
            String status = node.hasNonNull("status") ? node.get("status").asText() : "SUCCESS";
            // Deterministic event ref: a replayed identical callback dedupes.
            String eventRef = node.hasNonNull("eventRef")
                    ? node.get("eventRef").asText()
                    : name + "-" + paymentId + "-" + status + "-" + amount.stripTrailingZeros();
            return new WebhookResult(paymentId, Payment.PaymentStatus.valueOf(status),
                    amount, "mock-ref", false, eventRef);
        } catch (SecurityException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Invalid mock webhook payload: expected {paymentId, amount[, status, eventRef]}", e);
        }
    }

    /** Constant-time HMAC-SHA256 comparison of the Signature header. */
    private boolean verifySignature(String payload, String signature) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(webhookSecret, "HmacSHA256"));
            byte[] digest = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : digest) {
                hex.append(String.format("%02x", b));
            }
            return MessageDigest.isEqual(
                    hex.toString().getBytes(StandardCharsets.UTF_8),
                    signature.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public RefundResult refundPayment(UUID paymentId, BigDecimal amount) {
        return new RefundResult(
                paymentId,
                UUID.randomUUID(),
                Payment.PaymentStatus.REFUNDED,
                amount,
                "mock-refund-" + UUID.randomUUID().toString().substring(0, 8)
        );
    }

    @Override
    public PaymentStatusResult getPaymentStatus(String providerReference) {
        return new PaymentStatusResult(Payment.PaymentStatus.SUCCESS, null, providerReference);
    }
}
