import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_v1/model/parking/parking_model.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_v1/pages/config.dart';

class ParkingController {
  static bool activeParking = false;

  static bool isActiveParking() {
    return activeParking;
  }

  static Future<bool> checkActiveParking(String plate) async {
    try {
      final url = Uri.parse("${Config.baseUrl}/parking/check/$plate");
      final response = await http.get(url);

      if (response.statusCode != 200) {
        print("Plate not active or new.");
        activeParking = false;
        clearParkingAll();
        return false;
      }

      activeParking = true;

      final obj = jsonDecode(response.body);

      String timein = obj["timein"];
      String timeout = obj["timeout"];
      int? hours = (obj["time_used"] != null) ? (obj["time_used"] as num).round() : null;
      double amount = obj["amount"];

      String dateOnly = timein.split("T")[0];

      setParkingDate(dateOnly);
      setParkingStartTime(timein.substring(11));
      setParkingEndTime(timeout.substring(11));
      setParkingHours(hours);
      setParkingAmount(amount.toString());

      print("Parking data successfully saved.");

      return true;
    } catch (e) {
      print(e);
      activeParking = false;
      return false;
    }
  }

  // ===== Setters =====
  static void setParkingDate(String? date) {
    ParkingModel.parkDate = date?.trim();
  }

  static void setParkingStartTime(String? startTime) {
    ParkingModel.parkStartTime = startTime?.trim();
  }

  static void setParkingHours(int? hours) {
    ParkingModel.parkHours = hours;
  }

  static void setParkingEndTime(String? endTime) {
    ParkingModel.parkEndTime = endTime?.trim();
  }

  static void setParkingAmount(String? amount) {
    ParkingModel.parkAmount = amount?.trim();
  }

  // ===== Getters =====
  static String? getParkingDate() => ParkingModel.parkDate;
  static String? getParkingStartTime() => ParkingModel.parkStartTime;
  static int? getParkingHours() => ParkingModel.parkHours;
  static String? getParkingEndTime() => ParkingModel.parkEndTime;
  static String? getParkingAmount() => ParkingModel.parkAmount;

  // ===== Clear =====
  static void clearParkingAll() {
    ParkingModel.parkDate = null;
    ParkingModel.parkStartTime = null;
    ParkingModel.parkHours = null;
    ParkingModel.parkEndTime = null;
    ParkingModel.parkAmount = null;
    print("ParkingController: All parking data cleared.");
  }

}


class ParkingService {
  static Future<String?> callParkingExtendAPI({
    required String plate,
    required int extendHours,
    required String typePayment,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "extend_hours": extendHours,
        "transaction_type": typePayment,
      };

      final uri = Uri.parse(
        "${Config.baseUrl}/parking/$plate/${Config.terminalId}/extend",
      );

      final response = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Error: ${response.statusCode} -> ${response.body}";
      }
    } catch (e) {
      debugPrint("callParkingExtendAPI exception: $e");
      return null;
    }
  }

  static Future<String?> callParkingPayAPI({
    required String plate,
    required int timeUsed,
    required String typePayment,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "plate": plate,
        "time_used": timeUsed,
        "terminal": Config.terminalId,
        "transaction_type": typePayment,
      };

      final uri = Uri.parse("${Config.baseUrl}/parking/pay");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Error: ${response.statusCode} -> ${response.body}";
      }
    } catch (e) {
      debugPrint("callParkingPayAPI exception: $e");
      return null;
    }
  }
}

