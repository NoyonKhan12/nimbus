import '../api/api_client.dart';
import '../dto/driver_dtos.dart';
import '../dto/ride_dtos.dart';
import '../dto/location_dto.dart';
import '../dto/payment_dtos.dart';

/// Service for driver-specific operations.
class DriverService {
  final ApiClient _apiClient;

  DriverService(this._apiClient);

  // ===== Driver Profile =====
  Future<DriverProfile> getProfile() => _apiClient.getDriverProfile();

  Future<DriverEligibility> getEligibility() => _apiClient.getDriverEligibility();

  Future<List<DriverDocument>> getDocuments() => _apiClient.getDocuments();

  Future<DriverDocument> addDocument(DriverDocumentRequest request) =>
      _apiClient.addDocument(request);

  Future<DriverEarnings> getEarnings() => _apiClient.getEarnings();

  Future<List<DriverSettlement>> getSettlements() =>
      _apiClient.getSettlements();

  Future<DriverStatusResponse> getStatus() => _apiClient.getDriverStatus();

  Future<DriverStatusResponse> updateStatus(UpdateDriverStatusRequest request) =>
      _apiClient.updateDriverStatus(request);

  // ===== Location =====
  Future<void> updateLocation({
    required String rideId,
    required LocationDto location,
    double? heading,
    double? speed,
  }) =>
      _apiClient.updateDriverLocation(DriverLocationUpdate(
        rideId: rideId,
        location: location,
        heading: heading,
        speed: speed,
      ));

  // ===== Rides =====
  Future<List<Ride>> getAssignedRides({
    int page = 0,
    int size = 20,
    String? status,
  }) =>
      _apiClient.getAssignedRides({
        'page': page,
        'size': size,
        if (status != null) 'status': status,
      });

  Future<Ride> getRide(String rideId) => _apiClient.getRide(rideId);

  Future<Ride> startRide(String rideId) => _apiClient.startRide(rideId);

  Future<Ride> lockRoute(String rideId) => _apiClient.lockRoute(rideId);

  Future<Ride> completeRide(String rideId) => _apiClient.completeRide(rideId);

  Future<EtaResponse> getEta(String rideId) => _apiClient.getEta(rideId);

  // ===== Bookings =====
  Future<void> confirmPickup(String rideId, String bookingId) =>
      _apiClient.confirmPickup(rideId, bookingId);

  Future<void> confirmDropoff(String rideId, String bookingId) =>
      _apiClient.confirmDropoff(rideId, bookingId);

  // ===== Payments =====
  Future<Payment> getPaymentForBooking(String bookingId) =>
      _apiClient.getPaymentForBooking(bookingId);
}
