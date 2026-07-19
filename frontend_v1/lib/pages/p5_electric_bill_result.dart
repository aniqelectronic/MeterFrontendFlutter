import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/electric/electric_bill_model.dart';
import 'package:frontend_v1/pages/data.dart';

class P5ElectricBillResultPage extends StatefulWidget {
  final ElectricBillModel bill;

  const P5ElectricBillResultPage({
    super.key,
    required this.bill,
  });

  @override
  State<P5ElectricBillResultPage> createState() =>
      _P5ElectricBillResultPageState();
}

class _P5ElectricBillResultPageState
    extends State<P5ElectricBillResultPage> {
  final TextEditingController _amountController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();


  static const double _minimumAmount = 1.00;
  static const double _maximumAmount = 10000.00;
  static const double _amountStep = 1.00;

  double _selectedAmount = 1.00;

  ElectricBillModel get bill => widget.bill;

  double get _serviceFee =>
      Data.electricityServiceFee;

  double get _totalAmount =>
      _selectedAmount + _serviceFee;

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
    if (bill.outstandingAmount > 0) {
      return bill.outstandingAmount.clamp(
        _minimumAmount,
        _maximumAmount,
      );
    }

    if (bill.amount > 0) {
      return bill.amount.clamp(
        _minimumAmount,
        _maximumAmount,
      );
    }

    return _minimumAmount;
  }

  String _formatAmount(double amount) {
    return 'RM ${amount.abs().toStringAsFixed(2)}';
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
        loc.electricMaximumPayment(
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
          loc.electricMinimumPayment(
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
        loc.electricNoOutstandingBalance,
      );
      return;
    }

    _setQuickAmount(
      bill.outstandingAmount,
    );
  }

  void _handleContinue() {
    _closeKeyboard();

    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount < _minimumAmount) {
      _showMessage(
        loc.electricMinimumPayment(
          _formatAmount(_minimumAmount),
        ),
      );
      return;
    }

    if (_selectedAmount > _maximumAmount) {
      _showMessage(
        loc.electricMaximumPayment(
          _formatAmount(_maximumAmount),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _totalAmount,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF1976D2),
                size: 36,
              ),
              const SizedBox(width: 14),
              Text(
                loc.electricInformation,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 22,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                loc.electricOk,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
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
    barrierLabel: loc.electricKeyboard,
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
                                      0xFFE3F2FD,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(18),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .keyboard_alt_rounded,
                                    color:
                                        Color(0xFF1976D2),
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
                                        loc.electricEnterPaymentAmount,
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
                                    0xFF1976D2,
                                  ),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1976D2,
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
                                        loc.electricDone,
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
                                  loc.electricCancel,
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

                // ==========================
                // SCROLLABLE CONTENT
                // ==========================
                Expanded(
                    child: Padding(
                    padding: const EdgeInsets.only(right: 20),
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
                      child: Container(
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
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _buildBillInformationCard(),

                          const SizedBox(height: 30),

                          _buildAccountNumberSection(),

                          const SizedBox(height: 32),

                          _buildAmountSection(),

                          const SizedBox(height: 32),

                          _buildOrderSummary(),

                          // Give space so last card isn't hidden
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                   ),
                  ),
                ),
                ),

                // ==========================
                // FIXED BOTTOM BUTTON BAR
                // ==========================
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
            )
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
          Color(0xFF0D47A1),
          Color(0xFF1976D2),
          Color(0xFF42A5F5),
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
                bill.billerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                loc.electricBillPayment,
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
          Icons.electric_bolt_rounded,
          color: Colors.white,
          size: 64,
        ),
      ],
    ),
  );
}

  Widget _buildBillInformationCard() {
  final loc = AppLocalizations.of(context)!;

  final isCredit =
      bill.outstandingAmount < 0;

  final amountTitle = isCredit
      ? loc.electricCreditBalance
      : loc.electricOutstandingAmount;

  final amountColor = isCredit
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
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.electricBillInformation,
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontSize: 31,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InformationItem(
                icon: isCredit
                    ? Icons
                        .account_balance_wallet_rounded
                    : Icons.credit_card_rounded,
                label: amountTitle,
                value: _formatAmount(
                  bill.outstandingAmount,
                ),
                valueColor: amountColor,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: _InformationItem(
                icon:
                    Icons.calendar_month_rounded,
                label: loc.electricDueDate,
                value: bill.dueDate.trim().isEmpty
                    ? '-'
                    : bill.dueDate,
              ),
            ),
          ],
        ),
        if (bill.customerName
            .trim()
            .isNotEmpty) ...[
          const Divider(height: 28),
          _InformationItem(
            icon:
                Icons.person_outline_rounded,
            label: loc.electricCustomerName,
            value: bill.customerName,
          ),
        ],
        if (bill.customerAddress
            .trim()
            .isNotEmpty) ...[
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 22),
          _InformationItem(
            icon: Icons.home_outlined,
            label: loc.electricServiceAddress,
            value: bill.customerAddress,
          ),
        ],
        if (isCredit) ...[
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F4),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons
                      .check_circle_outline_rounded,
                  color: Color(0xFF138A72),
                  size: 32,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    loc.electricCreditNotice,
                    style: const TextStyle(
                      color:
                          Color(0xFF096B59),
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w700,
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
        loc.electricAccountNumber,
        style: const TextStyle(
          color: Color(0xFF102A43),
          fontSize: 27,
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
        loc.electricSelectPaymentAmount,
        style: const TextStyle(
          color: Color(0xFF102A43),
          fontSize: 27,
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
          color: const Color(0xFFEAF4FF),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF90CAF9),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.keyboard_alt_outlined,
              color: Color(0xFF1565C0),
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                loc.electricAmountInstruction,
                style: const TextStyle(
                  color: Color(0xFF0D47A1),
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
              fontSize: 30,
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
                          const Color(0xFF1976D2),
                      width: 3,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        color:
                            Color(0xFF1976D2),
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
              label: loc.electricFull,
              emphasized: true,
              onPressed:
                  _setFullOutstandingAmount,
            ),
        ],
      ),
    ],
  );
}

