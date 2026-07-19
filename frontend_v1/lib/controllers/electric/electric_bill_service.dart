import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/controllers/electric/electric_bill_exception.dart';
import 'package:frontend_v1/controllers/electric/electric_bill_inquiry_result.dart';
import 'package:frontend_v1/model/electric/electric_bill_model.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';

class ElectricBillService {
  ElectricBillService._();

  static const Duration _timeout = Duration(seconds: 30);

  static const Uuid _uuid = Uuid();

  // =========================================================
  // API CONFIGURATION
  // =========================================================

  static String get _electricInquiryUrl =>
      '${Data.iimmpactBaseUrl}/v2/bill-presentment';

  /*
   * These must match the Postman environment or collection variables:
   *
   * apiKey
   * hmacSecret
   *
   * hmacSecret must remain in its original Base64 format.
   */
  static String get _apiKey => Data.iimmpactApiKey;

  static String get _hmacSecret => Data.iimmpactHmacSecret;

  // =========================================================
  // BILL INQUIRY
  // =========================================================

  static Future<ElectricBillInquiryResult> inquiryBill({
    required String productCode,
    required String billerName,
    required String accountNumber,
    required AppLocalizations loc,
  }) async {
    final normalizedProductCode =
        productCode.trim().toUpperCase();

    final normalizedAccountNumber =
        accountNumber.trim();

    if (normalizedProductCode.isEmpty) {
      return ElectricBillInquiryResult.failure(
        message: loc.electricProductCodeRequired,
      );
    }

    if (normalizedAccountNumber.isEmpty) {
      return ElectricBillInquiryResult.failure(
        message: loc.electricAccountNumberRequired,
      );
    }

    if (_apiKey.trim().isEmpty) {
      throw  ElectricBillException(
        message: loc.electricApiKeyMissing,
      );
    }

    if (_hmacSecret.trim().isEmpty) {
      throw  ElectricBillException(
        message: loc.electricHmacSecretMissing,
      );
    }

    final queryParameters = <String, String>{
      'product': normalizedProductCode,
      'account': normalizedAccountNumber,
    };

    final uri = _buildInquiryUri(
      queryParameters: queryParameters,
    );

    try {
      final signedHeaders = _buildSignedHeaders(
        method: 'GET',
        queryParameters: queryParameters,
        body: '',
        loc: loc,
      );

      debugPrint('========================================');
      debugPrint('ELECTRIC BILL API REQUEST');
      debugPrint('Method: GET');
      debugPrint('URL: $uri');
      debugPrint('Product: $normalizedProductCode');
      debugPrint('Account: $normalizedAccountNumber');
      debugPrint(
        'Timestamp: ${signedHeaders['X-Timestamp']}',
      );
      debugPrint(
        'Nonce: ${signedHeaders['X-Nonce']}',
      );

      // Do not print the API key, HMAC secret, or signature in production.
      debugPrint('========================================');

      final response = await http
          .get(
            uri,
            headers: signedHeaders,
          )
          .timeout(_timeout);

      debugPrint('========================================');
      debugPrint('ELECTRIC BILL API RESPONSE');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('========================================');

      final decodedResponse = _decodeResponse(
        response.body,
        loc,
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final apiMessage = _extractMessage(
          decodedResponse,
          fallback: loc.electricInquiryHttpFailed(
            response.statusCode,
          ),
        );

        final localizedErrorMessage = _localizeApiMessage(
          message: apiMessage,
          loc: loc,
        );

        throw ElectricBillException(
          message: localizedErrorMessage,
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      final bill = ElectricBillModel.fromApi(
        productCode: normalizedProductCode,
        billerName: billerName,
        enteredAccountNumber:
            normalizedAccountNumber,
        response: decodedResponse,
      );

      final responseMessage = _extractMessage(
        decodedResponse,
        fallback: bill.message,
      );

      final localizedMessage = _localizeApiMessage(
        message: responseMessage,
        loc: loc,
      );

      if (!bill.success) {
        return ElectricBillInquiryResult.failure(
          message: responseMessage.isNotEmpty
            ? localizedMessage
            : loc.electricNoBillRecordFound,
        );
      }

      if (!_hasUsableBillData(bill)) {
        return ElectricBillInquiryResult.failure(
          message: responseMessage.isNotEmpty
            ? localizedMessage
            : loc.electricNoBillRecordFound,
        );
      }

      return ElectricBillInquiryResult.success(
        bill: bill,
        message: responseMessage,
      );
   } on TimeoutException {
      throw ElectricBillException(
        message: loc.electricInquiryTimeout,
      );
    } on SocketException {
      throw ElectricBillException(
        message: loc.electricUnableToConnect,
      );
    } on FormatException catch (error) {
      throw ElectricBillException(
        message: loc.electricInvalidServerResponse(
          error.toString(),
        ),
      );
    } on ElectricBillException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected electric bill inquiry error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      throw ElectricBillException(
        message: loc.electricInquiryFailed(
          error.toString(),
        ),
      );
    }
  }

  // =========================================================
  // BUILD URL
  // =========================================================

  static Uri _buildInquiryUri({
    required Map<String, String> queryParameters,
  }) {
    return Uri.parse(
      _electricInquiryUrl,
    ).replace(
      queryParameters: queryParameters,
    );
  }

  // =========================================================
  // HMAC AUTHENTICATION
  //
  // Matches the Postman pre-request script:
  //
  // v1:timestamp:nonce:method:sortedQuery:bodyHash
  // =========================================================

  static Map<String, String> _buildSignedHeaders({
    required String method,
    required Map<String, String> queryParameters,
    required String body,
    required AppLocalizations loc,
  }) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000)
            .toString();

