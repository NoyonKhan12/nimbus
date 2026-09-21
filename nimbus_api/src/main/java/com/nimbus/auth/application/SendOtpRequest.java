package com.nimbus.auth.application;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;

/**
 * Request to send OTP to a Bangladesh mobile number.
 * Format: +8801XXXXXXXXX
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class SendOtpRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+8801[3-9][0-9]{8}$", message = "Phone number must be in format +8801XXXXXXXXX")
    private String phone;

    @NotBlank(message = "Purpose is required")
    private String purpose;
}