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
 * Bootstraps an initial admin user on application startup.
 * Only runs when no admin user exists yet.
 * Intended for local/dev environments where manual DB access is impractical.
 */
@Component
@Slf4j
public class AdminUserBootstrap implements CommandLineRunner {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;

    // Default admin credentials — change immediately after first login.
    private static final String ADMIN_EMAIL = "admin@nimbus.com";
    private static final String ADMIN_PASSWORD = "admin123";
    private static final String ADMIN_PHONE = "+8801923456789";

    // Argon2 parameters matching Spring Security's Argon2PasswordEncoder(16, 32, 4, 7680, 1)
    private static final int SALT_LENGTH = 16;
    private static final int HASH_LENGTH = 32;
    private static final int MEMORY = 7680;
    private static final int ITERATIONS = 1;
    private static final int PARALLELISM = 4;

    public AdminUserBootstrap(UserRepository userRepository,
                              UserProfileRepository userProfileRepository) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
    }

    @Override
    public void run(String... args) {
        // Check if admin user already exists
        if (userRepository.findByEmail(ADMIN_EMAIL).isPresent()) {
            log.debug("Admin user '{}' already exists, skipping bootstrap.", ADMIN_EMAIL);
            return;
        }

        // Generate Argon2id hash using argon2-jvm library (matching Spring Security parameters)
        Argon2 argon2 = Argon2Factory.create(
                Argon2Factory.Argon2Types.ARGON2id,
                SALT_LENGTH,
                HASH_LENGTH
        );
        String passwordHash = argon2.hash(ITERATIONS, MEMORY, PARALLELISM, ADMIN_PASSWORD.toCharArray());
        

        // Create admin user
        User admin = User.builder()
                .phone(ADMIN_PHONE)
                .email(ADMIN_EMAIL)
                .passwordHash(passwordHash)
                .status(User.UserStatus.ACTIVE)
                .role(User.UserRole.ADMIN)
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

        log.info("Bootstrap: created admin user '{}' with email '{}' and password '{}'",
                admin.getId(), ADMIN_EMAIL, ADMIN_PASSWORD);
    }
}