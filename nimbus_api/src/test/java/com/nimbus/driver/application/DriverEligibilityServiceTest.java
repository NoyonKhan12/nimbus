package com.nimbus.driver.application;

import com.nimbus.driver.application.service.DriverEligibilityService;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.entity.DriverDocument;
import com.nimbus.driver.domain.entity.Vehicle;
import com.nimbus.driver.domain.repository.DriverDocumentRepository;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.driver.domain.repository.VehicleDocumentRepository;
import com.nimbus.driver.domain.repository.VehicleRepository;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

/**
 * Unit tests for the unified driver eligibility rules (guide §5):
 * active account, approved driver, approved active vehicle, valid
 * documents, no suspension, zero due.
 */
@ExtendWith(MockitoExtension.class)
class DriverEligibilityServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private DriverProfileRepository driverProfileRepository;
    @Mock private VehicleRepository vehicleRepository;
    @Mock private DriverDocumentRepository driverDocumentRepository;
    @Mock private VehicleDocumentRepository vehicleDocumentRepository;

    @InjectMocks
    private DriverEligibilityService service;

    private final UUID userId = UUID.randomUUID();
    private final UUID driverId = UUID.randomUUID();

    private User activeUser() {
        return User.builder().id(userId).status(User.UserStatus.ACTIVE).build();
    }

    private DriverProfile approvedDriver() {
        return DriverProfile.builder()
                .id(driverId)
                .user(activeUser())
                .approvalStatus(DriverProfile.ApprovalStatus.APPROVED)
                .driverStatus(DriverProfile.DriverStatus.ONLINE)
                .dueAmount(BigDecimal.ZERO)
                .licenseExpiry(Instant.now().plusSeconds(86400 * 365))
                .build();
    }

    private Vehicle approvedVehicle() {
        return Vehicle.builder()
                .id(UUID.randomUUID())
                .status(Vehicle.VehicleStatus.APPROVED)
                .seatCapacity(4)
                .build();
    }

    private com.nimbus.driver.domain.entity.VehicleDocument validRegistration() {
        return com.nimbus.driver.domain.entity.VehicleDocument.builder()
                .documentType(com.nimbus.driver.domain.entity.VehicleDocument.DocumentType.REGISTRATION)
                .status(com.nimbus.driver.domain.entity.VehicleDocument.DocumentStatus.APPROVED)
                .expiresAt(Instant.now().plusSeconds(86400))
                .build();
    }

    private DriverDocument validDoc(DriverDocument.DocumentType type) {
        return DriverDocument.builder()
                .documentType(type)
                .status(DriverDocument.DocumentStatus.APPROVED)
                .expiresAt(Instant.now().plusSeconds(86400))
                .build();
    }

    @Test
    void eligibleDriver_passesAllChecks() {
        when(userRepository.findById(userId)).thenReturn(Optional.of(activeUser()));
        when(driverProfileRepository.findByUserId(userId)).thenReturn(Optional.of(approvedDriver()));
        when(vehicleRepository.findByDriverId(driverId)).thenReturn(List.of(approvedVehicle()));
        when(driverDocumentRepository.findByDriverId(driverId)).thenReturn(List.of(
                validDoc(DriverDocument.DocumentType.DRIVER_LICENSE),
                validDoc(DriverDocument.DocumentType.NATIONAL_ID)));
        when(vehicleDocumentRepository.findByVehicleId(any()))
                .thenReturn(List.of(validRegistration()));

        var result = service.check(userId);

        assertTrue(result.eligible(), () -> "expected eligible, reasons: " + result.reasons());
    }

    @Test
    void inactiveAccount_isIneligible() {
        when(userRepository.findById(userId)).thenReturn(Optional.of(
                User.builder().id(userId).status(User.UserStatus.BANNED).build()));
        when(driverProfileRepository.findByUserId(userId)).thenReturn(Optional.of(approvedDriver()));
        when(vehicleRepository.findByDriverId(driverId)).thenReturn(List.of());
        when(driverDocumentRepository.findByDriverId(driverId)).thenReturn(List.of());

        var result = service.check(userId);

        assertFalse(result.eligible());
        assertTrue(result.reasons().stream().anyMatch(r -> r.contains("not active")));
    }

    @Test
    void suspendedDriver_isIneligible() {
        DriverProfile suspended = approvedDriver();
        suspended.setApprovalStatus(DriverProfile.ApprovalStatus.SUSPENDED);
        when(userRepository.findById(userId)).thenReturn(Optional.of(activeUser()));
        when(driverProfileRepository.findByUserId(userId)).thenReturn(Optional.of(suspended));
        when(vehicleRepository.findByDriverId(driverId)).thenReturn(List.of());
        when(driverDocumentRepository.findByDriverId(driverId)).thenReturn(List.of());

        var result = service.check(userId);

        assertFalse(result.eligible());
        assertTrue(result.reasons().stream().anyMatch(r -> r.contains("SUSPENDED")));
    }

    @Test
    void outstandingDue_isIneligible() {
        DriverProfile withDue = approvedDriver();
        withDue.setDueAmount(BigDecimal.valueOf(150));
        when(userRepository.findById(userId)).thenReturn(Optional.of(activeUser()));
        when(driverProfileRepository.findByUserId(userId)).thenReturn(Optional.of(withDue));
        when(vehicleRepository.findByDriverId(driverId)).thenReturn(List.of(approvedVehicle()));
        when(driverDocumentRepository.findByDriverId(driverId)).thenReturn(List.of(
                validDoc(DriverDocument.DocumentType.DRIVER_LICENSE),
                validDoc(DriverDocument.DocumentType.NATIONAL_ID)));
        when(vehicleDocumentRepository.findByVehicleId(any()))
                .thenReturn(List.of(validRegistration()));

        var result = service.check(userId);

        assertFalse(result.eligible());
        assertTrue(result.reasons().stream().anyMatch(r -> r.contains("Outstanding due")));
    }

    @Test
    void unverifiedOrMissingDocuments_areIneligible() {
        when(userRepository.findById(userId)).thenReturn(Optional.of(activeUser()));
        when(driverProfileRepository.findByUserId(userId)).thenReturn(Optional.of(approvedDriver()));
        when(vehicleRepository.findByDriverId(driverId)).thenReturn(List.of(approvedVehicle()));
        // Pending (unverified) license document is not valid.
        when(driverDocumentRepository.findByDriverId(driverId)).thenReturn(List.of(
                DriverDocument.builder()
                        .documentType(DriverDocument.DocumentType.DRIVER_LICENSE)
                        .status(DriverDocument.DocumentStatus.PENDING)
                        .expiresAt(Instant.now().plusSeconds(86400))
                        .build()));

        var result = service.check(userId);

        assertFalse(result.eligible());
        assertTrue(result.reasons().stream().anyMatch(r -> r.contains("national ID")));
    }

    @Test
    void assertEligible_throwsForPendingApproval() {
        DriverProfile pending = approvedDriver();
        pending.setApprovalStatus(DriverProfile.ApprovalStatus.PENDING);
        when(userRepository.findById(userId)).thenReturn(Optional.of(activeUser()));
        when(driverProfileRepository.findByUserId(userId)).thenReturn(Optional.of(pending));
        when(vehicleRepository.findByDriverId(driverId)).thenReturn(List.of());
        when(driverDocumentRepository.findByDriverId(driverId)).thenReturn(List.of());

        NimbusException ex = assertThrows(NimbusException.class,
                () -> service.assertEligible(userId));

        assertEquals(com.nimbus.kernel.domain.ErrorCode.DRIVER_NOT_APPROVED, ex.getErrorCode());
    }
}
