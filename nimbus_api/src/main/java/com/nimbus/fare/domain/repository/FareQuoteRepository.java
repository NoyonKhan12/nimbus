package com.nimbus.fare.domain.repository;

import com.nimbus.fare.domain.entity.FareQuote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface FareQuoteRepository extends JpaRepository<FareQuote, UUID> {
    Optional<FareQuote> findByBookingId(UUID bookingId);
    List<FareQuote> findByCreatedAtAfter(java.time.Instant after);
}
