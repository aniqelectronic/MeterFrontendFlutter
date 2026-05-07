import 'package:flutter/material.dart';
import '../im15_controller/pax_im15_c208_query_transaction.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_utils/im15_transaction_logger.dart';
import '../im15_utils/payment_spinner.dart';

abstract class AbstractC208QueryService {
  final BuildContext parentContext;
  final PaymentSpinner spinner;

  AbstractC208QueryService(this.parentContext, this.spinner);

  void execute(String port, String hostNo, String traceNo,
      {required VoidCallback onSuccess, required VoidCallback onFailure}) async {
    spinner.show();
    IM15ResponseModel? response;
    final logger = IM15TransactionLogger(getTransactionTypeLabel());

    try {
      response = await PaxIM15C208QueryTransaction()
          .executeQuery(port, hostNo, traceNo, logger);
    } catch (e) {
      logger.logInfo("Exception: ${e.toString()}");
    } finally {
      logger.endSession();
      spinner.hide();
    }

    if (response != null && response.statusCode == "00") {
      onSuccess();
    } else {
      final code = response?.statusCode ?? "null";
      _showWarning(
          "C208 Failed",
          "Query Failed.\nStatus Code: $code\n${_getStatusDescription(code)}");
      onFailure();
    }
  }

  String getTransactionTypeLabel();

  String _getStatusDescription(String status) {
    switch (status) {
      case "00":
        return "Approved";
      case "VT":
        return "Voided Transaction";
      case "TA":
        return "Transaction Not Found / Aborted";
      default:
        return "Unknown or terminal-defined error";
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
