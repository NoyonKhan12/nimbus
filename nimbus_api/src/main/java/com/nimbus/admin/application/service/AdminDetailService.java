package com.nimbus.admin.application.service;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.driver.domain.entity.DriverDocument;
import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.entity.Vehicle;
import com.nimbus.driver.domain.entity.VehicleDocument;
import com.nimbus.driver.domain.repository.DriverDocumentRepository;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.driver.domain.repository.VehicleDocumentRepository;
import com.nimbus.driver.domain.repository.VehicleRepository;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.entity.UserDevice;
import com.nimbus.kernel.domain.entity.UserProfile;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.kernel.domain.repository.UserProfileRepository;
import com.nimbus.kernel.domain.repository.UserDeviceRepository;
import com.nimbus.payment.domain.entity.Payment;
import com.nimbus.payment.domain.repository.PaymentRepository;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.entity.RidePassenger;
import com.nimbus.ride.domain.repository.RideRepository;
import com.nimbus.wallet.domain.entity.Wallet;
import com.nimbus.wallet.domain.repository.WalletRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

/**
 * Aggregate detail views behind the admin list tables: user, driver, vehicle
 * and ride details assembled from multiple repositories in one place.
 */
@Service
@Slf4j
public class AdminDetailService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserDeviceRepository userDeviceRepository;
    private final WalletRepository walletRepository;
    private final DriverProfileRepository driverRepository;
    private final DriverDocumentRepository driverDocumentRepository;
    private final VehicleRepository vehicleRepository;
    private final VehicleDocumentRepository vehicleDocumentRepository;
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;
    private final com.nimbus.settlement.domain.repository.SettlementRepository settlementRepository;
    private final com.nimbus.complaint.domain.repository.ComplaintRepository complaintRepository;
    private final com.nimbus.safety.domain.repository.SafetyEventRepository safetyEventRepository;

    public AdminDetailService(UserRepository userRepository,
                              UserProfileRepository userProfileRepository,
                              UserDeviceRepository userDeviceRepository,
                              WalletRepository walletRepository,
                              DriverProfileRepository driverRepository,
                              DriverDocumentRepository driverDocumentRepository,
                              VehicleRepository vehicleRepository,
                              VehicleDocumentRepository vehicleDocumentRepository,
                              RideRepository rideRepository,
                              BookingRepository bookingRepository,
                              PaymentRepository paymentRepository,
                              com.nimbus.settlement.domain.repository.SettlementRepository settlementRepository,
                              com.nimbus.complaint.domain.repository.ComplaintRepository complaintRepository,
                              com.nimbus.safety.domain.repository.SafetyEventRepository safetyEventRepository) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.userDeviceRepository = userDeviceRepository;
        this.walletRepository = walletRepository;
        this.driverRepository = driverRepository;
        this.driverDocumentRepository = driverDocumentRepository;
        this.vehicleRepository = vehicleRepository;
        this.vehicleDocumentRepository = vehicleDocumentRepository;
        this.rideRepository = rideRepository;
        this.bookingRepository = bookingRepository;
        this.paymentRepository = paymentRepository;
        this.settlementRepository = settlementRepository;
        this.complaintRepository = complaintRepository;
        this.safetyEventRepository = safetyEventRepository;
    }

    // ── DTOs ─────────────────────────────────────────────────────────────

    /** GET /admin/users/{id} — full user detail incl. profile + wallet. */
    public record UserDetail(
            UUID id, String phone, String email, String status, String role,
            boolean phoneVerified, Instant createdAt,
            Profile profile, WalletInfo wallet, int deviceCount) {
        public record Profile(String firstName, String lastName, String gender,
                              String emergencyContactName, String emergencyContactPhone,
                              String profilePhotoUrl) {}
        public record WalletInfo(BigDecimal balance, String currency, String ownerType) {}
    }

    /** GET /admin/drivers/{id} — full driver detail incl. vehicles + documents. */
    public record DriverDetail(
            UUID id, UUID userId, String phone, String email,
            String approvalStatus, String driverStatus,
            String licenseNumber, Instant licenseExpiry,
            BigDecimal rating, BigDecimal reliabilityScore,
            String currentLocation, Instant currentLocationUpdatedAt,
            Integer totalRides, BigDecimal totalEarnings, BigDecimal dueAmount,
            BigDecimal commissionRate, Instant createdAt,
            Profile profile,
            List<VehicleRow> vehicles, List<DocumentRow> documents) {
        public record Profile(String firstName, String lastName, String email) {}
        public record VehicleRow(UUID id, String registrationNumber, String type,
                                 String model, Integer year, String color,
                                 Integer seatCapacity, String status) {}
        public record DocumentRow(String documentType, String documentNumber,
                                  String status, Instant expiresAt, boolean verified,
                                  String documentUrl) {}
    }

    /** GET /admin/vehicles/{id} — full vehicle detail incl. documents + owner. */
    public record VehicleDetail(
            UUID id, UUID driverId, String driverName, String driverPhone,
            String registrationNumber, String type, String model, Integer year,
            String color, Integer seatCapacity, String status,
            Instant createdAt, List<DriverDetail.DocumentRow> documents) {}

    /** GET /admin/rides/{id} — full ride detail incl. passengers, bookings, payment. */
    public record RideDetail(
            UUID id, String status, String type,
            UUID driverId, String driverName, String driverPhone,
            UUID creatorId, String creatorName, String creatorPhone,
            String vehicleRegistration,
            String originAddress, String destinationAddress,
            Instant scheduledAt, Instant actualStartAt, Instant actualEndAt,
            Integer availableSeats, Integer maxDetourMeters,
            String notes, Instant createdAt,
            List<PassengerRow> passengers,
            List<BookingRow> bookings,
            PaymentRow payment) {
        public record PassengerRow(UUID id, UUID passengerId, UUID userId, String passengerName,
                                   String passengerPhone, Integer seats, String journeyStatus,
                                   Instant createdAt) {}
        public record BookingRow(UUID id, Integer seats, String status, String pickupAddress,
                                 String dropoffAddress, BigDecimal finalPayable,
                                 Instant pickupPlannedTime, String pickupLocation,
                                 String dropoffLocation, Instant createdAt) {}
        public record PaymentRow(UUID id, BigDecimal amount, String method, String status,
                                 String providerReference, Instant createdAt) {}
    }

    /** GET /admin/payments/{id} — payment detail with booking context + payer. */
    public record PaymentDetail(
            UUID id, UUID bookingId, UUID rideId, UUID payerId,
            String payerName, String payerPhone,
            java.math.BigDecimal amount, String method, String status,
            String providerReference, String idempotencyKey,
            String pickupAddress, String dropoffAddress,
            Instant createdAt, Instant updatedAt) {}

    /** GET /admin/settlements/{id} — settlement detail with driver info + full period math. */
    public record SettlementDetail(
            UUID id, UUID driverId, String driverName, String driverPhone,
            Instant periodStart, Instant periodEnd,
            java.math.BigDecimal grossEarnings, java.math.BigDecimal commission,
            java.math.BigDecimal adjustments, java.math.BigDecimal refunds,
            java.math.BigDecimal driverCredits, java.math.BigDecimal payable,
            String status, String paymentReference,
            Instant createdAt, Instant updatedAt) {}

    /** GET /admin/complaints/{id} — complaint detail with passenger + booking + ride links. */
    public record ComplaintDetail(
            UUID id, String category, String status, String description, String resolution,
            UUID passengerId, String passengerName, String passengerPhone,
            UUID bookingId, UUID rideId,
            Instant createdAt, Instant updatedAt) {}

    /** GET /admin/safety/{id} — safety event detail with participants + coordinates. */
    public record SafetyDetail(
            UUID id, String eventType, String status,
            UUID userId, String userName, String userPhone,
            UUID driverId, String driverName, String driverPhone,
            UUID rideId, UUID vehicleId, String vehicleRegistration,
            java.math.BigDecimal latitude, java.math.BigDecimal longitude,
            String description, String shareToken, Instant expiresAt,
            Instant createdAt, Instant updatedAt) {}

    // ── Queries ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public UserDetail getUserDetail(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("User not found"));
        UserProfile profile = userProfileRepository.findByUserId(id).orElse(null);
        Wallet wallet = walletRepository.findByOwnerId(id).orElse(null);
        List<UserDevice> devices = userDeviceRepository.findByUserId(id);

        return new UserDetail(
                user.getId(), user.getPhone(), user.getEmail(),
                user.getStatus() != null ? user.getStatus().name() : null,
                user.getRole(),
                Boolean.TRUE.equals(user.isPhoneVerified()),
                user.getCreatedAt(),
                profile == null ? null : new UserDetail.Profile(
                        profile.getFirstName(), profile.getLastName(),
                        profile.getGender() != null ? profile.getGender().name() : null,
                        profile.getEmergencyContactName(), profile.getEmergencyContactPhone(),
                        profile.getProfilePhotoUrl()),
                wallet == null ? null : new UserDetail.WalletInfo(
                        wallet.getBalance(), wallet.getCurrency(),
                        wallet.getOwnerType() != null ? wallet.getOwnerType().name() : null),
                devices.size());
    }

    @Transactional(readOnly = true)
    public DriverDetail getDriverDetail(UUID driverProfileId) {
        DriverProfile driver = driverRepository.findById(driverProfileId)
                .orElseThrow(() -> new NoSuchElementException("Driver not found"));
        UserSnapshot user = snapshotUser(driver.getUser());
        UUID userId = user != null ? user.id() : null;
        UserProfile profile = userId != null ? userProfileRepository.findByUserId(userId).orElse(null) : null;

        // vehicle.driver is a FK to DriverProfile — look up by the driver's profile id.
        List<Vehicle> vehicles = vehicleRepository.findByDriverId(driverProfileId);

        List<DriverDocument> docs = driverDocumentRepository.findByDriverId(driverProfileId);

        return new DriverDetail(
                driver.getId(), userId,
                user != null ? user.phone() : null,
                user != null ? user.email() : null,
                driver.getApprovalStatus() != null ? driver.getApprovalStatus().name() : null,
                driver.getDriverStatus() != null ? driver.getDriverStatus().name() : null,
                driver.getLicenseNumber(), driver.getLicenseExpiry(),
                driver.getRating(), driver.getReliabilityScore(),
                driver.getCurrentLocation(), driver.getCurrentLocationUpdatedAt(),
                driver.getTotalRides(), driver.getTotalEarnings(), driver.getDueAmount(),
                driver.getCommissionRate(), driver.getCreatedAt(),
                profile == null ? null : new DriverDetail.Profile(
                        profile.getFirstName(), profile.getLastName(),
                        profile.getUser() != null ? profile.getUser().getEmail() : null),
                vehicles.stream().map(v -> new DriverDetail.VehicleRow(
                        v.getId(), v.getRegistrationNumber(),
                        v.getType() != null ? v.getType().name() : null,
                        v.getModel(), v.getYear(), v.getColor(), v.getSeatCapacity(),
                        v.getStatus() != null ? v.getStatus().name() : null)).toList(),
                docs.stream().map(d -> new DriverDetail.DocumentRow(
                        d.getDocumentType() != null ? d.getDocumentType().name() : null,
                        d.getDocumentNumber(),
                        d.getStatus() != null ? d.getStatus().name() : null,
                        d.getExpiresAt(), d.isVerified(), d.getDocumentUrl())).toList());
    }

    @Transactional(readOnly = true)
    public VehicleDetail getVehicleDetail(UUID vehicleId) {
        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new NoSuchElementException("Vehicle not found"));
        DriverProfile owner = vehicle.getDriver();
        UserSnapshot ownerUser = snapshotUser(owner != null ? owner.getUser() : null);
        String ownerName = null;
        if (ownerUser != null) {
            ownerName = userProfileRepository.findByUserId(ownerUser.id())
                    .map(OwnerProfile -> {
                        String f = OwnerProfile.getFirstName() != null ? OwnerProfile.getFirstName() : "";
                        String l = OwnerProfile.getLastName() != null ? OwnerProfile.getLastName() : "";
                        return (f + " " + l).trim();
                    })
                    .orElse(null);
        }
        List<VehicleDocument> docs = vehicleDocumentRepository.findByVehicleId(vehicleId);

        return new VehicleDetail(
                vehicle.getId(),
                owner != null ? owner.getId() : null,
                ownerName,
                ownerUser != null ? ownerUser.phone() : null,
                vehicle.getRegistrationNumber(),
                vehicle.getType() != null ? vehicle.getType().name() : null,
                vehicle.getModel(), vehicle.getYear(), vehicle.getColor(),
                vehicle.getSeatCapacity(),
                vehicle.getStatus() != null ? vehicle.getStatus().name() : null,
                vehicle.getCreatedAt(),
                docs.stream().map(d -> new DriverDetail.DocumentRow(
                        d.getDocumentType() != null ? d.getDocumentType().name() : null,
                        d.getDocumentNumber(),
                        d.getStatus() != null ? d.getStatus().name() : null,
                        d.getExpiresAt(), d.isVerified(), d.getDocumentUrl())).toList());
    }

    @Transactional(readOnly = true)
    public RideDetail getRideDetail(UUID rideId) {
        Ride ride = rideRepository.findDetailedById(rideId)
                .orElseThrow(() -> new NoSuchElementException("Ride not found"));

        DriverProfile driver = ride.getDriver();
        UserSnapshot driverUser = snapshotUser(driver != null ? driver.getUser() : null);
        UserSnapshot creator = snapshotUser(ride.getCreator());

        List<Booking> bookings = bookingRepository.findByRideId(rideId);
        Payment payment = bookings.isEmpty() ? null
                : paymentRepository.findByBookingId(bookings.get(0).getId()).orElse(null);

        return new RideDetail(
                ride.getId(),
                ride.getStatus() != null ? ride.getStatus().name() : null,
                ride.getType() != null ? ride.getType().name() : null,
                driver != null ? driver.getId() : null,
                driverUser != null ? displayName(driverUser.id()) : null,
                driverUser != null ? driverUser.phone() : null,
                creator != null ? creator.id() : null,
                creator != null ? displayName(creator.id()) : null,
                creator != null ? creator.phone() : null,
                ride.getVehicleId() != null ? vehicleRepository.findById(ride.getVehicleId())
                        .map(Vehicle::getRegistrationNumber).orElse(null) : null,
                ride.getOriginAddress(), ride.getDestinationAddress(),
                ride.getScheduledAt(), ride.getActualStartAt(), ride.getActualEndAt(),
                ride.getAvailableSeats(), ride.getMaxDetourMeters(),
                ride.getNotes(), ride.getCreatedAt(),
                ride.getPassengers().stream().map((RidePassenger rp) -> {
                    UserSnapshot p = snapshotUser(rp.getPassenger());
                    return new RideDetail.PassengerRow(
                        rp.getId(),
                        p != null ? p.id() : null,
                        p != null ? p.id() : null,
                        p != null ? displayName(p.id()) : null,
                        p != null ? p.phone() : null,
                        rp.getSeats(),
                        rp.getJourneyStatus() != null ? rp.getJourneyStatus().name() : null,
                        rp.getCreatedAt());
                }).toList(),
                bookings.stream().map(b -> new RideDetail.BookingRow(
                        b.getId(), b.getSeats(),
                        b.getStatus() != null ? b.getStatus().name() : null,
                        b.getPickupAddress(), b.getDropoffAddress(), b.getFinalPayable(),
                        b.getPickupPlannedTime(), b.getPickupLocation(), b.getDropoffLocation(),
                        b.getCreatedAt())).toList(),
                payment == null ? null : new RideDetail.PaymentRow(
                        payment.getId(), payment.getAmount(),
                        payment.getMethod() != null ? payment.getMethod().name() : null,
                        payment.getStatus() != null ? payment.getStatus().name() : null,
                        payment.getProviderReference(), payment.getCreatedAt()));
    }

    /** Immutable safe-load of a lazy user reference; broken FKs degrade to null. */
    private record UserSnapshot(UUID id, String phone, String email) {}

    private UserSnapshot snapshotUser(User user) {
        if (user == null) return null;
        try {
            return new UserSnapshot(user.getId(), user.getPhone(), user.getEmail());
        } catch (jakarta.persistence.EntityNotFoundException | org.hibernate.ObjectNotFoundException e) {
            return null;
        }
    }

    private String displayName(UUID userId) {
        return userProfileRepository.findByUserId(userId)
                .map(p -> {
                    String f = p.getFirstName() != null ? p.getFirstName() : "";
                    String l = p.getLastName() != null ? p.getLastName() : "";
                    String n = (f + " " + l).trim();
                    return n.isEmpty() ? null : n;
                })
                .orElse(null);
    }

    // ── Payments / settlements / complaints / safety details ─────────────

    @Transactional(readOnly = true)
    public PaymentDetail getPaymentDetail(UUID paymentId) {
        com.nimbus.payment.domain.entity.Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new NoSuchElementException("Payment not found"));
        com.nimbus.booking.domain.entity.Booking booking = payment.getBooking();
        UUID rideId = null;
        String pickup = null, dropoff = null;
        if (booking != null) {
            pickup = booking.getPickupAddress();
            dropoff = booking.getDropoffAddress();
            try {
                rideId = booking.getRide() != null ? booking.getRide().getId() : null;
            } catch (jakarta.persistence.EntityNotFoundException e) {
                rideId = null;
            }
        }
        UserSnapshot payer = snapshotUser(payment.getPayer());

        return new PaymentDetail(
                payment.getId(),
                booking != null ? booking.getId() : null,
                rideId,
                payer != null ? payer.id() : null,
                payer != null ? displayName(payer.id()) : null,
                payer != null ? payer.phone() : null,
                payment.getAmount(),
                payment.getMethod() != null ? payment.getMethod().name() : null,
                payment.getStatus() != null ? payment.getStatus().name() : null,
                payment.getProviderReference(),
                payment.getIdempotencyKey(),
                pickup, dropoff,
                payment.getCreatedAt(), payment.getUpdatedAt());
    }

    @Transactional(readOnly = true)
    public SettlementDetail getSettlementDetail(UUID settlementId) {
        com.nimbus.settlement.domain.entity.Settlement settlement = settlementRepository.findById(settlementId)
                .orElseThrow(() -> new NoSuchElementException("Settlement not found"));
        DriverProfile driver = settlement.getDriver();
        UserSnapshot driverUser = snapshotUser(driver != null ? driver.getUser() : null);

        return new SettlementDetail(
                settlement.getId(),
                driver != null ? driver.getId() : null,
                driverUser != null ? displayName(driverUser.id()) : null,
                driverUser != null ? driverUser.phone() : null,
                settlement.getPeriodStart(), settlement.getPeriodEnd(),
                settlement.getGrossEarnings(), settlement.getCommission(),
                settlement.getAdjustments(), settlement.getRefunds(),
                settlement.getDriverCredits(), settlement.getPayable(),
                settlement.getStatus() != null ? settlement.getStatus().name() : null,
                settlement.getPaymentReference(),
                settlement.getCreatedAt(), settlement.getUpdatedAt());
    }

    @Transactional(readOnly = true)
    public ComplaintDetail getComplaintDetail(UUID complaintId) {
        com.nimbus.complaint.domain.entity.Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new NoSuchElementException("Complaint not found"));
        UserSnapshot passenger = snapshotUser(complaint.getUser());
        UUID bookingId = null, rideId = null;
        try {
            com.nimbus.booking.domain.entity.Booking booking = complaint.getBooking();
            if (booking != null) {
                bookingId = booking.getId();
                rideId = booking.getRide() != null ? booking.getRide().getId() : null;
            }
        } catch (jakarta.persistence.EntityNotFoundException e) {
            // booking/ride reference dangling
        }

        return new ComplaintDetail(
                complaint.getId(),
                complaint.getCategory() != null ? complaint.getCategory().name() : null,
                complaint.getStatus() != null ? complaint.getStatus().name() : null,
                complaint.getDescription(),
                complaint.getResolution(),
                passenger != null ? passenger.id() : null,
                passenger != null ? displayName(passenger.id()) : null,
                passenger != null ? passenger.phone() : null,
                bookingId, rideId,
                complaint.getCreatedAt(), complaint.getUpdatedAt());
    }

    @Transactional(readOnly = true)
    public SafetyDetail getSafetyDetail(UUID eventId) {
        com.nimbus.safety.domain.entity.SafetyEvent event = safetyEventRepository.findById(eventId)
                .orElseThrow(() -> new NoSuchElementException("Safety event not found"));
        UserSnapshot user = snapshotUser(event.getUser());
        DriverProfile driver = event.getDriver();
        UserSnapshot driverUser = snapshotUser(driver != null ? driver.getUser() : null);
        UUID rideId = null;
        try {
            rideId = event.getRide() != null ? event.getRide().getId() : null;
        } catch (jakarta.persistence.EntityNotFoundException e) {
            rideId = null;
        }

        return new SafetyDetail(
               event.getId(),
                event.getEventType() != null ? event.getEventType().name() : null,
                event.getStatus() != null ? event.getStatus().name() : null,
                user != null ? user.id() : null,
                user != null ? displayName(user.id()) : null,
                user != null ? user.phone() : null,
                driver != null ? driver.getId() : null,
                driverUser != null ? displayName(driverUser.id()) : null,
                driverUser != null ? driverUser.phone() : null,
                rideId,
                event.getVehicleId(),
                event.getVehicleId() != null ? vehicleRepository.findById(event.getVehicleId())
                        .map(com.nimbus.driver.domain.entity.Vehicle::getRegistrationNumber).orElse(null) : null,
                event.getLatitude(), event.getLongitude(),
                event.getDescription(), event.getShareToken(), event.getExpiresAt(),
                event.getCreatedAt(), event.getUpdatedAt());
    }
}
