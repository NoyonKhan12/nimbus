package com.nimbus.driver.application;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/**
 * Driver document response — flat DTO so lazy associations are never
 * serialized (returning raw entities blew up on Hibernate proxies).
 */
@Getter
@Builder
public class DriverDocumentResponse {
    private UUID id;
    private String documentType;
    private String documentNumber;
    private String status;
    private boolean verified;
    private Instant expiresAt;
    private String documentUrl;
    private Instant createdAt;
}
