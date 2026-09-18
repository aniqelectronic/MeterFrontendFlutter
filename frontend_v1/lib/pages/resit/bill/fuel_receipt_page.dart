import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';

import 'package:frontend_v1/widgets/kiosk_home_button.dart';

// ============================================================================
// FUEL RECEIPT DATA
// ============================================================================

class FuelReceiptData {
  final String productName;
  final String productCode;
  final String imageUrl;

  final String fieldId;
  final String fieldType;

  final String optionCode;
  final String optionName;
  final String optionDescription;

  final double baseAmount;
  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;

  // Localized catalog redemption instruction.
  final String instructionNote;

  final String refId;
  final String orderNo;
  final String bankTransactionNo;

  final String paymentMethod;

  final DateTime paidAt;

  // IIMMPACT result.
  final String providerStatus;

  final String serialNumber;
  final String pin;
  final String expiry;
  final String voucherLink;

  // Raw/final provider note returned by IIMMPACT.
  // Kept for data/debug but not directly displayed.
  final String providerNote;

  const FuelReceiptData({
    required this.productName,
    required this.productCode,
    required this.imageUrl,
    required this.fieldId,
    required this.fieldType,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.baseAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.processingTime,
    required this.instructionNote,
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
    required this.providerNote,
  });
}

// ============================================================================
// FUEL RECEIPT
// ============================================================================

