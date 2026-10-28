package com.nimbus.payment;

import com.nimbus.payment.infrastructure.provider.MockPaymentProvider;
import org.junit.jupiter.api.Test;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Webhook signature verification tests (guide §12/§18): only signed
 * callbacks are processed, and duplicate event refs are detectable.
 */
class MockPaymentProviderTest {

    private static final String SECRET = "test-secret";

    private String sign(String payload) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] digest = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
        StringBuilder hex = new StringBuilder();
        for (byte b : digest) hex.append(String.format("%02x", b));
        return hex.toString();
    }

    @Test
    void validSignature_isAccepted() throws Exception {
        MockPaymentProvider provider = new MockPaymentProvider("bkash", SECRET);
        UUID paymentId = UUID.randomUUID();
        String payload = "{\"paymentId\":\"" + paymentId + "\",\"amount\":\"250.00\"}";

        var result = provider.processWebhook(payload, sign(payload));

        assertEquals(paymentId, result.paymentId());
        assertEquals(new java.math.BigDecimal("250.00"), result.amount());
        assertNotNull(result.providerEventRef());
    }

    @Test
    void invalidSignature_isRejected() {
        MockPaymentProvider provider = new MockPaymentProvider("bkash", SECRET);
        String payload = "{\"paymentId\":\"" + UUID.randomUUID() + "\",\"amount\":\"250.00\"}";

        assertThrows(SecurityException.class,
                () -> provider.processWebhook(payload, "deadbeef"));
    }

    @Test
    void missingSignature_isRejected() {
        MockPaymentProvider provider = new MockPaymentProvider("bkash", SECRET);
        String payload = "{\"paymentId\":\"" + UUID.randomUUID() + "\",\"amount\":\"250.00\"}";

        assertThrows(SecurityException.class,
                () -> provider.processWebhook(payload, null));
    }

    @Test
    void identicalCallbacks_produceIdenticalEventRefs() throws Exception {
        MockPaymentProvider provider = new MockPaymentProvider("bkash", SECRET);
        String payload = "{\"paymentId\":\"" + UUID.randomUUID() + "\",\"amount\":\"100.00\"}";

        var first = provider.processWebhook(payload, sign(payload));
        var replay = provider.processWebhook(payload, sign(payload));

        // Same event ref ⇒ PaymentService dedupe sees the replay.
        assertEquals(first.providerEventRef(), replay.providerEventRef());
    }
}
