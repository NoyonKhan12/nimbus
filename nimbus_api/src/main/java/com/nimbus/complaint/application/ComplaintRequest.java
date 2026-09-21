package com.nimbus.complaint.application;

import jakarta.validation.constraints.*;
import lombok.*;

import java.util.UUID;

/**
 * Complaint request DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class ComplaintRequest {

    private UUID bookingId;

    @NotBlank(message = "Category is required")
    private String category;

    @NotBlank(message = "Description is required")
    @Size(max = 2000, message = "Description too long")
    private String description;
}
