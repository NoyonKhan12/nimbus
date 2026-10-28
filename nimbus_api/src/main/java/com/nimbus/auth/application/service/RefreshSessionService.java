package com.nimbus.auth.application.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.ErrorCode;
import lombok.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.*;

/**
 * Redis-backed refresh-token session store (guide §14: auth:refresh:{sessionId}).
 *
 * <p>Enables true refresh-token rotation and revocation: every refresh token
 * carries a session id ("sid") claim, and the session must exist in Redis for
 * the token to be refreshable. Rotating deletes the old session and issues a
 * new one; logout/admin action deletes sessions, instantly invalidating the
 * matching refresh tokens. PostgreSQL remains the source of truth for user
 * accounts; Redis is transient session state.</p>
 */
@Service
public class RefreshSessionService {

    private static final String SESSION_KEY_PREFIX = "auth:refresh:";
    private static final String USER_INDEX_KEY_PREFIX = "auth:refresh:user:";

    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;
    private final Duration sessionTtl;

    @Autowired
    public RefreshSessionService(
            StringRedisTemplate redisTemplate,
            ObjectMapper objectMapper,
            @Value("${app.jwt.refresh-token-expiration-ms:2592000000}") long refreshTokenExpirationMs) {
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
        this.sessionTtl = Duration.ofMillis(refreshTokenExpirationMs);
    }

    /** Session metadata returned by the session-list API. */
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class SessionInfo {
        private String sessionId;
        private UUID userId;
        private String deviceId;
        private String platform;
        private Instant createdAt;
        private Instant lastRefreshedAt;
    }

    /**
     * Create a new refresh session for the user.
     *
     * @return the session id to embed in the refresh token's "sid" claim
     */
    public String createSession(UUID userId, String deviceId, String platform) {
        String sessionId = UUID.randomUUID().toString();
        SessionInfo info = SessionInfo.builder()
                .sessionId(sessionId)
                .userId(userId)
                .deviceId(deviceId)
                .platform(platform)
                .createdAt(Instant.now())
                .lastRefreshedAt(Instant.now())
                .build();
        save(sessionId, info);
        redisTemplate.opsForSet().add(USER_INDEX_KEY_PREFIX + userId, sessionId);
        redisTemplate.expire(USER_INDEX_KEY_PREFIX + userId, sessionTtl);
        return sessionId;
    }

    /**
     * Rotate a session: verify it still exists (revoked sessions are gone)
     * and replace it with a fresh session id.
     *
     * @throws NimbusException 401 if the session was revoked or expired
     */
    public String rotate(String sessionId, UUID userId) {
        SessionInfo existing = get(sessionId);
        if (existing == null || !existing.getUserId().equals(userId)) {
            throw new NimbusException(ErrorCode.AUTH_REFRESH_TOKEN_INVALID,
                    "Refresh session has been revoked", HttpStatus.UNAUTHORIZED);
        }
        redisTemplate.delete(SESSION_KEY_PREFIX + sessionId);
        String newSessionId = createSession(userId, existing.getDeviceId(), existing.getPlatform());
        return newSessionId;
    }

    /** Revoke a single session if it exists and belongs to the user. */
    public boolean revoke(String sessionId, UUID userId) {
        SessionInfo existing = get(sessionId);
        if (existing == null || !existing.getUserId().equals(userId)) {
            return false;
        }
        redisTemplate.delete(SESSION_KEY_PREFIX + sessionId);
        redisTemplate.opsForSet().remove(USER_INDEX_KEY_PREFIX + userId, sessionId);
        return true;
    }

    /** Revoke every session of a user (password compromise / logout-all). */
    public void revokeAllForUser(UUID userId) {
        Set<String> sessionIds = redisTemplate.opsForSet().members(USER_INDEX_KEY_PREFIX + userId);
        if (sessionIds != null) {
            for (String sessionId : sessionIds) {
                redisTemplate.delete(SESSION_KEY_PREFIX + sessionId);
            }
        }
        redisTemplate.delete(USER_INDEX_KEY_PREFIX + userId);
    }

    /** List the user's active sessions. */
    public List<SessionInfo> listForUser(UUID userId) {
        Set<String> sessionIds = redisTemplate.opsForSet().members(USER_INDEX_KEY_PREFIX + userId);
        if (sessionIds == null || sessionIds.isEmpty()) {
            return List.of();
        }
        return sessionIds.stream()
                .map(this::get)
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(SessionInfo::getCreatedAt).reversed())
                .toList();
    }

    private SessionInfo get(String sessionId) {
        String json = redisTemplate.opsForValue().get(SESSION_KEY_PREFIX + sessionId);
        if (json == null) return null;
        try {
            return objectMapper.readValue(json, SessionInfo.class);
        } catch (Exception e) {
            return null;
        }
    }

    private void save(String sessionId, SessionInfo info) {
        try {
            redisTemplate.opsForValue().set(SESSION_KEY_PREFIX + sessionId,
                    objectMapper.writeValueAsString(info), sessionTtl);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to persist refresh session", e);
        }
    }
}
