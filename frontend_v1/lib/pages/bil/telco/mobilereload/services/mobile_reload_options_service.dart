import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/pages/data.dart';

// ============================================================================
// MOBILE RELOAD OPTION
// ============================================================================

class MobileReloadOption {
  final String code;
  final String displayName;
  final String description;

  final double priceAmount;
  final String priceCurrency;

  final bool isActive;

  final Map<String, dynamic> raw;

  const MobileReloadOption({
    required this.code,
    required this.displayName,
    required this.description,
    required this.priceAmount,
    required this.priceCurrency,
    required this.isActive,
    required this.raw,
  });

  factory MobileReloadOption.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic priceRaw =
        json['price'];

    double priceAmount = 0;
    String priceCurrency = 'MYR';

    if (priceRaw is Map) {
      final Map<String, dynamic> price =
          Map<String, dynamic>.from(
        priceRaw,
      );

      priceAmount = _toDouble(
        price['amount'] ??
            price['value'] ??
            price['price'],
      );

      final String currency =
          price['currency']
                  ?.toString()
                  .trim() ??
              '';

      if (currency.isNotEmpty) {
        priceCurrency = currency;
      }
    } else {
      priceAmount = _toDouble(
        json['price_amount'] ??
            json['amount'] ??
            json['face_value'],
      );
    }

    final String code =
        (
          json['code'] ??
          json['value'] ??
          json['subproduct_code'] ??
          json['id'] ??
          ''
        )
            .toString()
            .trim();

    final String displayName =
        (
          json['display_name'] ??
          json['name'] ??
          json['label'] ??
          code
        )
            .toString()
            .trim();

    final String description =
        json['description']
                ?.toString()
                .trim() ??
            '';

    final dynamic activeRaw =
        json['is_active'] ??
        json['active'];

    final bool isActive =
        activeRaw == null ||
        activeRaw == true ||
        activeRaw.toString().toLowerCase() ==
            'true';

    return MobileReloadOption(
      code: code,
      displayName: displayName,
      description: description,
      priceAmount: priceAmount,
      priceCurrency: priceCurrency,
      isActive: isActive,
      raw: json,
    );
  }

  static double _toDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

// ============================================================================
// RESULT
// ============================================================================

class MobileReloadOptionsResult {
  final String message;

  final List<MobileReloadOption>
      options;

  const MobileReloadOptionsResult({
    required this.message,
    required this.options,
  });
}

// ============================================================================
// EXCEPTION
// ============================================================================

class MobileReloadOptionsException
    implements Exception {
  final String message;

  const MobileReloadOptionsException(
    this.message,
  );

  @override
  String toString() => message;
}

// ============================================================================
// SERVICE
// ============================================================================

class MobileReloadOptionsService {
  MobileReloadOptionsService._();

  static const Duration _timeout =
      Duration(seconds: 30);

  static const Uuid _uuid =
      Uuid();

  static String get _optionsUrl =>
      '${Data.iimmpactBaseUrl}/v2/options';

  static String get _apiKey =>
      Data.iimmpactApiKey;

  static String get _hmacSecret =>
      Data.iimmpactHmacSecret;

