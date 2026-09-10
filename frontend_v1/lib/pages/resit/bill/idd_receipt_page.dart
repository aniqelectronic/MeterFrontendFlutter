import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

// ============================================================================
// IDD RECEIPT DATA
// ============================================================================

class IddReceiptData {
  final String providerName;
  final String productCode;

  final String optionCode;
  final String optionName;

  final double baseAmount;
  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;

  final String refId;
  final String orderNo;
  final String bankTransactionNo;

  final String paymentMethod;

  final DateTime paidAt;

  // ==========================================================================
  // IIMMPACT RESULT
  // ==========================================================================

  final String providerStatus;

  final String serialNumber;
  final String pin;
  final String expiry;
  final String voucherLink;
  final String note;

  const IddReceiptData({
    required this.providerName,
    required this.productCode,
    required this.optionCode,
    required this.optionName,
    required this.baseAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.processingTime,
    required this.refId,
    required this.orderNo,
    required this.bankTransactionNo,
    required this.paymentMethod,
    required this.paidAt,
    required this.providerStatus,
    required this.serialNumber,
    required this.pin,
    required this.expiry,
    required this.voucherLink,
    required this.note,
  });
}

// ============================================================================
// IDD RECEIPT PAGE
// ============================================================================

class IddReceiptPage extends StatelessWidget {
  final IddReceiptData data;

  const IddReceiptPage({
    super.key,
    required this.data,
  });

  static const Color _primary =
      Color(0xFF1469E8);

  static const Color _dark =
      Color(0xFF064CAC);

  static const Color _green =
      Color(0xFF16813B);

  // ==========================================================================
  // VALUE CHECKS
  // ==========================================================================

  bool get _hasAdjustment =>
      data.serviceAdjustment.abs() >= 0.005;

  bool get _hasSerialNumber =>
      _safeValue(data.serialNumber) != '-';

  bool get _hasPin =>
      _safeValue(data.pin) != '-';

  bool get _hasExpiry =>
      _safeValue(data.expiry) != '-';

  bool get _hasVoucherLink =>
      _safeValue(data.voucherLink) != '-';

  bool get _hasNote =>
      _safeValue(data.note) != '-';

  // ==========================================================================
  // FORMAT
  // ==========================================================================

  String _safeValue(
    String value,
  ) {
    final String cleaned =
        value.trim();

    if (cleaned.isEmpty ||
        cleaned.toLowerCase() == 'null') {
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

  String _formatSignedAmount(
    double amount,
  ) {
    final String sign =
        amount >= 0 ? '+' : '-';

    return '$sign RM '
        '${amount.abs().toStringAsFixed(2)}';
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final DateTime local =
        dateTime.toLocal();

    String two(
      int value,
    ) {
      return value
          .toString()
          .padLeft(
            2,
            '0',
          );
    }

    return '${two(local.day)}/'
        '${two(local.month)}/'
        '${local.year} '
        '${two(local.hour)}:'
        '${two(local.minute)}:'
        '${two(local.second)}';
  }

  // ==========================================================================
  // PROCESSING TIME
  // ==========================================================================

  String _formatProcessingTime(
    AppLocalizations loc,
  ) {
    final String value =
        data.processingTime
            .trim()
            .toLowerCase();

    switch (value) {
      case 'pin':
        return loc.iddDeliveryPin;

      case 'instant':
        return loc.processingInstant;

      case '24_hours':
        return loc.processing24Hours;

      case '3_days':
        return loc.processing3Days;

      default:
        if (value.isEmpty) {
          return '-';
        }

        return data.processingTime
            .replaceAll(
              '_',
              ' ',
            )
            .toUpperCase();
    }
  }

  // ==========================================================================
  // HOME
  // ==========================================================================

  void _goHome(
    BuildContext context,
  ) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '/p1',
        ),
        builder: (_) =>
            const P1BentongPage(),
      ),
      (
        Route<dynamic> route,
      ) =>
          false,
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // =================================================================
            // BACKGROUND
            // =================================================================

