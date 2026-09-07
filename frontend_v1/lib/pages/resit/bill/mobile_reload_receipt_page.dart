import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

// ============================================================================
// MOBILE RELOAD RECEIPT DATA
// ============================================================================

class MobileReloadReceiptData {
  final String providerName;
  final String productCode;

  // mobileData / mobilePrepaid
  final String category;

  final String phoneNumber;

  // Mobile Data only.
  final String optionCode;
  final String optionName;
  final String optionDescription;

  final double baseAmount;
  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;

  final String refId;
  final String orderNo;
  final String bankTransactionNo;

  final String paymentMethod;

  final DateTime paidAt;

  // Provider result.
  final String providerStatus;

  final String serialNumber;
  final String pin;
  final String expiry;
  final String voucherLink;
  final String note;

  const MobileReloadReceiptData({
    required this.providerName,
    required this.productCode,
    required this.category,
    required this.phoneNumber,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
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
// MOBILE RELOAD RECEIPT PAGE
// ============================================================================

class MobileReloadReceiptPage extends StatelessWidget {
  final MobileReloadReceiptData data;

  const MobileReloadReceiptPage({
    super.key,
    required this.data,
  });

  static const Color _primary =
      Color(0xFF7B4DCC);

  static const Color _dark =
      Color(0xFF56339B);

  static const Color _green =
      Color(0xFF16813B);

  // ==========================================================================
  // TYPE
  // ==========================================================================

  bool get _isInternet =>
      data.category.trim().toLowerCase() ==
      'mobiledata';

  bool get _hasAdjustment =>
      data.serviceAdjustment.abs() >= 0.005;

  bool get _hasPlan =>
      data.optionName.trim().isNotEmpty;

  bool get _hasDescription =>
      data.optionDescription.trim().isNotEmpty;

  // ==========================================================================
  // FORMAT
  // ==========================================================================

  String _safeValue(
    String value,
  ) {
    final cleaned =
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
    final local =
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
            Positioned.fill(
              child: Image.asset(
                'lib/images/pnew.png',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.white
                          .withOpacity(
                        0.16,
                      ),
                      Colors.white
                          .withOpacity(
                        0.34,
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
                        thumbVisibility:
                            true,
                        trackVisibility:
                            true,
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

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF56339B),
            Color(0xFF7B4DCC),
            Color(0xFF9A78F2),
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
          Icon(
            _isInternet
                ? Icons
                    .signal_cellular_alt_rounded
                : Icons
                    .phone_android_rounded,
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
                  _isInternet
                      ? loc
                          .mobileReloadInternetReceiptTitle
                      : loc
                          .mobileReloadPrepaidReceiptTitle,

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
                        Colors.white.withOpacity(
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
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 50,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RECEIPT
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
            0xFFD9D2F6,
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
          // DETAILS
          // ==================================================================

          _buildSectionTitle(
            icon:
                Icons.receipt_long_rounded,

            title:
                loc
                    .mobileReloadReceiptTransactionDetails,
          ),

          const SizedBox(
            height: 18,
          ),

          _buildDetailsContainer(
            [
              _ReceiptRow(
                icon:
                    Icons.phone_android_rounded,

                label:
                    loc.mobileReloadPhoneNumber,

                value:
                    _safeValue(
                  data.phoneNumber,
                ),
              ),

              if (_isInternet &&
                  _hasPlan)
                _ReceiptRow(
                  icon:
                      Icons
                          .signal_cellular_alt_rounded,

                  label:
                      loc
                          .mobileReloadSelectedPlan,

                  value:
                      data.optionName,

                  compact:
                      true,
                ),

              if (_isInternet &&
                  _hasDescription)
                _ReceiptRow(
                  icon:
                      Icons.description_outlined,

                  label:
                      loc
                          .mobileReloadReceiptPlanDetails,

                  value:
                      data.optionDescription,

                  compact:
                      true,
                ),

              if (!_isInternet)
                _ReceiptRow(
                  icon:
                      Icons.payments_rounded,

                  label:
                      loc
                          .mobileReloadReloadAmount,

                  value:
                      _formatAmount(
                    data.baseAmount,
                  ),
                ),

              if (_hasAdjustment)
                _ReceiptRow(
                  icon:
                      Icons.tune_rounded,

                  label:
                      loc
                          .mobileReloadServiceAdjustment,

                  value:
                      _formatSignedAmount(
                    data.serviceAdjustment,
                  ),
                ),

              _ReceiptRow(
                icon:
                    Icons.qr_code_2_rounded,

                label:
                    loc
                        .receiptPaymentMethodLabel,

                value:
                    data.paymentMethod,
              ),

              _ReceiptRow(
                icon:
                    Icons.schedule_rounded,

                label:
                    loc
                        .mobileReloadReceiptPaymentDate,

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
                      Icons.account_balance_rounded,

                  label:
                      loc
                          .mobileReloadReceiptBankTransaction,

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

                if (_safeValue(
                  data.serialNumber,
                ) !=
                '-')
              _ReceiptRow(
                icon:
                    Icons.confirmation_number_rounded,

                label:
                    loc.mobileReloadReceiptSerialNumber,

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
                    loc.mobileReloadReceiptPin,

                value:
                    data.pin,

                compact:
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
                    loc.mobileReloadReceiptExpiry,

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
                    loc.mobileReloadReceiptVoucherLink,

                value:
                    data.voucherLink,

                compact:
                    true,
              ),
            ],
          ),

          // ==================================================================
          // PROVIDER MESSAGE
          // ==================================================================

          if (_safeValue(
                data.note,
              ) !=
              '-') ...[
            const SizedBox(
              height: 28,
            ),

            // Container(
            //   width:
            //       double.infinity,

            //   padding:
            //       const EdgeInsets.all(
            //     22,
            //   ),

            //   decoration:
            //       BoxDecoration(
            //     color:
            //         const Color(
            //       0xFFF6F3FF,
            //     ),

            //     borderRadius:
            //         BorderRadius.circular(
            //       22,
            //     ),

            //     border:
            //         Border.all(
            //       color:
            //           const Color(
            //         0xFFD9D2F6,
            //       ),
            //       width: 2,
            //     ),
            //   ),

            //   child: Row(
            //     crossAxisAlignment:
            //         CrossAxisAlignment.start,
            //     children: [
            //       const Icon(
            //         Icons
            //             .info_outline_rounded,

            //         color:
            //             _primary,

            //         size: 38,
            //       ),

            //       const SizedBox(
            //         width: 16,
            //       ),

            //       Expanded(
            //         child: Text(
            //           data.note,

            //           style:
            //               const TextStyle(
            //             color:
            //                 Color(
            //               0xFF574F71,
            //             ),
            //             fontSize: 23,
            //             fontWeight:
            //                 FontWeight.w800,
            //             height: 1.35,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],

          const SizedBox(
            height: 28,
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
            Color(0xFF56339B),
            Color(0xFF7B4DCC),
            Color(0xFF9A78F2),
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
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child: imageUrl.isEmpty
                ? const Icon(
                    Icons
                        .phone_android_rounded,

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
                            .phone_android_rounded,

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
                  loc.mobileReloadProvider,

                  style:
                      TextStyle(
                    color:
                        Colors.white.withOpacity(
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
            Color(0xFF56339B),
            Color(0xFF7B4DCC),
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
              loc.mobileReloadReceiptTotalPaid,

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
              0xFFF0EBFF,
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
  // DETAILS
  // ==========================================================================

  Widget _buildDetailsContainer(
    List<Widget> rows,
  ) {
    final widgets =
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
        color:
            const Color(
          0xFFF5F8FB,
        ),

        borderRadius:
            BorderRadius.circular(
          25,
        ),
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
              onPressed:
                  () =>
                      _goHome(
                context,
              ),
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

class _ReceiptRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  final bool compact;

  const _ReceiptRow({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
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

            color:
                const Color(
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
                  compact ? 4 : 2,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  TextStyle(
                color:
                    const Color(
                  0xFF1D3043,
                ),

                fontSize:
                    compact
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