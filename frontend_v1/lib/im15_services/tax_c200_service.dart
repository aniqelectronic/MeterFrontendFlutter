import 'package:flutter/material.dart';
import '../im15_serial/im15_native_serial_transport.dart';
import '../im15_serial/im15_serial_connection_manager.dart';
import '../im15_serial/im15_transport.dart';
import '../im15_utils/payment_spinner.dart';
import '../im15_abstract/abstract_c200_transaction_service.dart';

/// Specialized C200 service for "Tax" transactions
class TaxC200Service extends AbstractC200TransactionService {
  final IM15SerialConnectionManager connMgr;
  IM15Transport? transport;

  TaxC200Service(
    BuildContext parentContext,
    PaymentSpinner? spinner,
    List<Function(bool)> interactiveSetters,
    this.connMgr,
  ) : super(parentContext, spinner, interactiveSetters);

  @override
  String getTransactionTypeLabel() => "C200 Sale-Tax";

  /// Override execute to use NATIVE serial transport (not libserialport)
  @override
  Future<void> execute(
    String rawAmount,
    String port,
    String traceNo, {
    void Function()? onCardDetected,
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
        onSuccess: onSuccess,
        onFailure: onFailure,
        onPINRequired: onPINRequired,
        onPINCompleted: onPINCompleted,
      );
    } finally {
      await _closeTransport();
    }
  }

  /// FIXED: Use IM15NativeSerialTransport instead of libserialport
  Future<void> _ensureTransport(String path) async {
    if (transport == null || !transport!.isOpen) {
      print('[TaxC200Service] Creating NATIVE transport for: $path');
      transport = IM15NativeSerialTransport(path, connMgr.cfg);
      await transport!.ensureOpen();
      print('[TaxC200Service] ✅ Native transport opened successfully');
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