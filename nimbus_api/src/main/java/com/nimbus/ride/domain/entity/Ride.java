package com.nimbus.ride.domain.entity;

import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnTransformer;
import org.hibernate.annotations.Where;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

/**
 * Ride entity representing a vehicle journey from origin to destination.
 * Manages the complete ride lifecycle through well-defined state transitions:
 * DRAFT → PUBLISHED → ROUTE_LOCKED → DRIVER_ARRIVING → IN_PROGRESS → COMPLETED/CANCELLED
 *
 * <p>Backend is authoritative for ride state. All state transitions are validated
 * and audited. Route is versioned and locked before execution.</p>
 */
@Entity
@Table(name = "rides", indexes = {
    @Index(name = "idx_rides_status_scheduled_at", columnList = "status, scheduled_at"),
    @Index(name = "idx_rides_driver_status", columnList = "driver_id, status"),
    @Index(name = "idx_rides_creator", columnList = "creator_id")
})
@Where(clause = "deleted_at IS NULL")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Ride {

    @Id
    @GeneratedValue
    @org.hibernate.annotations.GenericGenerator(name = "uuid2", strategy = "uuid2")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", foreignKey = @ForeignKey(name = "fk_ride_driver"))
    private DriverProfile driver;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creator_id", nullable = false, foreignKey = @ForeignKey(name = "fk_ride_creator"))
    private User creator;

    @Column(name = "vehicle_id")
    private UUID vehicleId;

    @Column(name = "type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private RideType type;

    @Column(name = "scheduled_at")
    private Instant scheduledAt;

    @Column(name = "actual_start_at")
    private Instant actualStartAt;

    @Column(name = "actual_end_at")
    private Instant actualEndAt;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private RideStatus status = RideStatus.DRAFT;

    @Column(name = "origin_location", columnDefinition = "text")
    private String originLocation;

    @Column(name = "origin_address", length = 500)
    private String originAddress;

    @Column(name = "destination_location", columnDefinition = "text")
    private String destinationLocation;

    @Column(name = "destination_address", length = 500)
    private String destinationAddress;

    @Column(name = "available_seats", nullable = false)
    @Builder.Default
    private Integer availableSeats = 0;

    @Column(name = "max_detour_meters")
    private Integer maxDetourMeters;

    @Column(name = "max_wait_seconds")
    private Integer maxWaitSeconds;

    @Column(name = "route_version")
    @Builder.Default
    private Integer routeVersion = 0;

    @Column(name = "fare_rule_version", length = 50)
    private String fareRuleVersion;

    @Column(name = "notes", length = 1000)
    private String notes;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @Column(name = "deleted_at")
    private Instant deletedAt;

    // Computed fields from database views/queries
    @OneToMany(mappedBy = "ride", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<RideStop> stops = new ArrayList<>();

    @OneToMany(mappedBy = "ride", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<RidePassenger> passengers = new ArrayList<>();

    public enum RideType {
        SCHEDULED, INSTANT, RECURRING
    }

    /** Recurrence pattern for recurring ride templates (guide §2). */
    public enum RecurrenceType { NONE, DAILY, WEEKLY }

    @Column(name = "recurrence_type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RecurrenceType recurrenceType = RecurrenceType.NONE;

    /** Recurring instances stop being materialized after this instant. */
    @Column(name = "recurrence_until")
    private Instant recurrenceUntil;

    /** Set on materialized instances of a recurring template. */
    @Column(name = "parent_ride_id")
    private UUID parentRideId;

    public enum RideStatus {
        DRAFT,         // Being created
        PUBLISHED,     // Searchable/bookable
        ROUTE_LOCKED,  // Execution route finalized
        DRIVER_ARRIVING, // Driver approaching pickup
        IN_PROGRESS,   // Journey active
        INTERRUPTED,   // Operational interruption
        COMPLETED,     // Finished
        CANCELLED      // Cancelled
    }

    /**
     * Check if the ride can accept bookings.
     */
    public boolean isBookable() {
        return status == RideStatus.PUBLISHED || status == RideStatus.ROUTE_LOCKED;
    }

    /**
     * Check if the ride has already started execution.
     */
    public boolean hasStarted() {
        return status == RideStatus.IN_PROGRESS ||
               status == RideStatus.DRIVER_ARRIVING ||
               status == RideStatus.ROUTE_LOCKED;
    }

    /**
     * Increment the route version for a new route calculation.
     */
    public void incrementRouteVersion() {
        this.routeVersion++;
    }

    /**
     * Check if route is locked for execution.
     */
    public boolean isRouteLocked() {
        return status == RideStatus.ROUTE_LOCKED;
    }

    /**
     * Calculate remaining seats available for booking.
     */
    public int getRemainingSeats() {
        int occupied = passengers != null ?
                passengers.stream().mapToInt(RidePassenger::getSeats).sum() : 0;
        return Math.max(0, availableSeats - occupied);
    }
}
