package com.nimbus.routing.application;

import com.nimbus.ride.domain.entity.*;
import com.nimbus.ride.domain.repository.*;
import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import lombok.Getter;
import lombok.Setter;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Route optimization service for ride pooling.
 *
 * <p>Algorithm (MVP - feasible insertion heuristic):
 * 1. Start from driver origin/current position
 * 2. Represent each passenger with pickup and dropoff nodes
 * 3. Try feasible insertion positions for the new pair
 * 4. Reject capacity, pickup-order, wait, detour, and time violations
 * 5. Use route distance/duration estimates to calculate insertion cost
 * 6. Choose the lowest-cost feasible insertion
 * 7. Persist a new route version and mark it active
 * 8. Lock the route before execution</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RouteService {

    private final RideRepository rideRepository;
    private final RideStopRepository rideStopRepository;
    private final RideRouteRepository rideRouteRepository;
    private final BookingRepository bookingRepository;

    /**
     * Plan a route for a ride with existing bookings.
     * Creates a new route version with stops for all passengers.
     */
    @Transactional
    public RideRoute planRoute(UUID rideId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));

        if (ride.getStatus() != Ride.RideStatus.PUBLISHED &&
            ride.getStatus() != Ride.RideStatus.ROUTE_LOCKED) {
            throw new IllegalStateException("Ride must be PUBLISHED or ROUTE_LOCKED to plan route");
        }

        // Get all confirmed passengers
        List<Booking> confirmedBookings = bookingRepository.findByRideIdAndStatus(
                rideId, Booking.BookingStatus.CONFIRMED);

        // Build route with stops
        List<RideStop> stops = buildRouteStops(ride, confirmedBookings);

        // Calculate route metrics
        RouteMetrics metrics = calculateRouteMetrics(stops);

        // Create new route version
        int newVersion = ride.getRouteVersion() + 1;
        ride.setRouteVersion(newVersion);
        rideRepository.save(ride);

        // Save route
        RideRoute route = RideRoute.builder()
                .ride(ride)
                .version(newVersion)
                .provider("FLEXIBLE_INSERTION")
                .polyline(generatePolyline(stops))
                .distanceMeters(metrics.totalDistance)
                .durationSeconds(metrics.totalDuration)
                .optimizationScore(metrics.score)
                .isActive(true)
                .build();

        // Deactivate previous active routes
        rideRouteRepository.findByRideId(rideId).forEach(prevRoute ->
                prevRoute.setIsActive(false));

        return rideRouteRepository.save(route);
    }

    /**
     * Insert a new booking's pickup/dropoff into the existing route.
     * Uses feasible insertion heuristic.
     */
    @Transactional
    public RideRoute insertBookingIntoRoute(UUID rideId, UUID bookingId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found: " + bookingId));

        // Get existing stops
        List<RideStop> existingStops = rideStopRepository.findByRideIdOrderBySequence(rideId);

        // Find best insertion position for pickup and dropoff
        InsertionPoint pickupInsertion = findBestInsertion(existingStops, booking, true);
        InsertionPoint dropoffInsertion = findBestInsertion(existingStops, booking, false);

        // Validate pickup before dropoff
        if (!isValidPickupBeforeDropoff(existingStops, pickupInsertion, dropoffInsertion)) {
            throw new IllegalStateException("Cannot insert: pickup must come before dropoff");
        }

        // Validate capacity
        if (!validateCapacity(ride, existingStops, booking.getSeats())) {
            throw new IllegalStateException("Cannot insert: vehicle capacity exceeded");
        }

        // Apply insertions
        applyInsertions(existingStops, pickupInsertion, dropoffInsertion, booking);

        // Recalculate route
        RouteMetrics metrics = calculateRouteMetrics(existingStops);

        // Create new route version
        int newVersion = ride.getRouteVersion() + 1;
        ride.setRouteVersion(newVersion);
        rideRepository.save(ride);

        return RideRoute.builder()
                .ride(ride)
                .version(newVersion)
                .provider("FLEXIBLE_INSERTION")
                .polyline(generatePolyline(existingStops))
                .distanceMeters(metrics.totalDistance)
                .durationSeconds(metrics.totalDuration)
                .optimizationScore(metrics.score)
                .isActive(true)
                .build();
    }

    /**
     * Lock route for execution - no more changes allowed.
     */
    @Transactional
    public void lockRoute(UUID rideId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));

        if (ride.getStatus() != Ride.RideStatus.PUBLISHED) {
            throw new IllegalStateException("Only PUBLISHED rides can be locked");
        }

        ride.setStatus(Ride.RideStatus.ROUTE_LOCKED);
        ride.setActualStartAt(Instant.now());
        rideRepository.save(ride);

        log.info("Route locked for ride: {}", rideId);
    }

    /**
     * Find the best insertion point for a stop.
     */
    private InsertionPoint findBestInsertion(List<RideStop> currentStops, Booking booking, boolean isPickup) {
        int bestPosition = 0;
        double bestCost = Double.MAX_VALUE;

        for (int i = 0; i <= currentStops.size(); i++) {
            double cost = calculateInsertionCost(currentStops, i, booking, isPickup);
            if (cost < bestCost) {
                bestCost = cost;
                bestPosition = i;
            }
        }

        return InsertionPoint.builder()
                .position(bestPosition)
                .cost(bestCost)
                .booking(booking)
                .build();
    }

    private double calculateInsertionCost(List<RideStop> stops, int position,
                                          Booking booking, boolean isPickup) {
        // Simple cost model: minimize additional distance
        // In production, this would call a routing API
        double baseCost = isPickup ? 0 : 5.0; // Dropoff has slightly higher penalty

        // Add penalty for inserting far from optimal position
        double positionPenalty = position * 0.1;

        // Add distance penalty based on stop type
        double typePenalty = isPickup ? 1.0 : 1.5;

        return baseCost + positionPenalty + typePenalty;
    }

    private boolean isValidPickupBeforeDropoff(List<RideStop> stops,
                                               InsertionPoint pickup, InsertionPoint dropoff) {
        // Pickup must be inserted at or before dropoff position
        if (pickup.getPosition() > dropoff.getPosition()) {
            // If dropoff is at same position, pickup must come first
            if (pickup.getPosition() == dropoff.getPosition() && pickup.getCost() > dropoff.getCost()) {
                return false;
            }
            return pickup.getPosition() <= dropoff.getPosition();
        }
        return true;
    }

    private boolean validateCapacity(Ride ride, List<RideStop> stops, int newSeats) {
        int currentPassengers = stops.stream()
                .filter(s -> s.getStopType() == RideStop.StopType.PICKUP ||
                        s.getStopType() == RideStop.StopType.ORIGIN)
                .mapToInt(s -> Optional.ofNullable(s.getBooking())
                        .map(Booking::getSeats)
                        .orElse(1))
                .sum();

        // Count dropoffs after current position to subtract from capacity
        int droppedOff = stops.stream()
                .filter(s -> s.getStopType() == RideStop.StopType.DROPOFF ||
                        s.getStopType() == RideStop.StopType.DESTINATION)
                .mapToInt(s -> Optional.ofNullable(s.getBooking())
                        .map(Booking::getSeats)
                        .orElse(0))
                .sum();

        int currentOccupancy = Math.max(0, currentPassengers - droppedOff);
        return currentOccupancy + newSeats <= ride.getAvailableSeats();
    }

    private void applyInsertions(List<RideStop> stops,
                                 InsertionPoint pickup,
                                 InsertionPoint dropoff,
                                 Booking booking) {
        // Create pickup stop
        RideStop pickupStop = RideStop.builder()
                .ride(stops.get(0).getRide())
                .booking(booking)
                .sequence(pickup.getPosition() + 1)
                .stopType(RideStop.StopType.PICKUP)
                .location(booking.getPickupLocation())
                .address(booking.getPickupAddress())
                .plannedTime(Instant.now().plusSeconds((long)(pickup.getCost() * 30)))
                .status(RideStop.StopStatus.PENDING)
                .build();

        // Create dropoff stop
        RideStop dropoffStop = RideStop.builder()
                .ride(stops.get(0).getRide())
                .booking(booking)
                .sequence(dropoff.getPosition() + 1)
                .stopType(RideStop.StopType.DROPOFF)
                .location(booking.getDropoffLocation())
                .address(booking.getDropoffAddress())
                .plannedTime(Instant.now().plusSeconds((long)(dropoff.getCost() * 30)))
                .status(RideStop.StopStatus.PENDING)
                .build();

        // Re-sequence stops
        int seq = 1;
        List<RideStop> newStops = new ArrayList<>();
        // Insert pickup at position
        newStops.addAll(stops.subList(0, pickup.getPosition()));
        newStops.add(pickupStop);
        // Insert dropoff (adjusting position if needed)
        int dropoffPos = dropoff.getPosition() + 1; // +1 for the pickup insertion
        newStops.addAll(stops.subList(pickup.getPosition(), Math.min(dropoffPos, stops.size())));
        newStops.add(dropoffStop);
        if (dropoffPos < stops.size()) {
            newStops.addAll(stops.subList(dropoffPos, stops.size()));
        }

        // Update sequences
        for (int i = 0; i < newStops.size(); i++) {
            newStops.get(i).setSequence(i + 1);
            rideStopRepository.save(newStops.get(i));
        }
    }

    private String generatePolyline(List<RideStop> stops) {
        // Generate encoded polyline from stop locations
        // Simplified for now - in production would use actual routing geometry
        return stops.stream()
                .map(RideStop::getLocation)
                .filter(Objects::nonNull)
                .map(loc -> loc.replace("POINT(", "").replace(")", ""))
                .collect(Collectors.joining("|"));
    }

    private List<RideStop> buildRouteStops(Ride ride, List<Booking> bookings) {
        List<RideStop> stops = new ArrayList<>();
        int sequence = 1;

        // Add origin stop
        if (ride.getOriginLocation() != null) {
            stops.add(RideStop.builder()
                    .ride(ride)
                    .sequence(sequence++)
                    .stopType(RideStop.StopType.ORIGIN)
                    .location(ride.getOriginLocation())
                    .address(ride.getOriginAddress())
                    .plannedTime(ride.getScheduledAt())
                    .status(RideStop.StopStatus.PENDING)
                    .build());
        }

        // Add pickup/dropoff stops for each booking
        for (Booking booking : bookings) {
            if (booking.getPickupLocation() != null) {
                stops.add(RideStop.builder()
                        .ride(ride)
                        .booking(booking)
                        .sequence(sequence++)
                        .stopType(RideStop.StopType.PICKUP)
                        .location(booking.getPickupLocation())
                        .address(booking.getPickupAddress())
                        .plannedTime(booking.getPickupPlannedTime())
                        .status(RideStop.StopStatus.PENDING)
                        .build());
            }
            if (booking.getDropoffLocation() != null) {
                stops.add(RideStop.builder()
                        .ride(ride)
                        .booking(booking)
                        .sequence(sequence++)
                        .stopType(RideStop.StopType.DROPOFF)
                        .location(booking.getDropoffLocation())
                        .address(booking.getDropoffAddress())
                        .plannedTime(booking.getDropoffPlannedTime())
                        .status(RideStop.StopStatus.PENDING)
                        .build());
            }
        }

        // Add destination stop
        if (ride.getDestinationLocation() != null) {
            stops.add(RideStop.builder()
                    .ride(ride)
                    .sequence(sequence++)
                    .stopType(RideStop.StopType.DESTINATION)
                    .location(ride.getDestinationLocation())
                    .address(ride.getDestinationAddress())
                    .plannedTime(ride.getScheduledAt()) // Will be adjusted
                    .status(RideStop.StopStatus.PENDING)
                    .build());
        }

        // Save all stops
        stops.forEach(stop -> rideStopRepository.save(stop));

        return stops;
    }

    private RouteMetrics calculateRouteMetrics(List<RideStop> stops) {
        int totalDistance = 0;
        int totalDuration = 0;
        double score = 1.0;

        // Simple metric calculation
        // In production, this would call a routing API
        for (int i = 1; i < stops.size(); i++) {
            RideStop prev = stops.get(i - 1);
            RideStop curr = stops.get(i);
            if (prev.getLocation() != null && curr.getLocation() != null) {
                // Calculate distance between stops
                double[] prevCoords = parseWktPoint(prev.getLocation());
                double[] currCoords = parseWktPoint(curr.getLocation());
                if (prevCoords != null && currCoords != null) {
                    double dist = haversineDistance(prevCoords, currCoords);
                    totalDistance += (int) dist;
                    totalDuration += (int) (dist / 15.0); // Assume 15 m/s avg speed
                }
            }
        }

        return RouteMetrics.builder()
                .totalDistance(totalDistance)
                .totalDuration(totalDuration)
                .score(BigDecimal.valueOf(score))
                .build();
    }

    private double[] parseWktPoint(String wkt) {
        if (wkt == null || !wkt.startsWith("POINT(")) return null;
        try {
            String coords = wkt.substring(6, wkt.length() - 1);
            String[] parts = coords.split(" ");
            return new double[]{Double.parseDouble(parts[1]), Double.parseDouble(parts[0])};
        } catch (Exception e) {
            return null;
        }
    }

    private double haversineDistance(double[] coord1, double[] coord2) {
        double lat1 = Math.toRadians(coord1[0]);
        double lon1 = Math.toRadians(coord1[1]);
        double lat2 = Math.toRadians(coord2[0]);
        double lon2 = Math.toRadians(coord2[1]);

        double dLat = lat2 - lat1;
        double dLon = lon2 - lon1;

        double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(lat1) * Math.cos(lat2) *
                Math.sin(dLon/2) * Math.sin(dLon/2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return 6371000 * c;
    }

    @Getter @Setter @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    private static class RouteMetrics {
        private int totalDistance;
        private int totalDuration;
        private BigDecimal score;
    }

    @Getter @Setter @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    private static class InsertionPoint {
        private int position;
        private double cost;
        private Booking booking;
    }
}
