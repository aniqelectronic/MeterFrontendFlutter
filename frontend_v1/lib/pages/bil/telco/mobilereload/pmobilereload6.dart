import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/bill/mobile_reload_qr_payment_page.dart';

// ============================================================================
// MOBILE RELOAD PAGE 6 - CONFIRMATION / SEMAKAN
//
// Receives final selection from PMOBILERELOAD5PAGE.
//
// MOBILE DATA:
// - provider
// - phone
// - selected internet plan
// - plan description
// - amount
//
// MOBILE PREPAID:
// - provider
// - phone
// - selected/custom reload amount
//
// Then user:
// - goes back to change selection
// - continues to payment
// ============================================================================

class PMOBILERELOAD6PAGE extends StatelessWidget {
  final String productCode;

  final String providerName;
  final String providerImageUrl;

  final String phoneNumber;

  // mobileData / mobilePrepaid
  final String category;

  // plan / amount
  final String fieldId;

  // Only exists for select-based products.
  final String? optionCode;
  final String? optionName;
  final String? optionDescription;

  final double baseAmount;
  final double adjustmentAmount;
  final double totalAmount;

  final String processingTime;

  const PMOBILERELOAD6PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
    required this.phoneNumber,
    required this.category,
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
      Color(0xFF7B4DCC);

  static const Color _darkColor =
      Color(0xFF56339B);

  static const Color _greenColor =
      Color(0xFF16813B);

  // ==========================================================================
  // TYPE
  // ==========================================================================

  bool get _isInternet =>
      category.trim().toLowerCase() ==
      'mobiledata';

  bool get _hasOption =>
      optionName?.trim().isNotEmpty ==
      true;

  bool get _hasDescription =>
      optionDescription
              ?.trim()
              .isNotEmpty ==
          true;

  bool get _hasAdjustment =>
      adjustmentAmount.abs() >= 0.005;

  // ==========================================================================
  // FORMAT
  // ==========================================================================

