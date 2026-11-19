import 'dart:convert';
import 'dart:io';
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
import 'package:frontend_v1/services/pegepay/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay/pegepay_webview_helper.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:intl/intl.dart';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';
import 'package:frontend_v1/controllers/taksiran/taksiran_payment_service_bentong.dart';
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';
import 'package:frontend_v1/controllers/sewaan/sewaan_payment_service_bentong.dart';
import 'package:window_manager/window_manager.dart';
import 'package:frontend_v1/widgets/payment_status_overlay.dart';
import 'package:frontend_v1/widgets/payment_video_guide.dart';


//PIP DASHBOARD API
import 'dart:async';
import 'package:frontend_v1/services/pip/pip_transaction_service.dart';
import 'package:frontend_v1/services/pip/pip_municipal_transaction_service.dart';

class PaymentData {
  String? plate;
  String? biz;
  int? hour;
  String? amount;

  // PIP Parking information
  String? negeri;
  String? kawasan;
  String? zon;
  DateTime? mulaSesi;
  DateTime? tamatSesi;

  String? parkingSessionId;
  DateTime? previousParkingEnd;

  String? samanNo;
  String? licenseNo;
  String? accountNo;
  List<PaymentTaxItem>? taxItems;
  List<String>? licenseNos;
  List<String>? compoundNos;
  // Optional real per-compound allocations from the selecting page.
  // Each item should provide compound_no, offender_name and amount.
  List<Map<String, dynamic>>? compoundItems;
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

    // PIP Parking information
    this.negeri,
    this.kawasan,
    this.zon,
    this.mulaSesi,
    this.tamatSesi,
    this.parkingSessionId,
    this.previousParkingEnd,

