import 'dart:convert';
import 'package:frontend_v1/model/tax/tax_model.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class TaxService {
  static const String baseUrl = Config.baseUrl;

  /// ===============================
  /// Fetch taxes by owner IC
  /// ===============================
  static Future<List<TaxModel>> getTaxesByIC(String ic) async {
    if (ic.trim().isEmpty) return [];

    final uri = Uri.parse('$baseUrl/tax/by-ic/$ic');

    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        print('TaxService error: ${response.statusCode}');
        return [];
      }

      final List<dynamic> data = jsonDecode(response.body);

      if (data.isEmpty) return [];

      return data.map((e) => TaxModel.fromJson(e)).toList();
    } catch (e) {
      print('TaxService exception: $e');
      return [];
    }
  }

  /// ===============================
  /// Pay multiple taxes
  /// ===============================
  static Future<bool> payMultipleTaxes(List<String> billNos) async {
    final uri = Uri.parse('$baseUrl/tax/pay/multi');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "bill_no": billNos,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('payMultipleTaxes error: $e');
      return false;
    }
  }
}
