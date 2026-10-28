package com.nimbus.admin.application.controller;

import com.nimbus.admin.application.dto.CreateUserRequest;
import com.nimbus.admin.application.service.AdminCacheService;
import com.nimbus.admin.application.service.AdminConfigService;
import com.nimbus.admin.application.service.AdminDashboardService;
import com.nimbus.admin.application.service.AdminDriverService;
import com.nimbus.admin.application.service.AdminPaymentService;
import com.nimbus.admin.application.service.AdminRideService;
import com.nimbus.admin.application.service.AdminSettlementService;
import com.nimbus.admin.application.service.AdminUserService;
import com.nimbus.admin.application.service.AdminVehicleService;
import com.nimbus.admin.domain.projection.*;
import com.nimbus.kernel.application.dto.ApiResponse;
import com.nimbus.settlement.application.DailySettlementScheduler;
import java.time.Instant;
import com.nimbus.kernel.application.dto.PagedResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
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
    private final com.nimbus.admin.application.service.AdminRoleService roleService;
    private final AdminDriverService driverService;
    private final AdminRideService rideService;
    private final AdminPaymentService paymentService;
    private final DailySettlementScheduler dailySettlementScheduler;
    private final AdminSettlementService settlementService;
    private final com.nimbus.settlement.application.SettlementService coreSettlementService;
    private final AdminVehicleService vehicleService;
    private final AdminConfigService configService;
    private final com.nimbus.safety.application.service.SafetyService safetyService;
    private final com.nimbus.admin.application.service.AdminDetailService adminDetailService;
    private final com.nimbus.complaint.application.service.ComplaintService complaintService;
    private final com.nimbus.kernel.domain.repository.AuditLogRepository auditLogRepository;
    private final com.nimbus.audit.application.service.AuditService auditService;
    private final AdminCacheService cacheService;

    public AdminController(DailySettlementScheduler dailySettlementScheduler,AdminDashboardService dashboardService,
                           AdminUserService userService,
                           com.nimbus.admin.application.service.AdminRoleService roleService,
                           AdminDriverService driverService,
                           AdminRideService rideService,
                           AdminPaymentService paymentService,
                           AdminSettlementService settlementService,
                           com.nimbus.settlement.application.SettlementService coreSettlementService,
                           AdminVehicleService vehicleService,
                           AdminConfigService configService,
                           com.nimbus.safety.application.service.SafetyService safetyService,
                           com.nimbus.admin.application.service.AdminDetailService adminDetailService,
                           com.nimbus.complaint.application.service.ComplaintService complaintService,
                           com.nimbus.kernel.domain.repository.AuditLogRepository auditLogRepository,
                           com.nimbus.audit.application.service.AuditService auditService,
                           AdminCacheService cacheService) {
        this.dashboardService = dashboardService;
        this.userService = userService;
        this.roleService = roleService;
        this.driverService = driverService;
        this.rideService = rideService;
        this.paymentService = paymentService;
        this.settlementService = settlementService;
        this.coreSettlementService = coreSettlementService;
        this.vehicleService = vehicleService;
        this.configService = configService;
        this.safetyService = safetyService;
        this.adminDetailService = adminDetailService;
        this.complaintService = complaintService;
        this.auditLogRepository = auditLogRepository;
        this.auditService = auditService;
        this.cacheService = cacheService;
        this.dailySettlementScheduler = dailySettlementScheduler;
    }

    // ── Dashboard Stats ──────────────────────────────────────────

    @GetMapping("/dashboard/stats")
    public ResponseEntity<ApiResponse<DashboardStats>> getDashboardStats() {
        DashboardStats stats = dashboardService.getStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    // ── Users ────────────────────────────────────────────────────

    @PostMapping("/users")
    public ResponseEntity<ApiResponse<UserAdminProjection>> createUser(
            @org.springframework.validation.annotation.Validated @RequestBody CreateUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(userService.createUser(request)));
    }

    // ── Roles (dynamic) ──────────────────────────────────────────

    @GetMapping("/roles")
    public ResponseEntity<ApiResponse<java.util.List<com.nimbus.admin.application.service.AdminRoleService.RoleInfo>>> getRoles() {
        return ResponseEntity.ok(ApiResponse.success(roleService.listRoles()));
    }

    @PostMapping("/roles")
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminRoleService.RoleInfo>> createRole(
            @org.springframework.validation.annotation.Validated @org.springframework.web.bind.annotation.RequestBody
            com.nimbus.admin.application.service.AdminRoleService.CreatePayload payload) {
        try {
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(roleService.createRole(payload)));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/roles/{id}")
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminRoleService.RoleInfo>> updateRole(
            @PathVariable String id,
            @org.springframework.validation.annotation.Validated @RequestBody
            com.nimbus.admin.application.service.AdminRoleService.UpdatePayload payload) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    roleService.updateRole(java.util.UUID.fromString(id), payload)));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/roles/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteRole(@PathVariable String id) {
        try {
            roleService.deleteRole(java.util.UUID.fromString(id));
            return ResponseEntity.noContent().build();
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<PagedResponse<UserAdminProjection>>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String role) {

        try {
            PagedResponse<UserAdminProjection> paged = userService.listUsers(page, size, search, status, role);
            return ResponseEntity.ok(ApiResponse.success(paged));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminDetailService.UserDetail>> getUserDetailById(
            @PathVariable String id) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    adminDetailService.getUserDetail(java.util.UUID.fromString(id))));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
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
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminDetailService.DriverDetail>> getDriverById(
            @PathVariable String id) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    adminDetailService.getDriverDetail(java.util.UUID.fromString(id))));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
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
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminDetailService.RideDetail>> getRideById(
            @PathVariable String id) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    adminDetailService.getRideDetail(java.util.UUID.fromString(id))));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
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

    /**
     * Run the daily settlement for a UTC date (ops trigger; the scheduler
     * runs it nightly). POST /admin/settlements/run?date=YYYY-MM-DD
     */
    @PostMapping("/settlements/run")
    public ResponseEntity<ApiResponse<Integer>> runSettlement(
            @org.springframework.web.bind.annotation.RequestParam(required = false)
            @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE)
            java.time.LocalDate date) {
        java.time.LocalDate day = date != null ? date : java.time.LocalDate.now(java.time.ZoneOffset.UTC).minusDays(1);
        int created = coreSettlementService.settlePeriod(day);
        auditService.logAction(currentStaffIdOrNull(), "SETTLEMENT_PERIOD_RUN",
                "SETTLEMENT", null, "period=" + day, "rows=" + created);
        return ResponseEntity.ok(ApiResponse.<Integer>builder()
                .success(true)
                .data(created)
                .timestamp(Instant.now().toString())
                .build());
    }

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
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminDetailService.SettlementDetail>> getSettlementById(@PathVariable String id) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    adminDetailService.getSettlementDetail(java.util.UUID.fromString(id))));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Settle (pay out) a settlement: posts the DRIVER_SETTLEMENT ledger
     * entry, marks PAID and clears the driver's due.
     * POST /admin/settlements/{id}/settle
     */
    @PostMapping("/settlements/{id}/settle")
    public ResponseEntity<ApiResponse<com.nimbus.settlement.application.SettlementResponse>> settleSettlement(
            @PathVariable String id) {
        try {
            var settled = coreSettlementService.processSettlement(java.util.UUID.fromString(id));
            return ResponseEntity.ok(ApiResponse.success(settled, "Settlement paid"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // ── Vehicles (guide §20: approval/suspension/document review) ────────

    @GetMapping("/vehicles")
    public ResponseEntity<ApiResponse<PagedResponse<AdminVehicleService.VehicleAdminRow>>> getVehicles(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status) {
        try {
            return ResponseEntity.ok(ApiResponse.success(vehicleService.listVehicles(page, size, status)));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/vehicles/{id}")
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminDetailService.VehicleDetail>> getVehicleById(
            @PathVariable String id) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    adminDetailService.getVehicleDetail(java.util.UUID.fromString(id))));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Approve / reject / suspend a vehicle.
     * PATCH /admin/vehicles/{id}/status  body: {"status": "APPROVED"}
     */
    @PatchMapping("/vehicles/{id}/status")
    public ResponseEntity<ApiResponse<AdminVehicleService.VehicleAdminRow>> updateVehicleStatus(
            @PathVariable String id, @RequestBody Map<String, String> body) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    vehicleService.updateVehicleStatus(id, body.get("status")),
                    "Vehicle status updated"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // ── Driver suspension (guide §20) ────────────────────────────────────

    /**
     * Set a driver's approval status — suspend / reinstate via
     * PENDING|APPROVED|REJECTED|SUSPENDED.
     * PATCH /admin/drivers/{id}/approval  body: {"status": "SUSPENDED"}
     */
    @PatchMapping("/drivers/{id}/approval")
    public ResponseEntity<ApiResponse<Void>> setDriverApproval(
            @PathVariable String id, @RequestBody Map<String, String> body) {
        try {
            driverService.setApprovalStatus(id, body.get("status"));
            return ResponseEntity.ok(ApiResponse.success(null, "Driver approval status updated"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // ── Configuration (guide §20) ────────────────────────────────────────

    @GetMapping("/config")
    public ResponseEntity<ApiResponse<List<com.nimbus.kernel.domain.entity.SystemConfiguration>>>
            getConfiguration() {
        return ResponseEntity.ok(ApiResponse.success(configService.listConfiguration()));
    }

    /**
     * Create/update an operational configuration value (fare/commission/
     * voucher/detour/wait etc.). PUT /admin/config/{key}
     */
    @PutMapping("/config/{key}")
    public ResponseEntity<ApiResponse<com.nimbus.kernel.domain.entity.SystemConfiguration>>
            updateConfiguration(@PathVariable String key, @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(ApiResponse.success(
                configService.upsert(key, body.get("value"), body.get("description")),
                "Configuration updated"));
    }

    // ── Audit trail (guide §20: full audit for privileged actions) ───────

    @GetMapping("/audit-logs")
    public ResponseEntity<ApiResponse<PagedResponse<com.nimbus.kernel.domain.entity.AuditLog>>>
            getAuditLogs(@RequestParam(defaultValue = "0") int page,
                         @RequestParam(defaultValue = "50") int size) {
        var logs = auditLogRepository.findAll(
                org.springframework.data.domain.PageRequest.of(page, size,
                        org.springframework.data.domain.Sort.by(
                                org.springframework.data.domain.Sort.Direction.DESC, "createdAt")));
        var meta = new com.nimbus.kernel.application.dto.PagedResponse.PageMeta(
                logs.getNumber(), logs.getSize(), logs.getTotalElements(), logs.getTotalPages());
        return ResponseEntity.ok(ApiResponse.success(
                com.nimbus.kernel.application.dto.PagedResponse
                        .<com.nimbus.kernel.domain.entity.AuditLog>builder()
                        .success(true)
                        .data(logs.getContent())
                        .meta(meta)
                        .timestamp(Instant.now().toString())
                        .build()));
    }

    // ── Safety operations (guide §20: SOS ops) ───────────────────────────

    /**
     * Acknowledge/escalate/resolve a safety event.
     * PATCH /admin/safety/{eventId}/status  body: {"status": "ESCALATED"}
     */
    @PatchMapping("/safety/{eventId}/status")
    public ResponseEntity<ApiResponse<com.nimbus.safety.domain.entity.SafetyEvent>>
            updateSafetyEventStatus(@PathVariable String eventId, @RequestBody Map<String, String> body) {
        try {
            var event = safetyService.updateSafetyEventStatus(
                    java.util.UUID.fromString(eventId),
                    com.nimbus.safety.domain.entity.SafetyEvent.EventStatus.valueOf(
                            body.getOrDefault("status", "IN_PROGRESS").toUpperCase()));
            return ResponseEntity.ok(ApiResponse.success(event, "Safety event updated"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    // ── Complaint operations (guide §20) ─────────────────────────────────

    @GetMapping("/complaints")
    public ResponseEntity<ApiResponse<List<com.nimbus.complaint.domain.entity.Complaint>>>
            getComplaints(@RequestParam(required = false) String status) {
        if (status != null && !status.isEmpty()) {
            var complaintStatus = com.nimbus.complaint.domain.entity.Complaint.ComplaintStatus
                    .valueOf(status.toUpperCase());
            return ResponseEntity.ok(ApiResponse.success(
                    complaintService.getComplaintsByStatus(complaintStatus)));
        }
        return ResponseEntity.ok(ApiResponse.success(complaintService.getAllComplaints()));
    }
    @GetMapping("/complaints/{id}")
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminDetailService.ComplaintDetail>> getComplaintById(@PathVariable String id) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    adminDetailService.getComplaintDetail(java.util.UUID.fromString(id))));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/safety/{id}")
    public ResponseEntity<ApiResponse<com.nimbus.admin.application.service.AdminDetailService.SafetyDetail>> getSafetyEventById(@PathVariable String id) {
        try {
            return ResponseEntity.ok(ApiResponse.success(
                    adminDetailService.getSafetyDetail(java.util.UUID.fromString(id))));
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    private UUID currentStaffIdOrNull() {
        var auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        if (auth instanceof com.nimbus.kernel.infrastructure.security.UserAuthenticationToken t) {
            return t.getUserId();
        }
        return null;
    }
}
