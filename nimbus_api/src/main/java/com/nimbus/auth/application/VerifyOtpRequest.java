package com.nimbus.auth.application;

import jakarta.validation.constraints.*;
import lombok.*;

/**
 * Request to verify OTP for authentication.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class VerifyOtpRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+8801[3-9][0-9]{8}$", message = "Phone number must be in format +8801XXXXXXXXX")
    private String phone;

    @NotBlank(message = "OTP code is required")
    @Pattern(regexp = "\\d{4,8}", message = "OTP code must be 4-8 digits")
    private String otp;

    private String deviceId;
    private String platform;
    private String pushToken;
}