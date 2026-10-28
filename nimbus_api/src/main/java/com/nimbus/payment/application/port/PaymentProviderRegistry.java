package com.nimbus.payment.application.port;

import org.springframework.stereotype.Component;

import java.util.*;

/**
 * Registry of available payment providers.
 * Maps payment methods to their provider implementations.
 */
@Component
public class PaymentProviderRegistry {

    private final Map<String, PaymentProvider> providers = new HashMap<>();

    public void registerProvider(PaymentProvider provider) {
        providers.put(provider.getProviderName(), provider);
    }

    public PaymentProvider getProvider(String name) {
        // Clients may send method names in any case ("bkash"/"BKASH").
        return name == null ? null : providers.get(name.toLowerCase());
    }

    public Collection<PaymentProvider> getAllProviders() {
        return providers.values();
    }

    public boolean hasProvider(String name) {
        return providers.containsKey(name);
    }
}
