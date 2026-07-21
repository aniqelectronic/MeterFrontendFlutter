import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/controllers/broadband/broadband_bill_exception.dart';
import 'package:frontend_v1/controllers/broadband/broadband_bill_inquiry_result.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/broadband/broadband_bill_model.dart';
import 'package:frontend_v1/pages/data.dart';

class BroadbandBillService {
  BroadbandBillService._();

  static const Duration _timeout =
      Duration(seconds: 30);

  static const Uuid _uuid = Uuid();

  // =========================================================
  // API CONFIGURATION
  // =========================================================

  static String get _broadbandInquiryUrl =>
      '${Data.iimmpactBaseUrl}/v2/bill-presentment';

  static String get _apiKey =>
      Data.iimmpactApiKey;

  static String get _hmacSecret =>
      Data.iimmpactHmacSecret;

  // =========================================================
  // BROADBAND BILL INQUIRY
  // =========================================================

  static Future<BroadbandBillInquiryResult>
      inquiryBill({
    required String productCode,
    required String billerName,
    required String accountNumber,
    required AppLocalizations loc,
  }) async {
    final normalizedProductCode =
        productCode.trim().toUpperCase();

    final normalizedAccountNumber =
        accountNumber.trim().toUpperCase();

    if (normalizedProductCode.isEmpty) {
      return BroadbandBillInquiryResult.failure(
        message:
            loc.broadbandProductCodeRequired,
      );
    }

    if (normalizedAccountNumber.isEmpty) {
      return BroadbandBillInquiryResult.failure(
        message:
            loc.broadbandAccountNumberRequired,
      );
    }

    if (_apiKey.trim().isEmpty) {
      throw BroadbandBillException(
        message: loc.broadbandApiKeyMissing,
      );
    }

    if (_hmacSecret.trim().isEmpty) {
      throw BroadbandBillException(
        message:
            loc.broadbandHmacSecretMissing,
      );
    }

    final queryParameters =
        <String, String>{
      'product': normalizedProductCode,
      'account': normalizedAccountNumber,
    };

    final uri = _buildInquiryUri(
      queryParameters: queryParameters,
    );

    try {
      final signedHeaders =
          _buildSignedHeaders(
        method: 'GET',
        queryParameters: queryParameters,
        body: '',
        loc: loc,
      );

      debugPrint(
        '========================================',
      );
      debugPrint(
        'BROADBAND BILL API REQUEST',
      );
      debugPrint('Method: GET');
      debugPrint('URL: $uri');
      debugPrint(
        'Product: $normalizedProductCode',
      );
      debugPrint(
        'Account: $normalizedAccountNumber',
      );
      debugPrint(
        'Timestamp: '
        '${signedHeaders['X-Timestamp']}',
      );
      debugPrint(
        'Nonce: '
        '${signedHeaders['X-Nonce']}',
      );
      debugPrint(
        '========================================',
      );

      final response = await http
          .get(
            uri,
            headers: signedHeaders,
          )
          .timeout(_timeout);

      debugPrint(
        '========================================',
      );
      debugPrint(
        'BROADBAND BILL API RESPONSE',
      );
      debugPrint(
        'Status code: ${response.statusCode}',
      );
      debugPrint(
        'Body: ${response.body}',
      );
      debugPrint(
        '========================================',
      );

      final decodedResponse =
          _decodeResponse(
        response.body,
        loc,
      );

      // =====================================================
      // HTTP ERROR
      // =====================================================

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final apiMessage =
            _extractMessage(
          decodedResponse,
          fallback:
              loc.broadbandInquiryHttpFailed(
            response.statusCode,
          ),
        );

        final localizedMessage =
            _localizeApiMessage(
          message: apiMessage,
          loc: loc,
        );

        throw BroadbandBillException(
          message: localizedMessage,
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      // =====================================================
      // CONVERT RESPONSE TO MODEL
      // =====================================================

      final bill =
          BroadbandBillModel.fromApi(
        productCode:
            normalizedProductCode,
        billerName: billerName,
        enteredAccountNumber:
            normalizedAccountNumber,
        response: decodedResponse,
      );

      final responseMessage =
          _extractMessage(
        decodedResponse,
        fallback: bill.message,
      );

      final localizedMessage =
          _localizeApiMessage(
        message: responseMessage,
        loc: loc,
      );

      // =====================================================
      // INVALID TRANSACTION
      // =====================================================

      if (!bill.success) {
        return BroadbandBillInquiryResult
            .failure(
          message:
              localizedMessage.isNotEmpty
                  ? localizedMessage
                  : loc
                      .broadbandNoBillRecordFound,
        );
      }

      // =====================================================
      // NO USABLE DATA
      // =====================================================

      if (!_hasUsableBillData(bill)) {
        return BroadbandBillInquiryResult
            .failure(
          message:
              localizedMessage.isNotEmpty
                  ? localizedMessage
                  : loc
                      .broadbandNoBillRecordFound,
        );
      }

      // =====================================================
      // SUCCESS
      // =====================================================

      return BroadbandBillInquiryResult
          .success(
        bill: bill,
        message: localizedMessage,
      );
    } on TimeoutException {
      throw BroadbandBillException(
        message:
            loc.broadbandInquiryTimeout,
      );
    } on SocketException {
      throw BroadbandBillException(
        message:
            loc.broadbandUnableToConnect,
      );
    } on FormatException catch (error) {
      throw BroadbandBillException(
        message:
            loc.broadbandInvalidServerResponse(
          error.toString(),
        ),
      );
    } on BroadbandBillException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected broadband bill '
        'inquiry error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      throw BroadbandBillException(
        message:
            loc.broadbandInquiryFailed(
          error.toString(),
        ),
      );
    }
  }

  // =========================================================
  // BUILD URL
  // =========================================================

  static Uri _buildInquiryUri({
    required Map<String, String>
        queryParameters,
  }) {
    return Uri.parse(
      _broadbandInquiryUrl,
    ).replace(
      queryParameters: queryParameters,
    );
  }

  // =========================================================
  // HMAC SIGNATURE
  //
  // Canonical:
  //
  // v1:timestamp:nonce:method:sortedQuery:bodyHash
  // =========================================================

  static Map<String, String>
      _buildSignedHeaders({
    required String method,
    required Map<String, String>
        queryParameters,
    required String body,
    required AppLocalizations loc,
  }) {
    final timestamp =
        (DateTime.now()
                    .millisecondsSinceEpoch ~/
                1000)
            .toString();

    final nonce =
        'req-$timestamp-'
        '${_uuid.v4().toLowerCase()}';

    final normalizedMethod =
        method.trim().toUpperCase();

    final bodyHash = base64Encode(
      sha256.convert(
        utf8.encode(body),
      ).bytes,
    );

    final sortedQuery =
        _buildSortedQuery(
      queryParameters,
    );

    final canonical =
        'v1:$timestamp:$nonce:'
        '$normalizedMethod:'
        '$sortedQuery:'
        '$bodyHash';

    late final List<int> secretBytes;

    try {
      secretBytes = base64Decode(
        _normalizeBase64(
          _hmacSecret.trim(),
        ),
      );
    } on FormatException {
      throw BroadbandBillException(
        message:
            loc.broadbandInvalidHmacBase64,
      );
    }

    final hmac = Hmac(
      sha256,
      secretBytes,
    );

    final signatureBytes =
        hmac.convert(
      utf8.encode(canonical),
    );

    final signature = base64Encode(
      signatureBytes.bytes,
    );

    debugPrint(
      'Broadband canonical: $canonical',
    );

    return <String, String>{
      HttpHeaders.acceptHeader:
          'application/json',

      'X-Api-Key':
          _apiKey.trim(),

      'X-Timestamp':
          timestamp,

      'X-Nonce':
          nonce,

      'X-Signature':
          'v1=$signature',
    };
  }

  // =========================================================
  // SORT QUERY PARAMETERS
  //
  // Original:
  // product=TM
  // account=9197000000
  //
  // Sorted:
  // account=9197000000&product=TM
  // =========================================================

  static String _buildSortedQuery(
    Map<String, String>
        queryParameters,
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
              '${entry.key}=${entry.value}',
        )
        .join('&');
  }

  // =========================================================
  // NORMALIZE BASE64 SECRET
  // =========================================================

  static String _normalizeBase64(
    String value,
  ) {
    var normalized = value
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll(' ', '');

    final remainder =
        normalized.length % 4;

    if (remainder != 0) {
      normalized +=
          '=' * (4 - remainder);
    }

    return normalized;
  }

  // =========================================================
  // DECODE RESPONSE
  // =========================================================

  static Map<String, dynamic>
      _decodeResponse(
    String responseBody,
    AppLocalizations loc,
  ) {
    if (responseBody.trim().isEmpty) {
      throw FormatException(
        loc.broadbandEmptyApiResponse,
      );
    }

    final decoded =
        jsonDecode(responseBody);

    if (decoded
        is Map<String, dynamic>) {
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
          'transaction_validity': false,
          'transaction_message':
              loc.broadbandNoBillRecordFound,
          'data': null,
          'items': decoded,
        };
      }

      final firstItem = decoded.first;

      if (firstItem
          is Map<String, dynamic>) {
        return {
          'transaction_validity': true,
          'data': firstItem,
          'items': decoded,
        };
      }

      if (firstItem is Map) {
        return {
          'transaction_validity': true,
          'data':
              Map<String, dynamic>.from(
            firstItem,
          ),
          'items': decoded,
        };
      }
    }

    throw FormatException(
      loc.broadbandInvalidJsonObject,
    );
  }

  // =========================================================
  // EXTRACT API MESSAGE
  // =========================================================

  static String _extractMessage(
    Map<String, dynamic> response, {
    required String fallback,
  }) {
    final possibleMessages =
        <dynamic>[
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

    for (final value
        in possibleMessages) {
      if (value == null) {
        continue;
      }

      final text =
          value.toString().trim();

      if (text.isNotEmpty &&
          text.toLowerCase() != 'null') {
        return text;
      }
    }

    return fallback;
  }

  // =========================================================
  // LOCALIZE API MESSAGE
  // =========================================================

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
        return loc.broadbandInvalidAccount;

      case 'no bill record was found':
      case 'no bill record found':
      case 'bill record not found':
        return loc
            .broadbandNoBillRecordFound;

      case 'account number is required':
      case 'account no is required':
        return loc
            .broadbandAccountNumberRequired;

      case 'product code is required':
      case 'product is required':
        return loc
            .broadbandProductCodeRequired;

      case 'endpoint request timed out':
      case 'request timed out':
        return loc
            .broadbandProviderTimeout;

      case 'account no is valid':
      case 'account number is valid':
      case 'success':
        return loc.broadbandAccountValid;

      default:
        return message;
    }
  }

  // =========================================================
  // CHECK RESPONSE DATA
  // =========================================================

  static bool _hasUsableBillData(
    BroadbandBillModel bill,
  ) {
    return bill.accountNumber.isNotEmpty ||
        bill.billerName.isNotEmpty ||
        bill.customerName.isNotEmpty ||
        bill.customerAddress.isNotEmpty ||
        bill.billNumber.isNotEmpty ||
        bill.dueDate.isNotEmpty ||
        bill.message.isNotEmpty ||
        bill.amount != 0 ||
        bill.outstandingAmount != 0 ||
        bill.currentAmount != 0;
  }
}