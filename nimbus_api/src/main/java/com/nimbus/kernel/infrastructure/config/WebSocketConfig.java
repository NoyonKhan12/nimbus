package com.nimbus.kernel.infrastructure.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.*;
import org.springframework.web.socket.config.annotation.*;
import org.springframework.web.socket.server.HandshakeInterceptor;

/**
 * WebSocket configuration for real-time ride tracking.
 *
 * <p>Clients connect to /ws and subscribe to ride-specific topics:
 * /ride/{rideId} - receives real-time ride updates and location
 *
 * <p>Authorization is enforced via WebSocketChannelInterceptor before
 * subscription to any ride topic.</p>
 */
@Configuration
@EnableWebSocketMessageBroker
@Slf4j
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final WebSocketChannelInterceptor channelInterceptor;
    private final WebSocketAuthInterceptor authInterceptor;

    public WebSocketConfig(WebSocketChannelInterceptor channelInterceptor,
                          WebSocketAuthInterceptor authInterceptor) {
        this.channelInterceptor = channelInterceptor;
        this.authInterceptor = authInterceptor;
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .addInterceptors(authInterceptor)
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Use the built-in simple broker for small scale
        // For production, use RabbitMQ external broker
        registry.enableSimpleBroker("/topic", "/queue");
        registry.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(channelInterceptor);
    }
}
