import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/license/license_service.dart';
import 'package:frontend_v1/controllers/parking/parking_controller.dart';
// import 'package:frontend_v1/controllers/tax/tax_service.dart';
import 'package:frontend_v1/im15_abstract/abstract_c200_transaction_service.dart';
import 'package:frontend_v1/im15_serial/im15_port_detector.dart';
import 'package:frontend_v1/im15_serial/im15_serial_connection_manager.dart';
import 'package:frontend_v1/im15_serial/im15_serial_settings.dart';
import 'package:frontend_v1/im15_services/compound_c200_service.dart';
// import 'package:frontend_v1/im15_services/license_c200_service.dart';
import 'package:frontend_v1/im15_services/parking_c200_service.dart';
import 'package:frontend_v1/im15_services/tax_c200_service.dart';
import 'package:frontend_v1/im15_utils/cancellation_token.dart';
// import 'package:frontend_v1/im15_utils/payment_spinner.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/tax/payment_tax_item.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/resit/resit.dart';
import 'package:frontend_v1/main.dart';
//import 'package:frontend_v1/pages/pin_entry.dart'; // Import new PIN entry screen
// import 'package:frontend_v1/services/pegepay_qr_page.dart';
import 'package:frontend_v1/services/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay_webview_helper.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:intl/intl.dart';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';
import 'package:frontend_v1/controllers/taksiran/taksiran_payment_service_bentong.dart';
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';
import 'package:frontend_v1/controllers/sewaan/sewaan_payment_service_bentong.dart';
import 'package:window_manager/window_manager.dart';
import 'package:frontend_v1/widgets/payment_status_overlay.dart';

class PaymentData {
  String? plate;
  String? biz;
  int? hour;
  String? amount;
  String? samanNo;
  String? licenseNo;
  String? accountNo;
  List<PaymentTaxItem>? taxItems;
  List<String>? licenseNos;
  List<String>? compoundNos;
  List<TaksiranPaymentItem>? taksiranItems;
  List<SewaanPaymentItem>? sewaanItems;

  String? offenderName;
  String? violationType;
  String? kodhasil;
  String? date;
  String? time;

  PaymentData({
    this.biz,
    this.plate,
    this.hour,
    this.amount,
    this.samanNo,
    this.licenseNo,
    this.accountNo,
    this.taxItems,
    this.licenseNos, 
    this.compoundNos,
    this.offenderName,
    this.violationType,
    this.kodhasil,
    this.date,
    this.time,
    this.taksiranItems,
    this.sewaanItems,
  });

}

