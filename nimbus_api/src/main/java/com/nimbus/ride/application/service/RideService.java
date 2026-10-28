package com.nimbus.ride.application.service;

import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.driver.domain.repository.VehicleRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.ride.application.CreateRideRequest;
import com.nimbus.ride.application.RideResponse;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.booking.application.BookingResponse;
import com.nimbus.booking.application.service.BookingService;
import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.ride.domain.repository.RideRepository;
import com.nimbus.wallet.application.service.LedgerService;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Ride lifecycle management service.
 *
 * <p>Ride states: DRAFT → PUBLISHED → ROUTE_LOCKED → DRIVER_ARRIVING
 *             → IN_PROGRESS → COMPLETED/CANCELLED
 *
 * <p>All state transitions are validated. Route is versioned and locked
 * before execution. Backend is authoritative for ride state.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RideService {

    private final RideRepository rideRepository;
    private final UserRepository userRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final VehicleRepository vehicleRepository;
    private final com.nimbus.driver.application.service.DriverEligibilityService driverEligibilityService;
    private final com.nimbus.payment.domain.repository.PaymentRepository paymentRepository;
    private final com.nimbus.ride.domain.repository.RideStopRepository rideStopRepository;
    private final BookingService bookingService;
    private final LedgerService ledgerService;
    private final SimpMessagingTemplate messagingTemplate;
    private final com.nimbus.matching.application.MatchingService matchingService;
    private final com.nimbus.routing.application.RouteService routeService;
    private final com.nimbus.notification.application.service.NotificationService notificationService;
    private final org.springframework.data.redis.core.StringRedisTemplate redisTemplate;
    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    /** Default platform commission when the profile has none set (10%). */
    private static final BigDecimal DEFAULT_COMMISSION_RATE = new BigDecimal("0.10");

    /**
     * Create a new ride in DRAFT state.
     */
    @Transactional
    public RideResponse createRide(UUID userId, CreateRideRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Validate driver eligibility
        validateDriverEligibility(userId);

        // Parse origin/destination coordinates
        Double[] origin = request.getOrigin();
        Double[] destination = request.getDestination();

        DriverProfile driverProfile = driverProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND));

        // Get vehicle
        var vehicle = vehicleRepository.findById(request.getVehicleId())
                .orElseThrow(() -> new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND));
        // Object-level authorization (guide §18): a driver may only publish
        // rides on their OWN vehicle.
        if (vehicle.getDriver() == null
                || !vehicle.getDriver().getId().equals(driverProfile.getId())) {
            throw new NimbusException(ErrorCode.FORBIDDEN,
                    "Vehicle does not belong to you", HttpStatus.FORBIDDEN);
        }

        // Guide §16: the ride's seat offer comes from the request, clamped to
        // a vehicle-feasible upper bound of (seatCapacity - 1) for the driver,
        // and must leave at least one bookable seat.
        int requestedSeats = request.getAvailableSeats() != null
                ? request.getAvailableSeats()
                : vehicle.getSeatCapacity() - 1;
        int maxBookableSeats = vehicle.getSeatCapacity() - 1;
        int availableSeats = Math.max(1, Math.min(requestedSeats, maxBookableSeats));

        Ride ride = Ride.builder()
                .creator(user)
                .driver(driverProfile)
                .vehicleId(request.getVehicleId())
                .type(Ride.RideType.valueOf(request.getRideType()))
                .scheduledAt(request.getScheduledAt())
                .recurrenceType(request.getRecurrenceType() != null
                        ? Ride.RecurrenceType.valueOf(request.getRecurrenceType().toUpperCase())
                        : Ride.RecurrenceType.NONE)
                .recurrenceUntil(request.getRecurrenceUntil())
                .status(Ride.RideStatus.DRAFT)
                .originAddress(request.getOriginAddress())
                .destinationAddress(request.getDestinationAddress())
                .availableSeats(availableSeats)
                .maxDetourMeters(request.getMaxDetourMeters())
                .maxWaitSeconds(request.getMaxWaitSeconds())
                .notes(request.getNotes())
                .routeVersion(0)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        // Store origin/destination as WKT
        if (origin != null && origin.length >= 2) {
            ride.setOriginLocation(String.format("POINT(%s %s)", origin[0], origin[1]));
        }
        if (destination != null && destination.length >= 2) {
            ride.setDestinationLocation(String.format("POINT(%s %s)", destination[0], destination[1]));
        }

        Ride saved = rideRepository.save(ride);
        log.info("Created ride: {}", saved.getId());
        return toRideResponse(saved);
    }

    /**
     * Validate driver eligibility before creating a ride. Delegates to the
     * unified eligibility service (guide §5): active account, approved
     * driver, valid documents, no suspension, zero due.
     */
    private void validateDriverEligibility(UUID userId) {
        driverEligibilityService.assertEligible(userId);
    }

    /**
     * Get ride by ID.
     */
    @Transactional(readOnly = true)
    public RideResponse getRide(UUID rideId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));
        return toRideResponse(ride);
    }

    /**
     * List rides for a user (as driver or creator).
     */
    @Transactional(readOnly = true)
    public List<RideResponse> listRides(UUID userId, String status) {
        List<Ride> rides;
        if (status != null) {
            try {
                Ride.RideStatus rideStatus = Ride.RideStatus.valueOf(status.toUpperCase());
                rides = rideRepository.findByCreatorIdAndStatus(userId, rideStatus);
            } catch (IllegalArgumentException e) {
                rides = rideRepository.findByCreatorId(userId);
            }
        } else {
            rides = rideRepository.findByCreatorId(userId);
        }
        return rides.stream()
                .map(this::toRideResponse)
                .collect(Collectors.toList());
    }

    /**
     * Update a ride (only when in DRAFT state).
     */
    @Transactional
    public RideResponse updateRide(UUID rideId, UUID userId, CreateRideRequest request) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() != Ride.RideStatus.DRAFT) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Only DRAFT rides can be updated", HttpStatus.CONFLICT);
        }

        ride.setType(Ride.RideType.valueOf(request.getRideType()));
        ride.setScheduledAt(request.getScheduledAt());
        ride.setOriginAddress(request.getOriginAddress());
        ride.setDestinationAddress(request.getDestinationAddress());
        ride.setMaxDetourMeters(request.getMaxDetourMeters());
        ride.setMaxWaitSeconds(request.getMaxWaitSeconds());
        ride.setNotes(request.getNotes());
        ride.setUpdatedAt(Instant.now());

        // Update locations if provided
        Double[] origin = request.getOrigin();
        Double[] destination = request.getDestination();
        if (origin != null && origin.length >= 2) {
            ride.setOriginLocation(String.format("POINT(%s %s)", origin[0], origin[1]));
        }
        if (destination != null && destination.length >= 2) {
            ride.setDestinationLocation(String.format("POINT(%s %s)", destination[0], destination[1]));
        }

        return toRideResponse(rideRepository.save(ride));
    }

    /**
     * Publish a ride (make it searchable/bookable).
     */
    @Transactional
    public RideResponse publishRide(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() != Ride.RideStatus.DRAFT) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Only DRAFT rides can be published", HttpStatus.CONFLICT);
        }

        // Validate driver eligibility
        validateDriverEligibility(userId);

        // Check vehicle exists, is approved, and belongs to this driver
        if (ride.getVehicleId() != null) {
            var vehicleOpt = vehicleRepository.findById(ride.getVehicleId());
            if (vehicleOpt.isEmpty()) {
                throw new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND);
            }
            UUID ownerProfileId = vehicleOpt.get().getDriver() != null
                    ? vehicleOpt.get().getDriver().getId() : null;
            UUID callerProfileId = driverProfileRepository.findByUserId(userId)
                    .map(com.nimbus.driver.domain.entity.DriverProfile::getId)
                    .orElse(null);
            if (ownerProfileId == null || !ownerProfileId.equals(callerProfileId)) {
                throw new NimbusException(ErrorCode.FORBIDDEN,
                        "Vehicle does not belong to you", HttpStatus.FORBIDDEN);
            }
            if (!vehicleOpt.get().isEligible()) {
                throw new NimbusException(ErrorCode.VEHICLE_NOT_ELIGIBLE, HttpStatus.FORBIDDEN);
            }
        }

        ride.setStatus(Ride.RideStatus.PUBLISHED);
        ride.setRouteVersion(ride.getRouteVersion() + 1);
        ride.setUpdatedAt(Instant.now());

        Ride saved = rideRepository.save(ride);
        log.info("Published ride: {}", saved.getId());
        return toRideResponse(saved);
    }

    /**
     * Search for rides matching criteria.
     */
    @Transactional(readOnly = true)
    public List<RideResponse> searchRides(Double originLat, Double originLng,
                                          Double destLat, Double destLng,
                                          Instant time) {
        // Search cache (guide §14 ride:search:{hash}, 10-30 s TTL). Redis is
        // transient — on a miss or a Redis outage the DB answers.
        String cacheKey = null;
        try {
            cacheKey = "ride:search:" + Integer.toHexString(Objects.hash(
                    originLat, originLng, destLat, destLng,
                    time != null ? time.toEpochMilli() / 1000 : 0));
            String cached = redisTemplate.opsForValue().get(cacheKey);
            if (cached != null) {
                return objectMapper.readValue(cached,
                        objectMapper.getTypeFactory().constructCollectionType(
                                List.class, RideResponse.class));
            }
        } catch (Exception e) {
            log.debug("Search cache read skipped: {}", e.getMessage());
        }

        // Matching engine (guide §9): hard constraints then weighted
        // scoring, owned by the matching module.
        List<Ride> matched = matchingService.findMatchingRides(
                originLat, originLng, destLat, destLng, time);
        List<RideResponse> responses = matched.stream()
                .map(this::toRideResponse)
                .collect(Collectors.toList());

        if (cacheKey != null) {
            try {
                redisTemplate.opsForValue().set(cacheKey,
                        objectMapper.writeValueAsString(responses),
                        java.time.Duration.ofSeconds(15));
            } catch (Exception e) {
                log.debug("Search cache write skipped: {}", e.getMessage());
            }
        }
        log.debug("Matched {} rides for search", responses.size());
        return responses;
    }

    private boolean isTimeCompatible(Ride ride, Instant time) {
        if (time == null || ride.getScheduledAt() == null) return true;
        long diffMinutes = Math.abs(ride.getScheduledAt().toEpochMilli() - time.toEpochMilli()) / 60000;
        return diffMinutes <= 30; // Within 30 minutes
    }

    /**
     * ETA from the driver's last known position to the ride destination.
     * Returns {durationSeconds, distanceMeters}.
     */
    @Transactional(readOnly = true)
    public java.util.Map<String, Integer> getEta(UUID rideId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        Double[] dest = parseLocation(ride.getDestinationLocation());
        if (dest == null) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Ride has no destination coordinates", HttpStatus.BAD_REQUEST);
        }

        double[] from = null;
        if (ride.getDriver() != null) {
            var driverProfile = driverProfileRepository.findById(ride.getDriver().getId());
            if (driverProfile.isPresent()
                    && driverProfile.get().getCurrentLocation() != null) {
                Double[] pos = parseLocation(driverProfile.get().getCurrentLocation());
                if (pos != null) from = new double[]{pos[0], pos[1]};
            }
        }
        if (from == null) {
            Double[] o = parseLocation(ride.getOriginLocation());
            if (o != null) from = new double[]{o[0], o[1]};
        }
        if (from == null) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "No driver position or origin to compute ETA", HttpStatus.BAD_REQUEST);
        }

        int meters = (int) Math.round(haversineMeters(from[0], from[1], dest[0], dest[1]) * 1.3);
        int seconds = (int) Math.round(meters / 1000.0 / 18.0 * 3600);

        // Push the refreshed ETA to subscribers (guide §17 ETA_UPDATED).
        broadcastEvent(ride, "ETA_UPDATED",
                java.util.Map.of("etaSeconds", seconds, "distanceMeters", meters));

        return java.util.Map.of("durationSeconds", seconds, "distanceMeters", meters);
    }

    private double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
        double r = 6371000.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    /**
     * Cancel a ride.
     */
    @Transactional
    public void cancelRide(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() == Ride.RideStatus.COMPLETED ||
                ride.getStatus() == Ride.RideStatus.CANCELLED) {
            throw new NimbusException(ErrorCode.RIDE_CANNOT_CANCEL, HttpStatus.CONFLICT);
        }

        ride.setStatus(Ride.RideStatus.CANCELLED);
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);
        broadcastStatus(ride);

        // Cascade (guide §5/§8): passengers' active bookings must follow the
        // ride — cancelled with refunds where payment was collected, and
        // every affected passenger notified. Confirmed rides are never
        // silently cancelled; this IS the operations-driven cancellation.
        try {
            bookingService.getRideBookingEntities(rideId).stream()
                    .filter(b -> b.getStatus() == Booking.BookingStatus.HELD
                            || b.getStatus() == Booking.BookingStatus.CONFIRMED)
                    .forEach(b -> bookingService.cancelBookingByDriver(
                            b.getId(), userId));
        } catch (Exception e) {
            log.error("Failed to cascade booking cancellation for ride {}: {}",
                    rideId, e.getMessage(), e);
        }

        log.info("Cancelled ride: {}", rideId);
    }

    /**
     * Lock the route before execution.
     */
    @Transactional
    public RideResponse lockRoute(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() != Ride.RideStatus.PUBLISHED) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Only PUBLISHED rides can be locked", HttpStatus.CONFLICT);
        }

        // Snapshot the current stop sequence as a new active route version
        // (guide §5/§10: the route becomes locked before execution).
        routeService.lockRouteForExecution(rideId);

        ride.setStatus(Ride.RideStatus.ROUTE_LOCKED);
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);
        broadcastStatus(ride);

        log.info("Locked route for ride: {}", rideId);
        return toRideResponse(ride);
    }

    /**
     * Driver marks that they are arriving at the pickup point
     * (PUBLISHED/ROUTE_LOCKED → DRIVER_ARRIVING, guide §8) and notifies
     * waiting passengers with DRIVER_ARRIVED.
     */
    @Transactional
    public RideResponse markDriverArriving(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() != Ride.RideStatus.ROUTE_LOCKED
                && ride.getStatus() != Ride.RideStatus.PUBLISHED) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Ride must be PUBLISHED or ROUTE_LOCKED to mark driver arriving",
                    HttpStatus.CONFLICT);
        }

        ride.setStatus(Ride.RideStatus.DRIVER_ARRIVING);
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);
        broadcastStatus(ride);

        // DRIVER_ARRIVED event with the first pickup stop (guide §17).
        UUID stopId = rideStopRepository.findByRideIdOrderBySequence(rideId).stream()
                .filter(s -> s.getStopType() == com.nimbus.ride.domain.entity.RideStop.StopType.PICKUP)
                .findFirst()
                .map(com.nimbus.ride.domain.entity.RideStop::getId)
                .orElse(null);
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("stopId", stopId != null ? stopId.toString() : null);
        broadcastEvent(ride, "DRIVER_ARRIVED", data);

        log.info("Driver arriving for ride: {}", rideId);
        return toRideResponse(ride);
    }

    /**
     * Operational interruption (IN_PROGRESS → INTERRUPTED, guide §8) —
     * breakdown, road closure, etc. Passengers are notified in real time.
     */
    @Transactional
    public RideResponse interruptRide(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() != Ride.RideStatus.IN_PROGRESS) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Only IN_PROGRESS rides can be interrupted", HttpStatus.CONFLICT);
        }

        ride.setStatus(Ride.RideStatus.INTERRUPTED);
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);
        broadcastStatus(ride);

        log.info("Interrupted ride: {}", rideId);
        return toRideResponse(ride);
    }

    /**
     * Resume from an interruption (INTERRUPTED → IN_PROGRESS).
     */
    @Transactional
    public RideResponse resumeRide(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() != Ride.RideStatus.INTERRUPTED) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Only INTERRUPTED rides can be resumed", HttpStatus.CONFLICT);
        }

        ride.setStatus(Ride.RideStatus.IN_PROGRESS);
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);
        broadcastStatus(ride);

        log.info("Resumed ride: {}", rideId);
        return toRideResponse(ride);
    }

    /**
     * Start a ride (transition to IN_PROGRESS).
     */
    @Transactional
    public RideResponse startRide(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() != Ride.RideStatus.ROUTE_LOCKED
                && ride.getStatus() != Ride.RideStatus.DRIVER_ARRIVING) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Ride must be ROUTE_LOCKED or DRIVER_ARRIVING to start", HttpStatus.CONFLICT);
        }

        ride.setStatus(Ride.RideStatus.IN_PROGRESS);
        ride.setActualStartAt(Instant.now());
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);
        broadcastStatus(ride);

        log.info("Started ride: {}", rideId);
        return toRideResponse(ride);
    }

    /**
     * Complete a ride.
     */
    @Transactional
    public RideResponse completeRide(UUID rideId, UUID userId) {
        // Lock the row so two concurrent completes cannot both read
        // IN_PROGRESS and double-settle the driver (guide §7).
        Ride ride = rideRepository.findByIdForUpdate(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(userId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        if (ride.getStatus() != Ride.RideStatus.IN_PROGRESS) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Only IN_PROGRESS rides can be completed", HttpStatus.CONFLICT);
        }

        ride.setStatus(Ride.RideStatus.COMPLETED);
        ride.setActualEndAt(Instant.now());
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);
        broadcastStatus(ride);

        // Settle the ride: post driver earnings (net of platform commission)
        // for every COMPLETED booking — the passenger→Nimbus→driver flow.
        settleDriverEarnings(ride);

        // Ask completed passengers to rate the driver (guide §19).
        try {
            bookingService.getRideBookingEntities(rideId).stream()
                    .filter(b -> b.getStatus() == Booking.BookingStatus.COMPLETED)
                    .forEach(b -> notificationService.sendNotification(
                            b.getPassenger().getId(),
                            com.nimbus.notification.domain.entity.Notification.NotificationType.RATING_REQUEST,
                            "Rate your ride",
                            "How was your trip? Your rating helps other commuters.",
                            java.util.Map.of("bookingId", b.getId().toString(),
                                    "rideId", rideId.toString())));
        } catch (Exception e) {
            log.warn("Rating request notifications failed: {}", e.getMessage());
        }

        log.info("Completed ride: {}", rideId);
        return toRideResponse(ride);
    }

    /**
     * Settles a completed ride: for each COMPLETED booking, posts the
     * driver's gross earning and the platform commission to the immutable
     * ledger, and updates the driver profile's running totals.
     */
    private void settleDriverEarnings(Ride ride) {
        try {
            if (ride.getDriver() == null) return;
            DriverProfile profile = ride.getDriver();
            BigDecimal rate = effectiveCommissionRate(profile);

            var completed = bookingService.listByRide(ride.getId(),
                    ride.getCreator().getId()).stream()
                    .filter(b -> b.getStatus() == Booking.BookingStatus.COMPLETED)
                    .toList();

            BigDecimal gross = BigDecimal.ZERO;
            BigDecimal cashCommissionDue = BigDecimal.ZERO;
            for (BookingResponse b : completed) {
                BigDecimal bookingGross = b.getFinalPayable() != null
                        ? b.getFinalPayable()
                        : BigDecimal.ZERO;
                BigDecimal commission = bookingGross.multiply(rate)
                        .setScale(2, RoundingMode.HALF_UP);
                if (bookingGross.compareTo(BigDecimal.ZERO) > 0) {
                    // Cash fares never entered the platform wallet: the
                    // driver already holds the gross. Crediting earnings
                    // here *and* paying them through settlement would pay
                    // the driver twice (guide §13). Only the platform
                    // commission remains due.
                    var successPayment = paymentRepository
                            .findFirstByBookingIdAndStatusOrderByCreatedAtDesc(
                                    b.getId(),
                                    com.nimbus.payment.domain.entity.Payment.PaymentStatus.SUCCESS);
                    if (successPayment.isEmpty()) {
                        // No successful payment and not cash-collected:
                        // posting earnings would pay the driver for money
                        // nobody paid (guide §13). Park it for
                        // reconciliation instead.
                        log.warn("Booking {} completed without payment — "
                                + "earnings withheld for reconciliation", b.getId());
                        continue;
                    }
                    boolean cash = successPayment.get().getMethod()
                            == com.nimbus.payment.domain.entity.Payment.PaymentMethod.CASH;
                    if (cash) {
                        cashCommissionDue = cashCommissionDue.add(commission);
                    } else {
                        ledgerService.postDriverEarnings(
                                profile.getId(), ride.getId(),
                                bookingGross, commission,
                                b.getId());
                    }
                    gross = gross.add(bookingGross.subtract(commission));
                }
            }

            if (gross.compareTo(BigDecimal.ZERO) > 0) {
                profile.setTotalEarnings((profile.getTotalEarnings() != null
                        ? profile.getTotalEarnings() : BigDecimal.ZERO).add(gross));
            }
            if (cashCommissionDue.compareTo(BigDecimal.ZERO) > 0) {
                profile.setDueAmount((profile.getDueAmount() != null
                        ? profile.getDueAmount() : BigDecimal.ZERO).add(cashCommissionDue));
                log.info("Driver {} owes {} commission on cash fares for ride {}",
                        profile.getId(), cashCommissionDue, ride.getId());
            }
            profile.setTotalRides((profile.getTotalRides() != null
                    ? profile.getTotalRides() : 0) + 1);
            driverProfileRepository.save(profile);
            log.info("Settled ride {}: {} completed bookings, driver net {}",
                    ride.getId(), completed.size(), gross);
        } catch (Exception e) {
            // Settlement failure must not fail the ride completion.
            log.error("Failed to settle earnings for ride {}: {}",
                    ride.getId(), e.getMessage(), e);
        }
    }

    /**
     * Commission rate as a fraction of gross. Profiles store it either as a
     * percentage (10.00 = 10%) or a fraction (0.10 = 10%) — normalize
     * defensively so commission is never 10× the fare.
     */
    private BigDecimal effectiveCommissionRate(DriverProfile profile) {
        BigDecimal rate = profile.getCommissionRate() != null
                ? profile.getCommissionRate()
                : DEFAULT_COMMISSION_RATE;
        if (rate.compareTo(BigDecimal.ONE) > 0) {
            rate = rate.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        }
        return rate;
    }

    /**
     * Broadcasts a RIDE_STATUS_CHANGED event to the ride's topic so
     * passengers track transitions in real time.
     */
    private void broadcastStatus(Ride ride) {
        try {
            messagingTemplate.convertAndSend("/topic/ride/" + ride.getId(),
                    java.util.Map.of(
                            "event", "RIDE_STATUS_CHANGED",
                            "rideId", ride.getId().toString(),
                            "data", java.util.Map.of("newStatus", ride.getStatus().name()),
                            "timestamp", Instant.now().toString()));
        } catch (Exception e) {
            log.warn("Failed to broadcast status for ride {}: {}",
                    ride.getId(), e.getMessage());
        }
    }

    /** Broadcasts a generic ride event with a data payload (guide §17). */
    private void broadcastEvent(Ride ride, String event, java.util.Map<String, Object> data) {
        try {
            var payload = new java.util.HashMap<String, Object>();
            payload.put("event", event);
            payload.put("rideId", ride.getId().toString());
            payload.put("data", data);
            payload.put("timestamp", Instant.now().toString());
            messagingTemplate.convertAndSend("/topic/ride/" + ride.getId(), payload);
        } catch (Exception e) {
            log.warn("Failed to broadcast {} for ride {}: {}", event, ride.getId(), e.getMessage());
        }
    }

    /**
     * Update driver location.
     */
    @Transactional
    public void updateDriverLocation(UUID driverId, UUID rideId, Double lat, Double lng) {
        User user = userRepository.findById(driverId)
                .orElseThrow(() -> new NimbusException(ErrorCode.USER_NOT_FOUND, HttpStatus.NOT_FOUND));

        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new NimbusException(ErrorCode.RIDE_NOT_FOUND, HttpStatus.NOT_FOUND));

        if (!ride.getCreator().getId().equals(driverId)) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }

        // Update driver's current location
        var driverProfile = driverProfileRepository.findByUserId(driverId);
        if (driverProfile.isPresent()) {
            DriverProfile profile = driverProfile.get();
            profile.setCurrentLocation(String.format("POINT(%s %s)", lng, lat));
            profile.setCurrentLocationUpdatedAt(Instant.now());
            driverProfileRepository.save(profile);
        }

        // Latest-location cache (guide §14 ride:location:{rideId}, short
        // TTL). Postgres stays authoritative; this serves polling clients.
        try {
            redisTemplate.opsForValue().set("ride:location:" + rideId,
                    lat + "," + lng, java.time.Duration.ofSeconds(60));
        } catch (Exception e) {
            log.warn("Redis location write failed (DB remains authoritative): {}", e.getMessage());
        }

        ride.setUpdatedAt(Instant.now());

        // Real-time push to the passenger's ride topic (guide §17).
        try {
            messagingTemplate.convertAndSend("/topic/ride/" + rideId,
                    java.util.Map.of(
                            "event", "RIDE_LOCATION_UPDATED",
                            "rideId", rideId.toString(),
                            "data", java.util.Map.of(
                                    "latitude", lat, "longitude", lng),
                            "timestamp", Instant.now().toString()));
        } catch (Exception e) {
            log.warn("Failed to broadcast driver location for ride {}: {}",
                    rideId, e.getMessage());
        }
        rideRepository.save(ride);

        log.debug("Updated driver location: {} for ride: {}", driverId, rideId);
    }

    private RideResponse toRideResponse(Ride ride) {
        RideResponse response = RideResponse.builder()
                .id(ride.getId())
                .driverId(ride.getDriver() != null ? ride.getDriver().getId() : null)
                .creatorId(ride.getCreator() != null ? ride.getCreator().getId() : null)
                .type(ride.getType())
                .scheduledAt(ride.getScheduledAt())
                .actualStartAt(ride.getActualStartAt())
                .actualEndAt(ride.getActualEndAt())
                .status(ride.getStatus())
                .originAddress(ride.getOriginAddress())
                .destinationAddress(ride.getDestinationAddress())
                .availableSeats(ride.getAvailableSeats())
                .maxDetourMeters(ride.getMaxDetourMeters())
                .maxWaitSeconds(ride.getMaxWaitSeconds())
                .routeVersion(ride.getRouteVersion())
                .fareRuleVersion(ride.getFareRuleVersion())
                .recurrenceType(ride.getRecurrenceType())
                .recurrenceUntil(ride.getRecurrenceUntil())
                .parentRideId(ride.getParentRideId())
                .notes(ride.getNotes())
                .createdAt(ride.getCreatedAt())
                .updatedAt(ride.getUpdatedAt())
                .build();

        // Parse coordinates from WKT if present
        Double[] originCoords = parseLocation(ride.getOriginLocation());
        if (originCoords != null) {
            response.setOriginLatitude(originCoords[0]);
            response.setOriginLongitude(originCoords[1]);
        }
        Double[] destCoords = parseLocation(ride.getDestinationLocation());
        if (destCoords != null) {
            response.setDestinationLatitude(destCoords[0]);
            response.setDestinationLongitude(destCoords[1]);
        }

        return response;
    }

    private Double[] parseLocation(String wkt) {
        if (wkt != null && wkt.startsWith("POINT(")) {
            try {
                String coords = wkt.substring(6, wkt.length() - 1);
                String[] parts = coords.split(" ");
                Double lng = Double.parseDouble(parts[0]);
                Double lat = Double.parseDouble(parts[1]);
                return new Double[]{lat, lng};
            } catch (Exception ignored) {
            }
        }
        return null;
    }
}
