import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/pages/data.dart';

// ============================================================================
// IIMMPACT PAYMENT EXCEPTION
// ============================================================================

class IimmpactPaymentException implements Exception {
  final String message;

  final int? httpStatusCode;

  final IimmpactPaymentResult? result;

  const IimmpactPaymentException(
    this.message, {
    this.httpStatusCode,
    this.result,
  });

  @override
  String toString() => message;
}

// ============================================================================
// IIMMPACT PAYMENT RESULT
// ============================================================================

class IimmpactPaymentResult {
  final int httpStatusCode;

  final int statusCode;

  final String status;

  final String account;

  final String product;

  final String productName;

  final double amount;

  /// Provider/operator serial number.
  ///
  /// Especially useful for Mobile PIN / voucher products.
  final String serialNumber;

  /// PIN/voucher code returned by provider.
  final String pin;

  /// Expiry returned by provider.
  final String expiry;

  /// Internal IIMMPACT wholesale cost.
  ///
  /// Do NOT display this to customer.
  final double cost;

  /// Internal IIMMPACT wallet balance.
  ///
  /// Do NOT display this to customer.
  final double balance;

  final String remarks;

  final String refId;

  final String timestamp;

  final String note;

  final String voucherLink;

  const IimmpactPaymentResult({
    required this.httpStatusCode,
    required this.statusCode,
    required this.status,
    required this.account,
    required this.product,
    required this.productName,
    required this.amount,
    required this.serialNumber,
    required this.pin,
    required this.expiry,
    required this.cost,
    required this.balance,
    required this.remarks,
    required this.refId,
    required this.timestamp,
    required this.note,
    required this.voucherLink,
  });

  // ==========================================================================
  // STATUS HELPERS
  // ==========================================================================

  /// IMPORTANT:
  ///
  /// IIMMPACT intentionally returns:
  ///
  /// Succesful
  ///
  /// NOT:
  ///
  /// Successful
  bool get isSuccessful =>
      status == 'Succesful';

  bool get isPending =>
      status == 'Accepted' ||
      status == 'Processing';

  bool get isFailed =>
      status == 'Failed';

  bool get isRefund =>
      status == 'Refund';

  bool get isFinal =>
      isSuccessful ||
      isFailed ||
      isRefund;

  // ==========================================================================
  // RESPONSE PARSER
  // ==========================================================================

  factory IimmpactPaymentResult.fromResponse({
    required int httpStatusCode,
    required Map<String, dynamic> json,
  }) {
    final dynamic rawData =
        json['data'];

    final Map<String, dynamic> data =
        rawData is Map
            ? Map<String, dynamic>.from(
                rawData,
              )
            : <String, dynamic>{};

    return IimmpactPaymentResult(
      httpStatusCode:
          httpStatusCode,

      statusCode:
          _parseInt(
        data['statusCode'],
      ),

      status:
          _parseString(
        data['status'],
      ),

      account:
          _parseString(
        data['account'],
      ),

      product:
          _parseString(
        data['product'],
      ),

      productName:
          _parseString(
        data['productName'],
      ),

      amount:
          _parseDouble(
        data['amount'],
      ),

      serialNumber:
          _parseString(
        data['sn'],
      ),

      pin:
          _parseString(
        data['pin'],
      ),

      expiry:
          _parseString(
        data['expiry'],
      ),

      cost:
          _parseDouble(
        data['cost'],
      ),

      balance:
          _parseDouble(
        data['balance'],
      ),

      remarks:
          _parseString(
        data['remarks'],
      ),

      refId:
          _parseString(
        data['refid'],
      ),

      timestamp:
          _parseString(
        data['timestamp'],
      ),

      note:
          _parseString(
        data['note'],
      ),

      voucherLink:
          _parseString(
        data['voucherlink'],
      ),
    );
  }

  // ==========================================================================
  // PARSERS
  // ==========================================================================

  static String _parseString(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value
        .toString()
        .trim();
  }

  static int _parseInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _parseDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }
}

