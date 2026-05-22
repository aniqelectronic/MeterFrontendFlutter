import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';

class SewaanPaymentServiceBentong {
  static const String _baseUrl = "http://52.163.74.67:3010";

  static const Map<String, String> _headers = {
    "x-api-key": "MPB_GW_2026_x8Kp91LmQ7zT44",
    "Content-Type": "application/json",
  };

  static String _cleanAccountNo(String accountNo) {
    return accountNo.trim().replaceFirst(RegExp(r'^[TS]'), '');
  }

  // =========================================
  // SINGLE PAYMENT
  // =========================================
  static Future<bool> paySewaan({
    required String accountNumber,
    required double amountPaid,
    required String referenceNo,
  }) async {
    try {
      final cleanAccountNo = _cleanAccountNo(accountNumber);

      final url = Uri.parse("$_baseUrl/api/v1/mpb/sewaan/payment");

      final body = {
        "module": "S",
        "account_number": cleanAccountNo,
        "amount_paid": amountPaid,
        "agent_code": "KTIP",
        "reference_no": referenceNo,
      };

      print("====================================");
      print("[SEWAAN PAYMENT]");
      print("Account No : $cleanAccountNo");
      print("Amount     : $amountPaid");
      print("Reference  : $referenceNo");
      print("Request    : ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      print("Status Code : ${response.statusCode}");
      print("Response    : ${response.body}");
      print("====================================");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("[SEWAAN PAYMENT ERROR] $e");
      return false;
    }
  }

  // =========================================
  // MULTIPLE PAYMENT
  // =========================================
  static Future<bool> payMultipleSewaan({
    required List<SewaanPaymentItem> items,
    required String referenceNo,
  }) async {
    for (final item in items) {
      final success = await paySewaan(
        accountNumber: item.accountNo,
        amountPaid: item.amount,
        referenceNo: referenceNo,
      );

      if (!success) {
        print(
          "[SEWAAN PAYMENT] Failed for account: ${_cleanAccountNo(item.accountNo)}",
        );
        return false;
      }
    }

    print("[SEWAAN PAYMENT] All payments success");
    return true;
  }
}