import 'package:flutter/material.dart';
import 'package:frontend_v1/im15_utils/cancellation_token.dart';
import '../im15_serial/im15_native_serial_transport.dart';
import '../im15_serial/im15_serial_connection_manager.dart';
import '../im15_serial/im15_transport.dart';
import '../im15_utils/payment_spinner.dart';
import '../im15_abstract/abstract_c200_transaction_service.dart';

/// Specialized C200 service for "Parking" transactions
class ParkingC200Service extends AbstractC200TransactionService {
  final IM15SerialConnectionManager connMgr;
  IM15Transport? transport;

  ParkingC200Service(
    BuildContext parentContext,
    PaymentSpinner? spinner,
    List<Function(bool)> interactiveSetters,
    this.connMgr,
  ) : super(parentContext, spinner, interactiveSetters);

  @override
  String getTransactionTypeLabel() => "C200 Sale-Parking";

  /// Override execute to use NATIVE serial transport (not libserialport)
  @override
  Future<void> execute(
    String rawAmount,
    String port, // This is the path you found in payment.dart
    String traceNo, {
    CancellationToken? cancelToken,
    void Function()? onCardDetected,
    void Function()? onCancelling,
    required Future<void> Function() onFailure,
    void Function()? onPINCompleted,
    void Function()? onPINRequired,
    required Future<void> Function() onSuccess,
  }) async {
    // Use the explicit port passed in rather than auto-detecting again
        
  // Do NOT open the serial port here.
  // PaxIM15C200Sale / IM15NativeSerialManager will open it.
 //   await _ensureTransport(port); 
    try {
    await super.execute(
      rawAmount,
      port,
      traceNo,
      cancelToken: cancelToken,
      onSuccess: onSuccess,
      onFailure: onFailure,
      onCardDetected: onCardDetected,
      onCancelling: onCancelling,
      onPINRequired: onPINRequired,
      onPINCompleted: onPINCompleted,
    );
    } finally {
      await _closeTransport();
    }
  }

  Future<void> _ensureTransport(String path) async {
    if (transport == null || !transport!.isOpen) {
      // FIXED: Use IM15NativeSerialTransport instead of IM15SerialTransport
      print('[ParkingC200Service] Creating NATIVE transport for: $path');
      transport = IM15NativeSerialTransport(path, connMgr.cfg);
      await transport!.ensureOpen();
      print('[ParkingC200Service] ✅ Native transport opened successfully');
    }
  }

  Future<void> _closeTransport() async {
    if (transport != null) {
      await transport!.close();
      transport = null;
    }
  }
}