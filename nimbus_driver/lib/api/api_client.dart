import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dto/auth_dtos.dart';
import '../dto/driver_dtos.dart';
import '../dto/ride_dtos.dart';
import '../dto/payment_dtos.dart';

part 'api_client.g.dart';

/// REST API client for Nimbus Driver backend.
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // ========== Auth ==========
  @POST('/auth/send-otp')
  Future<void> sendOtp(@Body() SendOtpRequest request);

  @POST('/auth/verify-otp')
  Future<AuthTokens> verifyOtp(@Body() VerifyOtpRequest request);

  @POST('/auth/refresh')
  Future<RefreshTokenResponse> refreshToken(@Body() Map<String, String> request);

  @POST('/auth/logout')
  Future<void> logout(@Body() Map<String, String> request);

  // ========== Driver ==========
  @GET('/drivers/profile')
  Future<DriverProfile> getDriverProfile();

  @GET('/drivers/eligibility')
  Future<DriverEligibility> getDriverEligibility();

  @GET('/drivers/documents')
  Future<List<DriverDocument>> getDocuments();

  @POST('/drivers/documents')
  Future<DriverDocument> addDocument(@Body() DriverDocumentRequest request);

  @GET('/drivers/earnings')
  Future<DriverEarnings> getEarnings();

  @GET('/drivers/settlements')
  Future<List<DriverSettlement>> getSettlements();

  @POST('/drivers/location')
  Future<void> updateDriverLocation(@Body() DriverLocationUpdate request);

  @GET('/drivers/status')
  Future<DriverStatusResponse> getDriverStatus();

  @POST('/drivers/status')
  Future<DriverStatusResponse> updateDriverStatus(@Body() UpdateDriverStatusRequest request);

  // ========== Ride ==========
  @GET('/rides/assigned')
  Future<List<Ride>> getAssignedRides(@Queries() Map<String, dynamic> params);

  @GET('/rides/{rideId}')
  Future<Ride> getRide(@Path('rideId') String rideId);

  @POST('/rides/{rideId}/start')
  Future<Ride> startRide(@Path('rideId') String rideId);

  @POST('/rides/{rideId}/route-lock')
  Future<Ride> lockRoute(@Path('rideId') String rideId);

  @POST('/rides/{rideId}/complete')
  Future<Ride> completeRide(@Path('rideId') String rideId);

  @GET('/rides/{rideId}/eta')
  Future<EtaResponse> getEta(@Path('rideId') String rideId);

  // ========== Booking ==========
  @POST('/rides/{rideId}/bookings/{bookingId}/pickup')
  Future<void> confirmPickup(
    @Path('rideId') String rideId,
    @Path('bookingId') String bookingId,
  );

  @POST('/rides/{rideId}/bookings/{bookingId}/dropoff')
  Future<void> confirmDropoff(
    @Path('rideId') String rideId,
    @Path('bookingId') String bookingId,
  );

  // ========== Payment ==========
  @GET('/payments/booking/{bookingId}')
  Future<Payment> getPaymentForBooking(@Path('bookingId') String bookingId);
}
