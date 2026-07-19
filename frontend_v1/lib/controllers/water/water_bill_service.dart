import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:frontend_v1/controllers/water/water_bill_exception.dart';
import 'package:frontend_v1/controllers/water/water_bill_inquiry_result.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/water/water_bill_model.dart';
import 'package:frontend_v1/pages/data.dart';

class WaterBillService {
  WaterBillService._();

  static const Duration _timeout = Duration(seconds: 30);
  static const Uuid _uuid = Uuid();

  static String get _inquiryUrl =>
      '${Data.iimmpactBaseUrl}/v2/bill-presentment';

  static String get _apiKey => Data.iimmpactApiKey;
  static String get _hmacSecret => Data.iimmpactHmacSecret;

  static Future<WaterBillInquiryResult> inquiryBill({
    required String productCode,
    required String billerName,
    required String accountNumber,
    required AppLocalizations loc,
  }) async {
    final product = productCode.trim().toUpperCase();
    final account = accountNumber.trim().toUpperCase();

    if (product.isEmpty) {
      return WaterBillInquiryResult.failure(
        message: loc.waterProductCodeRequired,
      );
    }

    if (account.isEmpty) {
      return WaterBillInquiryResult.failure(
        message: loc.waterAccountNumberRequired,
      );
    }

    if (_apiKey.trim().isEmpty) {
      throw WaterBillException(message: loc.waterApiKeyMissing);
    }

    if (_hmacSecret.trim().isEmpty) {
      throw WaterBillException(message: loc.waterHmacSecretMissing);
    }

    final query = <String, String>{
      'product': product,
      'account': account,
    };

    final uri = Uri.parse(_inquiryUrl).replace(
      queryParameters: query,
    );

    try {
      final headers = _buildSignedHeaders(
        method: 'GET',
        queryParameters: query,
        body: '',
        loc: loc,
      );

      debugPrint('WATER BILL REQUEST: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(_timeout);

      debugPrint('WATER BILL STATUS: ${response.statusCode}');
      debugPrint('WATER BILL RESPONSE: ${response.body}');

      final decoded = _decodeResponse(response.body, loc);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final rawMessage = _extractMessage(
          decoded,
          fallback: loc.waterInquiryHttpFailed(response.statusCode),
        );

        throw WaterBillException(
          message: _localizeApiMessage(
            message: rawMessage,
            loc: loc,
          ),
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      final bill = WaterBillModel.fromApi(
        productCode: product,
        billerName: billerName,
        enteredAccountNumber: account,
        response: decoded,
      );

      final rawMessage = _extractMessage(
        decoded,
        fallback: bill.message,
      );

      final message = _localizeApiMessage(
        message: rawMessage,
        loc: loc,
      );

      if (!bill.success || !_hasUsableBillData(bill)) {
        return WaterBillInquiryResult.failure(
          message: message.isNotEmpty
              ? message
              : loc.waterNoBillRecordFound,
        );
      }

      return WaterBillInquiryResult.success(
        bill: bill,
        message: message,
      );
    } on TimeoutException {
      throw WaterBillException(
        message: loc.waterInquiryTimeout,
      );
    } on SocketException {
      throw WaterBillException(
        message: loc.waterUnableToConnect,
      );
    } on FormatException catch (error) {
      throw WaterBillException(
        message: loc.waterInvalidServerResponse(error.toString()),
      );
    } on WaterBillException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('Unexpected water bill inquiry error: $error');
      debugPrintStack(stackTrace: stackTrace);

      throw WaterBillException(
        message: loc.waterInquiryFailed(error.toString()),
      );
    }
  }

  static Map<String, String> _buildSignedHeaders({
    required String method,
    required Map<String, String> queryParameters,
    required String body,
    required AppLocalizations loc,
  }) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final nonce =
        'req-$timestamp-${_uuid.v4().toLowerCase()}';

    final bodyHash = base64Encode(
      sha256.convert(utf8.encode(body)).bytes,
    );

    final sortedQuery = _buildSortedQuery(queryParameters);

    final canonical =
        'v1:$timestamp:$nonce:${method.toUpperCase()}:$sortedQuery:$bodyHash';

    late final List<int> secretBytes;

    try {
      secretBytes = base64Decode(
        _normalizeBase64(_hmacSecret.trim()),
      );
    } on FormatException {
      throw WaterBillException(
        message: loc.waterInvalidHmacBase64,
      );
    }

    final signature = base64Encode(
      Hmac(sha256, secretBytes)
          .convert(utf8.encode(canonical))
          .bytes,
    );

    return {
      HttpHeaders.acceptHeader: 'application/json',
      'X-Api-Key': _apiKey.trim(),
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': 'v1=$signature',
    };
  }

  static String _buildSortedQuery(
    Map<String, String> queryParameters,
  ) {
    final entries = queryParameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
  }

  static String _normalizeBase64(String value) {
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

  static Map<String, dynamic> _decodeResponse(
    String responseBody,
    AppLocalizations loc,
  ) {
    if (responseBody.trim().isEmpty) {
      throw FormatException(loc.waterEmptyApiResponse);
    }

    final decoded = jsonDecode(responseBody);

    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);

    if (decoded is List) {
      if (decoded.isEmpty) {
        return {
          'transaction_validity': false,
          'message': loc.waterNoBillRecordFound,
          'data': null,
        };
      }

      final first = decoded.first;
      if (first is Map) {
        return {
          'transaction_validity': true,
          'data': Map<String, dynamic>.from(first),
          'items': decoded,
        };
      }
    }

    throw FormatException(loc.waterInvalidJsonObject);
  }

  static String _extractMessage(
    Map<String, dynamic> response, {
    required String fallback,
  }) {
    final values = <dynamic>[
      response['transaction_message'],
      response['error_message'],
      response['message'],
      response['responseMessage'],
      response['response_message'],
    ];

    final data = response['data'];
    if (data is Map) {
      values.add(data['message']);
    }

    final error = response['error'];
    if (error is Map) {
      values.addAll([
        error['error_message'],
        error['message'],
        error['description'],
        error['detail'],
      ]);
    } else if (error != null) {
      values.add(error);
    }

    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return fallback;
  }

  static String _localizeApiMessage({
    required String message,
    required AppLocalizations loc,
  }) {
    final normalized = message
        .trim()
        .toLowerCase()
        .replaceAll('.', '');

    switch (normalized) {
      case 'invalid account no':
      case 'invalid account number':
      case 'invalid account':
        return loc.waterInvalidAccount;

      case 'no bill record was found':
      case 'no bill record found':
        return loc.waterNoBillRecordFound;

      case 'account number is required':
        return loc.waterAccountNumberRequired;

      case 'product code is required':
        return loc.waterProductCodeRequired;

          case 'endpoint request timed out':
      return loc.waterProviderTimeout;

      default:
        return message;
    }
  }

  static bool _hasUsableBillData(WaterBillModel bill) {
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