  String _formatMoney(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
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
      case 'instant':
        return loc.processingInstant;

      case '24_hours':
        return loc.processing24Hours;

      case '3_days':
        return loc.processing3Days;

      case 'pin':
        return 'PIN';

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
  // PAYMENT
  // ==========================================================================

  Future<void> _handlePayment(
    BuildContext context,
  ) async {
    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'MOBILE RELOAD CONFIRMED',
    );
    debugPrint(
      '========================================',
    );

    debugPrint(
      'Product Code : $productCode',
    );

    debugPrint(
      'Provider     : $providerName',
    );

    debugPrint(
      'Phone        : $phoneNumber',
    );

    debugPrint(
      'Category     : $category',
    );

    debugPrint(
      'Field ID     : $fieldId',
    );

    debugPrint(
      'Option Code  : $optionCode',
    );

    debugPrint(
      'Option Name  : $optionName',
    );

    debugPrint(
      'Base Amount  : $baseAmount',
    );

    debugPrint(
      'Adjustment   : $adjustmentAmount',
    );

    debugPrint(
      'Total Amount : $totalAmount',
    );

    debugPrint(
      '========================================',
    );
    debugPrint('');

  await Navigator.push(
    context,

    MaterialPageRoute(
      settings:
          const RouteSettings(
        name: '/payment',
      ),

      builder:
          (_) =>
              MobileReloadQrPaymentPage(
        providerName:
            providerName,

        productCode:
            productCode,

        category:
            category,

        phoneNumber:
            phoneNumber,

        fieldId:
            fieldId,

        optionCode:
            optionCode ?? '',

        optionName:
            optionName ?? '',

        optionDescription:
            optionDescription ?? '',

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
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'lib/images/pnew.png',
                  ),
                  fit: BoxFit.cover,
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
                  loc,
                ),

                // ============================================================
                // CONTENT
                // ============================================================

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 20,
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
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
                            // ===============================================
                            // CHECK NOTICE
                            // ===============================================

                            _buildConfirmationNotice(
                              loc,
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            // ===============================================
                            // SELECTED PRODUCT
                            // ===============================================

                            _buildSelectedProductCard(
                              loc,
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            // ===============================================
                            // ORDER SUMMARY
                            // ===============================================

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
                // BUTTONS
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
            Color(0xFF56339B),
            Color(0xFF7B4DCC),
            Color(0xFF9A78F2),
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
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),

            child: providerImageUrl
                    .trim()
                    .isEmpty
                ? const Icon(
                    Icons
                        .phone_android_rounded,
                    color:
                        _primaryColor,
                    size: 58,
                  )
                : Image.network(
                    providerImageUrl,
                    fit:
                        BoxFit.contain,

                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons
                            .phone_android_rounded,
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
                  CrossAxisAlignment.start,

              children: [
                Text(
                  loc.mobileReloadConfirmTitle
                      .toUpperCase(),

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight:
                        FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  loc.mobileReloadConfirmSubtitle,

                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 27,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.fact_check_rounded,
            color: Colors.white,
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
            Color(0xFFF0EBFF),
            Color(0xFFF9F7FF),
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
              Icons.checklist_rounded,
              color: Colors.white,
              size: 45,
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
                  loc.mobileReloadPleaseCheckTitle,

                  style:
                      const TextStyle(
                    color:
                        _darkColor,
                    fontSize: 34,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  loc.mobileReloadPleaseCheckMessage,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF574F71,
                    ),
                    fontSize: 27,
                    height: 1.35,
                    fontWeight:
                        FontWeight.w700,
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
  // SELECTED PRODUCT
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
            CrossAxisAlignment.stretch,

        children: [
          // ==================================================================
          // PROVIDER
          // ==================================================================

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
                      BorderRadius.circular(
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

                child: providerImageUrl
                        .trim()
                        .isEmpty
                    ? const Icon(
                        Icons
                            .phone_android_rounded,
                        color:
                            _primaryColor,
                        size: 60,
                      )
                    : Image.network(
                        providerImageUrl,
                        fit:
                            BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons
                                .phone_android_rounded,
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
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      loc.mobileReloadYouSelected,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF6A7280,
                        ),
                        fontSize: 25,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      providerName,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17283E,
                        ),
                        fontSize: 35,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.verified_rounded,
                color:
                    _greenColor,
                size: 50,
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          // ==================================================================
          // PHONE NUMBER
          // ==================================================================

          Container(
            width:
                double.infinity,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 21,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF8FAFD,
              ),

              borderRadius:
                  BorderRadius.circular(
                20,
              ),

              border:
                  Border.all(
                color:
                    const Color(
                  0xFFD8E0EB,
                ),
                width: 2,
              ),
            ),

            child: Row(
              children: [
                Container(
                  width: 65,
                  height: 65,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF0EBFF,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child:
                      const Icon(
                    Icons
                        .phone_android_rounded,
                    color:
                        _primaryColor,
                    size: 38,
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        loc.mobileReloadPhoneNumber,

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF68778A,
                          ),
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        phoneNumber,

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF17283E,
                          ),
                          fontSize: 31,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          // ==================================================================
          // SELECTED PLAN / RELOAD AMOUNT
          // ==================================================================

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
                  CrossAxisAlignment.start,

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
                      Icon(
                    _isInternet
                        ? Icons
                            .signal_cellular_alt_rounded
                        : Icons
                            .payments_rounded,

                    color:
                        Colors.white,
                    size: 47,
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        _isInternet
                            ? loc
                                .mobileReloadSelectedPlan
                            : loc
                                .mobileReloadReloadAmount,

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF6B6481,
                          ),
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      if (_isInternet &&
                          _hasOption)
                        Text(
                          optionName!,

                          style:
                              const TextStyle(
                            color:
                                _darkColor,
                            fontSize: 31,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        )
                      else
                        Text(
                          _formatMoney(
                            baseAmount,
                          ),

                          style:
                              const TextStyle(
                            color:
                                _darkColor,
                            fontSize: 35,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                      if (_isInternet &&
                          _hasDescription) ...[
                        const SizedBox(
                          height: 9,
                        ),

                        Text(
                          optionDescription!,

                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF68778A,
                            ),
                            fontSize: 23,
                            height: 1.35,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],

                      if (_isInternet) ...[
                        const SizedBox(
                          height: 12,
                        ),

                        // Text(
                        //   _formatMoney(
                        //     baseAmount,
                        //   ),

                        //   style:
                        //       const TextStyle(
                        //     color:
                        //         _greenColor,
                        //     fontSize: 31,
                        //     fontWeight:
                        //         FontWeight.w900,
                        //   ),
                        // ),
                      ],
                    ],
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
            CrossAxisAlignment.stretch,

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
                      BorderRadius.circular(
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
                  loc.mobileReloadOrderSummary,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF102A43,
                    ),
                    fontSize: 38,
                    fontWeight:
                        FontWeight.w900,
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
                loc.mobileReloadProvider,
            value:
                providerName,
          ),

          const Divider(
            height: 34,
          ),

          _SummaryRow(
            label:
                loc.mobileReloadPhoneNumber,
            value:
                phoneNumber,
          ),

          if (_isInternet &&
              _hasOption) ...[
            const Divider(
              height: 34,
            ),

            _SummaryRow(
              label:
                  loc.mobileReloadSelectedPlan,
              value:
                  optionName!,
            ),
          ],

          const Divider(
            height: 34,
          ),

          _SummaryRow(
            label:
                loc.mobileReloadSubtotal,
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
                      ? loc.mobileReloadServiceFee
                      : loc
                          .mobileReloadServiceAdjustment,

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
                  loc.mobileReloadTotalPayment,

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
                loc.processingTimeLabel,

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
  // BOTTOM
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
        32,
      ),

      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Row(
            children: [
              // ==============================================================
              // CHANGE
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
                      size: 42,
                    ),

                    label:
                        Text(
                      loc.mobileReloadChangeSelection,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 27,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
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
                            BorderRadius.circular(
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
                      size: 42,
                    ),

                    label:
                        Text(
                      loc.mobileReloadPayNow,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _greenColor,

                      foregroundColor:
                          Colors.white,

                      elevation: 3,

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
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          Text(
            Data.copyrightText,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
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
}

// ============================================================================
// SUMMARY ROW
// ============================================================================

class _SummaryRow extends StatelessWidget {
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
          CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Text(
            label,

            style:
                TextStyle(
              color:
                  isTotal
                      ? const Color(
                          0xFF102A43,
                        )
                      : const Color(
                          0xFF63758A,
                        ),

              fontSize:
                  isTotal
                      ? 30
                      : 27,

              fontWeight:
                  isTotal
                      ? FontWeight.w900
                      : FontWeight.w600,
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
              color:
                  valueColor ??
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
                      : 28,

              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}