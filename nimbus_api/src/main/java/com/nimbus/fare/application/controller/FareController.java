package com.nimbus.fare.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.fare.application.FareQuoteRequest;
import com.nimbus.fare.application.FareQuoteResponse;
import com.nimbus.fare.application.service.FareService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
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
        FareQuoteResponse response = fareService.generateQuote(request);
        return ResponseEntity.ok(ApiResponse.<FareQuoteResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }
}
