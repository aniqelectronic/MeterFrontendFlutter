import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/services/iimmpact/bill_receipt_service.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

// ============================================================================
// TELCO POSTPAID RECEIPT EXTRA DATA
// ============================================================================

class TelcoReceiptExtraData {
  final String providerName;
  final String productCode;
  final String accountNumber;

  final double providerAmount;
  final double serviceAdjustment;
  final double customerTotal;

  const TelcoReceiptExtraData({
    required this.providerName,
    required this.productCode,
    required this.accountNumber,
    required this.providerAmount,
    required this.serviceAdjustment,
    required this.customerTotal,
  });
}

// ============================================================================
// MOBILE PIN RECEIPT ITEM
// ============================================================================

class MobilePinReceiptItem {
  final String refId;
  final String serialNumber;
  final String pin;
  final String expiry;
  final String note;
  final String voucherLink;

  const MobilePinReceiptItem({
    required this.refId,
    required this.serialNumber,
    required this.pin,
    required this.expiry,
    required this.note,
    required this.voucherLink,
  });
}

// ============================================================================
// EWALLET RECEIPT EXTRA DATA
// ============================================================================

class EWalletReceiptExtraData {
  final String providerName;
  final String productCode;
  final String phoneNumber;

  final double reloadAmount;
  final double serviceAdjustment;
  final double customerTotal;

  final bool isPin;

    // Catalog note.
  final String providerNote;

  final String serialNumber;
  final String pin;
  final String expiry;
  final String note;
  final String voucherLink;

  const EWalletReceiptExtraData({
    required this.providerName,
    required this.productCode,
    required this.phoneNumber,
    required this.reloadAmount,
    required this.serviceAdjustment,
    required this.customerTotal,
    required this.isPin,
    this.providerNote = '',
    this.serialNumber = '',
    this.pin = '',
    this.expiry = '',
    this.note = '',
    this.voucherLink = '',
  });
}

// ============================================================================
// MOBILE PIN RECEIPT EXTRA DATA
// ============================================================================

class MobilePinReceiptExtraData {
  final String providerName;
  final String productCode;

  final double denomination;

  // Keep for future multiple PIN support.
  // Currently not shown in receipt UI.
  final int quantity;

  final double customerTotal;

  final List<MobilePinReceiptItem> pins;

  const MobilePinReceiptExtraData({
    required this.providerName,
    required this.productCode,
    required this.denomination,
    required this.quantity,
    required this.customerTotal,
    required this.pins,
  });
}

// ============================================================================
// SHARED BILL RECEIPT DATA
// ============================================================================

class BillReceiptData {
  final String billType;
  final String billCode;
  final String accountNumber;

  final double billAmount;
  final double totalAmount;

  final String orderNo;
  final String bankTransactionNo;

  final String paymentMethod;

  final DateTime paidAt;

  final String? refId;

  final TelcoReceiptExtraData? telco;

  final MobilePinReceiptExtraData? mobilePin;

  final EWalletReceiptExtraData? eWallet;

  const BillReceiptData({
    required this.billType,
    required this.billCode,
    required this.accountNumber,
    required this.billAmount,
    required this.totalAmount,
    required this.orderNo,
    required this.bankTransactionNo,
    this.paymentMethod = 'DuitNow QR',
    required this.paidAt,
    this.refId,
    this.telco,
    this.mobilePin,
    this.eWallet,
  });
}

// ============================================================================
// RECEIPT PAGE
// ============================================================================

class BillReceiptPage extends StatefulWidget {
  final BillReceiptData data;

  const BillReceiptPage({
    super.key,
    required this.data,
  });

  @override
  State<BillReceiptPage> createState() =>
      _BillReceiptPageState();
}

