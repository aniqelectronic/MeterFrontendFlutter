import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_v1/model/license/license_model.dart';
import 'package:frontend_v1/pages/config.dart';

class LicenseService {
  static const Duration _timeout = Duration(seconds: 10);

  /// ===============================
  /// Fetch licenses by IC
  /// ===============================
  static Future<List<LicenseModel>> getLicensesByIC(String ic) async {
    if (ic.trim().isEmpty) return [];

    try {
      final uri = Uri.parse('${Config.baseUrl}/license/by-ic/${ic.trim()}');
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        print('LicenseService: API error ${response.statusCode}');
        return [];
      }

      final List<dynamic> data = json.decode(response.body);

      if (data.isEmpty) return [];

      final licenses =
          data.map((e) => LicenseModel.fromJson(e)).toList();

      // Optional: auto-calc total
      double total = 0;
      for (var l in licenses) {
        total += l.amount;
      }
      LicenseModel.setTotalAmount(total);

      return licenses;
    } catch (e) {
      print('LicenseService exception: $e');
      return [];
    }
  }

  /// ===============================
  /// Pay multiple licenses
  /// ===============================
static Future<bool> payMultipleLicenses(List<String> licenseNos) async {
  if (licenseNos.isEmpty) return false;

  final uri = Uri.parse('${Config.baseUrl}/license/pay-multi');

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"licenses": licenseNos}),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    return response.statusCode == 200;
  } catch (e) {
    print('payMultipleLicenses error: $e');
    return false;
  }
}

  /// ===============================
  /// Selected licenses (P5 → P7)
  /// ===============================
  static final List<String> _selectedLicenses = [];

  static void setSelectedLicenses(List<String> licenses) {
    _selectedLicenses
      ..clear()
      ..addAll(licenses);
  }

  static List<String> getSelectedLicenses() {
    return List<String>.from(_selectedLicenses);
  }
}
