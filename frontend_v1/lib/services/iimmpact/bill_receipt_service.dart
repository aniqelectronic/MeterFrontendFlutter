import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/services/api/api_hmac_helper.dart';
import 'package:http/http.dart' as http;

class BillReceiptException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const BillReceiptException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    return message;
  }
}

class BillReceiptService {
  BillReceiptService._();

  static const Duration _timeout = Duration(
    seconds: 40,
  );

  /// Config.apiBaseUrl already contains:
  ///
  /// https://tipintar.juaraipasifik.com/api/v2
  ///
  /// Therefore, only append the endpoint path here.
  static String get _receiptUrl {
    return '${Config.apiBaseUrl}/bill/receipt/qr';
  }

  static Future<Uint8List> generateReceiptQr({
    required String orderNo,
    required DateTime paidDate,
    required String paymentMethod,
    required String billType,
    required String billCode,
    required String accountNumber,
    required double billAmount,
    required double totalAmount,
    String? bankTransactionNo,
  }) async {
    final String normalizedOrderNo = orderNo.trim();

    final String normalizedBillType =
        billType.trim();

    final String normalizedBillCode =
        billCode.trim().toUpperCase();

    final String normalizedAccountNumber =
        accountNumber.trim();

    final String normalizedPaymentMethod =
        paymentMethod.trim().isEmpty
            ? 'DuitNow QR'
            : paymentMethod.trim();

    final String normalizedBankTransactionNo =
        bankTransactionNo?.trim() ?? '';

    _validateInput(
      orderNo: normalizedOrderNo,
      billType: normalizedBillType,
      billCode: normalizedBillCode,
      accountNumber: normalizedAccountNumber,
      billAmount: billAmount,
      totalAmount: totalAmount,
    );

    final Uri uri = Uri.parse(
      _receiptUrl,
    );

    final Map<String, dynamic> payload =
        <String, dynamic>{
      'order_no': normalizedOrderNo,
      'paid_date': paidDate.toIso8601String(),
      'payment_method': normalizedPaymentMethod,
      'bank_trx_no':
          normalizedBankTransactionNo,
      'bill_type': normalizedBillType,
      'bill_code': normalizedBillCode,
      'account_number':
          normalizedAccountNumber,
      'bill_amount': double.parse(
        billAmount.toStringAsFixed(2),
      ),
      'total_amount': double.parse(
        totalAmount.toStringAsFixed(2),
      ),
    };

    /*
     * IMPORTANT:
     *
     * The exact same JSON string must be:
     *
     * 1. Used when creating the HMAC body hash.
     * 2. Sent as the HTTP request body.
     *
     * Do not call jsonEncode(payload) twice using different
     * payload objects or field orders.
     */
    final String body = jsonEncode(
      payload,
    );

    final Map<String, String> headers =
        ApiHmacHelper.createHeaders(
      method: 'POST',
      uri: uri,
      body: body,
      accept: 'image/png',
    );

    debugPrint(
      '[BillReceiptService] POST $uri',
    );

    debugPrint(
      '[BillReceiptService] Order: '
      '$normalizedOrderNo',
    );

    debugPrint(
      '[BillReceiptService] Bill provider: '
      '$normalizedBillType',
    );

    try {
      final http.Response response = await http
          .post(
            uri,
            headers: headers,
            body: body,
          )
          .timeout(_timeout);

      final String contentType =
          response.headers[
                  HttpHeaders.contentTypeHeader] ??
              '';

      debugPrint(
        '[BillReceiptService] Status: '
        '${response.statusCode}',
      );

      debugPrint(
        '[BillReceiptService] Content-Type: '
        '$contentType',
      );

      if (response.statusCode ==
          HttpStatus.ok) {
        if (!contentType
            .toLowerCase()
            .contains('image/png')) {
          debugPrint(
            '[BillReceiptService] Unexpected '
            'response body: ${response.body}',
          );

          throw BillReceiptException(
            message:
                'The receipt server returned an unexpected response.',
            statusCode: response.statusCode,
            responseBody: response.body,
          );
        }

        if (response.bodyBytes.isEmpty) {
          throw const BillReceiptException(
            message:
                'The receipt QR image is empty.',
          );
        }

        debugPrint(
          '[BillReceiptService] Receipt QR '
          'created successfully. Bytes: '
          '${response.bodyBytes.length}',
        );

        return Uint8List.fromList(
          response.bodyBytes,
        );
      }

      debugPrint(
        '[BillReceiptService] Error response: '
        '${response.body}',
      );

      throw BillReceiptException(
        message: _extractBackendError(
          response.body,
          fallback:
              'Unable to generate the digital receipt QR.',
        ),
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    } on TimeoutException {
      throw const BillReceiptException(
        message:
            'The receipt request took too long. Please try again.',
      );
    } on SocketException {
      throw const BillReceiptException(
        message:
            'Unable to connect to the receipt server.',
      );
    } on FormatException {
      throw const BillReceiptException(
        message:
            'The receipt server address is invalid.',
      );
    } on BillReceiptException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        '[BillReceiptService] Unexpected error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      throw BillReceiptException(
        message:
            'Unable to generate the digital receipt: $error',
      );
    }
  }

  static void _validateInput({
    required String orderNo,
    required String billType,
    required String billCode,
    required String accountNumber,
    required double billAmount,
    required double totalAmount,
  }) {
    if (orderNo.isEmpty) {
      throw const BillReceiptException(
        message:
            'The receipt order number is missing.',
      );
    }

    if (billType.isEmpty) {
      throw const BillReceiptException(
        message:
            'The bill provider is missing.',
      );
    }

    if (billCode.isEmpty) {
      throw const BillReceiptException(
        message:
            'The bill code is missing.',
      );
    }

    if (accountNumber.isEmpty) {
      throw const BillReceiptException(
        message:
            'The bill account number is missing.',
      );
    }

    if (billAmount <= 0) {
      throw const BillReceiptException(
        message:
            'The bill amount must be greater than zero.',
      );
    }

    if (totalAmount <= 0) {
      throw const BillReceiptException(
        message:
            'The total payment amount must be greater than zero.',
      );
    }

    if (Config.apiKey.trim().isEmpty) {
      throw const BillReceiptException(
        message:
            'The backend API key is missing.',
      );
    }

    if (Config.hmacSecret.trim().isEmpty) {
      throw const BillReceiptException(
        message:
            'The backend HMAC secret is missing.',
      );
    }
  }

  static String _extractBackendError(
    String responseBody, {
    required String fallback,
  }) {
    if (responseBody.trim().isEmpty) {
      return fallback;
    }

    try {
      final dynamic decoded = jsonDecode(
        responseBody,
      );

      if (decoded is Map<String, dynamic>) {
        final dynamic detail =
            decoded['detail'];

        if (detail is String &&
            detail.trim().isNotEmpty) {
          return detail.trim();
        }

        if (detail is List &&
            detail.isNotEmpty) {
          return detail.toString();
        }

        final dynamic message =
            decoded['message'];

        if (message is String &&
            message.trim().isNotEmpty) {
          return message.trim();
        }

        final dynamic error =
            decoded['error'];

        if (error is String &&
            error.trim().isNotEmpty) {
          return error.trim();
        }
      }
    } catch (_) {
      // The backend may return plain text or HTML.
    }

    final String cleanResponse =
        responseBody.trim();

    if (cleanResponse.length <= 250) {
      return cleanResponse;
    }

    return fallback;
  }
}