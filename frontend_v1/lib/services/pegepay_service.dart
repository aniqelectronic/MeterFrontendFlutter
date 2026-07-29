import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class PegePayService {
  static const String baseUrl = Config.apiBaseUrl;

  static const String apiKey = Config.apiKey;
  static const String hmacSecret = Config.hmacSecret;

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
      final key = Uri.encodeQueryComponent(
        item.key,
      );

      final value = Uri.encodeQueryComponent(
        item.value,
      );

      return "$key=$value";
    }).join("&");
  }

  static Map<String, String> _createHeaders({
    required String method,
    required Uri uri,
    required String body,
  }) {
    final bodyHash = _createBodyHash(body);

    final canonicalQuery = _createCanonicalQuery(
      uri,
    );

    final canonicalString = [
      method.toUpperCase(),
      uri.path,
      canonicalQuery,
      bodyHash,
    ].join("\n");

    final signatureDigest = Hmac(
      sha256,
      utf8.encode(hmacSecret),
    ).convert(
      utf8.encode(canonicalString),
    );

    final signature =
        "v1=${signatureDigest.toString()}";

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-API-Key": apiKey,
      "X-Signature": signature,
    };
  }

  static Future<Map<String, dynamic>> createOrder(
    double amount,
    String storeId,
    String terminalId,
    String shiftId,
  ) async {
    final uri = Uri.parse(
      "$baseUrl/pegepay/create-order",
    );

    final body = jsonEncode({
      "order_amount": amount,
      "qr_validity": 120,
      "store_id": storeId,
      "terminal_id": terminalId,
      "shift_id": shiftId,
    });

    final response = await http.post(
      uri,
      headers: _createHeaders(
        method: "POST",
        uri: uri,
        body: body,
      ),
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to create PegePay order: "
        "${response.body}",
      );
    }

    return jsonDecode(
      response.body,
    ) as Map<String, dynamic>;
  }

  static Future<bool> checkStatus(
    String orderNo,
  ) async {
    final uri = Uri.parse(
      "$baseUrl/pegepay/check-status",
    );

    final body = jsonEncode({
      "order_no": orderNo,
    });

    final response = await http.post(
      uri,
      headers: _createHeaders(
        method: "POST",
        uri: uri,
        body: body,
      ),
      body: body,
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    final orderStatus = data["order_status"]
        .toString()
        .toLowerCase();

    return orderStatus == "successful" ||
        orderStatus == "success" ||
        orderStatus == "paid";
  }

  static Future<Map<String, dynamic>>
      checkStatusDetails(
    String orderNo,
  ) async {
    final uri = Uri.parse(
      "$baseUrl/pegepay/check-status",
    );

    final body = jsonEncode({
      "order_no": orderNo,
    });

    final response = await http.post(
      uri,
      headers: _createHeaders(
        method: "POST",
        uri: uri,
        body: body,
      ),
      body: body,
    );

    if (response.statusCode != 200) {
      return {
        "success": false,
        "order_no": orderNo,
        "bank_trx_no": "",
      };
    }

    final data = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    final orderStatus = data["order_status"]
        .toString()
        .toLowerCase();

    return {
      "success": orderStatus == "successful" ||
          orderStatus == "success" ||
          orderStatus == "paid",
      "order_no": data["order_no"] ?? orderNo,
      "bank_trx_no":
          data["bank_trx_no"] ?? "",
    };
  }
}