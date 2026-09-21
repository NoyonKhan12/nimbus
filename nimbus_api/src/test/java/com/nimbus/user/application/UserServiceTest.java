package com.nimbus.user.application;

import com.nimbus.user.application.*;
import com.nimbus.user.application.service.UserService;
import com.nimbus.kernel.domain.entity.*;
import com.nimbus.kernel.domain.repository.*;
import org.locationtech.jts.geom.*;
import com.nimbus.kernel.infrastructure.security.UserAuthenticationToken;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.Instant;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private UserProfileRepository userProfileRepository;
    @Mock private SavedLocationRepository savedLocationRepository;

    private UserService userService;

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository, userProfileRepository, savedLocationRepository);
    }

    private void setUpSecurityContext(User user) {
        UserAuthenticationToken auth = new UserAuthenticationToken(user);
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @Test
    void saveLocation_savesLocationSuccessfully() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .phone("+8801712345678")
                .role(User.UserRole.PASSENGER)
                .status(User.UserStatus.ACTIVE)
                .build();
        setUpSecurityContext(user);

        SaveLocationRequest request = SaveLocationRequest.builder()
                .label("Home")
                .address("123 Main Street, Dhaka")
                .latitude(23.7037)
                .longitude(90.4078)
                .build();

        GeometryFactory factory = new GeometryFactory();
        Point point = factory.createPoint(new Coordinate(90.4078, 23.7037));
        point.setSRID(4326);

        SavedLocation savedLocation = SavedLocation.builder()
                .id(UUID.randomUUID())
                .user(user)
                .label("Home")
                .address("123 Main Street, Dhaka")
                .location(point)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        when(savedLocationRepository.existsByUserIdAndLabel(user.getId(), "Home")).thenReturn(false);
        when(savedLocationRepository.save(any(SavedLocation.class))).thenReturn(savedLocation);

        SavedLocationResponse response = userService.saveLocation(request);

        assertNotNull(response);
        assertEquals("Home", response.getLabel());
        assertEquals("123 Main Street, Dhaka", response.getAddress());
        verify(savedLocationRepository).save(any(SavedLocation.class));
    }

    @Test
    void saveLocation_duplicateLabel_throwsException() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .phone("+8801712345678")
                .role(User.UserRole.PASSENGER)
                .status(User.UserStatus.ACTIVE)
                .build();
        setUpSecurityContext(user);

        SaveLocationRequest request = SaveLocationRequest.builder()
                .label("Home")
                .address("123 Main Street, Dhaka")
                .latitude(23.7037)
                .longitude(90.4078)
                .build();

        when(savedLocationRepository.existsByUserIdAndLabel(user.getId(), "Home")).thenReturn(true);

        Assertions.assertThrows(com.nimbus.kernel.domain.exception.NimbusException.class,
                () -> userService.saveLocation(request));
        verify(savedLocationRepository, never()).save(any(SavedLocation.class));
    }

    @Test
    void getSavedLocations_returnsEmptyListWhenNoLocations() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .phone("+8801712345678")
                .role(User.UserRole.PASSENGER)
                .status(User.UserStatus.ACTIVE)
                .build();
        setUpSecurityContext(user);

        when(savedLocationRepository.findByUserId(user.getId())).thenReturn(Collections.emptyList());

        List<SavedLocationResponse> locations = userService.getSavedLocations();

        assertNotNull(locations);
        assertTrue(locations.isEmpty());
        verify(savedLocationRepository).findByUserId(user.getId());
    }

    @Test
    void getSavedLocations_returnsLocationsWhenPresent() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .phone("+8801712345678")
                .role(User.UserRole.PASSENGER)
                .status(User.UserStatus.ACTIVE)
                .build();
        setUpSecurityContext(user);

        List<SavedLocation> locations = List.of(
                SavedLocation.builder()
                        .id(UUID.randomUUID())
                        .user(user)
                        .label("Home")
                        .address("Dhaka")
                        .createdAt(Instant.now())
                        .updatedAt(Instant.now())
                        .build()
        );

        when(savedLocationRepository.findByUserId(user.getId())).thenReturn(locations);

        List<SavedLocationResponse> responses = userService.getSavedLocations();

        assertNotNull(responses);
        assertEquals(1, responses.size());
        assertEquals("Home", responses.get(0).getLabel());
    }
}