String _getBillUpdateTime(
  AppLocalizations loc,
) {
  final productCode =
      bill.productCode.trim().toUpperCase();

  switch (productCode) {
    // TNB: instant update
    case 'TNB':
      return loc.electricUpdateInstant;

    // Sabah Electricity: instant update
    case 'SESB':
    case 'SABAH ELECTRICITY':
      return loc.electricUpdateInstant;

    // Sarawak Energy: update within 3 days
    case 'SESCO':
    case 'SEB':
    case 'SARAWAK ENERGY':
      return loc.electricUpdateWithinThreeDays;

    // NUR Power: update within 3 days
    case 'NUR':
    case 'NUR POWER':
      return loc.electricUpdateWithinThreeDays;

    // Safe fallback
    default:
      return loc.electricUpdateWithinThreeDays;
  }
}

  Widget _buildOrderSummary() {
    final loc = AppLocalizations.of(context)!;

    final billUpdateTime = _getBillUpdateTime(
      loc,
    );

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
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.electricOrderSummary,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 25),

          _SummaryRow(
            label: bill.billerName,
            value: _formatAmount(
              _selectedAmount,
            ),
          ),

          const Divider(height: 38),

          _SummaryRow(
            label: loc.electricServiceFee,
            value: _formatAmount(
              _serviceFee,
            ),
          ),

          const Divider(height: 38),

          _SummaryRow(
            label: loc.electricTotalAmount,
            value: _formatAmount(
              _totalAmount,
            ),
            isTotal: true,
          ),

          const Divider(height: 38),

          _SummaryRow(
            label: loc.electricPaymentUpdateTime,
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
            onPressed: () {
              _closeKeyboard();
              Navigator.pop(context);
            },
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
            style:
                ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
              side: const BorderSide(
                color: Color(0xFFD5DCE5),
                width: 2,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
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
            onPressed: _handleContinue,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              size: 34,
            ),
            label: Text(
              loc.electricContinue,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 3,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
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
                  fontSize: 21,
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
                  fontSize: 25,
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
                  0xFF1976D2,
                )
              : Colors.white,
          side: BorderSide(
            color: emphasized
                ? const Color(
                    0xFF1976D2,
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
              color: isTotal
                  ? const Color(
                      0xFF102A43,
                    )
                  : const Color(
                      0xFF63758A,
                    ),
              fontSize:
                  isTotal ? 27 : 22,
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
            color: isTotal
                ? const Color(
                    0xFF2E7D32,
                  )
                : const Color(
                    0xFF102A43,
                  ),
            fontSize:
                isTotal ? 29 : 23,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }
}