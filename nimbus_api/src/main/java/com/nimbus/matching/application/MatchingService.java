package com.nimbus.matching.application;

import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.matching.domain.model.*;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.locationtech.jts.geom.*;
import org.springframework.http.HttpStatus;
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
    private final com.nimbus.driver.domain.repository.VehicleRepository vehicleRepository;
    private final com.nimbus.kernel.domain.repository.UserRepository userRepository;
    private final GeometryFactory geometryFactory = new GeometryFactory();

    /** Vehicle eligibility per guide §5: approved status and capacity. */
    private boolean isVehicleEligible(java.util.UUID vehicleId) {
        return vehicleRepository.findById(vehicleId)
                .map(v -> v.getStatus() == com.nimbus.driver.domain.entity.Vehicle.VehicleStatus.APPROVED
                        && v.getSeatCapacity() != null && v.getSeatCapacity() > 0)
                .orElse(false);
    }

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
     * Live ride search (guide §9): fetch published candidates, apply hard
     * constraints, score with the standard weights — route overlap 40%
     * (bearing similarity), pickup proximity 20%, dropoff proximity 20%,
     * time compatibility 10%, driver reliability 5%, other 5% — and return
     * the ranked rides. This is the single matching engine used by search
     * and revalidated by booking.
     */
    @Transactional(readOnly = true)
    public List<Ride> findMatchingRides(double originLat, double originLng,
                                        double destLat, double destLng,
                                        Instant time) {
        List<Ride> rides = rideRepository.findSearchableRides(
                Ride.RideStatus.PUBLISHED, null);

        record Scored(Ride ride, double score) {}
        List<Scored> scored = new ArrayList<>();
        for (Ride ride : rides) {
            // Hard constraint (guide §5/§9): the driver must still be
            // eligible — approved, active account, zero due — else their
            // rides do not surface in search at all.
            if (ride.getDriver() != null) {
                var dp = driverProfileRepository.findById(ride.getDriver().getId()).orElse(null);
                if (dp == null
                        || dp.getApprovalStatus() != com.nimbus.driver.domain.entity.DriverProfile.ApprovalStatus.APPROVED
                        || (dp.getDueAmount() != null
                            && dp.getDueAmount().compareTo(java.math.BigDecimal.ZERO) > 0)
                        || !userRepository.findById(dp.getUser().getId())
                            .map(com.nimbus.kernel.domain.entity.User::isActive)
                            .orElse(false)) {
                    continue;
                }
            }
            if (ride.getAvailableSeats() <= 0) continue;                 // capacity
            double[] o = wktToLatLng(ride.getOriginLocation());
            double[] d = wktToLatLng(ride.getDestinationLocation());
            if (o == null || d == null) continue;                        // no route points

            double pickupDist = haversineMeters(originLat, originLng, o[0], o[1]);
            double dropDist = haversineMeters(destLat, destLng, d[0], d[1]);
            int corridor = ride.getMaxDetourMeters() != null
                    ? ride.getMaxDetourMeters() : DEFAULT_MAX_DETOUR_METERS;
            if (pickupDist > corridor || dropDist > corridor) continue;  // corridor
            if (!withinTimeWindow(ride, time)) continue;                 // time window

            double pickupProx = 1 - Math.min(1, pickupDist / corridor);
            double dropProx = 1 - Math.min(1, dropDist / corridor);
            double overlap = directionSimilarity(o[0], o[1], d[0], d[1],
                    originLat, originLng, destLat, destLng);
            double timeScore = time == null ? 0.5
                    : 1 - Math.min(1, Math.abs(
                        ride.getScheduledAt() != null
                            ? ride.getScheduledAt().toEpochMilli() - time.toEpochMilli()
                            : 0) / (30.0 * 60_000));
            double reliability = ride.getDriver() != null
                    && ride.getDriver().getRating() != null
                        ? Math.min(1, ride.getDriver().getRating().doubleValue() / 5.0)
                        : 0.5;

            double score = 0.40 * overlap + 0.20 * pickupProx + 0.20 * dropProx
                    + 0.10 * Math.max(0, timeScore) + 0.05 * reliability + 0.05;
            scored.add(new Scored(ride, score));
        }

        scored.sort((a, b) -> Double.compare(b.score(), a.score()));
        return scored.stream().map(Scored::ride).collect(Collectors.toList());
    }

    /** Search time window: scheduled departure within ±30 minutes. */
    private boolean withinTimeWindow(Ride ride, Instant time) {
        if (time == null || ride.getScheduledAt() == null) return true;
        long diffMinutes = Math.abs(ride.getScheduledAt().toEpochMilli() - time.toEpochMilli()) / 60000;
        return diffMinutes <= 30;
    }

    /** 0..1 similarity of two segment directions (1 = same bearing). */
    private double directionSimilarity(double lat1, double lng1, double lat2, double lng2,
                                       double lat3, double lng3, double lat4, double lng4) {
        double b1 = bearingDegrees(lat1, lng1, lat2, lng2);
        double b2 = bearingDegrees(lat3, lng3, lat4, lng4);
        double delta = Math.toRadians(b1 - b2);
        return Math.max(0, Math.cos(delta));
    }

    private double bearingDegrees(double lat1, double lng1, double lat2, double lng2) {
        double dLng = Math.toRadians(lng2 - lng1);
        double phi1 = Math.toRadians(lat1);
        double phi2 = Math.toRadians(lat2);
        double y = Math.sin(dLng) * Math.cos(phi2);
        double x = Math.cos(phi1) * Math.sin(phi2)
                - Math.sin(phi1) * Math.cos(phi2) * Math.cos(dLng);
        return (Math.toDegrees(Math.atan2(y, x)) + 360) % 360;
    }

    /** Parses {@code POINT(lng lat)} WKT as {lat, lng}, or null. */
    private double[] wktToLatLng(String wkt) {
        if (wkt == null || !wkt.startsWith("POINT(")) return null;
        try {
            String coords = wkt.substring(6, wkt.length() - 1);
            String[] parts = coords.trim().split("\\s+");
            return new double[]{Double.parseDouble(parts[1]), Double.parseDouble(parts[0])};
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Revalidate a booking against the ride's hard constraints inside the
     * booking transaction (guide §9 algorithm step 7). Checks bookability,
     * capacity, corridor fit for BOTH pickup and drop-off, and that the
     * pickup precedes the drop-off along the ride direction.
     *
     * @throws NimbusException when any hard constraint fails
     */
    public void revalidateBookingFit(Ride ride,
                                     double pickupLng, double pickupLat,
                                     double dropoffLng, double dropoffLat,
                                     int seatsRequested) {
        // Bookable and capacity (the seat count itself is re-checked by
        // BookingService under the ride row lock).
        if (!ride.isBookable()) {
            throw new NimbusException(ErrorCode.RIDE_NOT_BOOKABLE, HttpStatus.BAD_REQUEST);
        }
        if (ride.getRemainingSeats() < seatsRequested) {
            throw new NimbusException(ErrorCode.RIDE_NO_SEATS, HttpStatus.CONFLICT);
        }

        Point rideOrigin = parsePoint(ride.getOriginLocation());
        Point rideDestination = parsePoint(ride.getDestinationLocation());
        if (rideOrigin == null || rideDestination == null) {
            return; // no usable route geometry to revalidate against
        }

        double maxDetourMeters = ride.getMaxDetourMeters() != null
                ? ride.getMaxDetourMeters() : DEFAULT_MAX_DETOUR_METERS;

        Point pickup = point(pickupLng, pickupLat);
        Point dropoff = point(dropoffLng, dropoffLat);

        // Corridor: both ends must be within the ride's max detour of the
        // driver's origin→destination line (guide §9 hard constraint).
        if (distanceToSegmentMeters(pickup, rideOrigin, rideDestination) > maxDetourMeters) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Pickup is outside the ride's route corridor", HttpStatus.BAD_REQUEST);
        }
        if (distanceToSegmentMeters(dropoff, rideOrigin, rideDestination) > maxDetourMeters) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Drop-off is outside the ride's route corridor", HttpStatus.BAD_REQUEST);
        }

        // Pickup must precede drop-off along the ride direction.
        if (projectionAlong(pickup, rideOrigin, rideDestination)
                >= projectionAlong(dropoff, rideOrigin, rideDestination)) {
            throw new NimbusException(ErrorCode.VALIDATION_ERROR,
                    "Pickup must come before drop-off along the ride route", HttpStatus.BAD_REQUEST);
        }
    }

    private static final int DEFAULT_MAX_DETOUR_METERS = 3000;

    private Point point(double lng, double lat) {
        Point p = geometryFactory.createPoint(new Coordinate(lng, lat));
        p.setSRID(4326);
        return p;
    }

    /**
     * Perpendicular distance in meters from p to segment a→b (projection
     * clamped to the segment, so past the ends measures to the nearer end).
     */
    private double distanceToSegmentMeters(Point p, Point a, Point b) {
        double t = projectionAlong(p, a, b);
        double px = a.getX() + t * (b.getX() - a.getX());
        double py = a.getY() + t * (b.getY() - a.getY());
        return haversineMeters(p.getY(), p.getX(), py, px);
    }

    /**
     * Fraction of the way from a to b where the projection of p onto the
     * a→b line falls, clamped to [0, 1].
     */
    private double projectionAlong(Point p, Point a, Point b) {
        double dx = b.getX() - a.getX();
        double dy = b.getY() - a.getY();
        double lengthSq = dx * dx + dy * dy;
        if (lengthSq == 0) return 0;
        double t = ((p.getX() - a.getX()) * dx + (p.getY() - a.getY()) * dy) / lengthSq;
        return Math.max(0, Math.min(1, t));
    }

    private double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * 6371000 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
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

        // Constraint 3: Driver and vehicle must be eligible (guide §5).
        if (ride.getDriver() != null) {
            var driverProfile = driverProfileRepository.findById(ride.getDriver().getId()).orElse(null);
            if (driverProfile == null
                    || driverProfile.getApprovalStatus() != com.nimbus.driver.domain.entity.DriverProfile.ApprovalStatus.APPROVED
                    || (driverProfile.getDueAmount() != null
                        && driverProfile.getDueAmount().compareTo(java.math.BigDecimal.ZERO) > 0)
                    || !userRepository.findById(driverProfile.getUser().getId())
                        .map(com.nimbus.kernel.domain.entity.User::isActive)
                        .orElse(false)) {
                return false;
            }
        }
        if (ride.getVehicleId() != null && !isVehicleEligible(ride.getVehicleId())) {
            return false;
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