void showProcessingDialog(BuildContext context,
    { required String message,}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(strokeWidth: 6),
                ),
                const SizedBox(height: 25),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showCardPaymentSuccessDialog(
  BuildContext context, {
  required String amount,
}) async {
  final l10n = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 650,
            padding: const EdgeInsets.symmetric(
              horizontal: 45,
              vertical: 45,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 25,
                  spreadRadius: 4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F8EE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF169B62),
                      width: 5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 100,
                    color: Color(0xFF169B62),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  l10n.cardPaymentSuccessTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF087443),
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  l10n.cardPaymentSuccessMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFB7CAE8),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.totalAmountText,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'RM $amount',
                        style: const TextStyle(
                          color: Color(0xFF0359D2),
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const SizedBox(
                  width: 65,
                  height: 65,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: Color(0xFF0359D2),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  l10n.cardPreparingReceipt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0359D2),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  l10n.cardPleaseWaitNotice,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void showLoadingDialog(BuildContext context, {String message = "Loading..."}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 15),
            Text(
              message,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black,),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

void showPINEntryDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 20),
            Text(
              "PIN REQUIRED",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Please enter your PIN\non the card reader",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow[700]!, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.orange[700],
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Waiting for PIN entry...",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



enum QrTransitionStage {
  opening,
  success,
  closing,
}

class QrTransitionOverlayController {
  final ValueNotifier<QrTransitionStage> stage;
  final OverlayEntry entry;

  bool _removed = false;

  QrTransitionOverlayController({
    required this.stage,
    required this.entry,
  });

  void showSuccess() {
    if (_removed) return;
    stage.value = QrTransitionStage.success;
  }

  void showClosing() {
    if (_removed) return;
    stage.value = QrTransitionStage.closing;
  }

  void remove() {
    if (_removed) return;
    _removed = true;

    try {
      entry.remove();
    } catch (_) {
      // The overlay may already have been removed.
    }

    stage.dispose();
  }
}

QrTransitionOverlayController showQrTransitionOverlay(
  BuildContext context, {
  required String amount,
}) {
  final l10n = AppLocalizations.of(context)!;

  final stageNotifier = ValueNotifier<QrTransitionStage>(
    QrTransitionStage.opening,
  );

  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: Material(
        color: const Color(0xFF071A2F),
        child: PopScope(
          canPop: false,
          child: ValueListenableBuilder<QrTransitionStage>(
            valueListenable: stageNotifier,
            builder: (context, stage, child) {
              final bool paymentSuccess =
                  stage == QrTransitionStage.success;
              final bool paymentClosing =
                  stage == QrTransitionStage.closing;

              final Color accentColor = paymentSuccess
                  ? const Color(0xFF169B62)
                  : paymentClosing
                      ? const Color(0xFFE58B17)
                      : const Color(0xFF0359D2);

              final Color borderColor = paymentSuccess
                  ? const Color(0xFFB9D8C7)
                  : paymentClosing
                      ? const Color(0xFFF0D2A7)
                      : const Color(0xFFB7CAE8);

              final Color panelColor = paymentSuccess
                  ? const Color(0xFFE7F8EE)
                  : paymentClosing
                      ? const Color(0xFFFFF4E3)
                      : const Color(0xFFF2F7FD);

              final String title = paymentSuccess
                  ? l10n.qrPaymentSuccessTitle
                  : paymentClosing
                      ? l10n.qrClosingPaymentTitle
                      : l10n.qrOpeningPayment;

              final String message = paymentSuccess
                  ? l10n.qrPaymentSuccessMessage
                  : paymentClosing
                      ? l10n.qrClosingPaymentMessage
                      : l10n.qrOpeningPaymentMessage;

              return Center(
                child: Container(
                  width: 660,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 46,
                    vertical: 44,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 36,
                        spreadRadius: 4,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: paymentSuccess
                            ? Container(
                                key: const ValueKey('qr-success'),
                                width: 138,
                                height: 138,
                                decoration: BoxDecoration(
                                  color: panelColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accentColor,
                                    width: 5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 96,
                                  color: accentColor,
                                ),
                              )
                            : SizedBox(
                                key: ValueKey(
                                  paymentClosing
                                      ? 'qr-closing'
                                      : 'qr-opening',
                                ),
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  strokeWidth: 8,
                                  color: accentColor,
                                ),
                              ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: paymentSuccess
                              ? const Color(0xFF087443)
                              : paymentClosing
                                  ? const Color(0xFFB86800)
                                  : const Color(0xFF0359D2),
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF24364B),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 26),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 19,
                        ),
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.qrTotalAmount,
                              style: const TextStyle(
                                color: Color(0xFF53657A),
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'RM $amount',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (paymentSuccess) ...[
                        const SizedBox(height: 27),
                        const SizedBox(
                          width: 62,
                          height: 62,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            color: Color(0xFF0359D2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.qrPreparingReceipt,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF0359D2),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.qrPleaseWaitNotice,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF5A6878),
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],

                      if (paymentClosing) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.qrClosingPleaseWait,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF7B5A2C),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Overlay.of(
    context,
    rootOverlay: true,
  ).insert(entry);

  return QrTransitionOverlayController(
    stage: stageNotifier,
    entry: entry,
  );
}


class PAYMENTPAGE extends StatefulWidget {
  final String biz;
  final PaymentData data;

  static bool _transactionInProgress = false;

  const PAYMENTPAGE({
    super.key,
    required this.biz,
    required this.data,
  });

  @override
  State<PAYMENTPAGE> createState() => _PAYMENTPAGEState();
}

class _PAYMENTPAGEState extends State<PAYMENTPAGE> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPaymentGuideDialog(context);
    });
  }

  Future<void> showPaymentGuideDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          width: 900,
          height: 1500,
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Text(
                "PANDUAN PEMBAYARAN",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0359D2),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "PAYMENT GUIDE",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        "lib/images/card_guide.png",
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30),
                      Image.asset(
                        "lib/images/qr_guide.png",
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 300,
                height: 80,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0359D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

        Future<bool> showCardConfirmationDialog(BuildContext context) async {
        final l10n = AppLocalizations.of(context)!;

        return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.credit_card,
                  color: Color(0xFF0359D2),
                  size: 100,
                ),

                const SizedBox(height: 20),

                Text(
                  l10n.cardConfirmTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0359D2),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  l10n.cardConfirmMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 75,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                          ),
                          child: Text(
                            l10n.cardConfirmCancel,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: SizedBox(
                        height: 75,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0359D2),
                          ),
                          child: Text(
                            l10n.cardConfirmContinue,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ) ??
      false;
}

