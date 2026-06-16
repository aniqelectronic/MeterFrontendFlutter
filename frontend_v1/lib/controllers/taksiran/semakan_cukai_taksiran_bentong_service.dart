import 'dart:convert';
import 'package:http/http.dart' as http;

class SemakanCukaiTaksiranBentongService {
  static List<Map<String, dynamic>> paymentList = [];

static Future<bool> semakanBayaran(String input) async {
  try {
    paymentList.clear();

    final originalInput = input.trim();
    final withoutPrefix =
        originalInput.replaceFirst(RegExp(r'^[Tt]'), '');

    // 1. Search no_pendaftaran first
    var url = Uri.parse(
      "http://4.194.122.32:8000/tax/payment-updates-cukaitaksiran-bentong/semakan?no_pendaftaran=${Uri.encodeComponent(originalInput)}",
    );

    var response = await http.get(url);

    // 2. Search account number exactly as entered
    if (response.statusCode != 200) {
      url = Uri.parse(
        "http://4.194.122.32:8000/tax/payment-updates-cukaitaksiran-bentong/semakan?account_number=${Uri.encodeComponent(originalInput)}",
      );

      response = await http.get(url);
    }

    // 3. Search account number with T prefix
    if (response.statusCode != 200) {
      url = Uri.parse(
        "http://4.194.122.32:8000/tax/payment-updates-cukaitaksiran-bentong/semakan?account_number=T${Uri.encodeComponent(withoutPrefix)}",
      );

      response = await http.get(url);
    }

    // 4. Search account number without T prefix
    if (response.statusCode != 200) {
      url = Uri.parse(
        "http://4.194.122.32:8000/tax/payment-updates-cukaitaksiran-bentong/semakan?account_number=${Uri.encodeComponent(withoutPrefix)}",
      );

      response = await http.get(url);
    }

    print("[SEMAKAN TAKSIRAN] Status: ${response.statusCode}");
    print("[SEMAKAN TAKSIRAN] Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        paymentList = data
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        return paymentList.isNotEmpty;
      }
    }

    paymentList = [];
    return false;
  } catch (e) {
    print("[SEMAKAN TAKSIRAN ERROR] $e");
    paymentList = [];
    return false;
  }
}
}