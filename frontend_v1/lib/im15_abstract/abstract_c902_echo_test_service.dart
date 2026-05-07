import 'package:flutter/material.dart';
import '../im15_controller/pax_im15_c902_echo_test.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_utils/im15_transaction_logger.dart';
import '../im15_utils/internet_checker.dart';
import '../im15_utils/payment_spinner.dart';

abstract class AbstractC902EchoTestService {
  final BuildContext parentContext;
  final PaymentSpinner spinner;

  AbstractC902EchoTestService(this.parentContext, this.spinner);

  void execute(String port,
      {required VoidCallback onSuccess, required VoidCallback onFailure}) async {
    const int maxRetries = 3;
    spinner.show();

    IM15ResponseModel? response;
    final logger = IM15TransactionLogger(getTransactionTypeLabel());

    try {
      if (!await InternetChecker.isInternetAvailable()) {
        logger.logInfo("Internet unreachable.");
        return;
      }

      int attempts = 0;
      while (attempts < maxRetries) {
        logger.logInfo("EchoTest Attempt #${attempts + 1}");
        response = await PaxIM15C902EchoTest().executeEchoTest(port, logger);
        if (response != null) break;
        attempts++;
      }
    } catch (e) {
      logger.logInfo("Exception: ${e.toString()}");
    } finally {
      logger.endSession();
      spinner.hide();
    }

    if (response != null) {
      print("C902 Echo Test: SUCCESS");
      onSuccess();
    } else {
      print("C902 Echo Test: FAILED");
      onFailure();
    }
  }

  String getTransactionTypeLabel();
}
