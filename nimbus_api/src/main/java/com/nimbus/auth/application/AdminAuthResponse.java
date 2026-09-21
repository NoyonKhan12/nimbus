package com.nimbus.auth.application;

import lombok.*;

/**
 * Response DTO for admin login — returns JWT tokens.
 * Matches the AdminAuthTokens interface expected by the admin panel.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminAuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType = "Bearer";
    private long expiresIn;
}