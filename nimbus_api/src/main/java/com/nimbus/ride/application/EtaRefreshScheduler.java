package com.nimbus.ride.application;

import com.nimbus.ride.application.service.RideService;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * ETA/route refresh job (guide §25): recomputes and broadcasts ETA_UPDATED
 * for active rides so subscribers without fresh GPS pushes still converge.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class EtaRefreshScheduler {

    private final RideRepository rideRepository;
    private final RideService rideService;

    @Scheduled(cron = "${nimbus.eta.refresh-cron:0 * * * * *}")
    public void refreshActiveRideEtas() {
        List<Ride> active = rideRepository.findByStatus(Ride.RideStatus.IN_PROGRESS);
        for (Ride ride : active) {
            try {
                rideService.getEta(ride.getId()); // broadcasts ETA_UPDATED
            } catch (Exception e) {
                log.debug("ETA refresh skipped for ride {}: {}", ride.getId(), e.getMessage());
            }
        }
    }
}
