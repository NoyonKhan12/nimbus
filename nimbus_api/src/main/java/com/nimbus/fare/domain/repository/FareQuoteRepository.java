package com.nimbus.fare.domain.repository;

import com.nimbus.fare.domain.entity.FareQuote;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public interface FareQuoteRepository extends JpaRepository<FareQuote, UUID> {
    Optional<FareQuote> findByBookingId(UUID bookingId);
    List<FareQuote> findByCreatedAtAfter(java.time.Instant after);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT q FROM FareQuote q WHERE q.id = :id")
    Optional<FareQuote> findByIdForUpdate(@Param("id") UUID id);
}
