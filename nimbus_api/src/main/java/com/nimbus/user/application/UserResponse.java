package com.nimbus.user.application;

import com.nimbus.kernel.domain.entity.User;
import lombok.*;

/**
 * User response DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private String id;
    private String phone;
    private String email;
    private User.UserStatus status;
    private User.UserRole role;
    private boolean phoneVerified;
    private UserProfileResponse profile;

    @Getter @Setter @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserProfileResponse {
        private String firstName;
        private String lastName;
        private String profilePhotoUrl;
        private String emergencyContactName;
        private String emergencyContactPhone;
    }
}