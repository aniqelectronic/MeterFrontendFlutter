import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_v1/model/compound/multi_compound_model.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/controllers/compound/kesalahan_controller.dart';

class MultipleCompoundController {
  static final List<MultiCompoundModel> _compoundList = [];
  static final List<String> _selectedCompoundNumbers = [];
  static double _selectedTotalAmount = 0.0;
  static String _plate = '';

  // ==========================
  // Plate Handling
  // ==========================
  static Future<bool> setPlateNumberMultiComp(String plate) async {
    _plate = plate.trim().toUpperCase();
    return await fetchByPlate(_plate);
  }

  static String get plate => _plate;

  // ==========================
  // Fetch Compounds by Plate
  // ==========================
  static Future<bool> fetchByPlate(String plateNo) async {
    _compoundList.clear();

    if (plateNo.trim().isEmpty) {
      debugPrint('Empty plate number');
      return false;
    }

    try {
      final url = Uri.parse(
        '${Config.forcifyEndpoint}/universal-unpaid'
        '?query=$plateNo&query_type=2',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${Config.forcifyToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('API error: ${response.statusCode}');
        return false;
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      if (data.isEmpty) {
        debugPrint('No compounds found for $plateNo');
        return false;
      }

      for (final item in data) {
        final model = MultiCompoundModel.fromJson(item);

        // Convert offense description
        model.perintah =
            KesalahanController.getPerintahFromDescription(model.offense);

        // Filter by compound prefix (e.g. "KN")
        if (model.compoundNum.startsWith(Config.compoundPrefix1)) {
          _compoundList.add(model);
          debugPrint(
              '→ ${model.compoundNum} | ${model.offense} | RM${model.amount} | ${model.status}');
        }
      }

      debugPrint('Total compounds fetched: ${_compoundList.length}');
      return true;
    } catch (e) {
      debugPrint('Error fetching compounds: $e');
      return false;
    }
  }

  // ==========================
  // Selected Compounds
  // ==========================
  static void setSelectedCompounds(
      List<String> compounds, double total) {
    _selectedCompoundNumbers
      ..clear()
      ..addAll(compounds);
    _selectedTotalAmount = total;
  }

  static List<String> get selectedCompoundNumbers =>
      _selectedCompoundNumbers;

  static double get selectedTotalAmount => _selectedTotalAmount;

  // ==========================
  // Getters
  // ==========================
  static List<MultiCompoundModel> get compoundList => _compoundList;

  static double get totalAmount =>
      _compoundList
          .where((c) => c.status == 'UNPAID')
          .fold(0.0, (sum, c) => sum + c.amount);

  static bool get hasUnpaidCompounds =>
      _compoundList.any((c) => c.status == 'UNPAID');

  // ==========================
  // Clear
  // ==========================
  static void clearAll() {
    _compoundList.clear();
    _selectedCompoundNumbers.clear();
    _selectedTotalAmount = 0.0;
    _plate = '';
    debugPrint('Cleared all compound data');
  }
}
