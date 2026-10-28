package com.nimbus.driver.application;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

/**
 * Vehicle document response — flat DTO so lazy associations are never
 * serialized (returning raw entities blew up on Hibernate proxies).
 */
@Getter
@Builder
public class VehicleDocumentResponse {
    private UUID id;
    private UUID vehicleId;
    private String documentType;
    private String documentNumber;
    private String status;
    private boolean verified;
    private Instant expiresAt;
    private String documentUrl;
    private Instant createdAt;
}
