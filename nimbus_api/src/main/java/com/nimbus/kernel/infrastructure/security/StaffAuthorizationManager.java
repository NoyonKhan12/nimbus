package com.nimbus.kernel.infrastructure.security;

import com.nimbus.kernel.domain.entity.Role;
import com.nimbus.kernel.domain.repository.RoleRepository;
import org.springframework.security.authentication.AuthenticationTrustResolver;
import org.springframework.security.authentication.AuthenticationTrustResolverImpl;
import org.springframework.security.authorization.AuthorizationDecision;
import org.springframework.security.authorization.AuthorizationManager;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.access.intercept.RequestAuthorizationContext;

import java.util.function.Supplier;

/**
 * Gate for the staff portal (/admin/**, /internal/**).
 *
 * <p>Roles are dynamic, so authentication only proves that the caller has a
 * staff role. Authorization then maps the request path to a capability and
 * enforces the access level stored on that role (Settings → Roles):
 * FULL allows reads and writes, VIEW allows reads only, NONE denies.
 * PASSENGER and DRIVER can never reach the portal.</p>
 */
public class StaffAuthorizationManager implements AuthorizationManager<RequestAuthorizationContext> {

    private static final AuthenticationTrustResolver TRUST = new AuthenticationTrustResolverImpl();

    private final RoleRepository roleRepository;

    public StaffAuthorizationManager(RoleRepository roleRepository) {
        this.roleRepository = roleRepository;
    }

    @Override
    public AuthorizationDecision check(Supplier<Authentication> authentication,
                                       RequestAuthorizationContext context) {
        Authentication auth = authentication.get();
        if (TRUST.isAnonymous(auth) || TRUST.isRememberMe(auth)) {
            return new AuthorizationDecision(false);
        }
        String roleName = roleName(auth);
        if (roleName == null || "PASSENGER".equals(roleName) || "DRIVER".equals(roleName)) {
            return new AuthorizationDecision(false);
        }

        Role role = roleRepository.findByName(roleName).orElse(null);
        if (role == null) {
            return new AuthorizationDecision(false);
        }

        // Portal shell endpoints (profile, dashboard) are available to every
        // staff member; capability-specific endpoints are checked below.
        String path = context.getRequest().getRequestURI();
        String contextPath = context.getRequest().getContextPath();
        if (contextPath != null && !contextPath.isEmpty() && path.startsWith(contextPath)) {
            path = path.substring(contextPath.length());
        }
        String capability = capabilityFor(path);
        if (capability == null) {
            return new AuthorizationDecision(true);
        }

        String access = role.permissions().getOrDefault(capability, "NONE").toUpperCase();
        boolean read = "GET".equalsIgnoreCase(context.getRequest().getMethod())
                || "HEAD".equalsIgnoreCase(context.getRequest().getMethod())
                || "OPTIONS".equalsIgnoreCase(context.getRequest().getMethod());

        boolean allowed = "FULL".equals(access) || (read && "VIEW".equals(access));
        return new AuthorizationDecision(allowed);
    }

    /** Map a staff API path to the capability key stored on the role. */
    private String capabilityFor(String uri) {
        if (uri == null) return null;
        if (uri.startsWith("/admin/users")
                || uri.startsWith("/admin/roles")
                || uri.startsWith("/admin/permissions")) {
            return "users";
        }
        if (uri.startsWith("/admin/passengers")) return "passengers";
        if (uri.startsWith("/admin/drivers")) return "drivers";
        if (uri.startsWith("/admin/vehicles")) return "vehicles";
        if (uri.startsWith("/admin/rides")) return "rides";
        if (uri.startsWith("/admin/payments")) return "payments";
        if (uri.startsWith("/admin/settlements")) return "settlements";
        if (uri.startsWith("/admin/complaints")) return "complaints";
        if (uri.startsWith("/admin/safety")) return "safety";
        if (uri.startsWith("/admin/config")
                || uri.startsWith("/admin/settings")
                || uri.startsWith("/admin/audit")) {
            return "config";
        }
        // /admin/profile, /admin/dashboard, /internal/** and future shell
        // endpoints are staff-only but not capability-scoped.
        return null;
    }

    private String roleName(Authentication auth) {
        if (auth instanceof UserAuthenticationToken token) {
            return token.getUser() != null ? token.getUser().getRole() : null;
        }
        if (auth != null && auth.getAuthorities() != null) {
            return auth.getAuthorities().stream()
                    .map(a -> a.getAuthority().replaceFirst("^ROLE_", ""))
                    .filter(a -> !"PERMISSION_ALL".equals(a))
                    .findFirst().orElse(null);
        }
        return null;
    }
}
