import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/pages/data.dart';

class IimmpactCatalogException implements Exception {
  final String message;

  const IimmpactCatalogException(this.message);

  @override
  String toString() => message;
}

class IimmpactCatalogService {
  IimmpactCatalogService._();

  static const Duration _timeout = Duration(seconds: 30);
  static const Uuid _uuid = Uuid();

  static String get _catalogUrl =>
      '${Data.iimmpactBaseUrl}/v2/catalog';

  static String get _apiKey => Data.iimmpactApiKey;
  static String get _hmacSecret => Data.iimmpactHmacSecret;

  static Future<Map<String, dynamic>> getCatalog() async {
    if (_apiKey.trim().isEmpty) {
      throw const IimmpactCatalogException(
        'IIMMPACT API key is missing.',
      );
    }

    if (_hmacSecret.trim().isEmpty) {
      throw const IimmpactCatalogException(
        'IIMMPACT HMAC secret is missing.',
      );
    }

    final uri = Uri.parse(_catalogUrl);
    final headers = _buildSignedHeaders(
      method: 'GET',
      body: '',
    );

    try {
      debugPrint('========================================');
      debugPrint('IIMMPACT CATALOG API REQUEST');
      debugPrint('Method: GET');
      debugPrint('URL: $uri');
      debugPrint('Timestamp: ${headers['X-Timestamp']}');
      debugPrint('Nonce: ${headers['X-Nonce']}');
      debugPrint('========================================');

      final response = await http
          .get(uri, headers: headers)
          .timeout(_timeout);

      debugPrint('========================================');
      debugPrint('IIMMPACT CATALOG API RESPONSE');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('========================================');

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw IimmpactCatalogException(
          _extractErrorMessage(
            response.body,
            fallback:
                'Unable to retrieve the product catalog. '
                'Status code: ${response.statusCode}',
          ),
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw const IimmpactCatalogException(
          'The catalog response format is invalid.',
        );
      }

      return Map<String, dynamic>.from(decoded);
    } on TimeoutException {
      throw const IimmpactCatalogException(
        'The catalog request timed out.',
      );
    } on FormatException {
      throw const IimmpactCatalogException(
        'The catalog response is not valid JSON.',
      );
    } on IimmpactCatalogException {
      rethrow;
    } catch (error) {
      throw IimmpactCatalogException(
        'Unable to retrieve the product catalog: $error',
      );
    }
  }

  static Map<String, String> _buildSignedHeaders({
    required String method,
    required String body,
  }) {
    final timestamp =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final nonce = 'req-$timestamp-${_uuid.v4()}';

    final bodyHash = base64Encode(
      sha256.convert(utf8.encode(body)).bytes,
    );

    // No query parameters for GET /v2/catalog, so the
    // canonical-query section between GET and bodyHash is empty.
    final canonical =
        'v1:$timestamp:$nonce:${method.toUpperCase()}::$bodyHash';

    final secretBytes = _decodeHmacSecret(_hmacSecret);
    final signatureBytes = Hmac(
      sha256,
      secretBytes,
    ).convert(utf8.encode(canonical)).bytes;

    final signature = 'v1=${base64Encode(signatureBytes)}';

    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-API-Key': _apiKey,
      'X-Timestamp': timestamp.toString(),
      'X-Nonce': nonce,
      'X-Signature': signature,
    };
  }

  static List<int> _decodeHmacSecret(String secret) {
    final normalized = secret.trim();

    try {
      return base64Decode(base64.normalize(normalized));
    } catch (_) {
      // Fallback only in case the configured secret is plain text.
      return utf8.encode(normalized);
    }
  }

  static String _extractErrorMessage(
    String body, {
    required String fallback,
  }) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map) {
        final message = decoded['message'];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString().trim();
        }
      }
    } catch (_) {
      // Use fallback below.
    }

    return fallback;
  }
}
