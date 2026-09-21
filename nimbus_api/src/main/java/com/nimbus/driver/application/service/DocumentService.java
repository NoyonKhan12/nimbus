package com.nimbus.driver.application.service;

import com.nimbus.driver.domain.entity.DriverDocument;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.entity.VehicleDocument;
import com.nimbus.driver.domain.repository.DriverDocumentRepository;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.driver.domain.repository.VehicleDocumentRepository;
import com.nimbus.driver.domain.repository.VehicleRepository;
import com.nimbus.driver.domain.entity.Vehicle;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.kernel.domain.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Driver document management service.
 *
 * <p>Handles document upload, verification workflow, and eligibility checks.
 * Documents are stored in object storage (S3/GCS) with metadata in the database.
 * Verification is performed by the operations team.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DocumentService {

    private final DriverDocumentRepository driverDocumentRepository;
    private final VehicleDocumentRepository vehicleDocumentRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;

    /**
     * Upload a driver document.
     * In production, this would integrate with an object storage service.
     */
    @Transactional
    public DriverDocument uploadDriverDocument(UUID userId, DriverDocument.DocumentType type,
                                               String documentNumber, Instant expiresAt,
                                               String documentUrl) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        DriverProfile driver = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        DriverDocument document = DriverDocument.builder()
                .driver(driver)
                .documentType(type)
                .documentNumber(documentNumber)
                .status(DriverDocument.DocumentStatus.PENDING)
                .expiresAt(expiresAt)
                .verified(false)
                .documentUrl(documentUrl)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        DriverDocument saved = driverDocumentRepository.save(document);
        log.info("Driver document uploaded: {} type: {}", saved.getId(), type);

        return saved;
    }

    /**
     * List driver's documents.
     */
    @Transactional(readOnly = true)
    public List<DriverDocument> getDriverDocuments(UUID userId) {
        DriverProfile driver = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        return driverDocumentRepository.findByDriverId(driver.getId());
    }

    /**
     * Update document verification status (admin/operations only).
     */
    @Transactional
    public void verifyDocument(UUID documentId, boolean approved, String rejectionReason) {
        DriverDocument document = driverDocumentRepository.findById(documentId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));

        document.setStatus(approved ? DriverDocument.DocumentStatus.APPROVED : DriverDocument.DocumentStatus.REJECTED);
        document.setVerified(approved);
        document.setUpdatedAt(Instant.now());

        driverDocumentRepository.save(document);
        log.info("Document {} verification: {}", documentId, approved ? "APPROVED" : "REJECTED");
    }

    /**
     * Upload a vehicle document.
     */
    @Transactional
    public VehicleDocument uploadVehicleDocument(UUID vehicleId, VehicleDocument.DocumentType type,
                                                  String documentNumber, Instant expiresAt,
                                                  String documentUrl) {
        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND));

        VehicleDocument document = VehicleDocument.builder()
                .vehicle(vehicle)
                .documentType(type)
                .documentNumber(documentNumber)
                .status(VehicleDocument.DocumentStatus.PENDING)
                .expiresAt(expiresAt)
                .verified(false)
                .documentUrl(documentUrl)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        VehicleDocument saved = vehicleDocumentRepository.save(document);
        log.info("Vehicle document uploaded: {} type: {}", saved.getId(), type);

        return saved;
    }

    /**
     * List vehicle's documents.
     */
    @Transactional(readOnly = true)
    public List<VehicleDocument> getVehicleDocuments(UUID vehicleId) {
        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND));

        return vehicleDocumentRepository.findByVehicleId(vehicle.getId());
    }

    /**
     * Check if driver has all required documents verified.
     */
    @Transactional(readOnly = true)
    public boolean hasRequiredDocumentsVerified(UUID userId) {
        DriverProfile driver = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        List<DriverDocument> documents = driverDocumentRepository.findByDriverId(driver.getId());

        // Check for required document types
        Set<DriverDocument.DocumentType> requiredTypes = Set.of(
                DriverDocument.DocumentType.DRIVER_LICENSE,
                DriverDocument.DocumentType.NATIONAL_ID
        );

        return documents.stream()
                .filter(doc -> requiredTypes.contains(doc.getDocumentType()))
                .allMatch(doc -> doc.isValid());
    }
}
