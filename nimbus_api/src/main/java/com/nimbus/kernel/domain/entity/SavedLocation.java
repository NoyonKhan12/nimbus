package com.nimbus.kernel.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.locationtech.jts.geom.Point;

import java.time.Instant;
import java.util.UUID;

/**
 * User's saved location (e.g., Home, Office).
 */
@Entity
@Table(name = "saved_locations")
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class SavedLocation {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(length = 100, nullable = false)
    private String label;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(columnDefinition = "geometry(Point,4326)")
    private Point location;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();
}