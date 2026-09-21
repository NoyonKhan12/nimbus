package com.nimbus.voucher.application;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Voucher validation request.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class VoucherValidateRequest {

    @NotBlank(message = "Voucher code is required")
    private String code;

    private UUID bookingId;
    private UUID userId;
    private BigDecimal fare;
}
