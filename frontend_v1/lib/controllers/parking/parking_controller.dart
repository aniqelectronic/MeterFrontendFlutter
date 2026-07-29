import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/model/parking/parking_model.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

// ============================================================
// HMAC HELPER
// ============================================================

class ParkingHmacHelper {
  ParkingHmacHelper._();

  static String _createBodyHash(String body) {
    final digest = sha256.convert(
      utf8.encode(body),
    );

    return base64Encode(digest.bytes);
  }

  static String _createCanonicalQuery(Uri uri) {
    final queryItems = <MapEntry<String, String>>[];

    uri.queryParametersAll.forEach((key, values) {
      for (final value in values) {
        queryItems.add(
          MapEntry(key, value),
        );
      }
    });

    queryItems.sort((a, b) {
      final keyCompare = a.key.compareTo(b.key);

      if (keyCompare != 0) {
        return keyCompare;
      }

      return a.value.compareTo(b.value);
    });

    return queryItems.map((item) {
      final encodedKey = Uri.encodeQueryComponent(
        item.key,
      );

      final encodedValue = Uri.encodeQueryComponent(
        item.value,
      );

      return '$encodedKey=$encodedValue';
    }).join('&');
  }

  static Map<String, String> createHeaders({
    required String method,
    required Uri uri,
    String body = '',
  }) {
    final bodyHash = _createBodyHash(body);
    final canonicalQuery = _createCanonicalQuery(uri);

    final canonicalString = [
      method.toUpperCase(),
      uri.path,
      canonicalQuery,
      bodyHash,
    ].join('\n');

    final signatureDigest = Hmac(
      sha256,
      utf8.encode(Config.hmacSecret),
    ).convert(
      utf8.encode(canonicalString),
    );

    final signature = 'v1=${signatureDigest.toString()}';

    debugPrint('=== PARKING HMAC DEBUG ===');
    debugPrint('Method: ${method.toUpperCase()}');
    debugPrint('Path: ${uri.path}');
    debugPrint('Query: $canonicalQuery');
    debugPrint('Body: $body');
    debugPrint('Body hash: $bodyHash');
    debugPrint('Canonical string: $canonicalString');
    debugPrint('Signature: $signature');

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-API-Key': Config.apiKey,
      'X-Signature': signature,
    };
  }
}

// ============================================================
// PARKING CONTROLLER
// ============================================================

class ParkingController {
  static bool activeParking = false;

  static bool isActiveParking() {
    return activeParking;
  }

  static Future<bool> checkActiveParking(
    String plate,
  ) async {
    final cleanedPlate = plate.trim();

    if (cleanedPlate.isEmpty) {
      activeParking = false;
      clearParkingAll();
      return false;
    }

    try {
      final encodedPlate = Uri.encodeComponent(
        cleanedPlate,
      );

      final uri = Uri.parse(
        '${Config.apiBaseUrl}/parking/check/$encodedPlate',
      );

      final response = await http.get(
        uri,
        headers: ParkingHmacHelper.createHeaders(
          method: 'GET',
          uri: uri,
        ),
      );

      debugPrint(
        'Parking check status: ${response.statusCode}',
      );

      debugPrint(
        'Parking check response: ${response.body}',
      );

      if (response.statusCode != 200) {
        debugPrint(
          'Plate is not active or parking is new.',
        );

        activeParking = false;
        clearParkingAll();

        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        debugPrint(
          'ParkingController: Invalid response format.',
        );

        activeParking = false;
        clearParkingAll();

        return false;
      }

      activeParking = true;

      final String timein =
          decoded['timein']?.toString() ?? '';

      final String timeout =
          decoded['timeout']?.toString() ?? '';

      final int? hours = decoded['time_used'] != null
          ? (decoded['time_used'] as num).round()
          : null;

      final double amount =
          (decoded['amount'] as num?)?.toDouble() ?? 0.0;

      if (timein.isNotEmpty) {
        final dateParts = timein.split('T');

        if (dateParts.isNotEmpty) {
          setParkingDate(dateParts.first);
        }

        if (timein.length >= 19) {
          setParkingStartTime(
            timein.substring(11),
          );
        }
      }

      if (timeout.length >= 19) {
        setParkingEndTime(
          timeout.substring(11),
        );
      }

      setParkingHours(hours);
      setParkingAmount(
        amount.toStringAsFixed(2),
      );

      debugPrint(
        'Parking data successfully saved.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'checkActiveParking exception: $e',
      );

      activeParking = false;
      clearParkingAll();

      return false;
    }
  }

