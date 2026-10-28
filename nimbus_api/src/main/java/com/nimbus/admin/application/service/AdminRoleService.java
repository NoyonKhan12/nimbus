package com.nimbus.admin.application.service;

import com.nimbus.kernel.domain.entity.Role;
import com.nimbus.kernel.domain.repository.RoleRepository;
import com.nimbus.kernel.domain.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.regex.Pattern;

/**
 * CRUD for dynamic staff roles (Settings → Users → Roles) plus validation
 * and permission handling shared with user creation.
 */
@Service
@Slf4j
public class AdminRoleService {

    public static final Pattern NAME_PATTERN = Pattern.compile("^[A-Z][A-Z0-9_]{1,31}$");
    private static final Set<String> APP_ONLY_ROLES = Set.of("PASSENGER", "DRIVER");
    private static final Set<String> VALID_ACCESS = Set.of("FULL", "VIEW", "NONE");

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final AdminCacheService cacheService;
    private final com.nimbus.audit.application.service.AuditService auditService;

    public AdminRoleService(RoleRepository roleRepository,
                            UserRepository userRepository,
                            AdminCacheService cacheService,
                            com.nimbus.audit.application.service.AuditService auditService) {
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
        this.cacheService = cacheService;
        this.auditService = auditService;
    }

    // ── DTOs ─────────────────────────────────────────────────────────────

    public record RoleInfo(
            UUID id, String name, String description, boolean system,
            Map<String, String> permissions, long userCount,
            Instant createdAt, Instant updatedAt) {}

    public interface UpsertPayload {
        String name();
        String description();
        Map<String, String> permissions();
    }

    public static record CreatePayload(
            String name, String description, Map<String, String> permissions) implements UpsertPayload {}

    public static record UpdatePayload(
            String name, String description, Map<String, String> permissions) implements UpsertPayload {}

    // ── Queries ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<RoleInfo> listRoles() {
        return roleRepository.findAll().stream()
                .map(r -> new RoleInfo(
                        r.getId(), r.getName(), r.getDescription(), r.isSystem(),
                        r.permissions(), userRepository.countByRole(r.getName()),
                        r.getCreatedAt(), r.getUpdatedAt()))
                .sorted(Comparator.comparing(RoleInfo::name))
                .toList();
    }

    @Transactional(readOnly = true)
    public Optional<RoleInfo> getRole(UUID id) {
        return roleRepository.findById(id)
                .map(r -> new RoleInfo(
                        r.getId(), r.getName(), r.getDescription(), r.isSystem(),
                        r.permissions(), userRepository.countByRole(r.getName()),
                        r.getCreatedAt(), r.getUpdatedAt()));
    }

    // ── Validation helpers (shared with user creation) ───────────────────

    /**
     * Returns true when the role exists and can be assigned to a staff user
     * (i.e. not one of the two app-only roles).
     */
    public boolean isUsableStaffRole(String roleName) {
        if (roleName == null) return false;
        String name = roleName.toUpperCase();
        if (APP_ONLY_ROLES.contains(name)) return false;
        return roleRepository.existsByName(name);
    }

    // ── CRUD ─────────────────────────────────────────────────────────────

    @Transactional
    public RoleInfo createRole(UpsertPayload payload) {
        String name = payload.name() == null ? "" : payload.name().trim().toUpperCase();
        if (!NAME_PATTERN.matcher(name).matches()) {
            throw newNameError();
        }
        if (APP_ONLY_ROLES.contains(name)) {
            throw reject("The roles PASSENGER and DRIVER belong to the mobile apps and cannot be recreated");
        }
        if (roleRepository.existsByName(name)) {
            throw reject("A role with the name " + name + " already exists");
        }
        Role role = Role.builder()
                .name(name)
                .description(normalizeDescription(payload.description()))
                .system(false)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        role.setPermissions(normalizePermissions(payload.permissions()));
        role = roleRepository.save(role);
        cacheService.invalidateUsers();
        auditService.logAction(null, "ROLE_CREATED", "ROLE", role.getId(),
                null, "name=" + name);
        return toInfo(role, 0);
    }

    @Transactional
    public RoleInfo updateRole(UUID id, UpsertPayload payload) {
        Role role = roleRepository.findById(id)
                .orElseThrow(() -> new java.util.NoSuchElementException("Role not found"));
        if (payload.name() != null && !payload.name().isBlank()
                && !payload.name().trim().toUpperCase().equals(role.getName())) {
            throw reject("Role names are immutable — create a new role instead");
        }
        if (payload.description() != null) {
            role.setDescription(normalizeDescription(payload.description()));
        }
        if (payload.permissions() != null) {
            role.setPermissions(normalizePermissions(payload.permissions()));
        }
        role.setUpdatedAt(Instant.now());
        role = roleRepository.save(role);
        cacheService.invalidateUsers();
        auditService.logAction(null, "ROLE_UPDATED", "ROLE", id,
                null, role.getName());
        return toInfo(role, userRepository.countByRole(role.getName()));
    }

    @Transactional
    public void deleteRole(UUID id) {
        Role role = roleRepository.findById(id)
                .orElseThrow(() -> new java.util.NoSuchElementException("Role not found"));
        if (role.isSystem()) {
            throw reject("System roles cannot be deleted");
        }
        long inUse = userRepository.countByRole(role.getName());
        if (inUse > 0) {
            throw reject("This role is assigned to " + inUse
                    + " user(s) — reassign them before deleting");
        }
        role.setDeletedAt(Instant.now());
        roleRepository.save(role);
        cacheService.invalidateUsers();
        auditService.logAction(null, "ROLE_DELETED", "ROLE", id,
                null, role.getName());
    }

    // ── Internals ────────────────────────────────────────────────────────

    private com.nimbus.kernel.domain.exception.NimbusException newNameError() {
        return reject("Role name must be 2-32 characters: letters, digits and underscores, "
                + "starting with a letter (e.g. CITY_MANAGER)");
    }

    private com.nimbus.kernel.domain.exception.NimbusException reject(String message) {
        return new com.nimbus.kernel.domain.exception.NimbusException(
                com.nimbus.kernel.domain.ErrorCode.USER_INVALID_INPUT, message);
    }

    private String normalizeDescription(String description) {
        if (description == null || description.isBlank()) return null;
        return description.trim();
    }

    private Map<String, String> normalizePermissions(Map<String, String> permissions) {
        Map<String, String> normalized = new HashMap<>();
        if (permissions != null) {
            for (String key : Role.CAPABILITY_KEYS) {
                String value = permissions.get(key);
                normalized.put(key, value != null && VALID_ACCESS.contains(value.toUpperCase())
                        ? value.toUpperCase() : "NONE");
            }
        } else {
            for (String key : Role.CAPABILITY_KEYS) normalized.put(key, "NONE");
        }
        return normalized;
    }

    private RoleInfo toInfo(Role role, long userCount) {
        return new RoleInfo(role.getId(), role.getName(), role.getDescription(),
                role.isSystem(), role.permissions(), userCount,
                role.getCreatedAt(), role.getUpdatedAt());
    }

}
