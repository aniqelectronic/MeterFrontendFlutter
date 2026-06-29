import 'dart:convert';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';

class SewaanPaymentServiceBentong {
  // MPB Gateway API
  static const String _paymentBaseUrl = "http://52.163.74.67:3010";

  // Your FastAPI backend
  static const String _backendBaseUrl = "http://4.194.122.32:8000";

  static final Map<String, String> _paymentHeaders = {
    "x-api-key": "MPB_GW_2026_x8Kp91LmQ7zT44",
    "Content-Type": "application/json",
    "x-source-system": "TIP-${Config.terminalId}",
  };

  static final Map<String, String> _backendHeaders = {
    "Content-Type": "application/json",
  };

  static String _cleanAccountNo(String accountNo) {
    return accountNo.trim().replaceFirst(RegExp(r'^[TS]'), '');
  }

  // =========================================
  // SINGLE PAYMENT TO MPB
  // =========================================
  static Future<bool> paySewaan({
    required String accountNumber,
    required double amountPaid,
    required String referenceNo,
  }) async {
    try {
      final cleanAccountNo = _cleanAccountNo(accountNumber);

      final url = Uri.parse("$_paymentBaseUrl/api/v1/mpb/sewaan/payment");

      final body = {
        "module": "S",
        "account_number": cleanAccountNo,
        "amount_paid": amountPaid,
        "agent_code": "KTIP",
        "reference_no": referenceNo,
      };

      print("====================================");
      print("[SEWAAN PAYMENT]");
      print("URL        : $url");
      print("Account No : $cleanAccountNo");
      print("Amount     : $amountPaid");
      print("Reference  : $referenceNo");
      print("Request    : ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: _paymentHeaders,
        body: jsonEncode(body),
      );

      print("Status Code : ${response.statusCode}");
      print("Response    : ${response.body}");
      print("====================================");

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded["success"] == false) {
        return false;
      }

      return true;
    } catch (e) {
      print("[SEWAAN PAYMENT ERROR] $e");
      return false;
    }
  }

  // =========================================
  // MULTIPLE PAYMENT TO MPB
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

  // =========================================
  // SAVE PAYMENT UPDATE TO LOCAL FASTAPI DB
  // =========================================
  static Future<bool> postPaymentUpdateBentong({
    required List<SewaanPaymentItem> items,
    required String orderNo,
    required String bankTrxNo,
    required String paymentMethod,
  }) async {
    try {
      final url = Uri.parse(
        "$_backendBaseUrl/sewaan/payment-updates-sewaan-bentong",
      );

      final payload = {
        "order_no": orderNo,
        "paid_date": DateTime.now().toIso8601String(),
        "payment_method": paymentMethod,
        "bank_trx_no": bankTrxNo,
        "sewaan_items": items.map((item) {
          return {
            "no_pendaftaran": item.noPendaftaran,
            "account_number": item.accountNo,
            "tenant_name": item.tenantName,
            "premise_address": item.premiseAddress,
            "amount": item.amount,
          };
        }).toList(),
      };

      print("====================================");
      print("[SEWAAN UPDATE]");
      print("URL     : $url");
      print("Payload : ${jsonEncode(payload)}");

      final response = await http.post(
        url,
        headers: _backendHeaders,
        body: jsonEncode(payload),
      );

      print("Status  : ${response.statusCode}");
      print("Body    : ${response.body}");
      print("====================================");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("[SEWAAN UPDATE ERROR] $e");
      return false;
    }
  }
}