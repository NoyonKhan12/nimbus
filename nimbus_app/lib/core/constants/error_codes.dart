/// Centralized error code mapping from the backend ErrorCode enum.
class ErrorCodes {
  static const invalidInput = 'INVALID_INPUT';
  static const unauthorized = 'UNAUTHORIZED';
  static const forbidden = 'FORBIDDEN';
  static const notFound = 'NOT_FOUND';
  static const conflict = 'CONFLICT';
  static const otpRateLimited = 'OTP_RATE_LIMITED';
  static const otpInvalid = 'OTP_INVALID';
  static const seatNotAvailable = 'SEAT_NOT_AVAILABLE';
  static const bookingConflict = 'BOOKING_CONFLICT';
  static const paymentFailed = 'PAYMENT_FAILED';
  static const fareQuoteExpired = 'FARE_QUOTE_EXPIRED';
  static const voucherInvalid = 'VOUCHER_INVALID';
  static const vehicleNotApproved = 'VEHICLE_NOT_APPROVED';
  static const driverNotEligible = 'DRIVER_NOT_ELIGIBLE';
  static const rideNotFound = 'RIDE_NOT_FOUND';
  static const bookingNotFound = 'BOOKING_NOT_FOUND';
  static const paymentNotFound = 'PAYMENT_NOT_FOUND';

  static String getMessage(String code) {
    return switch (code) {
      invalidInput => 'Invalid input provided',
      unauthorized => 'Please log in to continue',
      forbidden => 'You do not have access to this resource',
      notFound => 'Resource not found',
      conflict => 'Operation conflicts with current state',
      otpRateLimited => 'Too many OTP requests. Please try again later.',
      otpInvalid => 'Invalid or expired OTP code',
      seatNotAvailable => 'Selected seats are no longer available',
      bookingConflict => 'Booking conflict. Please refresh and try again.',
      paymentFailed => 'Payment processing failed',
      fareQuoteExpired => 'Fare quote has expired. Please request a new quote.',
      voucherInvalid => 'Voucher code is invalid or expired',
      vehicleNotApproved => 'Vehicle is not approved for operation',
      driverNotEligible => 'Driver is not eligible to accept rides',
      rideNotFound => 'Ride not found',
      bookingNotFound => 'Booking not found',
      paymentNotFound => 'Payment not found',
      _ => 'An unexpected error occurred',
    };
  }
}
