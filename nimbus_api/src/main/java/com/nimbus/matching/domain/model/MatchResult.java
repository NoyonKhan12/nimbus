package com.nimbus.matching.domain.model;

import com.nimbus.ride.domain.entity.Ride;
import lombok.*;

import java.util.*;

/**
 * Result of a matching query, containing scored ride candidates.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchResult {

    private List<MatchScore> matches;
    private int totalCandidates;
    private int filteredByHardConstraints;
    private int afterScoring;

    /**
     * Get top N matches.
     */
    public List<MatchScore> getTopN(int n) {
        if (matches == null || matches.isEmpty()) return Collections.emptyList();

        matches.sort(new MatchScore.ScoreComparator());
        return matches.subList(0, Math.min(n, matches.size()));
    }

    /**
     * Get the ride IDs from matches.
     */
    public List<UUID> getRideIds() {
        if (matches == null) return Collections.emptyList();
        return matches.stream()
                .map(ms -> ms.getRide().getId())
                .toList();
    }
}
