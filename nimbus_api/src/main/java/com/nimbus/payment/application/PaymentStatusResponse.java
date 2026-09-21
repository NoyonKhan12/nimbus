package com.nimbus.payment.application;

import com.nimbus.payment.domain.entity.Payment;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Payment status response.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentStatusResponse {
    private UUID paymentId;
    private UUID bookingId;
    private BigDecimal amount;
    private Payment.PaymentMethod method;
    private Payment.PaymentStatus status;
    private String providerReference;
    private Instant createdAt;
    private Instant updatedAt;
}
