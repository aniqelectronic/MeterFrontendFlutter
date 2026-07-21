import 'package:frontend_v1/model/broadband/broadband_bill_model.dart';

class BroadbandBillInquiryResult {
  final bool success;
  final BroadbandBillModel? bill;
  final String message;

  const BroadbandBillInquiryResult({
    required this.success,
    required this.bill,
    required this.message,
  });

  factory BroadbandBillInquiryResult.success({
    required BroadbandBillModel bill,
    String message = '',
  }) {
    return BroadbandBillInquiryResult(
      success: true,
      bill: bill,
      message: message,
    );
  }

  factory BroadbandBillInquiryResult.failure({
    required String message,
  }) {
    return BroadbandBillInquiryResult(
      success: false,
      bill: null,
      message: message,
    );
  }
}