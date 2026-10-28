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
    private final com.nimbus.booking.domain.repository.BookingRepository bookingRepository;
    private final com.nimbus.ride.domain.repository.RideRepository rideRepository;

    @org.springframework.beans.factory.annotation.Value("${app.upload.dir:./data/uploads}")
    private String uploadDir;

    /** Context path prefix so stored photo URLs resolve against the base URL. */
    @org.springframework.beans.factory.annotation.Value("${server.servlet.context-path:/api/v1}")
    private String contextPath;

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
                .map(this::toLocationResponse)
                .collect(Collectors.toList());
    }

    /**
     * Update a saved location (guide §15 saved-locations lifecycle).
     */
    @Transactional
    public SavedLocationResponse updateLocation(UUID locationId, SaveLocationRequest request) {
        User user = getCurrentUserFromContext();
        SavedLocation location = ownedLocation(user, locationId);

        if (request.getLabel() != null) {
            savedLocationRepository.findByUserIdAndLabel(user.getId(), request.getLabel())
                    .stream()
                    .filter(other -> !other.getId().equals(locationId))
                    .findFirst()
                    .ifPresent(other -> {
                        throw new NimbusException(ErrorCode.CONFLICT,
                                "A location with label '" + request.getLabel() + "' already exists",
                                HttpStatus.CONFLICT);
                    });
            location.setLabel(request.getLabel());
        }
        if (request.getAddress() != null) {
            location.setAddress(request.getAddress());
        }
        if (request.getLatitude() != null && request.getLongitude() != null) {
            GeometryFactory factory = new GeometryFactory();
            Point point = factory.createPoint(
                    new Coordinate(request.getLongitude(), request.getLatitude()));
            point.setSRID(4326);
            location.setLocation(point);
        }
        location.setUpdatedAt(Instant.now());
        return toLocationResponse(savedLocationRepository.save(location));
    }

    /**
     * Delete a saved location (guide §15 saved-locations lifecycle).
     */
    @Transactional
    public void deleteLocation(UUID locationId) {
        User user = getCurrentUserFromContext();
        SavedLocation location = ownedLocation(user, locationId);
        savedLocationRepository.delete(location);
    }

    private SavedLocation ownedLocation(User user, UUID locationId) {
        SavedLocation location = savedLocationRepository.findById(locationId)
                .orElseThrow(() -> new NimbusException(ErrorCode.NOT_FOUND,
                        "Saved location not found", HttpStatus.NOT_FOUND));
        if (!location.getUser().getId().equals(user.getId())) {
            throw new NimbusException(ErrorCode.FORBIDDEN, HttpStatus.FORBIDDEN);
        }
        return location;
    }

    /** JTS Point X is longitude, Y is latitude — keep them straight. */
    private SavedLocationResponse toLocationResponse(SavedLocation loc) {
        return SavedLocationResponse.builder()
                .id(loc.getId().toString())
                .label(loc.getLabel())
                .address(loc.getAddress())
                .latitude(loc.getLocation() != null ? loc.getLocation().getY() : 0.0)
                .longitude(loc.getLocation() != null ? loc.getLocation().getX() : 0.0)
                .build();
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

            return toLocationResponse(saved);
        } catch (NimbusException e) {
            throw e;
        } catch (Exception e) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Invalid location coordinates: " + e.getMessage(),
                    HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * Recent journey history for the current user (guide §15 GET
     * /me/history): bookings they made as a passenger plus rides they
     * created as a driver, newest first.
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getHistory() {
        User user = getCurrentUserFromContext();
        List<Map<String, Object>> history = new ArrayList<>();

        bookingRepository.findByPassengerId(user.getId()).stream()
                .limit(50)
                .forEach(b -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("type", "BOOKING");
                    item.put("id", b.getId().toString());
                    item.put("status", b.getStatus().name());
                    item.put("role", "PASSENGER");
                    if (b.getRide() != null) {
                        item.put("rideId", b.getRide().getId().toString());
                        item.put("origin", b.getPickupAddress() != null
                                ? b.getPickupAddress() : b.getRide().getOriginAddress());
                        item.put("destination", b.getDropoffAddress() != null
                                ? b.getDropoffAddress() : b.getRide().getDestinationAddress());
                    }
                    item.put("finalPayable", b.getFinalPayable());
                    item.put("timestamp", b.getCreatedAt());
                    history.add(item);
                });

        rideRepository.findByCreatorId(user.getId()).stream()
                .limit(50)
                .forEach(r -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("type", "RIDE");
                    item.put("id", r.getId().toString());
                    item.put("status", r.getStatus().name());
                    item.put("role", "DRIVER");
                    item.put("origin", r.getOriginAddress());
                    item.put("destination", r.getDestinationAddress());
                    item.put("timestamp", r.getScheduledAt() != null ? r.getScheduledAt() : r.getCreatedAt());
                    history.add(item);
                });

        history.sort((a, b) -> {
            Instant ta = (Instant) a.get("timestamp");
            Instant tb = (Instant) b.get("timestamp");
            return tb != null ? (ta != null ? tb.compareTo(ta) : 1) : (ta != null ? -1 : 0);
        });
        return history;
    }

    /**
     * Store a profile photo upload (guide §15 POST /me/photo). Files live
     * under the configured upload dir and are served from /uploads/**.
     */
    @Transactional
    public String updateProfilePhoto(org.springframework.web.multipart.MultipartFile file) {
        User user = getCurrentUserFromContext();
        if (file == null || file.isEmpty()) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Photo file is required", HttpStatus.BAD_REQUEST);
        }
        String original = file.getOriginalFilename() != null ? file.getOriginalFilename() : "photo";
        String ext = original.contains(".")
                ? original.substring(original.lastIndexOf('.')).toLowerCase() : ".jpg";
        if (!Set.of(".jpg", ".jpeg", ".png", ".webp").contains(ext)) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Only JPG, PNG or WebP images are allowed", HttpStatus.BAD_REQUEST);
        }
        if (file.getSize() > 5 * 1024 * 1024) {
            throw new NimbusException(ErrorCode.BAD_REQUEST,
                    "Photo must be 5 MB or smaller", HttpStatus.BAD_REQUEST);
        }
        try {
            java.nio.file.Path dir = java.nio.file.Path.of(uploadDir, "profile");
            java.nio.file.Files.createDirectories(dir);
            String filename = "profile-" + user.getId() + "-" + System.currentTimeMillis() + ext;
            java.nio.file.Files.copy(file.getInputStream(), dir.resolve(filename),
                    java.nio.file.StandardCopyOption.REPLACE_EXISTING);

            UserProfile profile = userProfileRepository.findByUserId(user.getId())
                    .orElseGet(() -> UserProfile.builder()
                            .user(user)
                            .createdAt(Instant.now())
                            .updatedAt(Instant.now())
                            .build());
            profile.setProfilePhotoUrl(contextPath + "/uploads/profile/" + filename);
            profile.setUpdatedAt(Instant.now());
            userProfileRepository.save(profile);
            return profile.getProfilePhotoUrl();
        } catch (NimbusException e) {
            throw e;
        } catch (Exception e) {
            log.error("Photo upload failed: {}", e.getMessage());
            throw new NimbusException(ErrorCode.INTERNAL_ERROR,
                    "Failed to store photo", HttpStatus.INTERNAL_SERVER_ERROR);
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