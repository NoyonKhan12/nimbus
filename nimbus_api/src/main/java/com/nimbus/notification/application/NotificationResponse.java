package com.nimbus.notification.application;

import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Notification response DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private UUID id;
    private UUID userId;
    private String type;
    private String title;
    private String content;
    private boolean isRead;
    private Instant createdAt;
}
