package com.nimbus.rating.domain.entity;

import com.nimbus.booking.domain.entity.Booking;
import com.nimbus.kernel.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

/**
 * Rating entity for post-trip feedback.
 *
 * <p>Ratings are allowed only after completed journeys.
 * Protected from duplicates via unique constraint on (booking_id, rater_id).</p>
 */
@Entity
@Table(name = "ratings", indexes = {
    @Index(name = "idx_ratings_booking_id", columnList = "booking_id"),
    @Index(name = "idx_ratings_rated_id", columnList = "rated_id")
}, uniqueConstraints = {
    @UniqueConstraint(columnNames = {"booking_id", "rater_id"}, name = "uk_ratings_booking_rater")
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Rating {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false, foreignKey = @ForeignKey(name = "fk_rating_booking"))
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rater_id", nullable = false, foreignKey = @ForeignKey(name = "fk_rating_rater"))
    private User rater;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rated_id", nullable = false, foreignKey = @ForeignKey(name = "fk_rating_rated"))
    private User rated;

    @Column(name = "score", nullable = false)
    private Integer score;

    @Column(name = "comment", columnDefinition = "TEXT")
    private String comment;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    /**
     * Validate rating score (1-5).
     */
    public boolean isValidScore() {
        return score != null && score >= 1 && score <= 5;
    }
}
