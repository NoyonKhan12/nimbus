/// Hand-written mappers from the backend's JSON contract (flat fields,
/// UPPER_SNAKE enums, `ApiResponse` envelope already unwrapped by
/// [BackendApi]) to the driver app's model classes.
library;

import '../dto/location_dto.dart';

// ---------------------------------------------------------------------------
// Primitives
// ---------------------------------------------------------------------------

double toDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int toInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

DateTime? toDateOrNull(dynamic value) {
  if (value is String) return DateTime.tryParse(value)?.toUtc();
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  return null;
}

DateTime toDate(dynamic value) => toDateOrNull(value) ?? DateTime.now().toUtc();

/// Human-readable label for a backend `UPPER_SNAKE` status.
String statusLabel(dynamic value) {
  final raw = value?.toString() ?? '';
  if (raw.isEmpty) return '';
  return raw
      .split('_')
      .map((w) =>
          w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}

// ---------------------------------------------------------------------------
// Rides (driver view — flat RideResponse)
// ---------------------------------------------------------------------------

enum RideType { instant, scheduled, recurring }

enum RideStatus {
  draft,
  published,
  routeLocked,
  driverArriving,
  inProgress,
  interrupted,
  completed,
  cancelled;

  bool get isLive =>
      this == RideStatus.routeLocked ||
      this == RideStatus.driverArriving ||
      this == RideStatus.inProgress;
}

RideType parseRideType(dynamic value) {
  switch (_snakeToCamel(value?.toString() ?? '')) {
    case 'instant':
      return RideType.instant;
    case 'recurring':
      return RideType.recurring;
    default:
      return RideType.scheduled;
  }
}

RideStatus parseRideStatus(dynamic value) {
  switch (_snakeToCamel(value?.toString() ?? '')) {
    case 'draft':
      return RideStatus.draft;
    case 'published':
      return RideStatus.published;
    case 'routeLocked':
      return RideStatus.routeLocked;
    case 'driverArriving':
      return RideStatus.driverArriving;
    case 'inProgress':
      return RideStatus.inProgress;
    case 'interrupted':
      return RideStatus.interrupted;
    case 'completed':
      return RideStatus.completed;
    case 'cancelled':
      return RideStatus.cancelled;
    default:
      return RideStatus.draft;
  }
}

String _snakeToCamel(String value) {
  final lower = value.toLowerCase();
  final sb = StringBuffer();
  for (var i = 0; i < lower.length; i++) {
    final ch = lower[i];
    if (ch == '_' && i + 1 < lower.length) {
      sb.write(lower[++i].toUpperCase());
    } else {
      sb.write(ch);
    }
  }
  return sb.toString();
}

class Ride {
  final String id;
  final String? driverId;
  final String? creatorId;
  final String? vehicleId;
  final RideType type;
  final RideStatus status;
  final DateTime? scheduledAt;
  final LocationDto origin;
  final LocationDto destination;
  final int availableSeats;
  final String? notes;

  const Ride({
    required this.id,
    this.driverId,
    this.creatorId,
    this.vehicleId,
    required this.type,
    required this.status,
    this.scheduledAt,
    required this.origin,
    required this.destination,
    required this.availableSeats,
    this.notes,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id']?.toString() ?? '',
      driverId: json['driverId']?.toString(),
      creatorId: json['creatorId']?.toString(),
      vehicleId: json['vehicleId']?.toString(),
      type: parseRideType(json['type'] ?? json['rideType']),
      status: parseRideStatus(json['status']),
      scheduledAt: toDateOrNull(json['scheduledAt']),
      origin: LocationDto(
        latitude: toDouble(json['originLatitude']),
        longitude: toDouble(json['originLongitude']),
        address: json['originAddress']?.toString(),
      ),
      destination: LocationDto(
        latitude: toDouble(json['destinationLatitude']),
        longitude: toDouble(json['destinationLongitude']),
        address: json['destinationAddress']?.toString(),
      ),
      availableSeats: toInt(json['availableSeats']),
      notes: json['notes']?.toString(),
    );
  }
}

// ---------------------------------------------------------------------------
// Bookings (passengers on a driver's ride)
// ---------------------------------------------------------------------------

enum BookingStatus {
  held,
  confirmed,
  pickedUp,
  completed,
  cancelled,
  expired,
  refundPending,
  refunded;

  static BookingStatus parse(dynamic value) {
    switch (_snakeToCamel(value?.toString() ?? '')) {
      case 'held':
        return BookingStatus.held;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pickedUp':
        return BookingStatus.pickedUp;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'expired':
        return BookingStatus.expired;
      case 'refundPending':
        return BookingStatus.refundPending;
      case 'refunded':
        return BookingStatus.refunded;
      default:
        return BookingStatus.held;
    }
  }
}

class PassengerBooking {
  final String id;
  final String rideId;
  final String passengerId;
  final int seats;
  final BookingStatus status;
  final LocationDto pickup;
  final LocationDto dropoff;

  const PassengerBooking({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.seats,
    required this.status,
    required this.pickup,
    required this.dropoff,
  });

  factory PassengerBooking.fromJson(Map<String, dynamic> json) {
    return PassengerBooking(
      id: json['id']?.toString() ?? '',
      rideId: json['rideId']?.toString() ?? '',
      passengerId: json['passengerId']?.toString() ?? '',
      seats: toInt(json['seats'], 1),
      status: BookingStatus.parse(json['status']),
      pickup: LocationDto(
        latitude: toDouble(json['pickupLatitude']),
        longitude: toDouble(json['pickupLongitude']),
        address: json['pickupAddress']?.toString(),
      ),
      dropoff: LocationDto(
        latitude: toDouble(json['dropoffLatitude']),
        longitude: toDouble(json['dropoffLongitude']),
        address: json['dropoffAddress']?.toString(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Driver profile, vehicles, documents
// ---------------------------------------------------------------------------

class DriverProfile {
  final String id;
  final String userId;
  final String driverStatus; // ONLINE / OFFLINE
  final String approvalStatus; // PENDING / APPROVED / REJECTED / SUSPENDED
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final double rating;
  final double reliabilityScore;
  final int totalRides;
  final double totalEarnings;
  final double commissionRate;

  bool get isApproved => approvalStatus == 'APPROVED';
  bool get isOnline => driverStatus == 'ONLINE';

  const DriverProfile({
    required this.id,
    required this.userId,
    required this.driverStatus,
    required this.approvalStatus,
    this.licenseNumber,
    this.licenseExpiry,
    required this.rating,
    required this.reliabilityScore,
    required this.totalRides,
    required this.totalEarnings,
    required this.commissionRate,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      driverStatus: json['driverStatus']?.toString() ?? 'OFFLINE',
      approvalStatus: json['approvalStatus']?.toString() ?? 'PENDING',
      licenseNumber: json['licenseNumber']?.toString(),
      licenseExpiry: toDateOrNull(json['licenseExpiry']),
      rating: toDouble(json['rating']),
      reliabilityScore: toDouble(json['reliabilityScore']),
      totalRides: toInt(json['totalRides']),
      totalEarnings: toDouble(json['totalEarnings']),
      commissionRate: toDouble(json['commissionRate']),
    );
  }
}

class Vehicle {
  final String id;
  final String registrationNumber;
  final String type;
  final String? model;
  final int? year;
  final String? color;
  final int seatCapacity;
  final String status;

  const Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.type,
    this.model,
    this.year,
    this.color,
    required this.seatCapacity,
    required this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      registrationNumber: json['registrationNumber']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      model: json['model']?.toString(),
      year: json['year'] is int ? json['year'] as int : toInt(json['year']),
      color: json['color']?.toString(),
      seatCapacity: toInt(json['seatCapacity'], 4),
      status: json['status']?.toString() ?? 'PENDING',
    );
  }
}

class DriverDocument {
  final String id;
  final String documentType;
  final String? documentNumber;
  final String? documentUrl;
  final String? status;
  final bool verified;
  final DateTime? expiresAt;

  const DriverDocument({
    required this.id,
    required this.documentType,
    this.documentNumber,
    this.documentUrl,
    this.status,
    this.verified = false,
    this.expiresAt,
  });

  factory DriverDocument.fromJson(Map<String, dynamic> json) {
    return DriverDocument(
      id: json['id']?.toString() ?? '',
      documentType: json['documentType']?.toString() ??
          json['type']?.toString() ??
          'DOCUMENT',
      documentNumber: json['documentNumber']?.toString() ??
          json['number']?.toString(),
      documentUrl: json['documentUrl']?.toString() ?? json['url']?.toString(),
      status: json['status']?.toString(),
      verified: json['verified'] == true,
      expiresAt: toDateOrNull(json['expiresAt'] ?? json['expiryDate']),
    );
  }
}

// ---------------------------------------------------------------------------
// User (GET /me) & wallet
// ---------------------------------------------------------------------------

class DriverUser {
  final String id;
  final String? phone;
  final String? email;
  final String? name;

  const DriverUser({
    required this.id,
    this.phone,
    this.email,
    this.name,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final first = profile['firstName']?.toString() ?? '';
    final last = profile['lastName']?.toString() ?? '';
    final name = [first, last].where((p) => p.isNotEmpty).join(' ');
    return DriverUser(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      name: name.isEmpty ? null : name,
    );
  }
}

class WalletInfo {
  final double balance;
  final String currency;

  const WalletInfo({required this.balance, required this.currency});

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      balance: toDouble(json['balance']),
      currency: json['currency']?.toString() ?? 'BDT',
    );
  }
}

class WalletTx {
  final String id;
  final double amount;
  final String type;
  final String? description;
  final DateTime? createdAt;

  const WalletTx({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    this.createdAt,
  });

  factory WalletTx.fromJson(Map<String, dynamic> json) {
    return WalletTx(
      id: json['id']?.toString() ?? '',
      amount: toDouble(json['amount']),
      type: json['type']?.toString() ?? 'UNKNOWN',
      description: json['description']?.toString(),
      createdAt: toDateOrNull(json['createdAt']),
    );
  }
}

LocationDto locationOf(dynamic lat, dynamic lng, [dynamic address]) {
  return LocationDto(
    latitude: toDouble(lat),
    longitude: toDouble(lng),
    address: address?.toString(),
  );
}
