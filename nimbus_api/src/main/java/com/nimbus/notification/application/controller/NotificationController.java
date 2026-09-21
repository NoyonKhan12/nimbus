package com.nimbus.notification.application.controller;

import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import com.nimbus.notification.application.NotificationResponse;
import com.nimbus.notification.application.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Notification management endpoints.
 */
@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    /**
     * Get user's recent notifications.
     * GET /notifications
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> getUserNotifications(
            @RequestParam(defaultValue = "20") int limit) {
        UUID userId = getCurrentUserId();
        List<NotificationResponse> notifications = notificationService.getUserNotifications(userId, limit);
        return ResponseEntity.ok(ApiResponse.<List<NotificationResponse>>builder()
                .success(true)
                .data(notifications)
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    /**
     * Mark a notification as read.
     * POST /notifications/{notificationId}/read
     */
    @PostMapping("/{notificationId}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable UUID notificationId) {
        UUID userId = getCurrentUserId();
        notificationService.markAsRead(notificationId, userId);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .success(true)
                .message("Notification marked as read")
                .timestamp(java.time.Instant.now().toString())
                .build());
    }

    private UUID getCurrentUserId() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        return auth.getUser().getId();
    }
}
