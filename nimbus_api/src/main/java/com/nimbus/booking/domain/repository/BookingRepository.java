package com.nimbus.booking.domain.repository;

import com.nimbus.booking.domain.entity.Booking;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.*;

/**
 * Repository for booking operations with transactional locking for seat allocation.
 */
@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {

    List<Booking> findByRideId(UUID rideId);

    List<Booking> findByRideIdAndStatus(UUID rideId, Booking.BookingStatus status);

    List<Booking> findByPassengerId(UUID passengerId);

    List<Booking> findByPassengerIdAndStatusIn(UUID passengerId, List<Booking.BookingStatus> statuses);

    Optional<Booking> findByRideIdAndPassengerId(UUID rideId, UUID passengerId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT b FROM Booking b WHERE b.id = :bookingId")
    Optional<Booking> findByIdForUpdate(@Param("bookingId") UUID bookingId);

    /**
     * Find all expired HELD bookings that need cleanup.
     */
    @Query("SELECT b FROM Booking b WHERE b.status = HELD " +
           "AND b.createdAt < :cutoff")
    List<Booking> findExpiredHeldBookings(@Param("cutoff") Instant cutoff);

    /**
     * Count active bookings (HELD, CONFIRMED, PICKED_UP) for a ride.
     */
    @Query("SELECT COUNT(b) FROM Booking b WHERE b.ride.id = :rideId " +
           "AND b.status IN (HELD, CONFIRMED, PICKED_UP)")
    int countActiveBookingsByRideId(@Param("rideId") UUID rideId);

    /**
     * Sum of seats allocated to active bookings for a ride.
     */
    /**
     * Bulk-expires HELD bookings older than the cutoff (seat holds last
     * 5 minutes — guide §5/§25). Returns the number expired.
     */
    @Modifying
    @Query(value = "UPDATE bookings SET status = 'EXPIRED', updated_at = now() "
           + "WHERE status = 'HELD' AND created_at < :cutoff", nativeQuery = true)
    int expireStaleHolds(@Param("cutoff") java.time.Instant cutoff);

    @Query("SELECT COALESCE(SUM(b.seats), 0) FROM Booking b WHERE b.ride.id = :rideId " +
           "AND b.status IN (HELD, CONFIRMED, PICKED_UP)")
    int sumActiveSeatsByRideId(@Param("rideId") UUID rideId);
}
