package com.nimbus.admin.application.dto;

import java.time.Instant;
import java.util.UUID;

/**
 * Current admin's own profile as returned by GET /admin/profile.
 */
public record AdminProfileResponse(
    UUID id,
    String phone,
    String email,
    String role,
    String status,
    String firstName,
    String lastName,
    Instant createdAt
) {
}
