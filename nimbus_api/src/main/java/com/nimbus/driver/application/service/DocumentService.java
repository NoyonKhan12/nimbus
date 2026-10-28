package com.nimbus.driver.application.service;

import com.nimbus.driver.application.DriverDocumentResponse;
import com.nimbus.driver.application.VehicleDocumentResponse;
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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

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
    private final com.nimbus.audit.application.service.AuditService auditService;
    private final DocumentStorageService documentStorageService;

    @Value("${server.servlet.context-path:}")
    private String contextPath;

    /**
     * Upload a driver document.
     * In production, this would integrate with an object storage service.
     */
    @Transactional
    public DriverDocumentResponse uploadDriverDocument(UUID userId, DriverDocument.DocumentType type,
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

        return toDriverDocumentResponse(saved);
    }

    /**
     * List driver's documents.
     */
    @Transactional(readOnly = true)
    public List<DriverDocumentResponse> getDriverDocuments(UUID userId) {
        DriverProfile driver = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        return driverDocumentRepository.findByDriverId(driver.getId()).stream()
                .map(this::toDriverDocumentResponse)
                .collect(Collectors.toList());
    }

    /**
     * Upload a driver document with its file in one request. The file is
     * stored outside the web root; the response URL points at an
     * ownership-checked download endpoint.
     */
    @Transactional
    public DriverDocumentResponse uploadDriverDocumentFile(UUID userId,
                                                           DriverDocument.DocumentType type,
                                                           String documentNumber,
                                                           Instant expiresAt,
                                                           MultipartFile file) {
        DriverProfile driver = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        DocumentStorageService.StoredDocument stored = documentStorageService.store(file);
        try {
            DriverDocument document = DriverDocument.builder()
                    .driver(driver)
                    .documentType(type)
                    .documentNumber(documentNumber)
                    .status(DriverDocument.DocumentStatus.PENDING)
                    .expiresAt(expiresAt)
                    .verified(false)
                    .storageKey(stored.key())
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();
            DriverDocument saved = driverDocumentRepository.save(document);
            saved.setDocumentUrl(driverDocumentFileUrl(saved.getId()));
            saved = driverDocumentRepository.save(saved);
            log.info("Driver document file uploaded: {} type: {}", saved.getId(), type);
            return toDriverDocumentResponse(saved);
        } catch (RuntimeException e) {
            documentStorageService.deleteQuietly(stored.key());
            throw e;
        }
    }

    /** Download a driver document if the caller owns it or is staff. */
    @Transactional(readOnly = true)
    public DocumentFile getDriverDocumentFile(UUID documentId, UUID userId, boolean staff) {
        DriverDocument document = driverDocumentRepository.findById(documentId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));
        if (!staff && (document.getDriver() == null
                || document.getDriver().getUser() == null
                || !document.getDriver().getUser().getId().equals(userId))) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        String key = document.getStorageKey();
        return new DocumentFile(documentStorageService.load(key),
                documentStorageService.contentType(key));
    }

    private String driverDocumentFileUrl(UUID documentId) {
        return contextPath + "/drivers/documents/" + documentId + "/file";
    }

    private DriverDocumentResponse toDriverDocumentResponse(DriverDocument doc) {
        return DriverDocumentResponse.builder()
                .id(doc.getId())
                .documentType(doc.getDocumentType() != null ? doc.getDocumentType().name() : null)
                .documentNumber(doc.getDocumentNumber())
                .status(doc.getStatus() != null ? doc.getStatus().name() : null)
                .verified(doc.isVerified())
                .expiresAt(doc.getExpiresAt())
                .documentUrl(doc.getDocumentUrl())
                .createdAt(doc.getCreatedAt())
                .build();
    }

    private VehicleDocumentResponse toVehicleDocumentResponse(VehicleDocument doc) {
        return VehicleDocumentResponse.builder()
                .id(doc.getId())
                .vehicleId(doc.getVehicle() != null ? doc.getVehicle().getId() : null)
                .documentType(doc.getDocumentType() != null ? doc.getDocumentType().name() : null)
                .documentNumber(doc.getDocumentNumber())
                .status(doc.getStatus() != null ? doc.getStatus().name() : null)
                .verified(doc.isVerified())
                .expiresAt(doc.getExpiresAt())
                .documentUrl(doc.getDocumentUrl())
                .createdAt(doc.getCreatedAt())
                .build();
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
        auditService.logAction(currentUserIdOrNull(), "DRIVER_DOCUMENT_VERIFIED", "DRIVER_DOCUMENT",
                documentId, null, approved ? "APPROVED" : "REJECTED");
        log.info("Document {} verification: {}", documentId, approved ? "APPROVED" : "REJECTED");
    }

    private UUID currentUserIdOrNull() {
        var auth = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }

    /**
     * Verify a vehicle document (admin/operations only) — approval feeds
     * the vehicle-document leg of driver eligibility (guide §5).
     */
    @Transactional
    public VehicleDocumentResponse verifyVehicleDocument(UUID documentId, boolean approved,
                                                         String rejectionReason) {
        VehicleDocument document = vehicleDocumentRepository.findById(documentId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));

        document.setStatus(approved ? VehicleDocument.DocumentStatus.APPROVED
                                    : VehicleDocument.DocumentStatus.REJECTED);
        document.setVerified(approved);
        document.setUpdatedAt(Instant.now());

        vehicleDocumentRepository.save(document);
        auditService.logAction(currentUserIdOrNull(), "VEHICLE_DOCUMENT_VERIFIED", "VEHICLE_DOCUMENT",
                documentId, null, approved ? "APPROVED" : "REJECTED");
        log.info("Vehicle document {} verification: {}", documentId, approved ? "APPROVED" : "REJECTED");
        return toVehicleDocumentResponse(document);
    }

    /**
     * Upload a vehicle document.
     */
    @Transactional
    public VehicleDocumentResponse uploadVehicleDocument(UUID vehicleId, UUID userId,
                                                         VehicleDocument.DocumentType type,
                                                         String documentNumber, Instant expiresAt,
                                                         String documentUrl) {
        Vehicle vehicle = requireOwnedVehicle(vehicleId, userId);

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

        return toVehicleDocumentResponse(saved);
    }

    /** Upload a vehicle document with its file in one request. */
    @Transactional
    public VehicleDocumentResponse uploadVehicleDocumentFile(UUID vehicleId, UUID userId,
                                                             VehicleDocument.DocumentType type,
                                                             String documentNumber,
                                                             Instant expiresAt,
                                                             MultipartFile file) {
        Vehicle vehicle = requireOwnedVehicle(vehicleId, userId);

        DocumentStorageService.StoredDocument stored = documentStorageService.store(file);
        try {
            VehicleDocument document = VehicleDocument.builder()
                    .vehicle(vehicle)
                    .documentType(type)
                    .documentNumber(documentNumber)
                    .status(VehicleDocument.DocumentStatus.PENDING)
                    .expiresAt(expiresAt)
                    .verified(false)
                    .storageKey(stored.key())
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();
            VehicleDocument saved = vehicleDocumentRepository.save(document);
            saved.setDocumentUrl(vehicleDocumentFileUrl(vehicleId, saved.getId()));
            saved = vehicleDocumentRepository.save(saved);
            log.info("Vehicle document file uploaded: {} type: {}", saved.getId(), type);
            return toVehicleDocumentResponse(saved);
        } catch (RuntimeException e) {
            documentStorageService.deleteQuietly(stored.key());
            throw e;
        }
    }

    /** Download a vehicle document if the caller owns the vehicle or is staff. */
    @Transactional(readOnly = true)
    public DocumentFile getVehicleDocumentFile(UUID vehicleId, UUID documentId,
                                               UUID userId, boolean staff) {
        VehicleDocument document = vehicleDocumentRepository.findById(documentId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND));
        if (document.getVehicle() == null
                || !document.getVehicle().getId().equals(vehicleId)) {
            throw new NimbusException(ErrorCode.NOT_FOUND, HttpStatus.NOT_FOUND);
        }
        if (!staff && (document.getVehicle().getDriver() == null
                || document.getVehicle().getDriver().getUser() == null
                || !document.getVehicle().getDriver().getUser().getId().equals(userId))) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        String key = document.getStorageKey();
        return new DocumentFile(documentStorageService.load(key),
                documentStorageService.contentType(key));
    }

    private String vehicleDocumentFileUrl(UUID vehicleId, UUID documentId) {
        return contextPath + "/drivers/vehicles/" + vehicleId
                + "/documents/" + documentId + "/file";
    }

    /**
     * List a vehicle's documents. Only the owning driver or staff may read
     * them; previously any authenticated user could enumerate another
     * driver's registration and insurance files.
     */
    @Transactional(readOnly = true)
    public List<VehicleDocumentResponse> getVehicleDocuments(UUID vehicleId, UUID userId,
                                                             boolean staff) {
        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND));
        if (!staff && (vehicle.getDriver() == null
                || vehicle.getDriver().getUser() == null
                || !vehicle.getDriver().getUser().getId().equals(userId))) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        return vehicleDocumentRepository.findByVehicleId(vehicle.getId()).stream()
                .map(this::toVehicleDocumentResponse)
                .collect(Collectors.toList());
    }

    private Vehicle requireOwnedVehicle(UUID vehicleId, UUID userId) {
        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND));
        if (vehicle.getDriver() == null || vehicle.getDriver().getUser() == null
                || !vehicle.getDriver().getUser().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        return vehicle;
    }

    /** Authenticated document payload with the content type we detected. */
    public record DocumentFile(Resource resource, String contentType) {
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
