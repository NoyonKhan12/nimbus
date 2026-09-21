package com.nimbus.user.application;

import lombok.*;

/**
 * Response DTO for saved location.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SavedLocationResponse {
    private String id;
    private String label;
    private String address;
    private double latitude;
    private double longitude;
}