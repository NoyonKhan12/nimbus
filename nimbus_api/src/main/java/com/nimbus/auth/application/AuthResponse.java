package com.nimbus.auth.application;

import com.nimbus.user.application.UserResponse;
import lombok.*;

/**
 * Authentication response with tokens and user info.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private long expiresIn;
    private UserResponse user;
}