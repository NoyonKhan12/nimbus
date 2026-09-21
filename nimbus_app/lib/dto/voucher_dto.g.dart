// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoucherValidationImpl _$$VoucherValidationImplFromJson(
        Map<String, dynamic> json) =>
    _$VoucherValidationImpl(
      valid: json['valid'] as bool,
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      voucherCode: json['voucherCode'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$VoucherValidationImplToJson(
        _$VoucherValidationImpl instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'discountAmount': instance.discountAmount,
      'voucherCode': instance.voucherCode,
      'message': instance.message,
    };

_$VoucherValidateRequestImpl _$$VoucherValidateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$VoucherValidateRequestImpl(
      code: json['code'] as String,
      fare: (json['fare'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$VoucherValidateRequestImplToJson(
        _$VoucherValidateRequestImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'fare': instance.fare,
    };
