import 'dart:io';

import 'package:dio/dio.dart';

import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Driver profile, onboarding, vehicles and documents.
class DriverService {
  final BackendApi _api;

  DriverService(this._api);

  /// Applies as a driver — license details plus the first vehicle
  /// (backend `DriverApplicationRequest` bundles both).
  Future<DriverProfile> apply({
    required String licenseNumber,
    DateTime? licenseExpiry,
    required String vehicleRegistrationNumber,
    required String vehicleType,
    required String vehicleModel,
    int? vehicleYear,
    String? vehicleColor,
    required int seatCapacity,
  }) async {
    final body = await _api.post('/drivers/apply', body: {
      'licenseNumber': licenseNumber,
      if (licenseExpiry != null)
        'licenseExpiry': licenseExpiry.toUtc().toIso8601String(),
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      if (vehicleYear != null) 'vehicleYear': vehicleYear,
      if (vehicleColor != null && vehicleColor.isNotEmpty)
        'vehicleColor': vehicleColor,
      'seatCapacity': seatCapacity,
    });
    return DriverProfile.fromJson(body.dataMap);
  }

  /// Fetches the driver profile. Returns null when the user has not
  /// applied yet (backend 404s).
  Future<DriverProfile?> getProfile() async {
    try {
      final body = await _api.get('/drivers/profile');
      return DriverProfile.fromJson(body.dataMap);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Whether the driver may create/publish rides.
  Future<bool> isEligible() async {
    final body = await _api.get('/drivers/eligibility');
    return body.data == true;
  }

  Future<List<Vehicle>> getVehicles() async {
    final body = await _api.get('/drivers/vehicles');
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(Vehicle.fromJson)
        .toList();
  }

  Future<List<DriverDocument>> getDocuments() async {
    final body = await _api.get('/drivers/documents');
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(DriverDocument.fromJson)
        .toList();
  }

  /// Uploads a document image/PDF from the device with its metadata.
  ///
  /// The backend validates the file signature and size, stores it outside
  /// the web root, and returns an ownership-checked download URL.
  Future<DriverDocument> uploadDocument({
    required String filePath,
    required String documentType,
    required String documentNumber,
    DateTime? expiresAt,
    void Function(int sent, int total)? onProgress,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const ApiException(
        code: 'FILE_NOT_FOUND',
        message: 'The selected file is no longer available.',
      );
    }
    final form = FormData.fromMap({
      'type': documentType,
      'documentNumber': documentNumber,
      if (expiresAt != null)
        'expiresAt': expiresAt.toUtc().toIso8601String(),
      'file': await MultipartFile.fromFile(
        filePath,
        filename: file.uri.pathSegments.last,
      ),
    });
    final body = await _api.postMultipart(
      '/drivers/documents/upload',
      formData: form,
      onSendProgress: onProgress,
    );
    return DriverDocument.fromJson(body.dataMap);
  }

  /// Registers document metadata without a file (legacy clients).
  Future<DriverDocument> addDocument({
    required String documentType,
    required String documentNumber,
    String? documentUrl,
    DateTime? expiresAt,
  }) async {
    final body = await _api.post('/drivers/documents', query: {
      'type': documentType,
      'documentNumber': documentNumber,
      if (documentUrl != null && documentUrl.isNotEmpty)
        'documentUrl': documentUrl,
      if (expiresAt != null) 'expiresAt': expiresAt.toUtc().toIso8601String(),
    });
    return DriverDocument.fromJson(body.dataMap);
  }
}