            Positioned.fill(
              child: Image.asset(
                'lib/images/pnew.png',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(
                        0.16,
                      ),
                      Colors.white.withOpacity(
                        0.34,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =================================================================
            // PAGE
            // =================================================================

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(
                    loc,
                  ),

                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 18,
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 10,
                        radius:
                            const Radius.circular(
                          20,
                        ),
                        child:
                            SingleChildScrollView(
                          physics:
                              const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(
                            55,
                            34,
                            55,
                            28,
                          ),
                          child:
                              _buildReceiptCard(
                            loc,
                          ),
                        ),
                      ),
                    ),
                  ),

                  _buildBottomSection(
                    context,
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
  // HEADER
  // ==========================================================================

  Widget _buildHeader(
    AppLocalizations loc,
  ) {
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
        horizontal: 32,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF064CAC),
            Color(0xFF1469E8),
            Color(0xFF41A0F2),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _dark.withOpacity(
              0.23,
            ),
            blurRadius: 22,
            offset:
                const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .phone_in_talk_rounded,
            color: Colors.white,
            size: 50,
          ),

          const SizedBox(
            width: 22,
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  loc.iddReceiptTitle,
                  textAlign:
                      TextAlign.center,
                  maxLines: 2,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 38,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  data.providerName,
                  textAlign:
                      TextAlign.center,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        Colors.white
                            .withOpacity(
                      0.84,
                    ),
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 22,
          ),

