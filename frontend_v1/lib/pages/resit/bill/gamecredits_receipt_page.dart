import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

// ============================================================================
// GAME CREDITS RECEIPT DATA
// ============================================================================

class GameCreditsReceiptData {
  // ==========================================================================
  // GAME / PRODUCT
  // ==========================================================================

  final String gameName;
  final String productCode;

  // ==========================================================================
  // SELECTED CREDIT / PACKAGE
  // ==========================================================================

  final String optionCode;
  final String optionName;
  final String optionDescription;

  // ==========================================================================
  // ACCOUNT
  //
  // Some Game Credits products require:
  //
  // player_id
  // user_id
  // account
  //
  // Some products do not require any account.
  // ==========================================================================

  final String account;
  final String accountLabel;

  // ==========================================================================
  // PAYMENT
  // ==========================================================================

  final double baseAmount;
  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;

  // ==========================================================================
  // TRANSACTION
  // ==========================================================================

  final String refId;
  final String orderNo;
  final String bankTransactionNo;
  final String paymentMethod;
  final DateTime paidAt;

  // ==========================================================================
  // IIMMPACT FULFILLMENT
  //
  // Not every Game Credit returns these.
  // Only display them when they exist.
  // ==========================================================================

  final String serialNumber;
  final String pin;
  final String expiry;
  final String voucherLink;

  const GameCreditsReceiptData({
    required this.gameName,
    required this.productCode,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.account,
    required this.accountLabel,
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
    required this.voucherLink,
  });
}

// ============================================================================
// GAME CREDITS RECEIPT PAGE
// ============================================================================

class GameCreditsReceiptPage extends StatelessWidget {
  final GameCreditsReceiptData data;

  const GameCreditsReceiptPage({
    super.key,
    required this.data,
  });

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primary =
      Color(0xFF009688);

  static const Color _dark =
      Color(0xFF087A70);

  static const Color _light =
      Color(0xFFE0F5F2);

  static const Color _green =
      Color(0xFF16813B);

  // ==========================================================================
  // SAFE VALUE
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

  // ==========================================================================
  // MONEY
  // ==========================================================================

