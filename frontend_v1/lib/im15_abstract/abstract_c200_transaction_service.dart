import 'package:flutter/material.dart';
import 'package:frontend_v1/im15_utils/cancellation_token.dart';
import 'package:frontend_v1/im15_utils/payment_utils.dart';
import '../im15_controller/pax_im15_c200_sale.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_model/im15_response_parser.dart';
import '../im15_utils/im15_transaction_logger.dart';
import '../im15_utils/internet_checker.dart';
import '../im15_utils/payment_spinner.dart';

/// Abstract class for all C200 transaction services
abstract class AbstractC200TransactionService {
  // ============================================================
  // TESTING SWITCH — set to false before deploying to production.
  //
  // true  = ANY response from the card reader (declined, aborted,
  //         wrong PIN, whatever) is treated as a SUCCESSFUL payment.
  //         Use this to test the app's flow without needing a real
  //         approved bank transaction every time.
  //
  // false = REAL deployment behavior. Only a genuine approved
  //         status code ('00') from the bank counts as success.
  //         Everything else (declined, timeout, no response,
  //         aborted) is treated as a failure.
  // ============================================================
  static const bool forceSuccessForTesting = true;

  final BuildContext parentContext;
  final PaymentSpinner? spinner;
  final List<Function(bool)> interactiveSetters; // Functions to enable/disable buttons

  AbstractC200TransactionService(
      this.parentContext, this.spinner, this.interactiveSetters);

