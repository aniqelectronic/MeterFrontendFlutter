import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

class TaksiranPaymentServiceBentong {
  // ============================================================
  // EXTERNAL MPB GATEWAY
  // ============================================================

  static const String _paymentBaseUrl =
      'http://52.163.74.67:3010';

  static const String _mpbApiKey =
      'MPB_GW_2026_x8Kp91LmQ7zT44';

  // ============================================================
  // YOUR TIP FASTAPI BACKEND
  // ============================================================

  static const String _kioskBackendUrl =
      Config.apiBaseUrl;

  static const Duration _timeout =
      Duration(seconds: 15);

  // ============================================================
  // CLEAN ACCOUNT NUMBER
  // ============================================================

  static String _cleanAccountNo(
    String accountNo,
  ) {
    return accountNo
        .trim()
        .replaceFirst(
          RegExp(
            r'^[TS]',
            caseSensitive: false,
          ),
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
        final keyCompare =
            a.key.compareTo(b.key);

        if (keyCompare != 0) {
          return keyCompare;
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
    print('[TAKSIRAN BACKEND HMAC]');
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
  // SINGLE PAYMENT TO MPB API
  // ============================================================

  static Future<bool> payOne({
    required String accountNo,
    required double amount,
    required String referenceNo,
  }) async {
    try {
      final cleanAccountNo =
          _cleanAccountNo(
        accountNo,
      );

      final url = Uri.parse(
        '$_paymentBaseUrl/api/v1/mpb/taksiran/payment',
      );

      final body = jsonEncode({
        'module': 'T',
        'account_number':
            cleanAccountNo,
        'amount_paid':
            amount,
        'agent_code':
            'KTIP',
        'reference_no':
            referenceNo,
      });

      print('====================================');
      print('[TAKSIRAN PAYMENT TO MPB]');
      print('URL        : $url');
      print('Account No : $cleanAccountNo');
      print('Amount     : $amount');
      print('Reference  : $referenceNo');
      print('Request    : $body');

      final response = await http
          .post(
            url,
            headers: {
              'x-api-key':
                  _mpbApiKey,
              'Content-Type':
                  'application/json',
              'Accept':
                  'application/json',
              'x-source-system':
                  'TIP-${Config.terminalId}',
            },
            body:
                body,
          )
          .timeout(
            _timeout,
          );

      print(
        '[TAKSIRAN PAYMENT] Status: '
        '${response.statusCode}',
      );

      print(
        '[TAKSIRAN PAYMENT] Response: '
        '${response.body}',
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
        '[TAKSIRAN PAYMENT ERROR] $e',
      );

      return false;
    }
  }

  // ============================================================
  // MULTIPLE PAYMENT TO MPB API
  // ============================================================

  static Future<bool> payMultiple({
    required List<TaksiranPaymentItem> items,
    required String referenceNo,
  }) async {
    if (items.isEmpty) {
      return false;
    }

    for (final item in items) {
      final success =
          await payOne(
        accountNo:
            item.accountNo,
        amount:
            item.amount,
        referenceNo:
            referenceNo,
      );

      if (!success) {
        print(
          '[TAKSIRAN PAYMENT] Failed for account: '
          '${_cleanAccountNo(item.accountNo)}',
        );

        return false;
      }
    }

    print(
      '[TAKSIRAN PAYMENT] All MPB payments successful',
    );

    return true;
  }

  // ============================================================
  // SAVE PAYMENT UPDATE TO YOUR TIP BACKEND
  // ============================================================

  static Future<bool>
      postPaymentUpdateBentong({
    required List<TaksiranPaymentItem> items,
    required String orderNo,
    required String bankTrxNo,
    required String paymentMethod,
  }) async {
    if (items.isEmpty) {
      print(
        '[CUKAI PAYMENT UPDATE] No items supplied',
      );

      return false;
    }

    try {
      final uri = Uri.parse(
        '$_kioskBackendUrl'
        '/tax/payment-updates-cukaitaksiran-bentong',
      );

      final taxItems = items.map(
        (item) {
          return {
            'no_pendaftaran':
                item.noPendaftaran,
            'account_number':
                _cleanAccountNo(
              item.accountNo,
            ),
            'owner_name':
                item.ownerName,
            'property_address':
                item.propertyAddress,
            'amount':
                item.amount,
          };
        },
      ).toList();

      final body = jsonEncode({
        'order_no':
            orderNo,
        'paid_date':
            DateTime.now()
                .toIso8601String(),
        'payment_method':
            paymentMethod,
        'bank_trx_no':
            bankTrxNo,
        'tax_items':
            taxItems,
      });

      print('====================================');
      print('[CUKAI PAYMENT UPDATE BENTONG]');
      print('URL     : $uri');
      print('Request : $body');

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
        'Status Code: ${response.statusCode}',
      );

      print(
        'Response   : ${response.body}',
      );

      print('====================================');

      return response.statusCode >= 200 &&
          response.statusCode < 300;
    } catch (e) {
      print(
        '[CUKAI PAYMENT UPDATE BENTONG ERROR] $e',
      );

      return false;
    }
  }
}