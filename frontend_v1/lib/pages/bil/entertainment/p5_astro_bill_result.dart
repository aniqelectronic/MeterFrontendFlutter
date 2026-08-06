import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/electric/electric_bill_model.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/bil_qr_payment_page.dart';

class P5AstroResultPage extends StatefulWidget {
  final ElectricBillModel bill;
  final CatalogPricing catalogPricing;

  const P5AstroResultPage({
    super.key,
    required this.bill,
    required this.catalogPricing,
  });

  @override
  State<P5AstroResultPage> createState() =>
      _P5AstroBillResultPageState();
}

class _P5AstroBillResultPageState
    extends State<P5AstroResultPage> {
  final TextEditingController _amountController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();


  static const double _minimumAmount = 1.00;
  static const double _maximumAmount = 10000.00;
  static const double _amountStep = 1.00;

  double _selectedAmount = 1.00;

  // Step 0: review bill details
  // Step 1: choose payment amount
  int _currentStep = 0;

  ElectricBillModel get bill => widget.bill;

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

  double get _totalAmount =>
      _pricingResult.totalAmount;

  bool get _hasProviderDiscount =>
      _pricingResult.providerDiscountAmount.abs() >= 0.005;

  bool get _hasPriceAdjustment =>
      _pricingResult.platformAdjustmentAmount.abs() >= 0.005;

  @override
  void initState() {
    super.initState();

    final initialAmount =
        _getInitialPaymentAmount();

    _selectedAmount = initialAmount;
    _updateAmountController(initialAmount);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
double _getInitialPaymentAmount() {
  if (_amountToPay > 0) {
    return _amountToPay.clamp(
      _minimumAmount,
      _maximumAmount,
    );
  }

  return _minimumAmount;
}

String _formatAmount(double amount) {
  return 'RM ${amount.toStringAsFixed(2)}';
}

String _formatPositiveAmount(double amount) {
  final safeAmount = amount > 0 ? amount : 0.0;
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
    _amountController.text =
        _formatInputAmount(amount);

    _amountController.selection =
        TextSelection.fromPosition(
      TextPosition(
        offset: _amountController.text.length,
      ),
    );
  }

  void _onAmountChanged(String value) {
    final cleanedValue = value
        .replaceAll('RM', '')
        .replaceAll(',', '')
        .trim();

    final parsedAmount =
        double.tryParse(cleanedValue);

    setState(() {
      _selectedAmount = parsedAmount ?? 0;
    });
  }

  void _setPaymentAmount(double amount) {
    final safeAmount = amount.clamp(
      _minimumAmount,
      _maximumAmount,
    );

    setState(() {
      _selectedAmount = safeAmount;
      _updateAmountController(safeAmount);
    });
  }

  void _increaseAmount() {
    _closeKeyboard();

    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount >= _maximumAmount) {
      _showMessage(
        loc.entertainmentMaximumPayment(
          _formatAmount(_maximumAmount),
        ),
      );
      return;
    }

    _setPaymentAmount(
      _selectedAmount + _amountStep,
    );
  }

    void _decreaseAmount() {
      _closeKeyboard();

      final loc = AppLocalizations.of(context)!;

      if (_selectedAmount <= _minimumAmount) {
        _showMessage(
          loc.entertainmentMinimumPayment(
            _formatAmount(_minimumAmount),
          ),
        );
        return;
      }

      _setPaymentAmount(
        _selectedAmount - _amountStep,
      );
    }

  void _setQuickAmount(double amount) {
    _closeKeyboard();
    _setPaymentAmount(amount);
  }

  void _setFullOutstandingAmount() {
    _closeKeyboard();

    final loc = AppLocalizations.of(context)!;

    if (bill.outstandingAmount <= 0) {
      _showMessage(
        loc.entertainmentNoOutstandingBalance,
      );
      return;
    }

    _setQuickAmount(
      bill.outstandingAmount,
    );
  }

  void _goToPaymentStep() {
    _closeKeyboard();

    setState(() {
      _currentStep = 1;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _handleBack() {
    _closeKeyboard();

    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      return;
    }

    Navigator.pop(context);
  }

  Future<void> _handleContinue() async {
    _closeKeyboard();

    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount < _minimumAmount) {
      _showMessage(
        loc.entertainmentMinimumPayment(
          _formatAmount(_minimumAmount),
        ),
      );
      return;
    }

    if (_selectedAmount > _maximumAmount) {
      _showMessage(
        loc.entertainmentMaximumPayment(
          _formatAmount(_maximumAmount),
        ),
      );
      return;
    }

    final result =
        await Navigator.push<BilQrPaymentResult>(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '/payment',
        ),
        builder: (_) => BilQrPaymentPage(
          // Example:
          // Astro or another entertainment provider.
          billType: bill.billerName,

          // Provider/product code, for example ASTRO or ASB.
          billCode: bill.productCode,

          accountNumber: bill.accountNumber,

          // Actual amount selected for the provider.
          billAmount: _selectedAmount,

          // Final amount charged through PegePay.
          totalAmount: _totalAmount,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    debugPrint(
      '[ENTERTAINMENT BILL] QR payment successful',
    );
    debugPrint(
      '[ENTERTAINMENT BILL] Bill type: ${result.billType}',
    );
    debugPrint(
      '[ENTERTAINMENT BILL] Bill code: ${result.billCode}',
    );
    debugPrint(
      '[ENTERTAINMENT BILL] Account: ${result.accountNumber}',
    );
    debugPrint(
      '[ENTERTAINMENT BILL] Bill amount: ${result.billAmount}',
    );
    debugPrint(
      '[ENTERTAINMENT BILL] Total charged: ${result.totalAmount}',
    );
    debugPrint(
      '[ENTERTAINMENT BILL] Order number: ${result.orderNo}',
    );
    debugPrint(
      '[ENTERTAINMENT BILL] Bank transaction: '
      '${result.bankTransactionNo}',
    );

    /*
    NEXT STEP:

    Call your entertainment bill payment API here.

    Example:

    final success =
        await EntertainmentBillService.payBill(
      productCode: result.billCode,
      accountNumber: result.accountNumber,
      amount: result.billAmount,
      orderNo: result.orderNo,
      bankTransactionNo:
          result.bankTransactionNo,
    );

    After the provider API succeeds, navigate to the
    bill receipt page.
    */
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: loc.entertainmentInformation,
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
                    color: const Color(0xFFF8BBD0),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 45,
                      offset: const Offset(0, 22),
                    ),
                    BoxShadow(
                      color: const Color(0xFFD81B60).withOpacity(0.24),
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
                            Color(0xFFF06292),
                            Color(0xFF880E4F),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD81B60)
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
                      loc.entertainmentInformation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF880E4F),
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
                            Color(0xFFF06292),
                            Color(0xFF880E4F),
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
                        color: const Color(0xFFFFF5F8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFF8BBD0),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4E5968),
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
                          loc.entertainmentOk,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD81B60),
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
    barrierLabel: loc.entertainmentKeyboard,
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
                                      0xFFFCE4EC,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(18),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .keyboard_alt_rounded,
                                    color:
                                        Color(0xFFD81B60),
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
                                        loc.entertainmentEnterPaymentAmount,
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
                                        loc.entertainmentUseKeypad,
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
                                    0xFFD81B60,
                                  ),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD81B60,
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
                                loc.entertainmentMinimumMaximum,
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
                                        loc.entertainmentClear,
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
                                        loc.entertainmentDone,
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
                                  loc.entertainmentCancel,
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


  Widget _buildStepHeading({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE4EC), Color(0xFFFFF8FB)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF48FB1), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFD81B60),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 44),
          ),
          const SizedBox(width: 24),
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
                const SizedBox(height: 9),
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFF5FFF6)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF66BB6A), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.payments_rounded, color: Colors.white, size: 48),
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.entertainmentAmountToPay,
                  style: const TextStyle(
                    color: Color(0xFF39724A),
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatPositiveAmount(_amountToPay),
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 44),
        ],
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _closeKeyboard,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
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
                  _buildHeader(),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 20,
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 12,
                        radius: const Radius.circular(20),
                        interactive: true,
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
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: Container(
                              key: ValueKey<int>(
                                _currentStep,
                              ),
                              padding: const EdgeInsets.all(
                                35,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.97,
                                ),
                                borderRadius:
                                    BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE2E8F0,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.08,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(
                                      0,
                                      8,
                                    ),
                                  ),
                                ],
                              ),
                              child: _currentStep == 0
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _buildStepHeading(
                                          icon: Icons
                                              .fact_check_outlined,
                                          title: loc
                                              .electricReviewDetailsTitle,
                                          subtitle: loc
                                              .electricReviewDetailsSubtitle,
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        _buildBillInformationCard(),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        _buildAccountNumberSection(),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _buildAmountToPayCard(),
                                        const SizedBox(
                                          height: 32,
                                        ),
                                        _buildAmountSection(),
                                        const SizedBox(
                                          height: 32,
                                        ),
                                        _buildOrderSummary(),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 60,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButtons(),
                        const SizedBox(height: 18),
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
      ),
    );
  }

 Widget _buildHeader() {
  final loc = AppLocalizations.of(context)!;

  return Container(
    margin: const EdgeInsets.fromLTRB(
      70,
      30,
      70,
      0,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 34,
      vertical: 26,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        colors: [
          Color(0xFF880E4F),
          Color(0xFFD81B60),
          Color(0xFFF06292),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.15,
          ),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Text(
                bill.billerName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                loc.entertainmentBillPayment.toUpperCase(),
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
          Icons.live_tv_rounded,
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
        : const Color(0xFF0097B2);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF0097B2),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.entertainmentBillInformation,
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
                child: _InformationItem(
                  icon: isCredit
                      ? Icons.account_balance_wallet_rounded
                      : Icons.credit_card_rounded,
                  label: loc.entertainmentOutstandingAmount,
                  value: _formatAmount(
                    bill.outstandingAmount,
                  ),
                  valueColor: outstandingColor,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: _InformationItem(
                  icon: Icons.calendar_month_rounded,
                  label: loc.entertainmentDueDate,
                  value: bill.dueDate.trim().isEmpty
                      ? '-'
                      : bill.dueDate,
                ),
              ),
            ],
          ),
          if (bill.customerName.trim().isNotEmpty) ...[
            const Divider(height: 32),
            _InformationItem(
              icon: Icons.person_outline_rounded,
              label: loc.entertainmentCustomerName,
              value: bill.customerName,
            ),
          ],
          if (bill.customerAddress.trim().isNotEmpty) ...[
            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 22),
            _InformationItem(
              icon: Icons.home_outlined,
              label: loc.entertainmentServiceAddress,
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
                      loc.entertainmentCreditNotice,
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
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        loc.entertainmentAccountNumber,
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
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4E1F5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.numbers_rounded,
              color: Color(0xFF60758D),
              size: 32,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                bill.accountNumber,
                style: const TextStyle(
                  color: Color(0xFF60758D),
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF8796A8),
              size: 28,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildAmountSection() {
  final loc = AppLocalizations.of(context)!;

  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        loc.entertainmentSelectPaymentAmount,
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
          color: const Color(0xFFFCE4EC),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF48FB1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.keyboard_alt_outlined,
              color: Color(0xFFC2185B),
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                loc.entertainmentAmountInstruction,
                style: const TextStyle(
                  color: Color(0xFF880E4F),
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
        crossAxisAlignment:
            CrossAxisAlignment.center,
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
                onTap:
                    _openCustomAmountKeyboard,
                borderRadius:
                    BorderRadius.circular(20),
                child: Container(
                  height: 95,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          const Color(0xFFD81B60),
                      width: 3,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        color:
                            Color(0xFFD81B60),
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _amountController
                                  .text.isEmpty
                              ? '0.00'
                              : _amountController
                                  .text,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Color(0xFF102A43),
                            fontSize: 32,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons
                            .keyboard_alt_rounded,
                        color:
                            Color(0xFF60758D),
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
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFFF3E0),
                foregroundColor:
                    const Color(0xFFE65100),
                elevation: 0,
                padding: EdgeInsets.zero,
                side: const BorderSide(
                  color: Color(0xFFFFB46A),
                  width: 3,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
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
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFE8F5E9),
                foregroundColor:
                    const Color(0xFF2E7D32),
                elevation: 0,
                padding: EdgeInsets.zero,
                side: const BorderSide(
                  color: Color(0xFF66BB6A),
                  width: 3,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
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
              loc.entertainmentIncreaseDecreaseInstruction,
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
        loc.entertainmentAmountLimit,
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
            onPressed: () {
              _setQuickAmount(20);
            },
          ),
          _QuickAmountButton(
            label: 'RM 50',
            onPressed: () {
              _setQuickAmount(50);
            },
          ),
          _QuickAmountButton(
            label: 'RM 100',
            onPressed: () {
              _setQuickAmount(100);
            },
          ),
          _QuickAmountButton(
            label: 'RM 200',
            onPressed: () {
              _setQuickAmount(200);
            },
          ),
          if (bill.outstandingAmount > 0)
            _QuickAmountButton(
              label: loc.entertainmentFull,
              emphasized: true,
              onPressed:
                  _setFullOutstandingAmount,
            ),
        ],
      ),
    ],
  );
}