class FuelReceiptPage
    extends StatelessWidget {
  final FuelReceiptData data;

  const FuelReceiptPage({
    super.key,
    required this.data,
  });

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primary =
      Color(0xFFD62828);

  static const Color _dark =
      Color(0xFF9F1D20);

  static const Color _light =
      Color(0xFFFFE5E5);

  static const Color _green =
      Color(0xFF16813B);

  // ==========================================================================
  // FLAGS
  // ==========================================================================

  bool get _isSelect =>
      data.fieldType
          .trim()
          .toLowerCase() ==
      'select';

  bool get _hasOption =>
      data.optionName
          .trim()
          .isNotEmpty;

  bool get _hasDescription {
    final String value =
        data.optionDescription
            .trim();

    return value.isNotEmpty &&
        value.toLowerCase() !=
            'null' &&
        value != '-';
  }

  bool get _hasAdjustment =>
      data.serviceAdjustment
          .abs() >=
      0.005;

  bool get _hasInstruction =>
      _safeValue(
        data.instructionNote,
      ) !=
      '-';

  // ==========================================================================
  // SAFE VALUE
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

  // ==========================================================================
  // FORMAT
  // ==========================================================================

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
        amount >= 0
            ? '+'
            : '-';

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
    ) =>
        value
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '${two(local.day)}/'
        '${two(local.month)}/'
        '${local.year} '
        '${two(local.hour)}:'
        '${two(local.minute)}:'
        '${two(local.second)}';
  }

  // ==========================================================================
  // DELIVERY
  // ==========================================================================

  String _formatDelivery(
    AppLocalizations loc,
  ) {
    final String value =
        data.processingTime
            .trim()
            .toLowerCase();

    switch (value) {
      case 'pin':
        return loc
            .fuelDeliveryPin;

      case 'link':
        return loc
            .fuelDeliveryLink;

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

        return value
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
        settings:
            const RouteSettings(
          name: '/p1',
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
  // REDEEM MODAL
  // ==========================================================================

  Future<void> _showRedeemInstructions(
    BuildContext context,
  ) async {
    final loc =
        AppLocalizations.of(context)!;

    await showDialog<void>(
      context:
          context,

      barrierDismissible:
          false,

      builder:
          (
        BuildContext dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,

          insetPadding:
              const EdgeInsets.symmetric(
            horizontal:
                60,
            vertical:
                80,
          ),

          child:
              Container(
            width:
                780,

            constraints:
                const BoxConstraints(
              maxHeight:
                  980,
            ),

            padding:
                const EdgeInsets.fromLTRB(
              35,
              34,
              35,
              32,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(
                32,
              ),

              border:
                  Border.all(
                color:
                    _primary,
                width:
                    3,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.25,
                  ),

                  blurRadius:
                      30,

                  offset:
                      const Offset(
                    0,
                    15,
                  ),
                ),
              ],
            ),

            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                // ============================================================
                // ICON
                // ============================================================

                Container(
                  width:
                      100,

                  height:
                      100,

                  decoration:
                      const BoxDecoration(
                    color:
                        _light,

                    shape:
                        BoxShape.circle,
                  ),

                  child:
                      const Icon(
                    Icons.menu_book_rounded,

                    color:
                        _primary,

                    size:
                        58,
                  ),
                ),

                const SizedBox(
                  height:
                      22,
                ),

                // ============================================================
                // TITLE
                // ============================================================

                Text(
                  loc
                      .fuelHowToRedeem,

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),

                    fontSize:
                        38,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height:
                      22,
                ),

                // ============================================================
                // CONTENT
                // ============================================================

                Flexible(
                  child:
                      SingleChildScrollView(
                    child:
                        Container(
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
                          0xFFFFF9E8,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          22,
                        ),

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFF3C766,
                          ),

                          width:
                              2,
                        ),
                      ),

                      child:
                          Text(
                        data.instructionNote,

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF665128,
                          ),

                          fontSize:
                              27,

                          height:
                              1.5,

                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                      26,
                ),

                // ============================================================
                // CLOSE
                // ============================================================

                SizedBox(
                  width:
                      double.infinity,

                  height:
                      78,

                  child:
                      ElevatedButton.icon(
                    onPressed:
                        () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },

                    icon:
                        const Icon(
                      Icons.close_rounded,

                      size:
                          30,
                    ),

                    label:
                        Text(
                      loc.close,

                      style:
                          const TextStyle(
                        fontSize:
                            25,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _primary,

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      canPop:
          false,

      child:
          Scaffold(
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

            // ================================================================
            // PAGE
            // ================================================================

            SafeArea(
              child:
                  Column(
                children: [
                  _buildHeader(
                    loc,
                  ),

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
                            context,
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
        horizontal:
            32,
        vertical:
            24,
      ),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFFC83261,
            ),
            Color(
              0xFFE65175,
            ),
            Color(
              0xFFF17C9C,
            ),
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
          const Icon(
            Icons.card_giftcard_rounded,

            color:
                Colors.white,

            size:
                50,
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
                  loc
                      .fuelReceiptTitle,

                  textAlign:
                      TextAlign.center,

                  maxLines:
                      2,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize:
                        38,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height:
                      5,
                ),

                Text(
                  data.productName,

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
                      0.84,
                    ),

                    fontSize:
                        23,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width:
                22,
          ),

          const Icon(
            Icons.check_circle_rounded,

            color:
                Colors.white,

            size:
                50,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RECEIPT CARD
  // ==========================================================================

  Widget _buildReceiptCard(
    BuildContext context,
    AppLocalizations loc,
  ) {
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
              const Color(
            0xFFF1CBD6,
          ),

          width:
              2.5,
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF17375E,
            ).withOpacity(
              0.12,
            ),

            blurRadius:
                28,

            offset:
                const Offset(
              0,
              12,
            ),
          ),
        ],
      ),

      child:
          Column(
        children: [
          // ==================================================================
          // PRODUCT
          // ==================================================================

          _buildProviderCard(
            loc,
          ),

          const SizedBox(
            height:
                28,
          ),

          // ==================================================================
          // TRANSACTION
          // ==================================================================

          _buildSectionTitle(
            icon:
                Icons.receipt_long_rounded,

            title:
                loc
                    .fuelReceiptTransactionDetails,
          ),

          const SizedBox(
            height:
                18,
          ),

          _buildDetailsContainer(
            [
              // ==============================================================
              // SELECTED OPTION
              // ==============================================================

              if (_isSelect &&
                  _hasOption)
                _ReceiptRow(
                  icon:
                      Icons.sell_rounded,

                  label:
                      loc
                          .fuelSelectedPackage,

                  value:
                      data.optionName,

                  compact:
                      true,
                ),

              // ==============================================================
              // OPTION DESCRIPTION
              // ==============================================================

              if (_hasDescription)
                _ReceiptRow(
                  icon:
                      Icons.description_outlined,

                  label:
                      loc
                          .fuelOptionDetails,

                  value:
                      data.optionDescription,

                  compact:
                      true,
                ),

              // ==============================================================
              // VOUCHER VALUE
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons.payments_rounded,

                label:
                    loc
                        .fuelVoucherValue,

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
                          .fuelServiceAdjustment,

                  value:
                      _formatSignedAmount(
                    data.serviceAdjustment,
                  ),
                ),

              // ==============================================================
              // DELIVERY
              // ==============================================================

              // _ReceiptRow(
              //   icon:
              //       Icons.local_shipping_outlined,

              //   label:
              //       loc.fuelDelivery,

              //   value:
              //       _formatDelivery(
              //     loc,
              //   ),
              // ),

              // ==============================================================
              // PAYMENT METHOD
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons.qr_code_2_rounded,

                label:
                    loc
                        .receiptPaymentMethodLabel,

                value:
                    data.paymentMethod,
              ),

              // ==============================================================
              // DATE
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons.schedule_rounded,

                label:
                    loc
                        .fuelReceiptPaymentDate,

                value:
                    _formatDateTime(
                  data.paidAt,
                ),

                compact:
                    true,
              ),

              // ==============================================================
              // BANK TRANSACTION
              // ==============================================================

              if (_safeValue(
                    data.bankTransactionNo,
                  ) !=
                  '-')
                _ReceiptRow(
                  icon:
                      Icons.account_balance_rounded,

                  label:
                      loc
                          .fuelReceiptBankTransaction,

                  value:
                      data.bankTransactionNo,

                  compact:
                      true,
                ),

              // ==============================================================
              // TRANSACTION REFERENCE
              // ==============================================================

              // if (_safeValue(
              //       data.refId,
              //     ) !=
              //     '-')
              //   _ReceiptRow(
              //     icon:
              //         Icons.tag_rounded,

              //     label:
              //         loc
              //             .receiptTransactionReference,

              //     value:
              //         data.refId,

              //     compact:
              //         true,
              //   ),
            ],
          ),

          // ==================================================================
          // VOUCHER DETAILS
          //
          // Only show if IIMMPACT actually returned something useful.
          // ==================================================================

          if (_hasVoucherFulfilment) ...[
            const SizedBox(
              height:
                  30,
            ),

            _buildSectionTitle(
              icon:
                  Icons.vpn_key_rounded,

              title:
                  loc
                      .fuelReceiptVoucherDetails,
            ),

            const SizedBox(
              height:
                  18,
            ),

            _buildDetailsContainer(
              [
                if (_safeValue(
                      data.serialNumber,
                    ) !=
                    '-')
                  _ReceiptRow(
                    icon:
                        Icons.confirmation_number_rounded,

                    label:
                        loc
                            .fuelReceiptSerialNumber,

                    value:
                        data.serialNumber,

                    compact:
                        true,
                  ),

                if (_safeValue(
                      data.pin,
                    ) !=
                    '-')
                  _ReceiptRow(
                    icon:
                        Icons.vpn_key_rounded,

                    label:
                        loc
                            .fuelReceiptPin,

                    value:
                        data.pin,

                    compact:
                        true,

                    emphasize:
                        true,
                  ),

                if (_safeValue(
                      data.expiry,
                    ) !=
                    '-')
                  _ReceiptRow(
                    icon:
                        Icons.event_rounded,

                    label:
                        loc
                            .fuelReceiptExpiry,

                    value:
                        data.expiry,
                  ),

                if (_safeValue(
                      data.voucherLink,
                    ) !=
                    '-')
                  _ReceiptRow(
                    icon:
                        Icons.link_rounded,

                    label:
                        loc
                            .fuelReceiptVoucherLink,

                    value:
                        data.voucherLink,

                    compact:
                        true,
                  ),
              ],
            ),
          ],

          // ==================================================================
          // HOW TO REDEEM
          // ==================================================================

          if (_hasInstruction) ...[
            const SizedBox(
              height:
                  28,
            ),

            SizedBox(
              width:
                  double.infinity,

              height:
                  88,

              child:
                  ElevatedButton.icon(
                onPressed:
                    () {
                  _showRedeemInstructions(
                    context,
                  );
                },

                icon:
                    const Icon(
                  Icons.menu_book_rounded,

                  size:
                      34,
                ),

                label:
                    Text(
                  loc.fuelHowToRedeem,

                  style:
                      const TextStyle(
                    fontSize:
                        28,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFFFFF4E1,
                  ),

                  foregroundColor:
                      const Color(
                    0xFF9A5800,
                  ),

                  elevation:
                      0,

                  side:
                      const BorderSide(
                    color:
                        Color(
                      0xFFF0C56A,
                    ),

                    width:
                        2,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(
            height:
                28,
          ),

          // ==================================================================
          // TOTAL
          // ==================================================================

          _buildTotalCard(
            loc,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CHECK FULFILMENT
  // ==========================================================================

  bool get _hasVoucherFulfilment =>
      _safeValue(
            data.serialNumber,
          ) !=
          '-' ||
      _safeValue(
            data.pin,
          ) !=
          '-' ||
      _safeValue(
            data.expiry,
          ) !=
          '-' ||
      _safeValue(
            data.voucherLink,
          ) !=
          '-';

  // ==========================================================================
  // PROVIDER
  // ==========================================================================

  Widget _buildProviderCard(
    AppLocalizations loc,
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
            Color(
              0xFFC83261,
            ),
            Color(
              0xFFE65175,
            ),
            Color(
              0xFFF17C9C,
            ),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          27,
        ),
      ),

      child:
          Row(
        children: [
          // ==================================================================
          // LOGO
          // ==================================================================

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
                data.imageUrl
                        .trim()
                        .isEmpty
                    ? const Icon(
                        Icons.card_giftcard_rounded,

                        color:
                            _primary,

                        size:
                            55,
                      )
                    : Image.network(
                        data.imageUrl,

                        fit:
                            BoxFit.contain,

                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.card_giftcard_rounded,

                            color:
                                _primary,

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

          // ==================================================================
          // NAME
          // ==================================================================

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  loc
                      .fuelReceiptProvider,

                  style:
                      TextStyle(
                    color:
                        Colors.white.withOpacity(
                      0.78,
                    ),

                    fontSize:
                        22,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height:
                      6,
                ),

                Text(
                  data.productName,

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
        horizontal:
            30,
        vertical:
            25,
      ),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFFC83261,
            ),
            Color(
              0xFFE65175,
            ),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          26,
        ),
      ),

      child:
          Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,

            color:
                Colors.white,

            size:
                48,
          ),

          const SizedBox(
            width:
                18,
          ),

          Expanded(
            child:
                Text(
              loc
                  .fuelReceiptTotalPaid,

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

          Flexible(
            child:
                FittedBox(
              fit:
                  BoxFit.scaleDown,

              child:
                  Text(
                _formatAmount(
                  data.totalAmount,
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
  // SECTION TITLE
  // ==========================================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width:
              58,

          height:
              58,

          decoration:
              const BoxDecoration(
            color:
                _light,

            shape:
                BoxShape.circle,
          ),

          child:
              Icon(
            icon,

            color:
                _primary,

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
  // DETAILS
  // ==========================================================================

  Widget _buildDetailsContainer(
    List<Widget> rows,
  ) {
    final List<Widget> widgets =
        <Widget>[];

    for (
      int i = 0;
      i < rows.length;
      i++
    ) {
      widgets.add(
        rows[i],
      );

      if (i !=
          rows.length - 1) {
        widgets.add(
          const Divider(
            height:
                1,

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
      ),

      child:
          Column(
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

      child:
          Column(
        children: [
          SizedBox(
            width:
                520,

            height:
                96,

            child:
                KioskHomeButton(
              onPressed:
                  () {
                _goHome(
                  context,
                );
              },
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
}

// ============================================================================
// RECEIPT ROW
// ============================================================================

class _ReceiptRow extends StatelessWidget {
  // Fuel highlight color
  static const Color _dark =
      Color(0xFF9F1D20);

  final IconData icon;
  final String label;
  final String value;

  final bool compact;
  final bool emphasize;

  const _ReceiptRow({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
    this.emphasize = false,
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
          // ================================================================
          // ICON
          // ================================================================

          Icon(
            icon,

            color:
                const Color(
              0xFF61778C,
            ),

            size: 35,
          ),

          const SizedBox(
            width: 14,
          ),

          // ================================================================
          // LABEL
          // ================================================================

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

                fontSize: 29,

                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          // ================================================================
          // VALUE
          // ================================================================

          Expanded(
            flex: 6,

            child: Text(
              value,

              textAlign:
                  TextAlign.right,

              maxLines:
                  compact
                      ? 4
                      : 2,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  TextStyle(
                // Highlight PIN with voucher pink
                color:
                    emphasize
                        ? _dark
                        : const Color(
                            0xFF1D3043,
                          ),

                // Same behavior as Game Platform
                fontSize:
                    emphasize
                        ? 36
                        : compact
                            ? 25
                            : 30,

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