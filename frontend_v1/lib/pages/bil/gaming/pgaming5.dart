import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/bill/gaming_qr_payment_page.dart';

// ============================================================================
// GAMING CONFIRMATION PAGE
//
// This page receives the customer's selection from PGAMING4PAGE.
// It does NOT call /v2/catalog or /v2/options again.
//
// FLOW:
// PGAMING4PAGE
//      -> choose ONE amount/package
// PGAMING5PAGE
//      -> review selected product
//      -> review selected amount/package
//      -> review service adjustment
//      -> review total amount
//      -> continue to payment
// ============================================================================
class PGAMING5PAGE extends StatelessWidget {
  final String productCode;
  final String platformName;
  final String imageUrl;

  final String fieldId;
  final String optionCode;
  final String optionName;
  final String optionDescription;

  final double baseAmount;
  final double adjustmentAmount;
  final double totalAmount;

  final String processingTime;

  const PGAMING5PAGE({
    super.key,
    required this.productCode,
    required this.platformName,
    required this.imageUrl,
    required this.fieldId,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.baseAmount,
    required this.adjustmentAmount,
    required this.totalAmount,
    required this.processingTime,
  });

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF7048E8);

  static const Color _darkColor =
      Color(0xFF5630C7);

  static const Color _greenColor =
      Color(0xFF16813B);

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  bool get _hasAdjustment =>
      adjustmentAmount.abs() >= 0.005;

  String _formatMoney(
    double amount,
  ) {
    return 'RM '
        '${amount.toStringAsFixed(2)}';
  }

  String _formatSignedMoney(
    double amount,
  ) {
    final String sign =
        amount >= 0 ? '+' : '-';

    return '$sign RM '
        '${amount.abs().toStringAsFixed(2)}';
  }

  String _formatProcessingTime(
    AppLocalizations loc,
  ) {
    final String value =
        processingTime
            .trim()
            .toLowerCase();

    switch (value) {
      case 'pin':
        return loc.gamingDeliveryPin;

      case 'link':
        return loc.gamingDeliveryLink;

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
  // CONTINUE TO PAYMENT
  // ==========================================================================
  Future<void> _handlePayment(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings:
            const RouteSettings(
          name: '/payment',
        ),
        builder:
            (_) =>
                GamingQrPaymentPage(
          platformName:
              platformName,

          productCode:
              productCode,

          optionCode:
              optionCode,

          optionName:
              optionName,

          optionDescription:
              optionDescription,

          baseAmount:
              baseAmount,

          serviceAdjustment:
              adjustmentAmount,

          totalAmount:
              totalAmount,

          processingTime:
              processingTime,
        ),
      ),
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

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================
          const Positioned.fill(
            child: DecoratedBox(
              decoration:
                  BoxDecoration(
                image:
                    DecorationImage(
                  image: AssetImage(
                    'lib/images/pnew.png',
                  ),
                  fit:
                      BoxFit.cover,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ============================================================
                // HEADER
                // ============================================================
                _buildHeader(
                  context,
                  loc,
                ),

                // ============================================================
                // BODY
                // ============================================================
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 20,
                    ),
                    child: Scrollbar(
                      thumbVisibility:
                          true,
                      trackVisibility:
                          true,
                      thickness: 12,
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
                          70,
                          34,
                          70,
                          30,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .stretch,
                          children: [
                            // =================================================
                            // CONFIRMATION NOTICE
                            // =================================================
                            _buildConfirmationNotice(
                              loc,
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            // =================================================
                            // SELECTED PRODUCT
                            // =================================================
                            _buildSelectedProductCard(
                              loc,
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            // =================================================
                            // SUMMARY
                            // =================================================
                            _buildOrderSummary(
                              loc,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ============================================================
                // ACTIONS
                // ============================================================
                _buildBottomArea(
                  context,
                  loc,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations loc,
  ) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        70,
        30,
        70,
        0,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 25,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFF5630C7,
            ),
            Color(
              0xFF7048E8,
            ),
            Color(
              0xFF9A78F2,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.15,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 95,
            height: 95,
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
                22,
              ),
            ),
            child: imageUrl
                    .trim()
                    .isEmpty
                ? const Icon(
                    Icons
                        .sports_esports_rounded,
                    color:
                        _primaryColor,
                    size: 58,
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
                      return const Icon(
                        Icons
                            .sports_esports_rounded,
                        color:
                            _primaryColor,
                        size: 58,
                      );
                    },
                  ),
          ),

          const SizedBox(
            width: 25,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  loc.gamingConfirmTitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 40,
                    fontWeight:
                        FontWeight
                            .w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  loc.gamingConfirmSubtitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 30,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .fact_check_rounded,
            color:
                Colors.white,
            size: 60,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CONFIRMATION NOTICE
  // ==========================================================================

  Widget _buildConfirmationNotice(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 25,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFFF0EBFF,
            ),
            Color(
              0xFFF9F7FF,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFB9A8F5,
          ),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration:
                BoxDecoration(
              color:
                  _primaryColor,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child:
                const Icon(
              Icons
                  .checklist_rounded,
              color:
                  Colors.white,
              size: 45,
            ),
          ),

          const SizedBox(
            width: 22,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  loc.gamingPleaseCheckTitle,
                  style:
                      const TextStyle(
                    color:
                        _darkColor,
                    fontSize: 35,
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  loc.gamingPleaseCheckMessage,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF574F71,
                    ),
                    fontSize: 30,
                    height: 1.35,
                    fontWeight:
                        FontWeight
                            .w700,
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
  // SELECTED PRODUCT CARD
  // ==========================================================================

  Widget _buildSelectedProductCard(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.98,
        ),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD9D2F6,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          Row(
            children: [
              Container(
                width: 115,
                height: 105,
                padding:
                    const EdgeInsets.all(
                  15,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                    22,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFE6E0FA,
                    ),
                    width: 2,
                  ),
                ),
                child: imageUrl
                        .trim()
                        .isEmpty
                    ? const Icon(
                        Icons
                            .sports_esports_rounded,
                        color:
                            _primaryColor,
                        size: 60,
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
                          return const Icon(
                            Icons
                                .sports_esports_rounded,
                            color:
                                _primaryColor,
                            size: 60,
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
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      loc.gamingYouSelected,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF6A7280,
                        ),
                        fontSize: 30,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      platformName,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17283E,
                        ),
                        fontSize: 35,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .verified_rounded,
                color:
                    _greenColor,
                size: 50,
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              24,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF6F3FF,
              ),
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFCFC4F7,
                ),
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration:
                      const BoxDecoration(
                    color:
                        _primaryColor,
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Icon(
                    Icons
                        .confirmation_number_rounded,
                    color:
                        Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        loc.gamingSelectedOption,
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF6B6481,
                          ),
                          fontSize: 35,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        optionName,
                        style:
                            const TextStyle(
                          color:
                              _darkColor,
                          fontSize: 35,
                          height: 1.25,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),

                      if (optionDescription
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          optionDescription,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF68778A,
                            ),
                            fontSize: 30,
                            height: 1.3,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                Text(
                  _formatMoney(
                    baseAmount,
                  ),
                  style:
                      const TextStyle(
                    color:
                        _greenColor,
                    fontSize: 40,
                    fontWeight:
                        FontWeight
                            .w900,
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
  // ORDER SUMMARY
  // ==========================================================================

  Widget _buildOrderSummary(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        32,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD3DCE8,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.06,
            ),
            blurRadius: 16,
            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE8F5E9,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .receipt_long_rounded,
                  color:
                      _greenColor,
                  size: 50,
                ),
              ),

              const SizedBox(
                width: 17,
              ),

              Expanded(
                child: Text(
                  loc.gamingOrderSummary,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF102A43,
                    ),
                    fontSize: 40,
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          _SummaryRow(
            label:
                loc.gamingProduct,
            value:
                platformName,
          ),

          const Divider(
            height: 34,
          ),

          _SummaryRow(
            label:
                loc.gamingSelectedOption,
            value:
                optionName,
          ),

          const Divider(
            height: 34,
          ),

          _SummaryRow(
            label:
                loc.gamingSubtotal,
            value:
                _formatMoney(
              baseAmount,
            ),
          ),

          if (_hasAdjustment) ...[
            const Divider(
              height: 34,
            ),

            _SummaryRow(
              label:
                  adjustmentAmount > 0
                      ? loc
                          .gamingServiceFee
                      : loc
                          .gamingServiceAdjustment,
              value:
                  _formatSignedMoney(
                adjustmentAmount,
              ),
              valueColor:
                  adjustmentAmount > 0
                      ? const Color(
                          0xFFE65100,
                        )
                      : const Color(
                          0xFF138A72,
                        ),
            ),
          ],

          const Divider(
            height: 38,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 20,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF8EE,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFF8BCF9D,
                ),
                width: 2,
              ),
            ),
            child:
                _SummaryRow(
              label:
                  loc.gamingTotalAmount,
              value:
                  _formatMoney(
                totalAmount,
              ),
              isTotal: true,
            ),
          ),

          const Divider(
            height: 38,
          ),

          _SummaryRow(
            label:
                loc.gamingDeliveryMethod,
            value:
                _formatProcessingTime(
              loc,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTTOM AREA
  // ==========================================================================

  Widget _buildBottomArea(
    BuildContext context,
    AppLocalizations loc,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        70,
        18,
        70,
        28,
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Row(
            children: [
              // ==============================================================
              // BACK / CHANGE SELECTION
              // ==============================================================
              Expanded(
                child: SizedBox(
                  height: 100,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .arrow_back_rounded,
                      size: 50,
                    ),
                    label: Text(
                      loc.gamingChangeSelection,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 38,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.white,
                      foregroundColor:
                          _darkColor,
                      elevation: 1,
                      side:
                          const BorderSide(
                        color:
                            Color(
                          0xFFB9A8F5,
                        ),
                        width: 2,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 24,
              ),

              // ==============================================================
              // PAY
              // ==============================================================
              Expanded(
                child: SizedBox(
                  height: 100,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      _handlePayment(
                        context,
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .payments_rounded,
                      size: 50,
                    ),
                    label: Text(
                      loc.gamingPayNow,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          _greenColor,
                      foregroundColor:
                          Colors.white,
                      elevation: 3,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            Data.copyrightText,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight
                      .w800,
              color:
                  Color(
                0xFF17375E,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  Future<void> _showMessage(
    BuildContext context,
    String message,
  ) async {
    final loc =
        AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierDismissible:
          false,
      builder:
          (
        BuildContext dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          child: Container(
            width: 680,
            padding:
                const EdgeInsets.all(
              38,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFD9D2F6,
                ),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .info_outline_rounded,
                  color:
                      _primaryColor,
                  size: 75,
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  message,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize: 27,
                    height: 1.4,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 76,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          _primaryColor,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                    ),
                    child: Text(
                      loc.electricOk,
                      style:
                          const TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight
                                .w900,
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
}

// ============================================================================
// SUMMARY ROW
// ============================================================================
class _SummaryRow
    extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        Expanded(
          child: Text(
            label,
            style:
                TextStyle(
              color: isTotal
                  ? const Color(
                      0xFF102A43,
                    )
                  : const Color(
                      0xFF63758A,
                    ),
              fontSize:
                  isTotal
                      ? 30
                      : 30,
              fontWeight:
                  isTotal
                      ? FontWeight
                          .w900
                      : FontWeight
                          .w600,
            ),
          ),
        ),

        const SizedBox(
          width: 20,
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style:
                TextStyle(
              color: valueColor ??
                  (
                    isTotal
                        ? const Color(
                            0xFF16813B,
                          )
                        : const Color(
                            0xFF102A43,
                          )
                  ),
              fontSize:
                  isTotal
                      ? 35
                      : 30,
              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),
        ),
      ],
    );
  }
}
