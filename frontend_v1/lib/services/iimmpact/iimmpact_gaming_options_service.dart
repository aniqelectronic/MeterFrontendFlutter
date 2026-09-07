import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/pages/data.dart';

class GamingOption {
  final String code;
  final String displayName;
  final String description;
  final double priceAmount;
  final String priceCurrency;
  final bool isActive;
  final Map<String, dynamic> raw;

  const GamingOption({
    required this.code,
    required this.displayName,
    required this.description,
    required this.priceAmount,
    required this.priceCurrency,
    required this.isActive,
    required this.raw,
  });

  factory GamingOption.fromJson(Map<String, dynamic> json) {
    final dynamic priceRaw = json['price'];
    double amount = 0;
    String currency = 'MYR';

    if (priceRaw is Map) {
      final price = Map<String, dynamic>.from(priceRaw);
      amount = _toDouble(
        price['amount'] ?? price['value'] ?? price['price'],
      );
      currency = price['currency']?.toString().trim().isNotEmpty == true
          ? price['currency'].toString().trim()
          : 'MYR';
    } else {
      amount = _toDouble(
        json['price_amount'] ?? json['amount'] ?? json['face_value'],
      );
    }

    final codeValue = (
      json['code'] ??
      json['value'] ??
      json['subproduct_code'] ??
      json['id'] ??
      ''
    ).toString().trim();

    final displayNameValue = (
      json['display_name'] ??
      json['name'] ??
      json['label'] ??
      json['description'] ??
      codeValue
    ).toString().trim();

    return GamingOption(
      code: codeValue,
      displayName: displayNameValue,
      description: (json['description'] ?? '').toString().trim(),
      priceAmount: amount,
      priceCurrency: currency,
      isActive: json['is_active'] != false,
      raw: json,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class GamingOptionsResult {
  final String message;
  final List<GamingOption> options;

  const GamingOptionsResult({
    required this.message,
    required this.options,
  });
}

class GamingOptionsException implements Exception {
  final String message;

  const GamingOptionsException(this.message);

  @override
  String toString() => message;
}

class IimmpactGamingOptionsService {
  IimmpactGamingOptionsService._();

  static const Duration _timeout = Duration(seconds: 30);
  static const Uuid _uuid = Uuid();

  static String get _optionsUrl =>
      '${Data.iimmpactBaseUrl}/v2/options';

  static String get _apiKey => Data.iimmpactApiKey;
  static String get _hmacSecret => Data.iimmpactHmacSecret;

  static Future<GamingOptionsResult> getOptions({
    required String productCode,
    required String fieldId,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const GamingOptionsException(
        'IIMMPACT API key is missing.',
      );
    }

    if (_hmacSecret.trim().isEmpty) {
      throw const GamingOptionsException(
        'IIMMPACT HMAC secret is missing.',
      );
    }

    final cleanProductCode =
        productCode.trim().toUpperCase();
    final cleanFieldId = fieldId.trim();

    final Uri uri = Uri.parse(_optionsUrl).replace(
      queryParameters: {
        'product_code': cleanProductCode,
        'field_id': cleanFieldId,
      },
    );

    final canonicalQuery = _createCanonicalQuery(uri);
    final headers = _buildSignedHeaders(
      method: 'GET',
      body: '',
      canonicalQuery: canonicalQuery,
    );

    try {
      debugPrint('IIMMPACT GAMING OPTIONS REQUEST: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(_timeout);

      debugPrint(
        'IIMMPACT GAMING OPTIONS RESPONSE '
        '${response.statusCode}: ${response.body}',
      );

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw GamingOptionsException(
          _extractMessage(
            decoded,
            fallback:
                'Unable to retrieve gaming options. '
                'Status code: ${response.statusCode}',
          ),
        );
      }

      final rawItems = _extractOptionList(decoded);

      final options = rawItems
          .whereType<Map>()
          .map(
            (item) => GamingOption.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (option) =>
                option.priceAmount > 0 &&
                option.isActive,
          )
          .toList();

      options.sort(
        (a, b) => a.priceAmount.compareTo(b.priceAmount),
      );

      return GamingOptionsResult(
        message: _extractMessage(decoded, fallback: ''),
        options: options,
      );
    } on TimeoutException {
      throw const GamingOptionsException(
        'The gaming options request timed out.',
      );
    } on FormatException {
      throw const GamingOptionsException(
        'The gaming options response is not valid JSON.',
      );
    } on GamingOptionsException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('Gaming options error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw GamingOptionsException(
        'Unable to retrieve gaming options: $error',
      );
    }
  }

  static List<dynamic> _extractOptionList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map) return const [];

    final json = Map<String, dynamic>.from(decoded);

    for (final key in const [
      'data',
      'options',
      'items',
      'results',
    ]) {
      final dynamic value = json[key];

      if (value is List) return value;

      if (value is Map) {
        for (final nestedKey in const [
          'options',
          'items',
          'data',
          'results',
        ]) {
          final dynamic nested = value[nestedKey];
          if (nested is List) return nested;
        }
      }
    }

    return const [];
  }

  static Map<String, String> _buildSignedHeaders({
    required String method,
    required String body,
    required String canonicalQuery,
  }) {
    final timestamp =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final nonce = 'req-$timestamp-${_uuid.v4()}';

    final bodyHash = base64Encode(
      sha256.convert(utf8.encode(body)).bytes,
    );

    final canonical =
        'v1:$timestamp:$nonce:${method.toUpperCase()}:'
        '$canonicalQuery:$bodyHash';

    final signatureBytes = Hmac(
      sha256,
      _decodeHmacSecret(_hmacSecret),
    ).convert(utf8.encode(canonical)).bytes;

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-API-Key': _apiKey,
      'X-Timestamp': timestamp.toString(),
      'X-Nonce': nonce,
      'X-Signature':
          'v1=${base64Encode(signatureBytes)}',
    };
  }

  static String _createCanonicalQuery(Uri uri) {
    final items = <MapEntry<String, String>>[];

    uri.queryParametersAll.forEach((key, values) {
      for (final value in values) {
        items.add(MapEntry(key, value));
      }
    });

    items.sort((a, b) {
      final keyCompare = a.key.compareTo(b.key);
      return keyCompare != 0
          ? keyCompare
          : a.value.compareTo(b.value);
    });

    return items
        .map(
          (item) =>
              '${Uri.encodeQueryComponent(item.key)}='
              '${Uri.encodeQueryComponent(item.value)}',
        )
        .join('&');
  }

  static List<int> _decodeHmacSecret(String secret) {
    final normalized = secret.trim();

    try {
      return base64Decode(base64.normalize(normalized));
    } catch (_) {
      return utf8.encode(normalized);
    }
  }

  static String _extractMessage(
    dynamic decoded, {
    required String fallback,
  }) {
    if (decoded is Map) {
      final message =
          decoded['message'] ??
          decoded['error'] ??
          decoded['detail'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
    }

    return fallback;
  }
}
