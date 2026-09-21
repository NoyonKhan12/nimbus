package com.nimbus.booking.application.controller;

import com.nimbus.booking.application.BookingResponse;
import com.nimbus.booking.application.CreateBookingRequest;
import com.nimbus.booking.application.service.BookingService;
import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * Booking management endpoints.
 */
@RestController
@RequestMapping("/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    /**
     * Create a new booking (seat hold).
     * POST /rides/{rideId}/bookings
     */
    @PostMapping
    public ResponseEntity<ApiResponse<BookingResponse>> createBooking(
            @Valid @RequestBody CreateBookingRequest request) {
        UUID userId = getCurrentUserId();
        BookingResponse response = bookingService.createBooking(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<BookingResponse>builder()
                        .success(true)
                        .data(response)
                        .message("Booking created successfully")
                        .timestamp(java.time.Instant.now().toString())
                        .build());
    }

    /**
     * Get booking details.
     * GET /bookings/{bookingId}
     */
    @GetMapping("/{bookingId}")
    public ResponseEntity<ApiResponse<BookingResponse>> getBooking(@PathVariable UUID bookingId) {
        UUID userId = getCurrentUserId();
        BookingResponse response = bookingService.getBooking(bookingId, userId);
        return ResponseEntity.ok(ApiResponse.<BookingResponse>builder()
                .success(true)
                .data(response)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * List user's bookings.
     * GET /bookings
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<BookingResponse>>> listBookings() {
        UUID userId = getCurrentUserId();
        List<BookingResponse> bookings = bookingService.listBookings(userId);
        return ResponseEntity.ok(ApiResponse.<List<BookingResponse>>builder()
                .success(true)
                .data(bookings)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Cancel a booking.
     * POST /bookings/{bookingId}/cancel
     */
    @PostMapping("/{bookingId}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelBooking(@PathVariable UUID bookingId) {
        UUID userId = getCurrentUserId();
        bookingService.cancelBooking(bookingId, userId);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Booking cancelled successfully")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Confirm a booking (transition from HELD to CONFIRMED).
     * POST /bookings/{bookingId}/confirm
     */
    @PostMapping("/{bookingId}/confirm")
    public ResponseEntity<ApiResponse<BookingResponse>> confirmBooking(@PathVariable UUID bookingId) {
        UUID userId = getCurrentUserId();
        BookingResponse response = bookingService.confirmBooking(bookingId, userId);
        return ResponseEntity.ok(ApiResponse.<BookingResponse>builder()
                .success(true)
                .data(response)
                .message("Booking confirmed successfully")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Mark passenger as picked up.
     * POST /bookings/{bookingId}/pickup
     */
    @PostMapping("/{bookingId}/pickup")
    public ResponseEntity<ApiResponse<Void>> pickup(@PathVariable UUID bookingId) {
        UUID userId = getCurrentUserId();
        bookingService.pickup(bookingId, userId);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Passenger picked up")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Mark passenger as dropped off.
     * POST /bookings/{bookingId}/dropoff
     */
    @PostMapping("/{bookingId}/dropoff")
    public ResponseEntity<ApiResponse<Void>> dropoff(@PathVariable UUID bookingId) {
        UUID userId = getCurrentUserId();
        bookingService.dropoff(bookingId, userId);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Passenger dropped off")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
