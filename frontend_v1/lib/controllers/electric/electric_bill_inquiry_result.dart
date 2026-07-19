import 'package:frontend_v1/model/electric/electric_bill_model.dart';

class ElectricBillInquiryResult {
  final bool success;
  final ElectricBillModel? bill;
  final String message;

  const ElectricBillInquiryResult({
    required this.success,
    required this.bill,
    required this.message,
  });

  factory ElectricBillInquiryResult.success({
    required ElectricBillModel bill,
    String message = '',
  }) {
    return ElectricBillInquiryResult(
      success: true,
      bill: bill,
      message: message,
    );
  }

  factory ElectricBillInquiryResult.failure({
    required String message,
  }) {
    return ElectricBillInquiryResult(
      success: false,
      bill: null,
      message: message,
    );
  }
}