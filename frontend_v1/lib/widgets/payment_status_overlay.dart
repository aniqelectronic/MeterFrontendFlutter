import 'package:flutter/material.dart';

enum PaymentStage { waitingForCard, processing, success, failed }

class PaymentStatusOverlay extends StatefulWidget {
  const PaymentStatusOverlay({super.key});

  @override
  State<PaymentStatusOverlay> createState() => PaymentStatusOverlayState();
}

class PaymentStatusOverlayState extends State<PaymentStatusOverlay> {
  PaymentStage _stage = PaymentStage.waitingForCard;

  void setStage(PaymentStage stage) {
    if (mounted) {
      setState(() => _stage = stage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, title, subtitle) = switch (_stage) {
      PaymentStage.waitingForCard => (
          Icons.contactless,
          Colors.blue[700]!,
          "TAP YOUR CARD",
          "Please tap on the card reader",
        ),
      PaymentStage.processing => (
          Icons.sync,
          Colors.orange[700]!,
          "PROCESSING",
          "Please wait while we process\nyour payment...",
        ),
      PaymentStage.success => (
          Icons.check_circle,
          Colors.green[700]!,
          "PAYMENT SUCCESSFUL",
          "Redirecting to receipt...",
        ),
      PaymentStage.failed => (
          Icons.error,
          Colors.red[700]!,
          "PAYMENT FAILED",
          "Please try again",
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
                if (_stage == PaymentStage.processing)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}