package com.nimbus.driver.domain.entity;

import com.nimbus.driver.domain.entity.DriverProfile;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.*;

/**
 * Vehicle entity for driver vehicles.
 */
@Entity
@Table(name = "vehicles", indexes = {
    @Index(name = "idx_vehicles_driver_id", columnList = "driver_id")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Vehicle {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = false, foreignKey = @ForeignKey(name = "fk_vehicle_driver"))
    private DriverProfile driver;

    @Column(name = "registration_number", nullable = false, unique = true, length = 100)
    private String registrationNumber;

    @Column(name = "type", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private VehicleType type;

    @Column(name = "model", length = 100)
    private String model;

    @Column(name = "year")
    private Integer year;

    @Column(name = "color", length = 50)
    private String color;

    @Column(name = "seat_capacity", nullable = false)
    private Integer seatCapacity;

    @Column(name = "status", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private VehicleStatus status = VehicleStatus.PENDING;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @OneToMany(mappedBy = "vehicle", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<VehicleDocument> documents = new ArrayList<>();

    public enum VehicleType {
        SEDAN, SUV, PICKUP, VAN, BIKE, TRUCK, OTHER
    }

    public enum VehicleStatus {
        PENDING, APPROVED, REJECTED, SUSPENDED
    }

    /**
     * Check if vehicle is eligible.
     */
    public boolean isEligible() {
        return status == VehicleStatus.APPROVED && seatCapacity > 0;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = updatedAt = Instant.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = Instant.now();
    }
}
