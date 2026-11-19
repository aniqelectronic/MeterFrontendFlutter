import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

import 'pip_iimmpact_catalog_lookup.dart';

/// One QR testing switch shared by all nine Bill Utilities QR pages.
/// When false, PegePay charges the actual customer-payable total.
class PipBillQrSettings {
  static const bool enableQrTesting = true;
  static const double qrTestingAmount = 0.05;

  static double gatewayAmount(double originalCustomerTotal) {
    return enableQrTesting ? qrTestingAmount : originalCustomerTotal;
  }
}

/// Reports a single Bill Utilities payment attempt to PIP.
/// PIP amount = original customer-payable total, NOT the test QR charge.
/// PIP status describes the bank payment, not the IIMMPACT fulfillment result.
///
/// The kiosk must have a registered terminal and its private pipApiKey.
/// This class does NOT store secrets or embed them in the source code.
class PipBillTransactionService {
  PipBillTransactionService({
    required String productCode,
    required String productName,
    required this.providerAmount,
    required this.gatewayAmount,
    required this.qrTesting,
    required this.amount,
    required String orderNo,
    String? accountNo,
    String? accountName,
    DateTime? createdAt,
  })  : productCode = productCode.trim().toUpperCase(),
        _fallbackProductName = _short(productName, 120, productCode.trim()),
        orderNo = orderNo.trim(),
        accountNo = _optional(accountNo, 120),
        accountName = _optional(accountName, 200),
        terminalId = Config.terminalId.trim(),
        branchId = Config.branchId.trim(),
        baseUrl = Config.pipBaseUrl.trim(),
        orderCreatedAt = (createdAt ?? DateTime.now()).toUtc(),
        paymentAttemptId = _newAttemptId(Config.terminalId.trim());

  static const String endpoint = '/api/ingest/payments';
  static const Duration requestTimeout = Duration(seconds: 12);

  static Future<void> _sendQueue = Future<void>.value();

  final String terminalId;
  final String branchId;
  final String baseUrl;
  final String productCode;
  final String _fallbackProductName;
  final double providerAmount;
  final double gatewayAmount;
  final bool qrTesting;
  final double amount;
  PipIimmpactProduct? _catalogProduct;
  Future<void>? _catalogRequest;

  String get serviceType => _short(
        _catalogProduct?.productName ?? _fallbackProductName,
        120,
        productCode,
      );
  final String orderNo;
  final String? accountNo;
  final String? accountName;
  final DateTime orderCreatedAt;
  final String paymentAttemptId;

  String? pipReferenceNo;
  String? lastError;
  int? lastStatusCode;

  Future<bool>? _pendingRequest;
  Future<bool>? _finalRequest;
  bool _pendingSaved = false;
  bool _paidStarted = false;
  String? _finalStatus;
  DateTime? _completedAt;
  DateTime? _sentAt;
  String? _bankTrxNo;

