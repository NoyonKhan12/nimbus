package com.nimbus.matching.domain.model;

import lombok.*;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;

import java.time.Instant;
import java.util.*;

/**
 * Criteria for finding matching rides.
 * Encapsulates the passenger's origin, destination, and time constraints.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchingCriteria {

    private Double originLatitude;
    private Double originLongitude;
    private Double destinationLatitude;
    private Double destinationLongitude;

    private Instant earliestPickup;
    private Instant latestPickup;

    private Integer seatsNeeded;
    private Integer maxDetourMeters;
    private Integer maxWaitSeconds;

    private UUID passengerId;
    private UUID excludedRideId; // Ride to exclude (e.g., passenger's own ride)

    /**
     * Convert origin to JTS Point.
     */
    public Point getOriginPoint() {
        if (originLatitude == null || originLongitude == null) return null;
        GeometryFactory factory = new GeometryFactory();
        return factory.createPoint(new Coordinate(originLongitude, originLatitude));
    }

    /**
     * Convert destination to JTS Point.
     */
    public Point getDestinationPoint() {
        if (destinationLatitude == null || destinationLongitude == null) return null;
        GeometryFactory factory = new GeometryFactory();
        return factory.createPoint(new Coordinate(destinationLongitude, destinationLatitude));
    }
}
