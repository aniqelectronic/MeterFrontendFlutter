import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class SemakanSewaanBentongService {
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
  // READ RESPONSE DATA
  // ============================================================

  static void _savePaymentList(String responseBody) {
    paymentList.clear();

    final decoded = jsonDecode(responseBody);

    if (decoded is List) {
      paymentList = decoded
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      return;
    }

    if (decoded is Map && decoded['data'] is List) {
      paymentList = (decoded['data'] as List)
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    }
  }

  // ============================================================
  // SEND SIGNED GET REQUEST
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
  // SEMAKAN BAYARAN
  // ============================================================

  static Future<bool> semakanBayaran(
    String input,
  ) async {
    try {
      paymentList.clear();

      final original = input.trim();

      if (original.isEmpty) {
        return false;
      }

      final withoutS = original.replaceFirst(
        RegExp(r'^[Ss]'),
        '',
      );

      final withS = original.toUpperCase().startsWith('S')
          ? original
          : 'S$original';

      final searchValues = <String>{
        original,
        withoutS,
        withS,
      };

      for (final value in searchValues) {
        if (value.trim().isEmpty) {
          continue;
        }

        // ======================================================
        // SEARCH BY NO PENDAFTARAN
        // ======================================================

        final registrationUri = Uri.parse(
          '${Config.apiBaseUrl}'
          '/sewaan/payment-updates-sewaan-bentong/semakan',
        ).replace(
          queryParameters: {
            'no_pendaftaran': value,
          },
        );

        final registrationResponse = await _signedGet(
          registrationUri,
        );

        print(
          '[SEMAKAN SEWAAN] no_pendaftaran status: '
          '${registrationResponse.statusCode}',
        );

        print(
          '[SEMAKAN SEWAAN] no_pendaftaran body: '
          '${registrationResponse.body}',
        );

        if (registrationResponse.statusCode == 200) {
          _savePaymentList(
            registrationResponse.body,
          );

          if (paymentList.isNotEmpty) {
            print(
              '[SEMAKAN SEWAAN] Found by '
              'no_pendaftaran: $value',
            );

            return true;
          }
        }

        // ======================================================
        // SEARCH BY ACCOUNT NUMBER
        // ======================================================

        final accountUri = Uri.parse(
          '${Config.apiBaseUrl}'
          '/sewaan/payment-updates-sewaan-bentong/semakan',
        ).replace(
          queryParameters: {
            'account_number': value,
          },
        );

        final accountResponse = await _signedGet(
          accountUri,
        );

        print(
          '[SEMAKAN SEWAAN] account_number status: '
          '${accountResponse.statusCode}',
        );

        print(
          '[SEMAKAN SEWAAN] account_number body: '
          '${accountResponse.body}',
        );

        if (accountResponse.statusCode == 200) {
          _savePaymentList(
            accountResponse.body,
          );

          if (paymentList.isNotEmpty) {
            print(
              '[SEMAKAN SEWAAN] Found by '
              'account_number: $value',
            );

            return true;
          }
        }
      }

      paymentList.clear();
      return false;
    } catch (e) {
      paymentList.clear();

      print(
        '[SEMAKAN SEWAAN ERROR] $e',
      );

      return false;
    }
  }
}