  static String _short(String value, int maxLength, String fallback) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return fallback;
    return cleaned.length > maxLength ? cleaned.substring(0, maxLength) : cleaned;
  }

  static String? _optional(String? value, int maxLength) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) return null;
    return cleaned.length > maxLength ? cleaned.substring(0, maxLength) : cleaned;
  }

  static String _newAttemptId(String terminalId) {
    final random = Random.secure().nextInt(1 << 32);
    return '$terminalId-${DateTime.now().microsecondsSinceEpoch}-$random';
  }

  static Future<bool> _enqueue(Future<bool> Function() operation) {
    final completer = Completer<bool>();
    _sendQueue = _sendQueue.then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, trace) {
        debugPrint('[PIP BILL] Reporting error: $error');
        debugPrintStack(stackTrace: trace);
        completer.complete(false);
      }
    }).catchError((Object error) {
      debugPrint('[PIP BILL] Queue error: $error');
      if (!completer.isCompleted) completer.complete(false);
    });
    return completer.future;
  }

  /// PENDING is created immediately after the PegePay QR order exists.
  Future<bool> pending() {
    if (_pendingSaved) return Future<bool>.value(true);
    return _pendingRequest ??= _enqueue(() async {
      _pendingSaved = await _post(status: 'PENDING');
      return _pendingSaved;
    });
  }

  /// Called only when PegePay verifies payment success.
  Future<bool> paid({String? bankTrxNo}) {
    if (_finalStatus == 'PAID') return Future<bool>.value(true);
    if (_finalStatus == 'CANCELLED') return Future<bool>.value(false);
    if (_finalRequest != null) return _finalRequest!;

    _paidStarted = true;
    _completedAt ??= DateTime.now().toUtc();
    final bank = bankTrxNo?.trim() ?? '';
    _bankTrxNo ??= bank.isEmpty ? null : bank;

    return _finalRequest = _enqueue(() async {
      if (!_pendingSaved) {
        // Recover the same attempt if the earlier PENDING request was unconfirmed.
        _pendingSaved = await _post(status: 'PENDING');
      }
      if (!_pendingSaved) {
        debugPrint('[PIP BILL] PAID not sent: PENDING is unconfirmed. '
            'order=$orderNo attempt=$paymentAttemptId');
        return false;
      }
      _sentAt ??= DateTime.now().toUtc();
      if (_sentAt!.isBefore(_completedAt!)) _sentAt = _completedAt;
      final saved = await _post(status: 'PAID');
      if (saved) _finalStatus = 'PAID';
      return saved;
    });
  }

  /// Only an explicit QR cancellation before bank approval is a cancellation.
  Future<bool> cancelled() {
    if (_paidStarted || _finalStatus == 'PAID') {
      return Future<bool>.value(false);
    }
    if (_finalStatus == 'CANCELLED') return Future<bool>.value(true);
    if (_finalRequest != null) return _finalRequest!;
    return _finalRequest = _enqueue(() async {
      if (!_pendingSaved) {
        // If PENDING was never accepted, PIP has nothing to cancel.
        return false;
      }
      final saved = await _post(status: 'CANCELLED');
      if (saved) _finalStatus = 'CANCELLED';
      return saved;
    });
  }

  Future<void> _ensureCatalog() => _catalogRequest ??= _resolveCatalog();

  Future<void> _resolveCatalog() async {
    _catalogProduct = await PipIimmpactCatalogLookup.resolve(
      productCode: productCode,
      fallbackName: _fallbackProductName,
    );
  }

  Map<String, dynamic> _payload(String status) {
    final paid = status == 'PAID';
    return <String, dynamic>{
      'terminal_id': terminalId,
      'branch_id': branchId,
      'category': 'BIL',
      'service_type': serviceType,
      'bill_details': _catalogProduct!.toJson(
        providerAmount: providerAmount,
        gatewayAmount: gatewayAmount,
        pegepayOrderNo: orderNo,
        qrTesting: qrTesting,
      ),
      'amount': amount.toStringAsFixed(2),
      'payment_method': 'DuitNow QR',
      'payment_status': status,
      'order_created_at': orderCreatedAt.toIso8601String(),
      'payment_completed_at': paid ? _completedAt!.toIso8601String() : null,
      'sent_to_pip_at': paid ? _sentAt!.toIso8601String() : null,
      'account_no': accountNo,
      'account_name': accountName,
      'payment_attempt_id': paymentAttemptId,
      'pip_reference_no': pipReferenceNo,
      'bank_trx_no': paid ? _bankTrxNo : null,
    };
  }

  Future<String> _readTerminalKey() async {
    // Prefer an explicit path to the existing private terminal.json.
    final customPath = Platform.environment['TIP_TERMINAL_JSON'] ?? '';
    final home = Platform.environment['HOME'] ?? '';
    final keyCandidates = <String>[
      Platform.environment['PIP_TERMINAL_KEY'] ?? '',
    ];
    for (final key in keyCandidates) {
      if (key.trim().isNotEmpty) return key.trim();
    }
    final paths = <String>[
      customPath,
      '/etc/tip/terminal.json',
      if (home.isNotEmpty) '$home/terminal.json',
      'terminal.json',
    ];
    for (final path in paths) {
      if (path.trim().isEmpty) continue;
      try {
        final file = File(path);
        if (!await file.exists()) continue;
        final config = jsonDecode(await file.readAsString());
        if (config is Map) {
          final key = config['pipApiKey']?.toString().trim() ?? '';
          if (key.isNotEmpty) return key;
        }
      } catch (error) {
        debugPrint('[PIP BILL] Could not read terminal configuration: $error');
      }
    }
    throw StateError(
      'PIP terminal API key missing. Set pipApiKey in the private '
      'terminal.json and point TIP_TERMINAL_JSON to that file.',
    );
  }

  Future<bool> _post({required String status}) async {
    try {
      await _ensureCatalog();
      if (terminalId.isEmpty || branchId.isEmpty || baseUrl.isEmpty) {
        throw StateError('PIP terminalId, branchId or pipBaseUrl is missing.');
      }
      if (!amount.isFinite || amount <= 0) {
        throw StateError('Original Bill Utilities total is invalid.');
      }
      final key = await _readTerminalKey();
      final uri = Uri.parse(
        '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$endpoint',
      );
      if (!const {'http', 'https'}.contains(uri.scheme) || !uri.hasAuthority) {
        throw StateError('Invalid PIP base URL.');
      }
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Terminal-Key': key,
        },
        body: jsonEncode(_payload(status)),
      ).timeout(requestTimeout);
      lastStatusCode = response.statusCode;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('PIP HTTP ${response.statusCode}: ${response.body}');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) throw const FormatException('PIP JSON response invalid');
      final ref = decoded['pip_reference_no']?.toString().trim() ?? '';
      if (ref.isEmpty) throw const FormatException('PIP reference missing');
      if (pipReferenceNo != null && pipReferenceNo != ref) {
        throw StateError('PIP returned a different reference for this attempt.');
      }
      pipReferenceNo = ref;
      lastError = null;
      debugPrint('[PIP BILL] ACK $status amount=${amount.toStringAsFixed(2)} '
          'service=$serviceType order=$orderNo reference=$ref');
      return true;
    } catch (error) {
      lastError = error.toString();
      debugPrint('[PIP BILL] $status unconfirmed: $error; '
          'order=$orderNo attempt=$paymentAttemptId');
      return false;
    }
  }
}