    this.samanNo,
    this.licenseNo,
    this.accountNo,
    this.taxItems,
    this.licenseNos, 
    this.compoundNos,
    this.compoundItems,
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

void showLoadingDialog(
  BuildContext context, {
  String? message,
}) {
  final l10n = AppLocalizations.of(context)!;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) {
      return PopScope(
        canPop: false,
        child: Material(
          color: const Color(0xFF071A2F).withOpacity(0.82),
          child: Center(
            child: Container(
              width: 650,
              padding: const EdgeInsets.symmetric(
                horizontal: 46,
                vertical: 44,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFB7CAE8),
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
                  // QR icon container
                  Container(
                    width: 138,
                    height: 138,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F2FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1469E8),
                        width: 5,
                      ),
                    ),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
                      size: 88,
                      color: Color(0xFF1469E8),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Localized title
                  Text(
                    l10n.loadingTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0359D2),
                      fontSize: 43,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Uses custom message when supplied.
                  // Otherwise uses the existing ARB loadingMessage.
                  Text(
                    message ?? l10n.loadingMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF24364B),
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Processing status panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F7FD),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFB7CAE8),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE1EDFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: Color(0xFF1469E8),
                            size: 37,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Text(
                            l10n.loadingStatusMessage,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color(0xFF294A73),
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Loading indicator
                  const SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      strokeWidth: 7,
                      color: Color(0xFF1469E8),
                      backgroundColor: Color(0xFFDCE9FA),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Localized instruction
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.touch_app_outlined,
                        color: Color(0xFF647187),
                        size: 28,
                      ),

                      const SizedBox(width: 12),

                      Flexible(
                        child: Text(
                          l10n.loadingDoNotClose,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF647187),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
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


OverlayEntry showQrPaymentSuccessOverlay(
  BuildContext context, {
  required String amount,
}) {
  final l10n = AppLocalizations.of(context)!;

  final entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: Material(
        color: const Color(0xFF071A2F).withOpacity(0.78),
        child: PopScope(
          canPop: false,
          child: Center(
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
                  color: const Color(0xFFB9D8C7),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.34),
                    blurRadius: 36,
                    spreadRadius: 4,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 138,
                    height: 138,
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
                      size: 96,
                      color: Color(0xFF169B62),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.cardPaymentSuccessTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF087443),
                      fontSize: 43,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.cardPaymentSuccessMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF24364B),
                      fontSize: 27,
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
                      color: const Color(0xFFF2F7FD),
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
                            color: Color(0xFF53657A),
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'RM $amount',
                          style: const TextStyle(
                            color: Color(0xFF0359D2),
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    l10n.cardPreparingReceipt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0359D2),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.cardPleaseWaitNotice,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5A6878),
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context, rootOverlay: true).insert(entry);
  return entry;
}

void removeQrPaymentSuccessOverlay(OverlayEntry? entry) {
  if (entry == null) return;

  try {
    entry.remove();
  } catch (_) {
    // The overlay may already have been removed.
  }
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
  // =====================================================
  // PIP MANAGEMENT API - GLOBAL ENABLE / DISABLE
  // =====================================================
  static const bool enablePip = true;

  // QR PAYMENT TESTING
  static const bool enableQrTesting = true;
  static const double qrTestingAmount = 0.05;

  bool get _pipEnabled =>
      enablePip &&
      (widget.biz == 'PARKING' ||
          widget.biz == 'EXTENDPARKING');

  // =====================================================
  // PIP PARKING - VERIFIED BACKEND SESSION TIME
  // =====================================================
  // Never calculate a paid session from the kiosk clock. The parking API
  // must supply authoritative timein/timeout (or mula_sesi/tamat_sesi).
  /// Called only after the existing parking provider API succeeds.
  /// PIP derives session times from PAID sent_to_pip_at and duration_minutes.
  Future<void> _saveParkingPaid({
    required PipTransactionService? pip,
    required Future<bool>? pendingRequest,
    required bool extension,
    String? bankTrxNo,
  }) async {
    if (pip == null) return;
    try {
      if (pendingRequest != null) await pendingRequest;
      final saved = await pip.paid(bankTrxNo: bankTrxNo);
      debugPrint('[PIP] ${extension ? 'EXTENSION' : 'NEW'} '
          'PAID=$saved, duration=${pip.durationMinutes} minutes, '
          'session=${pip.parkingSessionId}');
      if (!saved) {
        debugPrint('[PIP] PAID unconfirmed; reconciliation required.');
      }
    } catch (error) {
      debugPrint('[PIP] PAID update error: $error');
    }
  }


  // ============================================================
  // PIP MUNICIPAL TRANSACTIONS
  // ============================================================
  // Keep _pipEnabled and PipTransactionService.parking unchanged.
  // This separate flow covers Cukai, Sewaan and Kompaun only.
  // enablePip = false disables both reporting paths.
  bool get _municipalPipEnabled =>
      enablePip &&
      const <String>{
        'CUKAI',
        'SEMAKAN CUKAI',
        'SEWAAN',
        'SEMAKAN SEWAAN',
        'LESEN',
        'SINGLECOMPOUND',
        'MULTICOMPOUND',
      }.contains(widget.biz);

  String? _pipText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  // Read display metadata defensively: model field names may differ by branch.
  // Missing metadata must never prevent a fresh PENDING from being created.
  String? _accountFromSelectedItem(Object? item) {
    if (item == null) return null;
    if (item is Map) {
      return _pipText(item['accountNo'] ?? item['account_no']);
    }
    try {
      final dynamic selected = item;
      return _pipText(selected.accountNo);
    } catch (_) {
      return null;
    }
  }

  String? _nameFromSelectedItem(Object? item, {required bool tax}) {
    if (item == null) return null;
    if (item is Map) {
      return _pipText(tax
          ? (item['ownerName'] ?? item['owner_name'])
          : (item['tenantName'] ?? item['tenant_name']));
    }
    try {
      final dynamic selected = item;
      return _pipText(tax ? selected.ownerName : selected.tenantName);
    } catch (_) {
      return null;
    }
  }

  // Amounts may arrive formatted as "RM 1,000.00" from a council page.
  // Parsing only here keeps the working Parking amount logic unchanged.
  double _municipalBillAmount() {
    final text = (widget.data.amount ?? '')
        .replaceAll('RM', '')
        .replaceAll('rm', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(text) ?? 0.0;
  }

  /// Read the actual selected amount without relying on branch-specific models.
  /// Missing amounts are NOT guessed for multi-account payments.
  double? _selectedAccountAmount(Object? item) {
    Object? value;
    if (item is Map) {
      value = item['amount'];
    } else if (item != null) {
      try {
        final dynamic selected = item;
        value = selected.amount;
      } catch (_) {
        return null;
      }
    }

    if (value is num) {
      final amount = value.toDouble();
      return amount.isFinite && amount > 0 ? amount : null;
    }

    final cleaned = value?.toString()
        .replaceAll('RM', '')
        .replaceAll('rm', '')
        .replaceAll(',', '')
        .trim();
    final amount = double.tryParse(cleaned ?? '');
    return amount != null && amount.isFinite && amount > 0
        ? amount
        : null;
  }

  /// One PIP item per distinct account. Multiple-account allocations are only
  /// sent when every source amount is present and totals match the bill.
  /// For one distinct account, the full selected bill belongs to that account.
  List<PipMunicipalPaymentItem> _municipalAllocations({
    required List<Map<String, Object?>> selected,
    required double originalAmount,
    required String serviceType,
  }) {
    if (selected.isEmpty) return const <PipMunicipalPaymentItem>[];

    final grouped = <String, Map<String, Object?>>{};
    var hasMissingAccount = false;
    for (final row in selected) {
      final account = _pipText(row['accountNo']);
      if (account == null) {
        hasMissingAccount = true;
        continue;
      }
      final name = _pipText(row['accountName']);
      final partAmount = row['amount'] as double?;
      final existing = grouped[account];
      if (existing == null) {
        grouped[account] = <String, Object?>{
          'accountName': name,
          'amount': partAmount,
        };
      } else {
        existing['accountName'] ??= name;
        final previous = existing['amount'] as double?;
        existing['amount'] = previous != null && partAmount != null
            ? previous + partAmount
            : null;
      }
    }

    if (hasMissingAccount || grouped.isEmpty) {
      debugPrint('[PIP] $serviceType: missing account numbers; '
          'saving only transaction summary.');
      return const <PipMunicipalPaymentItem>[];
    }

    if (grouped.length == 1) {
      final account = grouped.keys.first;
      return <PipMunicipalPaymentItem>[
        PipMunicipalPaymentItem(
          accountNo: account,
          accountName: grouped[account]!['accountName'] as String?,
          amount: originalAmount,
        ),
      ];
    }

    final allocations = <PipMunicipalPaymentItem>[];
    var allocatedCents = 0;
    for (final entry in grouped.entries) {
      final partAmount = entry.value['amount'] as double?;
      if (partAmount == null ||
          !partAmount.isFinite ||
          partAmount <= 0 ||
          (partAmount * 100 - (partAmount * 100).round()).abs() > 0.00001) {
        debugPrint('[PIP] $serviceType: missing/invalid amount for '
            '${entry.key}; saving summary without invented allocations.');
        return const <PipMunicipalPaymentItem>[];
      }
      allocatedCents += (partAmount * 100).round();
      allocations.add(PipMunicipalPaymentItem(
        accountNo: entry.key,
        accountName: entry.value['accountName'] as String?,
        amount: partAmount,
      ));
    }

    if (allocatedCents != (originalAmount * 100).round()) {
      debugPrint('[PIP] $serviceType: selected-account amounts do not '
          'match the bill total; saving summary only.');
      return const <PipMunicipalPaymentItem>[];
    }
    return allocations;
  }

  PipMunicipalTransactionService? _newMunicipalAttempt({
    required String paymentMethod,
    required double originalAmount,
  }) {
    if (!_municipalPipEnabled ||
        !originalAmount.isFinite ||
        originalAmount <= 0) {
      return null;
    }

    String serviceType;
    String? accountName;
    final accountNumbers = <String>[];
    final selectedAllocations = <Map<String, Object?>>[];

    if (widget.biz == 'CUKAI' || widget.biz == 'SEMAKAN CUKAI') {
      serviceType = 'Cukai Taksiran';
      for (final item in widget.data.taksiranItems ?? <TaksiranPaymentItem>[]) {
        final number = _accountFromSelectedItem(item);
        if (number != null && !accountNumbers.contains(number)) {
          accountNumbers.add(number);
        }
        final owner = _nameFromSelectedItem(item, tax: true);
        accountName ??= owner;
        selectedAllocations.add(<String, Object?>{
          'accountNo': number,
          'accountName': owner,
          'amount': _selectedAccountAmount(item),
        });
      }
    } else if (widget.biz == 'SEWAAN' || widget.biz == 'SEMAKAN SEWAAN') {
      serviceType = 'Sewaan Majlis';
      for (final item in widget.data.sewaanItems ?? <SewaanPaymentItem>[]) {
        final number = _accountFromSelectedItem(item);
        if (number != null && !accountNumbers.contains(number)) {
          accountNumbers.add(number);
        }
        final tenant = _nameFromSelectedItem(item, tax: false);
        accountName ??= tenant;
        selectedAllocations.add(<String, Object?>{
          'accountNo': number,
          'accountName': tenant,
          'amount': _selectedAccountAmount(item),
        });
      }
    } else if (widget.biz == 'LESEN') {
      serviceType = 'Lesen';
      for (final number in widget.data.licenseNos ?? <String>[]) {
        final cleaned = _pipText(number);
        if (cleaned != null && !accountNumbers.contains(cleaned)) {
          accountNumbers.add(cleaned);
        }
      }
      final singleLicense = _pipText(widget.data.licenseNo);
      if (singleLicense != null && !accountNumbers.contains(singleLicense)) {
        accountNumbers.add(singleLicense);
      }
      for (final number in accountNumbers) {
        selectedAllocations.add(<String, Object?>{
          'accountNo': number,
          'accountName': null,
          'amount': null,
        });
      }
    } else {
      serviceType = 'Kompaun';
      accountName = _pipText(widget.data.offenderName);
      for (final number in widget.data.compoundNos ?? <String>[]) {
        final cleaned = _pipText(number);
        if (cleaned != null && !accountNumbers.contains(cleaned)) {
          accountNumbers.add(cleaned);
        }
      }
      final saman = _pipText(widget.data.samanNo);
      if (saman != null && !accountNumbers.contains(saman)) {
        accountNumbers.add(saman);
      }

      final selectedCompounds = widget.data.compoundItems;
      if (selectedCompounds != null && selectedCompounds.isNotEmpty) {
        for (final item in selectedCompounds) {
          final number = _pipText(
            item['compound_no'] ??
                item['compoundNo'] ??
                item['account_no'] ??
                item['accountNo'],
          );
          if (number != null && !accountNumbers.contains(number)) {
            accountNumbers.add(number);
          }
          selectedAllocations.add(<String, Object?>{
            'accountNo': number,
            'accountName': _pipText(
              item['offender_name'] ?? item['offenderName'],
            ) ?? accountName,
            'amount': _selectedAccountAmount(item),
          });
        }
      } else {
        for (final number in accountNumbers) {
          selectedAllocations.add(<String, Object?>{
            'accountNo': number,
            'accountName': accountName,
            'amount': null,
          });
        }
      }
    }

    final fallbackAccount = _pipText(widget.data.accountNo);
    if (accountNumbers.isEmpty && fallbackAccount != null) {
      accountNumbers.add(fallbackAccount);
      selectedAllocations.add(<String, Object?>{
        'accountNo': fallbackAccount,
        'accountName': accountName,
        'amount': originalAmount,
      });
    }

    final allocations = _municipalAllocations(
      selected: selectedAllocations,
      originalAmount: originalAmount,
      serviceType: serviceType,
    );

    final joined = accountNumbers.join(', ');
    final accountNo = joined.length <= 120 && joined.isNotEmpty
        ? joined
        : (accountNumbers.isEmpty ? null : accountNumbers.first);

    try {
      final transaction = PipMunicipalTransactionService(
        serviceType: serviceType,
        amount: originalAmount, // Bill total, never the RM0.05 QR test charge.
        paymentMethod: paymentMethod,
        accountNo: accountNo,
        accountName: accountName,
        paymentItems: allocations,
      );
      debugPrint(
        '[PIP] NEW municipal attempt: $serviceType '
        'account=${accountNo ?? '-'} amount=$originalAmount '
        'payment_items=${allocations.length}',
      );
      return transaction;
    } catch (error) {
      debugPrint('[PIP] Municipal reporting setup failed: $error');
      return null;
    }
  }

  Future<void> _markMunicipalPaid({
    required PipMunicipalTransactionService? pip,
    required Future<bool>? pendingRequest,
    String? bankTrxNo,
  }) async {
    if (pip == null) return;

    // PIP keeps the original bill amount from _newMunicipalAttempt().
    // The RM0.05 QR test amount is used only by PegePayService.createOrder().
    // Do not compare the gateway amount with the bill amount here.
    if (pendingRequest != null) {
      try {
        await pendingRequest;
      } catch (error) {
        debugPrint('[PIP] Municipal PENDING warning: $error');
      }
    }

    try {
      final saved = await pip.paid(bankTrxNo: bankTrxNo);
      debugPrint(
        '[PIP] Municipal PAID=$saved service=${pip.serviceType} '
        'billAmount=${pip.amount} reference=${pip.pipReferenceNo}',
      );
      if (!saved) {
        debugPrint('[PIP] Municipal PAID update unconfirmed; check PIP logs.');
      }
    } catch (error) {
      debugPrint('[PIP] Municipal PAID reporting error: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPaymentGuideDialog(context);
    });
  }

    Future<void> showPaymentGuideDialog(BuildContext context) async {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PaymentVideoGuide(),
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
    // MODERN + GOVERNMENT PAYMENT HEADER
    // ============================================================
    Positioned(
      top: 55,
      left: 80,
      right: 180,
      child: _ModernPaymentHeader(
        badgeText: AppLocalizations.of(context)!.paymentTitle,
        title: AppLocalizations.of(context)!.paymentTitle,
        subtitle: AppLocalizations.of(context)!.paymentSubtitle,
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
                    PipTransactionService? pipCard;
                    Future<bool>? pipCardPending;
                    PipMunicipalTransactionService? municipalCard;
                    Future<bool>? municipalCardPending;
                    
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

                      // PIP: create one record for this IM15 card attempt (Parking only).
                      pipCard = _pipEnabled
                          ? PipTransactionService.parking(
                              amount: double.tryParse(amount) ?? 0.0,
                              paymentMethod: 'Debit/Credit Card',
                              vehicleNo: widget.data.plate ?? '',
                              durationMinutes: (widget.data.hour ?? 0) * 60,
                              negeri: Config.negeri,
                              kawasan: Config.kawasan,
                              zon: Config.zon,
                              parkingPaymentType:
                                  widget.biz == 'EXTENDPARKING'
                                      ? 'EXTENSION'
                                      : 'NEW',
                              parkingSessionId:
                                  widget.data.parkingSessionId,
                            )
                          : null;

                      pipCardPending = pipCard?.pending();

                      // Municipal PENDING is independent of the working parking path.
                      municipalCard = _newMunicipalAttempt(
                        paymentMethod: 'Debit/Credit Card',
                        originalAmount: _municipalBillAmount(),
                      );
                      municipalCardPending = municipalCard?.pending();
                  
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

                          // PIP is independent of the council update result.
                          // IM15 reported success; record this municipal attempt
                          // even if the later Cukai/Sewaan provider API fails.
                          if (municipalCard != null) {
                            unawaited(_markMunicipalPaid(
                              pip: municipalCard,
                              pendingRequest: municipalCardPending,
                            ));
                          }

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
                            // Start PIP and ParkingService independently at the same time.
                                  // Neither API waits for the other to finish.
                                  unawaited(_saveParkingPaid(
                                    pip: pipCard,
                                    pendingRequest: pipCardPending,
                                    extension: false,
                                    bankTrxNo: null,
                                  ));
                                  final parkingRequest = ParkingService.callParkingPayAPI(
                              plate: widget.data.plate ?? "",
                              timeUsed: widget.data.hour ?? 0,
                              typePayment: "Debit/Credit Card",
                              orderNo: "0",
                              bankTrxNo: "0",
                            );
                                  final result = await parkingRequest;
                  
                          if (result != null && !result.startsWith("Error")) {
                            // =====================================================
                            // PIP - CARD PARKING PAID
                            // =====================================================
                            

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
                            // Start PIP and ParkingService independently at the same time.
                                  // Neither API waits for the other to finish.
                                  unawaited(_saveParkingPaid(
                                    pip: pipCard,
                                    pendingRequest: pipCardPending,
                                    extension: true,
                                    bankTrxNo: null,
                                  ));
                                  final parkingRequest = ParkingService.callParkingExtendAPI(
                              plate: widget.data.plate ?? "",
                              extendHours: widget.data.hour ?? 0,
                              typePayment: "Debit/Credit Card",
                              orderNo: "0",
                              bankTrxNo: "0",
                            );
                                  final result = await parkingRequest;

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

                          // PIP: close this attempt as FAILED when IM15 reports failure.
                          // A cancellation is kept separate from a confirmed failure.
                          if (pipCard != null) {
                            unawaited(() async {
                              try {
                                await pipCardPending;
                                final saved = cancelToken.isCancelled
                                    ? await pipCard!.cancelled()
                                    : await pipCard!.failed();
                                debugPrint('[PIP] CARD final status saved: $saved');
                              } catch (e) {
                                debugPrint('[PIP] CARD status error: $e');
                              }
                            }());
                          }

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
                          // Always keep the original bill amount for PIP and PBT.
                          final double originalAmount = _municipalBillAmount();

                          // QR testing only changes the amount charged by PegePay.
                          final double paymentAmount =
                              enableQrTesting ? qrTestingAmount : originalAmount;

                          showLoadingDialog(context);

                        
                          try {
                            final result = await PegePayService.createOrder(
                              paymentAmount,
                              Config.storeId,
                              Config.terminalId,
                              Config.shiftId,
                            );

                           //  Navigator.pop(context);
                        
                            final iframeUrl = result["iframe_url"];
                            final orderNo = result["order_no"];
                        
                            if (iframeUrl == null || orderNo == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to create PegePay order.")),
                              );
                              return;
                            }

                            // =====================================================
                            // PIP - QR PARKING PENDING
                            // =====================================================
                            final PipTransactionService? pipQr = _pipEnabled
                                ? PipTransactionService.parking(
                                    amount: originalAmount, // Original parking tariff, not RM0.05.
                                    paymentMethod: 'DuitNow QR',
                                    vehicleNo: widget.data.plate ?? '',
                                    durationMinutes: (widget.data.hour ?? 0) * 60,
                                    negeri: Config.negeri,
                                    kawasan: Config.kawasan,
                                    zon: Config.zon,
                                    parkingPaymentType:
                                        widget.biz == 'EXTENDPARKING'
                                            ? 'EXTENSION'
                                            : 'NEW',
                                    parkingSessionId:
                                        widget.data.parkingSessionId,
                                  )
                                : null;

                                  final Future<bool>? pipQrPending = pipQr?.pending();

                            // NEW QR order => NEW PIP PENDING for municipal services.
                            final municipalQr = _newMunicipalAttempt(
                              paymentMethod: 'DuitNow QR',
                              originalAmount: _municipalBillAmount(),
                            );
                            final Future<bool>? municipalQrPending =
                                municipalQr?.pending();
                        
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

                            /*
                            * Null while the QR is active.
                            * Created only after successful payment is detected.
                            */
                            OverlayEntry? qrSuccessOverlay;

                            await PegePayWebViewHelper.open(
                              iframeUrl: iframeUrl,
                              orderNo: orderNo,

                              onQrWindowOpened: () {
                                if (!mounted) return;

                                // Close the loading dialog when the QR window launches.
                                Navigator.of(context, rootNavigator: true).pop();
                              },

                              /*
                              * Called only when the backend reports that payment
                              * was successful. It is not called when Batal is pressed.
                              */
                              onPaymentDetected: () async {
                                if (!mounted) {
                                  return;
                                }

                                print(
                                  '[PegePay] Payment detected. '
                                  'Preparing loading overlay.',
                                );

                                qrSuccessOverlay ??=
                                    showQrPaymentSuccessOverlay(
                                  context,
                                  amount: widget.data.amount ?? '0.00',
                                );

                                /*
                                * Wait until Flutter paints the overlay.
                                * The QR window is still covering Flutter during this step.
                                */
                                await WidgetsBinding.instance.endOfFrame;

                                print(
                                  '[PegePay] Loading overlay is ready',
                                );
                              },

                                onSuccess: (
                                  Map<String, dynamic> paymentResult,
                                ) async {
                                  if (!mounted) {
                                    return;
                                  }

                                  final pegeOrderNo =
                                      paymentResult["order_no"] ?? orderNo;

                                  final pegeBankTrxNo =
                                      paymentResult["bank_trx_no"] ?? "";

                                  /*
                                  * Normally the overlay was already created by
                                  * onPaymentDetected. This is only a safety fallback.
                                  */
                                  qrSuccessOverlay ??=
                                      showQrPaymentSuccessOverlay(
                                    context,
                                    amount: widget.data.amount ?? '0.00',
                                  );

                                  await WidgetsBinding.instance.endOfFrame;

                                  // Gateway confirmed this QR order. Report to
                                  // PIP now, without waiting for Cukai/Sewaan
                                  // council APIs or the receipt navigation.
                                  if (municipalQr != null) {
                                    unawaited(_markMunicipalPaid(
                                      pip: municipalQr,
                                      pendingRequest: municipalQrPending,
                                      bankTrxNo: pegeBankTrxNo.toString(),
                                    ));
                                  }

                                if (widget.biz == "PARKING") {
                                  // EXISTING PARKING API - KEEP UNCHANGED
                                  // Start PIP and ParkingService independently at the same time.
                                  // Neither API waits for the other to finish.
                                  unawaited(_saveParkingPaid(
                                    pip: pipQr,
                                    pendingRequest: pipQrPending,
                                    extension: false,
                                    bankTrxNo: (pegeBankTrxNo.toString().trim().isEmpty ? null : pegeBankTrxNo.toString().trim()),
                                  ));
                                  final parkingRequest = ParkingService.callParkingPayAPI(
                                    plate: widget.data.plate ?? "",
                                    timeUsed: widget.data.hour ?? 0,
                                    typePayment: "DuitNow QR",
                                    orderNo: pegeOrderNo,
                                    bankTrxNo: pegeBankTrxNo,
                                  );
                                  final result = await parkingRequest;

                                  if (result != null &&
                                      !result.startsWith('Error')) {
                                    

                                      removeQrPaymentSuccessOverlay(qrSuccessOverlay);
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
                                 // Start PIP and ParkingService independently at the same time.
                                  // Neither API waits for the other to finish.
                                  unawaited(_saveParkingPaid(
                                    pip: pipQr,
                                    pendingRequest: pipQrPending,
                                    extension: true,
                                    bankTrxNo: (pegeBankTrxNo.toString().trim().isEmpty ? null : pegeBankTrxNo.toString().trim()),
                                  ));
                                  final parkingRequest = ParkingService.callParkingExtendAPI(
                                   plate: widget.data.plate ?? "",
                                   extendHours: widget.data.hour ?? 0,
                                   typePayment: "DuitNow",
                                     orderNo: pegeOrderNo,
                                    bankTrxNo: pegeBankTrxNo,
                                 );
                                  final result = await parkingRequest;
                               
                                 if (result != null && !result.startsWith("Error")) {
                                   

                                  removeQrPaymentSuccessOverlay(qrSuccessOverlay);
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
                                   removeQrPaymentSuccessOverlay(qrSuccessOverlay);

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

                                      removeQrPaymentSuccessOverlay(qrSuccessOverlay);
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
                                      removeQrPaymentSuccessOverlay(
                                        qrSuccessOverlay,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Cukai payment saved to MPB, but local update failed"),
                                        ),
                                      );
                                      return;
                                    }


                                    removeQrPaymentSuccessOverlay(qrSuccessOverlay);

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
                                    removeQrPaymentSuccessOverlay(qrSuccessOverlay);

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
                                          removeQrPaymentSuccessOverlay(qrSuccessOverlay);
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
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Sewaan payment saved to MPB, but local update failed"),
                                            ),
                                          );
                                          return;
                                        }

                                        removeQrPaymentSuccessOverlay(qrSuccessOverlay);

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
                                     removeQrPaymentSuccessOverlay(
                                       qrSuccessOverlay,
                                     );
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text("Tiada lesen dipilih")),
                                     );
                                     return;
                                   }
                                 
                                   final success =
                                       await LicenseService.payMultipleLicenses(licenseNos);
                                 
                                   if (success) {
                                    removeQrPaymentSuccessOverlay(qrSuccessOverlay);
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
                                     removeQrPaymentSuccessOverlay(qrSuccessOverlay);
                                     
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

                                 removeQrPaymentSuccessOverlay(qrSuccessOverlay);
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
                                  removeQrPaymentSuccessOverlay(qrSuccessOverlay);
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
                            print(
                              '[PegePay] User cancelled QR payment',
                            );
                            // PIP: QR closed without a successful payment.
                            // Treat this attempt as FAILED as requested.
                            // NOTE: Only safe if onCancel cannot run after bank approval.
                            if (pipQr != null) {
                              unawaited(() async {
                                try {
                                  await pipQrPending;
                                  final saved = await pipQr.cancelled();
                                  debugPrint('[PIP] QR CANCELLED saved: $saved');
                                } catch (e) {
                                  debugPrint('[PIP] QR CANCELLED error: $e');
                                }
                              }());
                            }
                            /*
                            * Usually this is null because payment was not successful.
                            * This cleanup is safe even when the overlay does not exist.
                            */
                            removeQrPaymentSuccessOverlay(
                              qrSuccessOverlay,
                            );

                            qrSuccessOverlay = null;

                            currentRouteName = '/payment';

                              try {
                                if (Platform.isWindows) {
                                  await windowManager.show();
                                  await windowManager.focus();
                                } else if (Platform.isLinux) {
                                  await windowManager.show();
                                  await windowManager.focus();
                                  await windowManager.setFullScreen(true);
                                }
                              } catch (e) {
                                debugPrint('[PegePay] Window restoration warning: $e');
                              }

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Payment cancelled',
                                ),
                              ),
                            );
                          },
                            );
                                                              
                            //     ),
                            //   ),
                            // );
                              } catch (e) {
                                // ============================================================
                                // PEGE PAY / QR SERVICE ERROR
                                // ============================================================

                                // Close loading dialog.
                                if (Navigator.of(context, rootNavigator: true).canPop()) {
                                  Navigator.of(context, rootNavigator: true).pop();
                                }

                                //PIP - QR CANCELLATION

                                currentRouteName = '/payment';

                                // Keep the real technical error in the log for troubleshooting.
                                debugPrint('[PegePay] createOrder error: $e');

                                if (!mounted) return;

                                final loc = AppLocalizations.of(context)!;

                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  useRootNavigator: true,
                                  builder: (dialogContext) {
                                    return PopScope(
                                      canPop: false,
                                      child: Dialog(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        child: Container(
                                          width: 650,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 45,
                                            vertical: 42,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(
                                              color: const Color(0xFFF2B8B5),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.30),
                                                blurRadius: 30,
                                                spreadRadius: 3,
                                                offset: const Offset(0, 14),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // ============================================================
                                              // ERROR ICON
                                              // ============================================================
                                              Container(
                                                width: 130,
                                                height: 130,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFEBEE),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(0xFFD32F2F),
                                                    width: 5,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.qr_code_2_rounded,
                                                  color: Color(0xFFD32F2F),
                                                  size: 78,
                                                ),
                                              ),

                                              const SizedBox(height: 28),

                                              // ============================================================
                                              // TITLE
                                              // ============================================================
                                              Text(
                                                loc.pegePayUnavailableTitle,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xFFB71C1C),
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.w900,
                                                  height: 1.15,
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              // ============================================================
                                              // MESSAGE
                                              // ============================================================
                                              Text(
                                                loc.pegePayUnavailableMessage,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xFF334155),
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.45,
                                                ),
                                              ),

                                              const SizedBox(height: 35),

                                              // ============================================================
                                              // OK BUTTON
                                              // ============================================================
                                              SizedBox(
                                                width: 280,
                                                height: 72,
                                                child: FilledButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      dialogContext,
                                                      rootNavigator: true,
                                                    ).pop();
                                                  },
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor: const Color(0xFFD32F2F),
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(18),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    loc.pegePayUnavailableOk,
                                                    style: const TextStyle(
                                                      fontSize: 27,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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

// ============================================================
// MODERN KIOSK INFO BUTTON
// ============================================================
Positioned(
  top: 100,
  right: 30,
  child: GestureDetector(
    onTap: () {
      showPaymentGuideDialog(context);
    },
    child: Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF075FD8),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF075FD8).withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFB9D6F7),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.info_rounded,
            color: Color(0xFF075FD8),
            size: 80,
          ),
        ),
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

