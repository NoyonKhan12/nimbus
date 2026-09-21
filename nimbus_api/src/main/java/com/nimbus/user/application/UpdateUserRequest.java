package com.nimbus.user.application;

import jakarta.validation.constraints.*;
import lombok.*;

/**
 * Request to update user profile information.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserRequest {

    @Size(min = 1, max = 100, message = "First name must be 1-100 characters")
    private String firstName;

    @Size(min = 1, max = 100, message = "Last name must be 1-100 characters")
    private String lastName;

    @Email(message = "Invalid email format")
    private String email;

    @Size(max = 200, message = "Emergency contact name too long")
    private String emergencyContactName;

    @Pattern(regexp = "^\\+8801[3-9][0-9]{8}$", message = "Invalid phone format")
    private String emergencyContactPhone;
}