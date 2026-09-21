package com.nimbus.ride.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Represents a versioned route for a ride.
 * Routes are versioned and become locked before execution.
 *
 * <p>Route optimization produces a new version with a polyline/geometry
 * and distance/duration estimates. Only one active route exists per ride
 * at any time, but history is preserved for audit and reproducibility.</p>
 */
@Entity
@Table(name = "ride_routes", indexes = {
    @Index(name = "idx_ride_routes_ride_version", columnList = "ride_id, version")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RideRoute {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ride_id", nullable = false, foreignKey = @ForeignKey(name = "fk_route_ride"))
    private Ride ride;

    @Column(name = "version", nullable = false)
    private Integer version;

    @Column(name = "provider", length = 50)
    private String provider;

    @Column(name = "polyline", columnDefinition = "TEXT")
    private String polyline;

    @Column(name = "geometry", columnDefinition = "GEOMETRY(LineString, 4326)")
    private String geometry;

    @Column(name = "distance_meters")
    private Integer distanceMeters;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    @Column(name = "optimization_score", precision = 10, scale = 4)
    private BigDecimal optimizationScore;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = false;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    /**
     * Check if this route contains a location within a corridor.
     */
    public boolean containsLocation(String pointWkt) {
        // Will be implemented with PostGIS ST_Contains in repository
        return true;
    }
}
