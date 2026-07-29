import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/model/license/license_model.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class LicenseService {
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
  // FETCH LICENSES BY IC
  // ============================================================

  static Future<List<LicenseModel>> getLicensesByIC(
    String ic,
  ) async {
    final cleanedIc = ic.trim();

    if (cleanedIc.isEmpty) {
      return [];
    }

    try {
      final encodedIc = Uri.encodeComponent(cleanedIc);

      final uri = Uri.parse(
        '${Config.apiBaseUrl}/license/by-ic/$encodedIc',
      );

      final response = await http
          .get(
            uri,
            headers: _createHeaders(
              method: 'GET',
              uri: uri,
            ),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        print(
          'LicenseService getLicensesByIC error: '
          '${response.statusCode}',
        );
        print(
          'LicenseService response: ${response.body}',
        );

        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        print(
          'LicenseService: Expected a JSON list.',
        );
        return [];
      }

      if (decoded.isEmpty) {
        return [];
      }

      final licenses = decoded
          .map(
            (item) => LicenseModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();

      double total = 0;

      for (final license in licenses) {
        total += license.amount;
      }

      LicenseModel.setTotalAmount(total);

      return licenses;
    } catch (e) {
      print(
        'LicenseService getLicensesByIC exception: $e',
      );

      return [];
    }
  }

  // ============================================================
  // PAY MULTIPLE LICENSES
  // ============================================================

  static Future<bool> payMultipleLicenses(
    List<String> licenseNos,
  ) async {
    if (licenseNos.isEmpty) {
      return false;
    }

    final uri = Uri.parse(
      '${Config.apiBaseUrl}/license/pay-multi',
    );

    final body = jsonEncode({
      'licenses': licenseNos,
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
        'LicenseService payMultipleLicenses status: '
        '${response.statusCode}',
      );

      print(
        'LicenseService payMultipleLicenses body: '
        '${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      print(
        'LicenseService payMultipleLicenses exception: $e',
      );

      return false;
    }
  }

  // ============================================================
  // SELECTED LICENSES
  // ============================================================

  static final List<String> _selectedLicenses = [];

  static void setSelectedLicenses(
    List<String> licenses,
  ) {
    _selectedLicenses
      ..clear()
      ..addAll(licenses);
  }

  static List<String> getSelectedLicenses() {
    return List<String>.from(
      _selectedLicenses,
    );
  }
}