  /// Execute a C200 transaction with retries
  Future<void> execute(String rawAmount, String port, String traceNo,
      {required Future<void> Function() onSuccess, 
      required Future<void> Function() onFailure,
      CancellationToken? cancelToken,  
      VoidCallback? onCardDetected,
      VoidCallback? onPINRequired,
      VoidCallback? onCancelling,
      VoidCallback? onPINCompleted}) async {
    const int maxRetries = 2;
    _setInteractionEnabled(false);
     await  spinner?.show();

    IM15ResponseModel? response;
    final logger = IM15TransactionLogger(getTransactionTypeLabel());
    bool shouldCallFailure = false;
    bool pinRequested = false;

    if (forceSuccessForTesting) {
      print('[AbstractC200] ⚠️⚠️⚠️ TESTING MODE ACTIVE — any reader response '
          'will be treated as SUCCESS. Set forceSuccessForTesting = false '
          'before deploying. ⚠️⚠️⚠️');
    }

    try {
      // Internet check
      if (!await InternetChecker.isInternetAvailable()) {
        logger.logInfo("Internet unreachable. Might affect PAX communication.");
        _showWarning("Connection Error",
            "Internet not reachable. Ensure PAX IM15 has access.");
        shouldCallFailure = true;
        return;
      }

      // Amount validation
      if (!PaymentUtils.isValidAmount(rawAmount)) {
        _showWarning("Invalid Amount", "Missing or invalid amount. Please retry.");
        shouldCallFailure = true;
        return;
      }

      final paxFormattedAmount = PaymentUtils.formatForPaxTransaction(rawAmount);

      int attempts = 0;
      while (attempts < maxRetries) {
        if (cancelToken?.isCancelled == true) {
          print('[AbstractC200] 🛑 Cancelled by user, stopping retries');
          logger.logInfo("Transaction cancelled by user before attempt #${attempts + 1}");
          break;
        }
        try {
          logger.logInfo("${getTransactionTypeLabel()} Attempt #${attempts + 1}");
          
          // FIXED: Removed Future.any race condition - let transaction complete naturally
          // Individual timeouts in pax_im15_c200_sale.dart (10s each) prevent hanging
          print('[AbstractC200] 🚀 Starting transaction attempt #${attempts + 1}...');
          
          // Create sale instance and track PIN state
          final sale = PaxIM15C200Sale();
          
          // Check if PIN might be required based on amount
          final amountValue = double.tryParse(rawAmount) ?? 0.0;
          if (amountValue > 250.00 && !pinRequested) {
            print('[AbstractC200] ⚠️ Amount > RM250 - PIN may be required');
            // Don't show PIN dialog immediately, wait for actual PIN prompt from card reader
            // The pax_im15_c200_sale.dart will handle PIN prompts from the card reader
          }
          
          // Pass PIN callbacks to the sale execution
          response = await sale.executeSale(
            port, 
            paxFormattedAmount, 
            traceNo, 
            logger,
            cancelToken: cancelToken,
             onCardDetected: () {
              print('[AbstractC200] 💳 Card detected callback triggered');
              onCardDetected?.call();
            },
            onPINRequired: () {
              print('[AbstractC200] 📞 PIN required callback triggered');
              pinRequested = true;
              if (onPINRequired != null) {
                onPINRequired();
              }
            },
            onPINCompleted: () {
              print('[AbstractC200] 📞 PIN completed callback triggered');
              if (onPINCompleted != null) {
                onPINCompleted();
              }
            },
              onCancelling: () {
            print('[AbstractC200] ⏳ Cancelling callback triggered');
            onCancelling?.call();
          },
          );

          // ==========================================================
          // TESTING MODE: log what actually happened, but the real
          // success/failure decision for testing vs deploy is made
          // once, below, after the retry loop — not here.
          // ==========================================================
          print('[AbstractC200] 📥 Transaction returned: '
              '${response != null ? "response (status: ${response.statusCode})" : "NULL"}');

          if (response != null) {
            IM15ResponseParser.printDebug(response);
            logger.logInfo("Terminal responded with status: ${response.statusCode}");
            logger.logInfo("Amount: ${response.amount}");
            logger.logInfo("Card: ${response.cardNumber}");

            // Notify PIN completion if PIN was requested
            if (pinRequested && onPINCompleted != null) {
              onPINCompleted();
            }
            // Got a definitive answer from the terminal (approved or
            // declined) — don't retry, the terminal already decided.
            break;
          } else {
            logger.logInfo("Attempt #${attempts + 1} returned null. No response from card reader.");
            print('[AbstractC200] ❌ Attempt #${attempts + 1} returned null');

            // Don't show a timeout warning if the person deliberately cancelled
            if (cancelToken?.isCancelled == true) {
              break;
            }
                      
            // Show timeout warning on last attempt
            if (attempts == maxRetries - 1) {
              print("[AbstractC200] 🛑 Transaction Timeout");
            }
          }
        } catch (e) {
          logger.logInfo("Exception: ${e.toString()}");
          print('[AbstractC200] ⚠️ Exception in attempt #${attempts + 1}: $e');
          if (attempts == maxRetries - 1) {
            // Only show error on last attempt
            _showWarning("Transaction Error", "Failed to complete sale:\n$e");
          }
        } finally {
          attempts++;
        }
      }
    } catch (e) {
      logger.logInfo("Unexpected error: ${e.toString()}");
      print('[AbstractC200] ❌ Unexpected error: $e');
      _showWarning("System Error", "An unexpected error occurred:\n$e");
      shouldCallFailure = true;
    } finally {
      logger.endSession();
      // Ensure spinner is always hidden
      try {
        await spinner?.hide();
      } catch (e) {
        logger.logInfo("Error hiding spinner: ${e.toString()}");
      }
      _setInteractionEnabled(true);
    }

    // ============================================================
    // FINAL SUCCESS/FAILURE DECISION
    //
    // forceSuccessForTesting = true  -> any response counts as success
    // forceSuccessForTesting = false -> only statusCode == '00' counts
    // ============================================================
    final bool isSuccess = forceSuccessForTesting
        ? response != null
        : (response != null && response.statusCode == '00');

    if (isSuccess) {
      print("[AbstractC200] 🎉 Payment Successful - Calling onSuccess() "
          "(testing override: $forceSuccessForTesting)");
      await onSuccess();
    } else {
      print("[AbstractC200] ❌ Payment failed - Calling onFailure()");
      if (cancelToken?.isCancelled == true) {
        print("[AbstractC200] 🛑 Payment cancelled by user, skipping failure dialog");
      } else if (!shouldCallFailure) {
        print("[AbstractC200] 🛑 Payment Failed, The user didnt tap the card");
      }
      onFailure();
    }
  }

  /// Abstract method for transaction type label
  String getTransactionTypeLabel();

  void _showWarning(String title, String message) {
    showDialog(
      context: parentContext,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(parentContext), child: const Text("OK"))
        ],
      ),
    );
  }

  /// Enable/disable interactive components using passed setter functions
  void _setInteractionEnabled(bool enabled) {
    for (var setter in interactiveSetters) {
      setter(enabled);
    }
  }
}