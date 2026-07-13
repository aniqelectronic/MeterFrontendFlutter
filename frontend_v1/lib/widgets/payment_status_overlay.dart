import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

enum PaymentStage { waitingForCard, processing,cancelling, success, failed }

class PaymentStatusOverlay extends StatefulWidget {
  final VoidCallback? onCancel;
  const PaymentStatusOverlay({super.key, this.onCancel});

  @override
  State<PaymentStatusOverlay> createState() => PaymentStatusOverlayState();
}

class PaymentStatusOverlayState extends State<PaymentStatusOverlay> {
  PaymentStage _stage = PaymentStage.waitingForCard;

  void setStage(PaymentStage stage) {
    if (mounted) {
      setState(() => _stage = stage);
          // Force an immediate repaint instead of waiting for the next
    // natural frame tick — closes any gap between setState and paint.
    WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    
     print('[TIMING] Overlay build, stage=$_stage @ ${DateTime.now()}');
      final (icon, iconColor, title, subtitle) = switch (_stage) {
        PaymentStage.waitingForCard => (
            Icons.contactless,
            Colors.blue[700]!,
            l10n.paymentTapYourCard,
            l10n.paymentTapCardInstruction,
          ),
        PaymentStage.processing => (
            Icons.sync,
            Colors.orange[700]!,
            l10n.paymentProcessing,
            l10n.paymentProcessingInstruction,
          ),
        PaymentStage.success => (
            Icons.check_circle,
            Colors.green[700]!,
            l10n.paymentSuccessful,
            l10n.paymentSuccessInstruction,
          ),
        PaymentStage.cancelling => (
            Icons.cancel_schedule_send,
            Colors.orange[700]!,
            l10n.paymentCancelling,
            l10n.paymentCancellingInstruction,
          ),
        PaymentStage.failed => (
            Icons.error,
            Colors.red[700]!,
            l10n.paymentFailed,
            l10n.paymentFailedInstruction,
          ),
      };

    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_stage == PaymentStage.processing ||
                  _stage == PaymentStage.cancelling)
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(strokeWidth: 6, color: iconColor),
                  )
                else
                  Icon(icon, size: 90, color: iconColor),
                const SizedBox(height: 25),
                Text(
                  title,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: iconColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
            Text(
                  subtitle,
                  style: const TextStyle(fontSize: 22, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),

                // Only show Cancel while waiting for the tap — once real
                // card data starts flowing, cancelling mid-read could leave
                // the terminal in a weird state, so it's hidden after that.
                if (_stage == PaymentStage.waitingForCard && widget.onCancel != null) ...[
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child:  Text(
                        l10n.cancelButton,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}