  String _formatAmount(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
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

  // ==========================================================================
  // DATE / TIME
  // ==========================================================================

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
  // FLAGS
  // ==========================================================================

  bool get _hasAdjustment =>
      data.serviceAdjustment.abs() >= 0.005;

  bool get _hasAccount =>
      _safeValue(
        data.account,
      ) !=
      '-';

  bool get _hasSerialNumber =>
      _safeValue(
        data.serialNumber,
      ) !=
      '-';

  bool get _hasPin =>
      _safeValue(
        data.pin,
      ) !=
      '-';

  bool get _hasExpiry =>
      _safeValue(
        data.expiry,
      ) !=
      '-';

  bool get _hasVoucherLink =>
      _safeValue(
        data.voucherLink,
      ) !=
      '-';

  bool get _hasFulfillmentData =>
      _hasSerialNumber ||
      _hasPin ||
      _hasExpiry ||
      _hasVoucherLink;

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
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // ==================================================================
            // BACKGROUND
            // ==================================================================

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
                        0.32,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================================
            // PAGE
            // ==================================================================

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
            Color(0xFF087A70),
            Color(0xFF009688),
            Color(0xFF35B7A8),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.12,
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
          const Icon(
            Icons
                .videogame_asset_rounded,
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
                  loc.gameCreditsReceiptTitle,
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
                  data.gameName,
                  textAlign:
                      TextAlign.center,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        Colors.white.withOpacity(
                      0.86,
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
            0xFFBCE4DE,
          ),
          width: 2.5,
        ),
      ),
      child: Column(
        children: [
          // ==================================================================
          // GAME
          // ==================================================================

          _buildGameCard(
            loc,
            imageUrl,
          ),

          const SizedBox(
            height: 28,
          ),

          // ==================================================================
          // PURCHASE DETAILS
          // ==================================================================

          _buildSectionTitle(
            icon:
                Icons
                    .receipt_long_rounded,
            title:
                loc
                    .gameCreditsReceiptPurchaseDetails,
          ),

          const SizedBox(
            height: 18,
          ),

          _buildDetailsContainer(
            [
              // ==============================================================
              // SELECTED CREDIT
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons
                        .confirmation_number_rounded,
                label:
                    loc
                        .gameCreditsReceiptSelectedCredit,
                value:
                    _safeValue(
                  data.optionName,
                ),
                compact:
                    true,
              ),

              // ==============================================================
              // CREDIT DESCRIPTION
              //
              // Example:
              // 130 Diamonds
              // 520 FC Points
              //
              // Only display if it is useful and different from optionName.
              // ==============================================================

              if (_shouldShowDescription)
                _ReceiptRow(
                  icon:
                      Icons
                          .stars_rounded,
                  label:
                      loc
                          .gameCreditsReceiptCreditReceived,
                  value:
                      _safeValue(
                    data.optionDescription,
                  ),
                  compact:
                      true,
                ),

              // ==============================================================
              // ACCOUNT / PLAYER ID
              // ==============================================================

              if (_hasAccount)
                _ReceiptRow(
                  icon:
                      Icons
                          .person_outline_rounded,
                  label:
                      data.accountLabel
                              .trim()
                              .isNotEmpty
                          ? data.accountLabel
                          : loc
                              .gameCreditsReceiptAccount,
                  value:
                      _safeValue(
                    data.account,
                  ),
                  compact:
                      true,
                  emphasize:
                      true,
                ),

              // ==============================================================
              // BASE PRICE
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons.payments_rounded,
                label:
                    loc
                        .gameCreditsReceiptBaseAmount,
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
                          .gameCreditsReceiptServiceAdjustment,
                  value:
                      _formatSignedAmount(
                    data.serviceAdjustment,
                  ),
                ),

              // ==============================================================
              // PAYMENT METHOD
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons.qr_code_2_rounded,
                label:
                    loc
                        .gameCreditsReceiptPaymentMethod,
                value:
                    data.paymentMethod,
              ),

              // ==============================================================
              // PAYMENT DATE
              // ==============================================================

              _ReceiptRow(
                icon:
                    Icons.schedule_rounded,
                label:
                    loc
                        .gameCreditsReceiptPaymentDate,
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
                      Icons
                          .account_balance_rounded,
                  label:
                      loc
                          .gameCreditsReceiptBankTransaction,
                  value:
                      _safeValue(
                    data.bankTransactionNo,
                  ),
                  compact:
                      true,
                ),
            ],
          ),

          // ==================================================================
          // FULFILLMENT DATA
          //
          // Only display if IIMMPACT returned something.
          // ==================================================================

          if (_hasFulfillmentData) ...[
            const SizedBox(
              height: 28,
            ),

            _buildSectionTitle(
              icon:
                  Icons
                      .redeem_rounded,
              title:
                  loc
                      .gameCreditsReceiptDeliveryDetails,
            ),

            const SizedBox(
              height: 18,
            ),

            _buildFulfillmentContainer(
              loc,
            ),
          ],

          const SizedBox(
            height: 28,
          ),

          // ==================================================================
          // MESSAGE
          // ==================================================================

          _buildInformationMessage(
            loc,
          ),

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
  // DESCRIPTION CHECK
  // ==========================================================================

  bool get _shouldShowDescription {
    final String description =
        _safeValue(
      data.optionDescription,
    );

    if (description == '-') {
      return false;
    }

    final String optionName =
        _safeValue(
      data.optionName,
    );

    return description
            .toLowerCase() !=
        optionName.toLowerCase();
  }

  // ==========================================================================
  // GAME CARD
  // ==========================================================================

  Widget _buildGameCard(
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
            Color(0xFF087A70),
            Color(0xFF009688),
            Color(0xFF35B7A8),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          27,
        ),
      ),
      child: Row(
        children: [
          // ==================================================================
          // LOGO
          // ==================================================================

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
                            .videogame_asset_rounded,
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
                                .videogame_asset_rounded,
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

          // ==================================================================
          // GAME NAME
          // ==================================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  loc.gameCreditsReceiptGame,
                  style:
                      TextStyle(
                    color:
                        Colors.white.withOpacity(
                      0.80,
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
                  data.gameName,
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
  // FULFILLMENT DETAILS
  // ==========================================================================

  Widget _buildFulfillmentContainer(
    AppLocalizations loc,
  ) {
    final List<Widget> rows =
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
              0xFFD5E4E1,
            ),
          ),
        );
      }

      rows.add(
        row,
      );
    }

    // =========================================================================
    // SERIAL NUMBER
    // =========================================================================

    if (_hasSerialNumber) {
      add(
        _ReceiptRow(
          icon:
              Icons
                  .confirmation_number_rounded,
          label:
              loc
                  .gameCreditsReceiptSerialNumber,
          value:
              data.serialNumber,
          compact:
              true,
        ),
      );
    }

    // =========================================================================
    // PIN
    // =========================================================================

    if (_hasPin) {
      add(
        _ReceiptRow(
          icon:
              Icons
                  .vpn_key_rounded,
          label:
              loc
                  .gameCreditsReceiptPin,
          value:
              data.pin,
          compact:
              true,
          emphasize:
              true,
        ),
      );
    }

    // =========================================================================
    // EXPIRY
    // =========================================================================

    if (_hasExpiry) {
      add(
        _ReceiptRow(
          icon:
              Icons
                  .event_rounded,
          label:
              loc
                  .gameCreditsReceiptExpiry,
          value:
              data.expiry,
        ),
      );
    }

    // =========================================================================
    // VOUCHER LINK
    // =========================================================================

    if (_hasVoucherLink) {
      add(
        _ReceiptRow(
          icon:
              Icons
                  .link_rounded,
          label:
              loc
                  .gameCreditsReceiptVoucherLink,
          value:
              data.voucherLink,
          compact:
              true,
          emphasize:
              !_hasPin,
        ),
      );
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
          0xFFF1FAF8,
        ),
        borderRadius:
            BorderRadius.circular(
          25,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFBCE4DE,
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
  // INFORMATION MESSAGE
  // ==========================================================================

  Widget _buildInformationMessage(
    AppLocalizations loc,
  ) {
    // If PIN / link is returned, tell user to keep it.
    //
    // Otherwise this is normally direct game-credit delivery
    // to the supplied account/player ID.

    final bool needsCodeProtection =
        _hasPin ||
        _hasSerialNumber ||
        _hasVoucherLink;

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
            needsCodeProtection
                ? const Color(
                    0xFFFFF7E8,
                  )
                : const Color(
                    0xFFEAF8F3,
                  ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              needsCodeProtection
                  ? const Color(
                      0xFFFFD27A,
                    )
                  : const Color(
                      0xFF9CD7C2,
                    ),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            needsCodeProtection
                ? Icons
                    .security_rounded
                : Icons
                    .check_circle_outline_rounded,
            color:
                needsCodeProtection
                    ? const Color(
                        0xFFE67E00,
                      )
                    : _green,
            size: 38,
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Text(
              needsCodeProtection
                  ? loc
                      .gameCreditsReceiptKeepCodeSafe
                  : loc
                      .gameCreditsReceiptDeliveryMessage,
              style:
                  TextStyle(
                color:
                    needsCodeProtection
                        ? const Color(
                            0xFF76520A,
                          )
                        : const Color(
                            0xFF236044,
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
            Color(0xFF087A70),
            Color(0xFF009688),
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
                  .gameCreditsReceiptTotalPaid,
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
                _light,
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
  // BOTTOM SECTION
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

          // ==================================================================
          // LABEL
          // ==================================================================

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

          // ==================================================================
          // VALUE
          // ==================================================================

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
                color:
                    emphasize
                        ? const Color(
                            0xFF087A70,
                          )
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