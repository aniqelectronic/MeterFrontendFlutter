import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/broadband/broadband_bill_model.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/bil_qr_payment_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

class P5BroadbandBillResultPage extends StatefulWidget {
  final BroadbandBillModel bill;
  final CatalogPricing catalogPricing;

  const P5BroadbandBillResultPage({
    super.key,
    required this.bill,
    required this.catalogPricing,
  });

  @override
  State<P5BroadbandBillResultPage> createState() =>
      _P5BroadbandBillResultPageState();
}

class _P5BroadbandBillResultPageState
    extends State<P5BroadbandBillResultPage> {
    double _minimumAmount = 1.00;
    double _maximumAmount = 10000.00;

    static const double _amountStep = 1.00;

    bool _isCatalogLimitLoading = true;

    String _processingTime = '';

  final TextEditingController _amountController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  double _selectedAmount = 1.00;

  // Step 0: review bill details
  // Step 1: choose payment amount
  int _currentStep = 0;

  BroadbandBillModel get bill => widget.bill;

  BillPricingResult get _pricingResult =>
      BillPricingResult.calculate(
        billAmount: _selectedAmount,
        pricing: widget.catalogPricing,
      );

  double get _totalAmount =>
      _pricingResult.totalAmount;

  @override
  void initState() {
    super.initState();

    final initialAmount =
        _getInitialPaymentAmount();

    _selectedAmount = initialAmount;
    _updateAmountController(initialAmount);

    _loadBroadbandPaymentLimits();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double _getInitialPaymentAmount() {
  if (bill.outstandingAmount > 0) {
    return bill.outstandingAmount.clamp(
      _minimumAmount,
      _maximumAmount,
    );
  }

  return _minimumAmount;
}

// ==========================================================================
// LOAD BROADBAND PAYMENT LIMIT FROM IIMMPACT CATALOG
// ==========================================================================

Future<void> _loadBroadbandPaymentLimits() async {
  try {
    final Map<String, dynamic> catalog =
        await IimmpactCatalogService.getCatalog();

    final dynamic productsRaw =
        catalog['products'];

    if (productsRaw is! Map) {
      throw Exception(
        'Catalog products object is missing.',
      );
    }

    final Map<String, dynamic> products =
        Map<String, dynamic>.from(
      productsRaw,
    );

    final String productCode =
        bill.productCode.trim().toUpperCase();

    final dynamic rawProduct =
        products[productCode];

    if (rawProduct is! Map) {
      throw Exception(
        'Broadband product $productCode '
        'was not found in catalog.',
      );
    }

    final Map<String, dynamic> product =
        Map<String, dynamic>.from(
      rawProduct,
    );

    // ======================================================================
    // PROCESSING TIME
    // Loaded dynamically from IIMMPACT catalog.
    // Examples:
    // instant
    // 24_hours
    // 3_days
    // ======================================================================

    final String processingTime =
        product['processing_time']
                ?.toString()
                .trim() ??
            '';

    double minimum = 0;
    double maximum = 0;

    // ======================================================================
    // PRIMARY:
    // fields -> amount -> validation -> min/max
    // ======================================================================

    final dynamic fieldsRaw =
        product['fields'];

    if (fieldsRaw is List) {
      for (final rawField in fieldsRaw) {
        if (rawField is! Map) {
          continue;
        }

        final Map<String, dynamic> field =
            Map<String, dynamic>.from(
          rawField,
        );

        final String fieldId =
            field['id']
                    ?.toString()
                    .trim()
                    .toLowerCase() ??
                '';

        if (fieldId != 'amount') {
          continue;
        }

        final dynamic validationRaw =
            field['validation'];

        if (validationRaw is! Map) {
          continue;
        }

        final Map<String, dynamic> validation =
            Map<String, dynamic>.from(
          validationRaw,
        );

        minimum = _toDouble(
          validation['min'],
        );

        maximum = _toDouble(
          validation['max'],
        );

        break;
      }
    }

    // ======================================================================
    // FALLBACK:
    // denomination = "1-1000", "5-500", etc.
    // ======================================================================

    if (minimum <= 0 ||
        maximum <= 0) {
      final String denomination =
          product['denomination']
                  ?.toString()
                  .trim() ??
              '';

      final range =
          _parseAmountRange(
        denomination,
      );

      if (minimum <= 0) {
        minimum = range.$1;
      }

      if (maximum <= 0) {
        maximum = range.$2;
      }
    }

    if (minimum <= 0 ||
        maximum <= 0 ||
        maximum < minimum) {
      throw Exception(
        'Invalid payment limits for '
        '$productCode.',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _minimumAmount = minimum;
      _maximumAmount = maximum;

      _processingTime =
          processingTime;

      double newAmount =
          _selectedAmount;

      if (bill.outstandingAmount > 0) {
        newAmount =
            bill.outstandingAmount;
      }

      if (newAmount <
          _minimumAmount) {
        newAmount =
            _minimumAmount;
      }

      if (newAmount >
          _maximumAmount) {
        newAmount =
            _maximumAmount;
      }

      _selectedAmount =
          newAmount;

      _updateAmountController(
        newAmount,
      );

      _isCatalogLimitLoading =
          false;
    });

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'BROADBAND PAYMENT LIMIT LOADED',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'Product : $productCode',
    );
    debugPrint(
      'Minimum : RM ${minimum.toStringAsFixed(2)}',
    );
    debugPrint(
      'Maximum : RM ${maximum.toStringAsFixed(2)}',
    );
    debugPrint(
      'Processing Time : $processingTime',
    );
    debugPrint(
      '========================================',
    );
    debugPrint('');
  } catch (error, stackTrace) {
    debugPrint(
      '[BROADBAND] Catalog payment-limit error: '
      '$error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    if (!mounted) {
      return;
    }

    // Same fallback strategy as Electric / Water.
    setState(() {
      _minimumAmount = 1.00;
      _maximumAmount = 10000.00;

      _processingTime = '';

      _isCatalogLimitLoading = false;

      final fallbackAmount =
          _getInitialPaymentAmount();

      _selectedAmount =
          fallbackAmount;

      _updateAmountController(
        fallbackAmount,
      );
    });
  }
}

double _toDouble(
  dynamic value,
) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

(double, double) _parseAmountRange(
  String value,
) {
  final List<String> parts =
      value.split('-');

  if (parts.length != 2) {
    return (
      0,
      0,
    );
  }

  return (
    double.tryParse(
          parts[0].trim(),
        ) ??
        0,
    double.tryParse(
          parts[1].trim(),
        ) ??
        0,
  );
}

  String _formatAmount(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
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
        loc.broadbandMaximumPayment(
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
        loc.broadbandMinimumPayment(
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
        loc.broadbandMinimumPayment(
          _formatAmount(_minimumAmount),
        ),
      );
      return;
    }

    if (_selectedAmount > _maximumAmount) {
      _showMessage(
        loc.broadbandMaximumPayment(
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
          // Unifi, Maxis Fibre, CelcomDigi Fibre,
          // TIME Internet or Astro Fibre.
          billType: bill.billerName,

          // Provider/product code from the inquiry result.
          billCode: bill.productCode,

          accountNumber: bill.accountNumber,

          // Actual amount selected for the broadband provider.
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
      '[BROADBAND BILL] QR payment successful',
    );
    debugPrint(
      '[BROADBAND BILL] Bill type: ${result.billType}',
    );
    debugPrint(
      '[BROADBAND BILL] Bill code: ${result.billCode}',
    );
    debugPrint(
      '[BROADBAND BILL] Account: ${result.accountNumber}',
    );
    debugPrint(
      '[BROADBAND BILL] Bill amount: ${result.billAmount}',
    );
    debugPrint(
      '[BROADBAND BILL] Total charged: ${result.totalAmount}',
    );
    debugPrint(
      '[BROADBAND BILL] Order number: ${result.orderNo}',
    );
    debugPrint(
      '[BROADBAND BILL] Bank transaction: '
      '${result.bankTransactionNo}',
    );

    /*
    NEXT STEP:

    Call your broadband bill payment API here.

    Example:

    final success =
        await BroadbandBillService.payBill(
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
      barrierLabel: loc.broadbandInformation,
      barrierColor: const Color(0xFF07182E).withOpacity(0.72),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 760,
                margin: const EdgeInsets.symmetric(horizontal:70,vertical:120),
                padding: const EdgeInsets.fromLTRB(46,42,46,40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(color: const Color(0xFFE1BEE7),width:3),
                  boxShadow:[
                    BoxShadow(color: Colors.black.withOpacity(0.35),blurRadius:45,offset: const Offset(0,22)),
                    BoxShadow(color: const Color(0xFF6A1B9A).withOpacity(0.24),blurRadius:55,spreadRadius:4),
                  ],
                ),
                child: Column(mainAxisSize: MainAxisSize.min,children:[
                  Container(
                    width:130,height:130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors:[Color(0xFFAB47BC),Color(0xFF4A148C)]),
                      boxShadow:[BoxShadow(color: const Color(0xFF6A1B9A).withOpacity(0.30),blurRadius:24,spreadRadius:3)],
                    ),
                    child: const Icon(Icons.info_outline_rounded,color: Colors.white,size:72),
                  ),
                  const SizedBox(height:28),
                  Text(loc.broadbandInformation,textAlign: TextAlign.center,style: const TextStyle(color: Color(0xFF4A148C),fontSize:46,fontWeight:FontWeight.w900)),
                  const SizedBox(height:16),
                  Container(width:120,height:6,decoration: BoxDecoration(
                    gradient: const LinearGradient(colors:[Color(0xFFAB47BC),Color(0xFF4A148C)]),
                    borderRadius: BorderRadius.circular(20),
                  )),
                  const SizedBox(height:28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal:30,vertical:28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F1FC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE1BEE7),width:2),
                    ),
                    child: Text(message,textAlign: TextAlign.center,style: const TextStyle(color: Color(0xFF4E5968),fontSize:31,fontWeight:FontWeight.w700,height:1.45)),
                  ),
                  const SizedBox(height:34),
                  SizedBox(
                    width: double.infinity,height:92,
                    child: ElevatedButton.icon(
                      onPressed: ()=>Navigator.pop(dialogContext),
                      icon: const Icon(Icons.check_circle_rounded,size:38),
                      label: Text(loc.broadbandOk,style: const TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ),
        );
      },
      transitionBuilder:(context,animation,secondaryAnimation,child){
        final curved=CurvedAnimation(parent: animation,curve: Curves.easeOutBack,reverseCurve: Curves.easeIn);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween<double>(begin:0.82,end:1).animate(curved),child: child),
        );
      },
    );
  }

  void _openCustomAmountKeyboard() {
    _closeKeyboard();

    final loc = AppLocalizations.of(context)!;

    final originalAmount = _selectedAmount;
    String temporaryValue = _amountController.text;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel:
          loc.broadbandEnterPaymentAmount,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration:
          const Duration(milliseconds: 220),
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curvedAnimation =
            CurvedAnimation(
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
            void refreshKeyboard() {
              setKeyboardState(() {});
            }

            void updateTemporaryValue(
              String newValue,
            ) {
              temporaryValue = newValue;
              refreshKeyboard();
            }

            void pressNumber(String number) {
              if (temporaryValue == '0.00' ||
                  temporaryValue == '0') {
                updateTemporaryValue(number);
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

              updateTemporaryValue(
                prospectiveValue,
              );
            }

            void pressDecimal() {
              if (temporaryValue.contains('.')) {
                return;
              }

              if (temporaryValue.isEmpty) {
                updateTemporaryValue('0.');
                return;
              }

              updateTemporaryValue(
                '$temporaryValue.',
              );
            }

            void pressDelete() {
              if (temporaryValue.isEmpty) {
                return;
              }

              updateTemporaryValue(
                temporaryValue.substring(
                  0,
                  temporaryValue.length - 1,
                ),
              );
            }

            void pressClear() {
              updateTemporaryValue('');
            }

            void pressCancel() {
              _selectedAmount = originalAmount;
              _updateAmountController(
                originalAmount,
              );

              Navigator.pop(dialogContext);
            }

            void pressDone() {
              final parsedAmount =
                  double.tryParse(
                        temporaryValue,
                      ) ??
                      0;

              if (parsedAmount <
                  _minimumAmount) {
                Navigator.pop(dialogContext);

                _showMessage(
                  loc.broadbandMinimumPayment(
                    _formatAmount(
                      _minimumAmount,
                    ),
                  ),
                );
                return;
              }

              if (parsedAmount >
                  _maximumAmount) {
                Navigator.pop(dialogContext);

                _showMessage(
                  loc.broadbandMaximumPayment(
                    _formatAmount(
                      _maximumAmount,
                    ),
                  ),
                );
                return;
              }

              _setPaymentAmount(parsedAmount);
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
                        child:
                            SingleChildScrollView(
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
                                        0xFFF3E5F5,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(18),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .keyboard_alt_rounded,
                                      color:
                                          Color(0xFF6A1B9A),
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
                                          loc.broadbandEnterPaymentAmount,
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
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
                                          loc.broadbandAmountInstruction,
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
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
                                    icon:
                                        const Icon(
                                      Icons
                                          .close_rounded,
                                      size: 36,
                                      color:
                                          Color(
                                        0xFF60758D,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 28,
                              ),
                              Container(
                                width:
                                    double.infinity,
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
                                      BorderRadius
                                          .circular(22),
                                  border: Border.all(
                                    color:
                                        const Color(
                                      0xFF6A1B9A,
                                    ),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color(
                                        0xFF6A1B9A,
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
                                      style:
                                          TextStyle(
                                        color:
                                            Color(
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
                                            TextAlign
                                                .right,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .fade,
                                        style:
                                            const TextStyle(
                                          color:
                                              Color(
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
                              const SizedBox(
                                height: 14,
                              ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                loc.electricPaymentRange(
                                  _formatAmount(
                                    _minimumAmount,
                                  ),
                                  _formatAmount(
                                    _maximumAmount,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF60758D),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                              const SizedBox(
                                height: 28,
                              ),
                              _buildNumberRow(
                                first: '1',
                                second: '2',
                                third: '3',
                                onNumberPressed:
                                    pressNumber,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildNumberRow(
                                first: '4',
                                second: '5',
                                third: '6',
                                onNumberPressed:
                                    pressNumber,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildNumberRow(
                                first: '7',
                                second: '8',
                                third: '9',
                                onNumberPressed:
                                    pressNumber,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
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
                              const SizedBox(
                                height: 26,
                              ),
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
                                          loc.keyboardBackspace,
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
                                            color:
                                                Color(
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
                                          loc.broadbandDone,
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
                              const SizedBox(
                                height: 14,
                              ),
                              SizedBox(
                                width:
                                    double.infinity,
                                height: 68,
                                child: TextButton.icon(
                                  onPressed:
                                      pressCancel,
                                  icon: const Icon(
                                    Icons
                                        .close_rounded,
                                    size: 28,
                                  ),
                                  label: Text(
                                    loc.broadbandCancel,
                                    style:
                                        const TextStyle(
                                      fontSize: 21,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
                                  style:
                                      TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.red,
                                    foregroundColor:
                                        Colors.white,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(16),
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

  Widget _buildNumberRow({
    required String first,
    required String second,
    required String third,
    required void Function(String)
        onNumberPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildKeyboardButton(
            label: first,
            onPressed: () {
              onNumberPressed(first);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKeyboardButton(
            label: second,
            onPressed: () {
              onNumberPressed(second);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKeyboardButton(
            label: third,
            onPressed: () {
              onNumberPressed(third);
            },
          ),
        ),
      ],
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
          foregroundColor:
              const Color(0xFF102A43),
          side: const BorderSide(
            color: Color(0xFFD5DEE9),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
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
          backgroundColor:
              const Color(0xFFFFF3E0),
          foregroundColor:
              const Color(0xFFE65100),
          side: const BorderSide(
            color: Color(0xFFFFB46A),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 20,
                      ),
                      child: Scrollbar(
                        controller:
                            _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 12,
                        radius:
                            const Radius.circular(20),
                        interactive: true,
                        child:
                            SingleChildScrollView(
                          controller:
                              _scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior
                                  .onDrag,
                          padding:
                              const EdgeInsets.fromLTRB(
                            70,
                            35,
                            70,
                            20,
                          ),
                          child: AnimatedSwitcher(
                            duration:
                                const Duration(
                              milliseconds: 250,
                            ),
                            switchInCurve:
                                Curves.easeOut,
                            switchOutCurve:
                                Curves.easeIn,
                            child: Container(
                              key: ValueKey<int>(
                                _currentStep,
                              ),
                              padding:
                                  const EdgeInsets.all(
                                35,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.97),
                                borderRadius:
                                    BorderRadius.circular(
                                  30,
                                ),
                                border: Border.all(
                                  color:
                                      const Color(
                                    0xFFE2E8F0,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(
                                      0.08,
                                    ),
                                    blurRadius: 20,
                                    offset:
                                        const Offset(
                                      0,
                                      8,
                                    ),
                                  ),
                                ],
                              ),
                              child:
                                  _currentStep == 0
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .stretch,
                                          children: [
                                            _buildReviewHeading(),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            _buildBillInformationCard(),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            _buildAccountNumberSection(),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .stretch,
                                          children: [
                                            _buildAmountSection(),
                                            const SizedBox(
                                              height: 32,
                                            ),
                                            _buildOrderSummary(),
                                          ],
                                        ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 60,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        _buildActionButtons(),
                        const SizedBox(height: 18),
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
                                Color(0xFF17375E),
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
            Color(0xFF4A148C),
            Color(0xFF6A1B9A),
            Color(0xFFAB47BC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  bill.billerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  loc.broadbandBillPayment,
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
            Icons.router_rounded,
            color: Colors.white,
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewHeading() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFCE93D8),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fact_check_outlined,
            color: Color(0xFF6A1B9A),
            size: 60,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  loc.broadbandReviewDetailsTitle,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.broadbandReviewDetailsSubtitle,
                  style: const TextStyle(
                    fontSize: 24,
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

  Widget _buildBillInformationCard() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFAB47BC),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.08),
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
            loc.broadbandBillInformation,
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          _InformationItem(
            icon:
                Icons.person_outline_rounded,
            label:
                loc.broadbandCustomerName,
            value: bill.customerName,
          ),
          if (bill.customerAddress
              .trim()
              .isNotEmpty) ...[
            const Divider(height: 35),
            _InformationItem(
              icon: Icons.home_outlined,
              label:
                  loc.broadbandServiceAddress,
              value:
                  bill.customerAddress,
            ),
          ],
          if (bill.dueDate
              .trim()
              .isNotEmpty) ...[
            const Divider(height: 35),
            _InformationItem(
              icon:
                  Icons.calendar_month_rounded,
              label: loc.broadbandDueDate,
              value: bill.dueDate,
            ),
          ],
          if (bill.outstandingAmount > 0) ...[
            const Divider(height: 35),
            _InformationItem(
              icon: Icons.payments_rounded,
              label: loc
                  .broadbandOutstandingAmount,
              value: _formatAmount(
                bill.outstandingAmount,
              ),
              valueColor:
                  const Color(0xFF6A1B9A),
            ),
          ],
          const Divider(height: 35),
          _InformationItem(
            icon:
                Icons.verified_user_outlined,
            label:
                loc.broadbandAccountStatus,
            value:
                loc.broadbandAccountValid,
            valueColor:
                const Color(0xFF2E7D32),
          ),
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
          loc.broadbandAccountNumber,
          style: const TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFF6F8FB),
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  const Color(0xFFD4E1F5),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.numbers_rounded,
                size: 32,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  bill.accountNumber,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
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
          loc.broadbandSelectPaymentAmount,
          style: const TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFF3E5F5),
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color:
                  const Color(0xFFCE93D8),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons
                    .keyboard_alt_outlined,
                color:
                    Color(0xFF6A1B9A),
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  loc.broadbandAmountInstruction,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF4A148C),
                    fontSize: 20,
                    height: 1.35,
                    fontWeight:
                        FontWeight.w700,
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
                color:
                    Color(0xFF53677E),
                fontSize: 34,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                onTap: _isCatalogLimitLoading
                    ? null
                    : _openCustomAmountKeyboard,
                  borderRadius:
                      BorderRadius.circular(20),
                  child: Container(
                    height: 95,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 22,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(20),
                      border: Border.all(
                        color:
                            const Color(
                          0xFF6A1B9A,
                        ),
                        width: 3,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .touch_app_rounded,
                          color:
                              Color(
                            0xFF6A1B9A,
                          ),
                          size: 30,
                        ),
                        const SizedBox(
                          width: 14,
                        ),
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
                                  Color(
                                0xFF102A43,
                              ),
                              fontSize: 32,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons
                              .keyboard_alt_rounded,
                          color:
                              Color(
                            0xFF60758D,
                          ),
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            _AmountButton(
              icon: Icons.remove_rounded,
              onPressed: _decreaseAmount,
              backgroundColor:
                  const Color(0xFFFFF3E0),
              foregroundColor:
                  const Color(0xFFE65100),
              borderColor:
                  const Color(0xFFFFB46A),
            ),
            const SizedBox(width: 18),
            _AmountButton(
              icon: Icons.add_rounded,
              onPressed: _increaseAmount,
              backgroundColor:
                  const Color(0xFFE8F5E9),
              foregroundColor:
                  const Color(0xFF2E7D32),
              borderColor:
                  const Color(0xFF66BB6A),
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
                loc.broadbandAmountInstruction,
                style: const TextStyle(
                  color:
                      Color(0xFF60758D),
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          loc.electricPaymentRange(
            _formatAmount(
              _minimumAmount,
            ),
            _formatAmount(
              _maximumAmount,
            ),
          ),
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
            for (final amount
                in [20, 50, 100, 200])
              _QuickAmountButton(
                label: 'RM $amount',
                onPressed: () {
                  _setQuickAmount(
                    amount.toDouble(),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  String _getBroadbandUpdateTime(
  AppLocalizations loc,
) {
  final String value =
      _processingTime
          .trim()
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('-', '_');

  if (value.isEmpty) {
    return '-';
  }

  // instant
  if (value == 'instant' ||
      value == 'immediate') {
    return loc
        .broadbandUpdateInstant
        .toUpperCase();
  }

  // 24_hours, 48_hours, 1_hour, etc.
  final RegExpMatch? hoursMatch =
      RegExp(
    r'^(\d+)_hours?$',
  ).firstMatch(value);

  if (hoursMatch != null) {
    final String hours =
        hoursMatch.group(1) ?? '';

    return loc
        .broadbandUpdateWithinHours(
          hours,
        )
        .toUpperCase();
  }

  // 1_day, 3_days, 5_days, etc.
  final RegExpMatch? daysMatch =
      RegExp(
    r'^(\d+)_days?$',
  ).firstMatch(value);

  if (daysMatch != null) {
    final String days =
        daysMatch.group(1) ?? '';

    return loc
        .broadbandUpdateWithinDays(
          days,
        )
        .toUpperCase();
  }

  // Unknown future catalog value:
  // display the actual value rather than guessing.
  return _processingTime
      .replaceAll('_', ' ')
      .toUpperCase();
}

  Widget _buildOrderSummary() {
    final loc = AppLocalizations.of(context)!;
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
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              loc.broadbandOrderSummary,
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
              pricing.billAmount,
            ),
          ),
          if (pricing
              .hasPlatformAdjustment) ...[
            const Divider(height: 38),
            _SummaryRow(
              label: isServiceFee
                  ? loc.broadbandServiceFee
                  : loc
                      .broadbandServiceAdjustment,
              value: _formatSignedAmount(
                pricing
                    .platformAdjustmentAmount,
              ),
            ),
          ],
          const Divider(height: 38),
          _SummaryRow(
            label:
                loc.broadbandTotalAmount,
            value: _formatAmount(
              pricing.totalAmount,
            ),
            isTotal: true,
          ),
          const Divider(height: 38),
          _SummaryRow(
            label:
                loc.broadbandPaymentUpdateTime,
            value:
                _getBroadbandUpdateTime(
              loc,
            ),
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
            onPressed: _currentStep == 0
                ? _goToPaymentStep
                : (_isCatalogLimitLoading
                    ? null
                    : _handleContinue),
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 34,
              ),
              label: Text(
                loc.broadbandContinue,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
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

class _InformationItem extends StatelessWidget {
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
          size: 34,
          color: const Color(0xFF6D7D90),
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
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
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
  final Color borderColor;

  const _AmountButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
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
          elevation: 0,
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: borderColor,
            width: 3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),
        child: Icon(
          icon,
          size: 55,
        ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickAmountButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              const Color(0xFF4A148C),
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFCE93D8),
            width: 2,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          shape: RoundedRectangleBorder(
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
                ? const Color(0xFF6A1B9A)
                : const Color(0xFF102A43),
            fontSize: isTotal ? 34 : 27,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
