import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

/// A real selected municipal account or compound allocation.
/// Amount is the selected bill allocation, not a nominal QR test charge.
class PipMunicipalPaymentItem {
  const PipMunicipalPaymentItem({
    required this.accountNo,
    required this.amount,
    this.accountName,
  });

  final String accountNo;
  final String? accountName;
  final double amount;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'account_no': accountNo.trim(),
        'account_name': accountName,
        'amount': amount.toStringAsFixed(2),
      };
}

/// Reports one Cukai, Sewaan or Kompaun payment attempt to PIP.
///
/// This class is intentionally independent of PipTransactionService.parking.
/// It does not touch the QR WebView, the parking provider, or kiosk windows.
/// A new PENDING lets PIP supersede the previous PENDING on this terminal.
class PipMunicipalTransactionService {
  PipMunicipalTransactionService({
    required this.serviceType,
    required this.amount,
    required this.paymentMethod,
    this.accountNo,
    this.accountName,
    List<PipMunicipalPaymentItem> paymentItems = const [],
  })  : paymentItems = List<PipMunicipalPaymentItem>.unmodifiable(paymentItems),
        terminalId = Config.terminalId.trim(),
        branchId = Config.branchId.trim(),
        baseUrl = Config.pipBaseUrl.trim(),
        createdAt = DateTime.now().toUtc(),
        paymentAttemptId =
            '${Config.terminalId.trim()}-${DateTime.now().microsecondsSinceEpoch}-'
            '${Random.secure().nextInt(1 << 32)}';

  static const String endpoint = '/api/ingest/payments';
  static const Duration requestTimeout = Duration(seconds: 10);

  final String serviceType;
  final double amount;
  final String paymentMethod;
  final String? accountNo;
  final String? accountName;
  final List<PipMunicipalPaymentItem> paymentItems;
  final String terminalId;
  final String branchId;
  final String baseUrl;
  final String paymentAttemptId;
  final DateTime createdAt;

  String? pipReferenceNo;
  String? lastError;
  bool _pendingSaved = false;
  bool _paidSaved = false;
  Future<bool>? _pendingInFlight;
  Future<bool>? _paidInFlight;
  DateTime? _completedAt;
  DateTime? _sentPaidAt;
  String? _bankReference;

  static String _iso(DateTime value) => value.toUtc().toIso8601String();

  Map<String, dynamic> _payload(String status) {
    final isPaid = status == 'PAID';

    final payload = <String, dynamic>{
      'terminal_id': terminalId,
      'branch_id': branchId,
      'category': 'PBT',
      'service_type': serviceType,
      'amount': amount.toStringAsFixed(2),
      'payment_method': paymentMethod,
      'payment_status': status,
      'order_created_at': _iso(createdAt),
      'payment_completed_at': isPaid ? _iso(_completedAt!) : null,
      'sent_to_pip_at': isPaid ? _iso(_sentPaidAt!) : null,
      'account_no': accountNo,
      'account_name': accountName,
      'payment_attempt_id': paymentAttemptId,
      'pip_reference_no': pipReferenceNo,
      'bank_trx_no': isPaid ? _bankReference : null,
    };

    // Send the SAME immutable allocations for PENDING and PAID.
    // Do not send an empty array: PIP rejects payment_items: [].
    if (paymentItems.isNotEmpty) {
      payload['payment_items'] =
          paymentItems.map((item) => item.toJson()).toList();
    }

    return payload;
  }

