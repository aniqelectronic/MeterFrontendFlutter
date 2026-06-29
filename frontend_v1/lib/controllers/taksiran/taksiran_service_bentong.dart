import 'dart:convert';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class TaksiranServiceBentong {
  static const String baseUrl = "http://52.163.74.67:3010";

  static final Map<String, String> headers = {
    "x-api-key": "MPB_GW_2026_x8Kp91LmQ7zT44",
    "Content-Type": "application/json",
    "x-source-system": "TIP-${Config.terminalId}",
  };

  static List<Map<String, dynamic>> taksiranList = [];

  static Future<bool> inquiryTaksiran(String searchValue) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/mpb/taksiran/inquiry"),
        headers: headers,
        body: jsonEncode({
          "search_value": searchValue,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true &&
            data["data"] != null &&
            data["data"]["data"] != null &&
            data["data"]["data"] is List) {
          taksiranList = List<Map<String, dynamic>>.from(
            data["data"]["data"],
          );
          return taksiranList.isNotEmpty;
        }
      }

      taksiranList = [];
      return false;
    } catch (e) {
      print("Taksiran Error: $e");
      taksiranList = [];
      return false;
    }
  }

  static void clearTaksiran() {
    taksiranList = [];
  }
}