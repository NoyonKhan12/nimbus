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
           "u.id, u.phone, u.email, CAST(u.status AS string), u.role, " +
           "u.phoneVerified, u.createdAt, p.firstName, p.lastName) " +
           "FROM User u LEFT JOIN UserProfile p ON p.user.id = u.id " +
           "WHERE (:search IS NULL OR :search = '' OR u.phone LIKE %:search% OR u.email LIKE %:search%) " +
           "AND (:status IS NULL OR u.status = :status) " +
           "AND (:role IS NULL OR u.role = :role) " +
           "ORDER BY u.createdAt DESC")
    Page<UserAdminProjection> findAdminUsers(
            @Param("search") String search,
            @Param("status") User.UserStatus status,
            @Param("role") String role,
            Pageable pageable
    );

    /** Same as {@link #findAdminUsers} but restricted to a set of roles
     *  (no null-jacket needed since the caller always supplies roles). */
    @Query("SELECT new com.nimbus.admin.domain.projection.UserAdminProjection(" +
           "u.id, u.phone, u.email, CAST(u.status AS string), u.role, " +
           "u.phoneVerified, u.createdAt, p.firstName, p.lastName) " +
           "FROM User u LEFT JOIN UserProfile p ON p.user.id = u.id " +
           "WHERE (:search IS NULL OR :search = '' OR u.phone LIKE %:search% OR u.email LIKE %:search%) " +
           "AND (:status IS NULL OR u.status = :status) " +
           "AND u.role IN :roles " +
           "ORDER BY u.createdAt DESC")
    Page<UserAdminProjection> findAdminUsersInRoles(
            @Param("search") String search,
            @Param("status") User.UserStatus status,
            @Param("roles") Collection<String> roles,
            Pageable pageable
    );

    /**
     * Fetch a single user by ID as projection (with profile JOIN).
     */
    @Query("SELECT new com.nimbus.admin.domain.projection.UserAdminProjection(" +
           "u.id, u.phone, u.email, CAST(u.status AS string), u.role, " +
           "u.phoneVerified, u.createdAt, p.firstName, p.lastName) " +
           "FROM User u LEFT JOIN UserProfile p ON p.user.id = u.id " +
           "WHERE u.id = :id")
    Optional<UserAdminProjection> findAdminUserById(@Param("id") UUID id);

    /**
     * Count users assigned to a dynamic role.
     */
    long countByRole(String role);

    /**
     * Aggregate count by role - useful for admin dashboard.
     */
    @Query("SELECT COUNT(u) FROM User u WHERE u.role = :role AND u.status = :status")
    long countByRoleAndStatus(@Param("role") String role,
                              @Param("status") User.UserStatus status);
}
