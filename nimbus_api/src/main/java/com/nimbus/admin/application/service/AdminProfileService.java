package com.nimbus.admin.application.service;

import com.nimbus.admin.application.dto.AdminProfileResponse;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.entity.UserProfile;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.kernel.domain.repository.UserProfileRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.NoSuchElementException;
import java.util.Objects;

/**
 * Service for the signed-in administrator's own profile:
 * view, edit personal info, and change password.
 */
@Service
@Slf4j
public class AdminProfileService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final com.nimbus.audit.application.service.AuditService auditService;

    public AdminProfileService(UserRepository userRepository,
                               UserProfileRepository userProfileRepository,
                               PasswordEncoder passwordEncoder,
                               com.nimbus.audit.application.service.AuditService auditService) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.passwordEncoder = passwordEncoder;
        this.auditService = auditService;
    }

    /**
     * Resolve the currently authenticated user (set by the JWT filter).
     */
    private User currentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken token) {
            return userRepository.findById(token.getUserId())
                    .orElseThrow(() -> new NoSuchElementException("Authenticated user no longer exists"));
        }
        throw new IllegalStateException("No authenticated principal");
    }

    public AdminProfileResponse getProfile() {
        User user = currentUser();
        UserProfile profile = userProfileRepository.findByUserId(user.getId()).orElse(null);
        return toResponse(user, profile);
    }

    /**
     * Update the current admin's own first/last name and email.
     * Email must remain unique across users.
     */
    @Transactional
    public AdminProfileResponse updateProfile(String email, String newFirstName, String newLastName) {
        User user = currentUser();

        if (email != null && !email.isBlank() && !email.equalsIgnoreCase(user.getEmail())) {
            userRepository.findByEmail(email).ifPresent(existing -> {
                if (!existing.getId().equals(user.getId())) {
                    throw new IllegalArgumentException("Email address is already in use");
                }
            });
            user.setEmail(email);
        }

        if (newFirstName != null || newLastName != null) {
            UserProfile profile = userProfileRepository.findByUserId(user.getId())
                    .orElseGet(() -> UserProfile.builder().user(user).build());
            if (newFirstName != null) profile.setFirstName(newFirstName.trim().isEmpty() ? null : newFirstName.trim());
            if (newLastName != null) profile.setLastName(newLastName.trim().isEmpty() ? null : newLastName.trim());
            profile.setUpdatedAt(java.time.Instant.now());
            userProfileRepository.save(profile);
        }

        user.setUpdatedAt(java.time.Instant.now());
        userRepository.save(user);
        auditService.logAction(user.getId(), "ADMIN_PROFILE_UPDATED", "USER", user.getId(),
                null, "email=" + user.getEmail());

        UserProfile profile = userProfileRepository.findByUserId(user.getId()).orElse(null);
        return toResponse(user, profile);
    }

    /**
     * Change the current admin's password. Requires the current password.
     */
    @Transactional
    public void changePassword(String currentPassword, String newPassword) {
        User user = currentUser();

        if (user.getPasswordHash() == null
                || !passwordEncoder.matches(Objects.requireNonNull(currentPassword), user.getPasswordHash())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }
        if (newPassword == null || newPassword.length() < 8) {
            throw new IllegalArgumentException("New password must be at least 8 characters");
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(java.time.Instant.now());
        userRepository.save(user);
        auditService.logAction(user.getId(), "ADMIN_PASSWORD_CHANGED", "USER", user.getId(), null, null);
        log.info("Admin {} changed their password", user.getId());
    }

    private AdminProfileResponse toResponse(User user, UserProfile profile) {
        return new AdminProfileResponse(
                user.getId(),
                user.getPhone(),
                user.getEmail(),
                user.getRole(),
                user.getStatus() != null ? user.getStatus().name() : null,
                profile != null ? profile.getFirstName() : null,
                profile != null ? profile.getLastName() : null,
                user.getCreatedAt()
        );
    }
}
