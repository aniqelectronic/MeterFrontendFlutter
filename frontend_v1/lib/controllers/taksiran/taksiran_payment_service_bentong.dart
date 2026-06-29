import 'dart:convert';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';

class TaksiranPaymentServiceBentong {
  static const String _baseUrl = "http://52.163.74.67:3010";
  static const String _apiKey = "MPB_GW_2026_x8Kp91LmQ7zT44";

  static const String _kioskBackendUrl =
      "http://4.194.122.32:8000";

  // =========================================
  // SINGLE PAYMENT TO MPB API
  // =========================================
  static Future<bool> payOne({
    required String accountNo,
    required double amount,
    required String referenceNo,
  }) async {
    try {
      final cleanAccountNo = accountNo.replaceFirst(RegExp(r'^[TS]'), '');

      final url = Uri.parse("$_baseUrl/api/v1/mpb/taksiran/payment");

      final body = {
        "module": "T",
        "account_number": cleanAccountNo,
        "amount_paid": amount,
        "agent_code": "KTIP",
        "reference_no": referenceNo,
      };

      final response = await http.post(
        url,
        headers: {
          "x-api-key": _apiKey,
          "Content-Type": "application/json",
          "x-source-system": "TIP-${Config.terminalId}",
        },
        body: jsonEncode(body),
      );

      print("[TAKSIRAN PAYMENT] Status: ${response.statusCode}");
      print("[TAKSIRAN PAYMENT] Response: ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("[TAKSIRAN PAYMENT ERROR] $e");
      return false;
    }
  }

  // =========================================
  // MULTIPLE PAYMENT TO MPB API
  // =========================================
  static Future<bool> payMultiple({
    required List<TaksiranPaymentItem> items,
    required String referenceNo,
  }) async {
    for (final item in items) {
      final cleanAccountNo =
          item.accountNo.replaceFirst(RegExp(r'^[TS]'), '');

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

  // =========================================
  // SAVE PAYMENT UPDATE TO YOUR BACKEND DB
  // =========================================
  static Future<bool> postPaymentUpdateBentong({
    required List<TaksiranPaymentItem> items,
    required String orderNo,
    required String bankTrxNo,
    required String paymentMethod,
  }) async {
    try {
      final url = Uri.parse(
        "$_kioskBackendUrl/tax/payment-updates-cukaitaksiran-bentong",
      );

      final taxItems = items.map((item) {
        final cleanAccountNo =
            item.accountNo.replaceFirst(RegExp(r'^[TS]'), '');

        return {
          "no_pendaftaran": item.noPendaftaran,
          "account_number": cleanAccountNo,
          "owner_name": item.ownerName,
          "property_address": item.propertyAddress,
          "amount": item.amount,
        };
      }).toList();

      final body = {
        "order_no": orderNo,
        "paid_date": DateTime.now().toIso8601String(),
        "payment_method": paymentMethod,
        "bank_trx_no": bankTrxNo,
        "tax_items": taxItems,
      };

      print("====================================");
      print("[CUKAI PAYMENT UPDATE BENTONG]");
      print("Request: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: const {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}");
      print("====================================");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("[CUKAI PAYMENT UPDATE BENTONG ERROR] $e");
      return false;
    }
  }
}