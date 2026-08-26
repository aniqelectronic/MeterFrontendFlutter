import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/model/telco/telco_bill_model.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/bil_qr_payment_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

class P5TelcoBillResultPage extends StatefulWidget {
  final TelcoBillModel bill;
  final String providerImageUrl;
  final CatalogPricing catalogPricing;

  const P5TelcoBillResultPage({
    super.key,
    required this.bill,
    required this.providerImageUrl,
    required this.catalogPricing,
  });

  @override
  State<P5TelcoBillResultPage> createState() =>
      _P5TelcoBillResultPageState();
}

class _P5TelcoBillResultPageState extends State<P5TelcoBillResultPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _amountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // PAYMENT SETTINGS
  // ============================================================

  double _minimumAmount = 1.00;
  double _maximumAmount = 10000.00;

  static const double _amountStep = 1.00;

  bool _isCatalogLimitLoading = true;

  String _processingTime = '';

  double _selectedAmount = 1.00;

  // 0 = Review bill
  // 1 = Select payment amount
  int _currentStep = 0;

  // ============================================================
  // SHORTCUTS
  // ============================================================

  TelcoBillModel get bill => widget.bill;

  double get _outstandingAmount {
    return bill.outstanding > 0 ? bill.outstanding : 0.0;
  }

  // ============================================================
  // CATALOG PRICING
  // ============================================================

  BillPricingResult get _pricingResult => BillPricingResult.calculate(
        billAmount: _selectedAmount,
        pricing: widget.catalogPricing,
      );

  double get _totalAmount => _pricingResult.totalAmount;

  bool get _hasProviderDiscount =>
      _pricingResult.providerDiscountAmount.abs() >= 0.005;

  bool get _hasPriceAdjustment =>
      _pricingResult.platformAdjustmentAmount.abs() >= 0.005;

  // ============================================================
  // LIFE CYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    final initialAmount =
        _getInitialPaymentAmount();

    _selectedAmount = initialAmount;

    _updateAmountController(
      initialAmount,
    );

    _loadTelcoPaymentLimits();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _loadTelcoPaymentLimits() async {
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
        bill.productCode
            .trim()
            .toUpperCase();

    final dynamic rawProduct =
        products[productCode];

    if (rawProduct is! Map) {
      throw Exception(
        'Telco product $productCode '
        'was not found in catalog.',
      );
    }

    final Map<String, dynamic> product =
        Map<String, dynamic>.from(
      rawProduct,
    );

    final String processingTime =
    product['processing_time']
            ?.toString()
            .trim() ??
        '';

    double minimum = 0;
    double maximum = 0;

    // ==========================================================
    // PRIMARY:
    // fields -> amount -> validation -> min / max
    // ==========================================================

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

    // ==========================================================
    // FALLBACK:
    // denomination = "1-1000", "5-500", etc.
    // ==========================================================

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

      if (_outstandingAmount > 0) {
        newAmount =
            _outstandingAmount;
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
      'TELCO PAYMENT LIMIT LOADED',
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
      '[TELCO] Catalog payment-limit error: '
      '$error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    if (!mounted) {
      return;
    }

    // Same fallback as your other bill pages.
    setState(() {
      _minimumAmount = 1.00;
      _maximumAmount = 10000.00;

      _processingTime = '';

      _isCatalogLimitLoading =
          false;

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

  // ============================================================
  // INITIAL PAYMENT AMOUNT
  // ============================================================

  double _getInitialPaymentAmount() {
    if (_outstandingAmount > 0) {
      return _outstandingAmount.clamp(
        _minimumAmount,
        _maximumAmount,
      );
    }

    // If IIMMPACT returns Outstanding = 0,
    // start payment amount at RM1.
    return _minimumAmount;
  }

  // ============================================================
  // FORMATTERS
  // ============================================================

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

  // ============================================================
  // PAYMENT AMOUNT
  // ============================================================

  void _updateAmountController(double amount) {
    _amountController.text = _formatInputAmount(amount);

    _amountController.selection = TextSelection.fromPosition(
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
    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount >= _maximumAmount) {
      _showMessage(
        loc.telcoMaximumPayment(
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
    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount <= _minimumAmount) {
      _showMessage(
        loc.telcoMinimumPayment(
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
    _setPaymentAmount(amount);
  }

void _setOutstandingAmount() {
  final loc =
      AppLocalizations.of(context)!;

  if (_outstandingAmount <= 0) {
    _showMessage(
      loc.telcoNoOutstandingBalance,
    );

    return;
  }

  if (_outstandingAmount >
      _maximumAmount) {
    _showMessage(
      loc.electricOutstandingExceedsMaximum(
        _formatAmount(
          _outstandingAmount,
        ),
        _formatAmount(
          _maximumAmount,
        ),
      ),
    );

    return;
  }

  if (_outstandingAmount <
      _minimumAmount) {
    _showMessage(
      loc.telcoMinimumPayment(
        _formatAmount(
          _minimumAmount,
        ),
      ),
    );

    return;
  }

  _setPaymentAmount(
    _outstandingAmount,
  );
}

  // ============================================================
  // PAGE STEP
  // ============================================================

  void _goToPaymentStep() {
    setState(() {
      _currentStep = 1;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _handleBack() {
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

  // ============================================================
  // QR PAYMENT
  // ============================================================

  Future<void> _handleContinue() async {
    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount < _minimumAmount) {
      _showMessage(
        loc.telcoMinimumPayment(
          _formatAmount(_minimumAmount),
        ),
      );

      return;
    }

    if (_selectedAmount > _maximumAmount) {
      _showMessage(
        loc.telcoMaximumPayment(
          _formatAmount(_maximumAmount),
        ),
      );

      return;
    }

    final result = await Navigator.push<BilQrPaymentResult>(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '/payment',
        ),
            builder: (_) => BilQrPaymentPage(
              // ==========================================================
              // IMPORTANT
              //
              // Tell the shared payment/receipt flow that this is
              // Telco Postpaid.
              //
              // The receipt page will:
              // - use Telco receipt information;
              // - NOT generate the e-receipt QR yet.
              //
              // Other bill services do not set this.
              // ==========================================================

              useTelcoReceipt: true,

              billType: bill.billerName,
              billCode: bill.productCode,
              accountNumber: bill.accountNumber,

              // Amount sent to IIMMPACT/provider.
              billAmount: _selectedAmount,

              // Amount customer pays after catalog pricing.
              totalAmount: _totalAmount,
            ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    debugPrint('========================================');
    debugPrint('TELCO QR PAYMENT SUCCESS');
    debugPrint('========================================');
    debugPrint('Provider         : ${result.billType}');
    debugPrint('Product Code     : ${result.billCode}');
    debugPrint('Account          : ${result.accountNumber}');
    debugPrint('Bill Amount      : ${result.billAmount}');
    debugPrint('Total Charged    : ${result.totalAmount}');
    debugPrint('Order No         : ${result.orderNo}');
    debugPrint('Bank Transaction : ${result.bankTransactionNo}');
    debugPrint('========================================');

    // ==========================================================
    // NEXT STEP
    // ==========================================================
    //
    // After PegePay payment succeeds, connect the IIMMPACT
    // Telco bill-payment API here.
    //
    // Provider amount:
    // result.billAmount
    //
    // Customer charged:
    // result.totalAmount
    //
    // Do NOT send totalAmount as the provider bill amount.
    // ==========================================================
  }

  // ============================================================
  // INFORMATION POPUP
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: loc.telcoInformation,
      barrierColor: const Color(0xFF052E2B).withOpacity(0.72),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.88,
              end: 1,
            ).animate(curved),
            child: child,
          ),
        );
      },
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
                padding: const EdgeInsets.all(42),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color: const Color(0xFF8DD8C1),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 45,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 125,
                      height: 125,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2AC69B),
                            Color(0xFF087456),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),

                    const SizedBox(height: 26),

                    Text(
                      loc.telcoInformation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF075B47),
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FAF7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4E5968),
                          fontSize: 33,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 88,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          size: 35,
                        ),
                        label: Text(
                          loc.telcoDone,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15946B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
    );
  }

  // ============================================================
  // CUSTOM PAYMENT AMOUNT KEYPAD
  // ============================================================

  void _openCustomAmountKeyboard() {
    final loc = AppLocalizations.of(context)!;

    String temporaryValue = _amountController.text;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: loc.telcoEnterPaymentAmount,
      barrierColor: Colors.black.withOpacity(0.58),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.88,
              end: 1,
            ).animate(curved),
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
            void updateValue(String value) {
              temporaryValue = value;

              setKeyboardState(() {});
            }

            void pressNumber(String number) {
            if (temporaryValue ==
                    _minimumAmount.toStringAsFixed(2) ||
                temporaryValue == '0.00') {
                updateValue(number);
                return;
              }

              if (temporaryValue.contains('.')) {
                final parts = temporaryValue.split('.');

                if (parts.length > 1 && parts.last.length >= 2) {
                  return;
                }
              }

              final prospective = '$temporaryValue$number';

              final parsed = double.tryParse(prospective);

              if (parsed != null && parsed > _maximumAmount) {
                return;
              }

              if (prospective.length > 8) {
                return;
              }

              updateValue(prospective);
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

              updateValue(
                temporaryValue.substring(
                  0,
                  temporaryValue.length - 1,
                ),
              );
            }

            void pressClear() {
              updateValue('');
            }

            void pressDone() {
              final parsed =
                  double.tryParse(temporaryValue) ?? 0;

              if (parsed < _minimumAmount) {
                _setPaymentAmount(_minimumAmount);
              } else {
                _setPaymentAmount(
                  parsed.clamp(
                    _minimumAmount,
                    _maximumAmount,
                  ),
                );
              }

              Navigator.pop(dialogContext);
            }

            return Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Center(
                  child: Container(
                    width: 820,
                    margin: const EdgeInsets.all(35),
                    padding: const EdgeInsets.all(38),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.30),
                          blurRadius: 40,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ==================================================
                          // KEYPAD HEADER
                          // ==================================================

                          Row(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2F7F0),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.dialpad_rounded,
                                  color: Color(0xFF15946B),
                                  size: 40,
                                ),
                              ),

                              const SizedBox(width: 18),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.telcoEnterPaymentAmount,
                                      style: const TextStyle(
                                        color: Color(0xFF102A43),
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      loc.telcoKeypadInstruction,
                                      style: const TextStyle(
                                        color: Color(0xFF60758D),
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 38,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // AMOUNT DISPLAY
                          // ==================================================

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 25,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFF15946B),
                                width: 3,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'RM',
                                  style: TextStyle(
                                    color: Color(0xFF53677E),
                                    fontSize: 39,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(width: 20),

                                Expanded(
                                  child: Text(
                                    temporaryValue.isEmpty
                                        ? '0.00'
                                        : temporaryValue,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Color(0xFF102A43),
                                      fontSize: 54,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

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
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          _keypadRow(
                            ['1', '2', '3'],
                            pressNumber,
                          ),

                          _keypadRow(
                            ['4', '5', '6'],
                            pressNumber,
                          ),

                          _keypadRow(
                            ['7', '8', '9'],
                            pressNumber,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: _keyboardButton(
                                  '.',
                                  pressDecimal,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: _keyboardButton(
                                  '0',
                                  () {
                                    pressNumber('0');
                                  },
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: _keyboardIconButton(
                                  Icons.backspace_outlined,
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
                                  child: OutlinedButton.icon(
                                    onPressed: pressClear,
                                    icon: const Icon(
                                      Icons.delete_sweep_rounded,
                                    ),
                                    label: Text(
                                      loc.telcoClear,
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 18),

                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 78,
                                  child: ElevatedButton.icon(
                                    onPressed: pressDone,
                                    icon: const Icon(
                                      Icons.check_circle_rounded,
                                      size: 30,
                                    ),
                                    label: Text(
                                      loc.telcoDone,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF15946B),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            height: 68,
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                              ),
                              label: Text(
                                loc.telcoCancel,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
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

  // ============================================================
  // KEYPAD HELPERS
  // ============================================================

  Widget _keypadRow(
    List<String> values,
    void Function(String) onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        children: [
          for (int i = 0; i < values.length; i++) ...[
            Expanded(
              child: _keyboardButton(
                values[i],
                () {
                  onPressed(values[i]);
                },
              ),
            ),
            if (i < values.length - 1)
              const SizedBox(
                width: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _keyboardButton(
    String text,
    VoidCallback onPressed,
  ) {
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
          text,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _keyboardIconButton(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 92,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF3E0),
          foregroundColor: const Color(0xFFE65100),
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

  // ============================================================
  // MAIN PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // ====================================================
          // BACKGROUND
          // ====================================================

          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.07),
            ),
          ),

          // ====================================================
          // HEADER
          // ====================================================

          Positioned(
            top: 50,
            left: 70,
            right: 70,
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF075B47),
                    Color(0xFF15946B),
                    Color(0xFF2AC69B),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF075B47).withOpacity(0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.smartphone_rounded,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),

                  const SizedBox(width: 22),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.telcoBillPayment,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          bill.billerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 115,
                    height: 80,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Image.network(
                      widget.providerImageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.sim_card_rounded,
                          color: Color(0xFF15946B),
                          size: 45,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ====================================================
          // CONTENT
          // ====================================================

          Positioned(
            top: 200,
            left: 65,
            right: 65,
            bottom: 175,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: _currentStep == 0
                  ? _buildReviewStep(loc)
                  : _buildPaymentStep(loc),
            ),
          ),

          // ====================================================
          // BOTTOM BUTTONS
          // ====================================================

          Positioned(
            bottom: 65,
            left: 70,
            right: 70,
            child: Row(
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
                        : (_isCatalogLimitLoading
                            ? null
                            : _handleContinue),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 34,
                      ),
                      label: Text(
                        loc.buttonContinue,
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
            ),
          ),

          // ====================================================
          // COPYRIGHT
          // ====================================================

          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Text(
              Data.copyrightText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 1 - REVIEW BILL
  // ============================================================

  Widget _buildReviewStep(
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        _buildStepHeading(
          icon: Icons.fact_check_rounded,
          title: loc.telcoReviewBillDetails,
          subtitle: loc.telcoReviewBillSubtitle,
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFA8DCCB),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // ==================================================
              // PROVIDER
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 160,
                    height: 110,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.black12,
                      ),
                    ),
                    child: Image.network(
                      widget.providerImageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.sim_card_rounded,
                          color: Color(0xFF15946B),
                          size: 65,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 25),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.telcoServiceProvider,
                          style: const TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          bill.billerName,
                          style: const TextStyle(
                            color: Color(0xFF102A43),
                            fontSize: 39,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4F7F0),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            loc.telcoAccountVerified,
                            style: const TextStyle(
                              color: Color(0xFF087456),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _infoCard(
                icon: Icons.phone_android_rounded,
                label: loc.telcoAccountMobileNumber,
                value: bill.accountNumber,
              ),

              const SizedBox(height: 15),

              _infoCard(
                icon: Icons.account_balance_wallet_rounded,
                label: loc.telcoOutstandingBalance,
                value: _formatAmount(_outstandingAmount),
                highlight: true,
              ),

              if (bill.customerName.isNotEmpty) ...[
                const SizedBox(height: 15),

                _infoCard(
                  icon: Icons.person_rounded,
                  label: loc.telcoCustomerName,
                  value: bill.customerName,
                ),
              ],

              if (bill.dueDate.isNotEmpty) ...[
                const SizedBox(height: 15),

                _infoCard(
                  icon: Icons.event_rounded,
                  label: loc.telcoDueDate,
                  value: bill.dueDate,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFFD54F),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFF57F17),
                size: 35,
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Text(
                  loc.telcoPaymentAmountNextInfo,
                  style: const TextStyle(
                    color: Color(0xFF6D5711),
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2 - SELECT PAYMENT AMOUNT
  // ============================================================

  Widget _buildPaymentStep(
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        _buildStepHeading(
          icon: Icons.payments_rounded,
          title: loc.telcoChoosePaymentAmount,
          subtitle: loc.telcoChoosePaymentSubtitle,
        ),

        const SizedBox(height: 25),

        // ======================================================
        // AMOUNT TO PAY
        // ======================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF075B47),
                Color(0xFF15946B),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              Text(
                loc.telcoAmountToPay,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _formatAmount(_selectedAmount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 62,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // ======================================================
        // AMOUNT SELECTOR
        // ======================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFA8DCCB),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.telcoSelectPaymentAmount,
                style: const TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFA8DCCB),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.keyboard_alt_outlined,
                      color: Color(0xFF087456),
                      size: 34,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        loc.electricAmountInstruction,
                        style: const TextStyle(
                          color: Color(0xFF075B47),
                          fontSize: 23,
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
                children: [
                  SizedBox(
                    width: 90,
                    height: 82,
                    child: ElevatedButton(
                      onPressed: _decreaseAmount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F5F0),
                        foregroundColor: const Color(0xFF087456),
                        elevation: 0,
                      ),
                      child: const Icon(
                        Icons.remove_rounded,
                        size: 42,
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: GestureDetector(
                      onTap: _isCatalogLimitLoading
                        ? null
                        : _openCustomAmountKeyboard,
                      child: Container(
                        height: 82,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFA),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF15946B),
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'RM',
                              style: TextStyle(
                                color: Color(0xFF53677E),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Text(
                                _selectedAmount.toStringAsFixed(2),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF102A43),
                                  fontSize: 39,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.dialpad_rounded,
                              color: Color(0xFF15946B),
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  SizedBox(
                    width: 90,
                    height: 82,
                    child: ElevatedButton(
                      onPressed: _increaseAmount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15946B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 42,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // QUICK AMOUNTS
              // ==================================================

              Row(
                children: [
                  _quickAmountButton(10),
                  const SizedBox(width: 12),
                  _quickAmountButton(30),
                  const SizedBox(width: 12),
                  _quickAmountButton(50),
                  const SizedBox(width: 12),
                  _quickAmountButton(100),
                ],
              ),

              if (_outstandingAmount > 0) ...[
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: OutlinedButton.icon(
                    onPressed: _setOutstandingAmount,
                    icon: const Icon(
                      Icons.account_balance_wallet_rounded,
                    ),
                    label: Text(
                      '${loc.telcoPayFullOutstanding}  '
                      '${_formatAmount(_outstandingAmount)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF087456),
                      side: const BorderSide(
                        color: Color(0xFF15946B),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 25),

        _buildOrderSummary(loc),

        const SizedBox(height: 20),
      ],
    );
  }

  String _getTelcoUpdateTime(
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

  if (value == 'instant' ||
      value == 'immediate') {
    return loc
        .telcoUpdateInstant
        .toUpperCase();
  }

  final RegExpMatch? hoursMatch =
      RegExp(
    r'^(\d+)_hours?$',
  ).firstMatch(value);

  if (hoursMatch != null) {
    final String hours =
        hoursMatch.group(1) ?? '';

    return loc
        .telcoUpdateWithinHours(
          hours,
        )
        .toUpperCase();
  }

  final RegExpMatch? daysMatch =
      RegExp(
    r'^(\d+)_days?$',
  ).firstMatch(value);

  if (daysMatch != null) {
    final String days =
        daysMatch.group(1) ?? '';

    return loc
        .telcoUpdateWithinDays(
          days,
        )
        .toUpperCase();
  }

  return _processingTime
      .replaceAll('_', ' ')
      .toUpperCase();
}

  // ============================================================
  // ORDER SUMMARY
  // ============================================================

  Widget _buildOrderSummary(
    AppLocalizations loc,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD6E6E0),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF15946B),
                size: 34,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  loc.telcoOrderSummary,
                  style: const TextStyle(
                    color: Color(0xFF102A43),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          _summaryRow(
            bill.billerName,
            _formatAmount(_selectedAmount),
          ),

          // ====================================================
          // PROVIDER DISCOUNT FROM /v2/catalog
          // ====================================================

          if (_hasProviderDiscount) ...[
            const SizedBox(height: 15),

            _summaryRow(
              loc.telcoServiceFee,
              _formatSignedAmount(
                _pricingResult.providerDiscountAmount,
              ),
              valueColor:
                  _pricingResult.providerDiscountAmount < 0
                      ? const Color(0xFF16813B)
                      : null,
            ),
          ],

          // ====================================================
          // SERVICE ADJUSTMENT FROM /v2/catalog
          // ====================================================

          if (_hasPriceAdjustment) ...[
            const SizedBox(height: 15),

            _summaryRow(
              loc.telcoServiceAdjustment,
              _formatSignedAmount(
                _pricingResult.platformAdjustmentAmount,
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 22,
            ),
            child: Divider(
              height: 1,
              thickness: 2,
            ),
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  loc.telcoTotalPayment,
                  style: const TextStyle(
                    color: Color(0xFF102A43),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              Text(
                _formatAmount(_totalAmount),
                style: const TextStyle(
                  color: Color(0xFF087456),
                  fontSize: 43,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: Divider(
              height: 1,
              thickness: 1.5,
            ),
          ),

          _summaryRow(
            loc.telcoPaymentUpdateTime,
            _getTelcoUpdateTime(
              loc,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF15946B),
                  size: 27,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    loc.telcoLatestPricingInfo,
                    style: const TextStyle(
                      color: Color(0xFF4C6A60),
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP HEADING
  // ============================================================

  Widget _buildStepHeading({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 27,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE4F7F0),
            Color(0xFFF8FFFC),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF8DD8C1),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFF15946B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 42,
            ),
          ),

          const SizedBox(width: 23),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF102A43),
                    fontSize: 39,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF53677E),
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFE9F8F2)
            : const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(20),
        border: highlight
            ? Border.all(
                color: const Color(0xFF8DD8C1),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5EE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF15946B),
              size: 31,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    color: highlight
                        ? const Color(0xFF087456)
                        : const Color(0xFF102A43),
                    fontSize: highlight ? 38 : 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK AMOUNT BUTTON
  // ============================================================

  Widget _quickAmountButton(double amount) {
    final selected =
        (_selectedAmount - amount).abs() < 0.005;

    return Expanded(
      child: SizedBox(
        height: 68,
        child: ElevatedButton(
          onPressed: () {
            _setQuickAmount(amount);
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: selected
                ? const Color(0xFF15946B)
                : const Color(0xFFE9F7F2),
            foregroundColor: selected
                ? Colors.white
                : const Color(0xFF087456),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'RM${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF53677E),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 20),

        Text(
          value,
          style: TextStyle(
            color: valueColor ??
                const Color(0xFF102A43),
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
