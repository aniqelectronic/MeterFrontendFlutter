import 'dart:convert';
import 'package:http/http.dart' as http;

class SemakanSewaanBentongService {
  static const String _baseUrl = "http://4.194.122.32:8000";

  static List<Map<String, dynamic>> paymentList = [];

  static Future<bool> semakanBayaran(String input) async {
    try {
      paymentList.clear();

      final original = input.trim();
      final withoutS = original.replaceFirst(RegExp(r'^[Ss]'), '');
      final withS =
          original.toUpperCase().startsWith('S') ? original : 'S$original';

      final searchValues = <String>{
        original,
        withoutS,
        withS,
      };

      for (final value in searchValues) {
        final query = Uri.encodeComponent(value);

        // Search by no_pendaftaran
        var url = Uri.parse(
          "$_baseUrl/sewaan/payment-updates-sewaan-bentong/semakan?no_pendaftaran=$query",
        );

        var response = await http.get(url);

        if (response.statusCode == 200) {
          print("[SEMAKAN SEWAAN] Found by no_pendaftaran: $value");
          print(response.body);

          final decoded = jsonDecode(response.body);

          if (decoded is List) {
            paymentList = decoded
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          } else if (decoded is Map && decoded["data"] is List) {
            paymentList = (decoded["data"] as List)
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }

          if (paymentList.isNotEmpty) {
            return true;
          }
        }

        // Search by account_number
        url = Uri.parse(
          "$_baseUrl/sewaan/payment-updates-sewaan-bentong/semakan?account_number=$query",
        );

        response = await http.get(url);

        if (response.statusCode == 200) {
          print("[SEMAKAN SEWAAN] Found by account_number: $value");
          print(response.body);

          final decoded = jsonDecode(response.body);

          if (decoded is List) {
            paymentList = decoded
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          } else if (decoded is Map && decoded["data"] is List) {
            paymentList = (decoded["data"] as List)
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }

          if (paymentList.isNotEmpty) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print("[SEMAKAN SEWAAN ERROR] $e");
      return false;
    }
  }
}