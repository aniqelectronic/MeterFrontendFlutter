import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/water/water_bill_model.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';

class P5WaterBillResultPage extends StatefulWidget {
  final WaterBillModel bill;
  final CatalogPricing catalogPricing;

  const P5WaterBillResultPage({
    super.key,
    required this.bill,
    required this.catalogPricing,
  });

  @override
  State<P5WaterBillResultPage> createState() =>
      _P5WaterBillResultPageState();
}

class _P5WaterBillResultPageState
    extends State<P5WaterBillResultPage> {
  static const double _minimumAmount = 1;
  static const double _maximumAmount = 10000;
  static const double _amountStep = 1;

  final TextEditingController _amountController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double _selectedAmount = 1;

  // Step 0: review bill details
  // Step 1: choose payment amount
  int _currentStep = 0;

  WaterBillModel get bill => widget.bill;

  double get _amountToPay {
  return bill.outstandingAmount > 0
      ? bill.outstandingAmount
      : 0.0;
}

  BillPricingResult get _pricingResult =>
      BillPricingResult.calculate(
        billAmount: _selectedAmount,
        pricing: widget.catalogPricing,
      );

  double get _totalAmount => _pricingResult.totalAmount;

  bool get _hasProviderDiscount =>
      _pricingResult.providerDiscountAmount.abs() >= 0.005;

  bool get _hasPriceAdjustment =>
      _pricingResult.platformAdjustmentAmount.abs() >= 0.005;

  @override
  void initState() {
    super.initState();

    final initialAmount = _amountToPay > 0
        ? _amountToPay.clamp(
            _minimumAmount,
            _maximumAmount,
          )
        : _minimumAmount;

    _selectedAmount = initialAmount;
    _amountController.text =
        initialAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _formatPositiveAmount(double amount) {
    final safeAmount = amount > 0
        ? amount
        : 0.0;

    return 'RM ${safeAmount.toStringAsFixed(2)}';
  }

  String _formatSignedAmount(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    return '$sign RM ${amount.abs().toStringAsFixed(2)}';
  }

  String _formatInputAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  void _closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _updateAmountController(double amount) {
    _amountController.text = _formatInputAmount(amount);
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
  }

  void _setPaymentAmount(double amount) {
    final safe = amount.clamp(
      _minimumAmount,
      _maximumAmount,
    );

    setState(() {
      _selectedAmount = safe;
      _amountController.text = safe.toStringAsFixed(2);
    });
  }

  void _increaseAmount() {
    _closeKeyboard();

    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount >= _maximumAmount) {
      _showMessage(
        loc.waterMaximumPayment(
          _formatAmount(_maximumAmount),
        ),
      );
      return;
    }

    _setPaymentAmount(_selectedAmount + _amountStep);
  }

  void _decreaseAmount() {
    _closeKeyboard();

    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount <= _minimumAmount) {
      _showMessage(
        loc.waterMinimumPayment(
          _formatAmount(_minimumAmount),
        ),
      );
      return;
    }

    _setPaymentAmount(_selectedAmount - _amountStep);
  }

  void _setFullOutstandingAmount() {
    _closeKeyboard();

    final loc = AppLocalizations.of(context)!;

    if (bill.outstandingAmount <= 0) {
      _showMessage(loc.waterNoOutstandingBalance);
      return;
    }

    _setPaymentAmount(bill.outstandingAmount);
  }

  void _goToPaymentStep() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _currentStep = 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _handleBack() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });

      return;
    }

    Navigator.pop(context);
  }

  void _handleContinue() {
    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount < _minimumAmount) {
      _showMessage(
        loc.waterMinimumPayment(
          _formatAmount(_minimumAmount),
        ),
      );
      return;
    }

    if (_selectedAmount > _maximumAmount) {
      _showMessage(
        loc.waterMaximumPayment(
          _formatAmount(_maximumAmount),
        ),
      );
      return;
    }

    Navigator.pop(context, _totalAmount);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: loc.waterInformation,
      barrierColor: const Color(0xFF07182E).withOpacity(0.72),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 760,
                margin: const EdgeInsets.symmetric(
                  horizontal: 70,
                  vertical: 120,
                ),
                padding: const EdgeInsets.fromLTRB(
                  46,
                  42,
                  46,
                  40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color: const Color(0xFFB2EBF2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 45,
                      offset: const Offset(0, 22),
                    ),
                    BoxShadow(
                      color: const Color(0xFF00838F).withOpacity(0.24),
                      blurRadius: 55,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF26C6DA),
                            Color(0xFF006064),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00838F)
                                .withOpacity(0.30),
                            blurRadius: 24,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 72,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      loc.waterInformation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF006064),
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: 120,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF26C6DA),
                            Color(0xFF006064),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FCFD),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFB2EBF2),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF445B63),
                          fontSize: 31,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    SizedBox(
                      width: double.infinity,
                      height: 92,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          size: 38,
                        ),
                        label: Text(
                          loc.waterOk,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00838F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
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
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.82,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  void _openCustomAmountKeyboard() {
  _closeKeyboard();

  final loc = AppLocalizations.of(context)!;

  String temporaryValue = _amountController.text;

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: loc.waterEnterPaymentAmount,
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(
      milliseconds: 220,
    ),
    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.88,
            end: 1.0,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
    pageBuilder: (
      dialogContext,
      animation,
      secondaryAnimation,
    ) {
      return StatefulBuilder(
        builder: (
          keyboardContext,
          setKeyboardState,
        ) {
          void updateValue(String newValue) {
            temporaryValue = newValue;

            final parsedAmount =
                double.tryParse(temporaryValue) ?? 0;

            final safeAmount =
                parsedAmount < _minimumAmount
                    ? _minimumAmount
                    : parsedAmount.clamp(
                        _minimumAmount,
                        _maximumAmount,
                      );

            setKeyboardState(() {});

            setState(() {
              _selectedAmount = safeAmount;

              _amountController.text =
                  temporaryValue.isEmpty
                      ? _formatInputAmount(
                          _minimumAmount,
                        )
                      : temporaryValue;
            });
          }

          void pressNumber(String number) {
            if (temporaryValue == '0.00' ||
                temporaryValue == '0') {
              updateValue(number);
              return;
            }

            if (temporaryValue.contains('.')) {
              final parts =
                  temporaryValue.split('.');

              final decimalPart =
                  parts.length > 1
                      ? parts.last
                      : '';

              if (decimalPart.length >= 2) {
                return;
              }
            }

            final prospectiveValue =
                '$temporaryValue$number';

            final parsedValue =
                double.tryParse(prospectiveValue);

            if (parsedValue != null &&
                parsedValue > _maximumAmount) {
              return;
            }

            if (prospectiveValue.length > 8) {
              return;
            }

            updateValue(prospectiveValue);
          }

          void pressDecimal() {
            if (temporaryValue.contains('.')) {
              return;
            }

            if (temporaryValue.isEmpty) {
              updateValue('0.');
              return;
            }

            updateValue('$temporaryValue.');
          }

          void pressDelete() {
            if (temporaryValue.isEmpty) {
              return;
            }

            final newValue =
                temporaryValue.substring(
              0,
              temporaryValue.length - 1,
            );

            updateValue(newValue);
          }

          void pressClear() {
            temporaryValue = '';

            setKeyboardState(() {});

            setState(() {
              _selectedAmount = _minimumAmount;

              _amountController.text =
                  _formatInputAmount(
                _minimumAmount,
              );
            });
          }

          void pressCancel() {
            Navigator.pop(dialogContext);

            _updateAmountController(
              _selectedAmount < _minimumAmount
                  ? _minimumAmount
                  : _selectedAmount,
            );
          }

          void pressDone() {
            final parsedAmount =
                double.tryParse(temporaryValue) ??
                    0;

            final finalAmount =
                parsedAmount < _minimumAmount
                    ? _minimumAmount
                    : parsedAmount.clamp(
                        _minimumAmount,
                        _maximumAmount,
                      );

            _setPaymentAmount(finalAmount);
            Navigator.pop(dialogContext);
          }

          return Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.all(35),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 820,
                      maxHeight: 1150,
                    ),
                    child: Container(
                      width: 820,
                      padding:
                          const EdgeInsets.fromLTRB(
                        38,
                        32,
                        38,
                        36,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF8FAFC),
                        borderRadius:
                            BorderRadius.circular(34),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.30),
                            blurRadius: 35,
                            spreadRadius: 5,
                            offset:
                                const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFE0F7FA,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(18),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .keyboard_alt_rounded,
                                    color:
                                        Color(0xFF00838F),
                                    size: 37,
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
                                        loc.waterEnterPaymentAmount,
                                        style:
                                            const TextStyle(
                                          color: Color(
                                            0xFF102A43,
                                          ),
                                          fontSize: 30,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        loc.electricUseKeypad,
                                        style:
                                            const TextStyle(
                                          color: Color(
                                            0xFF60758D,
                                          ),
                                          fontSize: 20,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      pressCancel,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 36,
                                    color:
                                        Color(0xFF60758D),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 28,
                                vertical: 25,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                  22,
                                ),
                                border: Border.all(
                                  color:
                                      const Color(
                                    0xFF00838F,
                                  ),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00838F,
                                    ).withOpacity(0.10),
                                    blurRadius: 15,
                                    offset:
                                        const Offset(
                                      0,
                                      6,
                                    ),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'RM',
                                    style: TextStyle(
                                      color: Color(
                                        0xFF53677E,
                                      ),
                                      fontSize: 34,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Text(
                                      temporaryValue
                                              .isEmpty
                                          ? '0.00'
                                          : temporaryValue,
                                      textAlign:
                                          TextAlign.right,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.fade,
                                      style:
                                          const TextStyle(
                                        color: Color(
                                          0xFF102A43,
                                        ),
                                        fontSize: 46,
                                        fontWeight:
                                            FontWeight
                                                .w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment:
                                  Alignment.centerLeft,
                              child: Text(
                                loc.electricMinimumMaximum,
                                style:
                                    const TextStyle(
                                  color:
                                      Color(0xFF60758D),
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '1',
                                    onPressed: () {
                                      pressNumber('1');
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '2',
                                    onPressed: () {
                                      pressNumber('2');
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '3',
                                    onPressed: () {
                                      pressNumber('3');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '4',
                                    onPressed: () {
                                      pressNumber('4');
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '5',
                                    onPressed: () {
                                      pressNumber('5');
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '6',
                                    onPressed: () {
                                      pressNumber('6');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '7',
                                    onPressed: () {
                                      pressNumber('7');
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '8',
                                    onPressed: () {
                                      pressNumber('8');
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '9',
                                    onPressed: () {
                                      pressNumber('9');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '.',
                                    onPressed:
                                        pressDecimal,
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                      _buildKeyboardButton(
                                    label: '0',
                                    onPressed: () {
                                      pressNumber('0');
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                      _buildKeyboardIconButton(
                                    icon: Icons
                                        .backspace_outlined,
                                    onPressed:
                                        pressDelete,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 78,
                                    child:
                                        OutlinedButton
                                            .icon(
                                      onPressed:
                                          pressClear,
                                      icon:
                                          const Icon(
                                        Icons
                                            .delete_sweep_outlined,
                                        size: 29,
                                      ),
                                      label: Text(
                                        loc.electricClear,
                                        style:
                                            const TextStyle(
                                          fontSize: 22,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
                                      ),
                                      style:
                                          OutlinedButton
                                              .styleFrom(
                                        foregroundColor:
                                            const Color(
                                          0xFFC62828,
                                        ),
                                        backgroundColor:
                                            const Color(
                                          0xFFFFF5F5,
                                        ),
                                        side:
                                            const BorderSide(
                                          color: Color(
                                            0xFFEF9A9A,
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
                                  width: 18,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 78,
                                    child:
                                        ElevatedButton
                                            .icon(
                                      onPressed:
                                          pressDone,
                                      icon:
                                          const Icon(
                                        Icons
                                            .check_circle_rounded,
                                        size: 31,
                                      ),
                                      label: Text(
                                        loc.waterDone,
                                        style:
                                            const TextStyle(
                                          fontSize: 24,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
                                      ),
                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            const Color(
                                          0xFF2E7D32,
                                        ),
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
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 68,
                              child: TextButton.icon(
                                onPressed:
                                    pressCancel,
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 28,
                                ),
                                label: Text(
                                  loc.waterCancel,
                                  style:
                                      const TextStyle(
                                    fontSize: 21,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                style:
                                    TextButton.styleFrom(
                                  backgroundColor:
                                      const Color
                                          .fromARGB(
                                    255,
                                    255,
                                    0,
                                    0,
                                  ),
                                  foregroundColor:
                                      const Color
                                          .fromARGB(
                                    255,
                                    240,
                                    239,
                                    237,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      16,
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
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildKeyboardButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    height: 92,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF102A43),
        side: const BorderSide(
          color: Color(0xFFD5DEE9),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 37,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

Widget _buildKeyboardIconButton({
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    height: 92,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 1,
        backgroundColor: const Color(0xFFFFF3E0),
        foregroundColor: const Color(0xFFE65100),
        side: const BorderSide(
          color: Color(0xFFFFB46A),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Icon(
        icon,
        size: 38,
      ),
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/pnew.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      interactive: true,
                      thickness: 12,
                      radius: const Radius.circular(20),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(
                          70,
                          35,
                          70,
                          20,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: Container(
                            key: ValueKey<int>(_currentStep),
                            padding: const EdgeInsets.all(35),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.97),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: _currentStep == 0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildStepHeading(
                                        icon: Icons.fact_check_outlined,
                                        title: loc.waterReviewDetailsTitle,
                                        subtitle:
                                            loc.waterReviewDetailsSubtitle,
                                      ),
                                      const SizedBox(height: 30),
                                      _buildBillInformationCard(),
                                      const SizedBox(height: 30),
                                      _buildAccountNumberSection(),
                                      const SizedBox(height: 30),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildAmountToPayCard(),
                                      const SizedBox(height: 32),
                                      _buildAmountSection(),
                                      const SizedBox(height: 32),
                                      _buildOrderSummary(),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    70,
                    30,
                    70,
                    55,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButtons(),
                      const SizedBox(height: 50),
                      Text(
                        Data.copyrightText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF17375E),
                        ),
                      ),
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


  Widget _buildStepHeading({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE0F7FA),
            Color(0xFFF4FEFF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF80DEEA),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF00838F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF102A43),
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF53677E),
                    fontSize: 24,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountToPayCard() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F7FA),
            Color(0xFFF4FFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF4DD0E1),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00838F).withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFF00838F),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 45,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.waterAmountToPay,
                  style: const TextStyle(
                    color: Color(0xFF236B70),
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _formatPositiveAmount(_amountToPay),
                  style: const TextStyle(
                    color: Color(0xFF006064),
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            color: Color(0xFF00838F),
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(70, 30, 70, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 26,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006064),
            Color(0xFF00838F),
            Color(0xFF26C6DA),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    bill.billerName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  loc.waterBillPayment,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildBillInformationCard() {
    final loc = AppLocalizations.of(context)!;

    final isCredit = bill.outstandingAmount < 0;

    final outstandingColor = isCredit
        ? const Color(0xFF138A72)
        : const Color(0xFF0097A7);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF00ACC1),
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.waterBillInformation,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 35,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem(
                  icon: isCredit
                      ? Icons.account_balance_wallet_rounded
                      : Icons.credit_card_rounded,
                  label: loc.waterOutstandingAmount,
                  value: _formatAmount(
                    bill.outstandingAmount,
                  ),
                  valueColor: outstandingColor,
                ),
              ),

              const SizedBox(width: 30),

              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_month_rounded,
                  label: loc.waterDueDate,
                  value: bill.dueDate.trim().isEmpty
                      ? '-'
                      : bill.dueDate,
                ),
              ),
            ],
          ),

          if (bill.customerName.trim().isNotEmpty) ...[
            const Divider(height: 35),
            _InfoItem(
              icon: Icons.person_outline_rounded,
              label: loc.waterCustomerName,
              value: bill.customerName,
            ),
          ],

          if (bill.customerAddress.trim().isNotEmpty) ...[
            const Divider(height: 35),
            _InfoItem(
              icon: Icons.home_outlined,
              label: loc.waterServiceAddress,
              value: bill.customerAddress,
            ),
          ],

          if (isCredit) ...[
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF138A72),
                    size: 32,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      loc.waterCreditNotice,
                      style: const TextStyle(
                        color: Color(0xFF096B59),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountNumberSection() {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.waterAccountNumber,
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontSize: 31,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD4E1F5),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.numbers_rounded),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  bill.accountNumber,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.lock_outline_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.waterSelectPaymentAmount,
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontSize: 31,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF80DEEA),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.keyboard_alt_outlined,
                color: Color(0xFF00838F),
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  loc.electricAmountInstruction,
                  style: const TextStyle(
                    color: Color(0xFF006064),
                    fontSize: 20,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'RM',
              style: TextStyle(
                color: Color(0xFF53677E),
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openCustomAmountKeyboard,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 95,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00838F),
                        width: 3,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          color: Color(0xFF00838F),
                          size: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _amountController.text.isEmpty
                                ? '0.00'
                                : _amountController.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF102A43),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_alt_rounded,
                          color: Color(0xFF60758D),
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 105,
              height: 95,
              child: ElevatedButton(
                onPressed: _decreaseAmount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF3E0),
                  foregroundColor: const Color(0xFFE65100),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  side: const BorderSide(
                    color: Color(0xFFFFB46A),
                    width: 3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Icon(
                  Icons.remove_rounded,
                  size: 55,
                ),
              ),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 105,
              height: 95,
              child: ElevatedButton(
                onPressed: _increaseAmount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F5E9),
                  foregroundColor: const Color(0xFF2E7D32),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  side: const BorderSide(
                    color: Color(0xFF66BB6A),
                    width: 3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 55,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(
              Icons.touch_app_rounded,
              color: Color(0xFF60758D),
              size: 25,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loc.electricIncreaseDecreaseInstruction,
                style: const TextStyle(
                  color: Color(0xFF60758D),
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          loc.electricAmountLimit,
          style: const TextStyle(
            color: Color(0xFF60758D),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _QuickAmountButton(
              label: 'RM 20',
              onPressed: () => _setPaymentAmount(20),
            ),
            _QuickAmountButton(
              label: 'RM 50',
              onPressed: () => _setPaymentAmount(50),
            ),
            _QuickAmountButton(
              label: 'RM 100',
              onPressed: () => _setPaymentAmount(100),
            ),
            _QuickAmountButton(
              label: 'RM 200',
              onPressed: () => _setPaymentAmount(200),
            ),
            if (bill.outstandingAmount > 0)
              _QuickAmountButton(
                label: loc.waterFull,
                emphasized: true,
                onPressed: _setFullOutstandingAmount,
              ),
          ],
        ),
      ],
    );
  }

  String _getBillUpdateTime(AppLocalizations loc) {
    final productCode = bill.productCode.trim().toUpperCase();

    switch (productCode) {
      // Instant
      case 'SAJ':
      case 'RANHILL SAJ':
      case 'AIRSELANGOR':
      case 'AIR SELANGOR':
      case 'SATU':
      case 'SYARIKAT AIR TERENGGANU':
        return loc.waterUpdateInstant;

      // 3 Days
      case 'SAINS':
      case 'SYARIKAT AIR NEGERI SEMBILAN':
      case 'SAP':
      case 'SYARIKAT AIR PERLIS':
        return loc.waterUpdateWithinThreeDays;

      // Default 24 Hours
      default:
        return loc.waterUpdateTwentyFourHours;
    }
  }

Widget _buildOrderSummary() {
  final loc = AppLocalizations.of(context)!;

  final double serviceAdjustment =
      _pricingResult.platformAdjustmentAmount;

  return Container(
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0xFFD3DCE8),
        width: 2,
      ),
    ),
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            loc.waterOrderSummary,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(height: 25),

        _SummaryRow(
          label: bill.billerName,
          value: _formatAmount(
            _pricingResult.billAmount,
          ),
        ),

        // Only show the customer-facing service adjustment.
        if (_pricingResult.hasPlatformAdjustment) ...[
          const Divider(height: 38),
          _SummaryRow(
            label: serviceAdjustment > 0
                ? loc.waterServiceFee
                : loc.waterServiceAdjustment,
            value: _formatSignedAmount(
              serviceAdjustment,
            ),
          ),
        ],

        const Divider(height: 38),

        _SummaryRow(
          label: loc.waterTotalAmount,
          value: _formatAmount(
            _pricingResult.totalAmount,
          ),
          isTotal: true,
        ),

        const Divider(height: 38),

        _SummaryRow(
          label: loc.waterPaymentUpdateTime,
          value: _getBillUpdateTime(loc),
        ),
      ],
    ),
  );
}

  Widget _buildActionButtons() {
    final loc = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 90,
            child: ElevatedButton.icon(
              onPressed: _handleBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 34,
              ),
              label: Text(
                loc.buttonBack,
                style: const TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                side: const BorderSide(
                  color: Color(0xFFD5DCE5),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: SizedBox(
            height: 90,
            child: ElevatedButton.icon(
              onPressed: _currentStep == 0
                  ? _goToPaymentStep
                  : _handleContinue,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 34,
              ),
              label: Text(
                loc.waterContinue,
                style: const TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 34),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                value.trim().isEmpty ? '-' : value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _AmountButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 105,
      height: 95,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 55),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool emphasized;

  const _QuickAmountButton({
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: emphasized
              ? Colors.white
              : const Color(0xFF17375E),
          backgroundColor: emphasized
              ? const Color(0xFF00838F)
              : Colors.white,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 31 : 25,
              fontWeight:
                  isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? const Color(0xFF00838F)
                : const Color(0xFF102A43),
            fontSize: isTotal ? 34 : 27,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
