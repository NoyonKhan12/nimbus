package com.nimbus.kernel.infrastructure.security;

import com.nimbus.kernel.domain.entity.User;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.*;

/**
 * Custom authentication token for Nimbus users.
 * Contains the user principal and their authorities.
 */
public class UserAuthenticationToken extends AbstractAuthenticationToken {

    private final User user;
    private final UUID userId;

    public UserAuthenticationToken(User user) {
        super(getAuthorities(user));
        this.user = user;
        this.userId = user.getId();
    }

    private static Collection<GrantedAuthority> getAuthorities(User user) {
        List<GrantedAuthority> authorities = new ArrayList<>();
        // Add role-based authority
        authorities.add(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()));

        // Add scope-based authorities for fine-grained access
        switch (user.getRole()) {
            case ADMIN:
                authorities.add(new SimpleGrantedAuthority("PERMISSION_ALL"));
                break;
            case DRIVER:
                authorities.add(new SimpleGrantedAuthority("PERMISSION_CREATE_RIDE"));
                authorities.add(new SimpleGrantedAuthority("PERMISSION_VIEW_WALLET"));
                break;
            case OPERATIONS:
                authorities.add(new SimpleGrantedAuthority("PERMISSION_MANAGE_RIDES"));
                break;
            case FINANCE:
                authorities.add(new SimpleGrantedAuthority("PERMISSION_MANAGE_SETTLEMENTS"));
                authorities.add(new SimpleGrantedAuthority("PERMISSION_VIEW_PAYMENTS"));
                break;
            case SUPPORT:
                authorities.add(new SimpleGrantedAuthority("PERMISSION_HANDLE_COMPLAINTS"));
                break;
            case SAFETY:
                authorities.add(new SimpleGrantedAuthority("PERMISSION_HANDLE_SOS"));
                break;
        }

        return authorities;
    }

    @Override
    public Object getCredentials() {
        return null; // No credentials needed for JWT
    }

    @Override
    public Object getPrincipal() {
        return user;
    }

    public User getUser() {
        return user;
    }

    public UUID getUserId() {
        return userId;
    }
}