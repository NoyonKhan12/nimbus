package com.nimbus.rating.domain.repository;

import com.nimbus.rating.domain.entity.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface RatingRepository extends JpaRepository<Rating, UUID> {
    List<Rating> findByRatedId(UUID ratedId);
    Optional<Rating> findByBookingIdAndRaterId(UUID bookingId, UUID raterId);
    boolean existsByBookingIdAndRaterId(UUID bookingId, UUID raterId);
}
