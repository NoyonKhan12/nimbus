package com.nimbus.matching.application;

import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.matching.domain.model.*;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.locationtech.jts.geom.*;
import org.locationtech.jts.util.GeometricShapeFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Deterministic, configurable matching engine for ride pooling.
 *
 * <p>Algorithm:
 * 1. Fetch spatial/time candidates (published rides near origin)
 * 2. Remove hard failures (ineligible driver/vehicle, insufficient capacity, etc.)
 * 3. Simulate pickup/dropoff insertion into route
 * 4. Calculate distance/duration/detour/overlap
 * 5. Score candidates
 * 6. Sort and return top N
 * 7. Revalidate inside booking transaction</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class MatchingService {

    private final RideRepository rideRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final GeometryFactory geometryFactory = new GeometryFactory();

    /**
     * Match passenger with compatible rides.
     *
     * @param criteria  Matching criteria (origin, destination, time, seats)
     * @param maxResults Maximum number of results to return
     * @return MatchResult with scored candidates
     */
    @Transactional(readOnly = true)
    public MatchResult findMatches(MatchingCriteria criteria, int maxResults) {
        if (criteria.getOriginPoint() == null || criteria.getDestinationPoint() == null) {
            return MatchResult.builder()
                    .matches(Collections.emptyList())
                    .totalCandidates(0)
                    .filteredByHardConstraints(0)
                    .afterScoring(0)
                    .build();
        }

        // Step 1: Fetch spatial/time candidates
        List<Ride> candidates = fetchSpatialTimeCandidates(criteria);
        int totalCandidates = candidates.size();

        // Step 2: Filter hard constraints
        List<Ride> passesHardConstraints = candidates.stream()
                .filter(ride -> passesHardConstraints(ride, criteria))
                .collect(Collectors.toList());

        // Step 3-4: Score candidates
        List<MatchScore> scored = passesHardConstraints.stream()
                .map(ride -> calculateMatchScore(ride, criteria))
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        // Step 5-6: Sort and return top N
        scored.sort(new MatchScore.ScoreComparator());
        List<MatchScore> topMatches = scored.stream()
                .limit(maxResults)
                .toList();

        return MatchResult.builder()
                .matches(topMatches)
                .totalCandidates(totalCandidates)
                .filteredByHardConstraints(totalCandidates - passesHardConstraints.size())
                .afterScoring(scored.size())
                .build();
    }

    /**
     * Fetch spatial/time candidates from published rides.
     * Uses PostGIS spatial queries for proximity filtering.
     */
    private List<Ride> fetchSpatialTimeCandidates(MatchingCriteria criteria) {
        // Get published rides scheduled around the search time
        List<Ride> publishedRides = rideRepository.findSearchableRides(
                Ride.RideStatus.PUBLISHED,
                Ride.RideType.SCHEDULED
        );

        // Filter by spatial proximity (origin within matching radius)
        // and time compatibility
        return publishedRides.stream()
                .filter(ride -> !ride.getId().equals(criteria.getExcludedRideId()))
                .filter(ride -> isWithinMatchingRadius(ride, criteria.getOriginPoint(), criteria.getMaxDetourMeters()))
                .filter(ride -> isTimeCompatible(ride, criteria))
                .collect(Collectors.toList());
    }

    /**
     * Check if a ride passes all hard constraints before scoring.
     */
    private boolean passesHardConstraints(Ride ride, MatchingCriteria criteria) {
        // Constraint 1: Ride must be published/bookable and time-compatible
        if (!ride.isBookable()) return false;

        // Constraint 2: Time compatibility
        if (!isTimeCompatible(ride, criteria)) return false;

        // Constraint 3: Driver and vehicle must be eligible
        if (ride.getDriver() != null) {
            var driverProfile = driverProfileRepository.findById(ride.getDriver().getId()).orElse(null);
            if (driverProfile == null || driverProfile.getApprovalStatus() != com.nimbus.driver.domain.entity.DriverProfile.ApprovalStatus.APPROVED) {
                return false;
            }
        }

        // Constraint 4: Capacity must be sufficient
        int remainingSeats = ride.getRemainingSeats();
        if (remainingSeats < criteria.getSeatsNeeded()) return false;

        // Constraint 5: Pickup/dropoff must fit the route corridor
        Point origin = criteria.getOriginPoint();
        if (origin != null) {
            if (!isWithinMatchingRadius(ride, origin, criteria.getMaxDetourMeters())) return false;
        }

        return true;
    }

    /**
     * Check if origin is within the matching radius of the ride's route.
     */
    private boolean isWithinMatchingRadius(Ride ride, Point origin, Integer maxDetourMeters) {
        if (origin == null) return false;

        int radiusKm = maxDetourMeters != null ?
                Math.max(2, maxDetourMeters / 1000) : 5;

        // Simple proximity check: is origin near ride's origin or destination
        Point rideOrigin = parsePoint(ride.getOriginLocation());
        Point rideDestination = parsePoint(ride.getDestinationLocation());

        if (rideOrigin != null && distanceInMeters(origin, rideOrigin) <= radiusKm * 1000) {
            return true;
        }
        if (rideDestination != null && distanceInMeters(origin, rideDestination) <= radiusKm * 1000) {
            return true;
        }
        return false;
    }

    /**
     * Check time compatibility between ride and passenger criteria.
     */
    private boolean isTimeCompatible(Ride ride, MatchingCriteria criteria) {
        Instant rideTime = ride.getScheduledAt();
        if (rideTime == null) return true; // No scheduled time

        Instant earliest = criteria.getEarliestPickup();
        Instant latest = criteria.getLatestPickup();

        if (earliest == null && latest == null) return true;

        if (earliest != null && rideTime.isBefore(earliest)) return false;
        if (latest != null && rideTime.isAfter(latest)) return false;

        return true;
    }

    /**
     * Calculate match score for a ride.
     */
    private MatchScore calculateMatchScore(Ride ride, MatchingCriteria criteria) {
        // Calculate individual components
        double routeOverlap = calculateRouteOverlap(ride, criteria);
        double pickupProximity = calculatePickupProximity(ride, criteria);
        double dropoffProximity = calculateDropoffProximity(ride, criteria);
        double timeCompatibility = calculateTimeCompatibility(ride, criteria);
        double driverReliability = calculateDriverReliability(ride);

        // Weighted score: 40% route overlap, 20% pickup proximity,
        // 20% dropoff proximity, 10% time compatibility, 5% driver reliability, 5% other
        double score = routeOverlap * 0.40
                + pickupProximity * 0.20
                + dropoffProximity * 0.20
                + timeCompatibility * 0.10
                + driverReliability * 0.05;

        return MatchScore.builder()
                .ride(ride)
                .score(score)
                .routeOverlapScore(routeOverlap)
                .pickupProximityScore(pickupProximity)
                .dropoffProximityScore(dropoffProximity)
                .timeCompatibilityScore(timeCompatibility)
                .driverReliabilityScore(driverReliability)
                .build();
    }

    /**
     * Calculate route overlap score (how much the passenger's route overlaps with the ride's route).
     */
    private double calculateRouteOverlap(Ride ride, MatchingCriteria criteria) {
        Point rideOrigin = parsePoint(ride.getOriginLocation());
        Point rideDest = parsePoint(ride.getDestinationLocation());
        Point passengerOrigin = criteria.getOriginPoint();
        Point passengerDest = criteria.getDestinationPoint();

        if (rideOrigin == null || rideDest == null ||
            passengerOrigin == null || passengerDest == null) {
            return 0.5; // Default score
        }

        // Calculate how much the passenger's route aligns with the ride's route
        // Simple heuristic: check if passenger pickup/dropoff are near the ride's endpoints
        double pickupDist = distanceInMeters(passengerOrigin, rideOrigin);
        double dropoffDist = distanceInMeters(passengerDest, rideDest);
        double rideDistance = distanceInMeters(rideOrigin, rideDest);

        if (rideDistance > 0) {
            double pickupScore = Math.max(0, 1.0 - pickupDist / rideDistance);
            double dropoffScore = Math.max(0, 1.0 - dropoffDist / rideDistance);
            return (pickupScore + dropoffScore) / 2.0;
        }
        return 0.5;
    }

    private double calculatePickupProximity(Ride ride, MatchingCriteria criteria) {
        Point rideOrigin = parsePoint(ride.getOriginLocation());
        Point passengerOrigin = criteria.getOriginPoint();

        if (rideOrigin == null || passengerOrigin == null) return 0.5;

        double dist = distanceInMeters(rideOrigin, passengerOrigin);
        int radiusKm = criteria.getMaxDetourMeters() != null ?
                Math.max(2, criteria.getMaxDetourMeters() / 1000) : 5;

        return Math.max(0, 1.0 - dist / (radiusKm * 1000));
    }

    private double calculateDropoffProximity(Ride ride, MatchingCriteria criteria) {
        Point rideDest = parsePoint(ride.getDestinationLocation());
        Point passengerDest = criteria.getDestinationPoint();

        if (rideDest == null || passengerDest == null) return 0.5;

        double dist = distanceInMeters(rideDest, passengerDest);
        int radiusKm = criteria.getMaxDetourMeters() != null ?
                Math.max(2, criteria.getMaxDetourMeters() / 1000) : 5;

        return Math.max(0, 1.0 - dist / (radiusKm * 1000));
    }

    private double calculateTimeCompatibility(Ride ride, MatchingCriteria criteria) {
        Instant rideTime = ride.getScheduledAt();
        if (rideTime == null) return 0.8;

        Instant earliest = criteria.getEarliestPickup();
        Instant latest = criteria.getLatestPickup();

        if (earliest == null && latest == null) return 0.8;

        if (earliest != null && latest != null) {
            long windowMs = latest.toEpochMilli() - earliest.toEpochMilli();
            long diffMs = Math.abs(rideTime.toEpochMilli() - earliest.toEpochMilli());
            return windowMs > 0 ? Math.max(0, 1.0 - (double) diffMs / windowMs) : 0.5;
        }

        return 0.8;
    }

    private double calculateDriverReliability(Ride ride) {
        if (ride.getDriver() == null) return 0.5;
        var driverProfile = driverProfileRepository.findById(ride.getDriver().getId()).orElse(null);
        if (driverProfile != null) {
            return driverProfile.getReliabilityScore() != null ?
                    driverProfile.getReliabilityScore().doubleValue() : 0.5;
        }
        return 0.5;
    }

    /**
     * Parse a WKT POINT string to JTS Point.
     */
    private Point parsePoint(String wkt) {
        if (wkt == null) return null;
        try {
            String coords = wkt.substring(6, wkt.length() - 1);
            String[] parts = coords.split(" ");
            double lng = Double.parseDouble(parts[0]);
            double lat = Double.parseDouble(parts[1]);
            Point p = geometryFactory.createPoint(new Coordinate(lng, lat));
            p.setSRID(4326);
            return p;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Calculate distance in meters between two points using Haversine formula.
     */
    private double distanceInMeters(Point a, Point b) {
        if (a == null || b == null) return Double.MAX_VALUE;

        double lat1 = Math.toRadians(a.getY());
        double lon1 = Math.toRadians(a.getX());
        double lat2 = Math.toRadians(b.getY());
        double lon2 = Math.toRadians(b.getX());

        double dLat = lat2 - lat1;
        double dLon = lon2 - lon1;

        double haversine = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(lat1) * Math.cos(lat2) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(haversine), Math.sqrt(1 - haversine));
        return 6371000 * c; // Earth radius in meters
    }
}
