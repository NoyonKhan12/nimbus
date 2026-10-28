package com.nimbus.driver.application.service;

import com.nimbus.driver.domain.entity.*;
import com.nimbus.driver.domain.repository.*;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * Unified driver eligibility service (guide §5).
 *
 * <p>Driver eligibility requires ALL of:
 * <ul>
 *   <li>Active account (not banned/suspended)</li>
 *   <li>Approved driver profile, not suspended</li>
 *   <li>An approved ACTIVE vehicle with positive capacity</li>
 *   <li>Valid required driver documents (verified, unexpired) and a
 *       valid registration document on the active vehicle</li>
 *   <li>No suspension/ban</li>
 *   <li>Zero previous due</li>
 * </ul>
 *
 * <p>Every eligibility-sensitive flow (ride create/publish, driver
 * self-check, matching hard constraint, admin operations) consults this
 * single implementation so the rules can never drift apart. Confirmed
 * rides are NOT silently cancelled when eligibility later changes — that
 * reassignment path belongs to operations (guide §5).</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DriverEligibilityService {

    private final UserRepository userRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final VehicleRepository vehicleRepository;
    private final DriverDocumentRepository driverDocumentRepository;
    private final VehicleDocumentRepository vehicleDocumentRepository;

    /**
     * Detailed eligibility result — reasons are human-readable and safe to
     * surface to the driver.
     */
    public record EligibilityResult(boolean eligible, List<String> reasons) {
        public String primaryReason() {
            return reasons.isEmpty() ? null : reasons.get(0);
        }
    }

    /** Full evaluation of every guide §5 rule for the user as a driver. */
    @Transactional(readOnly = true)
    public EligibilityResult check(UUID userId) {
        List<String> reasons = new ArrayList<>();

        // 1. Active account
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return new EligibilityResult(false, List.of("Account not found"));
        }
        if (!user.isActive()) {
            reasons.add("Account is not active");
        }

        // 2. Approved driver profile, not suspended/banned
        DriverProfile profile = driverProfileRepository.findByUserId(userId).orElse(null);
        if (profile == null) {
            reasons.add("No driver profile");
            return new EligibilityResult(false, reasons);
        }
        if (profile.getApprovalStatus() != DriverProfile.ApprovalStatus.APPROVED) {
            reasons.add("Driver approval status is " + profile.getApprovalStatus());
        }

        // 3. Approved ACTIVE vehicle with capacity
        Vehicle activeVehicle = vehicleRepository.findByDriverId(profile.getId()).stream()
                .filter(v -> v.getStatus() == Vehicle.VehicleStatus.APPROVED)
                .filter(v -> v.getSeatCapacity() != null && v.getSeatCapacity() > 0)
                .findFirst()
                .orElse(null);
        if (activeVehicle == null) {
            reasons.add("No approved active vehicle");
        }

        // 4. Valid required documents
        List<DriverDocument> docs = driverDocumentRepository.findByDriverId(profile.getId());
        boolean hasLicense = docs.stream()
                .anyMatch(d -> d.getDocumentType() == DriverDocument.DocumentType.DRIVER_LICENSE && d.isValid());
        boolean hasNationalId = docs.stream()
                .anyMatch(d -> d.getDocumentType() == DriverDocument.DocumentType.NATIONAL_ID && d.isValid());
        if (!hasLicense) reasons.add("No valid (approved, unexpired) driver license document");
        if (!hasNationalId) reasons.add("No valid (approved, unexpired) national ID document");
        if (profile.getLicenseExpiry() != null
                && profile.getLicenseExpiry().isBefore(java.time.Instant.now())) {
            reasons.add("Driver license has expired");
        }
        if (activeVehicle != null) {
            boolean vehicleDocsValid = vehicleDocumentRepository.findByVehicleId(activeVehicle.getId())
                    .stream()
                    .filter(d -> d.getDocumentType() == VehicleDocument.DocumentType.REGISTRATION)
                    .allMatch(VehicleDocument::isValid);
            boolean hasRegistration = vehicleDocumentRepository.findByVehicleId(activeVehicle.getId())
                    .stream()
                    .anyMatch(d -> d.getDocumentType() == VehicleDocument.DocumentType.REGISTRATION
                            && d.isValid());
            if (!hasRegistration) {
                reasons.add("Vehicle registration document missing or not valid");
            } else if (!vehicleDocsValid) {
                reasons.add("Vehicle registration document has expired");
            }
        }

        // 6. Zero previous due (previous-day due blocks new eligibility)
        if (profile.getDueAmount() != null
                && profile.getDueAmount().compareTo(java.math.BigDecimal.ZERO) > 0) {
            reasons.add("Outstanding due of " + profile.getDueAmount()
                    + " BDT must be cleared before driving");
        }

        return new EligibilityResult(reasons.isEmpty(), reasons);
    }

    /** Boolean form used by the driver self-check endpoint. */
    @Transactional(readOnly = true)
    public boolean isEligible(UUID userId) {
        return check(userId).eligible();
    }

    /**
     * Throws the appropriate NimbusException when the user may not drive —
     * used by ride create/publish flows.
     */
    @Transactional(readOnly = true)
    public void assertEligible(UUID userId) {
        EligibilityResult result = check(userId);
        if (result.eligible()) {
            return;
        }
        String reason = result.primaryReason();
        log.debug("Driver {} not eligible: {}", userId, result.reasons());
        if (reason != null && reason.contains("No driver profile")) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.DRIVER_NOT_FOUND,
                    org.springframework.http.HttpStatus.NOT_FOUND);
        }
        if (reason != null && reason.contains("not active")) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.AUTH_UNAUTHORIZED,
                    "Account is not active",
                    org.springframework.http.HttpStatus.FORBIDDEN);
        }
        if (reason != null && reason.contains("approval status is PENDING")) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.DRIVER_NOT_APPROVED,
                    "Driver must be approved before creating rides",
                    org.springframework.http.HttpStatus.FORBIDDEN);
        }
        if (reason != null && reason.contains("Outstanding due")) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.DRIVER_DUE_PENDING,
                    reason,
                    org.springframework.http.HttpStatus.FORBIDDEN);
        }
        if (reason != null && reason.contains("expired")) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.DRIVER_DOCUMENT_EXPIRED,
                    reason,
                    org.springframework.http.HttpStatus.FORBIDDEN);
        }
        throw new com.nimbus.kernel.domain.exception.NimbusException(
                com.nimbus.kernel.domain.ErrorCode.DRIVER_NOT_ELIGIBLE,
                reason != null ? reason : "Driver is not eligible",
                org.springframework.http.HttpStatus.FORBIDDEN);
    }

    /** Eligibility of one specific vehicle (used by ride publish). */
    @Transactional(readOnly = true)
    public boolean isVehicleEligible(UUID vehicleId) {
        return vehicleRepository.findById(vehicleId)
                .map(Vehicle::isEligible)
                .orElse(false);
    }
}