// ============================================================================
// IIMMPACT PAYMENT SERVICE
// ============================================================================
//
// Endpoint:
//
// POST /v2/topup
//
// Used for:
//
// - Electric bill
// - Water bill
// - Broadband
// - Entertainment
// - Telco Postpaid
// - Mobile PIN
// - Other supported IIMMPACT products
//
// ============================================================================
//
// IDEMPOTENCY:
//
// The SAME refid must be reused when checking transaction status.
//
// Accepted / Processing
//        ↓
// call /v2/topup again
//        ↓
// SAME:
//
// refid
// product
// account
// amount
// remarks
// extras
//
// ============================================================================

class IimmpactPaymentService {
  IimmpactPaymentService._();

  static const Duration _timeout =
      Duration(seconds: 30);

  static const Uuid _uuid =
      Uuid();

  static String get _paymentUrl =>
      '${Data.iimmpactBaseUrl}/v2/topup';

  // ==========================================================================
  // MAKE PAYMENT
  // ==========================================================================

  static Future<IimmpactPaymentResult> pay({
    required String refId,
    required String product,
    required String account,
    required double amount,

    String remarks = '',

    Map<String, dynamic> extras =
        const <String, dynamic>{},
  }) async {
    final String cleanRefId =
        refId.trim();

    final String cleanProduct =
        product
            .trim()
            .toUpperCase();

    final String cleanAccount =
        account.trim();

    // ========================================================================
    // BASIC VALIDATION
    // ========================================================================

    if (cleanRefId.isEmpty) {
      throw const IimmpactPaymentException(
        'IIMMPACT refid is required.',
      );
    }

    if (cleanRefId.length > 50) {
      throw const IimmpactPaymentException(
        'IIMMPACT refid must not exceed 50 characters.',
      );
    }

    if (cleanProduct.isEmpty) {
      throw const IimmpactPaymentException(
        'IIMMPACT product code is required.',
      );
    }

    if (cleanAccount.isEmpty) {
      throw const IimmpactPaymentException(
        'IIMMPACT account is required.',
      );
    }

    if (amount <= 0) {
      throw const IimmpactPaymentException(
        'IIMMPACT payment amount must be greater than zero.',
      );
    }

    // ========================================================================
    // REQUEST BODY
    // ========================================================================
    //
    // IMPORTANT:
    //
    // This exact JSON string is used for BOTH:
    //
    // 1. Body SHA-256 hash
    // 2. HTTP request body
    //
    // Never hash one JSON representation and send another representation.
    //
    // ========================================================================

    final Map<String, dynamic> body =
        <String, dynamic>{
      'refid':
          cleanRefId,

      'product':
          cleanProduct,

      'account':
          cleanAccount,

      'amount':
          amount,

      'remarks':
          remarks,

      'extras':
          extras,
    };

    return _post(
      body,
    );
  }

  // ==========================================================================
  // PAY AND WAIT FOR FINAL STATUS
  // ==========================================================================

  static Future<IimmpactPaymentResult>
      waitForFinalStatus({
    required String refId,
    required String product,
    required String account,
    required double amount,

    String remarks = '',

    Map<String, dynamic> extras =
        const <String, dynamic>{},

    Duration interval =
        const Duration(seconds: 6),

    int maxAttempts = 10,
  }) async {
    if (maxAttempts < 1) {
      throw const IimmpactPaymentException(
        'maxAttempts must be at least 1.',
      );
    }

    // ========================================================================
    // FIRST ATTEMPT
    // ========================================================================

    IimmpactPaymentResult result =
        await pay(
      refId:
          refId,

      product:
          product,

      account:
          account,

      amount:
          amount,

      remarks:
          remarks,

      extras:
          extras,
    );

    debugPrint(
      '[IimmpactPaymentService] '
      'Attempt 1/$maxAttempts '
      'status=${result.status}',
    );

    if (!result.isPending) {
      return result;
    }

    // ========================================================================
    // POLLING
    // ========================================================================
    //
    // IMPORTANT:
    //
    // Do NOT generate a new refid.
    //
    // Re-send the exact same transaction parameters.
    //
    // ========================================================================

    for (
      int attempt = 2;
      attempt <= maxAttempts;
      attempt++
    ) {
      await Future<void>.delayed(
        interval,
      );

      debugPrint(
        '[IimmpactPaymentService] '
        'Polling transaction '
        '$attempt/$maxAttempts '
        'refid=$refId',
      );

      result =
          await pay(
        refId:
            refId,

        product:
            product,

        account:
            account,

        amount:
            amount,

        remarks:
            remarks,

        extras:
            extras,
      );

      debugPrint(
        '[IimmpactPaymentService] '
        'Attempt $attempt/$maxAttempts '
        'status=${result.status}',
      );

      if (!result.isPending) {
        return result;
      }
    }

    // Still Accepted/Processing after max attempts.
    return result;
  }

