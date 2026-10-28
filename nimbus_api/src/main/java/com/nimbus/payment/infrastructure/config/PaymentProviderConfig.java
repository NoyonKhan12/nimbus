package com.nimbus.payment.infrastructure.config;

import com.nimbus.payment.application.port.PaymentProviderRegistry;
import com.nimbus.payment.infrastructure.provider.MockPaymentProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * Registers the payment providers available in this deployment. The MVP
 * ships only the mock provider, registered under the method names the
 * clients send. Real bKash/Nagad adapters register here alongside it.
 *
 * <p>Webhook secrets come from configuration — never hardcode them
 * (guide §18: secrets live in the environment).</p>
 */
@Configuration
public class PaymentProviderConfig {

    public PaymentProviderConfig(
            PaymentProviderRegistry registry,
            @Value("${app.payments.webhook-secret:mock-webhook-secret}") String webhookSecret) {
        registry.registerProvider(new MockPaymentProvider("bkash", webhookSecret));
        registry.registerProvider(new MockPaymentProvider("nagad", webhookSecret));
        registry.registerProvider(new MockPaymentProvider("wallet", webhookSecret));
        registry.registerProvider(new MockPaymentProvider("cash", webhookSecret));
    }
}
