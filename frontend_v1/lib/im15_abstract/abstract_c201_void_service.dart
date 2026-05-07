import 'package:flutter/material.dart';
import 'package:frontend_v1/im15_utils/im15_transaction_logger.dart';
import '../im15_controller/pax_im15_c201_void.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_utils/payment_spinner.dart';

abstract class AbstractC201VoidService {
  final BuildContext parentContext;
  final PaymentSpinner spinner;

  AbstractC201VoidService(this.parentContext, this.spinner);

  /// Execute a C201 void transaction
  void execute(String port, String hostNo, String amount, String traceNo,
      String refNo, {required VoidCallback onSuccess, required VoidCallback onFailure}) async {
    spinner.show();
    IM15ResponseModel? response;
    final logger = IM15TransactionLogger(getTransactionTypeLabel());

    try {
      response = await PaxIM15C201Void()
          .executeVoid(port, hostNo, amount, traceNo, refNo, logger);
    } catch (e) {
      logger.logInfo("Exception during C201: ${e.toString()}");
    } finally {
      logger.endSession();
      spinner.hide();
    }

    if (response != null && response.statusCode == "00") {
      onSuccess();
    } else {
      final code = response?.statusCode ?? "null";
      _showWarning(
          "C201 Failure",
          "Void Transaction Failed.\nStatus Code: $code\n${_getStatusDescription(code)}");
      onFailure();
    }
  }

  String getTransactionTypeLabel();

  String _getStatusDescription(String status) {
    switch (status) {
      case "00":
        return "Approved";
      case "VT":
        return "Transaction Already Voided";
      case "RE":
        return "Trace # Not Found (Record Error)";
      case "FE":
        return "Nothing to Void (Empty File)";
      case "TA":
        return "Transaction Aborted";
      case "ZE":
        return "Zero Amount (Already Settled)";
      default:
        return "Unknown or terminal-defined status";
    }
  }

  void _showWarning(String title, String message) {
    showDialog(
      context: parentContext,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(parentContext), child: Text("OK"))
        ],
      ),
    );
  }
}
