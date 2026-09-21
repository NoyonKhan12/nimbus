package com.nimbus.kernel.application.dto;

import lombok.*;

/**
 * Standard API response wrapper.
 *
 * @param <T> the type of the data field
 */
@Getter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
    @Builder.Default
    private boolean success = true;
    private T data;
    private String message;
    private String timestamp;

    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .data(data)
                .timestamp(java.time.Instant.now().toString())
                .build();
    }

    public static <T> ApiResponse<T> success(T data, String message) {
        return ApiResponse.<T>builder()
                .success(true)
                .data(data)
                .message(message)
                .timestamp(java.time.Instant.now().toString())
                .build();
    }

    public static <T> ApiResponse<T> error(String error) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(error)
                .timestamp(java.time.Instant.now().toString())
                .build();
    }
}