  // ============================================================
  // SETTERS
  // ============================================================

  static void setParkingDate(String? date) {
    ParkingModel.parkDate = date?.trim();
  }

  static void setParkingStartTime(
    String? startTime,
  ) {
    ParkingModel.parkStartTime =
        startTime?.trim();
  }

  static void setParkingHours(int? hours) {
    ParkingModel.parkHours = hours;
  }

  static void setParkingEndTime(
    String? endTime,
  ) {
    ParkingModel.parkEndTime =
        endTime?.trim();
  }

  static void setParkingAmount(
    String? amount,
  ) {
    ParkingModel.parkAmount = amount?.trim();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  static String? getParkingDate() {
    return ParkingModel.parkDate;
  }

  static String? getParkingStartTime() {
    return ParkingModel.parkStartTime;
  }

  static int? getParkingHours() {
    return ParkingModel.parkHours;
  }

  static String? getParkingEndTime() {
    return ParkingModel.parkEndTime;
  }

  static String? getParkingAmount() {
    return ParkingModel.parkAmount;
  }

  // ============================================================
  // CLEAR
  // ============================================================

  static void clearParkingAll() {
    ParkingModel.parkDate = null;
    ParkingModel.parkStartTime = null;
    ParkingModel.parkHours = null;
    ParkingModel.parkEndTime = null;
    ParkingModel.parkAmount = null;

    debugPrint(
      'ParkingController: All parking data cleared.',
    );
  }
}

// ============================================================
// PARKING SERVICE
// ============================================================

class ParkingService {
  static const Duration _timeout = Duration(
    seconds: 15,
  );

  // ============================================================
  // EXTEND PARKING
  // ============================================================

  static Future<String?> callParkingExtendAPI({
    required String plate,
    required int extendHours,
    required String typePayment,
    String? orderNo,
    String? bankTrxNo,
  }) async {
    try {
      final encodedPlate = Uri.encodeComponent(
        plate.trim(),
      );

      final encodedTerminalId = Uri.encodeComponent(
        Config.terminalId,
      );

      final uri = Uri.parse(
        '${Config.apiBaseUrl}'
        '/parking/$encodedPlate/$encodedTerminalId/extend',
      );

      final body = jsonEncode({
        'extend_hours': extendHours,
        'transaction_type': typePayment,
        'order_no': orderNo,
        'bank_trx_no': bankTrxNo,
      });

      final response = await http
          .put(
            uri,
            headers: ParkingHmacHelper.createHeaders(
              method: 'PUT',
              uri: uri,
              body: body,
            ),
            body: body,
          )
          .timeout(_timeout);

      debugPrint(
        'Parking extend status: ${response.statusCode}',
      );

      debugPrint(
        'Parking extend response: ${response.body}',
      );

      if (response.statusCode == 200) {
        return response.body;
      }

      return 'Error: ${response.statusCode} '
          '-> ${response.body}';
    } catch (e) {
      debugPrint(
        'callParkingExtendAPI exception: $e',
      );

      return null;
    }
  }

  // ============================================================
  // PAY PARKING
  // ============================================================

  static Future<String?> callParkingPayAPI({
    required String plate,
    required int timeUsed,
    required String typePayment,
    String? orderNo,
    String? bankTrxNo,
  }) async {
    try {
      final uri = Uri.parse(
        '${Config.apiBaseUrl}/parking/pay',
      );

      final body = jsonEncode({
        'plate': plate.trim(),
        'time_used': timeUsed,
        'terminal': Config.terminalId,
        'transaction_type': typePayment,
        'order_no': orderNo,
        'bank_trx_no': bankTrxNo,
      });

      final response = await http
          .post(
            uri,
            headers: ParkingHmacHelper.createHeaders(
              method: 'POST',
              uri: uri,
              body: body,
            ),
            body: body,
          )
          .timeout(_timeout);

      debugPrint(
        'Parking pay status: ${response.statusCode}',
      );

      debugPrint(
        'Parking pay response: ${response.body}',
      );

      if (response.statusCode == 200) {
        return response.body;
      }

      return 'Error: ${response.statusCode} '
          '-> ${response.body}';
    } catch (e) {
      debugPrint(
        'callParkingPayAPI exception: $e',
      );

      return null;
    }
  }
}