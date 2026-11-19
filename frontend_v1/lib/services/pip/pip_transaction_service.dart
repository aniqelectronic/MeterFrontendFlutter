import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:http/http.dart' as http;

/// A real account/compound allocation, using the keys accepted by PIP.
/// Never divide a combined payment to invent individual account amounts.
class PipPaymentItem {
  const PipPaymentItem({
    required this.accountNo,
    required this.amount,
    this.accountName,
  });

  final String accountNo;
  final String? accountName;
  final double amount;

  Map<String, dynamic> toJson() => {
        'account_no': accountNo.trim(),
        'account_name': accountName,
        'amount': amount.toStringAsFixed(2),
      };
}

/// One instance is ONE attempt, not one status update.
/// No WebView, Navigator, timers, Linux commands or payment-provider calls.
class PipTransactionService {
  PipTransactionService.parking({
    required this.amount,
    required this.paymentMethod,
    required this.vehicleNo,
    required this.durationMinutes,
    this.negeri,
    this.kawasan,
    this.zon,
    this.parkingPaymentType = 'NEW',
    this.parkingSessionId,
    DateTime? createdAt,
    http.Client? client,
  })  : serviceType = 'Parking',
        accountNo = vehicleNo,
        accountName = null,
        paymentItems = const [],
        terminalId = Config.terminalId.trim(),
        branchId = Config.branchId.trim(),
        _baseUrl = Config.pipBaseUrl,
        _client = client,
        orderCreatedAt = (createdAt ?? DateTime.now()).toUtc(),
        paymentAttemptId = _newAttemptId();

  PipTransactionService.municipal({
    required this.amount,
    required this.paymentMethod,
    required this.serviceType,
    this.accountNo,
    this.accountName,
    List<PipPaymentItem> items = const [],
    DateTime? createdAt,
    http.Client? client,
  })  : paymentItems = List<PipPaymentItem>.unmodifiable(items),
        vehicleNo = '',
        durationMinutes = 0,
        negeri = null,
        kawasan = null,
        zon = null,
        parkingPaymentType = 'NEW',
        parkingSessionId = null,
        terminalId = Config.terminalId.trim(),
        branchId = Config.branchId.trim(),
        _baseUrl = Config.pipBaseUrl,
        _client = client,
        orderCreatedAt = (createdAt ?? DateTime.now()).toUtc(),
        paymentAttemptId = _newAttemptId();

  static String get baseUrl => Config.pipBaseUrl;
  static const String endpoint = '/api/ingest/payments';
  static const Duration requestTimeout = Duration(seconds: 10);

  final String terminalId;
  final String branchId;
  final String _baseUrl;
  final http.Client? _client;

  // Serialize reporting in this app, without blocking payment/QR display.
  // A queued PAID cannot be overtaken by a later new PENDING from this app.
  static Future<void> _operationTail = Future<void>.value();

  static void _enqueue(Future<void> Function() operation) {
    _operationTail = _operationTail.then((_) => operation()).catchError(
      (Object error, StackTrace trace) {
        debugPrint('[PIP] Reporting queue error: $error');
      },
    );
  }
  final double amount;
  final String paymentMethod;
  final String serviceType;
  final String? accountNo;
  final String? accountName;
  final List<PipPaymentItem> paymentItems;
  final String vehicleNo;
  final int durationMinutes;
  final String? negeri;
  final String? kawasan;
  final String? zon;
  final String parkingPaymentType;
  String? parkingSessionId;
  final DateTime orderCreatedAt;
  final String paymentAttemptId;
  String? pipReferenceNo;

  // Diagnostic correlation only: the supplied PIP schema does not store order_no.
  String? orderNo;
  String? lastError;
  int? lastStatusCode;

  bool _pendingSaved = false;
  Future<bool>? _pendingRequest;
  String? _finalStatus;
  String? _requestedFinalStatus;
  Future<bool>? _finalRequest;
  DateTime? _paidCompletedAt;
  DateTime? _paidSentAt;
  String? _paidBankTrxNo;
  bool _paidDetailsCaptured = false;
  Map<String, dynamic>? _finalPayload;

  bool get pendingSaved => _pendingSaved;
  String? get finalStatus => _finalStatus;

  static String _newAttemptId() =>
      '${Config.terminalId.trim()}-${DateTime.now().microsecondsSinceEpoch}-'
      '${Random.secure().nextInt(1 << 32)}';

  static String _timestamp(DateTime value) => value.toUtc().toIso8601String();

  static int _cents(double value) => (value * 100).round();