String _getEntertainmentUpdateTime(
  AppLocalizations loc,
) {
  final productCode =
      bill.productCode.trim().toUpperCase();

  switch (productCode) {
    case 'ASB':
    case 'ASTRO':
      return loc.entertainmentUpdateInstant;

    default:
      return loc.entertainmentUpdateInstant;
  }
}

Widget _buildOrderSummary() {
  final loc = AppLocalizations.of(context)!;

  final billUpdateTime = _getEntertainmentUpdateTime(loc);
  final pricing = _pricingResult;

  final double serviceAdjustment =
      pricing.platformAdjustmentAmount;

  final bool isServiceFee =
      serviceAdjustment > 0;

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.entertainmentOrderSummary,
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 25),

        _SummaryRow(
          label: bill.billerName,
          value: _formatAmount(
            pricing.billAmount,
          ),
        ),

        // Only show customer-facing pricing.
        // Provider discount is our internal margin.
        if (pricing.hasPlatformAdjustment) ...[
          const Divider(height: 38),

          _SummaryRow(
            label: isServiceFee
                ? loc.entertainmentServiceFee
                : loc.entertainmentServiceAdjustment,
            value: _formatSignedAmount(
              serviceAdjustment,
            ),
            valueColor: isServiceFee
                ? const Color(0xFFE65100)
                : const Color(0xFF138A72),
          ),
        ],

        const Divider(height: 38),

        _SummaryRow(
          label: loc.entertainmentTotalAmount,
          value: _formatAmount(
            pricing.totalAmount,
          ),
          isTotal: true,
        ),

        const Divider(height: 38),

        _SummaryRow(
          label: loc.entertainmentPaymentUpdateTime,
          value: billUpdateTime,
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
                  fontSize: 28,
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
                loc.entertainmentContinue,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
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

class _InformationItem
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InformationItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue =
        value.trim().isEmpty
            ? '-'
            : value.trim();

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF6D7D90),
          size: 34,
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color:
                      Color(0xFF63758A),
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                displayValue,
                style: TextStyle(
                  color: valueColor ??
                      const Color(
                        0xFF102A43,
                      ),
                  fontSize: 29,
                  height: 1.35,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAmountButton
    extends StatelessWidget {
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
        style:
            OutlinedButton.styleFrom(
          foregroundColor: emphasized
              ? Colors.white
              : const Color(
                  0xFF17375E,
                ),
          backgroundColor: emphasized
              ? const Color(
                  0xFFD81B60,
                )
              : Colors.white,
          side: BorderSide(
            color: emphasized
                ? const Color(
                    0xFFD81B60,
                  )
                : const Color(
                    0xFFCAD5E2,
                  ),
            width: 2,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
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
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal
                  ? const Color(
                      0xFF102A43,
                    )
                  : const Color(
                      0xFF63758A,
                    ),
              fontSize:
                  isTotal ? 31 : 25,
              fontWeight: isTotal
                  ? FontWeight.w900
                  : FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 20),

        Text(
          value,
          style: TextStyle(
            color: valueColor ??
                (isTotal
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF102A43)),
            fontSize:
                isTotal ? 34 : 27,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }
}