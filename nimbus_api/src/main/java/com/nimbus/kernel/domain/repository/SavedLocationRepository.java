package com.nimbus.kernel.domain.repository;

import com.nimbus.kernel.domain.entity.SavedLocation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Repository for saved location operations.
 */
@Repository
public interface SavedLocationRepository extends JpaRepository<SavedLocation, UUID> {

    /**
     * Find all saved locations for a user.
     */
    List<SavedLocation> findByUserId(UUID userId);

    /**
     * Find saved location by label.
     */
    List<SavedLocation> findByUserIdAndLabel(UUID userId, String label);

    /**
     * Check if a label already exists for the user.
     */
    boolean existsByUserIdAndLabel(UUID userId, String label);
}