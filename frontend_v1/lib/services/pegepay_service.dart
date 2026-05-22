import 'dart:convert';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class PegePayService {
  static const String baseUrl = Config.baseUrl;

  static Future<Map<String, dynamic>> createOrder(
    double amount,
    String storeId,
    String terminalId,
    String shiftId,
  ) async {
    final body = jsonEncode({
      "order_amount": amount,
      "qr_validity": 120,
      "store_id": storeId,
      "terminal_id": terminalId,
      "shift_id": shiftId,
    });

    final response = await http.post(
      Uri.parse("$baseUrl/pegepay/create-order"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create PegePay order: ${response.body}");
    }

    return jsonDecode(response.body);
  }

  // KEEP OLD FUNCTION, so QR success still works
  static Future<bool> checkStatus(String orderNo) async {
    final res = await http.post(
      Uri.parse("$baseUrl/pegepay/check-status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"order_no": orderNo}),
    );

    if (res.statusCode != 200) return false;

    final json = jsonDecode(res.body);
    final status = json["order_status"].toString().toLowerCase();

    return status == "successful" || status == "success" || status == "paid";
  }

  // ADD NEW FUNCTION for receipt data
  static Future<Map<String, dynamic>> checkStatusDetails(String orderNo) async {
    final res = await http.post(
      Uri.parse("$baseUrl/pegepay/check-status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"order_no": orderNo}),
    );

    if (res.statusCode != 200) {
      return {
        "success": false,
        "order_no": orderNo,
        "bank_trx_no": "",
      };
    }

    final json = jsonDecode(res.body);
    final status = json["order_status"].toString().toLowerCase();

    return {
      "success": status == "successful" ||
          status == "success" ||
          status == "paid",
      "order_no": json["order_no"] ?? orderNo,
      "bank_trx_no": json["bank_trx_no"] ?? "",
    };
  }
}