  // ==========================================================================
  // GET OPTIONS
  //
  // Reference:
  //
  // /v2/options?
  // product_code=CEL&
  // field_id=plan
  //
  // Dynamic:
  //
  // /v2/options?
  // product_code=UMI&
  // field_id=plan&
  // account_number=0123456789
  //
  // ==========================================================================
  static Future<MobileReloadOptionsResult>
      getOptions({
    required String productCode,
    required String fieldId,

    String? accountNumber,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const MobileReloadOptionsException(
        'IIMMPACT API key is missing.',
      );
    }

    if (_hmacSecret.trim().isEmpty) {
      throw const MobileReloadOptionsException(
        'IIMMPACT HMAC secret is missing.',
      );
    }

    final String cleanProduct =
        productCode
            .trim()
            .toUpperCase();

    final String cleanField =
        fieldId.trim();

    final Map<String, String> query = {
      'product_code':
          cleanProduct,
      'field_id':
          cleanField,
    };

    final String cleanAccount =
        accountNumber?.trim() ?? '';

    if (cleanAccount.isNotEmpty) {
      query['account_number'] =
          cleanAccount;
    }

    final Uri uri =
        Uri.parse(
      _optionsUrl,
    ).replace(
      queryParameters: query,
    );

    final String canonicalQuery =
        _createCanonicalQuery(
      uri,
    );

    final Map<String, String> headers =
        _buildSignedHeaders(
      method: 'GET',
      body: '',
      canonicalQuery:
          canonicalQuery,
    );

    try {
      debugPrint(
        'IIMMPACT MOBILE RELOAD OPTIONS REQUEST: '
        '$uri',
      );

      final http.Response response =
          await http
              .get(
                uri,
                headers: headers,
              )
              .timeout(
                _timeout,
              );

      debugPrint(
        'IIMMPACT MOBILE RELOAD OPTIONS RESPONSE '
        '${response.statusCode}: '
        '${response.body}',
      );

      final dynamic decoded =
          jsonDecode(
        response.body,
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw MobileReloadOptionsException(
          _extractMessage(
            decoded,
            fallback:
                'Unable to retrieve Mobile Reload options.',
          ),
        );
      }

      final List<dynamic> rawItems =
          _extractOptionList(
        decoded,
      );

      final List<MobileReloadOption>
          options =
          rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    MobileReloadOption.fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              )
              .where(
                (option) =>
                    option.isActive &&
                    option.priceAmount > 0,
              )
              .toList();

      options.sort(
        (a, b) =>
            a.priceAmount.compareTo(
          b.priceAmount,
        ),
      );

      return MobileReloadOptionsResult(
        message:
            _extractMessage(
          decoded,
          fallback: '',
        ),
        options:
            options,
      );
    } on TimeoutException {
      throw const MobileReloadOptionsException(
        'The Mobile Reload options request timed out.',
      );
    } on FormatException {
      throw const MobileReloadOptionsException(
        'The Mobile Reload options response is invalid.',
      );
    } on MobileReloadOptionsException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        'Mobile Reload options error: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      throw MobileReloadOptionsException(
        'Unable to retrieve Mobile Reload options: '
        '$error',
      );
    }
  }

  // ==========================================================================
  // EXTRACT LIST
  // ==========================================================================

  static List<dynamic> _extractOptionList(
    dynamic decoded,
  ) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is! Map) {
      return const [];
    }

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(
      decoded,
    );

    for (final String key in const [
      'data',
      'options',
      'items',
      'results',
    ]) {
      final dynamic value =
          json[key];

      if (value is List) {
        return value;
      }

      if (value is Map) {
        for (final String nestedKey
            in const [
          'options',
          'items',
          'data',
          'results',
        ]) {
          final dynamic nested =
              value[nestedKey];

          if (nested is List) {
            return nested;
          }
        }
      }
    }

    return const [];
  }

  // ==========================================================================
  // HMAC
  // ==========================================================================

  static Map<String, String>
      _buildSignedHeaders({
    required String method,
    required String body,
    required String canonicalQuery,
  }) {
    final int timestamp =
        DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch ~/
            1000;

    final String nonce =
        'req-$timestamp-${_uuid.v4()}';

    final String bodyHash =
        base64Encode(
      sha256
          .convert(
            utf8.encode(
              body,
            ),
          )
          .bytes,
    );

    final String canonical =
        'v1:$timestamp:$nonce:'
        '${method.toUpperCase()}:'
        '$canonicalQuery:'
        '$bodyHash';

    final List<int> signatureBytes =
        Hmac(
      sha256,
      _decodeHmacSecret(
        _hmacSecret,
      ),
    )
            .convert(
              utf8.encode(
                canonical,
              ),
            )
            .bytes;

    return {
      'Accept':
          'application/json',
      'Content-Type':
          'application/json',
      'X-API-Key':
          _apiKey,
      'X-Timestamp':
          timestamp.toString(),
      'X-Nonce':
          nonce,
      'X-Signature':
          'v1=${base64Encode(signatureBytes)}',
    };
  }

  static String _createCanonicalQuery(
    Uri uri,
  ) {
    final List<MapEntry<String, String>>
        items = [];

    uri.queryParametersAll.forEach(
      (
        String key,
        List<String> values,
      ) {
        for (final String value
            in values) {
          items.add(
            MapEntry(
              key,
              value,
            ),
          );
        }
      },
    );

    items.sort(
      (a, b) {
        final int keyCompare =
            a.key.compareTo(
          b.key,
        );

        if (keyCompare != 0) {
          return keyCompare;
        }

        return a.value.compareTo(
          b.value,
        );
      },
    );

    return items
        .map(
          (item) =>
              '${Uri.encodeQueryComponent(item.key)}='
              '${Uri.encodeQueryComponent(item.value)}',
        )
        .join('&');
  }

  static List<int> _decodeHmacSecret(
    String secret,
  ) {
    final String normalized =
        secret.trim();

    try {
      return base64Decode(
        base64.normalize(
          normalized,
        ),
      );
    } catch (_) {
      return utf8.encode(
        normalized,
      );
    }
  }

  static String _extractMessage(
    dynamic decoded, {
    required String fallback,
  }) {
    if (decoded is Map) {
      final dynamic message =
          decoded['message'] ??
          decoded['error'] ??
          decoded['detail'];

      if (message != null &&
          message
              .toString()
              .trim()
              .isNotEmpty) {
        return message
            .toString()
            .trim();
      }
    }

    return fallback;
  }
}