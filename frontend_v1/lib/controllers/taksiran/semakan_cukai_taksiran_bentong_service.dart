import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class SemakanCukaiTaksiranBentongService {
  static const Duration _timeout = Duration(seconds: 10);

  static List<Map<String, dynamic>> paymentList = [];

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
      'X-API-Key': Config.apiKey,
      'X-Signature': signature,
    };
  }

  // ============================================================
  // SIGNED GET
  // ============================================================

  static Future<http.Response> _signedGet(Uri uri) {
    return http
        .get(
          uri,
          headers: _createHeaders(
            method: 'GET',
            uri: uri,
          ),
        )
        .timeout(_timeout);
  }

  // ============================================================
  // SAVE RESPONSE DATA
  // ============================================================

  static bool _savePaymentList(String responseBody) {
    paymentList.clear();

    final decoded = jsonDecode(responseBody);

    if (decoded is List) {
      paymentList = decoded
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      return paymentList.isNotEmpty;
    }

    if (decoded is Map && decoded['data'] is List) {
      paymentList = (decoded['data'] as List)
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      return paymentList.isNotEmpty;
    }

    return false;
  }

  // ============================================================
  // SEMAKAN BAYARAN
  // ============================================================

  static Future<bool> semakanBayaran(
    String input,
  ) async {
    try {
      paymentList.clear();

      final originalInput = input.trim();

      if (originalInput.isEmpty) {
        return false;
      }

      final withoutPrefix = originalInput.replaceFirst(
        RegExp(r'^[Tt]'),
        '',
      );

      final withPrefix =
          originalInput.toUpperCase().startsWith('T')
              ? originalInput
              : 'T$withoutPrefix';

      final endpoint = Uri.parse(
        '${Config.apiBaseUrl}'
        '/tax/payment-updates-cukaitaksiran-bentong/semakan',
      );

      final searchRequests = <Map<String, String>>[
        {
          'type': 'no_pendaftaran',
          'value': originalInput,
        },
        {
          'type': 'account_number',
          'value': originalInput,
        },
        {
          'type': 'account_number',
          'value': withPrefix,
        },
        {
          'type': 'account_number',
          'value': withoutPrefix,
        },
      ];

      final checkedRequests = <String>{};

      for (final search in searchRequests) {
        final type = search['type']!;
        final value = search['value']!.trim();

        if (value.isEmpty) {
          continue;
        }

        final requestKey = '$type:$value';

        if (checkedRequests.contains(requestKey)) {
          continue;
        }

        checkedRequests.add(requestKey);

        final uri = endpoint.replace(
          queryParameters: {
            type: value,
          },
        );

        final response = await _signedGet(uri);

        print(
          '[SEMAKAN TAKSIRAN] Search: '
          '$type=$value',
        );

        print(
          '[SEMAKAN TAKSIRAN] Status: '
          '${response.statusCode}',
        );

        print(
          '[SEMAKAN TAKSIRAN] Body: '
          '${response.body}',
        );

        if (response.statusCode == 200) {
          final found = _savePaymentList(
            response.body,
          );

          if (found) {
            print(
              '[SEMAKAN TAKSIRAN] Found by '
              '$type: $value',
            );

            return true;
          }
        }
      }

      paymentList.clear();
      return false;
    } catch (e) {
      print(
        '[SEMAKAN TAKSIRAN ERROR] $e',
      );

      paymentList.clear();
      return false;
    }
  }
}