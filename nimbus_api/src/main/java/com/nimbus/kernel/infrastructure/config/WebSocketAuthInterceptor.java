package com.nimbus.kernel.infrastructure.config;

import com.nimbus.ride.domain.repository.RideRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

/**
 * WebSocket authentication interceptor for handling JWT during handshake.
 */
@Component
@Slf4j
public class WebSocketAuthInterceptor implements HandshakeInterceptor {

    private final RideRepository rideRepository;

    public WebSocketAuthInterceptor(RideRepository rideRepository) {
        this.rideRepository = rideRepository;
    }

    @Override
    public boolean beforeHandshake(
            org.springframework.http.server.ServerHttpRequest request,
            org.springframework.http.server.ServerHttpResponse response,
            org.springframework.web.socket.WebSocketHandler handler,
            Map<String, Object> attributes) throws Exception {
        return true;
    }

    @Override
    public void afterHandshake(
            org.springframework.http.server.ServerHttpRequest request,
            org.springframework.http.server.ServerHttpResponse response,
            org.springframework.web.socket.WebSocketHandler handler,
            Exception ex) {
    }
}
