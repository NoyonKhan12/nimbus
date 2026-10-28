package com.nimbus.ride.domain.repository;

import com.nimbus.ride.domain.entity.RideStop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.*;

/**
 * Repository for ride stops.
 */
@Repository
public interface RideStopRepository extends JpaRepository<RideStop, UUID> {

    List<RideStop> findByRideIdOrderBySequence(UUID rideId);

    /** Removes all stops for a ride (route rebuilds start from scratch). */
    @Modifying
    void deleteByRideId(UUID rideId);

    Optional<RideStop> findByRideIdAndSequence(UUID rideId, Integer sequence);

    List<RideStop> findByRideIdAndStopType(UUID rideId, String stopType);

    List<RideStop> findByBookingId(UUID bookingId);

    @Query("SELECT s FROM RideStop s WHERE s.ride.id = :rideId " +
           "AND s.stopType IN ('PICKUP', 'DROPOFF') " +
           "ORDER BY s.sequence ASC")
    List<RideStop> findPickupDropoffStops(@Param("rideId") UUID rideId);
}
