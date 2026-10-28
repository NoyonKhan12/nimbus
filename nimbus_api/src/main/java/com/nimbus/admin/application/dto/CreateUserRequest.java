package com.nimbus.admin.application.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * Create a staff account (POST /admin/users).
 * Role must exist in the dynamic `roles` table and not be an app-only
 * role (PASSENGER/DRIVER) — validated in AdminUserService.createUser.
 */
@Data
public class CreateUserRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(
        regexp = "^\\+?[0-9]{10,15}$",
        message = "Phone must be 10-15 digits, optionally starting with +"
    )
    private String phone;

    @Email(message = "Email must be valid")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be at least 8 characters")
    private String password;

    @NotBlank(message = "Role is required")
    @Pattern(
        regexp = "^[A-Z][A-Z0-9_]{1,31}$",
        message = "Role name must be 2-32 characters: letters, digits and underscores, starting with a letter"
    )
    private String role;

    @Size(max = 50, message = "First name must be at most 50 characters")
    private String firstName;

    @Size(max = 50, message = "Last name must be at most 50 characters")
    private String lastName;
}