    final nonce =
        'req-$timestamp-${_uuid.v4().toLowerCase()}';

    final normalizedMethod =
        method.trim().toUpperCase();

    final bodyHash = base64Encode(
      sha256.convert(
        utf8.encode(body),
      ).bytes,
    );

    final sortedQuery =
        _buildSortedQuery(queryParameters);

    final canonical =
        'v1:$timestamp:$nonce:'
        '$normalizedMethod:$sortedQuery:$bodyHash';

    late final List<int> secretBytes;

    try {
      /*
       * Postman uses:
       *
       * CryptoJS.enc.Base64.parse(hmacSecret)
       *
       * Therefore Flutter must Base64-decode the secret first.
       */
      secretBytes = base64Decode(
        _normalizeBase64(_hmacSecret.trim()),
      );
    } on FormatException {
      throw ElectricBillException(
        message: loc.electricInvalidHmacBase64,
      );
    }

    final hmac = Hmac(
      sha256,
      secretBytes,
    );

    final signatureBytes = hmac.convert(
      utf8.encode(canonical),
    );

    final signature = base64Encode(
      signatureBytes.bytes,
    );

    debugPrint('Canonical: $canonical');

    // Only enable temporarily when comparing with Postman.
    // Do not log signatures in production.
    // debugPrint('Signature: v1=$signature');

    return <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      'X-Api-Key': _apiKey.trim(),
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': 'v1=$signature',
    };
  }

  // =========================================================
  // SORT QUERY PARAMETERS
  //
  // Postman sorts them alphabetically by key.
  //
  // Input:
  // product=TNB
  // account=220411163904
  //
  // Canonical value:
  // account=220411163904&product=TNB
  // =========================================================

  static String _buildSortedQuery(
    Map<String, String> queryParameters,
  ) {
    final entries =
        queryParameters.entries.toList()
          ..sort(
            (a, b) => a.key.compareTo(b.key),
          );

    return entries
        .map(
          (entry) =>
              '${entry.key}=${entry.value}',
        )
        .join('&');
  }

  // =========================================================
  // NORMALIZE BASE64
  // =========================================================

  static String _normalizeBase64(
    String value,
  ) {
    var normalized = value
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll(' ', '');

    final remainder = normalized.length % 4;

    if (remainder != 0) {
      normalized += '=' * (4 - remainder);
    }

    return normalized;
  }

  // =========================================================
  // DECODE RESPONSE
  // =========================================================

  static Map<String, dynamic> _decodeResponse(
    String responseBody,
    AppLocalizations loc,
  ) {
    if (responseBody.trim().isEmpty) {
      throw FormatException(
        loc.electricEmptyApiResponse,
      );
    }

    final decoded = jsonDecode(
      responseBody,
    );

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(
        decoded,
      );
    }

    if (decoded is List) {
      if (decoded.isEmpty) {
        return {
          'success': false,
          'message': loc.electricNoBillRecordFound,
          'data': null,
          'items': decoded,
        };
      }

      final firstItem = decoded.first;

      if (firstItem is Map<String, dynamic>) {
        return {
          'success': true,
          'data': firstItem,
          'items': decoded,
        };
      }

      if (firstItem is Map) {
        return {
          'success': true,
          'data': Map<String, dynamic>.from(
            firstItem,
          ),
          'items': decoded,
        };
      }
    }

    throw FormatException(
      loc.electricInvalidJsonObject,
    );
  }

  // =========================================================
  // EXTRACT API MESSAGE
  // =========================================================

  static String _extractMessage(
    Map<String, dynamic> response, {
    required String fallback,
  }) {
    final possibleMessages = [
      response['transaction_message'],
      response['error_message'],
      response['message'],
      response['responseMessage'],
      response['response_message'],
    ];

    final error = response['error'];

    if (error is Map) {
      possibleMessages.addAll([
        error['error_message'],
        error['message'],
        error['description'],
        error['detail'],
        error['error_code'],
      ]);
    } else if (error != null) {
      possibleMessages.add(error);
    }

    final data = response['data'];

  if (data is Map) {
    possibleMessages.addAll([
      data['message'],
    ]);
  }

    for (final value in possibleMessages) {
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();

      if (text.isNotEmpty &&
          text.toLowerCase() != 'null') {
        return text;
      }
    }

    return fallback;
  }

  static String _localizeApiMessage({
  required String message,
  required AppLocalizations loc,
}) {
  final normalizedMessage = message
      .trim()
      .toLowerCase()
      .replaceAll('.', '');

  switch (normalizedMessage) {
    case 'invalid account no':
    case 'invalid account number':
    case 'invalid account':
      return loc.electricInvalidAccount;

    case 'no bill record was found':
    case 'no bill record found':
      return loc.electricNoBillRecordFound;

    case 'account number is required':
      return loc.electricAccountNumberRequired;

    case 'product code is required':
      return loc.electricProductCodeRequired;

    default:
      return message;
  }
}

  // =========================================================
  // CHECK BILL DATA
  // =========================================================

  static bool _hasUsableBillData(
    ElectricBillModel bill,
  ) {
    return bill.accountNumber.isNotEmpty ||
        bill.billerName.isNotEmpty ||
        bill.customerName.isNotEmpty ||
        bill.customerAddress.isNotEmpty ||
        bill.dueDate.isNotEmpty ||
        bill.amount != 0 ||
        bill.outstandingAmount != 0 ||
        bill.currentAmount != 0;
  }
}