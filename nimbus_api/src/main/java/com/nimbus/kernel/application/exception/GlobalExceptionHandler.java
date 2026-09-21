package com.nimbus.kernel.application.exception;

import com.nimbus.kernel.domain.ErrorCode;
import com.nimbus.kernel.domain.exception.NimbusException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Global exception handler for standardized API error responses.
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(NimbusException.class)
    public ResponseEntity<ErrorResponse> handleNimbusException(NimbusException ex) {
        return buildErrorResponse(ex.getErrorCode(), ex.getMessage(), ex.getHttpStatus());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult().getFieldErrors()
                .stream()
                .map(f -> f.getField() + ": " + f.getDefaultMessage())
                .collect(Collectors.toList());

        return buildErrorResponse(
                ErrorCode.VALIDATION_ERROR,
                "Validation failed: " + String.join(", ", errors),
                HttpStatus.BAD_REQUEST
        );
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ErrorResponse> handleAuthException(AuthenticationException ex) {
        return buildErrorResponse(ErrorCode.AUTH_UNAUTHORIZED, "Authentication failed", HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDenied(AccessDeniedException ex) {
        return buildErrorResponse(ErrorCode.FORBIDDEN, "Access denied", HttpStatus.FORBIDDEN);
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ErrorResponse> handleBadCredentials(BadCredentialsException ex) {
        return buildErrorResponse(ErrorCode.AUTH_UNAUTHORIZED, "Invalid credentials", HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneralException(Exception ex) {
        log.error("Unhandled exception in controller", ex);
        return buildErrorResponse(
                ErrorCode.INTERNAL_ERROR,
                "An unexpected error occurred",
                HttpStatus.INTERNAL_SERVER_ERROR
        );
    }

    private ResponseEntity<ErrorResponse> buildErrorResponse(ErrorCode code, String message, HttpStatus status) {
        ErrorResponse response = ErrorResponse.builder()
                .success(false)
                .error(ErrorResponse.ErrorBody.builder()
                        .code(code.name())
                        .message(message)
                        .traceId(UUID.randomUUID().toString())
                        .build())
                .timestamp(Instant.now().toString())
                .build();
        return new ResponseEntity<>(response, status);
    }
}