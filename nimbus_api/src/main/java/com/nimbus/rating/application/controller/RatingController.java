package com.nimbus.rating.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import com.nimbus.rating.application.RatingRequest;
import com.nimbus.rating.application.service.RatingService;
import com.nimbus.rating.domain.entity.Rating;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Rating management endpoints.
 */
@RestController
@RequestMapping("/ratings")
@RequiredArgsConstructor
public class RatingController {

    private final RatingService ratingService;

    /**
     * Create a rating for a completed booking.
     * POST /ratings
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Void>> createRating(@Valid @RequestBody RatingRequest request) {
        UUID userId = getCurrentUserId();
        ratingService.createRating(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<Void>builder()
                        .success(true)
                        .message("Rating submitted successfully")
                        .timestamp(java.time.Instant.now().toString())
                        .build());
    }

    /**
     * Get ratings for a user.
     * GET /ratings/{userId}
     */
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<List<Rating>>> getUserRatings(
            @PathVariable UUID userId,
            @RequestParam(defaultValue = "20") int limit) {
        List<Rating> ratings = ratingService.getUserRatings(userId, limit);
        return ResponseEntity.ok(ApiResponse.<List<Rating>>builder()
                .success(true)
                .data(ratings)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
