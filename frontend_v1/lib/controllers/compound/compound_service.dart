import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_v1/model/compound/compound_model.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/controllers/compound/kesalahan_controller.dart'; //kesealahan list

class CompoundService {
  static final String _endpoint = Config.forcifyEndpoint;
  static final String _token = Config.forcifyToken;

  /// ===============================
  /// Fetch single compound by number
  /// ===============================
  static Future<CompoundModel?> getSingleCompound(String compNo) async {
    if (compNo.trim().isEmpty) return null;

    final url = Uri.parse(
      '$_endpoint/universal-unpaid?query=${compNo.trim()}&query_type=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('CompoundService: API error ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> root = json.decode(response.body);
      final List<dynamic>? data = root['data'];

      if (data == null || data.isEmpty) {
        print('CompoundService: No data for $compNo');
        return null;
      }

      final item = data.first as Map<String, dynamic>;

      /// ===== Timestamp split =====
      String? date;
      String? time;
      final String? timestamp = item['violation_timestamp'];
      if (timestamp != null && timestamp.contains('T')) {
        final parts = timestamp.split('T');
        date = parts[0];
        time = parts[1].split('+')[0];
      }

      /// ===== Amount cents → RM =====
      final double amount =
          (double.parse(item['compound_amount'].toString())) / 100.0;

      /// ===== Map violation type =====
      final String violationDesc = item['violation_type'] ?? '';
      final String compType =
          KesalahanController.getPerintahFromDescription(violationDesc);

      return CompoundModel(
        compNo: compNo,
        compPlateNo: item['plate_number'],
        compName: item['offender_name'],
        kodhasil: item['service_reference_2'],
        compPaymentStatus: item['status'],
        violationDesc: violationDesc,
        compDate: date,
        compTime: time,
        compType: compType,
        amount: amount,
      );
    } catch (e) {
      print('CompoundService: Failed -> $e');
      return null;
    }
  }
}
