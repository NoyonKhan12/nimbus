package com.nimbus.kernel.domain.repository;

import com.nimbus.kernel.domain.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository for user profile operations.
 */
@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, UUID> {
    Optional<UserProfile> findByUserId(UUID userId);
    boolean existsByUserId(UUID userId);

    @Query("SELECT p FROM UserProfile p JOIN FETCH p.user WHERE p.user.id = :userId")
    Optional<UserProfile> findByUserIdWithUser(@Param("userId") UUID userId);
}