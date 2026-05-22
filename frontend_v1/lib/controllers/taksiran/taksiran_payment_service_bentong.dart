import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';

class TaksiranPaymentServiceBentong {
  static const String _baseUrl = "http://52.163.74.67:3010";
  static const String _apiKey = "MPB_GW_2026_x8Kp91LmQ7zT44";

  // =========================================
  // SINGLE PAYMENT
  // =========================================
  static Future<bool> payOne({
    required String accountNo,
    required double amount,
    required String referenceNo,
  }) async {
    try {

      // Remove T or S at front if exist
      final cleanAccountNo = accountNo
          .replaceFirst(RegExp(r'^[TS]'), '');

      final url = Uri.parse(
        "$_baseUrl/api/v1/mpb/taksiran/payment",
      );

      final body = {
        "module": "T",
        "account_number": cleanAccountNo,
        "amount_paid": amount,
        "agent_code": "KTIP",
        "reference_no": referenceNo,
      };

      print("====================================");
      print("[TAKSIRAN PAYMENT]");
      print("Account No : $cleanAccountNo");
      print("Amount     : $amount");
      print("Reference  : $referenceNo");
      print("Request    : ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: const {
          "x-api-key": _apiKey,
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("Status Code : ${response.statusCode}");
      print("Response    : ${response.body}");
      print("====================================");

      return response.statusCode >= 200 &&
          response.statusCode < 300;

    } catch (e) {
      print("[TAKSIRAN PAYMENT ERROR] $e");
      return false;
    }
  }

  // =========================================
  // MULTIPLE PAYMENT
  // =========================================
static Future<bool> payMultiple({
  required List<TaksiranPaymentItem> items,
  required String referenceNo,
}) async {
  for (final item in items) {
    final cleanAccountNo = item.accountNo
        .replaceFirst(RegExp(r'^[TS]'), '');

    final success = await payOne(
      accountNo: cleanAccountNo,
      amount: item.amount,
      referenceNo: referenceNo,
    );

    if (!success) {
      print("[TAKSIRAN PAYMENT] Failed for account: $cleanAccountNo");
      return false;
    }
  }

  print("[TAKSIRAN PAYMENT] All payments success");
  return true;
}
}