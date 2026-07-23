import 'package:frontend_v1/model/electric/electric_bill_model.dart';

class EntertainmentBillInquiryResult {
  final bool success;
  final String message;
  final ElectricBillModel? bill;

  const EntertainmentBillInquiryResult._({
    required this.success,
    required this.message,
    required this.bill,
  });

  factory EntertainmentBillInquiryResult.success({
    required ElectricBillModel bill,
    String message = '',
  }) {
    return EntertainmentBillInquiryResult._(
      success: true,
      message: message,
      bill: bill,
    );
  }

  factory EntertainmentBillInquiryResult.failure({
    required String message,
  }) {
    return EntertainmentBillInquiryResult._(
      success: false,
      message: message,
      bill: null,
    );
  }
}
