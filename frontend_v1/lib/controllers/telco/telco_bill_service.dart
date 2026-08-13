import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/controllers/telco/telco_bill_exception.dart';
import 'package:frontend_v1/controllers/telco/telco_bill_inquiry_result.dart';
import 'package:frontend_v1/model/telco/telco_bill_model.dart';
import 'package:frontend_v1/pages/data.dart';

class TelcoBillService {
  TelcoBillService._();

  static const Duration _timeout =
      Duration(seconds: 30);

  static const Uuid _uuid = Uuid();

  // ============================================================
  // API
  // ============================================================

  static String get _inquiryUrl =>
      '${Data.iimmpactBaseUrl}/v2/bill-presentment';

  static String get _apiKey =>
      Data.iimmpactApiKey;

  static String get _hmacSecret =>
      Data.iimmpactHmacSecret;

  // ============================================================
  // TELCO POSTPAID INQUIRY
  // ============================================================

  static Future<TelcoBillInquiryResult>
      inquiryBill({
    required String productCode,
    required String accountNumber,
  }) async {
    final String normalizedProductCode =
        productCode.trim().toUpperCase();

    final String normalizedAccountNumber =
        accountNumber.trim();

    if (normalizedProductCode.isEmpty) {
      return TelcoBillInquiryResult.failure(
        message: 'Product code is required.',
      );
    }

    if (normalizedAccountNumber.isEmpty) {
      return TelcoBillInquiryResult.failure(
        message: 'Account number is required.',
      );
    }

    if (_apiKey.trim().isEmpty) {
      throw const TelcoBillException(
        message:
            'IIMMPACT API key is missing.',
      );
    }

    if (_hmacSecret.trim().isEmpty) {
      throw const TelcoBillException(
        message:
            'IIMMPACT HMAC secret is missing.',
      );
    }

    final Map<String, String>
        queryParameters = {
      'product': normalizedProductCode,
      'account': normalizedAccountNumber,
    };

    final Uri uri =
        Uri.parse(_inquiryUrl).replace(
      queryParameters: queryParameters,
    );

    try {
      final Map<String, String>
          signedHeaders =
          _buildSignedHeaders(
        method: 'GET',
        queryParameters: queryParameters,
        body: '',
      );

      debugPrint(
        '========================================',
      );

      debugPrint(
        'TELCO POSTPAID API REQUEST',
      );

      debugPrint('URL: $uri');

      debugPrint(
        'Product: $normalizedProductCode',
      );

      debugPrint(
        'Account: $normalizedAccountNumber',
      );

      debugPrint(
        '========================================',
      );

      final http.Response response =
          await http
              .get(
                uri,
                headers: signedHeaders,
              )
              .timeout(_timeout);

      debugPrint(
        '========================================',
      );

      debugPrint(
        'TELCO POSTPAID API RESPONSE',
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );

      debugPrint(
        'Body: ${response.body}',
      );

      debugPrint(
        '========================================',
      );

      final Map<String, dynamic> decoded =
          _decodeResponse(
        response.body,
      );

      // ========================================================
      // HTTP ERROR
      // Example:
      // 400 Invalid account no
      // ========================================================

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final String message =
            _extractMessage(
          decoded,
          fallback:
              'Inquiry failed. HTTP '
              '${response.statusCode}.',
        );

        return TelcoBillInquiryResult.failure(
          message: message,
        );
      }

      final TelcoBillModel bill =
          TelcoBillModel.fromApi(
        productCode:
            normalizedProductCode,
        accountNumber:
            normalizedAccountNumber,
        response: decoded,
      );

      final String responseMessage =
          _extractMessage(
        decoded,
        fallback: bill.message,
      );

      if (!bill.success) {
        return TelcoBillInquiryResult.failure(
          message:
              responseMessage.isNotEmpty
                  ? responseMessage
                  : 'Invalid account no',
        );
      }

      return TelcoBillInquiryResult.success(
        bill: bill,
        message: responseMessage,
      );
    } on TimeoutException {
      throw const TelcoBillException(
        message:
            'The inquiry took too long. Please try again.',
      );
    } on SocketException {
      throw const TelcoBillException(
        message:
            'Unable to connect to the bill inquiry service.',
      );
    } on FormatException catch (error) {
      throw TelcoBillException(
        message:
            'The server returned an invalid response: '
            '$error',
      );
    } on TelcoBillException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected Telco inquiry error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      throw TelcoBillException(
        message:
            'Telco bill inquiry failed: $error',
      );
    }
  }

  // ============================================================
  // HMAC
  // ============================================================

  static Map<String, String>
      _buildSignedHeaders({
    required String method,
    required Map<String, String>
        queryParameters,
    required String body,
  }) {
    final String timestamp =
        (DateTime.now()
                    .millisecondsSinceEpoch ~/
                1000)
            .toString();

    final String nonce =
        'req-$timestamp-'
        '${_uuid.v4().toLowerCase()}';

    final String normalizedMethod =
        method.trim().toUpperCase();

    final String bodyHash =
        base64Encode(
      sha256
          .convert(
            utf8.encode(body),
          )
          .bytes,
    );

    final String sortedQuery =
        _buildSortedQuery(
      queryParameters,
    );

    final String canonical =
        'v1:$timestamp:$nonce:'
        '$normalizedMethod:'
        '$sortedQuery:$bodyHash';

    late final List<int> secretBytes;

    try {
      secretBytes =
          base64Decode(
        _normalizeBase64(
          _hmacSecret.trim(),
        ),
      );
    } on FormatException {
      throw const TelcoBillException(
        message:
            'The IIMMPACT HMAC secret '
            'is not valid Base64.',
      );
    }

    final Hmac hmac =
        Hmac(
      sha256,
      secretBytes,
    );

    final Digest signatureDigest =
        hmac.convert(
      utf8.encode(canonical),
    );

    final String signature =
        base64Encode(
      signatureDigest.bytes,
    );

    return <String, String>{
      HttpHeaders.acceptHeader:
          'application/json',
      'X-Api-Key': _apiKey.trim(),
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': 'v1=$signature',
    };
  }

  // ============================================================
  // SORT QUERY
  // ============================================================

  static String _buildSortedQuery(
    Map<String, String> queryParameters,
  ) {
    final entries =
        queryParameters.entries.toList()
          ..sort(
            (a, b) =>
                a.key.compareTo(b.key),
          );

    return entries
        .map(
          (entry) =>
              '${entry.key}='
              '${entry.value}',
        )
        .join('&');
  }

  // ============================================================
  // BASE64
  // ============================================================

  static String _normalizeBase64(
    String value,
  ) {
    var normalized = value
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll(' ', '');

    final int remainder =
        normalized.length % 4;

    if (remainder != 0) {
      normalized +=
          '=' * (4 - remainder);
    }

    return normalized;
  }

  // ============================================================
  // JSON
  // ============================================================

  static Map<String, dynamic>
      _decodeResponse(
    String body,
  ) {
    if (body.trim().isEmpty) {
      throw const FormatException(
        'API response was empty.',
      );
    }

    final dynamic decoded =
        jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(
        decoded,
      );
    }

    throw const FormatException(
      'API response is not a JSON object.',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  static String _extractMessage(
    Map<String, dynamic> response, {
    required String fallback,
  }) {
    final List<dynamic> messages = [
      response['error_message'],
      response['transaction_message'],
      response['message'],
    ];

    final dynamic rawData =
        response['data'];

    if (rawData is Map) {
      messages.add(
        rawData['message'],
      );
    }

    for (final dynamic value
        in messages) {
      if (value == null) {
        continue;
      }

      final String text =
          value.toString().trim();

      if (text.isNotEmpty &&
          text.toLowerCase() !=
              'null') {
        return text;
      }
    }

    return fallback;
  }
}