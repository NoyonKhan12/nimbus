package com.nimbus.fare.application;

import lombok.*;

/**
 * Location DTO used in fare quotes and ride creation.
 */
@Getter @Setter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class LocationDTO {
    private Double latitude;
    private Double longitude;
    private String address;
}