          const Icon(
            Icons
                .check_circle_rounded,
            color:
                Colors.white,
            size: 50,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RECEIPT CARD
  // ==========================================================================

  Widget _buildReceiptCard(
    AppLocalizations loc,
  ) {
    final String imageUrl =
        data.productCode
                .trim()
                .isEmpty
            ? ''
            : 'https://dashboard.iimmpact.com/img/'
                '${data.productCode.trim().toUpperCase()}.png';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        32,
        32,
        32,
        34,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.98,
        ),
        borderRadius:
            BorderRadius.circular(
          36,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFC9DCF5,
          ),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF17375E,
            ).withOpacity(
              0.12,
            ),
            blurRadius: 28,
            offset:
                const Offset(
              0,
              12,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==================================================================
          // PROVIDER
          // ==================================================================

          _buildProviderCard(
            loc,
            imageUrl,
          ),

          const SizedBox(
            height: 28,
          ),

          // ==================================================================
          // IDD DETAILS
          // ==================================================================

          _buildSectionTitle(
            icon:
                Icons
                    .phone_in_talk_rounded,
            title:
                loc.iddReceiptPurchaseDetails,
          ),

          const SizedBox(
            height: 18,
          ),

          _buildDetailsContainer(
            [
              // ==============================================================
              // OPTION
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons
                        .confirmation_number_outlined,
                label:
                    loc.iddReceiptProduct,
                value:
                    _safeValue(
                  data.optionName,
                ),
              ),

              // ==============================================================
              // BASE AMOUNT
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons.payments_rounded,
                label:
                    loc.iddReceiptAmount,
                value:
                    _formatAmount(
                  data.baseAmount,
                ),
              ),

              // ==============================================================
              // ADJUSTMENT
              // ==============================================================

              if (_hasAdjustment)
                _ReceiptRow(
                  icon:
                      Icons.tune_rounded,
                  label:
                      loc
                          .iddServiceAdjustmentLabel,
                  value:
                      _formatSignedAmount(
                    data.serviceAdjustment,
                  ),
                ),

              // ==============================================================
              // DELIVERY TYPE
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons.schedule_rounded,
                label:
                    loc.processingTimeLabel,
                value:
                    _formatProcessingTime(
                  loc,
                ),
              ),
            ],
          ),

          // ==================================================================
          // PIN / VOUCHER DETAILS
          //
          // Only shown if IIMMPACT actually returned something.
          // ==================================================================

          if (_hasSerialNumber ||
              _hasPin ||
              _hasExpiry ||
              _hasVoucherLink) ...[
            const SizedBox(
              height: 30,
            ),

            _buildSectionTitle(
              icon:
                  Icons
                      .vpn_key_rounded,
              title:
                  loc.iddReceiptPinDetails,
            ),

            const SizedBox(
              height: 18,
            ),

            _buildPinContainer(
              loc,
            ),
          ],

          const SizedBox(
            height: 30,
          ),

          // ==================================================================
          // TRANSACTION DETAILS
          // ==================================================================

          _buildSectionTitle(
            icon:
                Icons
                    .receipt_long_rounded,
            title:
                loc.iddReceiptTransactionDetails,
          ),

          const SizedBox(
            height: 18,
          ),

          _buildDetailsContainer(
            [
              _ReceiptRow(
                icon:
                    Icons
                        .qr_code_2_rounded,
                label:
                    loc
                        .receiptPaymentMethodLabel,
                value:
                    data.paymentMethod,
              ),

              _ReceiptRow(
                icon:
                    Icons
                        .calendar_month_rounded,
                label:
                    loc.iddReceiptPaymentDate,
                value:
                    _formatDateTime(
                  data.paidAt,
                ),
                compact:
                    true,
              ),

              if (_safeValue(
                    data.bankTransactionNo,
                  ) !=
                  '-')
                _ReceiptRow(
                  icon:
                      Icons
                          .account_balance_rounded,
                  label:
                      loc
                          .iddReceiptBankTransaction,
                  value:
                      data.bankTransactionNo,
                  compact:
                      true,
                ),

              if (_safeValue(
                    data.refId,
                  ) !=
                  '-')
                _ReceiptRow(
                  icon:
                      Icons.tag_rounded,
                  label:
                      loc
                          .receiptTransactionReference,
                  value:
                      data.refId,
                  compact:
                      true,
                ),
            ],
          ),

          // ==================================================================
          // PROVIDER NOTE
          // ==================================================================

          if (_hasNote) ...[
            const SizedBox(
              height: 28,
            ),

            _buildNoteCard(
              loc,
            ),
          ],

          const SizedBox(
            height: 28,
          ),

          // ==================================================================
          // TOTAL PAID
          // ==================================================================

          _buildTotalCard(
            loc,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PROVIDER CARD
  // ==========================================================================

  Widget _buildProviderCard(
    AppLocalizations loc,
    String imageUrl,
  ) {
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
            const LinearGradient(
          colors: [
            Color(0xFF064CAC),
            Color(0xFF1469E8),
            Color(0xFF41A0F2),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          27,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 125,
            height: 90,
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
                    ? const Icon(
                        Icons
                            .phone_in_talk_rounded,
                        color:
                            _primary,
                        size: 55,
                      )
                    : Image.network(
                        imageUrl,
                        fit:
                            BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons
                                .phone_in_talk_rounded,
                            color:
                                _primary,
                            size: 55,
                          );
                        },
                      ),
          ),

          const SizedBox(
            width: 22,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  loc.iddReceiptProvider,
                  style:
                      TextStyle(
                    color:
                        Colors.white
                            .withOpacity(
                      0.78,
                    ),
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  data.providerName,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 36,
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
  // PIN CONTAINER
  // ==========================================================================

  Widget _buildPinContainer(
    AppLocalizations loc,
  ) {
    final List<Widget> rows = [];

    if (_hasSerialNumber) {
      rows.add(
        _ReceiptRow(
          icon:
              Icons
                  .numbers_rounded,
          label:
              loc.iddReceiptSerialNumber,
          value:
              data.serialNumber,
          compact:
              true,
        ),
      );
    }

    if (_hasPin) {
      rows.add(
        _ReceiptRow(
          icon:
              Icons
                  .key_rounded,
          label:
              loc.iddReceiptPin,
          value:
              data.pin,
          highlight:
              true,
        ),
      );
    }

    if (_hasExpiry) {
      rows.add(
        _ReceiptRow(
          icon:
              Icons
                  .event_rounded,
          label:
              loc.iddReceiptExpiry,
          value:
              data.expiry,
          compact:
              true,
        ),
      );
    }

    if (_hasVoucherLink) {
      rows.add(
        _ReceiptRow(
          icon:
              Icons
                  .link_rounded,
          label:
              loc.iddReceiptVoucherLink,
          value:
              data.voucherLink,
          compact:
              true,
        ),
      );
    }

    return _buildDetailsContainer(
      rows,
      pinStyle:
          true,
    );
  }

  // ==========================================================================
  // PROVIDER NOTE
  // ==========================================================================

  Widget _buildNoteCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        23,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFEAF3FF,
        ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFBDD6F7,
          ),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons
                .info_outline_rounded,
            color:
                _primary,
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
                  loc.iddReceiptProviderNote,
                  style:
                      const TextStyle(
                    color:
                        _dark,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  data.note,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF425A72,
                    ),
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w700,
                    height: 1.4,
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
  // TOTAL
  // ==========================================================================

  Widget _buildTotalCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 25,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF064CAC),
            Color(0xFF1469E8),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          26,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .account_balance_wallet_rounded,
            color:
                Colors.white,
            size: 48,
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(
            child: Text(
              loc.iddReceiptTotalPaid,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 33,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          Flexible(
            child: FittedBox(
              fit:
                  BoxFit.scaleDown,
              child: Text(
                _formatAmount(
                  data.totalAmount,
                ),
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 48,
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
  // SECTION TITLE
  // ==========================================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration:
              const BoxDecoration(
            color:
                Color(
              0xFFEAF3FF,
            ),
            shape:
                BoxShape.circle,
          ),
          child: Icon(
            icon,
            color:
                _primary,
            size: 39,
          ),
        ),

        const SizedBox(
          width: 14,
        ),

        Expanded(
          child: Text(
            title,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF20364C,
              ),
              fontSize: 34,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // DETAILS CONTAINER
  // ==========================================================================

  Widget _buildDetailsContainer(
    List<Widget> rows, {
    bool pinStyle = false,
  }) {
    final List<Widget> widgets = [];

    for (
      int i = 0;
      i < rows.length;
      i++
    ) {
      widgets.add(
        rows[i],
      );

      if (i != rows.length - 1) {
        widgets.add(
          const Divider(
            height: 1,
            color:
                Color(
              0xFFDCE3E9,
            ),
          ),
        );
      }
    }

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      decoration:
          BoxDecoration(
        color: pinStyle
            ? const Color(
                0xFFF0F7FF,
              )
            : const Color(
                0xFFF5F8FB,
              ),
        borderRadius:
            BorderRadius.circular(
          25,
        ),
        border: pinStyle
            ? Border.all(
                color:
                    const Color(
                  0xFFB8D6FA,
                ),
                width: 2,
              )
            : null,
      ),
      child: Column(
        children:
            widgets,
      ),
    );
  }

  // ==========================================================================
  // BOTTOM
  // ==========================================================================

  Widget _buildBottomSection(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        70,
        18,
        70,
        32,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 520,
            height: 96,
            child:
                KioskHomeButton(
              onPressed: () {
                _goHome(
                  context,
                );
              },
            ),
          ),

          const SizedBox(
            height: 24,
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
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RECEIPT ROW
// ============================================================================

class _ReceiptRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  final bool compact;

  // Used for the actual voucher PIN so it stands out.
  final bool highlight;

  const _ReceiptRow({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
    this.highlight = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 18,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: highlight
                ? const Color(
                    0xFF1469E8,
                  )
                : const Color(
                    0xFF61778C,
                  ),
            size: 35,
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            flex: 5,
            child: Text(
              label,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF4D5D6D,
                ),
                fontSize: 28,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              maxLines:
                  compact ? 5 : 3,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  TextStyle(
                color: highlight
                    ? const Color(
                        0xFF064CAC,
                      )
                    : const Color(
                        0xFF1D3043,
                      ),
                fontSize: highlight
                    ? 34
                    : compact
                        ? 24
                        : 29,
                height: 1.15,
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