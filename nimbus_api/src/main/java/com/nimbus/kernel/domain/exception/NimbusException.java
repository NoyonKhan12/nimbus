package com.nimbus.kernel.domain.exception;

import com.nimbus.kernel.domain.ErrorCode;
import org.springframework.http.HttpStatus;

/**
 * Base exception for all Nimbus business errors.
 */
public class NimbusException extends RuntimeException {
    private final ErrorCode errorCode;
    private final HttpStatus httpStatus;

    public NimbusException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
        this.httpStatus = HttpStatus.BAD_REQUEST;
    }

    public NimbusException(ErrorCode errorCode, HttpStatus httpStatus) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
        this.httpStatus = httpStatus;
    }

    public NimbusException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
        this.httpStatus = HttpStatus.BAD_REQUEST;
    }

    public NimbusException(ErrorCode errorCode, String message, HttpStatus httpStatus) {
        super(message);
        this.errorCode = errorCode;
        this.httpStatus = httpStatus;
    }

    public ErrorCode getErrorCode() { return errorCode; }
    public HttpStatus getHttpStatus() { return httpStatus; }
}