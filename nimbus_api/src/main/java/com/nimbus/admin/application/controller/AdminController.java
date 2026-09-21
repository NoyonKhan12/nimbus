package com.nimbus.admin.application.controller;

import com.nimbus.admin.application.service.AdminCacheService;
import com.nimbus.admin.application.service.AdminDashboardService;
import com.nimbus.admin.application.service.AdminDriverService;
import com.nimbus.admin.application.service.AdminPaymentService;
import com.nimbus.admin.application.service.AdminRideService;
import com.nimbus.admin.application.service.AdminSettlementService;
import com.nimbus.admin.application.service.AdminUserService;
import com.nimbus.admin.domain.projection.*;
import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.kernel.application.dto.PagedResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Admin controller providing listing and management endpoints for users,
 * drivers, rides, payments, and settlements.
 *
 * Optimizations applied:
 * - Single-query dashboard stats via aggregate functions
 * - Projection-based queries to avoid N+1 lazy loading
 * - Pagination via Page<T> (includes total counts)
 * - Redis caching for stats (2 min) and listings (5 min) at the service layer
 * - Cache eviction on mutations via AdminCacheService
 */
@RestController
@RequestMapping("/admin")
@Slf4j
public class AdminController {

    private final AdminDashboardService dashboardService;
    private final AdminUserService userService;
    private final AdminDriverService driverService;
    private final AdminRideService rideService;
    private final AdminPaymentService paymentService;
    private final AdminSettlementService settlementService;
    private final AdminCacheService cacheService;

    public AdminController(AdminDashboardService dashboardService,
                           AdminUserService userService,
                           AdminDriverService driverService,
                           AdminRideService rideService,
                           AdminPaymentService paymentService,
                           AdminSettlementService settlementService,
                           AdminCacheService cacheService) {
        this.dashboardService = dashboardService;
        this.userService = userService;
        this.driverService = driverService;
        this.rideService = rideService;
        this.paymentService = paymentService;
        this.settlementService = settlementService;
        this.cacheService = cacheService;
    }

    // ── Dashboard Stats ──────────────────────────────────────────

    @GetMapping("/dashboard/stats")
    public ResponseEntity<ApiResponse<DashboardStats>> getDashboardStats() {
        DashboardStats stats = dashboardService.getStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    // ── Users ────────────────────────────────────────────────────

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<PagedResponse<UserAdminProjection>>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status) {

        try {
            PagedResponse<UserAdminProjection> paged = userService.listUsers(page, size, search, status);
            return ResponseEntity.ok(ApiResponse.success(paged));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<ApiResponse<UserAdminProjection>> getUserById(@PathVariable String id) {
        return userService.getUserById(id)
                .map(u -> ResponseEntity.ok(ApiResponse.success(u)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/users/{id}/status")
    public ResponseEntity<ApiResponse<Void>> updateUserStatus(@PathVariable String id,
                                                                 @RequestBody Map<String, String> body) {
        try {
            userService.updateUserStatus(id, body.get("status"));
            return ResponseEntity.ok(ApiResponse.success(null, "User status updated"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable String id) {
        try {
            userService.deleteUser(id);
            return ResponseEntity.ok(ApiResponse.success(null, "User deleted"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // ── Drivers ──────────────────────────────────────────────────

    @GetMapping("/drivers")
    public ResponseEntity<ApiResponse<PagedResponse<DriverAdminProjection>>> getDrivers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status) {

        try {
            PagedResponse<DriverAdminProjection> paged = driverService.listDrivers(page, size, search, status);
            return ResponseEntity.ok(ApiResponse.success(paged));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/drivers/{id}")
    public ResponseEntity<ApiResponse<DriverAdminProjection>> getDriverById(@PathVariable String id) {
        return driverService.getDriverById(id)
                .map(d -> ResponseEntity.ok(ApiResponse.success(d)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/drivers/{id}/approve")
    public ResponseEntity<ApiResponse<Void>> approveDriver(@PathVariable String id) {
        try {
            driverService.approveDriver(id);
            return ResponseEntity.ok(ApiResponse.success(null, "Driver approved"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PatchMapping("/drivers/{id}/reject")
    public ResponseEntity<ApiResponse<Void>> rejectDriver(@PathVariable String id,
                                                            @RequestBody(required = false) Map<String, String> body) {
        try {
            driverService.rejectDriver(id);
            return ResponseEntity.ok(ApiResponse.success(null, "Driver rejected"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PatchMapping("/drivers/{id}/status")
    public ResponseEntity<ApiResponse<Void>> updateDriverStatus(@PathVariable String id,
                                                                 @RequestBody Map<String, String> body) {
        try {
            driverService.updateDriverStatus(id, body.get("status"));
            return ResponseEntity.ok(ApiResponse.success(null, "Driver status updated"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // ── Rides ───────────────────────────────────────────────────

    @GetMapping("/rides")
    public ResponseEntity<ApiResponse<PagedResponse<RideAdminProjection>>> getRides(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status) {

        try {
            PagedResponse<RideAdminProjection> paged = rideService.listRides(page, size, status);
            return ResponseEntity.ok(ApiResponse.success(paged));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/rides/{id}")
    public ResponseEntity<ApiResponse<RideAdminProjection>> getRideById(@PathVariable String id) {
        return rideService.getRideById(id)
                .map(r -> ResponseEntity.ok(ApiResponse.success(r)))
                .orElse(ResponseEntity.notFound().build());
    }

    // ── Payments ────────────────────────────────────────────────

    @GetMapping("/payments")
    public ResponseEntity<ApiResponse<PagedResponse<PaymentAdminProjection>>> getPayments(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status) {

        try {
            PagedResponse<PaymentAdminProjection> paged = paymentService.listPayments(page, size, status);
            return ResponseEntity.ok(ApiResponse.success(paged));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/payments/{id}")
    public ResponseEntity<ApiResponse<PaymentAdminProjection>> getPaymentById(@PathVariable String id) {
        return paymentService.getPaymentById(id)
                .map(p -> ResponseEntity.ok(ApiResponse.success(p)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/payments/{id}/refund")
    public ResponseEntity<ApiResponse<Void>> refundPayment(@PathVariable String id,
                                                            @RequestBody Map<String, Object> body) {
        try {
            paymentService.refundPayment(id);
            return ResponseEntity.ok(ApiResponse.success(null, "Payment refunded"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // ── Settlements ─────────────────────────────────────────────

    @GetMapping("/settlements")
    public ResponseEntity<ApiResponse<PagedResponse<SettlementAdminProjection>>> getSettlements(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status) {

        try {
            PagedResponse<SettlementAdminProjection> paged = settlementService.listSettlements(page, size, status);
            return ResponseEntity.ok(ApiResponse.success(paged));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/settlements/{id}")
    public ResponseEntity<ApiResponse<SettlementAdminProjection>> getSettlementById(@PathVariable String id) {
        return settlementService.getSettlementById(id)
                .map(s -> ResponseEntity.ok(ApiResponse.success(s)))
                .orElse(ResponseEntity.notFound().build());
    }
}