  String? _validationError() {
    if (terminalId.isEmpty || branchId.isEmpty) {
      return 'terminalId and branchId must be loaded before starting payment.';
    }
    if (!amount.isFinite || amount <= 0) return 'Payment amount must be positive.';
    if ((_cents(amount) / 100 - amount).abs() > 0.000001) {
      return 'Payment amount must have at most two decimal places.';
    }
    if (serviceType == 'Parking') {
      if (vehicleNo.trim().isEmpty) return 'Parking vehicle number is empty.';
      if (durationMinutes <= 0 || durationMinutes > 10080) {
        return 'Parking duration_minutes must be between 1 and 10080.';
      }
      if (parkingPaymentType != 'NEW' && parkingPaymentType != 'EXTENSION') {
        return 'parking_payment_type must be NEW or EXTENSION.';
      }
    } else if (!const {'Cukai Taksiran', 'Sewaan Majlis', 'Kompaun'}
        .contains(serviceType)) {
      return 'Unsupported municipal service: $serviceType';
    }
    if ((accountNo?.length ?? 0) > 120 || (accountName?.length ?? 0) > 200) {
      return 'Account number/name exceeds the PIP database field length.';
    }
    final numbers = <String>{};
    var total = 0;
    for (final item in paymentItems) {
      final number = item.accountNo.trim();
      if (number.isEmpty || number.length > 120 || !numbers.add(number)) {
        return 'payment_items account numbers must be non-empty and unique.';
      }
      if (!item.amount.isFinite || item.amount <= 0 ||
          (_cents(item.amount) / 100 - item.amount).abs() > 0.000001) {
        return 'Each payment item requires its real positive two-decimal amount.';
      }
      if ((item.accountName?.length ?? 0) > 200) {
        return 'An account name exceeds 200 characters.';
      }
      total += _cents(item.amount);
    }
    if (paymentItems.isNotEmpty && total != _cents(amount)) {
      return 'payment_items total does not equal the transaction amount.';
    }
    return null;
  }

  Map<String, dynamic> _payload({required String status}) {
    final isPaid = status == 'PAID';
    final payload = <String, dynamic>{
      'terminal_id': terminalId,
      'branch_id': branchId,
      'category': 'PBT',
      'service_type': serviceType,
      'amount': amount.toStringAsFixed(2),
      'payment_method': paymentMethod,
      'payment_status': status,
      'order_created_at': _timestamp(orderCreatedAt),
      'payment_completed_at': isPaid ? _timestamp(_paidCompletedAt!) : null,
      'sent_to_pip_at': isPaid ? _timestamp(_paidSentAt!) : null,
      'account_no': accountNo,
      'account_name': accountName,
      'payment_attempt_id': paymentAttemptId,
      'pip_reference_no': pipReferenceNo,
      'bank_trx_no': isPaid ? _paidBankTrxNo : null,
    };
    if (serviceType == 'Parking') {
      // Preserve the working parking contract. PIP computes session times.
      payload['parking_payment_type'] = parkingPaymentType;
      payload['parking_details'] = {
        'vehicle_no': vehicleNo,
        'negeri': negeri,
        'kawasan': kawasan,
        'zon': zon,
        'parking_session_id': parkingSessionId,
        'duration_minutes': durationMinutes,
      };
    } else if (paymentItems.isNotEmpty) {
      payload['payment_items'] = paymentItems.map((item) => item.toJson()).toList();
    }
    return payload;
  }

