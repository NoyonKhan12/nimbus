/// Hand-written mappers from the backend's JSON contract (flat fields,
/// UPPER_SNAKE enums, `ApiResponse` envelope already unwrapped by
/// [BackendApi]) to the app's generated DTOs.
///
/// The DTO classes themselves come from build_runner output; only this
/// parsing layer is maintained by hand.
library;

import '../dto/complaint_dto.dart';
import '../dto/fare_quote_dto.dart';
import '../dto/location_dto.dart';
import '../dto/notification_dto.dart';
import '../dto/ride_booking_dtos.dart';
import '../dto/safety_dto.dart';
import '../dto/user_dtos.dart';
import '../dto/wallet_dto.dart';

// ---------------------------------------------------------------------------
// Primitives
// ---------------------------------------------------------------------------

/// Parses a money value that may arrive as a JSON number (Jackson double)
/// or as a string (BigDecimal raw value).
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

/// Parses timestamps sent as ISO-8601 instants (`2026-10-05T10:00:00Z`)
/// or epoch milliseconds.
DateTime? toDateOrNull(dynamic value) {
  if (value is String) return DateTime.tryParse(value)?.toUtc();
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  return null;
}

DateTime toDate(dynamic value) => toDateOrNull(value) ?? DateTime.now().toUtc();

/// `ROUTE_LOCKED` → `RideStatus.routeLocked`.
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

// ---------------------------------------------------------------------------
// Enum parsing (backend UPPER_SNAKE → client camelCase)
// ---------------------------------------------------------------------------

