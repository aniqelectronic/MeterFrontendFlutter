import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/model/tax/tax_model.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class TaxService {
  static const String baseUrl = Config.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 10);

  // ============================================================
  // HMAC HELPERS
  // ============================================================

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

  static Map<String, String> _createHeaders({
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

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-API-Key': Config.apiKey,
      'X-Signature': signature,
    };
  }

  // ============================================================
  // FETCH TAXES BY IC
  // ============================================================

  static Future<List<TaxModel>> getTaxesByIC(
    String ic,
  ) async {
    final cleanedIc = ic.trim();

    if (cleanedIc.isEmpty) {
      return [];
    }

    final encodedIc = Uri.encodeComponent(cleanedIc);

    final uri = Uri.parse(
      '$baseUrl/tax/by-ic/$encodedIc',
    );

    try {
      final response = await http
          .get(
            uri,
            headers: _createHeaders(
              method: 'GET',
              uri: uri,
            ),
          )
          .timeout(_timeout);

      print(
        'TaxService getTaxesByIC status: '
        '${response.statusCode}',
      );

      print(
        'TaxService getTaxesByIC body: '
        '${response.body}',
      );

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        print(
          'TaxService: Expected a JSON list.',
        );

        return [];
      }

      if (decoded.isEmpty) {
        return [];
      }

      return decoded
          .map(
            (item) => TaxModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (e) {
      print(
        'TaxService getTaxesByIC exception: $e',
      );

      return [];
    }
  }

  // ============================================================
  // PAY MULTIPLE TAXES
  // ============================================================

  static Future<bool> payMultipleTaxes(
    List<String> billNos,
  ) async {
    if (billNos.isEmpty) {
      return false;
    }

    final uri = Uri.parse(
      '$baseUrl/tax/pay/multi',
    );

    final body = jsonEncode({
      'bill_no': billNos,
    });

    try {
      final response = await http
          .post(
            uri,
            headers: _createHeaders(
              method: 'POST',
              uri: uri,
              body: body,
            ),
            body: body,
          )
          .timeout(_timeout);

      print(
        'TaxService payMultipleTaxes status: '
        '${response.statusCode}',
      );

      print(
        'TaxService payMultipleTaxes body: '
        '${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print(
        'TaxService payMultipleTaxes exception: $e',
      );

      return false;
    }
  }
}