  Future<bool> _post(String status) async {
    try {
      if (terminalId.isEmpty || branchId.isEmpty) {
        lastError = 'Missing PIP terminalId or branchId in Config.';
        debugPrint('[PIP] $lastError');
        return false;
      }

      if (!amount.isFinite || amount <= 0) {
        lastError = 'Invalid PIP amount: $amount';
        debugPrint('[PIP] $lastError');
        return false;
      }

      if (paymentItems.isNotEmpty) {
        final seen = <String>{};
        var totalCents = 0;
        for (final item in paymentItems) {
          final number = item.accountNo.trim();
          if (number.isEmpty ||
              number.length > 120 ||
              !seen.add(number) ||
              !item.amount.isFinite ||
              item.amount <= 0 ||
              (item.amount * 100 - (item.amount * 100).round()).abs() > 0.00001) {
            lastError = 'Invalid municipal payment_items allocation.';
            debugPrint('[PIP] $lastError');
            return false;
          }
          totalCents += (item.amount * 100).round();
        }
        if (totalCents != (amount * 100).round()) {
          lastError = 'payment_items total differs from transaction amount.';
          debugPrint('[PIP] $lastError');
          return false;
        }
      }

      final uri = Uri.parse(
        '${baseUrl.replaceFirst(RegExp(r"/+$"), "")}$endpoint',
      );

      if (!uri.hasAuthority ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        lastError = 'Invalid Config.pipBaseUrl: $baseUrl';
        debugPrint('[PIP] $lastError');
        return false;
      }

      final payload = _payload(status);
      debugPrint(
        '[PIP] SEND $status service=$serviceType '
        'terminal=$terminalId account=${accountNo ?? "-"} '
        'attempt=$paymentAttemptId uri=$uri',
      );

      if (Config.pipApiKey.isEmpty) {
        lastError = 'PIP terminal API key is not configured.';
        debugPrint('[PIP] $lastError');
        return false;
      }

      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Terminal-Key': Config.pipApiKey,
        },
        body: jsonEncode(payload),
      ).timeout(requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError = 'HTTP ${response.statusCode}: ${response.body}';
        debugPrint('[PIP] $lastError');
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('PIP response must be a JSON object.');
      }

      final reference = decoded['pip_reference_no']?.toString().trim();
      if (reference == null || reference.isEmpty) {
        throw const FormatException('PIP response has no pip_reference_no.');
      }
      if (pipReferenceNo != null && pipReferenceNo != reference) {
        throw const FormatException('PIP changed the reference for one attempt.');
      }

      pipReferenceNo = reference;
      lastError = null;
      debugPrint(
        '[PIP] ACK $status service=$serviceType '
        'attempt=$paymentAttemptId reference=$reference '
        'duplicate=${decoded['duplicate']}',
      );
      return true;
    } catch (error) {
      // A timeout means unconfirmed, not necessarily rejected by PIP.
      lastError = error.toString();
      debugPrint('[PIP] $status unconfirmed: $error');
      return false;
    }
  }

  /// Send once for this attempt. Retry reuses the same payment_attempt_id.
  Future<bool> pending() {
    if (_pendingSaved) return Future<bool>.value(true);
    return _pendingInFlight ??= _sendPending();
  }

  Future<bool> _sendPending() async {
    try {
      final saved = await _post('PENDING');
      if (saved) _pendingSaved = true;
      return saved;
    } finally {
      _pendingInFlight = null;
    }
  }

  /// Called only after verified gateway/card success by payment.dart.
  /// Council updates are reported independently by that page.
  /// A nominal QR test must be restricted to an isolated test PIP backend.
  Future<bool> paid({String? bankTrxNo}) {
    if (_paidSaved) return Future<bool>.value(true);
    return _paidInFlight ??= _sendPaid(bankTrxNo: bankTrxNo);
  }

  Future<bool> _sendPaid({String? bankTrxNo}) async {
    try {
      if (!_pendingSaved && !await pending()) {
        debugPrint(
          '[PIP] $serviceType PAID not sent: PENDING is unconfirmed.',
        );
        return false;
      }

      _completedAt ??= DateTime.now().toUtc();
      _sentPaidAt ??= DateTime.now().toUtc();
      final reference = bankTrxNo?.trim();
      _bankReference ??=
          reference == null || reference.isEmpty || reference == '0'
              ? null
              : reference;

      final saved = await _post('PAID');
      if (saved) _paidSaved = true;
      return saved;
    } finally {
      _paidInFlight = null;
    }
  }
}
