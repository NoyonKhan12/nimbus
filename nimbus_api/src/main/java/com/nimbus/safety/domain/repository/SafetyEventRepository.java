package com.nimbus.safety.domain.repository;

import com.nimbus.safety.domain.entity.SafetyEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface SafetyEventRepository extends JpaRepository<SafetyEvent, UUID> {
    List<SafetyEvent> findByRideId(UUID rideId);
    List<SafetyEvent> findByUserId(UUID userId);
    List<SafetyEvent> findByStatus(SafetyEvent.EventStatus status);

    java.util.Optional<SafetyEvent> findByShareToken(String shareToken);
    Optional<SafetyEvent> findFirstByRideIdOrderByCreatedAtDesc(UUID rideId);
}
