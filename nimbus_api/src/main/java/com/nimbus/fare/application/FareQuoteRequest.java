package com.nimbus.fare.application;

import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.UUID;

/**
 * Request to generate a fare quote for a booking.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class FareQuoteRequest {

    @NotNull(message = "Ride ID is required")
    private UUID rideId;

    private UUID bookingId;

    private Integer routeVersion;

    /**
     * Passenger pickup/drop-off as {@code [longitude, latitude]}, matching
     * the booking contract. When omitted, the backend falls back to the
     * ride's origin/destination for compatibility with older clients.
     */
    private Double[] pickupLocation;

    /** Passenger drop-off as {@code [longitude, latitude]}. */
    private Double[] dropoffLocation;

    /**
     * @deprecated Client-supplied distance/duration are ignored; the
     * backend derives both from the bound segment.
     */
    @Deprecated
    private Integer distanceMeters;

    /**
     * @deprecated Client-supplied distance/duration are ignored; the
     * backend derives both from the bound segment.
     */
    @Deprecated
    private Integer durationSeconds;

    private Integer seats;

    private String voucherCode;
}
