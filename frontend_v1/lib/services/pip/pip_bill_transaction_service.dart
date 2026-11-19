import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

import 'pip_iimmpact_catalog_lookup.dart';

/// Shared QR test setting for all nine IIMMPACT/BIL payment pages.
/// The PIP transaction amount is always the actual customer-payable amount.
class PipBillQrSettings {
  static const bool enableQrTesting = true;
  static const double qrTestingAmount = 0.05;

  static double gatewayAmount(double originalCustomerTotal) {
    return enableQrTesting ? qrTestingAmount : originalCustomerTotal;
  }
}

/// Reports one PegePay QR attempt to PIP without blocking QR presentation.
///
/// PENDING: PegePay has created an order, but no bank payment is confirmed.
/// PAID: PegePay confirmed the bank payment (regardless of IIMMPACT outcome).
/// CANCELLED: the customer explicitly cancelled before bank confirmation.
///
/// The original amount, product details, order time and payment attempt ID
/// remain identical across the PENDING and final-status requests.
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
        _fallbackProductName = _short(
          productName,
          120,
          productCode.trim().toUpperCase(),
        ),
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

  // Catalog metadata is useful, but must not delay a payment event indefinitely.
  // The supplied catalog snapshot supplies a valid, immediate fallback.
  static const Duration catalogWaitTimeout = Duration(seconds: 1);

  // Like the working Parking/PBT flow, serialize outgoing BIL events to avoid
  // sending a newer PENDING ahead of an earlier attempt's final status.
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
  final String orderNo;
  final String? accountNo;
  final String? accountName;
  final DateTime orderCreatedAt;
  final String paymentAttemptId;

  PipIimmpactProduct? _catalogProduct;
  Future<void>? _catalogRequest;

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

  String get serviceType => _short(
        _catalogProduct?.productName ?? _fallbackProductName,
        120,
        productCode,
      );

  static String _short(String value, int maxLength, String fallback) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return fallback;
    return cleaned.length > maxLength
        ? cleaned.substring(0, maxLength)
        : cleaned;
  }

  static String? _optional(String? value, int maxLength) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) return null;
    return cleaned.length > maxLength
        ? cleaned.substring(0, maxLength)
        : cleaned;
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
      } catch (error, stackTrace) {
        debugPrint('[PIP BILL] Queue operation failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (!completer.isCompleted) completer.complete(false);
      }
    }).catchError((Object error, StackTrace stackTrace) {
      debugPrint('[PIP BILL] Reporting queue failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!completer.isCompleted) completer.complete(false);
    });

    return completer.future;
  }

  /// This diagnostic appears as soon as a BIL QR page calls pending().
  /// If it is absent, execution did not reach the BIL PIP service.
  Future<bool> pending() {
    debugPrint(
      '[PIP BILL] PENDING requested '
      'order=$orderNo attempt=$paymentAttemptId',
    );

    if (_pendingSaved) return Future<bool>.value(true);
    if (_pendingRequest != null) return _pendingRequest!;

    final request = _enqueue(() async {
      _pendingSaved = await _post(status: 'PENDING');
      return _pendingSaved;
    });

    _pendingRequest = request;
    unawaited(request.then<void>((_) {
      if (identical(_pendingRequest, request)) _pendingRequest = null;
    }));
    return request;
  }

  /// Call ONLY after PegePay's verified onSuccess callback.
  Future<bool> paid({String? bankTrxNo}) {
    debugPrint(
      '[PIP BILL] PAID requested '
      'order=$orderNo attempt=$paymentAttemptId',
    );

    if (_finalStatus == 'PAID') return Future<bool>.value(true);
    if (_finalStatus == 'CANCELLED') return Future<bool>.value(false);
    if (_finalRequest != null) return _finalRequest!;

    _paidStarted = true;
    _completedAt ??= DateTime.now().toUtc();
    final bank = bankTrxNo?.trim() ?? '';
    _bankTrxNo ??= bank.isEmpty ? null : bank;

    final request = _enqueue(() async {
      // A timed-out PENDING response may actually have been stored by PIP.
      // Retry the SAME payment attempt safely, then send PAID.
      if (!_pendingSaved) {
        _pendingSaved = await _post(status: 'PENDING');
      }
      if (!_pendingSaved) {
        debugPrint(
          '[PIP BILL] PAID not sent: PENDING unconfirmed '
          'order=$orderNo attempt=$paymentAttemptId',
        );
        return false;
      }

      _sentAt ??= DateTime.now().toUtc();
      if (_sentAt!.isBefore(_completedAt!)) _sentAt = _completedAt;

      final saved = await _post(status: 'PAID');
      if (saved) _finalStatus = 'PAID';
      return saved;
    });

    _finalRequest = request;
    unawaited(request.then<void>((_) {
      if (identical(_finalRequest, request)) _finalRequest = null;
    }));
    return request;
  }

  /// Only a customer cancellation before bank approval changes this status.
  Future<bool> cancelled() {
    debugPrint(
      '[PIP BILL] CANCELLED requested '
      'order=$orderNo attempt=$paymentAttemptId',
    );

    if (_paidStarted || _finalStatus == 'PAID') {
      debugPrint('[PIP BILL] Cancellation ignored: payment already confirmed.');
      return Future<bool>.value(false);
    }
    if (_finalStatus == 'CANCELLED') return Future<bool>.value(true);
    if (_finalRequest != null) return _finalRequest!;

    final request = _enqueue(() async {
      // Ensure the attempt exists before issuing CANCELLED. This also covers
      // the case where PENDING was written but its response was lost.
      if (!_pendingSaved) {
        _pendingSaved = await _post(status: 'PENDING');
      }
      if (!_pendingSaved) {
        debugPrint(
          '[PIP BILL] CANCELLED not sent: PENDING unconfirmed '
          'order=$orderNo attempt=$paymentAttemptId',
        );
        return false;
      }

      final saved = await _post(status: 'CANCELLED');
      if (saved) _finalStatus = 'CANCELLED';
      return saved;
    });

    _finalRequest = request;
    unawaited(request.then<void>((_) {
      if (identical(_finalRequest, request)) _finalRequest = null;
    }));
    return request;
  }

  Future<void> _ensureCatalog() => _catalogRequest ??= _resolveCatalog();

  Future<void> _resolveCatalog() async {
    // Snapshot is available immediately; never require an IIMMPACT network
    // response before a PIP transaction can be created.
    _catalogProduct = PipIimmpactCatalogLookup.snapshot(
      productCode: productCode,
      fallbackName: _fallbackProductName,
    );

    try {
      final liveProduct = await PipIimmpactCatalogLookup.resolve(
        productCode: productCode,
        fallbackName: _fallbackProductName,
      ).timeout(catalogWaitTimeout);

      // Freeze the chosen product details for this specific payment attempt.
      // PIP requires identical bill_details for PENDING and final statuses.
      _catalogProduct = liveProduct;
      debugPrint(
        '[PIP BILL] Catalog ready: '
        'group=${liveProduct.groupName} '
        'category=${liveProduct.categoryName} '
        'product=$productCode',
      );
    } on TimeoutException {
      debugPrint(
        '[PIP BILL] Catalog lookup exceeded 1 second; '
        'using bundled snapshot for $productCode.',
      );
    } catch (error) {
      debugPrint(
        '[PIP BILL] Catalog lookup failed for $productCode; '
        'using bundled snapshot: $error',
      );
    }
  }

  Map<String, dynamic> _payload(String status) {
    final paid = status == 'PAID';
    final product = _catalogProduct!;

    return <String, dynamic>{
      'terminal_id': terminalId,
      'branch_id': branchId,
      'category': 'BIL',
      'service_type': serviceType,
      'bill_details': product.toJson(
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

  Future<bool> _post({required String status}) async {
    // Log BEFORE validation or catalog lookup. Previously the first SEND log
    // appeared only after the potentially slow external catalog request.
    debugPrint(
      '[PIP BILL] PREPARE $status '
      'order=$orderNo attempt=$paymentAttemptId',
    );

    try {
      lastStatusCode = null;

      if (terminalId.isEmpty || branchId.isEmpty || baseUrl.isEmpty) {
        throw StateError('PIP terminalId, branchId or pipBaseUrl is missing.');
      }
      if (productCode.isEmpty || orderNo.isEmpty) {
        throw StateError('BIL product code or PegePay order number is missing.');
      }
      if (orderNo.length > 120) {
        throw StateError('PegePay order number exceeds 120 characters.');
      }
      if (!amount.isFinite || amount <= 0) {
        throw StateError('Original Bill Utilities total is invalid.');
      }
      if (!providerAmount.isFinite || providerAmount < 0) {
        throw StateError('Invalid BIL provider amount.');
      }
      if (!gatewayAmount.isFinite || gatewayAmount <= 0) {
        throw StateError('Invalid PegePay amount.');
      }

      // This is the private terminal credential, NOT Config.apiKey (HMAC).
      final key = Config.pipApiKey.trim();
      if (key.isEmpty) {
        throw StateError('PIP terminal API key is not configured.');
      }

      final uri = Uri.parse(
        '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$endpoint',
      );
      if (!const {'http', 'https'}.contains(uri.scheme) || !uri.hasAuthority) {
        throw StateError('Invalid PIP base URL: $baseUrl');
      }

      await _ensureCatalog();

      // No sensitive key or account number is printed to the journal.
      debugPrint(
        '[PIP BILL] SEND $status '
        'service=$serviceType terminal=$terminalId branch=$branchId '
        'attempt=$paymentAttemptId uri=$uri',
      );

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
      debugPrint(
        '[PIP BILL] HTTP $status status=${response.statusCode} '
        'order=$orderNo',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'PIP HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('PIP JSON response is not an object.');
      }

      final ref = decoded['pip_reference_no']?.toString().trim() ?? '';
      if (ref.isEmpty) {
        throw const FormatException('PIP response has no pip_reference_no.');
      }
      if (pipReferenceNo != null && pipReferenceNo != ref) {
        throw StateError('PIP returned a different reference for this attempt.');
      }

      pipReferenceNo = ref;
      lastError = null;
      debugPrint(
        '[PIP BILL] ACK $status '
        'amount=${amount.toStringAsFixed(2)} '
        'order=$orderNo reference=$ref',
      );
      return true;
    } catch (error, stackTrace) {
      lastError = error.toString();
      debugPrint(
        '[PIP BILL] $status unconfirmed: $error; '
        'order=$orderNo attempt=$paymentAttemptId',
      );
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}
