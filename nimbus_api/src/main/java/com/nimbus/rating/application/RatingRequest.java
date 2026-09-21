package com.nimbus.rating.application;

import jakarta.validation.constraints.*;
import lombok.*;

import java.util.UUID;

/**
 * Rating request DTO.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class RatingRequest {

    @NotNull(message = "Booking ID is required")
    private UUID bookingId;

    @NotNull(message = "Rated user ID is required")
    private UUID ratedId;

    @Min(value = 1, message = "Score must be between 1 and 5")
    @Max(value = 5, message = "Score must be between 1 and 5")
    private int score;

    @Size(max = 1000, message = "Comment too long")
    private String comment;
}
