package com.nimbus.ride.domain.repository;

import com.nimbus.ride.domain.entity.RideRoute;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface RideRouteRepository extends JpaRepository<RideRoute, UUID> {
    List<RideRoute> findByRideId(UUID rideId);
    Optional<RideRoute> findByRideIdAndVersion(UUID rideId, Integer version);
    Optional<RideRoute> findByRideIdAndIsActiveTrue(UUID rideId);
}
