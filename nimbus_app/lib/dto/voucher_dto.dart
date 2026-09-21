import 'package:freezed_annotation/freezed_annotation.dart';

part 'voucher_dto.freezed.dart';
part 'voucher_dto.g.dart';

@freezed
class VoucherValidation with _$VoucherValidation {
  const factory VoucherValidation({
    required bool valid,
    required double? discountAmount,
    String? voucherCode,
    String? message,
  }) = _VoucherValidation;

  factory VoucherValidation.fromJson(Map<String, dynamic> json) =>
      _$VoucherValidationFromJson(json);
}

@freezed
class VoucherValidateRequest with _$VoucherValidateRequest {
  const factory VoucherValidateRequest({
    required String code,
    double? fare,
  }) = _VoucherValidateRequest;

  factory VoucherValidateRequest.fromJson(Map<String, dynamic> json) =>
      _$VoucherValidateRequestFromJson(json);
}
