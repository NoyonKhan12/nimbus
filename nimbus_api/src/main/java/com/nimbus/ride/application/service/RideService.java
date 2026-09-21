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
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
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

        Ride ride = Ride.builder()
                .creator(user)
                .driver(driverProfile)
                .vehicleId(request.getVehicleId())
                .type(Ride.RideType.valueOf(request.getRideType()))
                .scheduledAt(request.getScheduledAt())
                .status(Ride.RideStatus.DRAFT)
                .originAddress(request.getOriginAddress())
                .destinationAddress(request.getDestinationAddress())
                .availableSeats(vehicle.getSeatCapacity() - 1) // Driver doesn't count as a seat
                .maxDetourMeters(request.getMaxDetourMeters())
                .maxWaitSeconds(request.getMaxWaitSeconds())
                .notes(request.getNotes())
                .routeVersion(0)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        // Store origin/destination as WKT
        if (origin != null && origin.length >= 2) {
            ride.setOriginLocation(String.format("POINT(%s %s)", origin[1], origin[0]));
        }
        if (destination != null && destination.length >= 2) {
            ride.setDestinationLocation(String.format("POINT(%s %s)", destination[1], destination[0]));
        }

        Ride saved = rideRepository.save(ride);
        log.info("Created ride: {}", saved.getId());
        return toRideResponse(saved);
    }

    /**
     * Validate driver eligibility before creating a ride.
     */
    private void validateDriverEligibility(UUID userId) {
        var driverProfile = driverProfileRepository.findByUserId(userId);
        if (driverProfile.isEmpty()) {
            throw new NimbusException(ErrorCode.DRIVER_NOT_FOUND, HttpStatus.NOT_FOUND);
        }

        DriverProfile profile = driverProfile.get();

        // Check driver approval status
        if (profile.getApprovalStatus() != DriverProfile.ApprovalStatus.APPROVED) {
            throw new NimbusException(ErrorCode.DRIVER_NOT_APPROVED,
                    "Driver must be approved before creating rides", HttpStatus.FORBIDDEN);
        }

        // Check for suspension/ban
        if (profile.getApprovalStatus() == DriverProfile.ApprovalStatus.SUSPENDED) {
            throw new NimbusException(ErrorCode.DRIVER_NOT_ELIGIBLE,
                    "Driver is suspended", HttpStatus.FORBIDDEN);
        }

        // Check documents not expired
        if (profile.getLicenseExpiry() != null && profile.getLicenseExpiry().isBefore(Instant.now())) {
            throw new NimbusException(ErrorCode.DRIVER_DOCUMENT_EXPIRED, HttpStatus.FORBIDDEN);
        }

        // Check no outstanding due (previous-day due blocks new eligibility)
        if (profile.getDueAmount() != null &&
                profile.getDueAmount().compareTo(BigDecimal.ZERO) > 0) {
            throw new NimbusException(ErrorCode.DRIVER_DUE_PENDING, HttpStatus.FORBIDDEN);
        }
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
            ride.setOriginLocation(String.format("POINT(%s %s)", origin[1], origin[0]));
        }
        if (destination != null && destination.length >= 2) {
            ride.setDestinationLocation(String.format("POINT(%s %s)", destination[1], destination[0]));
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

        // Check vehicle exists and is approved
        if (ride.getVehicleId() != null) {
            var vehicleOpt = vehicleRepository.findById(ride.getVehicleId());
            if (vehicleOpt.isEmpty()) {
                throw new NimbusException(ErrorCode.VEHICLE_NOT_FOUND, HttpStatus.NOT_FOUND);
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
        // In a full implementation, this would use PostGIS spatial queries
        // and the matching engine for scoring
        List<Ride> rides = rideRepository.findSearchableRides(
                Ride.RideStatus.PUBLISHED,
                Ride.RideType.SCHEDULED
        );

        return rides.stream()
                .filter(ride -> isWithinSearchRadius(ride, originLat, originLng, destLat, destLng))
                .filter(ride -> isTimeCompatible(ride, time))
                .map(this::toRideResponse)
                .collect(Collectors.toList());
    }

    private boolean isWithinSearchRadius(Ride ride, Double originLat, Double originLng,
                                         Double destLat, Double destLng) {
        // Simple proximity check for now
        return true;
    }

    private boolean isTimeCompatible(Ride ride, Instant time) {
        if (time == null || ride.getScheduledAt() == null) return true;
        long diffMinutes = Math.abs(ride.getScheduledAt().toEpochMilli() - time.toEpochMilli()) / 60000;
        return diffMinutes <= 30; // Within 30 minutes
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

        ride.setStatus(Ride.RideStatus.ROUTE_LOCKED);
        ride.setRouteVersion(ride.getRouteVersion() + 1);
        ride.setActualStartAt(Instant.now());
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);

        log.info("Locked route for ride: {}", rideId);
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

        if (ride.getStatus() != Ride.RideStatus.ROUTE_LOCKED) {
            throw new NimbusException(ErrorCode.RIDE_INVALID_STATE_TRANSITION,
                    "Ride must be ROUTE_LOCKED to start", HttpStatus.CONFLICT);
        }

        ride.setStatus(Ride.RideStatus.IN_PROGRESS);
        ride.setActualStartAt(Instant.now());
        ride.setUpdatedAt(Instant.now());
        rideRepository.save(ride);

        log.info("Started ride: {}", rideId);
        return toRideResponse(ride);
    }

    /**
     * Complete a ride.
     */
    @Transactional
    public RideResponse completeRide(UUID rideId, UUID userId) {
        Ride ride = rideRepository.findById(rideId)
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

        log.info("Completed ride: {}", rideId);
        return toRideResponse(ride);
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

        ride.setUpdatedAt(Instant.now());
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
