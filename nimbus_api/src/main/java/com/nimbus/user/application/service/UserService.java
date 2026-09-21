package com.nimbus.user.application.service;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.user.application.*;
import com.nimbus.kernel.domain.entity.*;
import com.nimbus.kernel.domain.exception.NimbusException;
import com.nimbus.kernel.domain.repository.*;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.locationtech.jts.geom.*;
import org.locationtech.jts.io.ParseException;
import org.locationtech.jts.io.WKTReader;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Service for user profile management and saved locations.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final SavedLocationRepository savedLocationRepository;

    /**
     * Get current user profile.
     */
    public UserResponse getCurrentUser() {
        User user = getCurrentUserFromContext();
        return toUserResponse(user);
    }

    /**
     * Update current user profile.
     */
    @Transactional
    public UserResponse updateProfile(UpdateUserRequest request) {
        User user = getCurrentUserFromContext();

        if (request.getEmail() != null) {
            user.setEmail(request.getEmail());
        }

        UserProfile profile = userProfileRepository.findByUserId(user.getId())
                .orElse(UserProfile.builder()
                        .user(user)
                        .createdAt(Instant.now())
                        .updatedAt(Instant.now())
                        .build());

        if (request.getFirstName() != null) {
            profile.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            profile.setLastName(request.getLastName());
        }
        if (request.getEmergencyContactName() != null) {
            profile.setEmergencyContactName(request.getEmergencyContactName());
        }
        if (request.getEmergencyContactPhone() != null) {
            profile.setEmergencyContactPhone(request.getEmergencyContactPhone());
        }
        profile.setUpdatedAt(Instant.now());

        userRepository.save(user);
        userProfileRepository.save(profile);

        return toUserResponse(user);
    }

    /**
     * Get all saved locations for the current user.
     */
    public List<SavedLocationResponse> getSavedLocations() {
        User user = getCurrentUserFromContext();
        List<SavedLocation> locations = savedLocationRepository.findByUserId(user.getId());

        return locations.stream()
                .map(loc -> SavedLocationResponse.builder()
                        .id(loc.getId().toString())
                        .label(loc.getLabel())
                        .address(loc.getAddress())
                        .latitude(loc.getLocation() != null ? loc.getLocation().getX() : 0.0)
                        .longitude(loc.getLocation() != null ? loc.getLocation().getY() : 0.0)
                        .build())
                .collect(Collectors.toList());
    }

    /**
     * Save a new location for the current user.
     */
    @Transactional
    public SavedLocationResponse saveLocation(SaveLocationRequest request) {
        User user = getCurrentUserFromContext();

        if (savedLocationRepository.existsByUserIdAndLabel(user.getId(), request.getLabel())) {
            throw new NimbusException(ErrorCode.CONFLICT,
                    "A location with label '" + request.getLabel() + "' already exists",
                    HttpStatus.CONFLICT);
        }

        try {
            GeometryFactory factory = new GeometryFactory();
            Point point = factory.createPoint(new Coordinate(request.getLongitude(), request.getLatitude()));
            // Set SRID 4326
            point.setSRID(4326);

            SavedLocation location = SavedLocation.builder()
                    .user(user)
                    .label(request.getLabel())
                    .address(request.getAddress())
                    .location(point)
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();

            SavedLocation saved = savedLocationRepository.save(location);

            return SavedLocationResponse.builder()
                    .id(saved.getId().toString())
                    .label(saved.getLabel())
                    .address(saved.getAddress())
                    .latitude(saved.getLocation().getX())
                    .longitude(saved.getLocation().getY())
                    .build();
        } catch (Exception e) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Invalid location coordinates: " + e.getMessage(),
                    HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * Get user entity from security context.
     */
    private User getCurrentUserFromContext() {
        var auth = (UserAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) {
            throw new NimbusException(ErrorCode.AUTH_UNAUTHORIZED, HttpStatus.UNAUTHORIZED);
        }
        return auth.getUser();
    }

    /**
     * Convert User entity to response DTO.
     */
    private UserResponse toUserResponse(User user) {
        UserProfile profile = userProfileRepository.findByUserId(user.getId()).orElse(null);

        UserResponse.UserProfileResponse profileResponse = null;
        if (profile != null) {
            profileResponse = UserResponse.UserProfileResponse.builder()
                    .firstName(profile.getFirstName())
                    .lastName(profile.getLastName())
                    .profilePhotoUrl(profile.getProfilePhotoUrl())
                    .emergencyContactName(profile.getEmergencyContactName())
                    .emergencyContactPhone(profile.getEmergencyContactPhone())
                    .build();
        }

        return UserResponse.builder()
                .id(user.getId().toString())
                .phone(user.getPhone())
                .email(user.getEmail())
                .status(user.getStatus())
                .role(user.getRole())
                .phoneVerified(user.isPhoneVerified())
                .profile(profileResponse)
                .build();
    }
}