class _PaymentKioskButtonState extends State<_PaymentKioskButton> {
  bool _isPressed = false;
  bool _isFocused = false;

  void _setPressed(bool value) {
    if (!mounted || _isPressed == value) return;

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengikut pengesanan Kad / QR dalam kod asal anda.
    final bool isQr = widget.label.toLowerCase().contains('qr');

    final Color accentColor = isQr
        ? const Color(0xFF15946B)
        : const Color(0xFF1469E8);

    final Color lightColor = isQr
        ? const Color(0xFFE2F7EF)
        : const Color(0xFFE5F0FF);

    final bool emphasized = _isPressed || _isFocused;
    final BorderRadius radius = BorderRadius.circular(26);

    final Color borderColor = emphasized
        ? accentColor
        : Color.lerp(
            const Color(0xFFB9C8DA),
            accentColor,
            0.28,
          )!;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 400,
        height: 430,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18324F).withOpacity(
                _isPressed ? 0.05 : 0.11,
              ),
              blurRadius: _isPressed ? 8 : 18,
              offset: Offset(0, _isPressed ? 2 : 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: borderColor,
              width: 2,
            ),
          ),
          child: InkWell(
            // Kekalkan tindakan pembayaran asal.
            onTap: widget.onPressed,
            onHighlightChanged: _setPressed,
            onFocusChange: (focused) {
              if (!mounted) return;

              setState(() {
                _isFocused = focused;
              });
            },
            splashColor: accentColor.withOpacity(0.10),
            highlightColor: accentColor.withOpacity(0.04),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==========================================
                    // PANEL IKON TERAPUNG
                    // ==========================================
                    SizedBox(
                      height: 230,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 165,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    lightColor,
                                    Color.lerp(
                                      Colors.white,
                                      lightColor,
                                      0.40,
                                    )!,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 22,
                            right: 22,
                            top: 24,
                            bottom: 10,
                            child: IgnorePointer(
                              child: ExcludeSemantics(
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Color.lerp(
                                      Colors.white,
                                      lightColor,
                                      0.18,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(22),
                                    border: Border.all(
                                      color: accentColor.withOpacity(0.22),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor.withOpacity(
                                          _isPressed ? 0.08 : 0.15,
                                        ),
                                        blurRadius: _isPressed ? 10 : 18,
                                        offset: Offset(
                                          0,
                                          _isPressed ? 3 : 7,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: SizedBox(
                                            width: 130,
                                            height: 130,
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Icon(
                                                widget.icon,
                                                size: 130,
                                                color: accentColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==========================================
                    // TEKS BUTANG — AUTO FIT
                    // ==========================================
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          28,
                          22,
                          28,
                          28,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: Text(
                                    widget.label.toUpperCase(),
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF142D4E),
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      height: 1.16,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Border sentiasa kelihatan di atas panel.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(
                          color: borderColor,
                          width: emphasized ? 3 : 2,
                        ),
                      ),
                    ),
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


// ============================================================================
// MODERN + GOVERNMENT PAYMENT HEADER
// ============================================================================
class _ModernPaymentHeader extends StatelessWidget {
  final String badgeText;
  final String title;
  final String subtitle;

  const _ModernPaymentHeader({
    required this.badgeText,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFD5E4F7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A66).withOpacity(0.14),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          // ==========================================================
          // LEFT PAYMENT ICON
          // ==========================================================
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF064AA3),
                  Color(0xFF1478D4),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF095AB8).withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(width: 28),

          // ==========================================================
          // TEXT AREA
          // ==========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small payment badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F3FF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 20,
                        color: Color(0xFF1265BC),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        badgeText.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF1265BC),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Main title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF122C4C),
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1.02,
                    letterSpacing: -0.8,
                  ),
                ),

                const SizedBox(height: 9),

                // Subtitle
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607188),
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ==========================================================
          // RIGHT ACCENT BAR
          // ==========================================================
          Container(
            width: 8,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0751A8),
                  Color(0xFF2196E8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
