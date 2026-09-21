package com.nimbus.voucher.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import com.nimbus.voucher.application.VoucherValidateRequest;
import com.nimbus.voucher.application.VoucherValidateResponse;
import com.nimbus.voucher.application.service.VoucherService;
import com.nimbus.voucher.domain.entity.VoucherRedemption;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Voucher validation and redemption endpoints.
 */
@RestController
@RequestMapping("/vouchers")
@RequiredArgsConstructor
public class VoucherController {

    private final VoucherService voucherService;

    /**
     * Validate a voucher for the current user.
     * POST /vouchers/validate
     */
    @PostMapping("/validate")
    public ResponseEntity<ApiResponse<VoucherValidateResponse>> validateVoucher(
            @Valid @RequestBody VoucherValidateRequest request) {
        UUID userId = getCurrentUserId();
        VoucherValidateResponse response = voucherService.validateVoucher(userId, request);
        return ResponseEntity.ok(ApiResponse.<VoucherValidateResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * List user's voucher redemptions.
     * GET /vouchers/redemptions
     */
    @GetMapping("/redemptions")
    public ResponseEntity<ApiResponse<List<VoucherRedemption>>> getUserRedemptions() {
        UUID userId = getCurrentUserId();
        List<VoucherRedemption> redemptions = voucherService.getUserRedemptions(userId);
        return ResponseEntity.ok(ApiResponse.<List<VoucherRedemption>>builder()
                .success(true)
                .data(redemptions)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
