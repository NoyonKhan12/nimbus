package com.nimbus.auth.infrastructure.provider;

import com.nimbus.auth.application.port.SmsProvider;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * Development/default SMS provider that records the dispatch attempt.
 *
 * Never logs the OTP unless {@code nimbus.sms.log-content=true} is explicitly
 * set in a local environment (guide §18: never log OTPs). Production must
 * register a real provider — set {@code nimbus.sms.provider} accordingly and
 * implement this port with the provider SDK.
 */
@Component
@ConditionalOnProperty(name = "nimbus.sms.provider", havingValue = "console", matchIfMissing = true)
@Slf4j
public class ConsoleSmsProvider implements SmsProvider {

    private final boolean logContent;

    public ConsoleSmsProvider(@Value("${nimbus.sms.log-content:false}") boolean logContent) {
        this.logContent = logContent;
    }

    @Override
    public void send(String phone, String message) {
        if (logContent) {
            log.info("[SMS console provider] to={} message={}", phone, message);
        } else {
            log.info("[SMS console provider] message dispatched to {} (content not logged)", phone);
        }
    }
}