class _BillReceiptPageState
    extends State<BillReceiptPage> {
  // ==========================================================================
  // AUTO HOME
  // ==========================================================================
  //
  // AUTO HOME IS DISABLED FOR NOW.
  //
  // Keep these variables/functions so it is easy to enable again later.
  // ==========================================================================

  static const int _countdownDuration =
      150;

  Timer? _countdownTimer;

  int _remainingSeconds =
      _countdownDuration;

  Uint8List? _receiptQrBytes;

  bool _isReceiptQrLoading =
      true;

  bool _receiptQrLoadFailed =
      false;

  bool _hasEWalletProviderSurcharge(
  EWalletReceiptExtraData eWallet,
) {
  return eWallet.providerNote
      .toLowerCase()
      .contains(
        'surcharge',
      );
}

double _getEWalletProviderSurcharge(
  EWalletReceiptExtraData eWallet,
) {
  final match =
      RegExp(
    r'RM\s*([0-9]+(?:\.[0-9]+)?)',
    caseSensitive: false,
  ).firstMatch(
    eWallet.providerNote,
  );

  if (match == null) {
    return 0;
  }

  return double.tryParse(
        match.group(1) ?? '',
      ) ??
      0;
}

// ==========================================================================
// RECEIPT TYPE
// ==========================================================================

bool get _isTelcoPostpaid {
  return widget.data.telco != null;
}

bool get _isMobilePin {
  return widget.data.mobilePin != null;
}

bool get _isEWallet {
  return widget.data.eWallet != null;
}

bool get _isEWalletPin {
  return _isEWallet &&
      widget.data.eWallet!.isPin;
}

bool get _isEWalletPinless {
  return _isEWallet &&
      !widget.data.eWallet!.isPin;
}

bool get _isStandardBill {
  return !_isTelcoPostpaid &&
      !_isMobilePin &&
      !_isEWallet;
}


TelcoReceiptExtraData? get _telco {
  return widget.data.telco;
}

MobilePinReceiptExtraData?
    get _mobilePin {
  return widget.data.mobilePin;
}

EWalletReceiptExtraData?
    get _eWallet {
  return widget.data.eWallet;
}

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    // ========================================================================
    // STANDARD BILL:
    // Keep existing digital receipt QR.
    //
    // TELCO POSTPAID:
    // No e-receipt QR yet.
    //
    // MOBILE PIN:
    // No e-receipt QR yet.
    // ========================================================================

    if (_isStandardBill) {
      _fetchReceiptQr();
    } else {
      _receiptQrBytes = null;
      _isReceiptQrLoading =
          false;
      _receiptQrLoadFailed =
          false;
    }

    // ========================================================================
    // AUTO HOME DISABLED FOR NOW
    // ========================================================================
    //
    // Uncomment this later if automatic home return is needed.
    //
    // _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();

    super.dispose();
  }

  // ==========================================================================
  // ORIGINAL BILL RECEIPT QR
  // ==========================================================================

  Future<void> _fetchReceiptQr() async {
    if (!_isStandardBill) {
      return;
    }

    setState(() {
      _isReceiptQrLoading =
          true;

      _receiptQrLoadFailed =
          false;
    });

    try {
      final Uint8List qrBytes =
          await BillReceiptService
              .generateReceiptQr(
        orderNo:
            widget.data.orderNo,

        paidDate:
            widget.data.paidAt,

        paymentMethod:
            widget.data.paymentMethod,

        bankTransactionNo:
            widget.data.bankTransactionNo,

        billType:
            widget.data.billType,

        billCode:
            widget.data.billCode,

        accountNumber:
            widget.data.accountNumber,

        billAmount:
            widget.data.billAmount,

        totalAmount:
            widget.data.totalAmount,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _receiptQrBytes =
            qrBytes;

        _isReceiptQrLoading =
            false;

        _receiptQrLoadFailed =
            false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        '[BillReceiptPage] '
        'Receipt QR error: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _receiptQrBytes =
            null;

        _isReceiptQrLoading =
            false;

        _receiptQrLoadFailed =
            true;
      });
    }
  }

  // ==========================================================================
  // COUNTDOWN
  // ==========================================================================
  //
  // Kept for future use.
  //
  // Not started in initState right now.
  // ==========================================================================

  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer =
        Timer.periodic(
      const Duration(
        seconds:
            1,
      ),
      (
        Timer timer,
      ) {
        if (_remainingSeconds <=
            1) {
          timer.cancel();

          if (mounted) {
            _goHome();
          }

          return;
        }

        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
  }

  // ==========================================================================
  // HOME
  // ==========================================================================
  //
  // HOME BUTTON REMAINS ACTIVE.
  // ==========================================================================

  void _goHome() {
    _countdownTimer?.cancel();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings:
            const RouteSettings(
          name:
              '/p1',
        ),
        builder:
            (_) =>
                const P1BentongPage(),
      ),
      (
        Route<dynamic> route,
      ) =>
          false,
    );
  }

  // ==========================================================================
  // FORMATTERS
  // ==========================================================================

  String _safeValue(
    String value,
  ) {
    final String cleaned =
        value.trim();

    if (cleaned.isEmpty ||
        cleaned.toLowerCase() ==
            'null') {
      return '-';
    }

    return cleaned;
  }

  String _formatAmount(
    double amount,
  ) {
    return 'RM '
        '${amount.toStringAsFixed(2)}';
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final DateTime local =
        dateTime.toLocal();

    final String day =
        local.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String month =
        local.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String year =
        local.year.toString();

    final String hour =
        local.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String minute =
        local.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String second =
        local.second
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/$year '
        '$hour:$minute:$second';
  }

  // ============================================================
  // E-WALLET NOTE LOCALIZATION
  // ============================================================

  String _getLocalizedEWalletNote(
    AppLocalizations loc,
    String? apiNote,
  ) {
    final note = apiNote?.trim() ?? '';

    if (note.isEmpty) {
      return '';
    }

    final lowerNote = note.toLowerCase();

    // TNG PIN note returned by IIMMPACT.
    if (lowerNote.contains('to redeem') &&
        lowerNote.contains('touch n go')) {
      return loc.eWalletTngRedeemNote;
    }

    // Keep any unknown IIMMPACT note unchanged.
    return note;
  }


  // ==========================================================================
  // PAGE
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    return PopScope(
      canPop:
          false,

      child:
          Scaffold(
        resizeToAvoidBottomInset:
            false,

        body:
            Stack(
          children: [
            // ================================================================
            // BACKGROUND
            // ================================================================

            Positioned.fill(
              child:
                  Image.asset(
                'lib/images/pnew.png',
                fit:
                    BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child:
                  DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,

                    end:
                        Alignment.bottomCenter,

                    colors: [
                      Colors.white.withOpacity(
                        0.18,
                      ),
                      Colors.white.withOpacity(
                        0.38,
                      ),
                      Colors.white.withOpacity(
                        0.28,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ================================================================
            // PAGE CONTENT
            // ================================================================

            SafeArea(
              child:
                  Column(
                children: [
                  // ==========================================================
                  // HEADER
                  // ==========================================================

                  if (_isMobilePin)
                    _buildMobilePinHeader(
                      loc,
                    )
                  else if (_isEWallet)
                    _buildEWalletHeader(
                      loc,
                    )
                  else if (_isTelcoPostpaid)
                    _buildTelcoHeader(
                      loc,
                    )
                  else
                    _buildHeader(
                      loc,
                    ),

                  // ==========================================================
                  // RECEIPT CONTENT
                  // ==========================================================

                  Expanded(
                    child:
                        Padding(
                      padding:
                          const EdgeInsets.only(
                        right:
                            18,
                      ),

                      child:
                          Scrollbar(
                        thumbVisibility:
                            true,

                        trackVisibility:
                            true,

                        thickness:
                            10,

                        radius:
                            const Radius.circular(
                          20,
                        ),

                        child:
                            SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(
                            55,
                            34,
                            55,
                            28,
                          ),

                          child:
                              _buildReceiptBody(
                            loc,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==========================================================
                  // BOTTOM
                  //
                  // Countdown removed.
                  // HOME button still displayed.
                  // ==========================================================

                  _buildBottomSection(
                    loc,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // RECEIPT BODY
  // ==========================================================================

    Widget _buildReceiptBody(
      AppLocalizations loc,
    ) {
      if (_isMobilePin) {
        return _buildMobilePinReceiptCard(
          loc,
        );
      }

      if (_isEWalletPin) {
        return _buildEWalletPinReceiptCard(
          loc,
        );
      }

      if (_isEWalletPinless) {
        return _buildEWalletPinlessReceiptCard(
          loc,
        );
      }

      if (_isTelcoPostpaid) {
        return _buildTelcoReceiptCard(
          loc,
        );
      }

      return _buildReceiptCard(
        loc,
      );
    }

  // ==========================================================================
  // STANDARD HEADER
  // ==========================================================================

  Widget _buildHeader(
    AppLocalizations loc,
  ) {
    return _buildCommonHeader(
      colors:
          const [
        Color(
          0xFF164FA5,
        ),
        Color(
          0xFF1D73CD,
        ),
        Color(
          0xFF39A5F4,
        ),
      ],

      leftIcon:
          Icons.receipt_long_rounded,

      title:
          loc.receiptPaymentTitle,
    );
  }

  // ==========================================================================
  // TELCO HEADER
  // ==========================================================================

  Widget _buildTelcoHeader(
    AppLocalizations loc,
  ) {
    return _buildCommonHeader(
      colors:
          const [
        Color(
          0xFF075B47,
        ),
        Color(
          0xFF15946B,
        ),
        Color(
          0xFF2AC69B,
        ),
      ],

      leftIcon:
          Icons.phone_android_rounded,

      title:
          loc.telcoReceiptTitle,

      subtitle:
          _safeValue(
        _telco?.providerName ??
            '',
      ),
    );
  }

  // ==========================================================================
  // MOBILE PIN HEADER
  // ==========================================================================

  Widget _buildMobilePinHeader(
    AppLocalizations loc,
  ) {
    return _buildCommonHeader(
      colors:
          const [
        Color(
          0xFF0D47A1,
        ),
        Color(
          0xFF1769D2,
        ),
        Color(
          0xFF42A5F5,
        ),
      ],

      leftIcon:
          Icons.sim_card_download_rounded,

      title:
          loc.mobilePinReceiptTitle,

      subtitle:
          _safeValue(
        _mobilePin?.providerName ??
            '',
      ),
    );
  }

  // ==========================================================================
  // E-WALLET PIN HEADER
  // ==========================================================================

  Widget _buildEWalletHeader(
    AppLocalizations loc,
  ) {
    final EWalletReceiptExtraData eWallet =
        _eWallet!;

    return _buildCommonHeader(
      colors: const [
        Color(0xFFD35400),
        Color(0xFFEF6C35),
        Color(0xFFFFA264),
      ],
      leftIcon:
          eWallet.isPin
              ? Icons.key_rounded
              : Icons.account_balance_wallet_rounded,
      title:
          eWallet.isPin
              ? loc.eWalletPinReceiptTitle
              : loc.eWalletReloadReceiptTitle,
      subtitle:
          _safeValue(
        eWallet.providerName,
      ),
    );
  }

  // ==========================================================================
  // COMMON HEADER
  // ==========================================================================

  Widget _buildCommonHeader({
    required List<Color> colors,
    required IconData leftIcon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        55,
        32,
        55,
        0,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal:
            32,
        vertical:
            24,
      ),

      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.centerLeft,

          end:
              Alignment.centerRight,

          colors:
              colors,
        ),

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        boxShadow: [
          BoxShadow(
            color:
                colors.first.withOpacity(
              0.24,
            ),

            blurRadius:
                22,

            offset:
                const Offset(
              0,
              10,
            ),
          ),
        ],
      ),

      child:
          Row(
        children: [
          Container(
            width:
                68,
            height:
                68,

            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.18,
              ),

              borderRadius:
                  BorderRadius.circular(
                19,
              ),
            ),

            child:
                Icon(
              leftIcon,
              color:
                  Colors.white,
              size:
                  43,
            ),
          ),

          const SizedBox(
            width:
                22,
          ),

          Expanded(
            child:
                Column(
              children: [
                Text(
                  title.toUpperCase(),

                  textAlign:
                      TextAlign.center,

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize:
                        40,

                    fontWeight:
                        FontWeight.w900,

                    letterSpacing:
                        0.5,
                  ),
                ),

                if (subtitle !=
                        null &&
                    subtitle !=
                        '-') ...[
                  const SizedBox(
                    height:
                        5,
                  ),

                  Text(
                    subtitle,

                    textAlign:
                        TextAlign.center,

                    maxLines:
                        1,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        TextStyle(
                      color:
                          Colors.white.withOpacity(
                        0.82,
                      ),

                      fontSize:
                          22,

                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(
            width:
                22,
          ),

          Container(
            width:
                68,
            height:
                68,

            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.18,
              ),

              borderRadius:
                  BorderRadius.circular(
                19,
              ),
            ),

            child:
                const Icon(
              Icons.check_circle_rounded,
              color:
                  Colors.white,
              size:
                  43,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // STANDARD BILL RECEIPT
  // ==========================================================================

  Widget _buildReceiptCard(
    AppLocalizations loc,
  ) {
    return _receiptOuterCard(
      borderColor:
          const Color(
        0xFFD2E2F2,
      ),

      child:
          Column(
        children: [
          const SizedBox(
            height:
                8,
          ),

          _buildSectionTitle(
            icon:
                Icons.description_rounded,

            title:
                loc.receiptTransactionDetailsTitle,

            accentColor:
                const Color(
              0xFF315F8C,
            ),

            backgroundColor:
                const Color(
              0xFFE6EEF6,
            ),
          ),

          const SizedBox(
            height:
                18,
          ),

          _buildDetailsContainer(
            [
              _ReceiptInfoRow(
                icon:
                    Icons.business_rounded,

                label:
                    loc.billProvider,

                value:
                    _safeValue(
                  widget.data.billType,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.code_rounded,

                label:
                    loc.billCode,

                value:
                    _safeValue(
                  widget.data.billCode,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.numbers_rounded,

                label:
                    loc.accountNumber,

                value:
                    _safeValue(
                  widget.data.accountNumber,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.qr_code_2_rounded,

                label:
                    loc.receiptPaymentMethodLabel,

                value:
                    _safeValue(
                  widget.data.paymentMethod,
                ),
              ),

              if (_safeValue(
                    widget.data.refId ??
                        '',
                  ) !=
                  '-')
                _ReceiptInfoRow(
                  icon:
                      Icons.tag_rounded,

                  label:
                      loc.receiptTransactionReference,

                  value:
                      _safeValue(
                    widget.data.refId ??
                        '',
                  ),

                  compactValue:
                      true,
                ),

                // ============================================================
                // ORDER NUMBER - HIDDEN FROM RECEIPT UI
                // Keep widget.data.orderNo for backend/internal use.
                // ============================================================

                // _ReceiptInfoRow(
                //   icon: Icons.receipt_long_rounded,
                //   label: loc.receiptOrderNumberLabel,
                //   value: _safeValue(
                //     widget.data.orderNo,
                //   ),
                //   compactValue: true,
                // ),

              if (_safeValue(
                    widget.data.bankTransactionNo,
                  ) !=
                  '-')
                _ReceiptInfoRow(
                  icon:
                      Icons.account_balance_rounded,

                  label:
                      loc.receiptBankTransactionLabel,

                  value:
                      _safeValue(
                    widget.data.bankTransactionNo,
                  ),

                  compactValue:
                      true,
                ),
            ],
          ),

          const SizedBox(
            height:
                26,
          ),

          _buildTotalCard(
            label:
                loc.receiptAmountLabel2,

            amount:
                widget.data.totalAmount,

            colors:
                const [
              Color(
                0xFF183B63,
              ),
              Color(
                0xFF2F6DA7,
              ),
            ],
          ),

          const SizedBox(
            height:
                26,
          ),

          _buildDigitalReceiptCard(
            loc,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TELCO POSTPAID RECEIPT
  // ==========================================================================

  Widget _buildTelcoReceiptCard(
    AppLocalizations loc,
  ) {
    final TelcoReceiptExtraData telco =
        _telco!;

    final String productCode =
        telco.productCode
            .trim()
            .toUpperCase();

    final String imageUrl =
        productCode.isEmpty
            ? ''
            : 'https://dashboard.iimmpact.com/img/$productCode.png';

    return _receiptOuterCard(
      borderColor:
          const Color(
        0xFFCBE4D8,
      ),

      child:
          Column(
        children: [
          _buildProviderCard(
            label:
                loc.telcoReceiptProvider,

            providerName:
                telco.providerName,

            imageUrl:
                imageUrl,

            colors:
                const [
              Color(
                0xFF075B47,
              ),
              Color(
                0xFF15946B,
              ),
              Color(
                0xFF22AB80,
              ),
            ],
          ),

          const SizedBox(
            height:
                28,
          ),

          _buildSectionTitle(
            icon:
                Icons.description_rounded,

            title:
                loc.telcoReceiptTransactionDetails,

            accentColor:
                const Color(
              0xFF15946B,
            ),

            backgroundColor:
                const Color(
              0xFFE4F3EC,
            ),
          ),

          const SizedBox(
            height:
                18,
          ),

          _buildDetailsContainer(
            [
              _ReceiptInfoRow(
                icon:
                    Icons.code_rounded,

                label:
                    loc.telcoReceiptProductCode,

                value:
                    _safeValue(
                  telco.productCode,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.phone_android_rounded,

                label:
                    loc.telcoReceiptAccountNumber,

                value:
                    _safeValue(
                  telco.accountNumber,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.qr_code_2_rounded,

                label:
                    loc.telcoReceiptPaymentMethod,

                value:
                    _safeValue(
                  widget.data.paymentMethod,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.schedule_rounded,

                label:
                    loc.telcoReceiptPaymentDate,

                value:
                    _formatDateTime(
                  widget.data.paidAt,
                ),

                compactValue:
                    true,
              ),

              if (_safeValue(
                    widget.data.refId ??
                        '',
                  ) !=
                  '-')
                _ReceiptInfoRow(
                  icon:
                      Icons.tag_rounded,

                  label:
                      loc.receiptTransactionReference,

                  value:
                      _safeValue(
                    widget.data.refId ??
                        '',
                  ),

                  compactValue:
                      true,
                ),

                // ============================================================
                // ORDER NUMBER - HIDDEN FROM RECEIPT UI
                // Keep widget.data.orderNo for backend/internal use.
                // ============================================================

                // _ReceiptInfoRow(
                //   icon: Icons.receipt_long_rounded,
                //   label: loc.telcoReceiptOrderNumber,
                //   value: _safeValue(
                //     widget.data.orderNo,
                //   ),
                //   compactValue: true,
                // ),

              if (_safeValue(
                    widget.data.bankTransactionNo,
                  ) !=
                  '-')
                _ReceiptInfoRow(
                  icon:
                      Icons.account_balance_rounded,

                  label:
                      loc.telcoReceiptBankTransaction,

                  value:
                      _safeValue(
                    widget.data.bankTransactionNo,
                  ),

                  compactValue:
                      true,
                ),
            ],
          ),

          const SizedBox(
            height:
                26,
          ),

          _buildTotalCard(
            label:
                loc.telcoReceiptTotalPaid,

            amount:
                telco.customerTotal,

            colors:
                const [
              Color(
                0xFF075B47,
              ),
              Color(
                0xFF15946B,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MOBILE PIN RECEIPT
  // ==========================================================================

  Widget _buildMobilePinReceiptCard(
    AppLocalizations loc,
  ) {
    final MobilePinReceiptExtraData mobilePin =
        _mobilePin!;

    final String productCode =
        mobilePin.productCode
            .trim()
            .toUpperCase();

    final String imageUrl =
        productCode.isEmpty
            ? ''
            : 'https://dashboard.iimmpact.com/img/$productCode.png';

    return _receiptOuterCard(
      borderColor:
          const Color(
        0xFFC8DBF3,
      ),

      child:
          Column(
        children: [
          // ==================================================================
          // PROVIDER
          // ==================================================================

          _buildProviderCard(
            label:
                loc.mobilePinReceiptProvider,

            providerName:
                mobilePin.providerName,

            imageUrl:
                imageUrl,

            colors:
                const [
              Color(
                0xFF0D47A1,
              ),
              Color(
                0xFF1769D2,
              ),
              Color(
                0xFF42A5F5,
              ),
            ],
          ),

          const SizedBox(
            height:
                28,
          ),

          // ==================================================================
          // TRANSACTION DETAILS
          // ==================================================================

          _buildSectionTitle(
            icon:
                Icons.description_rounded,

            title:
                loc.mobilePinReceiptTransactionDetails,

            accentColor:
                const Color(
              0xFF1769D2,
            ),

            backgroundColor:
                const Color(
              0xFFE8F1FD,
            ),
          ),

          const SizedBox(
            height:
                18,
          ),

          _buildDetailsContainer(
            [
              // ==============================================================
              // PRODUCT CODE
              // ==============================================================

              _ReceiptInfoRow(
                icon:
                    Icons.code_rounded,

                label:
                    loc.mobilePinReceiptProductCode,

                value:
                    _safeValue(
                  mobilePin.productCode,
                ),
              ),

              // ==============================================================
              // PIN VALUE
              // ==============================================================

              _ReceiptInfoRow(
                icon:
                    Icons.payments_rounded,

                label:
                    loc.mobilePinReceiptPinValue,

                value:
                    _formatAmount(
                  mobilePin.denomination,
                ),
              ),

              // ==============================================================
              // QUANTITY
              //
              // REMOVED FROM DISPLAY FOR NOW.
              //
              // Data is still kept in:
              //
              // mobilePin.quantity
              //
              // so multiple PIN support can be added later.
              // ==============================================================

              // _ReceiptInfoRow(
              //   icon:
              //       Icons.numbers_rounded,
              //
              //   label:
              //       loc.mobilePinReceiptQuantity,
              //
              //   value:
              //       '${mobilePin.quantity}',
              // ),

              // ==============================================================
              // PAYMENT METHOD
              // ==============================================================

              _ReceiptInfoRow(
                icon:
                    Icons.qr_code_2_rounded,

                label:
                    loc.mobilePinReceiptPaymentMethod,

                value:
                    _safeValue(
                  widget.data.paymentMethod,
                ),
              ),

              // ==============================================================
              // PAYMENT DATE
              // ==============================================================

              _ReceiptInfoRow(
                icon:
                    Icons.schedule_rounded,

                label:
                    loc.mobilePinReceiptPaymentDate,

                value:
                    _formatDateTime(
                  widget.data.paidAt,
                ),

                compactValue:
                    true,
              ),

              // ==============================================================
              // TRANSACTION REF
              // ==============================================================

              // if (_safeValue(
              //       widget.data.refId ??
              //           '',
              //     ) !=
              //     '-')
              //   _ReceiptInfoRow(
              //     icon:
              //         Icons.tag_rounded,

              //     label:
              //         loc.receiptTransactionReference,

              //     value:
              //         _safeValue(
              //       widget.data.refId ??
              //           '',
              //     ),

              //     compactValue:
              //         true,
              //   ),

              // ==============================================================
              // ORDER NUMBER
              //
              // REMOVED FROM MOBILE PIN DISPLAY FOR NOW.
              //
              // The value remains available as:
              //
              // widget.data.orderNo
              // ==============================================================

              // _ReceiptInfoRow(
              //   icon:
              //       Icons.receipt_long_rounded,
              //
              //   label:
              //       loc.mobilePinReceiptOrderNumber,
              //
              //   value:
              //       _safeValue(
              //     widget.data.orderNo,
              //   ),
              //
              //   compactValue:
              //       true,
              // ),

              // ==============================================================
              // BANK TRANSACTION
              // ==============================================================

              if (_safeValue(
                    widget.data.bankTransactionNo,
                  ) !=
                  '-')
                _ReceiptInfoRow(
                  icon:
                      Icons.account_balance_rounded,

                  label:
                      loc.mobilePinReceiptBankTransaction,

                  value:
                      _safeValue(
                    widget.data.bankTransactionNo,
                  ),

                  compactValue:
                      true,
                ),
            ],
          ),

          const SizedBox(
            height:
                26,
          ),

          // ==================================================================
          // PIN DETAILS
          // ==================================================================

          if (mobilePin.pins.isNotEmpty) ...[
            _buildSectionTitle(
              icon:
                  Icons.key_rounded,

              title:
                  loc.mobilePinReceiptPinDetails,

              accentColor:
                  const Color(
                0xFF1769D2,
              ),

              backgroundColor:
                  const Color(
                0xFFE8F1FD,
              ),
            ),

            const SizedBox(
              height:
                  18,
            ),

            for (
              int index = 0;
              index <
                  mobilePin.pins.length;
              index++
            ) ...[
              _buildPinResultCard(
                loc,

                item:
                    mobilePin.pins[index],

                index:
                    index + 1,
              ),

              if (index !=
                  mobilePin.pins.length -
                      1)
                const SizedBox(
                  height:
                      18,
                ),
            ],

            const SizedBox(
              height:
                  26,
            ),
          ],

          // ==================================================================
          // IMPORTANT PIN MESSAGE
          // ==================================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(
              22,
            ),

            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF7E8,
              ),

              borderRadius: BorderRadius.circular(
                22,
              ),

              border: Border.all(
                color: const Color(
                  0xFFFFD27A,
                ),

                width: 2,
              ),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,

                  color: Color(
                    0xFFE67E00,
                  ),

                  size: 38,
                ),

                const SizedBox(
                  width: 16,
                ),

                Expanded(
                  child: Text(
                    loc.mobilePinReceiptSavePinMessage,

                    style: const TextStyle(
                      color: Color(
                        0xFF76520A,
                      ),

                      fontSize: 23,

                      fontWeight: FontWeight.w800,

                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          // ==================================================================
          // TOTAL PAID
          // ==================================================================

          _buildTotalCard(
            label:
                loc.mobilePinReceiptTotalPaid,

            amount:
                mobilePin.customerTotal,

            colors:
                const [
              Color(
                0xFF0D47A1,
              ),
              Color(
                0xFF1769D2,
              ),
            ],
          ),
        ],
      ),
    );
  }

// ==========================================================================
// E-WALLET PIN RECEIPT
// ==========================================================================

Widget _buildEWalletPinReceiptCard(
  AppLocalizations loc,
) {
  final EWalletReceiptExtraData
      eWallet =
      _eWallet!;

  final String productCode =
      eWallet.productCode
          .trim()
          .toUpperCase();

  final String imageUrl =
      productCode.isEmpty
          ? ''
          : 'https://dashboard.iimmpact.com/img/$productCode.png';

  final List<Widget> pinRows =
      [];

  // ========================================================================
  // IIMMPACT REFERENCE
  // ========================================================================

  if (_safeValue(
        widget.data.refId ?? '',
      ) !=
      '-') {
    pinRows.add(
      _ReceiptInfoRow(
        icon:
            Icons.tag_rounded,

        label:
            loc.receiptTransactionReference,

        value:
            _safeValue(
          widget.data.refId ?? '',
        ),

        compactValue:
            true,
      ),
    );
  }

  // ========================================================================
  // SERIAL NUMBER
  // ========================================================================

  // if (_safeValue(
  //       eWallet.serialNumber,
  //     ) !=
  //     '-') {
  //   pinRows.add(
  //     _ReceiptInfoRow(
  //       icon:
  //           Icons.confirmation_number_rounded,

  //       label:
  //           loc.eWalletPinReceiptSerialNumber,

  //       value:
  //           _safeValue(
  //         eWallet.serialNumber,
  //       ),

  //       compactValue:
  //           true,
  //     ),
  //   );
  // }

  // ========================================================================
  // PIN
  // ========================================================================

  if (_safeValue(
        eWallet.pin,
      ) !=
      '-') {
    pinRows.add(
      _ReceiptInfoRow(
        icon:
            Icons.vpn_key_rounded,

        label:
            loc.eWalletPinReceiptPinCode,

        value:
            _safeValue(
          eWallet.pin,
        ),

        compactValue:
            true,

        emphasizeValue:
            true,


        valueColor:
            const Color(
          0xFFD35400,
        ),
      ),
    );
  }

  // ========================================================================
  // EXPIRY
  // ========================================================================

  if (_safeValue(
        eWallet.expiry,
      ) !=
      '-') {
    pinRows.add(
      _ReceiptInfoRow(
        icon:
            Icons.event_rounded,

        label:
            loc.eWalletPinReceiptExpiry,

        value:
            _safeValue(
          eWallet.expiry,
        ),
      ),
    );
  }

  // ========================================================================
  // NOTE
  // ========================================================================

  if (_safeValue(
        eWallet.note,
      ) !=
      '-') {
    pinRows.add(
      _ReceiptInfoRow(
        icon:
            Icons.info_outline_rounded,

        label:
            loc.eWalletPinReceiptNote,

        value:
            _safeValue(
          _getLocalizedEWalletNote(
            loc,
            eWallet.note,
          ),
        ),

        compactValue:
            true,
      ),
    );
  }

  // ========================================================================
  // VOUCHER LINK
  // ========================================================================

  if (_safeValue(
        eWallet.voucherLink,
      ) !=
      '-') {
    pinRows.add(
      _ReceiptInfoRow(
        icon:
            Icons.link_rounded,

        label:
            loc.eWalletPinReceiptVoucherLink,

        value:
            _safeValue(
          eWallet.voucherLink,
        ),

        compactValue:
            true,
      ),
    );
  }

  return _receiptOuterCard(
    borderColor:
        const Color(
      0xFFFFC7AA,
    ),

    child:
        Column(
      children: [
        // ==================================================================
        // PROVIDER
        // ==================================================================

        _buildProviderCard(
          label:
              loc.eWalletPinReceiptProvider,

          providerName:
              eWallet.providerName,

          imageUrl:
              imageUrl,

          colors:
              const [
            Color(
              0xFFD35400,
            ),
            Color(
              0xFFEF6C35,
            ),
            Color(
              0xFFFFA264,
            ),
          ],
        ),

        const SizedBox(
          height: 28,
        ),

        // ==================================================================
        // TRANSACTION DETAILS
        // ==================================================================

        _buildSectionTitle(
          icon:
              Icons.description_rounded,

          title:
              loc.eWalletPinReceiptTransactionDetails,

          accentColor:
              const Color(
            0xFFEF6C35,
          ),

          backgroundColor:
              const Color(
            0xFFFFEADD,
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        _buildDetailsContainer(
          [
            // ==============================================================
            // PRODUCT CODE
            // ==============================================================

            _ReceiptInfoRow(
              icon:
                  Icons.code_rounded,

              label:
                  loc.eWalletPinReceiptProductCode,

              value:
                  _safeValue(
                eWallet.productCode,
              ),
            ),

            // ==============================================================
            // PHONE / REFERENCE
            // ==============================================================

            _ReceiptInfoRow(
              icon:
                  Icons.phone_android_rounded,

              label:
                  loc.eWalletPinReceiptPhoneReference,

              value:
                  _safeValue(
                eWallet.phoneNumber,
              ),
            ),

            // ==============================================================
            // PIN VALUE
            // ==============================================================

            _ReceiptInfoRow(
              icon:
                  Icons.payments_rounded,

              label:
                  loc.eWalletPinReceiptValue,

              value:
                  _formatAmount(
                eWallet.reloadAmount,
              ),
            ),

            // ==============================================================
            // SERVICE ADJUSTMENT
            // ==============================================================

            // if (eWallet
            //         .serviceAdjustment
            //         .abs() >=
            //     0.005)
            //   _ReceiptInfoRow(
            //     icon:
            //         Icons.tune_rounded,

            //     label:
            //         loc.eWalletServiceAdjustment,

            //     value:
            //         _formatAmount(
            //       eWallet.serviceAdjustment,
            //     ),
            //   ),

            // ==============================================================
            // PAYMENT METHOD
            // ==============================================================

            _ReceiptInfoRow(
              icon:
                  Icons.qr_code_2_rounded,

              label:
                  loc.eWalletPinReceiptPaymentMethod,

              value:
                  _safeValue(
                widget.data.paymentMethod,
              ),
            ),

            // ==============================================================
            // PAYMENT DATE
            // ==============================================================

            _ReceiptInfoRow(
              icon:
                  Icons.schedule_rounded,

              label:
                  loc.eWalletPinReceiptPaymentDate,

              value:
                  _formatDateTime(
                widget.data.paidAt,
              ),

              compactValue:
                  true,
            ),

            // ==============================================================
            // BANK TRANSACTION
            // ==============================================================

            if (_safeValue(
                  widget.data.bankTransactionNo,
                ) !=
                '-')
              _ReceiptInfoRow(
                icon:
                    Icons.account_balance_rounded,

                label:
                    loc.eWalletPinReceiptBankTransaction,

                value:
                    _safeValue(
                  widget.data.bankTransactionNo,
                ),

                compactValue:
                    true,
              ),
          ],
        ),

        // ==================================================================
        // PIN DETAILS
        // ==================================================================

        if (pinRows.isNotEmpty) ...[
          const SizedBox(
            height: 28,
          ),

          _buildSectionTitle(
            icon:
                Icons.key_rounded,

            title:
                loc.eWalletPinReceiptPinDetails,

            accentColor:
                const Color(
              0xFFEF6C35,
            ),

            backgroundColor:
                const Color(
              0xFFFFEADD,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            width:
                double.infinity,

            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  24,
              vertical:
                  8,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFFF8F4,
              ),

              borderRadius:
                  BorderRadius.circular(
                25,
              ),

              border:
                  Border.all(
                color:
                    const Color(
                  0xFFFFC7AA,
                ),

                width:
                    2,
              ),
            ),

            child:
                Column(
              children:
                  _insertDividers(
                pinRows,
              ),
            ),
          ),
        ],

        const SizedBox(
          height: 28,
        ),

        // ==================================================================
        // IMPORTANT PIN MESSAGE
        // ==================================================================

        Container(
          width:
              double.infinity,

          padding:
              const EdgeInsets.all(
            22,
          ),

          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFFFF7E8,
            ),

            borderRadius:
                BorderRadius.circular(
              22,
            ),

            border:
                Border.all(
              color:
                  const Color(
                0xFFFFD27A,
              ),

              width:
                  2,
            ),
          ),

          child:
              Row(
            children: [
              const Icon(
                Icons
                    .info_outline_rounded,

                color:
                    Color(
                  0xFFE67E00,
                ),

                size:
                    38,
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child:
                    Text(
                  loc.eWalletPinReceiptSavePinMessage,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF76520A,
                    ),

                    fontSize:
                        23,

                    fontWeight:
                        FontWeight.w800,

                    height:
                        1.35,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 28,
        ),

        if (_hasEWalletProviderSurcharge(
              eWallet,
            )) ...[
          _buildEWalletSurchargeNotice(
            loc,
            eWallet,
          ),

          const SizedBox(
            height: 28,
          ),
        ],

        // ==================================================================
        // TOTAL PAID
        // ==================================================================

        _buildTotalCard(
          label:
              loc.eWalletPinReceiptTotalPaid,

          amount:
              eWallet.customerTotal,

          colors:
              const [
            Color(
              0xFFD35400,
            ),
            Color(
              0xFFEF6C35,
            ),
          ],
        ),

        // ==================================================================
        // IMPORTANT:
        //
        // NO _buildDigitalReceiptCard()
        //
        // E-Wallet PIN currently has no digital receipt QR.
        // ==================================================================
      ],
    ),
  );
}

  // ==========================================================================
  // E-WALLET PINLESS RECEIPT
  // ==========================================================================

  Widget _buildEWalletPinlessReceiptCard(
    AppLocalizations loc,
  ) {
    final EWalletReceiptExtraData eWallet =
        _eWallet!;

    final String productCode =
        eWallet.productCode.trim().toUpperCase();

    final String imageUrl =
        productCode.isEmpty
            ? ''
            : 'https://dashboard.iimmpact.com/img/$productCode.png';

    return _receiptOuterCard(
      borderColor: const Color(0xFFFFC7AA),
      child: Column(
        children: [
          _buildProviderCard(
            label:
                loc.eWalletReloadReceiptProvider,
            providerName:
                eWallet.providerName,
            imageUrl:
                imageUrl,
            colors: const [
              Color(0xFFD35400),
              Color(0xFFEF6C35),
              Color(0xFFFFA264),
            ],
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(
            icon:
                Icons.description_rounded,
            title:
                loc.eWalletPinReceiptTransactionDetails,
            accentColor:
                const Color(0xFFEF6C35),
            backgroundColor:
                const Color(0xFFFFEADD),
          ),

          const SizedBox(height: 18),

          _buildDetailsContainer(
            [
              _ReceiptInfoRow(
                icon:
                    Icons.code_rounded,
                label:
                    loc.eWalletPinReceiptProductCode,
                value:
                    _safeValue(
                  eWallet.productCode,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.phone_android_rounded,
                label:
                    loc.eWalletPhoneNumber,
                value:
                    _safeValue(
                  eWallet.phoneNumber,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.payments_rounded,
                label:
                    loc.eWalletReloadValue,
                value:
                    _formatAmount(
                  eWallet.reloadAmount,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.qr_code_2_rounded,
                label:
                    loc.eWalletPinReceiptPaymentMethod,
                value:
                    _safeValue(
                  widget.data.paymentMethod,
                ),
              ),

              _ReceiptInfoRow(
                icon:
                    Icons.schedule_rounded,
                label:
                    loc.eWalletPinReceiptPaymentDate,
                value:
                    _formatDateTime(
                  widget.data.paidAt,
                ),
                compactValue:
                    true,
              ),

              if (_safeValue(
                    widget.data.refId ?? '',
                  ) !=
                  '-')
                _ReceiptInfoRow(
                  icon:
                      Icons.tag_rounded,
                  label:
                      loc.receiptTransactionReference,
                  value:
                      _safeValue(
                    widget.data.refId ?? '',
                  ),
                  compactValue:
                      true,
                ),

              if (_safeValue(
                    widget.data.bankTransactionNo,
                  ) !=
                  '-')
                _ReceiptInfoRow(
                  icon:
                      Icons.account_balance_rounded,
                  label:
                      loc.eWalletPinReceiptBankTransaction,
                  value:
                      _safeValue(
                    widget.data.bankTransactionNo,
                  ),
                  compactValue:
                      true,
                ),
            ],
          ),

          const SizedBox(height: 28),

          if (_hasEWalletProviderSurcharge(
            eWallet,
          )) ...[
            _buildEWalletSurchargeNotice(
              loc,
              eWallet,
            ),
            const SizedBox(height: 28),
          ],

          _buildTotalCard(
            label:
                loc.eWalletPinReceiptTotalPaid,
            amount:
                eWallet.customerTotal,
            colors: const [
              Color(0xFFD35400),
              Color(0xFFEF6C35),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MOBILE PIN RESULT CARD
  // ==========================================================================

  Widget _buildPinResultCard(
    AppLocalizations loc, {
    required MobilePinReceiptItem item,
    required int index,
  }) {
    final List<Widget> rows =
        [];

    // ========================================================================
    // TRANSACTION REFERENCE
    // ========================================================================

    rows.add(
      _ReceiptInfoRow(
        icon:
            Icons.tag_rounded,

        label:
            loc.receiptTransactionReference,

        value:
            _safeValue(
          item.refId,
        ),

        compactValue:
            true,
      ),
    );

    // ========================================================================
    // SERIAL NUMBER
    // ========================================================================

    // if (_safeValue(
    //       item.serialNumber,
    //     ) !=
    //     '-') {
    //   rows.add(
    //     _ReceiptInfoRow(
    //       icon:
    //           Icons.confirmation_number_rounded,

    //       label:
    //           loc.mobilePinReceiptSerialNumber,

    //       value:
    //           _safeValue(
    //         item.serialNumber,
    //       ),

    //       compactValue:
    //           true,
    //     ),
    //   );
    // }

    // ========================================================================
    // PIN CODE
    // ========================================================================

    if (_safeValue(
          item.pin,
        ) !=
        '-') {
      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.vpn_key_rounded,

          label:
              loc.mobilePinReceiptPinCode,

          value:
              _safeValue(
            item.pin,
          ),

          compactValue:
              true,

          emphasizeValue: true,

          valueColor:
              const Color(
            0xFF0D5CBD,
          ),
        ),
      );
    }

    // ========================================================================
    // EXPIRY
    // ========================================================================

    if (_safeValue(
          item.expiry,
        ) !=
        '-') {
      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.event_rounded,

          label:
              loc.mobilePinReceiptExpiry,

          value:
              _safeValue(
            item.expiry,
          ),
        ),
      );
    }

    // ========================================================================
    // NOTE
    // ========================================================================

    if (_safeValue(
          item.note,
        ) !=
        '-') {
      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.info_outline_rounded,

          label:
              loc.mobilePinReceiptNote,

          value:
              _safeValue(
            item.note,
          ),

          compactValue:
              true,
        ),
      );
    }

    // ========================================================================
    // VOUCHER LINK
    // ========================================================================

    if (_safeValue(
          item.voucherLink,
        ) !=
        '-') {
      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.link_rounded,

          label:
              loc.mobilePinReceiptVoucherLink,

          value:
              _safeValue(
            item.voucherLink,
          ),

          compactValue:
              true,
        ),
      );
    }

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        22,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF5F8FC,
        ),

        borderRadius:
            BorderRadius.circular(
          25,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFC8DBF3,
          ),

          width:
              2,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ============================================================
          // PIN NUMBER LABEL
          //
          // Hidden for now because only ONE PIN is purchased per
          // transaction.
          // ============================================================

          // Container(
          //   padding:
          //       const EdgeInsets.symmetric(
          //     horizontal:
          //         18,
          //     vertical:
          //         10,
          //   ),

          //   decoration:
          //       BoxDecoration(
          //     color:
          //         const Color(
          //       0xFFE8F1FD,
          //     ),

          //     borderRadius:
          //         BorderRadius.circular(
          //       100,
          //     ),
          //   ),

          //   child:
          //       Text(
          //     loc.mobilePinReceiptPinNumber(
          //       index,
          //     ),

          //     style:
          //         const TextStyle(
          //       color:
          //           Color(
          //         0xFF0D5CBD,
          //       ),

          //       fontSize:
          //           23,

          //       fontWeight:
          //           FontWeight.w900,
          //     ),
          //   ),
          // ),

          // const SizedBox(
          //   height:
          //       12,
          // ),

          Column(
            children:
                _insertDividers(
              rows,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PROVIDER CARD
  // ==========================================================================

  Widget _buildProviderCard({
    required String label,
    required String providerName,
    required String imageUrl,
    required List<Color> colors,
  }) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        24,
      ),

      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.centerLeft,

          end:
              Alignment.centerRight,

          colors:
              colors,
        ),

        borderRadius:
            BorderRadius.circular(
          27,
        ),
      ),

      child:
          Row(
        children: [
          Container(
            width:
                125,
            height:
                90,

            padding:
                const EdgeInsets.all(
              12,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child:
                imageUrl.isEmpty
                    ? Icon(
                        Icons.sim_card_rounded,
                        color:
                            colors[1],
                        size:
                            55,
                      )
                    : Image.network(
                        imageUrl,
                        fit:
                            BoxFit.contain,
                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Icon(
                            Icons.sim_card_rounded,
                            color:
                                colors[1],
                            size:
                                55,
                          );
                        },
                      ),
          ),

          const SizedBox(
            width:
                22,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style:
                      TextStyle(
                    color:
                        Colors.white.withOpacity(
                      0.76,
                    ),

                    fontSize:
                        21,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height:
                      6,
                ),

                Text(
                  _safeValue(
                    providerName,
                  ),

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize:
                        36,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TOTAL CARD
  // ==========================================================================

  Widget _buildTotalCard({
    required String label,
    required double amount,
    required List<Color> colors,
  }) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal:
            30,
        vertical:
            25,
      ),

      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.centerLeft,

          end:
              Alignment.centerRight,

          colors:
              colors,
        ),

        borderRadius:
            BorderRadius.circular(
          26,
        ),

        boxShadow: [
          BoxShadow(
            color:
                colors.first.withOpacity(
              0.22,
            ),

            blurRadius:
                16,

            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),

      child:
          Row(
        children: [
          Container(
            width:
                66,
            height:
                66,

            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.16,
              ),

              shape:
                  BoxShape.circle,
            ),

            child:
                const Icon(
              Icons.account_balance_wallet_rounded,

              color:
                  Colors.white,

              size:
                  42,
            ),
          ),

          const SizedBox(
            width:
                18,
          ),

          Expanded(
            child:
                Text(
              label,

              style:
                  const TextStyle(
                color:
                    Colors.white,

                fontSize:
                    33,

                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(
            width:
                16,
          ),

          Flexible(
            child:
                FittedBox(
              fit:
                  BoxFit.scaleDown,

              alignment:
                  Alignment.centerRight,

              child:
                  Text(
                _formatAmount(
                  amount,
                ),

                style:
                    const TextStyle(
                  color:
                      Colors.white,

                  fontSize:
                      48,

                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RECEIPT OUTER CARD
  // ==========================================================================

  Widget _receiptOuterCard({
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.fromLTRB(
        32,
        32,
        32,
        34,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.98,
        ),

        borderRadius:
            BorderRadius.circular(
          36,
        ),

        border:
            Border.all(
          color:
              borderColor,

          width:
              2.5,
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF17375E,
            ).withOpacity(
              0.15,
            ),

            blurRadius:
                30,

            offset:
                const Offset(
              0,
              14,
            ),
          ),
        ],
      ),

      child:
          child,
    );
  }

  // ==========================================================================
  // DETAILS CONTAINER
  // ==========================================================================

  Widget _buildDetailsContainer(
    List<Widget> rows,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal:
            24,
        vertical:
            8,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF5F8FB,
        ),

        borderRadius:
            BorderRadius.circular(
          25,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD8E0E8,
          ),

          width:
              1.5,
        ),
      ),

      child:
          Column(
        children:
            _insertDividers(
          rows,
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION TITLE
  // ==========================================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    return Row(
      children: [
        Container(
          width:
              58,
          height:
              58,

          decoration:
              BoxDecoration(
            color:
                backgroundColor,

            shape:
                BoxShape.circle,
          ),

          child:
              Icon(
            icon,
            color:
                accentColor,
            size:
                39,
          ),
        ),

        const SizedBox(
          width:
              14,
        ),

        Expanded(
          child:
              Text(
            title,

            style:
                const TextStyle(
              color:
                  Color(
                0xFF20364C,
              ),

              fontSize:
                  34,

              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // DIGITAL RECEIPT CARD
  // ==========================================================================

  Widget _buildDigitalReceiptCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.fromLTRB(
        28,
        28,
        28,
        26,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF1FBF7,
        ),

        borderRadius:
            BorderRadius.circular(
          26,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFF9DDAC5,
          ),

          width:
              2.5,
        ),
      ),

      child:
          Column(
        children: [
          Row(
            children: [
              Container(
                width:
                    64,
                height:
                    64,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE1F7EF,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child:
                    const Icon(
                  Icons.receipt_long_rounded,

                  color:
                      Color(
                    0xFF118762,
                  ),

                  size:
                      39,
                ),
              ),

              const SizedBox(
                width:
                    18,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      loc.billReceiptDigitalTitle,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF0B6A4D,
                        ),

                        fontSize:
                            31,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                          5,
                    ),

                    Text(
                      loc.billReceiptDigitalSubtitle,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF407565,
                        ),

                        fontSize:
                            21,

                        fontWeight:
                            FontWeight.w700,

                        height:
                            1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                24,
          ),

          AnimatedSwitcher(
            duration:
                const Duration(
              milliseconds:
                  250,
            ),

            child:
                _buildQrContent(
              loc,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // QR CONTENT
  // ==========================================================================

  Widget _buildQrContent(
    AppLocalizations loc,
  ) {
    if (_isReceiptQrLoading) {
      return Container(
        key:
            const ValueKey<String>(
          'loading',
        ),

        width:
            double.infinity,

        constraints:
            const BoxConstraints(
          minHeight:
              270,
        ),

        padding:
            const EdgeInsets.all(
          28,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            22,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xFFC8E8DC,
            ),

            width:
                2,
          ),
        ),

        child:
            Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const SizedBox(
              width:
                  68,
              height:
                  68,

              child:
                  CircularProgressIndicator(
                strokeWidth:
                    7,

                color:
                    Color(
                  0xFF118762,
                ),

                backgroundColor:
                    Color(
                  0xFFDDF1E9,
                ),
              ),
            ),

            const SizedBox(
              height:
                  22,
            ),

            Text(
              loc.billReceiptQrLoading,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF155D49,
                ),

                fontSize:
                    25,

                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    if (!_receiptQrLoadFailed &&
        _receiptQrBytes !=
            null) {
      return Container(
        key:
            const ValueKey<String>(
          'success',
        ),

        width:
            double.infinity,

        padding:
            const EdgeInsets.all(
          24,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            22,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xFFC8E8DC,
            ),

            width:
                2,
          ),
        ),

        child:
            Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(
                14,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),

                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFD6E5DF,
                  ),

                  width:
                      2,
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(
                      0.10,
                    ),

                    blurRadius:
                        15,

                    offset:
                        const Offset(
                      0,
                      7,
                    ),
                  ),
                ],
              ),

              child:
                  Image.memory(
                _receiptQrBytes!,

                width:
                    320,

                height:
                    320,

                fit:
                    BoxFit.contain,

                gaplessPlayback:
                    true,

                filterQuality:
                    FilterQuality.high,
              ),
            ),

            const SizedBox(
              height:
                  30,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                const Icon(
                  Icons.phone_android_rounded,

                  color:
                      Color(
                    0xFF118762,
                  ),

                  size:
                      31,
                ),

                const SizedBox(
                  width:
                      10,
                ),

                Flexible(
                  child:
                      Text(
                    loc.billReceiptQrScanInstruction,

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF155D49,
                      ),

                      fontSize:
                          23,

                      fontWeight:
                          FontWeight.w800,

                      height:
                          1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      key:
          const ValueKey<String>(
        'error',
      ),

      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        26,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFFF5F5,
        ),

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFEF9A9A,
          ),

          width:
              2,
        ),
      ),

      child:
          Column(
        children: [
          const Icon(
            Icons.qr_code_2_rounded,

            color:
                Color(
              0xFFC62828,
            ),

            size:
                82,
          ),

          const SizedBox(
            height:
                16,
          ),

          Text(
            loc.billReceiptQrError,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Color(
                0xFFC62828,
              ),

              fontSize:
                  24,

              fontWeight:
                  FontWeight.w800,

              height:
                  1.35,
            ),
          ),

          const SizedBox(
            height:
                22,
          ),

          SizedBox(
            width:
                300,
            height:
                72,

            child:
                ElevatedButton.icon(
              onPressed:
                  _fetchReceiptQr,

              icon:
                  const Icon(
                Icons.refresh_rounded,

                size:
                    30,
              ),

              label:
                  Text(
                loc.billReceiptQrRetry,

                style:
                    const TextStyle(
                  fontSize:
                      24,

                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF118762,
                ),

                foregroundColor:
                    Colors.white,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTTOM SECTION
  // ==========================================================================
  //
  // HOME BUTTON IS KEPT.
  //
  // AUTO HOME COUNTDOWN IS DISABLED.
  // ==========================================================================

  Widget _buildBottomSection(
    AppLocalizations loc,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        70,
        18,
        70,
        32,
      ),

      child:
          Column(
        children: [
          // ==================================================================
          // AUTO HOME COUNTDOWN
          //
          // DISABLED FOR NOW.
          //
          // FUTURE:
          // Put countdown UI back here if needed.
          // ==================================================================

          SizedBox(
            width:
                520,

            height:
                96,

            child:
                KioskHomeButton(
              onPressed:
                  _goHome,
            ),
          ),

          const SizedBox(
            height:
                24,
          ),

          Text(
            Data.copyrightText,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Color(
                0xFF273747,
              ),

              fontSize:
                  19,

              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

 // ==========================================================================
  // SURCHARGE NOTICE
  // ==========================================================================

  Widget _buildEWalletSurchargeNotice(
  AppLocalizations loc,
  EWalletReceiptExtraData eWallet,
) {
  final double surcharge =
      _getEWalletProviderSurcharge(
    eWallet,
  );

  final double receivedAmount =
      (eWallet.reloadAmount -
              surcharge)
          .clamp(
            0,
            double.infinity,
          )
          .toDouble();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(
      22,
    ),
    decoration: BoxDecoration(
      color: const Color(
        0xFFFFF7E8,
      ),
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      border: Border.all(
        color: const Color(
          0xFFFFD27A,
        ),
        width: 2,
      ),
    ),
    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Color(
            0xFFE67E00,
          ),
          size: 38,
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                loc.eWalletProviderSurchargeTitle,
                style:
                    const TextStyle(
                  color: Color(
                    0xFF76520A,
                  ),
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                loc.eWalletProviderSurchargeMessage(
                  _formatAmount(
                    surcharge,
                  ),
                  _formatAmount(
                    eWallet.reloadAmount,
                  ),
                  _formatAmount(
                    receivedAmount,
                  ),
                ),
                style:
                    const TextStyle(
                  color: Color(
                    0xFF76520A,
                  ),
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ==========================================================================
  // DIVIDERS
  // ==========================================================================

  List<Widget> _insertDividers(
    List<Widget> rows,
  ) {
    final List<Widget> result =
        [];

    for (
      int index = 0;
      index < rows.length;
      index++
    ) {
      result.add(
        rows[index],
      );

      if (index !=
          rows.length -
              1) {
        result.add(
          const Divider(
            height:
                1,

            thickness:
                1,

            color:
                Color(
              0xFFDCE3E9,
            ),
          ),
        );
      }
    }

    return result;
  }
}

// ============================================================================
// RECEIPT INFO ROW
// ============================================================================

class _ReceiptInfoRow
    extends StatelessWidget {
  final IconData icon;

  final String label;

  final String value;

  final bool compactValue;

  final bool emphasizeValue;

  final Color? valueColor;

  const _ReceiptInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.compactValue = false,
    this.emphasizeValue = false,
    this.valueColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical:
            18,
      ),

      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          Icon(
            icon,

            color:
                const Color(
              0xFF61778C,
            ),

            size:
                35,
          ),

          const SizedBox(
            width:
                14,
          ),

          Expanded(
            flex:
                5,

            child:
                Text(
              label,

              maxLines:
                  2,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF4D5D6D,
                ),

                fontSize:
                    29,

                height:
                    1.15,

                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(
            width:
                16,
          ),

          Expanded(
            flex:
                6,

            child:
                Text(
              value,

              textAlign:
                  TextAlign.right,

              maxLines:
                  compactValue
                      ? 3
                      : 1,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  TextStyle(
                color:
                    valueColor ??
                        const Color(
                          0xFF1D3043,
                        ),

              fontSize:
                  emphasizeValue
                      ? 36
                      : compactValue
                          ? 24
                          : 30,

                height:
                    1.15,

                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}