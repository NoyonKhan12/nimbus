package com.nimbus.auth.application.port;

/**
 * Port for SMS delivery (guide §12/§18: keep providers behind adapters).
 * Implementations ship separately per provider (bKash gateway, custom SMS
 * gateway, etc.). The default local implementation is {@code ConsoleSmsProvider}.
 */
public interface SmsProvider {

    /**
     * Deliver an SMS message to the given phone number (E.164 format).
     *
     * @param phone   recipient phone
     * @param message message body (must not include secrets other than the OTP)
     */
    void send(String phone, String message);
}
