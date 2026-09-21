package com.nimbus.auth.application;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

/**
 * Request to refresh access token.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class RefreshTokenRequest {
    @NotBlank(message = "Refresh token is required")
    private String refreshToken;
}