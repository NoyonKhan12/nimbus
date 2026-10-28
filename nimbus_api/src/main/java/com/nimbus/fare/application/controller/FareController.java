package com.nimbus.fare.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.fare.application.FareQuoteRequest;
import com.nimbus.fare.application.FareQuoteResponse;
import com.nimbus.fare.application.service.FareService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;
import org.springframework.web.bind.annotation.*;

/**
 * Fare calculation endpoints.
 */
@RestController
@RequestMapping("/fare")
@RequiredArgsConstructor
public class FareController {

    private final FareService fareService;

    /**
     * Generate a fare quote for a potential booking.
     */
    @PostMapping("/quote")
    public ResponseEntity<ApiResponse<FareQuoteResponse>> quote(@Valid @RequestBody FareQuoteRequest request) {
        UUID userId = getCurrentUserId();
        FareQuoteResponse response = fareService.generateQuote(request, userId);
        return ResponseEntity.ok(ApiResponse.<FareQuoteResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }


    private UUID getCurrentUserId() {
        var auth = (com.nimbus.kernel.infrastructure.security.UserAuthenticationToken)
                SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}