RideType parseRideType(dynamic value) {
  switch (_snakeToCamel(value?.toString() ?? '')) {
    case 'instant':
      return RideType.instant;
    case 'recurring':
      return RideType.recurring;
    case 'scheduled':
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

BookingStatus parseBookingStatus(dynamic value) {
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
// Locations
// ---------------------------------------------------------------------------

LocationDto locationOf(dynamic lat, dynamic lng, [dynamic address]) {
  return LocationDto(
    latitude: toDouble(lat),
    longitude: toDouble(lng),
    address: address?.toString(),
  );
}

// ---------------------------------------------------------------------------
// Rides & bookings
// ---------------------------------------------------------------------------

Ride rideFromJson(Map<String, dynamic> json) {
  final availableSeats = toInt(json['availableSeats']);
  return Ride(
    id: json['id']?.toString() ?? '',
    driverId: json['driverId']?.toString(),
    creatorId: json['creatorId']?.toString(),
    vehicleId: json['vehicleId']?.toString(),
    rideType: parseRideType(json['type'] ?? json['rideType']),
    status: parseRideStatus(json['status']),
    scheduledAt: toDateOrNull(json['scheduledAt']),
    origin: locationOf(
      json['originLatitude'],
      json['originLongitude'],
      json['originAddress'],
    ),
    destination: locationOf(
      json['destinationLatitude'],
      json['destinationLongitude'],
      json['destinationAddress'],
    ),
    // The backend exposes only remaining seats; keep the model contract
    // satisfied without inventing capacity.
    totalSeats: availableSeats,
    availableSeats: availableSeats,
    maxDetourMeters: json['maxDetourMeters'] is int
        ? json['maxDetourMeters'] as int
        : toInt(json['maxDetourMeters']),
    maxWaitSeconds: json['maxWaitSeconds'] is int
        ? json['maxWaitSeconds'] as int
        : toInt(json['maxWaitSeconds']),
    notes: json['notes']?.toString(),
    routeVersion: json['routeVersion']?.toString(),
    fareRuleVersion: json['fareRuleVersion']?.toString(),
    createdAt: toDateOrNull(json['createdAt']),
    updatedAt: toDateOrNull(json['updatedAt']),
  );
}

FareQuoteDto fareQuoteFromJson(Map<String, dynamic> json) {
  return FareQuoteDto(
    quoteId: json['quoteId']?.toString() ?? '',
    bookingId: json['bookingId']?.toString(),
    fareRuleVersion: json['fareRuleVersion']?.toString() ?? '',
    routeVersion: json['routeVersion']?.toString() ?? '',
    distanceMeters: toInt(json['distanceMeters']),
    durationSeconds: toInt(json['durationSeconds']),
    baseFare: toDouble(json['baseFare']),
    distanceCharge: toDouble(json['distanceCharge']),
    timeCharge: toDouble(json['timeCharge']),
    serviceFee: toDouble(json['serviceFee']),
    tax: toDouble(json['tax']),
    grossFare: toDouble(json['grossFare']),
    discount: toDouble(json['discount']),
    finalPayable: toDouble(json['finalPayable']),
    currency: json['currency']?.toString() ?? 'BDT',
    expiresAt: toDate(json['expiresAt']),
  );
}

Booking bookingFromJson(Map<String, dynamic> json) {
  return Booking(
    id: json['id']?.toString() ?? '',
    rideId: json['rideId']?.toString() ?? '',
    passengerId: json['passengerId']?.toString() ?? '',
    seats: toInt(json['seats'], 1),
    fareQuote: null, // The booking carries fareQuoteId; the quote is fetched
    // separately when a breakdown is needed.
    pickupLocation: locationOf(
      json['pickupLatitude'],
      json['pickupLongitude'],
      json['pickupAddress'],
    ),
    dropoffLocation: locationOf(
      json['dropoffLatitude'],
      json['dropoffLongitude'],
      json['dropoffAddress'],
    ),
    pickupAddress: json['pickupAddress']?.toString(),
    dropoffAddress: json['dropoffAddress']?.toString(),
    status: parseBookingStatus(json['status']),
    createdAt: toDateOrNull(json['createdAt']),
    updatedAt: toDateOrNull(json['updatedAt']),
  );
}

// ---------------------------------------------------------------------------
// User & saved locations
// ---------------------------------------------------------------------------

UserProfile userProfileFromJson(Map<String, dynamic> json) {
  final profile = json['profile'] is Map<String, dynamic>
      ? json['profile'] as Map<String, dynamic>
      : const <String, dynamic>{};
  final first = profile['firstName']?.toString() ?? '';
  final last = profile['lastName']?.toString() ?? '';
  final name = [first, last].where((p) => p.isNotEmpty).join(' ');
  return UserProfile(
    id: json['id']?.toString() ?? '',
    name: name.isEmpty ? null : name,
    email: json['email']?.toString(),
    phone: json['phone']?.toString(),
    photoUrl: profile['profilePhotoUrl']?.toString(),
  );
}

SavedLocation savedLocationFromJson(Map<String, dynamic> json) {
  return SavedLocation(
    id: json['id']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
    location: locationOf(json['latitude'], json['longitude'], json['address']),
    isFavorite: json['isFavorite'] is bool ? json['isFavorite'] as bool : null,
  );
}

// ---------------------------------------------------------------------------
// Wallet & notifications
// ---------------------------------------------------------------------------

Wallet walletFromJson(Map<String, dynamic> json) {
  return Wallet(
    id: json['id']?.toString() ?? '',
    userId: json['ownerId']?.toString() ?? json['userId']?.toString() ?? '',
    balance: toDouble(json['balance']),
    currency: json['currency']?.toString() ?? 'BDT',
    lastUpdated: toDateOrNull(json['updatedAt']),
    createdAt: toDateOrNull(json['createdAt']),
  );
}

WalletTransaction walletTransactionFromJson(Map<String, dynamic> json) {
  return WalletTransaction(
    id: json['id']?.toString() ?? '',
    walletId: json['accountId']?.toString() ?? '',
    amount: toDouble(json['amount']),
    type: json['type']?.toString() ?? 'UNKNOWN',
    // Ledger entries are immutable once posted.
    status: 'COMPLETED',
    referenceId: json['referenceId']?.toString(),
    description: json['description']?.toString(),
    createdAt: toDateOrNull(json['createdAt']),
  );
}

Notification notificationFromJson(Map<String, dynamic> json) {
  return Notification(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    body: json['content']?.toString() ?? json['body']?.toString() ?? '',
    type: json['type']?.toString(),
    referenceId: json['referenceId']?.toString(),
    read: json['isRead'] is bool
        ? json['isRead'] as bool
        : json['read'] is bool
            ? json['read'] as bool
            : false,
    createdAt: toDateOrNull(json['createdAt']),
  );
}

// ---------------------------------------------------------------------------
// Safety & complaints
// ---------------------------------------------------------------------------

SafetyEvent safetyEventFromJson(Map<String, dynamic> json) {
  return SafetyEvent(
    id: json['id']?.toString() ?? '',
    userId: json['user'] is Map<String, dynamic>
        ? (json['user'] as Map<String, dynamic>)['id']?.toString() ?? ''
        : json['userId']?.toString() ?? '',
    rideId: json['ride'] is Map<String, dynamic>
        ? (json['ride'] as Map<String, dynamic>)['id']?.toString()
        : json['rideId']?.toString(),
    type: json['eventType']?.toString() ?? json['type']?.toString() ?? 'SOS',
    status: json['status']?.toString() ?? 'OPEN',
    location: json['latitude'] == null || json['longitude'] == null
        ? null
        : [toDouble(json['latitude']), toDouble(json['longitude'])],
    note: json['description']?.toString(),
    createdAt: toDateOrNull(json['createdAt']),
  );
}

Complaint complaintFromJson(Map<String, dynamic> json) {
  return Complaint(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ??
        (json['user'] is Map ? json['user']['id']?.toString() : null) ??
        '',
    rideId: json['bookingId']?.toString() ?? json['rideId']?.toString(),
    subject: json['category']?.toString() ?? json['subject']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    status: json['status']?.toString(),
    response: json['resolution']?.toString() ?? json['response']?.toString(),
    respondedAt: toDateOrNull(json['respondedAt']),
    createdAt: toDateOrNull(json['createdAt']),
  );
}
