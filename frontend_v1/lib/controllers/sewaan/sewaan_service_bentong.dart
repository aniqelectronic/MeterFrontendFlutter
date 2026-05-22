import 'dart:convert';
import 'package:http/http.dart' as http;

class SewaanService {
  static const String baseUrl = "http://52.163.74.67:3010";

  static const Map<String, String> headers = {
    "x-api-key": "MPB_GW_2026_x8Kp91LmQ7zT44",
    "Content-Type": "application/json",
  };

  // ✅ Save latest pulled sewaan data here
  static Map<String, dynamic>? sewaanData;

  static Future<bool> inquirySewaan(String searchValue) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/mpb/sewaan/inquiry"),
        headers: headers,
        body: jsonEncode({
          "search_value": searchValue,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true &&
            data["data"] != null &&
            data["data"]["data"] != null) {
          sewaanData = data["data"]["data"];
          return true;
        }
      }

      sewaanData = null;
      return false;
    } catch (e) {
      print("Sewaan Error: $e");
      sewaanData = null;
      return false;
    }
  }

  static void clearSewaan() {
    sewaanData = null;
  }
}