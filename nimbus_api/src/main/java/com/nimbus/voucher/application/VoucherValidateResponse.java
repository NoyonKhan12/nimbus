package com.nimbus.voucher.application;

import com.nimbus.voucher.domain.entity.Voucher;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Voucher validation response.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class VoucherValidateResponse {
    private String voucherCode;
    private Voucher.DiscountType discountType;
    private BigDecimal discountAmount;
    private BigDecimal discountedFare;
    private String description;
    private String message;
}
