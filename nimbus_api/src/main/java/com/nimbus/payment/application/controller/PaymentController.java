package com.nimbus.payment.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import com.nimbus.payment.application.*;
import com.nimbus.payment.application.port.PaymentProviderRegistry;
import com.nimbus.payment.application.PaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Payment management endpoints.
 */
@RestController
@RequestMapping("/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    /**
     * Create a payment for a booking.
     * POST /payments
     */
    @PostMapping
    public ResponseEntity<ApiResponse<PaymentResponse>> createPayment(
            @Valid @RequestBody PaymentRequest request) {
        UUID userId = getCurrentUserId();
        PaymentResponse response = paymentService.createPayment(request, userId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<PaymentResponse>builder()
                        .success(true)
                        .data(response)
                        .message("Payment created successfully")
                        .timestamp(java.time.Instant.now().toString())
                        .build());
    }

    /**
     * Get payment status.
     * GET /payments/{paymentId}
     */
    @GetMapping("/{paymentId}")
    public ResponseEntity<ApiResponse<PaymentStatusResponse>> getPaymentStatus(@PathVariable UUID paymentId) {
        UUID userId = getCurrentUserId();
        PaymentStatusResponse response = paymentService.getPaymentStatus(paymentId, userId);
        return ResponseEntity.ok(ApiResponse.<PaymentStatusResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Provider webhook callback.
     * POST /payments/webhooks/{provider}
     */
    @PostMapping("/webhooks/{provider}")
    public ResponseEntity<ApiResponse<Void>> handleWebhook(
            @PathVariable String provider,
            @RequestHeader(value = "Signature", required = false) String signature,
            @RequestBody String rawPayload) {
        paymentService.processWebhook(provider, rawPayload, signature);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
