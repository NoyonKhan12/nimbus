package com.nimbus.kernel.infrastructure.bootstrap;

import com.nimbus.kernel.domain.entity.User;
import com.nimbus.kernel.domain.entity.UserProfile;
import com.nimbus.kernel.domain.repository.UserRepository;
import com.nimbus.kernel.domain.repository.UserProfileRepository;
import de.mkammerer.argon2.Argon2Factory;
import de.mkammerer.argon2.Argon2;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.Instant;

/**
 * Bootstraps an initial admin user when explicitly enabled.
 *
 * <p>Production deployments must create the first administrator through a
 * controlled database/secret-manager process. The old hard-coded
 * {@code admin@nimbus.com / admin123} seed is gone: enabling this runner
 * now requires {@code ADMIN_BOOTSTRAP_ENABLED=true} and a non-empty
 * {@code ADMIN_PASSWORD}.</p>
 */
@Component
@Slf4j
public class AdminUserBootstrap implements CommandLineRunner {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final boolean enabled;
    private final String adminEmail;
    private final String adminPassword;
    private final String adminPhone;

    // Argon2 parameters matching Spring Security's Argon2PasswordEncoder(16, 32, 4, 7680, 1)
    private static final int SALT_LENGTH = 16;
    private static final int HASH_LENGTH = 32;
    private static final int MEMORY = 7680;
    private static final int ITERATIONS = 1;
    private static final int PARALLELISM = 4;

    public AdminUserBootstrap(
            UserRepository userRepository,
            UserProfileRepository userProfileRepository,
            @org.springframework.beans.factory.annotation.Value(
                    "${app.bootstrap.admin.enabled:false}") boolean enabled,
            @org.springframework.beans.factory.annotation.Value(
                    "${app.bootstrap.admin.email:admin@nimbus.com}") String adminEmail,
            @org.springframework.beans.factory.annotation.Value(
                    "${app.bootstrap.admin.password:}") String adminPassword,
            @org.springframework.beans.factory.annotation.Value(
                    "${app.bootstrap.admin.phone:+8801923456789}") String adminPhone) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.enabled = enabled;
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
        this.adminPhone = adminPhone;
    }

    @Override
    public void run(String... args) {
        if (!enabled) {
            log.debug("Admin bootstrap disabled (set ADMIN_BOOTSTRAP_ENABLED=true for local/dev).");
            return;
        }
        if (adminPassword == null || adminPassword.isBlank()) {
            log.warn("Admin bootstrap skipped: ADMIN_PASSWORD is empty.");
            return;
        }
        // Check if admin user already exists
        if (userRepository.findByEmail(adminEmail).isPresent()) {
            log.debug("Admin user '{}' already exists, skipping bootstrap.", adminEmail);
            return;
        }

        // Generate Argon2id hash using argon2-jvm library (matching Spring Security parameters)
        Argon2 argon2 = Argon2Factory.create(
                Argon2Factory.Argon2Types.ARGON2id,
                SALT_LENGTH,
                HASH_LENGTH
        );
        String passwordHash = argon2.hash(ITERATIONS, MEMORY, PARALLELISM, adminPassword.toCharArray());
        

        // Create admin user
        User admin = User.builder()
                .phone(adminPhone)
                .email(adminEmail)
                .passwordHash(passwordHash)
                .status(User.UserStatus.ACTIVE)
                .role("ADMIN")
                .phoneVerified(true)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        admin = userRepository.save(admin);

        // Create admin profile
        UserProfile profile = UserProfile.builder()
                .user(admin)
                .firstName("Admin")
                .lastName("User")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        userProfileRepository.save(profile);

        log.info("Bootstrap: created admin user '{}' with email '{}'. "
                        + "Change the password after first login.",
                admin.getId(), adminEmail);
    }
}