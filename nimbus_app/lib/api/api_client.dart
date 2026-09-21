import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dto/auth_dtos.dart';
import '../dto/user_dtos.dart';
import '../dto/create_ride_dto.dart';
import '../dto/fare_quote_dto.dart';
import '../dto/location_dto.dart';
import '../dto/error_response_dto.dart';
import '../dto/ride_booking_dtos.dart';
import '../dto/driver_dtos.dart';
import '../dto/payment_dto.dart';
import '../dto/wallet_dto.dart';
import '../dto/voucher_dto.dart';
import '../dto/rating_dto.dart';
import '../dto/complaint_dto.dart';
import '../dto/safety_dto.dart';
import '../dto/notification_dto.dart';
import '../dto/paged_response_dto.dart';

part 'api_client.g.dart';

/// REST API client for Nimbus backend.
/// Generated via retrofit_generator from the interface below.
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // ========== Auth ==========

  @POST('/auth/send-otp')
  Future<void> sendOtp(@Body() SendOtpRequest request);

  @POST('/auth/verify-otp')
  Future<AuthTokens> verifyOtp(@Body() VerifyOtpRequest request);

  @POST('/auth/refresh')
  Future<RefreshTokenResponse> refreshToken(
    @Body() Map<String, String> request,
  );

  @POST('/auth/logout')
  Future<void> logout(@Body() Map<String, String> request);

  @GET('/auth/sessions')
  Future<List<UserSession>> getSessions();

  @DELETE('/auth/sessions/{sessionId}')
  Future<void> revokeSession(@Path('sessionId') String sessionId);

  // ========== User ==========

  @GET('/me')
  Future<UserProfile> getCurrentUser();

  @PUT('/me')
  Future<UserProfile> updateProfile(@Body() UpdateUserProfileRequest request);

  @POST('/me/photo')
  @MultiPart()
  Future<UserProfile> uploadPhoto(@Part(name: "file") String filePath);

  @GET('/me/history')
  Future<List<RideHistoryItem>> getHistory();

  // ========== Driver ==========

  @POST('/drivers/apply')
  Future<DriverApplication> applyAsDriver(@Body() DriverApplicationRequest request);

  @GET('/drivers/profile')
  Future<DriverProfile> getDriverProfile();

  @GET('/drivers/eligibility')
  Future<DriverEligibility> getEligibility();

  @GET('/drivers/documents')
  Future<List<DriverDocument>> getDocuments();

  @POST('/drivers/documents')
  Future<DriverDocument> addDocument(@Body() DriverDocumentRequest request);

  @GET('/drivers/earnings')
  Future<DriverEarnings> getEarnings();

  @GET('/drivers/settlements')
  Future<List<Settlement>> getSettlements();

  @POST('/drivers/settlements')
  Future<Settlement> settlementAction(@Body() SettlementActionRequest request);

  @POST('/drivers/location')
  Future<void> updateDriverLocation(@Body() DriverLocationUpdate request);

  // ========== Vehicle ==========

  @GET('/vehicles')
  Future<List<Vehicle>> getVehicles();

  @POST('/vehicles')
  Future<Vehicle> createVehicle(@Body() CreateVehicleRequest request);

  @GET('/vehicles/{vehicleId}')
  Future<Vehicle> getVehicle(@Path('vehicleId') String vehicleId);

  @PUT('/vehicles/{vehicleId}')
  Future<Vehicle> updateVehicle(
    @Path('vehicleId') String vehicleId,
    @Body() UpdateVehicleRequest request,
  );

  // ========== Ride ==========

  @GET('/rides')
  Future<List<Ride>> listRides();

  @POST('/rides')
  Future<Ride> createRide(@Body() CreateRideRequest request);

  @GET('/rides/search')
  Future<List<Ride>> searchRides(@Queries() Map<String, dynamic> params);

  @GET('/rides/{rideId}')
  Future<Ride> getRide(@Path('rideId') String rideId);

  @PUT('/rides/{rideId}')
  Future<Ride> updateRide(
    @Path('rideId') String rideId,
    @Body() UpdateRideRequest request,
  );

  @POST('/rides/{rideId}/publish')
  Future<Ride> publishRide(@Path('rideId') String rideId);

  @POST('/rides/{rideId}/cancel')
  Future<Ride> cancelRide(
    @Path('rideId') String rideId,
    @Body() CancelRideRequest request,
  );

  @POST('/rides/{rideId}/start')
  Future<Ride> startRide(@Path('rideId') String rideId);

  @POST('/rides/{rideId}/route-lock')
  Future<Ride> lockRoute(@Path('rideId') String rideId);

  @POST('/rides/{rideId}/complete')
  Future<Ride> completeRide(@Path('rideId') String rideId);

  @GET('/rides/{rideId}/eta')
  Future<EtaResponse> getEta(@Path('rideId') String rideId);

  // ========== Booking ==========

  @POST('/rides/{rideId}/bookings')
  Future<Booking> createBooking(
    @Path('rideId') String rideId,
    @Body() CreateBookingRequest request,
  );

  @GET('/bookings/{bookingId}')
  Future<Booking> getBooking(@Path('bookingId') String bookingId);

  @POST('/bookings/{bookingId}/cancel')
  Future<Booking> cancelBooking(
    @Path('bookingId') String bookingId,
    @Body() CancelBookingRequest request,
  );

  @POST('/bookings/{bookingId}/pickup')
  Future<Booking> pickupBooking(@Path('bookingId') String bookingId);

  @POST('/bookings/{bookingId}/dropoff')
  Future<Booking> dropoffBooking(@Path('bookingId') String bookingId);

  // ========== Fare ==========

  @POST('/fare/quote')
  Future<FareQuoteDto> getFareQuote(@Body() FareQuoteRequest request);

  // ========== Payment ==========

  @POST('/payments')
  Future<Payment> createPayment(@Body() PaymentRequest request);

  @GET('/payments/{paymentId}')
  Future<Payment> getPaymentStatus(@Path('paymentId') String paymentId);

  // ========== Wallet ==========

  @GET('/wallet')
  Future<Wallet> getWallet();

  @GET('/wallet/transactions')
  Future<PagedResponse<WalletTransaction>> getWalletTransactions(
    @Queries() Map<String, dynamic> params,
  );

  // ========== Voucher ==========

  @POST('/vouchers/validate')
  Future<VoucherValidation> validateVoucher(@Body() VoucherValidateRequest request);

  // ========== Rating ==========

  @POST('/ratings')
  Future<Rating> createRating(@Body() CreateRatingRequest request);

  // ========== Complaint ==========

  @POST('/complaints')
  Future<Complaint> createComplaint(@Body() CreateComplaintRequest request);

  @GET('/complaints/{complaintId}')
  Future<Complaint> getComplaint(@Path('complaintId') String complaintId);

  // ========== Safety ==========

  @POST('/safety/sos')
  Future<SafetyEvent> triggerSos(@Body() SosRequest request);

  @POST('/safety/trip-share')
  Future<TripShareResponse> startTripShare(@Body() TripShareRequest request);

  @GET('/safety/events/{eventId}')
  Future<SafetyEvent> getSafetyEvent(@Path('eventId') String eventId);

  // ========== Notifications ==========

  @GET('/notifications')
  Future<PagedResponse<Notification>> getNotifications(
    @Queries() Map<String, dynamic> params,
  );

  @POST('/notifications/{notificationId}/read')
  Future<void> markNotificationRead(@Path('notificationId') String notificationId);
}