  // ==========================================================================
  // BUILD SORTED QUERY
  // ==========================================================================

  static String _buildSortedQuery(
    Uri uri,
  ) {
    final List<MapEntry<String, String>>
        items =
        <MapEntry<String, String>>[];

    uri.queryParametersAll.forEach(
      (
        String key,
        List<String> values,
      ) {
        for (final String value
            in values) {
          items.add(
            MapEntry<String, String>(
              key,
              value,
            ),
          );
        }
      },
    );

    items.sort(
      (
        MapEntry<String, String> left,
        MapEntry<String, String> right,
      ) {
        final int keyComparison =
            left.key.compareTo(
          right.key,
        );

        if (keyComparison != 0) {
          return keyComparison;
        }

        return left.value.compareTo(
          right.value,
        );
      },
    );

    return items
        .map(
          (
            MapEntry<String, String>
                item,
          ) =>
              '${item.key}=${item.value}',
        )
        .join('&');
  }

  // ==========================================================================
  // NORMALIZE BASE64
  // ==========================================================================

  static String _normalizeBase64(
    String value,
  ) {
    String normalized =
        value
            .trim()
            .replaceAll(
              '-',
              '+',
            )
            .replaceAll(
              '_',
              '/',
            )
            .replaceAll(
              RegExp(r'\s+'),
              '',
            );

    while (
        normalized.length % 4 !=
            0) {
      normalized += '=';
    }

    return normalized;
  }

  // ==========================================================================
  // POST /v2/topup
  // ==========================================================================

  static Future<IimmpactPaymentResult> _post(
    Map<String, dynamic> body,
  ) async {
    final Uri uri =
        Uri.parse(
      _paymentUrl,
    );

    // ========================================================================
    // EXACT REQUEST BODY
    // ========================================================================

    final String requestBody =
        jsonEncode(
      body,
    );

    // ========================================================================
    // TIMESTAMP
    //
    // Unix time in seconds.
    // ========================================================================

    final String timestamp =
        (
          DateTime.now()
                  .millisecondsSinceEpoch ~/
              1000
        ).toString();

    // ========================================================================
    // NONCE
    // ========================================================================
    //
    // Unique for each HTTP request.
    //
    // IMPORTANT:
    //
    // refid stays the same during polling.
    //
    // nonce should be NEW for each HTTP request.
    //
    // ========================================================================

    final String nonce =
        _uuid
            .v4()
            .toLowerCase();

    // ========================================================================
    // BODY HASH
    //
    // SHA256(raw JSON string)
    //        ↓
    // Base64
    // ========================================================================

    final Digest bodyDigest =
        sha256.convert(
      utf8.encode(
        requestBody,
      ),
    );

    final String bodyHash =
        base64Encode(
      bodyDigest.bytes,
    );

    // ========================================================================
    // SORT QUERY PARAMETERS
    // ========================================================================
    //
    // /v2/topup currently has no query parameters.
    //
    // Therefore normally:
    //
    // sortedQuery = ""
    //
    // ========================================================================

    final String sortedQuery =
        _buildSortedQuery(
      uri,
    );

    // ========================================================================
    // IIMMPACT CANONICAL STRING
    // ========================================================================
    //
    // REQUIRED FORMAT:
    //
    // v1:timestamp:nonce:method:sortedQuery:bodyHash
    //
    // Example:
    //
    // v1:1776221361:
    // uuid:
    // POST:
    // :
    // ABCDEF==
    //
    // Joined into one line:
    //
    // v1:1776221361:uuid:POST::ABCDEF==
    //
    // IMPORTANT:
    //
    // uri.path is NOT included here.
    //
    // ========================================================================

    final String canonicalString =
        'v1:'
        '$timestamp:'
        '$nonce:'
        'POST:'
        '$sortedQuery:'
        '$bodyHash';

    // ========================================================================
    // HMAC SECRET
    // ========================================================================
    //
    // IMPORTANT:
    //
    // Data.iimmpactHmacSecret is Base64 encoded.
    //
    // WRONG:
    //
    // utf8.encode(Data.iimmpactHmacSecret)
    //
    // CORRECT:
    //
    // base64Decode(Data.iimmpactHmacSecret)
    //
    // ========================================================================

    late final List<int> secretBytes;

    try {
      secretBytes =
          base64Decode(
        _normalizeBase64(
          Data.iimmpactHmacSecret,
        ),
      );
    } on FormatException {
      throw const IimmpactPaymentException(
        'The IIMMPACT HMAC secret is not valid Base64.',
      );
    }

    // ========================================================================
    // HMAC SHA256
    // ========================================================================

    final Digest signatureDigest =
        Hmac(
      sha256,
      secretBytes,
    ).convert(
      utf8.encode(
        canonicalString,
      ),
    );

    // ========================================================================
    // SIGNATURE
    // ========================================================================
    //
    // IMPORTANT:
    //
    // IIMMPACT expects:
    //
    // Base64(HMAC-SHA256)
    //
    // NOT hexadecimal.
    //
    // ========================================================================

    final String signature =
        base64Encode(
      signatureDigest.bytes,
    );

    // ========================================================================
    // HEADERS
    // ========================================================================

    final Map<String, String> headers =
        <String, String>{
      HttpHeaders.acceptHeader:
          'application/json',

      HttpHeaders.contentTypeHeader:
          'application/json',

      'X-Api-Key':
          Data.iimmpactApiKey.trim(),

      'X-Timestamp':
          timestamp,

      'X-Nonce':
          nonce,

      'X-Signature':
          'v1=$signature',

      // Optional IIMMPACT API version can be added later if required:
      //
      // 'X-API-Version':
      //     '2026-04-01',
    };

    // ========================================================================
    // DEBUG
    // ========================================================================

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'IIMMPACT PAYMENT REQUEST',
    );
    debugPrint(
      '========================================',
    );

