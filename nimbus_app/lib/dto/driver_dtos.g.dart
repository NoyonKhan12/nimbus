// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverApplicationRequestImpl _$$DriverApplicationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverApplicationRequestImpl(
      licenseNumber: json['licenseNumber'] as String,
      nationalId: json['nationalId'] as String,
      vehicleId: json['vehicleId'] as String,
      drivingLicensePhoto: json['drivingLicensePhoto'] as String,
      nationalIdPhoto: json['nationalIdPhoto'] as String,
      vehicleRegistrationPhoto: json['vehicleRegistrationPhoto'] as String?,
    );

Map<String, dynamic> _$$DriverApplicationRequestImplToJson(
        _$DriverApplicationRequestImpl instance) =>
    <String, dynamic>{
      'licenseNumber': instance.licenseNumber,
      'nationalId': instance.nationalId,
      'vehicleId': instance.vehicleId,
      'drivingLicensePhoto': instance.drivingLicensePhoto,
      'nationalIdPhoto': instance.nationalIdPhoto,
      'vehicleRegistrationPhoto': instance.vehicleRegistrationPhoto,
    };

_$DriverApplicationImpl _$$DriverApplicationImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverApplicationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );

Map<String, dynamic> _$$DriverApplicationImplToJson(
        _$DriverApplicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'status': instance.status,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewedBy': instance.reviewedBy,
      'rejectionReason': instance.rejectionReason,
    };

_$DriverProfileImpl _$$DriverProfileImplFromJson(Map<String, dynamic> json) =>
    _$DriverProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalRides: (json['totalRides'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DriverProfileImplToJson(_$DriverProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'rating': instance.rating,
      'totalRides': instance.totalRides,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$DriverEligibilityImpl _$$DriverEligibilityImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverEligibilityImpl(
      eligible: json['eligible'] as bool,
      missingRequirements: (json['missingRequirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$DriverEligibilityImplToJson(
        _$DriverEligibilityImpl instance) =>
    <String, dynamic>{
      'eligible': instance.eligible,
      'missingRequirements': instance.missingRequirements,
      'reason': instance.reason,
    };

_$DriverDocumentImpl _$$DriverDocumentImplFromJson(Map<String, dynamic> json) =>
    _$DriverDocumentImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      number: json['number'] as String,
      status: json['status'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      photoUrl: json['photoUrl'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$$DriverDocumentImplToJson(
        _$DriverDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'number': instance.number,
      'status': instance.status,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'photoUrl': instance.photoUrl,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };

_$DriverDocumentRequestImpl _$$DriverDocumentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverDocumentRequestImpl(
      type: json['type'] as String,
      number: json['number'] as String,
      photoUrl: json['photoUrl'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$DriverDocumentRequestImplToJson(
        _$DriverDocumentRequestImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'number': instance.number,
      'photoUrl': instance.photoUrl,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

_$DriverEarningsImpl _$$DriverEarningsImplFromJson(Map<String, dynamic> json) =>
    _$DriverEarningsImpl(
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      pendingSettlement: (json['pendingSettlement'] as num).toDouble(),
      availableBalance: (json['availableBalance'] as num).toDouble(),
      periodStart: json['periodStart'] == null
          ? null
          : DateTime.parse(json['periodStart'] as String),
      periodEnd: json['periodEnd'] == null
          ? null
          : DateTime.parse(json['periodEnd'] as String),
    );

Map<String, dynamic> _$$DriverEarningsImplToJson(
        _$DriverEarningsImpl instance) =>
    <String, dynamic>{
      'totalEarnings': instance.totalEarnings,
      'pendingSettlement': instance.pendingSettlement,
      'availableBalance': instance.availableBalance,
      'periodStart': instance.periodStart?.toIso8601String(),
      'periodEnd': instance.periodEnd?.toIso8601String(),
    };

_$SettlementImpl _$$SettlementImplFromJson(Map<String, dynamic> json) =>
    _$SettlementImpl(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      grossAmount: (json['grossAmount'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      adjustments: (json['adjustments'] as num).toDouble(),
      payable: (json['payable'] as num).toDouble(),
      status: json['status'] as String,
      periodStart: json['periodStart'] == null
          ? null
          : DateTime.parse(json['periodStart'] as String),
      periodEnd: json['periodEnd'] == null
          ? null
          : DateTime.parse(json['periodEnd'] as String),
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
    );

Map<String, dynamic> _$$SettlementImplToJson(_$SettlementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'grossAmount': instance.grossAmount,
      'commission': instance.commission,
      'adjustments': instance.adjustments,
      'payable': instance.payable,
      'status': instance.status,
      'periodStart': instance.periodStart?.toIso8601String(),
      'periodEnd': instance.periodEnd?.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
    };

_$SettlementActionRequestImpl _$$SettlementActionRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SettlementActionRequestImpl(
      action: json['action'] as String,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$SettlementActionRequestImplToJson(
        _$SettlementActionRequestImpl instance) =>
    <String, dynamic>{
      'action': instance.action,
      'reason': instance.reason,
    };

_$VehicleImpl _$$VehicleImplFromJson(Map<String, dynamic> json) =>
    _$VehicleImpl(
      id: json['id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      photoUrl: json['photoUrl'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$VehicleImplToJson(_$VehicleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'color': instance.color,
      'licensePlate': instance.licensePlate,
      'photoUrl': instance.photoUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$CreateVehicleRequestImpl _$$CreateVehicleRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateVehicleRequestImpl(
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$$CreateVehicleRequestImplToJson(
        _$CreateVehicleRequestImpl instance) =>
    <String, dynamic>{
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'color': instance.color,
      'licensePlate': instance.licensePlate,
      'photoUrl': instance.photoUrl,
    };

_$UpdateVehicleRequestImpl _$$UpdateVehicleRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateVehicleRequestImpl(
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: (json['year'] as num?)?.toInt(),
      color: json['color'] as String?,
      licensePlate: json['licensePlate'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$$UpdateVehicleRequestImplToJson(
        _$UpdateVehicleRequestImpl instance) =>
    <String, dynamic>{
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'color': instance.color,
      'licensePlate': instance.licensePlate,
      'photoUrl': instance.photoUrl,
      'isActive': instance.isActive,
    };

_$DriverLocationUpdateImpl _$$DriverLocationUpdateImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverLocationUpdateImpl(
      rideId: json['rideId'] as String,
      location: LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$DriverLocationUpdateImplToJson(
        _$DriverLocationUpdateImpl instance) =>
    <String, dynamic>{
      'rideId': instance.rideId,
      'location': instance.location,
      'heading': instance.heading,
      'speed': instance.speed,
    };
