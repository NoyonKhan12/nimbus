package com.nimbus.admin.domain.projection;

import java.time.Instant;
import java.util.UUID;

/**
 * Projection for admin user listing - avoids N+1 by joining profile in a single query.
 */
public record UserAdminProjection(
    UUID id,
    String phone,
    String email,
    String status,
    String role,
    boolean phoneVerified,
    Instant createdAt,
    String firstName,
    String lastName
) {
}
