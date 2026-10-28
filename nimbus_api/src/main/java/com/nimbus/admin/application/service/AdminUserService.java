package com.nimbus.admin.application.service;

import com.nimbus.admin.application.dto.CreateUserRequest;
import com.nimbus.admin.domain.projection.UserAdminProjection;
import com.nimbus.kernel.application.dto.PagedResponse;
import com.nimbus.kernel.application.dto.PagedResponse.PageMeta;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.entity.UserProfile;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.kernel.domain.repository.UserProfileRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;

/**
 * Service for admin user operations.
 * Caching at the service layer to avoid ResponseEntity serialization issues.
 */
@Service
@Slf4j
public class AdminUserService {

    private final UserRepository userRepository;
    private final AdminCacheService cacheService;
    private final com.nimbus.audit.application.service.AuditService auditService;
    private final UserProfileRepository userProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final com.nimbus.kernel.domain.repository.RoleRepository roleRepository;

    public AdminUserService(UserRepository userRepository, AdminCacheService cacheService,
                            com.nimbus.audit.application.service.AuditService auditService,
                            UserProfileRepository userProfileRepository,
                            PasswordEncoder passwordEncoder,
                            com.nimbus.kernel.domain.repository.RoleRepository roleRepository) {
        this.userRepository = userRepository;
        this.cacheService = cacheService;
        this.auditService = auditService;
        this.userProfileRepository = userProfileRepository;
        this.passwordEncoder = passwordEncoder;
        this.roleRepository = roleRepository;
    }

    public PagedResponse<UserAdminProjection> listUsers(int page, int size, String search, String status, String role) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        User.UserStatus statusEnum = null;
        if (status != null && !status.isEmpty()) {
            statusEnum = User.UserStatus.valueOf(status.toUpperCase());
        }
        // The "Users" list only shows internal (staff) accounts by default.
        // Passenger accounts live in the Passengers list, drivers in Drivers.
        List<String> roles = new ArrayList<>();
        if (role != null && !role.isEmpty()) {
            for (String r : role.split(",")) {
                if (!r.isBlank()) roles.add(r.trim().toUpperCase());
            }
        } else {
            // Default staff (internal) roles — passengers/drivers have their own lists
            roles.add("ADMIN");
            roles.add("OPERATIONS");
            roles.add("FINANCE");
            roles.add("SUPPORT");
            roles.add("SAFETY");
        }

        Page<UserAdminProjection> userPage = userRepository.findAdminUsersInRoles(search, statusEnum, roles, pageable);
        return toPagedResponse(userPage);
    }

    /**
     * Create a staff account (Users page → "Add user").
     * Accepts internal roles only — passengers onboard via OTP, drivers via
     * the driver application flow. The account is created ACTIVE with the
     * phone already verified (courtesy of admin creation) and an optional
     * profile with first/last name for display in lists.
     */
    @org.springframework.transaction.annotation.Transactional
    public UserAdminProjection createUser(CreateUserRequest request) {
        String roleName = request.getRole().trim().toUpperCase();
        com.nimbus.kernel.domain.entity.Role staffRole = roleRepository.findByName(roleName)
                .orElseThrow(() -> new com.nimbus.kernel.domain.exception.NimbusException(
                        com.nimbus.kernel.domain.ErrorCode.USER_INVALID_INPUT,
                        "Role " + roleName + " does not exist — create it first under Users → Roles"));
        if ("PASSENGER".equals(roleName) || "DRIVER".equals(roleName)) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.USER_INVALID_INPUT,
                    "The roles PASSENGER and DRIVER are for the mobile apps — "
                            + "choose a staff role instead");
        }

        String phone = request.getPhone().trim();
        if (userRepository.existsByPhone(phone)) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.USER_INVALID_INPUT,
                    "A user with this phone number already exists");
        }

        String email = request.getEmail() != null && !request.getEmail().isBlank()
                ? request.getEmail().trim() : null;
        if (email != null && userRepository.findByEmail(email).isPresent()) {
            throw new com.nimbus.kernel.domain.exception.NimbusException(
                    com.nimbus.kernel.domain.ErrorCode.USER_INVALID_INPUT,
                    "A user with this email already exists");
        }

        User user = User.builder()
                .phone(phone)
                .email(email)
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .status(User.UserStatus.ACTIVE)
                .role(roleName)
                .phoneVerified(true)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        user = userRepository.save(user);

        if (request.getFirstName() != null || request.getLastName() != null) {
            UserProfile profile = UserProfile.builder()
                    .user(user)
                    .firstName(request.getFirstName() != null && !request.getFirstName().isBlank()
                            ? request.getFirstName().trim() : null)
                    .lastName(request.getLastName() != null && !request.getLastName().isBlank()
                            ? request.getLastName().trim() : null)
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();
            userProfileRepository.save(profile);
        }

        cacheService.invalidateUsers();
        cacheService.invalidateDashboardStats();
        auditService.logAction(currentUserIdOrNull(), "USER_CREATED", "USER",
                user.getId(), null, "role=" + user.getRole());

        return userRepository.findAdminUserById(user.getId())
                .orElseThrow(() -> new RuntimeException("Created user could not be reloaded"));
    }

    public Optional<UserAdminProjection> getUserById(String id) {
        UUID userId = UUID.fromString(id);
        return userRepository.findAdminUserById(userId);
    }

    public void updateUserStatus(String id, String status) {
        UUID userId = UUID.fromString(id);
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        String oldStatus = user.getStatus() != null ? user.getStatus().name() : null;
        user.setStatus(User.UserStatus.valueOf(status.toUpperCase()));
        userRepository.save(user);
        cacheService.invalidateUsers();
        cacheService.invalidateDashboardStats();
        auditService.logAction(currentUserIdOrNull(), "USER_STATUS_CHANGED", "USER",
                userId, "status=" + oldStatus, "status=" + user.getStatus().name());
    }

    public void deleteUser(String id) {
        UUID userId = UUID.fromString(id);
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        userRepository.delete(user);
        cacheService.invalidateAll();
        auditService.logAction(currentUserIdOrNull(), "USER_DELETED", "USER", userId, null, null);
    }

    private UUID currentUserIdOrNull() {
        var auth = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return token.getUserId();
        }
        return null;
    }

    private <T> PagedResponse<T> toPagedResponse(Page<T> page) {
        PageMeta meta = new PageMeta(
            page.getNumber(),
            page.getSize(),
            page.getTotalElements(),
            page.getTotalPages()
        );
        return PagedResponse.<T>builder()
            .success(true)
            .data(page.getContent())
            .meta(meta)
            .timestamp(Instant.now().toString())
            .build();
    }
}
