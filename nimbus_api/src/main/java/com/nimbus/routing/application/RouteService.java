package com.nimbus.routing.application;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.booking.domain.repository.BookingRepository;
import com.nimbus.ride.domain.entity.*;
import com.nimbus.ride.domain.repository.*;
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
 * Route optimization service for ride pooling (guide §10).
 *
 * <p>MVP uses a feasible insertion heuristic over the driver's
 * origin→destination line: each pickup/drop-off pair is ordered by its
 * projection along the route so a passenger's pickup always precedes their
 * drop-off, and the resulting stop sequence is persisted as a new immutable
 * route version. The route becomes locked before execution; post-lock
 * changes require the controlled operations path.</p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RouteService {

    private static final String PROVIDER = "FLEXIBLE_INSERTION";
    /** Average city speed used for planned-time estimates (~18 km/h). */
    private static final double AVG_SPEED_MPS = 5.0;

    private final RideRepository rideRepository;
    private final RideStopRepository rideStopRepository;
    private final RideRouteRepository rideRouteRepository;
    private final BookingRepository bookingRepository;

    /**
     * (Re)build the full stop sequence for a ride from its confirmed
     * bookings and persist a new active route version. Idempotent: existing
     * stops are replaced.
     */
    @Transactional
    public RideRoute planRoute(UUID rideId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));

        List<Booking> confirmedBookings = bookingRepository.findByRideIdAndStatus(
                rideId, Booking.BookingStatus.CONFIRMED);

        rideStopRepository.deleteByRideId(rideId);
        rideStopRepository.flush();

        List<Waypoint> waypoints = buildWaypoints(ride, confirmedBookings);
        List<RideStop> stops = persistStops(ride, waypoints);

        return persistRouteVersion(ride, stops);
    }

    /**
     * Insert a newly confirmed booking's pickup/drop-off into the ride's
     * route and persist a new active route version (guide §10: choose the
     * lowest-cost feasible insertion — here, ordering by projection along
     * the driver's line, which preserves pickup-before-dropoff by
     * construction).
     */
    @Transactional
    public RideRoute insertBookingIntoRoute(UUID rideId, UUID bookingId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found: " + bookingId));

        List<RideStop> existing = rideStopRepository.findByRideIdOrderBySequence(rideId);
        if (existing.isEmpty()) {
            // First insertion: build the whole route including this booking.
            List<Booking> confirmed = bookingRepository.findByRideIdAndStatus(
                    rideId, Booking.BookingStatus.CONFIRMED);
            if (confirmed.stream().noneMatch(b -> b.getId().equals(bookingId))) {
                confirmed.add(booking);
            }
            rideStopRepository.deleteByRideId(rideId);
            rideStopRepository.flush();
            List<Waypoint> waypoints = buildWaypoints(ride, confirmed);
            List<RideStop> stops = persistStops(ride, waypoints);
            return persistRouteVersion(ride, stops);
        }

        // Projected position of the new stops along the driver's line.
        double[] origin = parseWktPoint(ride.getOriginLocation());
        double[] dest = parseWktPoint(ride.getDestinationLocation());

        // Collect current sequence as waypoints plus the new pair.
        List<Waypoint> waypoints = new ArrayList<>();
        for (RideStop stop : existing) {
            waypoints.add(new Waypoint(stop.getStopType(), stop.getBooking() != null
                    ? stop.getBooking().getId() : null,
                    parseWktPoint(stop.getLocation()), stop.getAddress(),
                    stop.getPlannedTime()));
        }
        if (origin != null && dest != null) {
            waypoints.add(new Waypoint(RideStop.StopType.PICKUP, booking.getId(),
                    parseWktPoint(booking.getPickupLocation()), booking.getPickupAddress(),
                    plannedTime(origin, dest, booking.getPickupLocation(), ride.getScheduledAt())));
            waypoints.add(new Waypoint(RideStop.StopType.DROPOFF, booking.getId(),
                    parseWktPoint(booking.getDropoffLocation()), booking.getDropoffAddress(),
                    plannedTime(origin, dest, booking.getDropoffLocation(), ride.getScheduledAt())));
        } else {
            // Without route geometry, append pickup then dropoff before the end.
            waypoints.add(new Waypoint(RideStop.StopType.PICKUP, booking.getId(),
                    parseWktPoint(booking.getPickupLocation()), booking.getPickupAddress(),
                    ride.getScheduledAt()));
            waypoints.add(new Waypoint(RideStop.StopType.DROPOFF, booking.getId(),
                    parseWktPoint(booking.getDropoffLocation()), booking.getDropoffAddress(),
                    ride.getScheduledAt()));
        }

        List<RideStop> stops = persistStops(ride, orderWaypoints(waypoints, origin, dest));
        return persistRouteVersion(ride, stops);
    }

    /**
     * Snapshot + persist the execution route before the ride starts
     * (guide §5: route becomes locked before execution). Called from
     * RideService.lockRoute — the status transition stays owned there.
     */
    @Transactional
    public RideRoute lockRouteForExecution(UUID rideId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found: " + rideId));
        List<RideStop> stops = rideStopRepository.findByRideIdOrderBySequence(rideId);
        if (stops.isEmpty()) {
            return planRoute(rideId);
        }
        return rideRouteRepository.findByRideIdAndIsActiveTrue(rideId)
                .orElseGet(() -> persistRouteVersion(ride, stops));
    }

    // ── Internals ────────────────────────────────────────────────────────

    private List<Waypoint> buildWaypoints(Ride ride, List<Booking> bookings) {
        double[] origin = parseWktPoint(ride.getOriginLocation());
        double[] dest = parseWktPoint(ride.getDestinationLocation());

        List<Waypoint> waypoints = new ArrayList<>();
        waypoints.add(new Waypoint(RideStop.StopType.ORIGIN, null, origin,
                ride.getOriginAddress(), ride.getScheduledAt()));

        for (Booking booking : bookings) {
            waypoints.add(new Waypoint(RideStop.StopType.PICKUP, booking.getId(),
                    parseWktPoint(booking.getPickupLocation()), booking.getPickupAddress(),
                    plannedTime(origin, dest, booking.getPickupLocation(), ride.getScheduledAt())));
            waypoints.add(new Waypoint(RideStop.StopType.DROPOFF, booking.getId(),
                    parseWktPoint(booking.getDropoffLocation()), booking.getDropoffAddress(),
                    plannedTime(origin, dest, booking.getDropoffLocation(), ride.getScheduledAt())));
        }

        waypoints.add(new Waypoint(RideStop.StopType.DESTINATION, null, dest,
                ride.getDestinationAddress(), ride.getScheduledAt()));
        return orderWaypoints(waypoints, origin, dest);
    }

    /**
     * Orders waypoints by their projection along the origin→destination
     * line. ORIGIN always first, DESTINATION always last, pickups before
     * their own dropoffs guaranteed by sorting pickups ahead of dropoffs
     * of the same booking at equal projection.
     */
    private List<Waypoint> orderWaypoints(List<Waypoint> waypoints, double[] origin, double[] dest) {
        List<Waypoint> sorted = new ArrayList<>(waypoints);
        Comparator<Waypoint> byProjection = Comparator.comparingDouble(w -> {
            if (w.getStopType() == RideStop.StopType.ORIGIN) return -1.0;
            if (w.getStopType() == RideStop.StopType.DESTINATION) return Double.MAX_VALUE;
            if (origin == null || dest == null || w.getCoords() == null) return 0;
            return projectionT(origin, dest, w.getCoords());
        });
        sorted.sort(byProjection
                .thenComparing(w -> w.getStopType() == RideStop.StopType.PICKUP ? 0 : 1));
        return sorted;
    }

    private List<RideStop> persistStops(Ride ride, List<Waypoint> waypoints) {
        List<RideStop> stops = new ArrayList<>();
        int sequence = 1;
        int elapsedSeconds = 0;
        double[] prev = null;
        Instant baseTime = ride.getScheduledAt() != null ? ride.getScheduledAt() : Instant.now();

        for (Waypoint w : waypoints) {
            if (w.getCoords() != null && prev != null) {
                elapsedSeconds += (int) (haversineMeters(prev, w.getCoords()) / AVG_SPEED_MPS);
            }
            Instant planned = w.getStopType() == RideStop.StopType.ORIGIN
                    ? baseTime
                    : baseTime.plusSeconds(elapsedSeconds);
            RideStop stop = RideStop.builder()
                    .ride(ride)
                    .booking(w.getBookingId() != null
                            ? Booking.builder().id(w.getBookingId()).build() : null)
                    .sequence(sequence++)
                    .stopType(w.getStopType())
                    .location(w.getCoords() != null
                            ? String.format("POINT(%.6f %.6f)", w.getCoords()[1], w.getCoords()[0])
                            : null)
                    .address(w.getAddress())
                    .plannedTime(planned)
                    .status(RideStop.StopStatus.PENDING)
                    .build();
            stops.add(rideStopRepository.save(stop));
            if (w.getCoords() != null) prev = w.getCoords();
        }
        return stops;
    }

    /**
     * Persist a new active route version (guide §10: persist a new route
     * version and mark it active; history is preserved).
     */
    private RideRoute persistRouteVersion(Ride ride, List<RideStop> stops) {
        rideRouteRepository.findByRideId(rideId(ride)).forEach(prev -> prev.setIsActive(false));

        RouteMetrics metrics = calculateRouteMetrics(stops);
        int newVersion = (ride.getRouteVersion() != null ? ride.getRouteVersion() : 0) + 1;
        ride.setRouteVersion(newVersion);
        rideRepository.save(ride);

        RideRoute route = RideRoute.builder()
                .ride(ride)
                .version(newVersion)
                .provider(PROVIDER)
                .polyline(generatePolyline(stops))
                .distanceMeters(metrics.getTotalDistance())
                .durationSeconds(metrics.getTotalDuration())
                .optimizationScore(metrics.getScore())
                .isActive(true)
                .build();
        return rideRouteRepository.save(route);
    }

    private UUID rideId(Ride ride) {
        return ride.getId();
    }

    private RouteMetrics calculateRouteMetrics(List<RideStop> stops) {
        int totalDistance = 0;
        double[] prev = null;
        for (RideStop stop : stops) {
            double[] coords = parseWktPoint(stop.getLocation());
            if (coords != null && prev != null) {
                totalDistance += (int) haversineMeters(prev, coords);
            }
            if (coords != null) prev = coords;
        }
        return RouteMetrics.builder()
                .totalDistance(totalDistance)
                .totalDuration((int) (totalDistance / AVG_SPEED_MPS))
                .score(BigDecimal.ONE)
                .build();
    }

    private String generatePolyline(List<RideStop> stops) {
        return stops.stream()
                .map(RideStop::getLocation)
                .filter(Objects::nonNull)
                .map(loc -> loc.replace("POINT(", "").replace(")", ""))
                .collect(Collectors.joining("|"));
    }

    /** Planned arrival time for a stop, from cumulative distance at ~18 km/h. */
    private Instant plannedTime(double[] origin, double[] dest, String locationWkt, Instant scheduledAt) {
        Instant base = scheduledAt != null ? scheduledAt : Instant.now();
        double[] point = parseWktPoint(locationWkt);
        if (origin == null || dest == null || point == null) return base;
        double meters = haversineMeters(origin, point);
        return base.plusSeconds((long) (meters / AVG_SPEED_MPS));
    }

    /** Parses {@code POINT(lng lat)} WKT as {lat, lng}. */
    private double[] parseWktPoint(String wkt) {
        if (wkt == null || !wkt.startsWith("POINT(")) return null;
        try {
            String coords = wkt.substring(6, wkt.length() - 1);
            String[] parts = coords.trim().split("\\s+");
            return new double[]{Double.parseDouble(parts[1]), Double.parseDouble(parts[0])};
        } catch (Exception e) {
            return null;
        }
    }

    private double projectionT(double[] a, double[] b, double[] p) {
        double dx = b[1] - a[1];
        double dy = b[0] - a[0];
        double lenSq = dx * dx + dy * dy;
        if (lenSq == 0) return 0;
        double t = ((p[1] - a[1]) * dx + (p[0] - a[0]) * dy) / lenSq;
        return Math.max(0, Math.min(1, t));
    }

    private double haversineMeters(double[] a, double[] b) {
        double dLat = Math.toRadians(b[0] - a[0]);
        double dLng = Math.toRadians(b[1] - a[1]);
        double h = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(a[0])) * Math.cos(Math.toRadians(b[0]))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * 6371000 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
    }

    @Getter @Setter @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    private static class RouteMetrics {
        private int totalDistance;
        private int totalDuration;
        private BigDecimal score;
    }

    /** One route node awaiting sequencing. */
    @Getter @Setter @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    private static class Waypoint {
        private RideStop.StopType stopType;
        private UUID bookingId;
        private double[] coords;
        private String address;
        private Instant plannedTime;
    }
}
