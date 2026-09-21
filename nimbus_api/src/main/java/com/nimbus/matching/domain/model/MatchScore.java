package com.nimbus.matching.domain.model;

import com.nimbus.ride.domain.entity.Ride;
import lombok.*;

import java.math.BigDecimal;
import java.util.Comparator;

/**
 * Matches a ride candidate with a computed score.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchScore {

    private Ride ride;
    private double score;
    private String reason;

    // Scoring components
    private double routeOverlapScore;
    private double pickupProximityScore;
    private double dropoffProximityScore;
    private double timeCompatibilityScore;
    private double driverReliabilityScore;

    /**
     * Compare scores for sorting (higher is better).
     */
    public static class ScoreComparator implements Comparator<MatchScore> {
        @Override
        public int compare(MatchScore a, MatchScore b) {
            return Double.compare(b.score, a.score); // Descending
        }
    }
}
