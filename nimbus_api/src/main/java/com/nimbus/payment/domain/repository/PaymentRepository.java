package com.nimbus.payment.domain.repository;

import com.nimbus.admin.domain.projection.PaymentAdminProjection;
import com.nimbus.payment.domain.entity.Payment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.*;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    Optional<Payment> findByBookingId(UUID bookingId);
    Optional<Payment> findByIdempotencyKey(String idempotencyKey);
    List<Payment> findByStatus(Payment.PaymentStatus status);
    Page<Payment> findByStatus(Payment.PaymentStatus status, Pageable pageable);
    List<Payment> findByPayerId(UUID payerId);

    // ── Optimized admin queries ──────────────────────────────────────────

    /**
     * Sum paid revenue in a single query instead of fetching all rows.
     */
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = :successStatus")
    BigDecimal sumTotalRevenue(@Param("successStatus") Payment.PaymentStatus successStatus);

    /**
     * Count successful payments for dashboard.
     */
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = :successStatus")
    long countSuccessfulPayments(@Param("successStatus") Payment.PaymentStatus successStatus);

    /**
     * Fetch payments as projections to avoid lazy loading and N+1.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.PaymentAdminProjection(" +
           "p.id, b.id, u.id, p.amount, CAST(p.method AS string), CAST(p.status AS string), " +
           "p.providerReference, p.idempotencyKey, p.createdAt, p.updatedAt) " +
           "FROM Payment p JOIN p.booking b JOIN p.payer u " +
           "WHERE (:status IS NULL OR p.status = :status) " +
           "ORDER BY p.createdAt DESC")
    Page<PaymentAdminProjection> findAdminPayments(
            @Param("status") Payment.PaymentStatus status,
            Pageable pageable
    );

    /**
     * Fetch payment by ID as projection.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.PaymentAdminProjection(" +
           "p.id, b.id, u.id, p.amount, CAST(p.method AS string), CAST(p.status AS string), " +
           "p.providerReference, p.idempotencyKey, p.createdAt, p.updatedAt) " +
           "FROM Payment p JOIN p.booking b JOIN p.payer u WHERE p.id = :id")
    Optional<PaymentAdminProjection> findByIdProjection(@Param("id") UUID id);
}