void _closeCardSuccessDialog() {
  if (!mounted) return;

  final navigator = Navigator.of(
    context,
    rootNavigator: true,
  );

  if (navigator.canPop()) {
    navigator.pop();
  }
}

  @override
  Widget build(BuildContext context) {
    
    final String displayedAmount = widget.data.amount ?? "0.00";

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

        // ============================================================
        // MODERN HEADER TITLE
        // ============================================================
        Positioned(
          top: 90,
          left: 65,
          right: 65,
          child: Column(
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFF064CAC),
                      Color(0xFF1987EB),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  AppLocalizations.of(context)!.paymentTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              Container(
                constraints: const BoxConstraints(
                  maxWidth: 850,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.90),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.18),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF113968).withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  AppLocalizations.of(context)!.paymentSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF435166),
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ============================================================
        // MODERN TOTAL AMOUNT CARD
        // ============================================================
        Positioned(
          top: 380,
          left: 200,
          right: 200,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 45,
              vertical: 28,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF19375C).withOpacity(0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Row(
              children: [
                // Container(
                //   width: 105,
                //   height: 105,
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFE5F0FF),
                //     borderRadius: BorderRadius.circular(28),
                //   ),
                //   child: const Icon(
                //     Icons.account_balance_wallet_rounded,
                //     color: Color(0xFF1469E8),
                //     size: 58,
                //   ),
                // ),

                const SizedBox(width: 28),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.totalAmountText,
                        style: const TextStyle(
                          color: Color(0xFF647187),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'RM $displayedAmount',
                        style: const TextStyle(
                          color: Color(0xFF1469E8),
                          fontSize: 65,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

          // CARD READER Button
          Positioned(
            top: 700,
            left: -500,
            right: 0,
            child: Center(
                    child: _PaymentKioskButton(
                    icon: IconData(0xe19f, fontFamily: 'MaterialIcons'),
                    label: AppLocalizations.of(context)!.cardButton,
                    onPressed: () async {
                    currentRouteName = '/payment';

                    final confirmed = await showCardConfirmationDialog(context);

                    if (!confirmed) {
                      return;
                    }

                    // Prevent multiple simultaneous transactions
                    if (PAYMENTPAGE._transactionInProgress) {
                      print('[PAYMENTPAGE] ⚠️ Transaction already in progress, ignoring button press');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Transaction already in progress. Please wait.")),
                      );
                      return;
                    }

                    PAYMENTPAGE._transactionInProgress = true;
                    final amount = widget.data.amount ?? "0.00";
                  //  final PaymentSpinner spinner = PaymentSpinner(context);

                    bool spinnerShown = false;
                    GlobalKey<PaymentStatusOverlayState>? overlayKey;
                    OverlayEntry? overlayEntry;
                    final cancelToken = CancellationToken();
                    
                    try {
                      // // Validate amount for RM250 threshold
                      // final double amountValue = double.tryParse(amount) ?? 0.0;
                      
                      // if (amountValue > 250.00) {
                      //   // Amount exceeds RM250 - navigate to PIN entry screen
                      //   print('[PAYMENTPAGE] ⚠️ Amount RM${amountValue.toStringAsFixed(2)} exceeds RM250 - navigating to PIN entry screen');
                        
                      //   // First, detect port and prepare for transaction
                      //   // await spinner.show();
                      //   // spinnerShown = true;

                      //   // final overlayKey = GlobalKey<PaymentStatusOverlayState>();
                      //   // late final OverlayEntry overlayEntry;
                      //   // overlayEntry = OverlayEntry(
                      //   //   builder: (_) => PaymentStatusOverlay(key: overlayKey),
                      //   // );
                      //   // Overlay.of(context).insert(overlayEntry);
                      //   // spinnerShown = true; // reuse this flag to know we need to remove the overlay

                      //   overlayKey = GlobalKey<PaymentStatusOverlayState>();
                      //   overlayEntry = OverlayEntry(
                      //     builder: (_) => PaymentStatusOverlay(key: overlayKey!),
                      //   );
                      //   Overlay.of(context).insert(overlayEntry);
                      //   spinnerShown = true; // reuse this flag to know we need to remove the overlay

                      //   // Detect port automatically with timeout
                      //   final port = await Future.any([
                      //     IM15PortDetector.detect(),
                      //     Future.delayed(const Duration(seconds: 10), () => null),
                      //   ]);
                    
                      //   if (port == null) {
                      //     // if (spinnerShown) await spinner.hide();
                      //     // spinnerShown = false;
                      //     overlayEntry?.remove();
                      //     spinnerShown = false;
                      //     PAYMENTPAGE._transactionInProgress = false;
                          
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //         content: Text("No IM15 device detected. Please check connection."),
                      //         duration: Duration(seconds: 3),
                      //       ),
                      //     );
                      //     return;
                      //   }
                        
                      //   // Hide spinner before navigating to PIN screen
                      //   if (spinnerShown) {
                      //     // await spinner.hide();
                      //     // spinnerShown = false;
                      //     overlayEntry?.remove();
                      //     spinnerShown = false;
                      //   }
                        
                      //   // Navigate to PIN entry screen
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       settings: const RouteSettings(name: '/payment'),
                      //       builder: (_) => PinEntryScreen(
                      //         amount: amount,
                      //         port: port,
                      //         traceNo: DateTime.now().millisecondsSinceEpoch.toString(),
                      //         biz: widget.biz,
                      //         paymentData: widget.data,
                      //         transactionType: _getTransactionTypeLabel(widget.biz),
                      //       ),
                      //     ),
                      //   ).then((_) {
                      //     // Reset transaction flag when returning from PIN screen
                      //     PAYMENTPAGE._transactionInProgress = false;
                      //   });
                        
                      //   return; // Exit early - PIN screen will handle the rest
                      // }
                      
                      // // Amount ≤ RM250 - proceed with normal transaction flow
                      // print('[PAYMENTPAGE] ✅ Amount RM${amountValue.toStringAsFixed(2)} ≤ RM250 - proceeding with normal transaction');

                      // // await spinner.show();
                      // // spinnerShown = true;
                      // // var overlayKey = GlobalKey<PaymentStatusOverlayState>();
                      // // late final OverlayEntry overlayEntry;
                      // // overlayEntry = OverlayEntry(
                      // //   builder: (_) => PaymentStatusOverlay(key: overlayKey),
                      // // );
                      // // Overlay.of(context).insert(overlayEntry);
                      // // spinnerShown = true; // reuse this flag to know we need to remove the overlay

                      // overlayKey = GlobalKey<PaymentStatusOverlayState>();
                      overlayKey = GlobalKey<PaymentStatusOverlayState>();
                      overlayEntry = OverlayEntry(
                        builder: (_) => PaymentStatusOverlay(
                          key: overlayKey!,
                        // onCancel: () {
                        //   print('[PAYMENTPAGE] 🛑 User tapped Cancel');

                        //   overlayKey?.currentState?.setStage(PaymentStage.cancelling); // instant visual feedback
                        //   cancelToken.cancel();  // triggers ABORT + 15s wait inside pax_im15_c200_sale.dart
                        //   // do NOT remove overlayEntry here — let the `finally` block below do it
                        //   // once the transaction actually finishes (after the abort completes)
                        // },
                        ),
                      );
                      Overlay.of(context).insert(overlayEntry!);
                      spinnerShown = true; // reuse this flag to know we need to remove the overlay

                      final serialSettings = IM15SerialSettings();
                      final connMgr = IM15SerialConnectionManager(serialSettings);
                  
                      AbstractC200TransactionService? service;
                  
                      // Select service based on biz type
                      if (widget.biz == "PARKING" || widget.biz == "EXTENDPARKING") {
                        service = ParkingC200Service(context, null, [], connMgr);
                      } else if (widget.biz == "MULTICOMPOUND" || widget.biz == "SINGLECOMPOUND") {
                        service = CompoundC200Service(context, null, [], connMgr);
                      }
                       else if (widget.biz == "CUKAI" || widget.biz == "SEMAKAN CUKAI") {
                        service = TaxC200Service(context, null, [], connMgr);
                      } else if (widget.biz == "SEWAAN" || widget.biz == "SEMAKAN SEWAAN") {
                        service = CompoundC200Service(context, null, [], connMgr);
                      }
                  
                      if (service == null) {
                        throw Exception("Unsupported business type: ${widget.biz}");
                      }
                      
                  
                      // Detect port automatically with timeout
                      final port = await Future.any([
                        IM15PortDetector.detect(),
                        Future.delayed(const Duration(seconds: 10), () => null),
                      ]);
                    
                      if (port == null) {
                        throw Exception("No IM15 device detected. Please check connection.");
                      }
                  
                      await service.execute(
                        amount,
                        port,
                        DateTime.now().millisecondsSinceEpoch.toString(), // traceNo
                        cancelToken: cancelToken,
                          onCardDetected: () {
                          print('[PAYMENTPAGE] 💳 Changing overlay to PROCESSING');
                          overlayKey?.currentState?.setStage(PaymentStage.processing);
                        },
                        onCancelling: () {
                          print('[PAYMENTPAGE] ⏳ Cancelling payment...');
                          overlayKey?.currentState?.setStage(PaymentStage.cancelling);
                        },
                        onSuccess: () async {
                          print('[PAYMENTPAGE] ✅ Card payment successful');

                          // First show the success state on the card-reader overlay.
                          overlayKey?.currentState?.setStage(
                            PaymentStage.success,
                          );

                          await Future.delayed(
                            const Duration(milliseconds: 900),
                          );

                          // Remove the card-reader overlay before showing the success card.
                          if (spinnerShown) {
                            try {
                              overlayEntry?.remove();
                            } catch (_) {}

                            overlayEntry = null;
                            spinnerShown = false;
                          }

                          if (!mounted) return;

                          
                          showCardPaymentSuccessDialog(
                            context,
                            amount: widget.data.amount ?? '0.00',
                          );

                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                  
                          // =============================
                          // ===== PARKING CARD PAYMENT
                          // =============================
                          if (widget.biz == "PARKING") {
                            final result = await ParkingService.callParkingPayAPI(
                              plate: widget.data.plate ?? "",
                              timeUsed: widget.data.hour ?? 0,
                              typePayment: "Debit/Credit Card",
                              orderNo: "0",
                              bankTrxNo: "0",
                            );
                  
                        if (result != null && !result.startsWith("Error")) {
                          _closeCardSuccessDialog();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: '/receipt'),
                              builder: (_) => RESITPAGE(
                                biz: widget.biz,
                                data: ResitData(
                                  plate: widget.data.plate,
                                  hour: widget.data.hour,
                                  amount: widget.data.amount,
                                  pegeOrderNo: "0",
                                  pegeBankTrxNo: "0",
                                  typePayment: "Debit/Credit Card",
                                ),
                              ),
                            ),
                          );
                        }
                          }
                  
                          // =============================
                          // ===== EXTEND PARKING CARD PAYMENT
                          // =============================
                          else if (widget.biz == "EXTENDPARKING") {
                            final result = await ParkingService.callParkingExtendAPI(
                              plate: widget.data.plate ?? "",
                              extendHours: widget.data.hour ?? 0,
                              typePayment: "Debit/Credit Card",
                              orderNo: "0",
                              bankTrxNo: "0",
                            );
                  
                            if (result != null && !result.startsWith("Error")) {
                              _closeCardSuccessDialog();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(name: '/receipt'),
                                  builder: (_) => RESITPAGE(
                                    biz: "PARKING",
                                    data: ResitData(
                                      plate: widget.data.plate,
                                      hour: widget.data.hour,
                                      amount: widget.data.amount,
                                      pegeOrderNo: "0",
                                      pegeBankTrxNo: "0",
                                      typePayment: "Debit/Credit Card",
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result ?? "Extend parking failed")),
                              );
                            }
                          }
                  
                          // =============================
                          // ===== TAX CARD PAYMENT
                          // =============================


                          // else if (widget.biz == "CUKAI") {
                          //   final billNos = widget.data.taxItems!.map((e) => e.billNo).toList();
                          //   final success = await TaxService.payMultipleTaxes(billNos);
                  
                          //   if (success) {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         settings: const RouteSettings(name: '/receipt'),
                          //         builder: (_) => RESITPAGE(
                          //           biz: "CUKAI",
                          //           data: ResitData(
                          //             amount: widget.data.amount,
                          //             taxItems: widget.data.taxItems,
                          //             typePayment: "Debit/Credit Card",
                          //           ),
                          //         ),
                          //       ),
                          //     );
                          //   } else {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       const SnackBar(content: Text("Tax payment failed")),
                          //     );
                          //   }
                          // }

                          else if (widget.biz == "CUKAI" || widget.biz == "SEMAKAN CUKAI") {
                          final items = widget.data.taksiranItems ?? [];

                          if (items.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Tiada cukai dipilih")),
                            );
                            return;
                          }

                          final success = await TaksiranPaymentServiceBentong.payMultiple(
                            items: items,
                            referenceNo: "0",
                          );

                          if (success) {
                            final updateSuccess =
                                await TaksiranPaymentServiceBentong.postPaymentUpdateBentong(
                              items: items,
                              orderNo: "0",
                              bankTrxNo: "0",
                              paymentMethod: "Debit/Credit Card",
                            );

                            if (!updateSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Cukai payment saved to MPB, but local update failed"),
                                ),
                              );
                              return;
                            }

                            _closeCardSuccessDialog();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: const RouteSettings(name: '/receipt'),
                                builder: (_) => RESITPAGE(
                                  biz: "CUKAI",
                                  data: ResitData(
                                    amount: widget.data.amount,
                                    taksiranItems: widget.data.taksiranItems,
                                    typePayment: "Debit/Credit Card",
                                  ),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Cukai payment update failed")),
                            );
                          }
                        }
                  
                          // =============================
                          // ===== LICENSE CARD PAYMENT
                          // =============================
                          else if (widget.biz == "LESEN") {
                            final licenseNos = widget.data.licenseNos ?? [];
                            if (licenseNos.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Tiada lesen dipilih")),
                              );
                              return;
                            }
                  
                            final success = await LicenseService.payMultipleLicenses(licenseNos);
                            if (success) {
                              _closeCardSuccessDialog();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(name: '/receipt'),
                                  builder: (_) => RESITPAGE(
                                    biz: "LESEN",
                                    data: ResitData(
                                      amount: widget.data.amount,
                                      licenseNos: licenseNos,
                                      typePayment: "Debit/Credit Card",
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Pembayaran lesen gagal")),
                              );
                            }
                          }

                     // =============================
                     // ===== SEWAAN CARD PAYMENT
                     // =============================

                    else if (widget.biz == "SEWAAN" || widget.biz == "SEMAKAN SEWAAN") {
                      final items = widget.data.sewaanItems ?? [];

                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Tiada sewaan dipilih")),
                        );
                        return;
                      }

                      final success = await SewaanPaymentServiceBentong.payMultipleSewaan(
                        items: items,
                        referenceNo: "0",
                      );

                      if (success) {
                        final updateSuccess =
                            await SewaanPaymentServiceBentong.postPaymentUpdateBentong(
                          items: items,
                          orderNo: "0",
                          bankTrxNo: "0",
                          paymentMethod: "Debit/Credit Card",
                        );

                        if (!updateSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Sewaan payment saved to MPB, but local update failed"),
                            ),
                          );
                          return;
                        }

                         _closeCardSuccessDialog();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/receipt'),
                            builder: (_) => RESITPAGE(
                              biz: "SEWAAN",
                              data: ResitData(
                                amount: widget.data.amount,
                                sewaanItems: widget.data.sewaanItems,
                                typePayment: "Debit/Credit Card",
                              ),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sewaan payment update failed")),
                        );
                      }
                    }
                  
                          // =============================
                          // ===== COMPOUND CARD PAYMENT
                          // =============================
                          else if (widget.biz == "MULTICOMPOUND" || widget.biz == "SINGLECOMPOUND") {

                            _closeCardSuccessDialog();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: const RouteSettings(name: '/receipt'),
                                builder: (_) => RESITPAGE(
                                  biz: widget.biz,
                                  data: ResitData(
                                    amount: widget.data.amount,
                                    compoundNos: widget.data.compoundNos,
                                    plate: widget.data.plate,
                                    offenderName: widget.data.offenderName,
                                    violationType: widget.data.violationType,
                                    kodhasil: widget.data.kodhasil,
                                    date: widget.data.date ?? DateFormat("yyyy-MM-dd").format(DateTime.now()),
                                    time: widget.data.time ?? DateFormat("HH:mm:ss").format(DateTime.now()),
                                    typePayment: "Debit/Credit Card",
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        onFailure: () async {
                          print('[PAYMENTPAGE] ❌ Card payment failed');

                          if (cancelToken.isCancelled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Payment cancelled."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Card payment failed or timeout. Please try again."),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      onPINRequired: () {
                          print('[PAYMENTPAGE] 🔐 PIN required - switching overlay to PIN stage');
                          overlayKey?.currentState?.setStage(PaymentStage.pinRequired);
                        },
                        onPINCompleted: () {
                          print('[PAYMENTPAGE] ✅ PIN completed - switching overlay back to processing');
                          overlayKey?.currentState?.setStage(PaymentStage.processing);
                        },
                      );
                    } catch (e) {
                      print('[PAYMENTPAGE] ❌ Payment error: $e');
                      
                      // Show user-friendly error message
                      String errorMessage = "Payment error occurred. Please try again.";
                      if (e.toString().contains("timeout") || e.toString().contains("Timeout")) {
                        errorMessage = "Transaction timeout. Please check card reader and try again.";
                      } else if (e.toString().contains("port") || e.toString().contains("connection")) {
                        errorMessage = "Card reader connection failed. Please check device.";
                      } else if (e.toString().contains("declined")) {
                        errorMessage = "Transaction declined. Please check your card.";
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          duration: const Duration(seconds: 4),
                          backgroundColor: Colors.red[700],
                        ),
                      );
                    } finally {
                      // ALWAYS hide spinner and reset transaction flag
                      if (spinnerShown) {
                        try {
                          // await spinner.hide();
                          overlayEntry?.remove();
                          print('[PAYMENTPAGE] ✅ Spinner hidden in finally block');
                        } catch (hideError) {
                          print('[PAYMENTPAGE] ⚠️ Error hiding spinner in finally block: $hideError');
                        }
                      }
                      
                      PAYMENTPAGE._transactionInProgress = false;
                      print('[PAYMENTPAGE] ✅ Transaction flag reset');
                    }
                  },
              ),
            ),
          ),

                      // QR PAYMENT Button
                      Positioned(
                        top: 700,
                        left: 0,
                        right: -500,
                        child: Center(
                        child: _PaymentKioskButton(
                        icon: IconData(0xe4f5, fontFamily: 'MaterialIcons'),
                        label: AppLocalizations.of(context)!.qrButton,
                        onPressed: () async {
                          QrTransitionOverlayController? qrOverlay;

                          // Keep RM0.01 for testing.
                          const double testing = 0.01;

                          // REAL DEPLOYMENT AMOUNT:
                          // final double amount = double.tryParse(
                          //   widget.data.amount ?? "0.00",
                          // ) ?? 0.00;

                          // Show one QR transition overlay immediately.

                          // IMPORTANT: create this overlay only once.

                          qrOverlay = showQrTransitionOverlay(

                            context,

                            amount: widget.data.amount ?? '0.00',

                          );


                          await WidgetsBinding.instance.endOfFrame;


                          try {

                            final result = await PegePayService.createOrder(
                              testing,

                              // FOR REAL DEPLOYMENT, replace `testing` above
                              // with `amount` after enabling the declaration.
                              // amount,

                              Config.storeId,
                              Config.terminalId,
                              Config.shiftId,
                            );
                            final iframeUrl = result["iframe_url"];
                            final orderNo = result["order_no"];
                        
                            if (iframeUrl == null || orderNo == null) {
                              qrOverlay?.remove();
                              qrOverlay = null;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to create PegePay order.")),
                              );
                              return;
                            }
                        
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     settings: const RouteSettings(name: '/payment'),
                            //     builder: (_) => PegePayQRPageDesktopWebView(
                            //        iframeUrl: iframeUrl,
                            //       orderNo: orderNo,
                            //        onSuccess: () async {
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           const SnackBar(content: Text("Payment successful!")),
                            //         );

                            currentRouteName = '/payment';
                        await PegePayWebViewHelper.open(
                            iframeUrl: iframeUrl,
                            orderNo: orderNo,

                            onPaymentDetected: () async {
                              // The QR WebView is still active at this point.
                              // Prepare the Flutter overlay behind it so that
                              // Flutter immediately shows payment success when
                              // the QR window closes.
                              qrOverlay?.showSuccess();
                              await WidgetsBinding.instance.endOfFrame;
                            },

                            onSuccess: (Map<String, dynamic> paymentResult) async {
                              final pegeOrderNo =
                                  paymentResult["order_no"] ?? orderNo;
                              final pegeBankTrxNo =
                                  paymentResult["bank_trx_no"] ?? "";

/* ======================= */
                                  /* ===== PARKING QR PAYMENT ===== */
                                  /* ======================= */
                                  
                                  if (widget.biz == "PARKING") {
                                    final result = await ParkingService.callParkingPayAPI(
                                      plate: widget.data.plate ?? "",
                                      timeUsed: widget.data.hour ?? 0,
                                      typePayment: "DuitNow QR",
                                      orderNo: pegeOrderNo,
                                      bankTrxNo: pegeBankTrxNo,
                                    );
                                  
                                    if (result != null && !result.startsWith("Error")) {

                                      qrOverlay?.remove();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings: const RouteSettings(name: '/receipt'),
                                          builder: (_) => RESITPAGE(
                                            biz: widget.biz,
                                            data: ResitData(
                                              plate: widget.data.plate,
                                              hour: widget.data.hour,
                                              amount: widget.data.amount,
                                              pegeOrderNo: pegeOrderNo,
                                              pegeBankTrxNo: pegeBankTrxNo,
                                              typePayment: "DuitNow QR",
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }

                                  /* ======================= */
                                  /* ===== Extend QR PAYMENT ===== */
                                  /* ======================= */

                                  else if (widget.biz == "EXTENDPARKING") {
                                 final result = await ParkingService.callParkingExtendAPI(
                                   plate: widget.data.plate ?? "",
                                   extendHours: widget.data.hour ?? 0,
                                   typePayment: "DuitNow",
                                     orderNo: pegeOrderNo,
                                    bankTrxNo: pegeBankTrxNo,
                                 );
                               
                                 if (result != null && !result.startsWith("Error")) {

                                  qrOverlay?.remove();
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                      settings: const RouteSettings(name: '/receipt'),
                                       builder: (_) => RESITPAGE(
                                         biz: "PARKING",
                                         data: ResitData(
                                           plate: widget.data.plate,
                                           hour: widget.data.hour,
                                           amount: widget.data.amount,
                                           pegeOrderNo: pegeOrderNo,
                                           pegeBankTrxNo: pegeBankTrxNo,
                                           typePayment: "DuitNow QR",
                                         ),
                                       ),
                                     ),
                                   );
                                 } else {
                                   qrOverlay?.remove();

                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text(result ?? "Extend parking failed")),
                                   );
                                 }
                               }
                                                                 
                                  /* ======================= */
                                  /* ===== TAX QR PAYMENT ===== */
                                  /* ======================= */
                                  // else if (biz == "CUKAI") {
                                  //   final billNos =
                                  //       data.taxItems!.map((e) => e.billNo).toList();
                                  
                                  //   final success = await TaxService.payMultipleTaxes(billNos);
                                  
                                  //   if (success) {
                                  //    Navigator.push(
                                  //      context,
                                  //      MaterialPageRoute(
                                  //       settings: const RouteSettings(name: '/receipt'),
                                  //        builder: (_) => RESITPAGE(
                                  //          biz: "CUKAI",
                                  //          data: ResitData(
                                  //            amount: data.amount,
                                  //            taxItems: data.taxItems,
                                  //            pegeOrderNo: pegeOrderNo,
                                  //            pegeBankTrxNo: pegeBankTrxNo,
                                  //          ),
                                  //        ),
                                  //      ),
                                  //    );
                                     
                                  //   } else {
                                  //     ScaffoldMessenger.of(context).showSnackBar(
                                  //       const SnackBar(content: Text("Tax payment failed")),
                                  //     );
                                  //   }
                                  // }

                                  else if (widget.biz == "CUKAI" || widget.biz == "SEMAKAN CUKAI") {
                                  final items = widget.data.taksiranItems ?? [];

                                  if (items.isEmpty) {

                                      qrOverlay?.remove();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Tiada cukai dipilih")),
                                    );
                                    return;
                                  }

                                  final success = await TaksiranPaymentServiceBentong.payMultiple(
                                    items: items,
                                    referenceNo: pegeOrderNo,
                                  );

                                  if (success) {
                                    final updateSuccess =
                                        await TaksiranPaymentServiceBentong.postPaymentUpdateBentong(
                                      items: items,
                                      orderNo: pegeOrderNo,
                                      bankTrxNo: pegeBankTrxNo,
                                      paymentMethod: "DuitNow QR",
                                    );

                                    if (!updateSuccess) {
                                      qrOverlay?.remove();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Cukai payment saved to MPB, but local update failed"),
                                        ),
                                      );
                                      return;
                                    }

                                    qrOverlay?.remove();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        settings: const RouteSettings(name: '/receipt'),
                                        builder: (_) => RESITPAGE(
                                          biz: "CUKAI",
                                          data: ResitData(
                                            amount: widget.data.amount,
                                            taksiranItems: widget.data.taksiranItems,
                                            pegeOrderNo: pegeOrderNo,
                                            pegeBankTrxNo: pegeBankTrxNo,
                                            typePayment: "DuitNow QR",
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    qrOverlay?.remove();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Cukai payment update failed")),
                                    );
                                  }
                                }
                                   /* ======================= */
                                   /* ===== SEWAAN QR PAYMENT ===== */
                                   /* ======================= */
                                    else if (widget.biz == "SEWAAN" || widget.biz == "SEMAKAN SEWAAN") {
                                      final items = widget.data.sewaanItems ?? [];

                                      if (items.isEmpty) {
                                          qrOverlay?.remove();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Tiada sewaan dipilih")),
                                        );
                                        return;
                                      }

                                      final success = await SewaanPaymentServiceBentong.payMultipleSewaan(
                                        items: items,
                                        referenceNo: pegeBankTrxNo,
                                      );

                                      if (success) {
                                        final updateSuccess =
                                            await SewaanPaymentServiceBentong.postPaymentUpdateBentong(
                                          items: items,
                                          orderNo: pegeOrderNo,
                                          bankTrxNo: pegeBankTrxNo,
                                          paymentMethod: "DuitNow QR",
                                        );

                                        if (!updateSuccess) {
                                          qrOverlay?.remove();

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Sewaan payment saved to MPB, but local update failed"),
                                            ),
                                          );
                                          return;
                                        }
                                        qrOverlay?.remove();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            settings: const RouteSettings(name: '/receipt'),
                                            builder: (_) => RESITPAGE(
                                              biz: "SEWAAN",
                                              data: ResitData(
                                                amount: widget.data.amount,
                                                sewaanItems: widget.data.sewaanItems,
                                                pegeOrderNo: pegeOrderNo,
                                                pegeBankTrxNo: pegeBankTrxNo,
                                                typePayment: "DuitNow QR",
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        qrOverlay?.remove();

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Sewaan payment update failed"),
                                          ),
                                        );
                                      }
                                    }
                                                                    
                                   /* ======================= */
                                   /* ===== LICENSE QR PAYMENT ===== */
                                   /* ======================= */
                                   else if (widget.biz == "LESEN") {
                                   final licenseNos = widget.data.licenseNos ?? [];
                                   print('Selected licenses:  $licenseNos');

                                 
                                   if (licenseNos.isEmpty) {
                                     qrOverlay?.remove();
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text("Tiada lesen dipilih")),
                                     );
                                     return;
                                   }
                                 
                                   final success =
                                       await LicenseService.payMultipleLicenses(licenseNos);
                                 
                                   if (success) {
                                    qrOverlay?.remove();
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                        settings: const RouteSettings(name: '/receipt'),
                                         builder: (_) => RESITPAGE(
                                           biz: "LESEN", 
                                           data: ResitData(
                                             amount: widget.data.amount,
                                             licenseNos: licenseNos, 
                                             pegeOrderNo: pegeOrderNo,
                                             pegeBankTrxNo: pegeBankTrxNo,
                                             typePayment: "DuitNow QR",
                                           ),
                                         ),
                                       ),
                                     );
                                   } else {
                                     qrOverlay?.remove();
                                     
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text("Pembayaran lesen gagal")),
                                     );
                                   }
                                 }
      
                                  /* ======================= */
                                  /* ===== MULTIPLECOMPOUND QR PAYMENT ===== */
                                  /* ======================= */

                                 else if (widget.biz == "MULTICOMPOUND") {
                                   // NO API CALL ❌
                                   // Just go to receipt page ✅
                                //Navigator.pop(context);

                                 qrOverlay?.remove();
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                      settings: const RouteSettings(name: '/receipt'),
                                       builder: (_) => RESITPAGE(
                                         biz: "MULTICOMPOUND",
                                         data: ResitData(
                                           amount: widget.data.amount,
                                           compoundNos: widget.data.compoundNos,
                                           pegeOrderNo: pegeOrderNo,
                                           pegeBankTrxNo: pegeBankTrxNo,
                                           typePayment: "DuitNow QR",
                                         ),
                                       ),
                                     ),
                                   );
                                 }
                                  
                                else if (widget.biz == "SINGLECOMPOUND") {
                                  qrOverlay?.remove();
                                 Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                    settings: const RouteSettings(name: '/receipt'),
                                     builder: (_) => RESITPAGE(
                                       biz: "SINGLECOMPOUND",
                                       data: ResitData(
                                        amount: widget.data.amount,
                                        pegeOrderNo: pegeOrderNo,
                                        pegeBankTrxNo: pegeBankTrxNo,
                                        compoundNos: widget.data.compoundNos,
                                        plate: widget.data.plate,
                                        offenderName: widget.data.offenderName,
                                        violationType: widget.data.violationType,
                                        kodhasil: widget.data.kodhasil,
                                        date: widget.data.date ?? DateFormat("yyyy-MM-dd").format(DateTime.now()),
                                        time: widget.data.time ?? DateFormat("HH:mm:ss").format(DateTime.now()),
                                        typePayment: "DuitNow QR",
                                       ),
                                     ),
                                   ),
                                 );
                               }
                               
                                  },
                            onCancel: () async {
                              print("User cancelled QR payment");

                              /*
                               * Keep the existing overlay visible while the
                               * native QR window finishes closing. Only change
                               * its content to a clear closing message.
                               */
                              qrOverlay?.showClosing();

                              await WidgetsBinding.instance.endOfFrame;

                              currentRouteName = '/payment';

                              await windowManager.show();
                              await windowManager.focus();
                              await windowManager.setFullScreen(true);

                              /*
                               * Give the user a short, intentional transition
                               * instead of briefly showing the old opening text.
                               */
                              await Future.delayed(
                                const Duration(milliseconds: 700),
                              );

                              qrOverlay?.remove();

                              qrOverlay = null;

                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!
                                        .qrPaymentCancelled,
                                  ),
                                ),
                              );
                            },
                            );
                                                              
                            //     ),
                            //   ),
                            // );
                          } catch (e) {
                            qrOverlay?.remove();
                            qrOverlay = null;

                            currentRouteName = '/payment';
                            print("PegePay createOrder error: $e");

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Error creating PegePay order.",
                                ),
                              ),
                            );
                          }
                        },
              ),
            ),
          ),

        
        //we accept text + payment method image

          Positioned(
          top: 1200,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.weAcceptText,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // rounded image
                  child: Image.asset(
                    "lib/images/Payment_Method.png",
                    width: 520,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 70,
          right: 50,
          child: InkWell(
            onTap: () {
              showPaymentGuideDialog(context);
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0359D2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 100,
              ),
            ),
          ),
        ),


          // Bottom button (KEMBALI)
          Positioned(
            bottom: 170,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Footer text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child:  Center(
              child: Text(
                Data.copyrightText,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Helper function to get transaction type label
  String _getTransactionTypeLabel(String biz) {
    switch (biz) {
      case "PARKING":
        return "Parking Payment";
      case "EXTENDPARKING":
        return "Extend Parking";
      case "CUKAI":
        return "Tax Payment";
      case "LESEN":
        return "License Payment";
      case "MULTICOMPOUND":
        return "Multiple Compound";
      case "SINGLECOMPOUND":
        return "Single Compound";
      default:
        return "Payment";
    }
  }
  
}

/// =======================================================
/// PAYMENT BUTTON STYLE (SAME AS PBT3)
/// =======================================================
class _PaymentKioskButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PaymentKioskButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_PaymentKioskButton> createState() =>
      _PaymentKioskButtonState();
}

class _PaymentKioskButtonState
    extends State<_PaymentKioskButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isQr =
        widget.label.toLowerCase().contains('qr');

    final Color accentColor = isQr
        ? const Color(0xFF15946B)
        : const Color(0xFF1469E8);

    final Color lightColor = isQr
        ? const Color(0xFFE2F7EF)
        : const Color(0xFFE5F0FF);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.965 : 1,
        duration: const Duration(milliseconds: 130),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 400,
          height: 430,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: _isPressed
                  ? accentColor
                  : Colors.black,
              width: _isPressed ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF19375C)
                    .withOpacity(_isPressed ? 0.08 : 0.18),
                blurRadius: _isPressed ? 15 : 30,
                offset: Offset(
                  0,
                  _isPressed ? 7 : 16,
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(37),
            child: Stack(
              children: [
                Positioned(
                  right: -45,
                  top: -45,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightColor,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 135,
                            height: 125,
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius:
                                  BorderRadius.circular(32),
                              border: Border.all(
                                color:
                                    accentColor.withOpacity(0.20),
                              ),
                            ),
                            child: Icon(
                              widget.icon,
                              size: 72,
                              color: accentColor,
                            ),
                          ),

                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Text(
                        widget.label.toUpperCase(),
                        maxLines: 3,
                        style: const TextStyle(
                          color: Color(0xFF15253A),
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 7,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius:
                                  BorderRadius.circular(50),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 12,
                            height: 7,
                            decoration: BoxDecoration(
                              color:
                                  accentColor.withOpacity(0.28),
                              borderRadius:
                                  BorderRadius.circular(50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
