import 'package:flutter/material.dart';
import '../im15_controller/pax_im15_c500_settlement.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_utils/im15_transaction_logger.dart';
import '../im15_utils/internet_checker.dart';
import '../im15_utils/payment_spinner.dart';

abstract class AbstractC500SettlementService {
  final BuildContext parentContext;
  final PaymentSpinner spinner;

  AbstractC500SettlementService(this.parentContext, this.spinner);

  void execute(String port, String hostNo,
      {required VoidCallback onSuccess, required VoidCallback onFailure}) async {
    spinner.show();
    IM15ResponseModel? response;
    final logger = IM15TransactionLogger(getTransactionTypeLabel());

    try {
      if (!await InternetChecker.isInternetAvailable()) {
        logger.logInfo("Internet unreachable.");
        return;
      }

      response = await PaxIM15C500Settlement().executeSettlement(port, hostNo);
      if (response != null) {
        logger.logInfo(
            "Settlement Success. BatchNo=${response.batchNo}, Status=${response.statusCode}");
      }
    } catch (e) {
      logger.logInfo("Exception: ${e.toString()}");
    } finally {
      logger.endSession();
      spinner.hide();
    }

    if (response != null) {
      if (response.statusCode == "00") {
        print("C500 Settlement: SUCCESS");
        onSuccess();
      } else {
        _showWarning(
            "C500 Rejected",
            "Settlement Rejected.\nStatus: ${response.statusCode}\n${_getStatusDescription(response.statusCode!)}");
        onFailure();
      }
    } else {
      print("C500 Settlement: FAILED (null response)");
      onFailure();
    }
  }

  String getTransactionTypeLabel();

  String _getStatusDescription(String status) {
    switch (status) {
      case "00":
        return "Approved";
      case "TA":
        return "Transaction Aborted";
      case "ZE":
        return "Zero Amount (Already Settled)";
      case "BU":
        return "Batch Not Found";
      case "PE":
        return "PIN Entry Error";
      case "CE":
        return "Comms Timeout";
      case "VT":
        return "Already Voided";
      default:
        return "Unknown or Host-defined status code";
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
