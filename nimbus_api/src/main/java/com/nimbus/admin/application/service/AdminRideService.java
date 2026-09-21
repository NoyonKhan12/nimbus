package com.nimbus.admin.application.service;

import com.nimbus.admin.domain.projection.RideAdminProjection;
import com.nimbus.kernel.application.dto.PagedResponse;
import com.nimbus.kernel.application.dto.PagedResponse.PageMeta;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;

/**
 * Service for admin ride operations.
 * Caching at the service layer to avoid ResponseEntity serialization issues.
 */
@Service
@Slf4j
public class AdminRideService {

    private final RideRepository rideRepository;

    public AdminRideService(RideRepository rideRepository) {
        this.rideRepository = rideRepository;
    }

    public PagedResponse<RideAdminProjection> listRides(int page, int size, String status) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        Ride.RideStatus statusEnum = null;
        if (status != null && !status.isEmpty()) {
            statusEnum = Ride.RideStatus.valueOf(status.toUpperCase());
        }

        Page<RideAdminProjection> ridePage = rideRepository.findAdminRides(statusEnum, pageable);
        return toPagedResponse(ridePage);
    }

    public Optional<RideAdminProjection> getRideById(String id) {
        UUID rideId = UUID.fromString(id);
        return rideRepository.findByIdProjection(rideId);
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
