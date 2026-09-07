import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

// ============================================================================
// GAMING RECEIPT DATA
// ============================================================================

class GamingReceiptData {
  final String platformName;
  final String productCode;

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

  final String serialNumber;
  final String pin;
  final String expiry;
  final String note;
  final String voucherLink;

  const GamingReceiptData({
    required this.platformName,
    required this.productCode,
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
    required this.serialNumber,
    required this.pin,
    required this.expiry,
    required this.note,
    required this.voucherLink,
  });
}

// ============================================================================
// GAMING RECEIPT PAGE
// ============================================================================

class GamingReceiptPage extends StatelessWidget {
  final GamingReceiptData data;

  const GamingReceiptPage({
    super.key,
    required this.data,
  });

  static const Color _primary =
      Color(0xFF7048E8);

  static const Color _dark =
      Color(0xFF5630C7);

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
    final sign =
        amount >= 0
            ? '+'
            : '-';

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

  bool get _hasAdjustment =>
      data.serviceAdjustment
          .abs() >=
      0.005;

  bool get _hasRedemptionData {
    return _safeValue(
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
            '-' ||
        _safeValue(
              data.note,
            ) !=
            '-';
  }

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

  List<String> _redemptionSteps(
      AppLocalizations loc,
    ) {
      switch (
          data.productCode
              .trim()
              .toUpperCase()) {
        case 'CC':
          return [
            loc.gamingRedeemCcStep1,
            loc.gamingRedeemCcStep2,
            loc.gamingRedeemCcStep3,
            loc.gamingRedeemCcStep4,
          ];

        case 'GSMY':
          return [
            loc.gamingRedeemGarenaStep1,
            loc.gamingRedeemGarenaStep2,
            loc.gamingRedeemGarenaStep3,
            loc.gamingRedeemGarenaStep4,
          ];

        case 'MOL':
          return [
            loc.gamingRedeemRazerStep1,
            loc.gamingRedeemRazerStep2,
            loc.gamingRedeemRazerStep3,
            loc.gamingRedeemRazerStep4,
          ];

        case 'OF':
          return [
            loc.gamingRedeemOffgamersStep1,
            loc.gamingRedeemOffgamersStep2,
            loc.gamingRedeemOffgamersStep3,
            loc.gamingRedeemOffgamersStep4,
          ];

        case 'STEAMMY':
          return [
            loc.gamingRedeemSteamStep1,
            loc.gamingRedeemSteamStep2,
            loc.gamingRedeemSteamStep3,
            loc.gamingRedeemSteamStep4,
          ];

        case 'UNI':
          return [
            loc.gamingRedeemUnipinStep1,
            loc.gamingRedeemUnipinStep2,
            loc.gamingRedeemUnipinStep3,
            loc.gamingRedeemUnipinStep4,
          ];

        default:
          return [
            loc.gamingRedeemGenericStep1,
            loc.gamingRedeemGenericStep2,
            loc.gamingRedeemGenericStep3,
          ];
      }
    }

    Future<void> _showRedemptionGuide(
  BuildContext context,
) async {
  final loc =
      AppLocalizations.of(context)!;

  final List<String> steps =
      _redemptionSteps(
    loc,
  );

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (
      BuildContext dialogContext,
    ) {
      return Dialog(
        backgroundColor:
            Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(
          horizontal: 35,
          vertical: 45,
        ),
        child: Container(
          width: 720,
          padding:
              const EdgeInsets.fromLTRB(
            38,
            34,
            38,
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
                  const Color(
                0xFFD9D2F6,
              ),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.redeem_rounded,
                color:
                    Color(
                  0xFF7048E8,
                ),
                size: 80,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                loc.gamingHowToRedeem,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF5630C7,
                  ),
                  fontSize: 38,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                data.platformName,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF27384A,
                  ),
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 26,
              ),

              ...List.generate(
                steps.length,
                (
                  int index,
                ) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 18,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment:
                              Alignment.center,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(
                              0xFFF0EBFF,
                            ),
                            shape:
                                BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF5630C7,
                              ),
                              fontSize: 25,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 18,
                        ),

                        Expanded(
                          child: Text(
                            steps[index],
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF344A5E,
                              ),
                              fontSize: 25,
                              height: 1.35,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 82,
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  icon:
                      const Icon(
                    Icons.close_rounded,
                    size: 34,
                  ),
                  label:
                      Text(
                    loc.gamingClose,
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
                        const Color(
                      0xFF7048E8,
                    ),
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
                        0.32,
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
        horizontal: 32,
        vertical: 24,
      ),
      decoration:
          BoxDecoration(
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
        borderRadius:
            BorderRadius.circular(
          28,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sports_esports_rounded,
            color:
                Colors.white,
            size: 50,
          ),

          const SizedBox(
            width: 22,
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  loc.gamingReceiptTitle,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 40,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  data.platformName,
                  textAlign:
                      TextAlign.center,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
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
    BuildContext context,
    AppLocalizations loc,
  ) {
    final imageUrl =
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
      ),
      child: Column(
        children: [
          _buildPlatformCard(
            loc,
            imageUrl,
          ),

          const SizedBox(
            height: 28,
          ),

          _buildSectionTitle(
            icon:
                Icons
                    .receipt_long_rounded,
            title:
                loc
                    .gamingReceiptPurchaseDetails,
          ),

          const SizedBox(
            height: 18,
          ),

          _buildDetailsContainer(
            [
              _ReceiptRow(
                icon:
                    Icons
                        .confirmation_number_rounded,
                label:
                    loc
                        .gamingReceiptSelectedPackage,
                value:
                    _safeValue(
                  data.optionName,
                ),
                compact:
                    true,
              ),

              // if (data
              //     .optionDescription
              //     .trim()
              //     .isNotEmpty)
              //   _ReceiptRow(
              //     icon:
              //         Icons
              //             .description_outlined,
              //     label:
              //         loc
              //             .gamingReceiptDescription,
              //     value:
              //         _safeValue(
              //       data
              //           .optionDescription,
              //     ),
              //     compact:
              //         true,
              //   ),

              _ReceiptRow(
                icon:
                    Icons.payments_rounded,
                label:
                    loc
                        .gamingReceiptBaseAmount,
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
                          .gamingReceiptServiceAdjustment,
                  value:
                      _formatSignedAmount(
                    data
                        .serviceAdjustment,
                  ),
                ),

              _ReceiptRow(
                icon:
                    Icons.qr_code_2_rounded,
                label:
                    loc
                        .gamingReceiptPaymentMethod,
                value:
                    data.paymentMethod,
              ),

              _ReceiptRow(
                icon:
                    Icons.schedule_rounded,
                label:
                    loc
                        .gamingReceiptPaymentDate,
                value:
                    _formatDateTime(
                  data.paidAt,
                ),
                compact:
                    true,
              ),

              if (_safeValue(
                    data
                        .bankTransactionNo,
                  ) !=
                  '-')
                _ReceiptRow(
                  icon:
                      Icons
                          .account_balance_rounded,
                  label:
                      loc
                          .gamingReceiptBankTransaction,
                  value:
                      _safeValue(
                    data
                        .bankTransactionNo,
                  ),
                  compact:
                      true,
                ),
            ],
          ),

          if (_hasRedemptionData) ...[
            const SizedBox(
              height: 28,
            ),

            _buildSectionTitle(
              icon:
                  Icons.redeem_rounded,
              title:
                  loc
                      .gamingReceiptRedemptionDetails,
            ),

            const SizedBox(
              height: 18,
            ),

            _buildRedemptionContainer(
              context,
              loc,
            ),
          ],

          const SizedBox(
            height: 28,
          ),

          _buildImportantMessage(
            loc,
          ),

          const SizedBox(
            height: 28,
          ),

          _buildTotalCard(
            loc,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PLATFORM
  // ==========================================================================

  Widget _buildPlatformCard(
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
            child: imageUrl.isEmpty
                ? const Icon(
                    Icons
                        .sports_esports_rounded,
                    color:
                        _primary,
                    size: 55,
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
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  loc
                      .gamingReceiptPlatform,
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
                  data.platformName,
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
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
  // REDEMPTION DETAILS
  // ==========================================================================

  Widget _buildRedemptionContainer(
    BuildContext context,
    AppLocalizations loc,
  ) {
    final rows =
        <Widget>[];

    void add(
      Widget row,
    ) {
      if (rows.isNotEmpty) {
        rows.add(
          const Divider(
            height: 1,
            color:
                Color(
              0xFFDCE3E9,
            ),
          ),
        );
      }

      rows.add(
        row,
      );
    }

    if (_safeValue(
          data.serialNumber,
        ) !=
        '-') {
      add(
        _ReceiptRow(
          icon:
              Icons
                  .confirmation_number_rounded,
          label:
              loc
                  .gamingReceiptSerialNumber,
          value:
              data.serialNumber,
          compact:
              true,
        ),
      );
    }

    if (_safeValue(
          data.pin,
        ) !=
        '-') {
      add(
        _ReceiptRow(
          icon:
              Icons.vpn_key_rounded,
          label:
              loc
                  .gamingReceiptPinCode,
          value:
              data.pin,
          compact:
              true,
          emphasize:
              true,
        ),
      );
    }

    if (_safeValue(
          data.expiry,
        ) !=
        '-') {
      add(
        _ReceiptRow(
          icon:
              Icons.event_rounded,
          label:
              loc
                  .gamingReceiptExpiry,
          value:
              data.expiry,
        ),
      );
    }

    if (_safeValue(
          data.voucherLink,
        ) !=
        '-') {
      add(
        _ReceiptRow(
          icon:
              Icons.link_rounded,
          label:
              loc
                  .gamingReceiptVoucherLink,
          value:
              data.voucherLink,
          compact:
              true,
          emphasize:
              data.pin
                  .trim()
                  .isEmpty,
        ),
      );
    }

    // if (_safeValue(
    //       data.note,
    //     ) !=
    //     '-') {
    //   add(
    //     _ReceiptRow(
    //       icon:
    //           Icons
    //               .info_outline_rounded,
    //       label:
    //           loc
    //               .gamingReceiptProviderNote,
    //       value:
    //           data.note,
    //       compact:
    //           true,
    //     ),
    //   );
    // }

    add(
      Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Material(
          color:
              Colors.transparent,
          child: InkWell(
            onTap: () {
              _showRedemptionGuide(
                context,
              );
            },
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            child: Ink(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 20,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF5F1FF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFC8B9F7,
                  ),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // ==========================================
                  // ICON BOX
                  // ==========================================

                  Container(
                    width: 70,
                    height: 70,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF7048E8,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons.redeem_rounded,
                      color:
                          Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(
                    width: 20,
                  ),

                  // ==========================================
                  // TITLE + DESCRIPTION
                  // ==========================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.gamingHowToRedeem,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF5630C7,
                            ),
                            fontSize: 29,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          loc
                              .gamingRedeemButtonHint,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF68758A,
                            ),
                            fontSize: 21,
                            height: 1.25,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  // ==========================================
                  // ARROW
                  // ==========================================

                  const Icon(
                    Icons
                        .arrow_forward_ios_rounded,
                    color:
                        Color(
                      0xFF7048E8,
                    ),
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

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
          0xFFFAF8FF,
        ),
        borderRadius:
            BorderRadius.circular(
          25,
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
        children:
            rows,
      ),
    );
  }

  // ==========================================================================
  // IMPORTANT MESSAGE
  // ==========================================================================

  Widget _buildImportantMessage(
    AppLocalizations loc,
  ) {
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
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.security_rounded,
            color:
                Color(
              0xFFE67E00,
            ),
            size: 38,
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Text(
              loc
                  .gamingReceiptKeepCodeSafe,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF76520A,
                ),
                fontSize: 24,
                height: 1.35,
                fontWeight:
                    FontWeight.w800,
              ),
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
            Color(
              0xFF5630C7,
            ),
            Color(
              0xFF7048E8,
            ),
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
              loc
                  .gamingReceiptTotalPaid,
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
  // HELPERS
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
          rows.length -
              1) {
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
  static const Color _dark = Color(0xFF5630C7);

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
                fontSize: 29,
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
                  compact
                      ? 4
                      : 2,
              overflow:
                  TextOverflow
                      .ellipsis,
              style:
                  TextStyle(
                color:
                    emphasize
                        ? _dark
                        : const Color(
                            0xFF1D3043,
                          ),
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
