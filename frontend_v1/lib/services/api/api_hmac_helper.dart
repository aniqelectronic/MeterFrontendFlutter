import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_v1/pages/config.dart';

class ApiHmacHelper {
  ApiHmacHelper._();

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
    String accept = 'application/json',
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

    debugPrint('=== API HMAC DEBUG ===');
    debugPrint('Method: ${method.toUpperCase()}');
    debugPrint('Path: ${uri.path}');
    debugPrint('Query: $canonicalQuery');
    debugPrint('Body hash: $bodyHash');
    debugPrint('Canonical string: $canonicalString');
    debugPrint('Signature: $signature');

    return {
      'Accept': accept,
      'Content-Type': 'application/json',
      'X-API-Key': Config.apiKey,
      'X-Signature': signature,
    };
  }
}