package com.nimbus.payment.application;

import jakarta.validation.constraints.*;
import lombok.*;

import java.util.UUID;

/**
 * Payment request DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRequest {

    @NotNull(message = "Booking ID is required")
    private UUID bookingId;

    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be positive")
    private java.math.BigDecimal amount;

    @NotBlank(message = "Payment method is required")
    private String method;

    private String returnUrl;

    @NotBlank(message = "Idempotency key is required")
    private String idempotencyKey;
}