    debugPrint(
      'Method    : POST',
    );

    debugPrint(
      'URL       : $_paymentUrl',
    );

    debugPrint(
      'Path      : ${uri.path}',
    );

    debugPrint(
      'Query     : $sortedQuery',
    );

    debugPrint(
      'Timestamp : $timestamp',
    );

    debugPrint(
      'Nonce     : $nonce',
    );

    debugPrint(
      'Body      : $requestBody',
    );

    debugPrint(
      'Body Hash : $bodyHash',
    );

    debugPrint(
      'Canonical : $canonicalString',
    );

    // TEMPORARY DEBUG.
    //
    // Safe enough while testing signature generation,
    // but remove this line for production logging.
    debugPrint(
      'Signature : v1=$signature',
    );

    // NEVER print:
    //
    // Data.iimmpactApiKey
    // Data.iimmpactHmacSecret

    debugPrint(
      '========================================',
    );
    debugPrint('');

    // ========================================================================
    // SEND REQUEST
    // ========================================================================

    try {
      final http.Response response =
          await http
              .post(
                uri,
                headers:
                    headers,
                body:
                    requestBody,
              )
              .timeout(
                _timeout,
              );

      // ======================================================================
      // RESPONSE DEBUG
      // ======================================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'IIMMPACT PAYMENT RESPONSE',
      );
      debugPrint(
        '========================================',
      );

      debugPrint(
        'HTTP : ${response.statusCode}',
      );

      debugPrint(
        'Body : ${response.body}',
      );

      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // JSON DECODE
      // ======================================================================

      Map<String, dynamic> json =
          <String, dynamic>{};

