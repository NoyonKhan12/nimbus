package com.nimbus.kernel.domain.repository;

import com.nimbus.admin.domain.projection.UserAdminProjection;
import com.nimbus.kernel.domain.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.*;

/**
 * Repository for user entity operations.
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByPhone(String phone);
    boolean existsByPhone(String phone);
    Optional<User> findByEmail(String email);
    Optional<User> findByPhoneAndPhoneVerifiedTrue(String phone);
    Page<User> findByPhoneContainingOrEmailContaining(String phone, String email, Pageable pageable);
    Page<User> findByStatus(User.UserStatus status, Pageable pageable);

    // ── Optimized admin queries ──────────────────────────────────────────

    /**
     * Fetch users with their profiles in a single JOIN query to avoid N+1.
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.UserAdminProjection(" +
           "u.id, u.phone, u.email, CAST(u.status AS string), CAST(u.role AS string), " +
           "u.phoneVerified, u.createdAt, p.firstName, p.lastName) " +
           "FROM User u LEFT JOIN UserProfile p ON p.user.id = u.id " +
           "WHERE (:search IS NULL OR u.phone LIKE %:search% OR u.email LIKE %:search%) " +
           "AND (:status IS NULL OR u.status = :status) " +
           "ORDER BY u.createdAt DESC")
    Page<UserAdminProjection> findAdminUsers(
            @Param("search") String search,
            @Param("status") User.UserStatus status,
            Pageable pageable
    );

    /**
     * Fetch a single user by ID as projection (with profile JOIN).
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.UserAdminProjection(" +
           "u.id, u.phone, u.email, CAST(u.status AS string), CAST(u.role AS string), " +
           "u.phoneVerified, u.createdAt, p.firstName, p.lastName) " +
           "FROM User u LEFT JOIN UserProfile p ON p.user.id = u.id " +
           "WHERE u.id = :id")
    Optional<UserAdminProjection> findAdminUserById(@Param("id") UUID id);

    /**
     * Aggregate count by role - useful for admin dashboard.
     */
    @Query("SELECT COUNT(u) FROM User u WHERE u.role = :role AND u.status = :status")
    long countByRoleAndStatus(@Param("role") User.UserRole role,
                              @Param("status") User.UserStatus status);
}
