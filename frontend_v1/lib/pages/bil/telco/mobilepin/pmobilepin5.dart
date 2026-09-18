import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/payment/bill/bil_qr_payment_page.dart';
import 'package:frontend_v1/pages/resit/bill/bill_receipt_page.dart';

// ============================================================================
// MOBILE PIN PAGE 5 - RECIPIENT MOBILE NUMBER
// ============================================================================
//
// FLOW:
//
// PMOBILEPIN4PAGE
// Choose PIN denomination
//        ↓
// PMOBILEPIN5PAGE
// Enter recipient mobile number
//        ↓
// BilQrPaymentPage
//        ↓
// PegePay success
//        ↓
// IIMMPACT POST /v2/topup
//
// product = productCode
// account = recipient mobile number
// amount  = PIN denomination
//
// ============================================================================

class PMOBILEPIN5PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;

  /// PIN face value sent to IIMMPACT.
  final double pinAmount;

  /// Final amount paid by customer.
  final double totalAmount;

  const PMOBILEPIN5PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
    required this.pinAmount,
    required this.totalAmount,
  });

  @override
  State<PMOBILEPIN5PAGE> createState() =>
      _PMOBILEPIN5PAGEState();
}

class _PMOBILEPIN5PAGEState
    extends State<PMOBILEPIN5PAGE> {
  // ==========================================================================
  // CONTROLLER
  // ==========================================================================

  final TextEditingController _controller =
      TextEditingController();

  String? _activeKey;

  bool _isNavigating = false;

  // ==========================================================================
  // THEME
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF1769D2);

  static const Color _darkColor =
      Color(0xFF0D47A1);

  static const Color _lightColor =
      Color(0xFF42A5F5);

  // ==========================================================================
  // INPUT
  // ==========================================================================

  /// Malaysian mobile numbers are normally comfortably below this.
  ///
  /// We keep 11 digits because the API requires a recipient identifier
  /// and we do not want unnecessarily loose input.
  int get _maximumLength => 11;

  String get _mobileNumber =>
      _controller.text.trim();

  void _addNumber(
    String number,
  ) {
    if (_isNavigating) {
      return;
    }

    if (_controller.text.length >=
        _maximumLength) {
      return;
    }

    setState(() {
      _controller.text += number;
    });
  }

  void _backspace() {
    if (_isNavigating ||
        _controller.text.isEmpty) {
      return;
    }

    setState(() {
      _controller.text =
          _controller.text.substring(
        0,
        _controller.text.length - 1,
      );
    });
  }

  void _clearAll() {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _controller.clear();
    });
  }

  // ==========================================================================
  // MOBILE NUMBER VALIDATION
  // ==========================================================================

  bool _isValidMobileNumber(
    String number,
  ) {
    // Digits only.
    if (!RegExp(r'^[0-9]+$')
        .hasMatch(number)) {
      return false;
    }

    // Malaysia local-format mobile numbers generally start with 01.
    if (!number.startsWith('01')) {
      return false;
    }

    // Keep validation broad enough for valid Malaysian ranges.
    if (number.length < 9 ||
        number.length > 11) {
      return false;
    }

    return true;
  }

  // ==========================================================================
  // FORMAT MONEY
  // ==========================================================================

  String _formatMoney(
    double value,
  ) {
    return 'RM ${value.toStringAsFixed(2)}';
  }

  // ==========================================================================
  // ALERT
  // ==========================================================================

  void _showAlert(
    String title,
    String message, {
    IconData icon =
        Icons.info_outline_rounded,
    Color color =
        const Color(0xFF1769D2),
  }) {
    showGeneralDialog<void>(
      context:
          context,

      barrierDismissible:
          false,

      barrierLabel:
          title,

      barrierColor:
          Colors.black.withValues(
        alpha:
            0.65,
      ),

      transitionDuration:
          const Duration(
        milliseconds:
            220,
      ),

      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return SafeArea(
          child:
              Center(
            child:
                Material(
              color:
                  Colors.transparent,
              child:
                  Container(
                width:
                    820,
                padding:
                    const EdgeInsets.fromLTRB(
                  50,
                  45,
                  50,
                  40,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    38,
                  ),
                  border:
                      Border.all(
                    color:
                        color.withValues(
                      alpha:
                          0.30,
                    ),
                    width:
                        3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(
                        alpha:
                            0.30,
                      ),
                      blurRadius:
                          35,
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
                    Container(
                      width:
                          130,
                      height:
                          130,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color:
                            color.withValues(
                          alpha:
                              0.12,
                        ),
                      ),
                      child:
                          Icon(
                        icon,
                        size:
                            78,
                        color:
                            color,
                      ),
                    ),

                    const SizedBox(
                      height:
                          28,
                    ),

                    Text(
                      title,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17283E,
                        ),
                        fontSize:
                            45,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                          22,
                    ),

                    Text(
                      message,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF536272,
                        ),
                        fontSize:
                            30,
                        fontWeight:
                            FontWeight.w600,
                        height:
                            1.35,
                      ),
                    ),

                    const SizedBox(
                      height:
                          35,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height:
                          85,
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
                          Icons
                              .check_circle_outline_rounded,
                          size:
                              34,
                        ),
                        label:
                            Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .telcoOkButton,
                          style:
                              const TextStyle(
                            fontSize:
                                30,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              color,
                          foregroundColor:
                              Colors.white,
                          elevation:
                              0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              22,
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
      },

      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return FadeTransition(
          opacity:
              animation,
          child:
              ScaleTransition(
            scale:
                Tween<double>(
              begin:
                  0.88,
              end:
                  1,
            ).animate(
              CurvedAnimation(
                parent:
                    animation,
                curve:
                    Curves.easeOutBack,
              ),
            ),
            child:
                child,
          ),
        );
      },
    );
  }

  // ==========================================================================
  // CONTINUE TO PAYMENT
  // ==========================================================================

  Future<void> _handleContinue() async {
    if (_isNavigating) {
      return;
    }

    final loc =
        AppLocalizations.of(context)!;

    final String number =
        _mobileNumber;

    // ========================================================================
    // EMPTY
    // ========================================================================

    if (number.isEmpty) {
      _showAlert(
        loc.mobilePinNumberAlertTitle,
        loc.mobilePinNumberRequired,
        icon:
            Icons.phone_android_rounded,
      );

      return;
    }

    // ========================================================================
    // INVALID
    // ========================================================================

    if (!_isValidMobileNumber(
      number,
    )) {
      _showAlert(
        loc.mobilePinNumberAlertTitle,
        loc.mobilePinNumberInvalid,
        icon:
            Icons.warning_amber_rounded,
        color:
            const Color(
          0xFFE08A00,
        ),
      );

      return;
    }

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'MOBILE PIN - READY FOR PAYMENT',
    );
    debugPrint(
      '========================================',
    );

    debugPrint(
      'Provider          : '
      '${widget.providerName}',
    );

    debugPrint(
      'Product Code      : '
      '${widget.productCode}',
    );

    debugPrint(
      'Recipient Mobile  : '
      '$number',
    );

    debugPrint(
      'PIN Amount        : '
      '${widget.pinAmount}',
    );

    debugPrint(
      'Customer Total    : '
      '${widget.totalAmount}',
    );

    debugPrint(
      '========================================',
    );
    debugPrint('');

    setState(() {
      _isNavigating =
          true;
    });

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  BilQrPaymentPage(
            // ================================================================
            // MOBILE PIN RECEIPT MODE
            // ================================================================

            useMobilePinReceipt:
                true,

            // ================================================================
            // PRODUCT
            // ================================================================

            billType:
                widget.providerName,

            billCode:
                widget.productCode,

            // ================================================================
            // IIMMPACT ACCOUNT
            //
            // For Mobile PIN we use recipient mobile number as the
            // transaction recipient identifier.
            // ================================================================

            accountNumber:
                number,

            // ================================================================
            // IIMMPACT AMOUNT
            //
            // Actual PIN denomination.
            // ================================================================

            billAmount:
                widget.pinAmount,

            // ================================================================
            // CUSTOMER AMOUNT
            //
            // Includes catalog price adjustment.
            // ================================================================

            totalAmount:
                widget.totalAmount,

            // ================================================================
            // RECEIPT INFORMATION
            // ================================================================

            mobilePinReceiptData:
                MobilePinReceiptExtraData(
              providerName:
                  widget.providerName,

              productCode:
                  widget.productCode,

              denomination:
                  widget.pinAmount,

              // One PIN only for now.
              quantity:
                  1,

              customerTotal:
                  widget.totalAmount,

              // Filled after IIMMPACT /v2/topup succeeds.
              pins:
                  const [],
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating =
              false;
        });
      }
    }
  }

  // ==========================================================================
  // NUMBER KEY
  // ==========================================================================

  Widget _buildNumberKey(
    String value,
  ) {
    final bool pressed =
        _activeKey == value;

    return Listener(
      onPointerDown:
          (_) {
        if (_isNavigating) {
          return;
        }

        setState(() {
          _activeKey =
              value;
        });
      },

      onPointerUp:
          (_) {
        if (_isNavigating) {
          return;
        }

        setState(() {
          _activeKey =
              null;
        });

        _addNumber(
          value,
        );
      },

      onPointerCancel:
          (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _activeKey =
              null;
        });
      },

      child:
          AnimatedScale(
        scale:
            pressed
                ? 0.93
                : 1,

        duration:
            const Duration(
          milliseconds:
              110,
        ),

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds:
                110,
          ),

          height:
              125,

          decoration:
              BoxDecoration(
            color:
                pressed
                    ? _primaryColor
                        .withValues(
                        alpha:
                            0.15,
                      )
                    : Colors.white,

            borderRadius:
                BorderRadius.circular(
              28,
            ),

            border:
                Border.all(
              color:
                  pressed
                      ? _primaryColor
                      : const Color(
                          0xFFB8C7D6,
                        ),
              width:
                  pressed
                      ? 4
                      : 2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(
                  alpha:
                      pressed
                          ? 0.08
                          : 0.15,
                ),
                blurRadius:
                    pressed
                        ? 6
                        : 14,
                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child:
              Center(
            child:
                Text(
              value,
              style:
                  TextStyle(
                color:
                    pressed
                        ? _darkColor
                        : const Color(
                            0xFF15253A,
                          ),
                fontSize:
                    64,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ACTION KEY
  // ==========================================================================

  Widget _buildActionKey({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color:
          Colors.transparent,

      child:
          InkWell(
        onTap:
            _isNavigating
                ? null
                : onPressed,

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        child:
            Container(
          height:
              125,

          decoration:
              BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                _lightColor,
                _darkColor,
              ],
            ),

            borderRadius:
                BorderRadius.circular(
              28,
            ),

            border:
                Border.all(
              color:
                  _darkColor,
              width:
                  2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    _primaryColor.withValues(
                  alpha:
                      0.25,
                ),
                blurRadius:
                    14,
                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child:
              Center(
            child:
                Icon(
              icon,
              color:
                  Colors.white,
              size:
                  50,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
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
      body:
          Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================

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
                Container(
              color:
                  Colors.white.withValues(
                alpha:
                    0.06,
              ),
            ),
          ),

          // ==================================================================
          // MODERN + GOVERNMENT HEADER
          // ==================================================================

          Positioned(
            top: 50,
            left: 65,
            right: 65,
            child: _MobilePinNumberHeader(
              serviceLabel: loc.mobilePinNumberServiceLabel,
              title: loc.mobilePinEnterNumberTitle,
              subtitle: loc.mobilePinEnterNumberSubtitle,
            ),
          ),

          // ==================================================================
          // PRODUCT + INPUT
          // ==================================================================

          Positioned(
            top:
                350,
            left:
                70,
            right:
                70,
            child:
                Container(
              padding:
                  const EdgeInsets.fromLTRB(
                28,
                25,
                28,
                28,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white.withValues(
                  alpha:
                      0.96,
                ),
                borderRadius:
                    BorderRadius.circular(
                  34,
                ),
                border:
                    Border.all(
                  color:
                      _primaryColor
                          .withValues(
                        alpha:
                            0.25,
                      ),
                  width:
                      2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(
                      0xFF19375C,
                    ).withValues(
                      alpha:
                          0.14,
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
                  // ==========================================================
                  // PRODUCT
                  // ==========================================================

                  Row(
                    children: [
                      Container(
                        width:
                            130,
                        height:
                            100,
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
                            24,
                          ),
                          border:
                              Border.all(
                            color:
                                _primaryColor
                                    .withValues(
                                  alpha:
                                      0.18,
                                ),
                          ),
                        ),
                        child:
                            Image.network(
                          widget.providerImageUrl,
                          fit:
                              BoxFit.contain,
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.sim_card_rounded,
                              size:
                                  55,
                              color:
                                  _primaryColor,
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        width:
                            20,
                      ),

                      Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.mobilePinSelectedProduct
                                  .toUpperCase(),
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF758399,
                                ),
                                fontSize:
                                    21,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),

                            const SizedBox(
                              height:
                                  5,
                            ),

                            Text(
                              widget.providerName,
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF17283E,
                                ),
                                fontSize:
                                    32,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),

                            const SizedBox(
                              height:
                                  8,
                            ),

                            Text(
                              '${_formatMoney(widget.pinAmount)}'
                              '  •  '
                              '${loc.mobilePinPaymentTotal}: '
                              '${_formatMoney(widget.totalAmount)}',
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF1769D2,
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
                    ],
                  ),

                  const SizedBox(
                    height:
                        35,
                  ),

                  // ==========================================================
                  // NUMBER FIELD
                  // ==========================================================

                  Container(
                    height:
                        110,
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF7FAFD,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),
                      border:
                          Border.all(
                        color:
                            _primaryColor,
                        width:
                            3,
                      ),
                    ),
                    child:
                        TextField(
                      controller:
                          _controller,
                      readOnly:
                          true,
                      showCursor:
                          true,
                      cursorColor:
                          _primaryColor,
                      cursorWidth:
                          4,
                      textAlign:
                          TextAlign.center,
                      keyboardType:
                          TextInputType.none,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17283E,
                        ),
                        fontSize:
                            50,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing:
                            2,
                      ),
                      decoration:
                          InputDecoration(
                        border:
                            InputBorder.none,
                        hintText:
                            loc.mobilePinNumberHint
                                .toUpperCase(),
                        hintStyle:
                            const TextStyle(
                          color:
                              Color(
                            0xFF9AA6B4,
                          ),
                          fontSize:
                              25,
                          fontWeight:
                              FontWeight.w700,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        23,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color:
                            Color(
                          0xFF60748B,
                        ),
                        size:
                            26,
                      ),

                      const SizedBox(
                        width:
                            10,
                      ),

                      Flexible(
                        child:
                            Text(
                          loc.mobilePinNumberInstruction,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF657386,
                            ),
                            fontSize:
                                25,
                            fontWeight:
                                FontWeight.w600,
                            height:
                                1.30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ==================================================================
          // KEYPAD
          // ==================================================================

          Positioned(
            top:
                850,
            left:
                80,
            right:
                80,
            child:
                AbsorbPointer(
              absorbing:
                  _isNavigating,
              child:
                  GridView.count(
                crossAxisCount:
                    3,
                shrinkWrap:
                    true,
                physics:
                    const NeverScrollableScrollPhysics(),
                mainAxisSpacing:
                    20,
                crossAxisSpacing:
                    20,
                childAspectRatio:
                    1.72,
                children: [
                  _buildNumberKey(
                    '1',
                  ),
                  _buildNumberKey(
                    '2',
                  ),
                  _buildNumberKey(
                    '3',
                  ),

                  _buildNumberKey(
                    '4',
                  ),
                  _buildNumberKey(
                    '5',
                  ),
                  _buildNumberKey(
                    '6',
                  ),

                  _buildNumberKey(
                    '7',
                  ),
                  _buildNumberKey(
                    '8',
                  ),
                  _buildNumberKey(
                    '9',
                  ),

                  _buildActionKey(
                    icon:
                        Icons
                            .delete_sweep_rounded,
                    onPressed:
                        _clearAll,
                  ),

                  _buildNumberKey(
                    '0',
                  ),

                  _buildActionKey(
                    icon:
                        Icons.backspace_outlined,
                    onPressed:
                        _backspace,
                  ),
                ],
              ),
            ),
          ),

          // ==================================================================
          // ACTIONS
          // ==================================================================

          Positioned(
            bottom:
                130,
            left:
                80,
            right:
                80,
            child:
                Row(
              children: [
                Expanded(
                  child:
                      SizedBox(
                    height:
                        108,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          _isNavigating
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                      icon:
                          const Icon(
                        Icons.arrow_back_rounded,
                        size:
                            40,
                      ),
                      label:
                          Text(
                        loc.buttonBack,
                        style:
                            const TextStyle(
                          fontSize:
                              30,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        backgroundColor:
                            Colors.white
                                .withValues(
                              alpha:
                                  0.95,
                            ),
                        foregroundColor:
                            const Color(
                          0xFF26364A,
                        ),
                        side:
                            const BorderSide(
                          color:
                              Colors.black,
                          width:
                              2.5,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width:
                      22,
                ),

                Expanded(
                  flex:
                      2,
                  child:
                      SizedBox(
                    height:
                        108,
                    child:
                        ElevatedButton(
                      onPressed:
                          _isNavigating
                              ? null
                              : _handleContinue,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF16813B,
                        ),
                        foregroundColor:
                            Colors.white,
                        elevation:
                            7,
                        shadowColor:
                            const Color(
                          0x5516813B,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                        ),
                      ),
                      child:
                          _isNavigating
                              ? const SizedBox(
                                  width:
                                      40,
                                  height:
                                      40,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        5,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child:
                                          Text(
                                        loc.mobilePinContinueToPayment
                                            .toUpperCase(),
                                        textAlign:
                                            TextAlign.center,
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              31,
                                          fontWeight:
                                              FontWeight.w900,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      width:
                                          12,
                                    ),

                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size:
                                          40,
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================================================================
          // FOOTER
          // ==================================================================

          Positioned(
            bottom:
                42,
            left:
                0,
            right:
                0,
            child:
                Text(
              Data.copyrightText,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF26364A,
                ),
                fontSize:
                    20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================================
// MODERN + GOVERNMENT MOBILE PIN NUMBER HEADER
// KEEPS EXISTING SERVICE LABEL + TITLE + SUBTITLE
// ============================================================================

class _MobilePinNumberHeader extends StatelessWidget {
  final String serviceLabel;
  final String title;
  final String subtitle;

  const _MobilePinNumberHeader({
    required this.serviceLabel,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF1769D2);
    const Color darkColor = Color(0xFF0D47A1);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.96,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFD5E4F7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A66).withValues(
              alpha: 0.14,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          // ==========================================================
          // LEFT ICON
          // ==========================================================

          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  darkColor,
                  Color(0xFF42A5F5),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(
                    alpha: 0.28,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.sim_card_download_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(width: 28),

          // ==========================================================
          // EXISTING TEXT
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // SERVICE LABEL
                // ------------------------------------------------------

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
                        Icons.sim_card_rounded,
                        size: 20,
                        color: accentColor,
                      ),

                      const SizedBox(width: 8),

                      Flexible(
                        child: Text(
                          serviceLabel.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: accentColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ------------------------------------------------------
                // TITLE
                // ------------------------------------------------------

                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF122C4C),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.02,
                    letterSpacing: -0.7,
                  ),
                ),

                const SizedBox(height: 9),

                // ------------------------------------------------------
                // SUBTITLE
                // ------------------------------------------------------

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607188),
                    fontSize: 22,
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
                  darkColor,
                  Color(0xFF42A5F5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}