  Future<bool> _post(Map<String, dynamic> payload) async {
    try {
      lastStatusCode = null;
      final validation = _validationError();
      if (validation != null) {
        lastError = validation;
        debugPrint('[PIP] NOT SENT: $validation');
        return false;
      }
      final uri = Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/+$'), '')}$endpoint');
      if (!uri.hasAuthority || !const {'http', 'https'}.contains(uri.scheme)) {
        lastError = 'Invalid Config.pipBaseUrl.';
        debugPrint('[PIP] NOT SENT: $lastError');
        return false;
      }
      debugPrint(
        '[PIP] SEND ${payload['payment_status']} '
        'service=$serviceType terminal=$terminalId branch=$branchId '
        'attempt=$paymentAttemptId account=${accountNo ?? '-'} uri=$uri',
      );
      if (Config.pipApiKey.isEmpty) {
        lastError = 'PIP terminal API key is not configured.';
        debugPrint('[PIP] $lastError');
        return false;
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Terminal-Key': Config.pipApiKey,
      };
      final body = jsonEncode(payload);
      final client = _client;
      final response = await (client != null
              ? client.post(uri, headers: headers, body: body)
              : http.post(uri, headers: headers, body: body))
          .timeout(requestTimeout);
      lastStatusCode = response.statusCode;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError = 'HTTP ${response.statusCode}: ${response.body}';
        debugPrint('[PIP] $lastError');
        return false;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('PIP response is not a JSON object.');
      }
      final reference = decoded['pip_reference_no']?.toString().trim() ?? '';
      if (reference.isEmpty) {
        throw const FormatException('PIP response has no pip_reference_no.');
      }
      if (pipReferenceNo != null && pipReferenceNo != reference) {
        throw const FormatException('PIP returned a different transaction reference.');
      }
      pipReferenceNo = reference;
      final sessionId = decoded['parking_session_id']?.toString().trim();
      if (serviceType == 'Parking' && sessionId != null && sessionId.isNotEmpty) {
        // PIP may legitimately start NEW when an extension has no active session.
        parkingSessionId = sessionId;
      }
      lastError = null;
      debugPrint(
        '[PIP] ACK ${payload['payment_status']} '
        'attempt=$paymentAttemptId reference=$pipReferenceNo '
        'duplicate=${decoded['duplicate']}',
      );
      return true;
    } catch (error) {
      lastError = error.toString();
      debugPrint('[PIP] Outcome UNCONFIRMED: $error; attempt=$paymentAttemptId');
      // A timeout does not prove that the server rejected or rolled back a write.
      return false;
    }
  }

  Future<bool> pending() {
    if (_pendingSaved) return Future<bool>.value(true);
    final inFlight = _pendingRequest;
    if (inFlight != null) return inFlight;
    final completion = Completer<bool>();
    _pendingRequest = completion.future;
    _enqueue(() => _savePending(completion));
    return completion.future;
  }

  Future<void> _savePending(Completer<bool> completion) async {
    var saved = false;
    try {
      saved = _pendingSaved || await _post(_payload(status: 'PENDING'));
      if (saved) _pendingSaved = true;
    } catch (error) {
      lastError = error.toString();
      debugPrint('[PIP] PENDING error: $error');
    } finally {
      _pendingRequest = null;
      completion.complete(saved);
    }
  }

  /// Invoke only after verified gateway approval and the required provider update.
  /// This method cannot independently confirm a bank transaction.
  Future<bool> paid({DateTime? completedAt, String? bankTrxNo}) {
    final bank = (bankTrxNo ?? '').trim();
    final normalizedBank = bank.isEmpty ? null : bank;
    if (_paidDetailsCaptured && normalizedBank != _paidBankTrxNo) {
      debugPrint('[PIP] Refusing changed bank reference on a PAID retry.');
      return Future<bool>.value(false);
    }
    if (!_paidDetailsCaptured) {
      _paidCompletedAt = (completedAt ?? DateTime.now()).toUtc();
      _paidBankTrxNo = normalizedBank;
      _paidDetailsCaptured = true;
    }
    return _finalize('PAID');
  }

  /// Only explicit payment-provider rejection qualifies, not timeout/closed UI.
  Future<bool> failed({bool confirmed = false}) {
    if (!confirmed) {
      debugPrint('[PIP] Failure unconfirmed; leaving the attempt PENDING.');
      return Future<bool>.value(false);
    }
    return _finalize('FAILED');
  }

  /// Compatibility with older call sites only. NO HTTP request is made.
  /// The next new PENDING on the same terminal supersedes the old one in PIP.
  @Deprecated('Cancellation is managed by PIP; do not call from payment callbacks.')
  Future<bool> cancelled() {
    debugPrint('[PIP] Client cancellation disabled; no status update sent.');
    return Future<bool>.value(false);
  }

  Future<bool> _finalize(String status) {
    if (_finalStatus != null) return Future<bool>.value(_finalStatus == status);
    if (_requestedFinalStatus != null && _requestedFinalStatus != status) {
      debugPrint('[PIP] Conflicting final update blocked: $_requestedFinalStatus / $status');
      return Future<bool>.value(false);
    }
    final inFlight = _finalRequest;
    if (inFlight != null) return inFlight;
    _requestedFinalStatus = status;
    final completion = Completer<bool>();
    _finalRequest = completion.future;
    _enqueue(() => _sendFinal(status, completion));
    return completion.future;
  }

  Future<void> _sendFinal(String status, Completer<bool> completion) async {
    var saved = false;
    try {
      // Do not enqueue pending() from inside this queued operation.
      // This also handles PAID after an unconfirmed/lost PENDING response.
      if (!_pendingSaved) {
        _pendingSaved = await _post(_payload(status: 'PENDING'));
      }
      if (!_pendingSaved) {
        debugPrint('[PIP] PENDING unconfirmed; $status requires reconciliation.');
        return;
      }
      if (status == 'PAID') {
        _paidSentAt ??= DateTime.now().toUtc();
        if (_paidSentAt!.isBefore(_paidCompletedAt!)) {
          lastError = 'Completion time is after the send time; check kiosk clock.';
          debugPrint('[PIP] $lastError');
          return;
        }
      }
      // A retry must use the same immutable financial identity and timestamps.
      _finalPayload ??= _payload(status: status);
      saved = await _post(_finalPayload!);
      if (saved) _finalStatus = status;
    } catch (error) {
      lastError = error.toString();
      debugPrint('[PIP] $status error: $error');
    } finally {
      _finalRequest = null;
      completion.complete(saved);
    }
  }
}
