package com.nimbus.admin.application.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * Update the current admin's own profile (PATCH /admin/profile).
 */
@Data
public class UpdateProfileRequest {

    @Size(max = 60, message = "First name too long")
    private String firstName;

    @Size(max = 60, message = "Last name too long")
    private String lastName;

    @Email(message = "Invalid email address")
    private String email;
}
