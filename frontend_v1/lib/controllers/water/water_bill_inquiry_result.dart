import 'package:frontend_v1/model/water/water_bill_model.dart';

class WaterBillInquiryResult {
  final bool success;
  final WaterBillModel? bill;
  final String message;

  const WaterBillInquiryResult({
    required this.success,
    required this.bill,
    required this.message,
  });

  factory WaterBillInquiryResult.success({
    required WaterBillModel bill,
    String message = '',
  }) {
    return WaterBillInquiryResult(
      success: true,
      bill: bill,
      message: message,
    );
  }

  factory WaterBillInquiryResult.failure({
    required String message,
  }) {
    return WaterBillInquiryResult(
      success: false,
      bill: null,
      message: message,
    );
  }
}
