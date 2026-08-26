import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/pages/data.dart';

// ============================================================================
// PTPTN SUBPRODUCT MODEL
// ============================================================================

class PtptnSubproduct {
  final String subproductCode;
  final String displayName;
  final String description;
  final String accountNumber;

  final double? denomination;
  final double? faceValue;

  final String? validity;
  final dynamic additionalDescription;

  final String? min;
  final String? max;

  const PtptnSubproduct({
    required this.subproductCode,
    required this.displayName,
    required this.description,
    required this.accountNumber,
    required this.denomination,
    required this.faceValue,
    required this.validity,
    required this.additionalDescription,
    required this.min,
    required this.max,
  });

  factory PtptnSubproduct.fromJson(
    Map<String, dynamic> json,
  ) {
    return PtptnSubproduct(
      subproductCode:
          json['subproduct_code']
                  ?.toString()
                  .trim() ??
              '',

      displayName:
          json['display_name']
                  ?.toString()
                  .trim() ??
              '',

      description:
          json['description']
                  ?.toString()
                  .trim() ??
              '',

      accountNumber:
          json['account_number']
                  ?.toString()
                  .trim() ??
              '',

      denomination:
          _toDouble(
        json['denomination'],
      ),

      faceValue:
          _toDouble(
        json['face_value'],
      ),

      validity:
          json['validity']
              ?.toString()
              .trim(),

      additionalDescription:
          json[
              'additional_description'],

      min:
          json['min']
              ?.toString()
              .trim(),

      max:
          json['max']
              ?.toString()
              .trim(),
    );
  }

  static double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }
}

// ============================================================================
// RESULT
// ============================================================================

class PtptnSubproductResult {
  final String message;
  final List<PtptnSubproduct> products;

  const PtptnSubproductResult({
    required this.message,
    required this.products,
  });
}

// ============================================================================
// EXCEPTION
// ============================================================================

class PtptnSubproductException
    implements Exception {
  final String message;

  const PtptnSubproductException(
    this.message,
  );

  @override
  String toString() => message;
}

// ============================================================================
// SERVICE
// ============================================================================

class PtptnSubproductService {
  PtptnSubproductService._();

  static const Duration _timeout =
      Duration(
    seconds: 30,
  );

  static const Uuid _uuid =
      Uuid();

  // ==========================================================================
  // CONFIG
  // ==========================================================================

  static String get _subproductsUrl =>
      '${Data.iimmpactBaseUrl}/v2/subproducts';

  static String get _apiKey =>
      Data.iimmpactApiKey;

  static String get _hmacSecret =>
      Data.iimmpactHmacSecret;

  // ==========================================================================
  // GET PTPTN / SSPN ACCOUNTS
  // ==========================================================================

  static Future<PtptnSubproductResult>
      getAccounts({
    required String nric,
  }) async {
    // ========================================================================
    // VALIDATE CONFIG
    // ========================================================================

    if (_apiKey.trim().isEmpty) {
      throw const PtptnSubproductException(
        'IIMMPACT API key is missing.',
      );
    }

    if (_hmacSecret.trim().isEmpty) {
      throw const PtptnSubproductException(
        'IIMMPACT HMAC secret is missing.',
      );
    }

    final String cleanedNric =
        nric.trim();

    if (cleanedNric.isEmpty) {
      throw const PtptnSubproductException(
        'NRIC is required.',
      );
    }

    // ========================================================================
    // BUILD QUERY PARAMETERS
    // ========================================================================

    final Map<String, String>
        queryParameters = {
      'product_code': 'PTPTN',
      'account_number': cleanedNric,
    };

    // ========================================================================
    // BUILD REQUEST URI
    // ========================================================================

    final Uri uri =
        Uri.parse(
      _subproductsUrl,
    ).replace(
      queryParameters:
          queryParameters,
    );

    // ========================================================================
    // BUILD CANONICAL QUERY FOR HMAC
    //
    // IMPORTANT:
    //
    // Actual URL may be:
    //
    // product_code=PTPTN&account_number=000828100942
    //
    // HMAC canonical query is sorted:
    //
    // account_number=000828100942&product_code=PTPTN
    //
    // ========================================================================

    final String canonicalQuery =
        _createCanonicalQuery(
      queryParameters,
    );

    // ========================================================================
    // SIGN REQUEST
    // ========================================================================

    final Map<String, String> headers =
        _buildSignedHeaders(
      method: 'GET',
      body: '',
      canonicalQuery:
          canonicalQuery,
    );

    try {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'IIMMPACT PTPTN SUBPRODUCT REQUEST',
      );
      debugPrint(
        '========================================',
      );

      debugPrint(
        'Method: GET',
      );

      debugPrint(
        'URL: $uri',
      );

      debugPrint(
        'Product Code: PTPTN',
      );

      debugPrint(
        'NRIC: $cleanedNric',
      );

      debugPrint(
        'Canonical Query: '
        '$canonicalQuery',
      );

      debugPrint(
        'Timestamp: '
        '${headers['X-Timestamp']}',
      );

      debugPrint(
        'Nonce: '
        '${headers['X-Nonce']}',
      );

      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // SEND REQUEST
      // ======================================================================

      final http.Response response =
          await http
              .get(
        uri,
        headers: headers,
      )
              .timeout(
        _timeout,
      );

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'IIMMPACT PTPTN SUBPRODUCT RESPONSE',
      );
      debugPrint(
        '========================================',
      );

      debugPrint(
        'Status Code: '
        '${response.statusCode}',
      );

      debugPrint(
        'Body: ${response.body}',
      );

      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // DECODE RESPONSE
      // ======================================================================

      final dynamic decoded =
          jsonDecode(
        response.body,
      );

