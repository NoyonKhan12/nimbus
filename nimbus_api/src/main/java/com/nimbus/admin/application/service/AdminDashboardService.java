package com.nimbus.admin.application.service;

import com.nimbus.admin.domain.projection.DashboardStats;
import com.nimbus.admin.domain.projection.RecentRide;
import com.nimbus.driver.domain.repository.DriverProfileRepository;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.payment.domain.entity.Payment;
import com.nimbus.payment.domain.repository.PaymentRepository;
import com.nimbus.ride.domain.entity.Ride;
import com.nimbus.ride.domain.repository.RideRepository;
import com.nimbus.settlement.domain.entity.Settlement;
import com.nimbus.settlement.domain.repository.SettlementRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * Service for admin dashboard statistics.
 * Caches results for 2 minutes to reduce load on the database.
 * All aggregates computed via single-query COUNT/SUM operations.
 */
@Service
@Slf4j
public class AdminDashboardService {

    private final UserRepository userRepository;
    private final DriverProfileRepository driverProfileRepository;
    private final RideRepository rideRepository;
    private final PaymentRepository paymentRepository;
    private final SettlementRepository settlementRepository;

    public AdminDashboardService(UserRepository userRepository,
                                 DriverProfileRepository driverProfileRepository,
                                 RideRepository rideRepository,
                                 PaymentRepository paymentRepository,
                                 SettlementRepository settlementRepository) {
        this.userRepository = userRepository;
        this.driverProfileRepository = driverProfileRepository;
        this.rideRepository = rideRepository;
        this.paymentRepository = paymentRepository;
        this.settlementRepository = settlementRepository;
    }

    /**
     * Dashboard stats — computed via single-query aggregates per stat.
     * Caching disabled to avoid Redis deserialization issues with record types.
     */
    public DashboardStats getStats() {
        long totalUsers = userRepository.count();
        long totalDrivers = driverProfileRepository.count();

        List<Ride.RideStatus> activeStatuses = Arrays.asList(
            Ride.RideStatus.IN_PROGRESS, Ride.RideStatus.DRIVER_ARRIVING
        );
        long activeRides = rideRepository.countByStatusIn(activeStatuses);
        long totalRides = rideRepository.count();
        long totalPayments = paymentRepository.countSuccessfulPayments(Payment.PaymentStatus.SUCCESS);
        long pendingSettlements = settlementRepository.countByStatus(Settlement.SettlementStatus.PENDING);

        java.math.BigDecimal totalRevenue = paymentRepository.sumTotalRevenue(Payment.PaymentStatus.SUCCESS);
        String revenueStr = totalRevenue != null ? totalRevenue.toPlainString() : "0";

        // Fetch recent rides via projection (single JOIN query, no N+1)
        Pageable recentRidePage = PageRequest.of(0, 5, Sort.by(Sort.Direction.DESC, "createdAt"));
        List<RecentRide> recentRides = rideRepository.findRecentRides(recentRidePage);

        return new DashboardStats(
            totalUsers, totalDrivers, activeRides, totalRides,
            totalPayments, pendingSettlements, revenueStr, recentRides
        );
    }
}
