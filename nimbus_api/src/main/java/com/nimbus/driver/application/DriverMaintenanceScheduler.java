package com.nimbus.driver.application;

import com.nimbus.driver.domain.entity.DriverProfile;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

/**
 * Eligibility reconciliation job (guide §25): recalculates driver
 * availability when credentials lapse — an expired license takes the
 * driver OFFLINE until the document is refreshed. Existing confirmed
 * rides are NOT cancelled (operations handles exceptions, guide §5).
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DriverMaintenanceScheduler {

    private final DriverProfileRepository driverProfileRepository;

    @Scheduled(fixedDelay = 300_000)
    @Transactional
    public void reconcileEligibility() {
        List<DriverProfile> all = driverProfileRepository.findAll();
        int takenOffline = 0;
        for (DriverProfile profile : all) {
            if (profile.getApprovalStatus() != DriverProfile.ApprovalStatus.APPROVED) continue;
            boolean licenseExpired = profile.getLicenseExpiry() != null
                    && profile.getLicenseExpiry().isBefore(Instant.now());
            if (licenseExpired && profile.getDriverStatus() == DriverProfile.DriverStatus.ONLINE) {
                profile.setDriverStatus(DriverProfile.DriverStatus.OFFLINE);
                driverProfileRepository.save(profile);
                takenOffline++;
                log.info("Driver {} taken OFFLINE: license expired", profile.getId());
            }
        }
        if (takenOffline > 0) {
            log.info("Eligibility reconciliation: {} drivers taken offline", takenOffline);
        }
    }
}