      if (decoded is! Map) {
        throw const PtptnSubproductException(
          'The PTPTN response format is invalid.',
        );
      }

      final Map<String, dynamic> json =
          Map<String, dynamic>.from(
        decoded,
      );

      final String message =
          json['message']
                  ?.toString()
                  .trim() ??
              '';

      // ======================================================================
      // HTTP ERROR
      // ======================================================================

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw PtptnSubproductException(
          message.isNotEmpty
              ? message
              : 'Unable to retrieve PTPTN accounts. '
                  'Status code: ${response.statusCode}',
        );
      }

      // ======================================================================
      // READ DATA
      // ======================================================================

      final dynamic dataRaw =
          json['data'];

      final List<PtptnSubproduct>
          products =
          <PtptnSubproduct>[];

      if (dataRaw is List) {
        for (final dynamic item
            in dataRaw) {
          if (item is Map) {
            products.add(
              PtptnSubproduct.fromJson(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            );
          }
        }
      }

      // ======================================================================
      // DEBUG PARSED ACCOUNTS
      // ======================================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'PTPTN ACCOUNTS PARSED',
      );
      debugPrint(
        '========================================',
      );

      debugPrint(
        'Message: $message',
      );

      debugPrint(
        'Total: ${products.length}',
      );

      for (final PtptnSubproduct product
          in products) {
        debugPrint(
          '----------------------------------------',
        );

        debugPrint(
          'Subproduct Code : '
          '${product.subproductCode}',
        );

        debugPrint(
          'Description     : '
          '${product.description}',
        );

        debugPrint(
          'Display Name    : '
          '${product.displayName}',
        );

        debugPrint(
          'Account Number  : '
          '${product.accountNumber}',
        );
      }

      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // IMPORTANT
      //
      // data: [] is a successful API response.
      //
      // We return an empty products list.
      //
      // PLOAN4PAGE can then do:
      //
      // if (result.products.isEmpty) {
      //   show no-account popup
      // }
      //
      // ======================================================================

      return PtptnSubproductResult(
        message: message,
        products: products,
      );
    } on TimeoutException {
      throw const PtptnSubproductException(
        'The PTPTN account request timed out.',
      );
    } on FormatException {
      throw const PtptnSubproductException(
        'The PTPTN response is not valid JSON.',
      );
    } on PtptnSubproductException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        'PTPTN subproduct request error: '
        '$error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      throw PtptnSubproductException(
        'Unable to retrieve PTPTN accounts: '
        '$error',
      );
    }
  }

  // ==========================================================================
  // BUILD SIGNED HEADERS
  // ==========================================================================

  static Map<String, String>
      _buildSignedHeaders({
    required String method,
    required String body,
    required String canonicalQuery,
  }) {
    // ========================================================================
    // TIMESTAMP
    // ========================================================================

    final int timestamp =
        DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch ~/
            1000;

    // ========================================================================
    // NONCE
    // ========================================================================

    final String nonce =
        'req-$timestamp-${_uuid.v4()}';

    // ========================================================================
    // BODY HASH
    //
    // GET request:
    //
    // body = ''
    //
    // ========================================================================

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

    // ========================================================================
    // CANONICAL STRING
    // ========================================================================
    //
    // Format:
    //
    // v1:timestamp:nonce:METHOD:canonicalQuery:bodyHash
    //
    // Example:
    //
    // v1:
    // 1787720000:
    // req-...:
    // GET:
    // account_number=000828100942&product_code=PTPTN:
    // <BODY HASH>
    //
    // ========================================================================

    final String canonical =
        'v1:'
        '$timestamp:'
        '$nonce:'
        '${method.toUpperCase()}:'
        '$canonicalQuery:'
        '$bodyHash';

    // ========================================================================
    // HMAC SECRET
    // ========================================================================

    final List<int> secretBytes =
        _decodeHmacSecret(
      _hmacSecret,
    );

    // ========================================================================
    // CREATE SIGNATURE
    // ========================================================================

    final Digest signatureDigest =
        Hmac(
      sha256,
      secretBytes,
    ).convert(
      utf8.encode(
        canonical,
      ),
    );

    final String signature =
        'v1=${base64Encode(signatureDigest.bytes)}';

    // ========================================================================
    // DEBUG
    //
    // Safe:
    // canonical query
    // timestamp
    // nonce
    //
    // Avoid printing API secret.
    // ========================================================================

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'PTPTN HMAC SIGNING',
    );
    debugPrint(
      '========================================',
    );

    debugPrint(
      'Canonical Query: '
      '$canonicalQuery',
    );

    debugPrint(
      'Canonical String: '
      '$canonical',
    );

    debugPrint(
      '========================================',
    );
    debugPrint('');

    // ========================================================================
    // HEADERS
    // ========================================================================

    return <String, String>{
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
          signature,
    };
  }

  // ==========================================================================
  // CREATE CANONICAL QUERY
  // ==========================================================================

  static String _createCanonicalQuery(
    Map<String, String>
        queryParameters,
  ) {
    final List<MapEntry<String, String>>
        entries =
        queryParameters.entries
            .toList();

    // ========================================================================
    // SORT BY KEY
    //
    // account_number
    // comes before
    // product_code
    //
    // ========================================================================

    entries.sort(
      (
        a,
        b,
      ) {
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

    // ========================================================================
    // URL ENCODE EACH KEY + VALUE
    // ========================================================================

    return entries.map(
      (
        entry,
      ) {
        final String key =
            Uri.encodeQueryComponent(
          entry.key,
        );

        final String value =
            Uri.encodeQueryComponent(
          entry.value,
        );

        return '$key=$value';
      },
    ).join(
      '&',
    );
  }

  // ==========================================================================
  // DECODE HMAC SECRET
  // ==========================================================================

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
}