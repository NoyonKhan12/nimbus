package com.nimbus.kernel.application.exception;

import lombok.*;

/**
 * Standard error response structure for all API errors.
 */
@Getter @Builder
@NoArgsConstructor
@AllArgsConstructor
public class ErrorResponse {
    @Builder.Default
    private boolean success = false;
    private ErrorBody error;
    private String timestamp;

    @Getter @Setter @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ErrorBody {
        private String code;
        private String message;
        private Object details;
        private String traceId;
    }
}