      try {
        final dynamic decoded =
            jsonDecode(
          response.body,
        );

        if (decoded is Map) {
          json =
              Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (error, stackTrace) {
        debugPrint(
          '[IimmpactPaymentService] '
          'Response JSON decode failed: '
          '$error',
        );
        debugPrint(
          '[IimmpactPaymentService] '
          'Stack trace: '
          '$stackTrace',
        );
      }

      // ======================================================================
      // BUILD RESULT
      // ======================================================================

      final IimmpactPaymentResult result =
          IimmpactPaymentResult
              .fromResponse(
        httpStatusCode:
            response.statusCode,

        json:
            json,
      );

      // ======================================================================
      // HTTP 200
      // ======================================================================
      //
      // Possible statuses:
      //
      // Accepted
      // Processing
      // Succesful
      // Failed
      // Refund
      //
      // ======================================================================

      if (response.statusCode == 200) {
        return result;
      }

      // ======================================================================
      // HTTP 400
      // ======================================================================
      //
      // Validation error.
      //
      // According to IIMMPACT:
      //
      // - transaction NOT created
      // - refid NOT consumed
      // - same refid can be reused after fixing input
      //
      // Examples:
      //
      // Invalid_Denomination
      // Insufficient_Balance
      // invalid account
      // invalid product
      //
      // ======================================================================

      if (response.statusCode == 400) {
        String errorMessage =
            result.remarks;

        if (errorMessage.isEmpty) {
          errorMessage =
              _extractApiErrorMessage(
            json,
          );
        }

        if (errorMessage.isEmpty) {
          errorMessage =
              'IIMMPACT validation failed.';
        }

        throw IimmpactPaymentException(
          errorMessage,
          httpStatusCode:
              response.statusCode,
          result:
              result,
        );
      }

      // ======================================================================
      // HTTP 401
      // ======================================================================

      if (response.statusCode == 401) {
        final String apiMessage =
            _extractApiErrorMessage(
          json,
        );

        throw IimmpactPaymentException(
          apiMessage.isNotEmpty
              ? 'IIMMPACT authentication failed: '
                  '$apiMessage'
              : 'IIMMPACT authentication failed.',
          httpStatusCode:
              response.statusCode,
          result:
              result,
        );
      }

      // ======================================================================
      // HTTP 403
      // ======================================================================

      if (response.statusCode == 403) {
        final String apiMessage =
            _extractApiErrorMessage(
          json,
        );

        throw IimmpactPaymentException(
          apiMessage.isNotEmpty
              ? 'IIMMPACT request forbidden: '
                  '$apiMessage'
              : 'IIMMPACT request forbidden.',
          httpStatusCode:
              response.statusCode,
          result:
              result,
        );
      }

      // ======================================================================
      // OTHER HTTP ERROR
      // ======================================================================

      final String apiMessage =
          _extractApiErrorMessage(
        json,
      );

      throw IimmpactPaymentException(
        apiMessage.isNotEmpty
            ? 'IIMMPACT payment failed '
                'with HTTP ${response.statusCode}: '
                '$apiMessage'
            : 'IIMMPACT payment failed '
                'with HTTP ${response.statusCode}.',
        httpStatusCode:
            response.statusCode,
        result:
            result,
      );
    } on TimeoutException {
      // ======================================================================
      // IMPORTANT
      //
      // A timeout does NOT necessarily mean IIMMPACT did not receive
      // the transaction.
      //
      // Because refid is idempotent, the correct recovery is to query
      // again using the SAME request + SAME refid.
      //
      // Do NOT create a new payment refid automatically.
      // ======================================================================

      throw const IimmpactPaymentException(
        'IIMMPACT payment request timed out. '
        'The transaction status should be checked again '
        'using the same refid.',
      );
    } on SocketException {
      throw const IimmpactPaymentException(
        'Unable to connect to IIMMPACT.',
      );
    } on IimmpactPaymentException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        '[IimmpactPaymentService] '
        'Unexpected error: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      throw IimmpactPaymentException(
        'Unexpected IIMMPACT error: '
        '$error',
      );
    }
  }

  // ==========================================================================
  // EXTRACT API ERROR MESSAGE
  // ==========================================================================

  static String _extractApiErrorMessage(
    Map<String, dynamic> json,
  ) {
    final String message =
        json['message']
                ?.toString()
                .trim() ??
            '';

    if (message.isNotEmpty) {
      return message;
    }

    final String error =
        json['error']
                ?.toString()
                .trim() ??
            '';

    if (error.isNotEmpty) {
      return error;
    }

    final dynamic data =
        json['data'];

    if (data is Map) {
      final String remarks =
          data['remarks']
                  ?.toString()
                  .trim() ??
              '';

      if (remarks.isNotEmpty) {
        return remarks;
      }
    }

    return '';
  }
}