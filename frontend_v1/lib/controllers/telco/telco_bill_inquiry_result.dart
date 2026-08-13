import 'package:frontend_v1/model/telco/telco_bill_model.dart';

class TelcoBillInquiryResult {
  final bool success;
  final String message;
  final TelcoBillModel? bill;

  const TelcoBillInquiryResult._({
    required this.success,
    required this.message,
    required this.bill,
  });

  factory TelcoBillInquiryResult.success({
    required TelcoBillModel bill,
    required String message,
  }) {
    return TelcoBillInquiryResult._(
      success: true,
      message: message,
      bill: bill,
    );
  }

  factory TelcoBillInquiryResult.failure({
    required String message,
  }) {
    return TelcoBillInquiryResult._(
      success: false,
      message: message,
      bill: null,
    );
  }
}