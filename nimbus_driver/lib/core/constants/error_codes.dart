/// Error code mapping from the backend.
class ErrorCodes {
  static const invalidInput = 'INVALID_INPUT';
  static const unauthorized = 'UNAUTHORIZED';
  static const forbidden = 'FORBIDDEN';
  static const notFound = 'NOT_FOUND';
  static const conflict = 'CONFLICT';
  static const seatNotAvailable = 'SEAT_NOT_AVAILABLE';
  static const paymentFailed = 'PAYMENT_FAILED';
  static const rideNotFound = 'RIDE_NOT_FOUND';
  static const driverNotEligible = 'DRIVER_NOT_ELIGIBLE';
  static const vehicleNotApproved = 'VEHICLE_NOT_APPROVED';

  static String getMessage(String code) {
    return switch (code) {
      invalidInput => 'Invalid input provided',
      unauthorized => 'Please log in to continue',
      forbidden => 'Access denied',
      notFound => 'Resource not found',
      conflict => 'Operation conflict',
      seatNotAvailable => 'Seats are no longer available',
      paymentFailed => 'Payment failed',
      rideNotFound => 'Ride not found',
      driverNotEligible => 'You are not eligible to accept this ride',
      vehicleNotApproved => 'Your vehicle is not approved',
      _ => 'An error occurred',
    };
  }
}
