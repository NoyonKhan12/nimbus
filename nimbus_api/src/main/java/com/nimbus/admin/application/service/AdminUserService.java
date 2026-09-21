package com.nimbus.admin.application.service;

import com.nimbus.admin.domain.projection.UserAdminProjection;
import com.nimbus.kernel.application.dto.PagedResponse;
import com.nimbus.kernel.application.dto.PagedResponse.PageMeta;
import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
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

    public AdminUserService(UserRepository userRepository, AdminCacheService cacheService) {
        this.userRepository = userRepository;
        this.cacheService = cacheService;
    }

    public PagedResponse<UserAdminProjection> listUsers(int page, int size, String search, String status) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        User.UserStatus statusEnum = null;
        if (status != null && !status.isEmpty()) {
            statusEnum = User.UserStatus.valueOf(status.toUpperCase());
        }

        Page<UserAdminProjection> userPage = userRepository.findAdminUsers(search, statusEnum, pageable);
        return toPagedResponse(userPage);
    }

    public Optional<UserAdminProjection> getUserById(String id) {
        UUID userId = UUID.fromString(id);
        return userRepository.findAdminUserById(userId);
    }

    public void updateUserStatus(String id, String status) {
        UUID userId = UUID.fromString(id);
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        user.setStatus(User.UserStatus.valueOf(status.toUpperCase()));
        userRepository.save(user);
        cacheService.invalidateUsers();
        cacheService.invalidateDashboardStats();
    }

    public void deleteUser(String id) {
        UUID userId = UUID.fromString(id);
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        userRepository.delete(user);
        cacheService.invalidateAll();
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
