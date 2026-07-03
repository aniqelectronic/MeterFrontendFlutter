import 'package:flutter/material.dart';
import 'package:frontend_v1/im15_utils/payment_utils.dart';
import '../im15_controller/pax_im15_c200_sale.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_model/im15_response_parser.dart';
import '../im15_utils/im15_transaction_logger.dart';
import '../im15_utils/internet_checker.dart';
import '../im15_utils/payment_spinner.dart';

/// Abstract class for all C200 transaction services
abstract class AbstractC200TransactionService {
  final BuildContext parentContext;
  final PaymentSpinner spinner;
  final List<Function(bool)> interactiveSetters; // Functions to enable/disable buttons

  AbstractC200TransactionService(
      this.parentContext, this.spinner, this.interactiveSetters);

  /// Execute a C200 transaction with retries
  Future<void> execute(String rawAmount, String port, String traceNo,
      {required Future<void> Function() onSuccess, 
     required Future<void> Function() onFailure,
      VoidCallback? onCardDetected,
       VoidCallback? onPINRequired,
       VoidCallback? onPINCompleted}) async {
    const int maxRetries = 5;
    _setInteractionEnabled(false);
    spinner.show();

    IM15ResponseModel? response;
    final logger = IM15TransactionLogger(getTransactionTypeLabel());
    bool shouldCallFailure = false;
    bool pinRequested = false;

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
          );
          print('[AbstractC200] 📥 Transaction returned: ${response != null ? "SUCCESS" : "NULL"}');

          if (response != null) {
            print('[AbstractC200] ✅ Transaction returned SUCCESS response');
            IM15ResponseParser.printDebug(response);
            logger.logInfo("Status: SUCCESS");
            logger.logInfo("Amount: ${response.amount}");
            logger.logInfo("Card: ${response.cardNumber}");
            
            // Notify PIN completion if PIN was requested
            if (pinRequested && onPINCompleted != null) {
              onPINCompleted();
            }
            break;
          } else {
            logger.logInfo("Attempt #${attempts + 1} returned null. No response from card reader.");
            print('[AbstractC200] ❌ Attempt #${attempts + 1} returned null');
            
            // Show timeout warning on last attempt
            if (attempts == maxRetries - 1) {
              _showWarning("Transaction Timeout", 
                "Card reader did not respond after ${maxRetries} attempts.\n\nPlease check:\n1. Card reader is powered on\n2. Card reader cable is connected\n3. Card is inserted properly");
            }
          }

          //when deploy 

          // final approved = response != null && response.statusCode == '00';
          // print('[AbstractC200] 📥 Transaction returned: ${response == null ? "NULL" : (approved ? "APPROVED" : "DECLINED (${response.statusCode})")}');

          // if (approved) {
          //   print('[AbstractC200] ✅ Transaction APPROVED');
          //   IM15ResponseParser.printDebug(response!);
          //   logger.logInfo("Status: APPROVED (${response.statusCode})");
          //   logger.logInfo("Amount: ${response.amount}");
          //   logger.logInfo("Card: ${response.cardNumber}");
            
          //   // Notify PIN completion if PIN was requested
          //   if (pinRequested && onPINCompleted != null) {
          //     onPINCompleted();
          //   }
          //   break;
          // } else if (response != null) {
          //   // Got a real response from the terminal, but it was declined/aborted.
          //   // Don't retry — the terminal gave a definitive answer.
          //   print('[AbstractC200] ❌ Transaction declined. Status: ${response.statusCode}');
          //   logger.logInfo("Transaction declined with status ${response.statusCode}");
          //   _showWarning("Transaction Declined",
          //       "The transaction was not approved (status: ${response.statusCode}). Please try again.");
          //   response = null; // treat as failure for the final success/failure check below
          //   break;
          // } else {
          //   logger.logInfo("Attempt #${attempts + 1} returned null. No response from card reader.");
          //   print('[AbstractC200] ❌ Attempt #${attempts + 1} returned null');
            
          //   // Show timeout warning on last attempt
          //   if (attempts == maxRetries - 1) {
          //     _showWarning("Transaction Timeout", 
          //       "Card reader did not respond after ${maxRetries} attempts.\n\nPlease check:\n1. Card reader is powered on\n2. Card reader cable is connected\n3. Card is inserted properly");
          //   }
          // }
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
        spinner.hide();
      } catch (e) {
        logger.logInfo("Error hiding spinner: ${e.toString()}");
      }
      _setInteractionEnabled(true);
    }

    // Handle success/failure callbacks
    if (response != null) {
//  if (response != null && response.statusCode == '00') {
      print("[AbstractC200] 🎉 Payment Successful - Calling onSuccess()");
      await onSuccess();
    } else {
      print("[AbstractC200] ❌ Payment failed - Calling onFailure()");
      if (!shouldCallFailure) {
        _showWarning("Payment Failed",
            "No response received after $maxRetries attempts.\n\nThe card reader may need to be reset. Please try again or contact support.");
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