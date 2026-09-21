package com.nimbus.kernel.domain;

/**
 * Standardized error codes for API responses.
 * Codes remain stable while messages may change.
 */
public enum ErrorCode {

    // Auth
    AUTH_INVALID_OTP("Invalid OTP code provided"),
    AUTH_OTP_EXPIRED("OTP has expired"),
    AUTH_OTP_LIMIT_EXCEEDED("OTP request limit exceeded"),
    AUTH_OTP_ATTEMPTS_EXCEEDED("Too many failed OTP attempts"),
    AUTH_TOKEN_EXPIRED("Access token has expired"),
    AUTH_TOKEN_INVALID("Invalid access token"),
    AUTH_REFRESH_TOKEN_INVALID("Invalid refresh token"),
    AUTH_UNAUTHORIZED("Authentication required"),
    AUTH_ACCOUNT_SUSPENDED("Account is suspended"),
    AUTH_ACCOUNT_BANNED("Account is banned"),
    AUTH_PHONE_NOT_VERIFIED("Phone number is not verified"),

    // User
    USER_NOT_FOUND("User not found"),
    USER_INVALID_INPUT("Invalid user input"),

    // Driver
    DRIVER_NOT_FOUND("Driver not found"),
    DRIVER_NOT_ELIGIBLE("Driver is not eligible"),
    DRIVER_NOT_APPROVED("Driver is not approved"),
    DRIVER_DOCUMENT_EXPIRED("Required document has expired"),
    DRIVER_DUE_PENDING("Please settle outstanding amount"),

    // Vehicle
    VEHICLE_NOT_FOUND("Vehicle not found"),
    VEHICLE_NOT_ELIGIBLE("Vehicle is not eligible"),

    // Ride
    RIDE_NOT_FOUND("Ride not found"),
    RIDE_NOT_BOOKABLE("Ride is not available for booking"),
    RIDE_NO_SEATS("No seats are available for this ride"),
    RIDE_ALREADY_STARTED("Ride has already started"),
    RIDE_CANNOT_CANCEL("Cannot cancel ride in current state"),
    RIDE_INVALID_STATE_TRANSITION("Invalid ride state transition"),

    // Booking
    BOOKING_NOT_FOUND("Booking not found"),
    BOOKING_ALREADY_CONFIRMED("Booking is already confirmed"),
    BOOKING_EXPIRED("Booking has expired"),
    BOOKING_SEAT_UNAVAILABLE("Requested seats are not available"),

    // Payment
    PAYMENT_FAILED("Payment processing failed"),
    PAYMENT_ALREADY_PROCESSED("Payment already processed"),
    PAYMENT_IDEMPOTENCY_KEY_MISMATCH("Idempotency key mismatch"),

    // Fare
    FARE_QUOTE_EXPIRED("Fare quote has expired"),

    // Voucher
    VOUCHER_NOT_FOUND("Voucher not found"),
    VOUCHER_NOT_ACTIVE("Voucher is not active"),
    VOUCHER_EXPIRED("Voucher has expired"),
    VOUCHER_USAGE_LIMIT_EXCEEDED("Voucher usage limit exceeded"),
    VOUCHER_USER_LIMIT_REACHED("User has reached the usage limit for this voucher"),

    // Wallet
    WALLET_INSUFFICIENT_BALANCE("Insufficient wallet balance"),

    // General
    BAD_REQUEST("Invalid request parameters"),
    NOT_FOUND("Resource not found"),
    FORBIDDEN("Access denied"),
    RATE_LIMITED("Too many requests"),
    INTERNAL_ERROR("Internal error occurred"),
    SERVICE_UNAVAILABLE("Service unavailable"),
    VALIDATION_ERROR("Request validation failed"),
    CONFLICT("Resource conflict"),
    NOT_IMPLEMENTED("Not yet implemented");

    private final String message;

    ErrorCode(String message) { this.message = message; }
    public String getMessage() { return message; }
}
