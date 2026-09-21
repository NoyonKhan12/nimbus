package com.nimbus.kernel.infrastructure.security;

import com.nimbus.kernel.domain.entity.User;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.*;
import java.util.function.Function;

/**
 * Utility for JWT token creation and validation.
 */
@Component
public class JwtTokenUtil {

    private final SecretKey secretKey;
    private final long accessTokenExpirationMs;
    private final long refreshTokenExpirationMs;

    public long getAccessTokenExpirationMs() {
        return accessTokenExpirationMs;
    }

    public JwtTokenUtil(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.access-token-expiration-ms:900000}") long accessTokenExpirationMs,
            @Value("${app.jwt.refresh-token-expiration-ms:2592000000}") long refreshTokenExpirationMs) {
        this.secretKey = Keys.hmacShaKeyFor(Base64.getDecoder().decode(secret));
        this.accessTokenExpirationMs = accessTokenExpirationMs;
        this.refreshTokenExpirationMs = refreshTokenExpirationMs;
    }

    /**
     * Generate access token for a user.
     */
    public String generateAccessToken(User user) {
        return generateAccessToken(user, null);
    }

    /**
     * Generate access token with custom expiration for admin users.
     * When adminExpirationMs is provided, uses that duration instead of the default.
     */
    public String generateAccessToken(User user, Long adminExpirationMs) {
        Date now = new Date();
        long expiration = adminExpirationMs != null ? adminExpirationMs : accessTokenExpirationMs;
        Date expiryDate = new Date(now.getTime() + expiration);

        Map<String, Object> claims = new HashMap<>();
        claims.put("role", user.getRole().name());
        claims.put("phone_verified", user.isPhoneVerified());
        claims.put("type", "access");

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(user.getId().toString())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(secretKey)
                .compact();
    }

    /**
     * Generate refresh token for a user.
     */
    public String generateRefreshToken(User user) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + refreshTokenExpirationMs);

        Map<String, Object> claims = new HashMap<>();
        claims.put("type", "refresh");

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(user.getId().toString())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(secretKey)
                .compact();
    }

    /**
     * Extract user ID from token.
     */
    public UUID getUserIdFromToken(String token) {
        String userId = getClaimFromToken(token, Claims::getId);
        if (userId == null) {
            String subject = getSubjectFromToken(token);
            return UUID.fromString(subject);
        }
        return UUID.fromString(userId);
    }

    /**
     * Extract subject (user ID) from token.
     */
    public String getSubjectFromToken(String token) {
        return getClaimFromToken(token, Claims::getSubject);
    }

    /**
     * Get a specific claim from the token.
     */
    public <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = parseClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Parse and validate JWT claims.
     */
    private Claims parseClaims(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (JwtException e) {
            throw new JwtException("Invalid JWT token", e);
        }
    }

    /**
     * Validate token for a user.
     */
    public boolean validateToken(String token, User user) {
        try {
            UUID tokenUserId = getUserIdFromToken(token);
            return tokenUserId.equals(user.getId());
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Check if the token is a refresh token.
     */
    public boolean isRefreshToken(String token) {
        try {
            Claims claims = parseClaims(token);
            return "refresh".equals(claims.get("type"));
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Check if the token is an access token.
     */
    public boolean isAccessToken(String token) {
        try {
            Claims claims = parseClaims(token);
            return "access".equals(claims.get("type"));
        } catch (Exception e) {
            return false;
        }
    }
}