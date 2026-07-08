import 'package:flutter/material.dart';
import 'package:frontend_v1/im15_utils/cancellation_token.dart';
import '../im15_serial/im15_native_serial_transport.dart';
import '../im15_serial/im15_serial_connection_manager.dart';
import '../im15_serial/im15_transport.dart';
import '../im15_utils/payment_spinner.dart';
import '../im15_abstract/abstract_c200_transaction_service.dart';

/// Specialized C200 service for "License" transactions
class LicenseC200Service extends AbstractC200TransactionService {
  final IM15SerialConnectionManager connMgr;
  IM15Transport? transport;

  LicenseC200Service(
    BuildContext parentContext,
    PaymentSpinner? spinner,
    List<Function(bool)> interactiveSetters,
    this.connMgr,
  ) : super(parentContext, spinner, interactiveSetters);

  @override
  String getTransactionTypeLabel() => "C200 Sale-License";

  /// Override execute to use NATIVE serial transport (not libserialport)
  @override
  Future<void> execute(
    String rawAmount,
    String port,
    String traceNo, {
    CancellationToken? cancelToken,
    void Function()? onCardDetected,
    void Function()? onCancelling,
    required Future<void> Function() onFailure,
    void Function()? onPINCompleted,
    void Function()? onPINRequired,
    required Future<void> Function() onSuccess,
  }) async {
    await _ensureTransport(port);
    try {
      await super.execute(
        rawAmount,
        port,
        traceNo,
        cancelToken: cancelToken,
        onSuccess: onSuccess,
        onFailure: onFailure,
        onCardDetected: onCardDetected,
        onPINRequired: onPINRequired,
        onPINCompleted: onPINCompleted,
        onCancelling: onCancelling,
      );
    } finally {
      await _closeTransport();
    }
  }

  /// FIXED: Use IM15NativeSerialTransport instead of libserialport
  Future<void> _ensureTransport(String path) async {
    if (transport == null || !transport!.isOpen) {
      print('[LicenseC200Service] Creating NATIVE transport for: $path');
      transport = IM15NativeSerialTransport(path, connMgr.cfg);
      await transport!.ensureOpen();
      print('[LicenseC200Service] ✅ Native transport opened successfully');
    }
  }

  /// Manager-independent close
  Future<void> _closeTransport() async {
    if (transport != null) {
      await transport!.close();
      transport = null;
    }
  }
}