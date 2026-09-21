package com.nimbus.kernel.infrastructure.config;

import io.swagger.v3.oas.models.*;
import io.swagger.v3.oas.models.info.*;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.*;

import java.util.List;

/**
 * OpenAPI 3.0 documentation configuration.
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Nimbus Commuter Ride-Pooling API")
                        .description("API for Bangladesh commuter ride-pooling platform")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Nimbus Team")
                                .email("dev@nimbus.example.com"))
                        .license(new License()
                                .name("Proprietary")
                                .url("https://nimbus.example.com")))
                .servers(List.of(
                        new io.swagger.v3.oas.models.servers.Server()
                                .url("https://api.nimbus.example.com")
                                .description("Production"),
                        new io.swagger.v3.oas.models.servers.Server()
                                .url("https://staging-api.nimbus.example.com")
                                .description("Staging"),
                        new io.swagger.v3.oas.models.servers.Server()
                                .url("http://localhost:8080")
                                .description("Local")
                ));
    }

    @Bean
    public GroupedOpenApi publicApi() {
        return GroupedOpenApi.builder()
                .group("public")
                .pathsToMatch("/auth/**", "/v3/api-docs/**", "/swagger-ui/**")
                .build();
    }

    @Bean
    public GroupedOpenApi authenticatedApi() {
        return GroupedOpenApi.builder()
                .group("authenticated")
                .pathsToMatch("/me/**", "/rides/**", "/bookings/**", "/payments/**")
                .build();
    }
}