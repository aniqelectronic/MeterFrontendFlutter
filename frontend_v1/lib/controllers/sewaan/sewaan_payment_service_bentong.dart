import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class SewaanPaymentServiceBentong {
  // ============================================================
  // MPB GATEWAY
  // ============================================================

  static const String _paymentBaseUrl =
      'http://52.163.74.67:3010';

  // ============================================================
  // YOUR FASTAPI BACKEND
  // ============================================================

  static const String _backendBaseUrl =
      Config.apiBaseUrl;

  static const Duration _timeout =
      Duration(seconds: 15);

  // ============================================================
  // MPB HEADERS
  //
  // These headers are only for the external MPB Gateway.
  // Do not replace them with your TIP HMAC headers.
  // ============================================================

  static Map<String, String> get _paymentHeaders {
    return {
      'x-api-key': 'MPB_GW_2026_x8Kp91LmQ7zT44',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-source-system': 'TIP-${Config.terminalId}',
    };
  }

  // ============================================================
  // CLEAN ACCOUNT NUMBER
  // ============================================================

  static String _cleanAccountNo(
    String accountNo,
  ) {
    return accountNo
        .trim()
        .replaceFirst(
          RegExp(r'^[TS]', caseSensitive: false),
          '',
        );
  }

  // ============================================================
  // TIP BACKEND HMAC HELPERS
  // ============================================================

  static String _createBodyHash(
    String body,
  ) {
    final digest = sha256.convert(
      utf8.encode(body),
    );

    return base64Encode(
      digest.bytes,
    );
  }

  static String _createCanonicalQuery(
    Uri uri,
  ) {
    final queryItems =
        <MapEntry<String, String>>[];

    uri.queryParametersAll.forEach(
      (key, values) {
        for (final value in values) {
          queryItems.add(
            MapEntry(key, value),
          );
        }
      },
    );

    queryItems.sort(
      (a, b) {
        final keyComparison =
            a.key.compareTo(b.key);

        if (keyComparison != 0) {
          return keyComparison;
        }

        return a.value.compareTo(b.value);
      },
    );

    return queryItems.map(
      (item) {
        final encodedKey =
            Uri.encodeQueryComponent(
          item.key,
        );

        final encodedValue =
            Uri.encodeQueryComponent(
          item.value,
        );

        return '$encodedKey=$encodedValue';
      },
    ).join('&');
  }

  static Map<String, String>
      _createBackendHeaders({
    required String method,
    required Uri uri,
    String body = '',
  }) {
    final bodyHash =
        _createBodyHash(body);

    final canonicalQuery =
        _createCanonicalQuery(uri);

    final canonicalString = [
      method.toUpperCase(),
      uri.path,
      canonicalQuery,
      bodyHash,
    ].join('\n');

    final signatureDigest = Hmac(
      sha256,
      utf8.encode(
        Config.hmacSecret,
      ),
    ).convert(
      utf8.encode(
        canonicalString,
      ),
    );

    final signature =
        'v1=${signatureDigest.toString()}';

    print('====================================');
    print('[SEWAAN BACKEND HMAC]');
    print('Method    : ${method.toUpperCase()}');
    print('Path      : ${uri.path}');
    print('Query     : $canonicalQuery');
    print('Body hash : $bodyHash');
    print('Signature : $signature');
    print('====================================');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Key': Config.apiKey,
      'X-Signature': signature,
    };
  }

  // ============================================================
  // SINGLE PAYMENT TO MPB
  // ============================================================

  static Future<bool> paySewaan({
    required String accountNumber,
    required double amountPaid,
    required String referenceNo,
  }) async {
    try {
      final cleanAccountNo =
          _cleanAccountNo(
        accountNumber,
      );

      final url = Uri.parse(
        '$_paymentBaseUrl/api/v1/mpb/sewaan/payment',
      );

      final body = jsonEncode({
        'module': 'S',
        'account_number':
            cleanAccountNo,
        'amount_paid':
            amountPaid,
        'agent_code':
            'KTIP',
        'reference_no':
            referenceNo,
      });

      print('====================================');
      print('[SEWAAN PAYMENT TO MPB]');
      print('URL        : $url');
      print('Account No : $cleanAccountNo');
      print('Amount     : $amountPaid');
      print('Reference  : $referenceNo');
      print('Request    : $body');

      final response = await http
          .post(
            url,
            headers:
                _paymentHeaders,
            body:
                body,
          )
          .timeout(
            _timeout,
          );

      print(
        'Status Code : ${response.statusCode}',
      );

      print(
        'Response    : ${response.body}',
      );

      print('====================================');

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return false;
      }

      final decoded =
          jsonDecode(
        response.body,
      );

      if (decoded is Map &&
          decoded['success'] == false) {
        return false;
      }

      return true;
    } catch (e) {
      print(
        '[SEWAAN PAYMENT ERROR] $e',
      );

      return false;
    }
  }

  // ============================================================
  // MULTIPLE PAYMENT TO MPB
  // ============================================================

  static Future<bool> payMultipleSewaan({
    required List<SewaanPaymentItem> items,
    required String referenceNo,
  }) async {
    if (items.isEmpty) {
      return false;
    }

    for (final item in items) {
      final success =
          await paySewaan(
        accountNumber:
            item.accountNo,
        amountPaid:
            item.amount,
        referenceNo:
            referenceNo,
      );

      if (!success) {
        print(
          '[SEWAAN PAYMENT] Failed for account: '
          '${_cleanAccountNo(item.accountNo)}',
        );

        return false;
      }
    }

    print(
      '[SEWAAN PAYMENT] All MPB payments successful',
    );

    return true;
  }

  // ============================================================
  // SAVE PAYMENT UPDATE TO YOUR FASTAPI BACKEND
  // ============================================================

  static Future<bool>
      postPaymentUpdateBentong({
    required List<SewaanPaymentItem> items,
    required String orderNo,
    required String bankTrxNo,
    required String paymentMethod,
  }) async {
    if (items.isEmpty) {
      print(
        '[SEWAAN UPDATE] No items supplied',
      );

      return false;
    }

    try {
      final uri = Uri.parse(
        '$_backendBaseUrl'
        '/sewaan/payment-updates-sewaan-bentong',
      );

      final body = jsonEncode({
        'order_no': orderNo,
        'paid_date':
            DateTime.now()
                .toIso8601String(),
        'payment_method':
            paymentMethod,
        'bank_trx_no':
            bankTrxNo,
        'sewaan_items':
            items.map(
          (item) {
            return {
              'no_pendaftaran':
                  item.noPendaftaran,
              'account_number':
                  item.accountNo,
              'tenant_name':
                  item.tenantName,
              'premise_address':
                  item.premiseAddress,
              'amount':
                  item.amount,
            };
          },
        ).toList(),
      });

      print('====================================');
      print('[SEWAAN UPDATE TO TIP BACKEND]');
      print('URL     : $uri');
      print('Payload : $body');

      final response = await http
          .post(
            uri,
            headers:
                _createBackendHeaders(
              method:
                  'POST',
              uri:
                  uri,
              body:
                  body,
            ),
            body:
                body,
          )
          .timeout(
            _timeout,
          );

      print(
        'Status  : ${response.statusCode}',
      );

      print(
        'Body    : ${response.body}',
      );

      print('====================================');

      return response.statusCode >= 200 &&
          response.statusCode < 300;
    } catch (e) {
      print(
        '[SEWAAN UPDATE ERROR] $e',
      );

      return false;
    }
  }
}