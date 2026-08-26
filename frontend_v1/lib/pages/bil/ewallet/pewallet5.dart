import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/bil_qr_payment_page.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

import 'package:frontend_v1/pages/resit/bill_receipt_page.dart';

// ============================================================================
// E-WALLET PAGE 5
// ============================================================================
//
// TNG PIN
// -------
// PAGE 4:
//   Select PIN denomination.
//
// PAGE 5:
//   Enter phone/reference number.
//   Continue to payment.
//
//
// TNGD / TRUE
// -----------
// PAGE 4:
//   Enter phone number.
//
// PAGE 5:
//   Select / enter reload amount.
//   Continue to payment.
//
// ============================================================================

class PEWALLET5PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;

  /// TNG:
  /// Selected PIN denomination from PAGE 4.
  ///
  /// TNGD / TRUE:
  /// null because amount is entered on PAGE 5.
  final double? selectedAmount;

  /// TNG:
  /// Customer-facing total after catalog price adjustment.
  final double? selectedTotalAmount;

  /// TNG:
  /// null because phone/reference is entered on PAGE 5.
  ///
  /// TNGD / TRUE:
  /// phone already entered on PAGE 4.
  final String? phoneNumber;

  const PEWALLET5PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
    this.selectedAmount,
    this.selectedTotalAmount,
    this.phoneNumber,
  });

  @override
  State<PEWALLET5PAGE> createState() =>
      _PEWALLET5PAGEState();
}

class _PEWALLET5PAGEState extends State<PEWALLET5PAGE> {
  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  // ==========================================================================
  // STATE
  // ==========================================================================

  String? _activeKey;

  bool _isLoading = false;
  bool _isNavigating = false;

  String? _errorMessage;

  Map<String, dynamic>? _product;

  CatalogPricing _catalogPricing =
      CatalogPricing.empty();

  double _minimumAmount = 0;
  double _maximumAmount = 0;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFFEF6C35);

  static const Color _darkColor =
      Color(0xFFD35400);

  static const Color _lightColor =
      Color(0xFFFFA264);

  static const Color _greenColor =
      Color(0xFF2E7D32);

  // ==========================================================================
  // PRODUCT TYPE
  // ==========================================================================

  String get _code =>
      widget.productCode.trim().toUpperCase();

  bool get _isTngPin =>
      _code == 'TNG';

  bool get _isPinless =>
      _code == 'TNGD' ||
      _code == 'TRUE';

  bool get _isTrueMoney =>
      _code == 'TRUE';

  // ==========================================================================
  // VALUES
  // ==========================================================================

  String get _phoneNumber {
    if (_isTngPin) {
      return _phoneController.text.trim();
    }

    return widget.phoneNumber?.trim() ?? '';
  }

  double get _reloadAmount {
    if (_isTngPin) {
      return widget.selectedAmount ?? 0;
    }

    return double.tryParse(
          _amountController.text.trim(),
        ) ??
        0;
  }

  // ==========================================================================
  // PROCESSING TIME
  // ==========================================================================

    String get _processingTime {
    return _product?['processing_time']
            ?.toString()
            .trim() ??
        '';
  }


  // ==========================================================================
  // PRICING
  // ==========================================================================

  PriceAdjustmentResult get _pricingResult {
    if (_isTngPin) {
      return PriceAdjustmentResult.none(
        _reloadAmount,
      );
    }

    final adjustment =
        _catalogPricing.priceAdjustment;

    if (adjustment == null) {
      return PriceAdjustmentResult.none(
        _reloadAmount,
      );
    }

    return adjustment.apply(
      _reloadAmount,
    );
  }

  double get _totalAmount {
    if (_isTngPin) {
      return widget.selectedTotalAmount ??
          _reloadAmount;
    }

    return _pricingResult.amountAfter;
  }

  double get _adjustmentAmount {
    if (_isTngPin) {
      return _totalAmount -
          _reloadAmount;
    }

    return _pricingResult.adjustmentAmount;
  }

  bool get _hasAdjustment =>
      _adjustmentAmount.abs() >= 0.005;


// ==========================================================================
// PROVIDER SURCHARGE NOTE
// ==========================================================================

String get _catalogNote {
  return _product?['note']
          ?.toString()
          .trim() ??
      '';
}

bool get _hasProviderSurcharge {
  final note =
      _catalogNote.toLowerCase();

  return note.contains(
    'surcharge',
  );
}

double get _providerSurchargeAmount {
  if (!_hasProviderSurcharge) {
    return 0;
  }

  final match =
      RegExp(
    r'RM\s*([0-9]+(?:\.[0-9]+)?)',
    caseSensitive: false,
  ).firstMatch(
    _catalogNote,
  );

  if (match == null) {
    return 0;
  }

  return double.tryParse(
        match.group(1) ?? '',
      ) ??
      0;
}

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    if (_isPinless) {
      _loadPinlessProduct();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD TNGD / TRUE PRODUCT
  // ==========================================================================

  Future<void> _loadPinlessProduct() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService
              .getCatalog();

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products are missing.',
        );
      }

      final products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final dynamic rawProduct =
          products[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'E-Wallet product $_code was not found.',
        );
      }

      final product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      double minimum = 0;
      double maximum = 0;

      final dynamic fieldsRaw =
          product['fields'];

      if (fieldsRaw is List) {
        for (final rawField in fieldsRaw) {
          if (rawField is! Map) {
            continue;
          }

          final field =
              Map<String, dynamic>.from(
            rawField,
          );

          if (field['id'] != 'amount') {
            continue;
          }

          final dynamic validationRaw =
              field['validation'];

          if (validationRaw is Map) {
            final validation =
                Map<String, dynamic>.from(
              validationRaw,
            );

            minimum = _toDouble(
              validation['min'],
            );

            maximum = _toDouble(
              validation['max'],
            );
          }
        }
      }

      if (minimum <= 0 ||
          maximum <= 0) {
        final denomination =
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

      final pricing =
          CatalogPricing
              .fromCatalogResponse(
        catalogJson: catalog,
        productCode: _code,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;

        _minimumAmount = minimum;
        _maximumAmount = maximum;

        _catalogPricing = pricing;

        if (_amountController.text.isEmpty &&
            minimum > 0) {
          _updateAmountController(
            minimum,
          );
        }

        _isLoading = false;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'E-WALLET PINLESS PRODUCT LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Product Code     : $_code',
      );
      debugPrint(
        'Provider         : ${widget.providerName}',
      );
      debugPrint(
        'Phone            : $_phoneNumber',
      );
      debugPrint(
        'Minimum          : $_minimumAmount',
      );
      debugPrint(
        'Maximum          : $_maximumAmount',
      );
      debugPrint(
        'Price Adjustment : '
        '${_catalogPricing.priceAdjustment?.displayValue ?? '-'}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');
    }  catch (error, stackTrace) {
      debugPrint(
        'E-Wallet PAGE 5 catalog error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  // ==========================================================================
  // PARSERS
  // ==========================================================================

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
    final parts =
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

  // ==========================================================================
  // PHONE VALIDATION
  // ==========================================================================

  bool _isValidPhone(
    String number,
  ) {
    if (!RegExp(r'^[0-9]+$')
        .hasMatch(number)) {
      return false;
    }

    if (!number.startsWith('01')) {
      return false;
    }

    return number.length >= 9 &&
        number.length <= 11;
  }

  // ==========================================================================
  // MONEY FORMATTERS
  // ==========================================================================

  String _formatMoney(
    double value,
  ) {
    return 'RM ${value.toStringAsFixed(2)}';
  }

  String _formatSignedMoney(
    double value,
  ) {
    final sign =
        value >= 0 ? '+' : '-';

    return '$sign RM '
        '${value.abs().toStringAsFixed(2)}';
  }

  String _getEWalletProcessingTime(
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
          .eWalletUpdateInstant
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
          .eWalletUpdateWithinHours(
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
          .eWalletUpdateWithinDays(
            days,
          )
          .toUpperCase();
    }

    return _processingTime
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  // ==========================================================================
  // TNG PHONE INPUT
  // ==========================================================================

  void _addPhoneNumber(
    String number,
  ) {
    if (_isNavigating) {
      return;
    }

    if (_phoneController.text.length >=
        11) {
      return;
    }

    setState(() {
      _phoneController.text +=
          number;
    });
  }

  void _phoneBackspace() {
    if (_isNavigating ||
        _phoneController.text.isEmpty) {
      return;
    }

    setState(() {
      _phoneController.text =
          _phoneController.text.substring(
        0,
        _phoneController.text.length -
            1,
      );
    });
  }

  void _clearPhone() {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _phoneController.clear();
    });
  }

  // ==========================================================================
  // PINLESS AMOUNT
  // ==========================================================================

  void _updateAmountController(
    double amount,
  ) {
    _amountController.text =
        amount.toStringAsFixed(2);

    _amountController.selection =
        TextSelection.fromPosition(
      TextPosition(
        offset:
            _amountController.text.length,
      ),
    );
  }

  void _setReloadAmount(
    double amount,
  ) {
    if (!_isPinless) {
      return;
    }

    double safeAmount =
        amount;

    if (_minimumAmount > 0 &&
        safeAmount < _minimumAmount) {
      safeAmount =
          _minimumAmount;
    }

    if (_maximumAmount > 0 &&
        safeAmount > _maximumAmount) {
      safeAmount =
          _maximumAmount;
    }

    setState(() {
      _updateAmountController(
        safeAmount,
      );
    });
  }

  void _increaseReloadAmount() {
    final current =
        _reloadAmount;

    final next =
        current <= 0
            ? _minimumAmount
            : current + 1.00;

    if (_maximumAmount > 0 &&
        next > _maximumAmount) {
      return;
    }

    _setReloadAmount(
      next,
    );
  }

  void _decreaseReloadAmount() {
    final current =
        _reloadAmount;

    if (current <=
        _minimumAmount) {
      return;
    }

    _setReloadAmount(
      current - 1.00,
    );
  }

  void _setQuickReloadAmount(
    double amount,
  ) {
    if (amount <
        _minimumAmount) {
      return;
    }

    if (_maximumAmount > 0 &&
        amount > _maximumAmount) {
      return;
    }

    _setReloadAmount(
      amount,
    );
  }

  // ==========================================================================
  // CUSTOM AMOUNT KEYBOARD
  // ==========================================================================

  void _openEWalletAmountKeyboard() {
    final loc =
        AppLocalizations.of(context)!;

    String temporaryValue =
        _amountController.text.trim();

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel:
          loc.eWalletEnterAmountTitle,
      barrierColor:
          Colors.black.withOpacity(
        0.58,
      ),
      transitionDuration:
          const Duration(
        milliseconds: 220,
      ),
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved =
            CurvedAnimation(
          parent: animation,
          curve:
              Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale:
                Tween<double>(
              begin: 0.88,
              end: 1,
            ).animate(
              curved,
            ),
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
            void updateValue(
              String value,
            ) {
              temporaryValue =
                  value;

              setKeyboardState(
                () {},
              );
            }

            void pressNumber(
              String number,
            ) {
              if (temporaryValue ==
                      '0.00' ||
                  temporaryValue ==
                      '0') {
                updateValue(
                  number,
                );

                return;
              }

              if (temporaryValue
                  .contains('.')) {
                final parts =
                    temporaryValue
                        .split('.');

                if (parts.length > 1 &&
                    parts.last.length >=
                        2) {
                  return;
                }
              }

              final prospective =
                  '$temporaryValue$number';

              if (prospective.length >
                  9) {
                return;
              }

              final parsed =
                  double.tryParse(
                prospective,
              );

              if (parsed != null &&
                  _maximumAmount > 0 &&
                  parsed >
                      _maximumAmount) {
                return;
              }

              updateValue(
                prospective,
              );
            }

            void pressDecimal() {
              if (temporaryValue
                  .contains('.')) {
                return;
              }

              if (temporaryValue
                  .isEmpty) {
                updateValue(
                  '0.',
                );

                return;
              }

              updateValue(
                '$temporaryValue.',
              );
            }

            void pressDelete() {
              if (temporaryValue
                  .isEmpty) {
                return;
              }

              updateValue(
                temporaryValue.substring(
                  0,
                  temporaryValue.length -
                      1,
                ),
              );
            }

            void pressClear() {
              updateValue('');
            }

            void pressDone() {
              final parsed =
                  double.tryParse(
                        temporaryValue,
                      ) ??
                      0;

              if (parsed <
                  _minimumAmount) {
                _showAlert(
                  loc.eWalletInvalidAmountTitle,
                  loc.eWalletMinimumAmount(
                    _formatMoney(
                      _minimumAmount,
                    ),
                  ),
                );

                return;
              }

              if (_maximumAmount > 0 &&
                  parsed >
                      _maximumAmount) {
                _showAlert(
                  loc.eWalletInvalidAmountTitle,
                  loc.eWalletMaximumAmount(
                    _formatMoney(
                      _maximumAmount,
                    ),
                  ),
                );

                return;
              }

              _setReloadAmount(
                parsed,
              );

              Navigator.pop(
                dialogContext,
              );
            }

            return Material(
              color:
                  Colors.transparent,
              child: SafeArea(
                child: Center(
                  child: Container(
                    width: 820,
                    margin:
                        const EdgeInsets.all(
                      35,
                    ),
                    padding:
                        const EdgeInsets.all(
                      38,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF8FAFC,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        34,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black
                                  .withOpacity(
                            0.30,
                          ),
                          blurRadius: 40,
                          offset:
                              const Offset(
                            0,
                            18,
                          ),
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
                                width: 68,
                                height: 68,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFFFE9DE,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    18,
                                  ),
                                ),
                                child:
                                    const Icon(
                                  Icons
                                      .dialpad_rounded,
                                  color:
                                      _primaryColor,
                                  size: 40,
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
                                      loc.eWalletEnterAmountTitle,
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF102A43,
                                        ),
                                        fontSize: 34,
                                        fontWeight:
                                            FontWeight
                                                .w900,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    Text(
                                      loc.eWalletAmountRange(
                                        _formatMoney(
                                          _minimumAmount,
                                        ),
                                        _formatMoney(
                                          _maximumAmount,
                                        ),
                                      ),
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF60758D,
                                        ),
                                        fontSize: 23,
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  Navigator.pop(
                                    dialogContext,
                                  );
                                },
                                icon:
                                    const Icon(
                                  Icons
                                      .close_rounded,
                                  size: 38,
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
                                const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 25,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                22,
                              ),
                              border:
                                  Border.all(
                                color:
                                    _primaryColor,
                                width: 3,
                              ),
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
                                    fontSize: 39,
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
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF102A43,
                                      ),
                                      fontSize: 54,
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
                            height: 28,
                          ),

                          _ewalletKeypadRow(
                            [
                              '1',
                              '2',
                              '3',
                            ],
                            pressNumber,
                          ),

                          _ewalletKeypadRow(
                            [
                              '4',
                              '5',
                              '6',
                            ],
                            pressNumber,
                          ),

                          _ewalletKeypadRow(
                            [
                              '7',
                              '8',
                              '9',
                            ],
                            pressNumber,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child:
                                    _ewalletKeyboardButton(
                                  '.',
                                  pressDecimal,
                                ),
                              ),

                              const SizedBox(
                                width: 16,
                              ),

                              Expanded(
                                child:
                                    _ewalletKeyboardButton(
                                  '0',
                                  () {
                                    pressNumber(
                                      '0',
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(
                                width: 16,
                              ),

                              Expanded(
                                child:
                                    _ewalletKeyboardIconButton(
                                  Icons
                                      .backspace_outlined,
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
                                child:
                                    SizedBox(
                                  height: 78,
                                  child:
                                      OutlinedButton.icon(
                                    onPressed:
                                        pressClear,
                                    icon:
                                        const Icon(
                                      Icons
                                          .delete_sweep_rounded,
                                    ),
                                    label: Text(
                                      loc.eWalletKeypadClear,
                                      style:
                                          const TextStyle(
                                        fontSize: 25,
                                        fontWeight:
                                            FontWeight
                                                .w900,
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
                                child:
                                    SizedBox(
                                  height: 78,
                                  child:
                                      ElevatedButton.icon(
                                    onPressed:
                                        pressDone,
                                    icon:
                                        const Icon(
                                      Icons
                                          .check_circle_rounded,
                                      size: 30,
                                    ),
                                    label: Text(
                                      loc.eWalletKeypadDone,
                                      style:
                                          const TextStyle(
                                        fontSize: 28,
                                        fontWeight:
                                            FontWeight
                                                .w900,
                                      ),
                                    ),
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          _primaryColor,
                                      foregroundColor:
                                          Colors.white,
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
                            height: 15,
                          ),

                          SizedBox(
                            width:
                                double.infinity,
                            height: 68,
                            child:
                                TextButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                              ),
                              label: Text(
                                loc.eWalletKeypadCancel,
                                style:
                                    const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                              style:
                                  TextButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFFD32F2F,
                                ),
                                foregroundColor:
                                    Colors.white,
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
            );
          },
        );
      },
    );
  }

  // ==========================================================================
  // AMOUNT KEYPAD HELPERS
  // ==========================================================================

  Widget _ewalletKeypadRow(
    List<String> values,
    void Function(String) onPressed,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        children: [
          for (int i = 0;
              i < values.length;
              i++) ...[
            Expanded(
              child:
                  _ewalletKeyboardButton(
                values[i],
                () {
                  onPressed(
                    values[i],
                  );
                },
              ),
            ),

            if (i <
                values.length - 1)
              const SizedBox(
                width: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _ewalletKeyboardButton(
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 92,
      child: ElevatedButton(
        onPressed:
            onPressed,
        style:
            ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor:
              Colors.white,
          foregroundColor:
              const Color(
            0xFF102A43,
          ),
          side:
              const BorderSide(
            color:
                Color(
              0xFFD5DEE9,
            ),
            width: 2,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
        ),
        child: Text(
          text,
          style:
              const TextStyle(
            fontSize: 42,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _ewalletKeyboardIconButton(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 92,
      child: ElevatedButton(
        onPressed:
            onPressed,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(
            0xFFFFF3E8,
          ),
          foregroundColor:
              _darkColor,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: 38,
        ),
      ),
    );
  }

  // ==========================================================================
  // PAYMENT
  // ==========================================================================

  Future<void> _handleContinue() async {
    if (_isNavigating) {
      return;
    }

    final loc =
        AppLocalizations.of(context)!;

    if (_isTngPin) {
      if (_phoneNumber.isEmpty) {
        _showAlert(
          loc.eWalletPhoneRequiredTitle,
          loc.eWalletPhoneRequiredMessage,
        );

        return;
      }

      if (!_isValidPhone(
        _phoneNumber,
      )) {
        _showAlert(
          loc.eWalletInvalidPhoneTitle,
          loc.eWalletInvalidPhoneMessage,
        );

        return;
      }
    }

    if (_isPinless) {
      if (_amountController.text
          .trim()
          .isEmpty) {
        _showAlert(
          loc.eWalletAmountRequiredTitle,
          loc.eWalletAmountRequiredMessage,
        );

        return;
      }

      if (_reloadAmount <
          _minimumAmount) {
        _showAlert(
          loc.eWalletInvalidAmountTitle,
          loc.eWalletMinimumAmount(
            _formatMoney(
              _minimumAmount,
            ),
          ),
        );

        return;
      }

      if (_reloadAmount >
          _maximumAmount) {
        _showAlert(
          loc.eWalletInvalidAmountTitle,
          loc.eWalletMaximumAmount(
            _formatMoney(
              _maximumAmount,
            ),
          ),
        );

        return;
      }
    }

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'E-WALLET READY FOR QR PAYMENT',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'Provider       : ${widget.providerName}',
    );
    debugPrint(
      'Product Code   : $_code',
    );
    debugPrint(
      'Phone/Account  : $_phoneNumber',
    );
    debugPrint(
      'Reload Amount  : $_reloadAmount',
    );
    debugPrint(
      'Adjustment     : $_adjustmentAmount',
    );
    debugPrint(
      'Customer Total : $_totalAmount',
    );
    debugPrint(
      '========================================',
    );
    debugPrint('');

    setState(() {
      _isNavigating = true;
    });

    try {
      final result =
          await Navigator.push<
              BilQrPaymentResult>(
        context,
        MaterialPageRoute(
          settings:
              const RouteSettings(
            name:
                '/ewallet-payment',
          ),
          builder:
              (_) =>
            BilQrPaymentPage(
              billType:
                  widget.providerName,

              billCode:
                  _code,

              accountNumber:
                  _phoneNumber,

              billAmount:
                  _reloadAmount,

              totalAmount:
                  _totalAmount,

              useEWalletPinReceipt:
                  _isTngPin,

              useEWalletPinlessReceipt:
                  _isPinless,

              eWalletReceiptData:
                  EWalletReceiptExtraData(
                providerName:
                    widget.providerName,

                productCode:
                    _code,

                phoneNumber:
                    _phoneNumber,

                reloadAmount:
                    _reloadAmount,

                serviceAdjustment:
                    _adjustmentAmount,

                customerTotal:
                    _totalAmount,

                isPin:
                    _isTngPin,

                providerNote:
                   _catalogNote,
              ),
            ),
        ),
      );

      if (!mounted ||
          result == null) {
        return;
      }

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'E-WALLET QR PAYMENT SUCCESS',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Product      : ${result.billCode}',
      );
      debugPrint(
        'Account      : ${result.accountNumber}',
      );
      debugPrint(
        'Reload Amount: ${result.billAmount}',
      );
      debugPrint(
        'Paid Amount  : ${result.totalAmount}',
      );
      debugPrint(
        'Order No     : ${result.orderNo}',
      );
      debugPrint(
        'Bank Txn     : ${result.bankTransactionNo}',
      );
      debugPrint(
        '========================================',
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
  // ALERT
  // ==========================================================================

  void _showAlert(
    String title,
    String message,
  ) {
    if (!mounted) {
      return;
    }

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel:
          title,
      barrierColor:
          Colors.black.withOpacity(
        0.65,
      ),
      transitionDuration:
          const Duration(
        milliseconds: 220,
      ),
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved =
            CurvedAnimation(
          parent: animation,
          curve:
              Curves.easeOutBack,
        );

        return FadeTransition(
          opacity:
              animation,
          child:
              ScaleTransition(
            scale:
                Tween<double>(
              begin: 0.88,
              end: 1,
            ).animate(
              curved,
            ),
            child:
                child,
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
              color:
                  Colors.transparent,
              child: Container(
                width: 760,
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 70,
                  vertical: 120,
                ),
                padding:
                    const EdgeInsets.all(
                  42,
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
                        const Color(
                      0xFFFFB38A,
                    ),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(
                        0.30,
                      ),
                      blurRadius: 45,
                      offset:
                          const Offset(
                        0,
                        20,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 125,
                      height: 125,
                      decoration:
                          const BoxDecoration(
                        shape:
                            BoxShape.circle,
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.topLeft,
                          end:
                              Alignment.bottomRight,
                          colors: [
                            _lightColor,
                            _darkColor,
                          ],
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .info_outline_rounded,
                        color:
                            Colors.white,
                        size: 70,
                      ),
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    Text(
                      title,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            _darkColor,
                        fontSize: 45,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.all(
                        28,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFFFF7F2,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          24,
                        ),
                      ),
                      child:
                          Text(
                        message,
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF4E5968,
                          ),
                          fontSize: 31,
                          fontWeight:
                              FontWeight
                                  .w700,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 88,
                      child:
                          ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        icon:
                            const Icon(
                          Icons
                              .check_circle_rounded,
                          size: 35,
                        ),
                        label: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .eWalletOkButton,
                          style:
                              const TextStyle(
                            fontSize: 32,
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              _primaryColor,
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
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
    );
  }

  // ==========================================================================
  // TNG PHONE KEYPAD
  // ==========================================================================

  Widget _phoneNumberKey(
    String value,
  ) {
    final bool pressed =
        _activeKey == value;

    return Listener(
      onPointerDown: (_) {
        if (_isNavigating) {
          return;
        }

        setState(() {
          _activeKey =
              value;
        });
      },
      onPointerUp: (_) {
        if (_isNavigating) {
          return;
        }

        setState(() {
          _activeKey =
              null;
        });

        _addPhoneNumber(
          value,
        );
      },
      onPointerCancel: (_) {
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
          milliseconds: 110,
        ),
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 110,
          ),
          height: 110,
          decoration:
              BoxDecoration(
            color:
                pressed
                    ? _primaryColor
                        .withOpacity(
                        0.15,
                      )
                    : Colors.white,
            borderRadius:
                BorderRadius.circular(
              24,
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
                    Colors.black
                        .withOpacity(
                  0.10,
                ),
                blurRadius: 10,
                offset:
                    const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF15253A,
                ),

                // Bigger for elderly users.
                fontSize: 64,

                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneActionKey({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color:
          Colors.transparent,
      child: InkWell(
        onTap:
            _isNavigating
                ? null
                : onPressed,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        child: Container(
          height: 110,
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
              24,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color:
                  Colors.white,

              // Bigger clear/backspace icon.
              size: 52,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // QUICK RELOAD AMOUNT
  // ==========================================================================

  Widget _quickReloadButton(
    double amount,
  ) {
    final bool selected =
        (_reloadAmount -
                    amount)
                .abs() <
            0.005;

    final bool valid =
        amount >= _minimumAmount &&
            (_maximumAmount <= 0 ||
                amount <=
                    _maximumAmount);

    return Expanded(
      child: SizedBox(
        height: 68,
        child:
            ElevatedButton(
          onPressed:
              valid
                  ? () {
                      _setQuickReloadAmount(
                        amount,
                      );
                    }
                  : null,
          style:
              ElevatedButton
                  .styleFrom(
            elevation: 0,
            backgroundColor:
                selected
                    ? _primaryColor
                    : const Color(
                        0xFFFFEFE7,
                      ),
            foregroundColor:
                selected
                    ? Colors.white
                    : _darkColor,
            disabledBackgroundColor:
                const Color(
              0xFFF1F1F1,
            ),
            disabledForegroundColor:
                Colors.grey,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
          ),
          child: Text(
            'RM${amount.toStringAsFixed(0)}',
            style:
                const TextStyle(
              fontSize: 23,
              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // MAIN PAGE
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
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit:
                  BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color:
                  Colors.white
                      .withOpacity(
                0.06,
              ),
            ),
          ),

          if (_isLoading)
            _buildLoading(
              loc,
            )
          else if (_errorMessage !=
              null)
            _buildError(
              loc,
            )
          else if (_isTngPin)
            _buildTngPhonePage(
              loc,
            )
          else
            _buildModernPinlessAmountPage(
              loc,
            ),

          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Text(
              Data.copyrightText,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF26364A,
                ),
                fontSize: 17,
                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // LOADING
  // ==========================================================================

  Widget _buildLoading(
    AppLocalizations loc,
  ) {
    return Center(
      child: Container(
        width: 620,
        padding:
            const EdgeInsets.all(
          45,
        ),
        decoration:
            BoxDecoration(
          color:
              Colors.white,
          borderRadius:
              BorderRadius.circular(
            36,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const SizedBox(
              width: 90,
              height: 90,
              child:
                  CircularProgressIndicator(
                strokeWidth: 7,
                color:
                    _primaryColor,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            Text(
              loc.eWalletLoadingTitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize: 40,
                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              loc.eWalletLoadingMessage,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF657386,
                ),
                fontSize: 27,
                fontWeight:
                    FontWeight
                        .w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ERROR
  // ==========================================================================

  Widget _buildError(
    AppLocalizations loc,
  ) {
    return Center(
      child: Container(
        width: 700,
        padding:
            const EdgeInsets.all(
          45,
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
                const Color(
              0xFFE57373,
            ),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color:
                  Color(
                0xFFD32F2F,
              ),
              size: 90,
            ),

            const SizedBox(
              height: 25,
            ),

            Text(
              loc.eWalletCatalogErrorTitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize: 42,
                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              loc.eWalletCatalogErrorMessage,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF657386,
                ),
                fontSize: 28,
                fontWeight:
                    FontWeight
                        .w600,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      SizedBox(
                    height: 82,
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
                      ),
                      label: Text(
                        loc.buttonBack,
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.white,
                        foregroundColor:
                            Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                Expanded(
                  child:
                      SizedBox(
                    height: 82,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _loadPinlessProduct,
                      icon:
                          const Icon(
                        Icons
                            .refresh_rounded,
                      ),
                      label: Text(
                        loc.eWalletRetry,
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            _primaryColor,
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TNG PIN - PHONE / REFERENCE PAGE
  // ==========================================================================

  Widget _buildTngPhonePage(
    AppLocalizations loc,
  ) {
    return Stack(
      children: [
        // ====================================================================
        // TOP HEADER
        // ====================================================================

        Positioned(
          top: 32,
          left: 50,
          right: 50,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 11,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      _primaryColor
                          .withOpacity(
                    0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    100,
                  ),
                  border:
                      Border.all(
                    color:
                        _primaryColor
                            .withOpacity(
                      0.16,
                    ),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons
                          .account_balance_wallet_rounded,
                      color:
                          _primaryColor,
                      size: 30,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Flexible(
                      child: Text(
                        loc.eWalletPhoneStepLabel
                            .toUpperCase(),
                        textAlign:
                            TextAlign.center,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color:
                              _primaryColor,

                          // Larger badge.
                          fontSize: 23,

                          fontWeight:
                              FontWeight
                                  .w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              Text(
                loc.eWalletEnterPhoneTitle
                    .toUpperCase(),
                textAlign:
                    TextAlign.center,
                maxLines: 2,
                style:
                    const TextStyle(
                  color:
                      _darkColor,

                  // Larger main title.
                  fontSize: 48,

                  fontWeight:
                      FontWeight
                          .w900,
                  height: 1.05,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // ====================================================================
        // INFORMATION CARD
        // ====================================================================

        Positioned(
          top: 200,
          left: 45,
          right: 45,
          child: Container(
            padding:
                const EdgeInsets.fromLTRB(
              24,
              22,
              24,
              22,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(
                0.98,
              ),
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
              border:
                  Border.all(
                color:
                    _primaryColor
                        .withOpacity(
                  0.35,
                ),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(
                    0xFF6A3A23,
                  ).withOpacity(
                    0.08,
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
            child: Column(
              children: [
                // ==========================================================
                // PROVIDER INFORMATION
                // ==========================================================

                Row(
                  children: [
                    Container(
                      width: 118,
                      height: 88,
                      padding:
                          const EdgeInsets.all(
                        11,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFE4E7EB,
                          ),
                          width: 1.5,
                        ),
                      ),
                      child:
                          Image.network(
                        widget
                            .providerImageUrl,
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
                                .account_balance_wallet_rounded,
                            color:
                                _primaryColor,
                            size: 50,
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 20,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            widget
                                .providerName,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF17283E,
                              ),

                              // Larger provider.
                              fontSize: 32,

                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          Text(
                            '${loc.eWalletPinValue}: '
                            '${_formatMoney(_reloadAmount)}',
                            style:
                                const TextStyle(
                              color:
                                  _primaryColor,

                              // Larger PIN amount.
                              fontSize: 25,

                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==========================================================
                // PHONE NUMBER INPUT DISPLAY
                // ==========================================================

                Container(
                  height: 108,
                  alignment:
                      Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF7F9FC,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      22,
                    ),
                    border:
                        Border.all(
                      color:
                          _primaryColor,
                      width: 2.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _primaryColor
                                .withOpacity(
                          0.07,
                        ),
                        blurRadius: 10,
                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller:
                        _phoneController,
                    readOnly: true,
                    showCursor: true,
                    cursorColor:
                        _primaryColor,
                    cursorWidth: 4,
                    keyboardType:
                        TextInputType.none,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF17283E,

                      ),

                      // Bigger actual number.
                      fontSize: 48,

                      fontWeight:
                          FontWeight
                              .w900,
                      letterSpacing: 2,
                    ),
                    decoration:
                        InputDecoration(
                      border:
                          InputBorder.none,

                      // ALL CAPITAL.
                      hintText:
                          loc.eWalletPhoneHint
                              .toUpperCase(),

                      hintStyle:
                          const TextStyle(
                        color:
                            Color(
                          0xFF7C808A,
                        ),

                        // Larger hint.
                        fontSize: 32,

                        fontWeight:
                            FontWeight
                                .w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==========================================================
                // PHONE NUMBER INFORMATION
                // ==========================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: _primaryColor,
                      size: 27,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Flexible(
                      child: Text(
                        loc.eWalletPinPhoneReferenceHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF53677E),
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==========================================================
                // SUMMARY
                // ==========================================================

                _buildTngCompactSummary(
                  loc,
                ),
              ],
            ),
          ),
        ),

        // ====================================================================
        // PHONE KEYPAD
        // ====================================================================

        Positioned(
          top: 825,
          left: 60,
          right: 60,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),

            mainAxisSpacing: 20,
            crossAxisSpacing: 20,

            // Slightly wider/shorter so it fits comfortably.
            childAspectRatio: 1.8,

            children: [
              _phoneNumberKey('1'),
              _phoneNumberKey('2'),
              _phoneNumberKey('3'),
              _phoneNumberKey('4'),
              _phoneNumberKey('5'),
              _phoneNumberKey('6'),
              _phoneNumberKey('7'),
              _phoneNumberKey('8'),
              _phoneNumberKey('9'),

              _phoneActionKey(
                icon:
                    Icons
                        .delete_sweep_rounded,
                onPressed:
                    _clearPhone,
              ),

              _phoneNumberKey('0'),

              _phoneActionKey(
                icon:
                    Icons
                        .backspace_outlined,
                onPressed:
                    _phoneBackspace,
              ),
            ],
          ),
        ),

        // ====================================================================
        // BOTTOM BUTTONS
        // ====================================================================

        Positioned(
          bottom: 150,
          left: 30,
          right: 30,
          child:
              _buildBottomButtons(
            loc,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TNG SUMMARY
  // ==========================================================================

  Widget _buildTngCompactSummary(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFFF7F2,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFFFE0D0,
          ),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          _compactSummaryRow(
            loc.eWalletPinValue,
            _formatMoney(
              _reloadAmount,
            ),
          ),

          if (_hasAdjustment) ...[
            const Divider(
              height: 10,
              color:
                  Color(
                0xFFE4DAD5,
              ),
            ),

            _compactSummaryRow(
              loc.eWalletServiceAdjustment,
              _formatSignedMoney(
                _adjustmentAmount,
              ),
            ),
          ],

          const Divider(
            height: 10,
            color:
                Color(
              0xFFE4DAD5,
            ),
          ),

          _compactSummaryRow(
            loc.eWalletTotalPayment,
            _formatMoney(
              _totalAmount,
            ),
            bold: true,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PINLESS AMOUNT PAGE
  // ==========================================================================

  Widget _buildModernPinlessAmountPage(
    AppLocalizations loc,
  ) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 70,
          right: 70,
          child: Container(
            height: 120,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.centerLeft,
                end:
                    Alignment.centerRight,
                colors: [
                  _darkColor,
                  _primaryColor,
                  _lightColor,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _darkColor
                          .withOpacity(
                    0.20,
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
            child: Row(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white
                            .withOpacity(
                      0.16,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .account_balance_wallet_rounded,
                    color:
                        Colors.white,
                    size: 45,
                  ),
                ),

                const SizedBox(
                  width: 22,
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        loc.eWalletReloadDetails,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 22,
                          fontWeight:
                              FontWeight
                                  .w800,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        widget
                            .providerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 40,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 115,
                  height: 80,
                  padding:
                      const EdgeInsets.all(
                    10,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                  ),
                  child:
                      Image.network(
                    widget
                        .providerImageUrl,
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
                            .account_balance_wallet_rounded,
                        color:
                            _primaryColor,
                        size: 45,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 200,
          left: 65,
          right: 65,
          bottom: 175,
          child:
              SingleChildScrollView(
            controller:
                _scrollController,
            physics:
                const ClampingScrollPhysics(),
            child: Column(
              children: [
                _buildAmountStepHeading(
                  loc,
                ),

                const SizedBox(
                  height: 25,
                ),

                _buildPhoneInformationCard(
                  loc,
                ),

                const SizedBox(
                  height: 25,
                ),

                // Container(
                //   width:
                //       double.infinity,
                //   padding:
                //       const EdgeInsets.all(
                //     30,
                //   ),
                //   decoration:
                //       BoxDecoration(
                //     gradient:
                //         const LinearGradient(
                //       begin:
                //           Alignment.topLeft,
                //       end:
                //           Alignment.bottomRight,
                //       colors: [
                //         _darkColor,
                //         _primaryColor,
                //       ],
                //     ),
                //     borderRadius:
                //         BorderRadius
                //             .circular(
                //       30,
                //     ),
                //     boxShadow: [
                //       BoxShadow(
                //         color:
                //             _primaryColor
                //                 .withOpacity(
                //           0.20,
                //         ),
                //         blurRadius: 18,
                //         offset:
                //             const Offset(
                //           0,
                //           8,
                //         ),
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     children: [
                //       Text(
                //         loc.eWalletReloadAmount,
                //         style:
                //             const TextStyle(
                //           color:
                //               Colors.white70,
                //           fontSize: 23,
                //           fontWeight:
                //               FontWeight
                //                   .w800,
                //         ),
                //       ),

                //       const SizedBox(
                //         height: 8,
                //       ),

                //       Text(
                //         _formatMoney(
                //           _reloadAmount,
                //         ),
                //         style:
                //             const TextStyle(
                //           color:
                //               Colors.white,
                //           fontSize: 62,
                //           fontWeight:
                //               FontWeight
                //                   .w900,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // const SizedBox(
                //   height: 25,
                // ),

                _buildAmountSelector(
                  loc,
                ),

                if (_hasProviderSurcharge) ...[
                  const SizedBox(
                    height: 20,
                  ),

                  _buildProviderSurchargeNotice(
                    loc,
                  ),
                ],

                const SizedBox(
                  height: 25,
                ),

                _buildModernEWalletOrderSummary(
                  loc,
                ),

                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 65,
          left: 70,
          right: 70,
          child:
              _buildBottomButtons(
            loc,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // AMOUNT STEP HEADING
  // ==========================================================================

  Widget _buildAmountStepHeading(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 27,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFFFFE8DC,
            ),
            Color(
              0xFFFFFBF8,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          25,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFFFB38A,
          ),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
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
              Icons.payments_rounded,
              color:
                  Colors.white,
              size: 42,
            ),
          ),

          const SizedBox(
            width: 23,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  loc.eWalletEnterAmountTitle,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF102A43,
                    ),
                    fontSize: 39,
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  loc.eWalletAmountStepSubtitle,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF53677E,
                    ),
                    fontSize: 25,
                    fontWeight:
                        FontWeight
                            .w600,
                    height: 1.3,
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
  // PHONE INFORMATION
  // ==========================================================================

  Widget _buildPhoneInformationCard(
    AppLocalizations loc,
  ) {
    return Container(
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
            Colors.white.withOpacity(
          0.97,
        ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFFFD4BF,
          ),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFFE8DC,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child:
                const Icon(
              Icons
                  .phone_android_rounded,
              color:
                  _primaryColor,
              size: 31,
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  loc.eWalletPhoneNumber,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF718096,
                    ),
                    fontSize: 20,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  _phoneNumber,
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
              ],
            ),
          ),

          Container(
            width: 50,
            height: 50,
            decoration:
                const BoxDecoration(
              color:
                  Color(
                0xFFE6F6EC,
              ),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.check_rounded,
              color:
                  Color(
                0xFF16813B,
              ),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // AMOUNT SELECTOR
  // ==========================================================================

  Widget _buildAmountSelector(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),
        borderRadius:
            BorderRadius.circular(
          30,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFFFC2A5,
          ),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            loc.eWalletSelectReloadValue,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF102A43,
              ),
              fontSize: 29,
              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFFF0E8,
              ),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFFFC2A5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons
                      .keyboard_alt_outlined,
                  color:
                      _darkColor,
                  size: 34,
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Text(
                    loc.eWalletAmountRange(
                      _formatMoney(
                        _minimumAmount,
                      ),
                      _formatMoney(
                        _maximumAmount,
                      ),
                    ),
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF86411E,
                      ),
                      fontSize: 23,
                      height: 1.35,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              SizedBox(
                width: 90,
                height: 82,
                child:
                    ElevatedButton(
                  onPressed:
                      _decreaseReloadAmount,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFFFEDE3,
                    ),
                    foregroundColor:
                        _darkColor,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .remove_rounded,
                    size: 42,
                  ),
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              Expanded(
                child:
                    GestureDetector(
                  onTap:
                      _openEWalletAmountKeyboard,
                  child: Container(
                    height: 82,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 25,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFFFFAF7,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      border:
                          Border.all(
                        color:
                            _primaryColor,
                        width: 2.5,
                      ),
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
                            fontSize: 30,
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),

                        const SizedBox(
                          width: 15,
                        ),

                        Expanded(
                          child: Text(
                            _reloadAmount
                                .toStringAsFixed(
                              2,
                            ),
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF102A43,
                              ),
                              fontSize: 39,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons
                              .dialpad_rounded,
                          color:
                              _primaryColor,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              SizedBox(
                width: 90,
                height: 82,
                child:
                    ElevatedButton(
                  onPressed:
                      _increaseReloadAmount,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        _primaryColor,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .add_rounded,
                    size: 42,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 25,
          ),

          Row(
            children: [
              _quickReloadButton(
                10,
              ),

              const SizedBox(
                width: 12,
              ),

              _quickReloadButton(
                30,
              ),

              const SizedBox(
                width: 12,
              ),

              _quickReloadButton(
                50,
              ),

              const SizedBox(
                width: 12,
              ),

              _quickReloadButton(
                100,
              ),
            ],
          ),

          if (_isTrueMoney) ...[
            const SizedBox(
              height: 20,
            ),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                18,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFFFF8E1,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .info_outline_rounded,
                    color:
                        Color(
                      0xFFF57F17,
                    ),
                    size: 28,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      loc.eWalletTrueMoneyNote,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF6D5711,
                        ),
                        fontSize: 21,
                        fontWeight:
                            FontWeight
                                .w700,
                        height: 1.3,
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

  // ==========================================================================
  // MODERN ORDER SUMMARY
  // ==========================================================================

  Widget _buildModernEWalletOrderSummary(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
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
          30,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFFFD4BF,
          ),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .receipt_long_rounded,
                color:
                    _primaryColor,
                size: 34,
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Text(
                  loc.eWalletOrderSummary,
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
              ),
            ],
          ),

          const SizedBox(
            height: 25,
          ),

          _summaryRow(
            loc.eWalletPhoneNumber,
            _phoneNumber,
          ),

          const SizedBox(
            height: 15,
          ),

          _summaryRow(
            loc.eWalletReloadValue,
            _formatMoney(
              _reloadAmount,
            ),
          ),

          if (_hasAdjustment) ...[
            const SizedBox(
              height: 15,
            ),

            _summaryRow(
              loc.eWalletServiceAdjustment,
              _formatSignedMoney(
                _adjustmentAmount,
              ),
              valueColor:
                  _adjustmentAmount <
                          0
                      ? const Color(
                          0xFF16813B,
                        )
                      : const Color(
                          0xFFE65100,
                        ),
            ),
          ],

          const Padding(
            padding:
                EdgeInsets.symmetric(
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
                  loc.eWalletTotalPayment,
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

              const SizedBox(
                width: 20,
              ),

              Text(
                _formatMoney(
                  _totalAmount,
                ),
                style:
                    const TextStyle(
                  color:
                      _primaryColor,
                  fontSize: 43,
                  fontWeight:
                      FontWeight
                          .w900,
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
              loc.eWalletProcessingTime,
              _getEWalletProcessingTime(
                loc,
              ),
            ),


          const SizedBox(
            height: 15,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              18,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFFF5EF,
              ),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons
                      .verified_user_rounded,
                  color:
                      _primaryColor,
                  size: 27,
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    loc.eWalletLatestPricingInfo,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF795548,
                      ),
                      fontSize: 21,
                      fontWeight:
                          FontWeight
                              .w700,
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

  // ==========================================================================
  // BOTTOM BUTTONS
  // ==========================================================================

  Widget _buildBottomButtons(
    AppLocalizations loc,
  ) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 92,
            child:
                ElevatedButton.icon(
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
                Icons
                    .arrow_back_rounded,

                // Bigger arrow.
                size: 38,
              ),
              label: Text(
                loc.buttonBack
                    .toUpperCase(),
                textAlign:
                    TextAlign.center,
                maxLines: 1,
                style:
                    const TextStyle(
                  // Larger back text.
                  fontSize: 31,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.white,
                foregroundColor:
                    const Color(
                  0xFF17283E,
                ),
                elevation: 2,
                side:
                    const BorderSide(
                  color:
                      Color(
                    0xFFC7CFD8,
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
            height: 92,
            child:
                ElevatedButton(
              onPressed:
                  _isNavigating
                      ? null
                      : _handleContinue,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    _greenColor,
                foregroundColor:
                    Colors.white,
                elevation: 4,
                shadowColor:
                    _greenColor
                        .withOpacity(
                  0.25,
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
              child:
                  _isNavigating
                      ? const SizedBox(
                          width: 38,
                          height: 38,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 4,
                            color:
                                Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Flexible(
                              child: Text(
                                loc.eWalletContinuePayment
                                    .toUpperCase(),
                                textAlign:
                                    TextAlign.center,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  // Large but safer than 40.
                                  fontSize: 32,

                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            const Icon(
                              Icons
                                  .arrow_forward_rounded,
                              size: 38,
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // STANDARD SUMMARY ROW
  // ==========================================================================

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
            style:
                const TextStyle(
              color:
                  Color(
                0xFF53677E,
              ),
              fontSize: 24,
              fontWeight:
                  FontWeight
                      .w700,
            ),
          ),
        ),

        const SizedBox(
          width: 20,
        ),

        Text(
          value,
          textAlign:
              TextAlign.right,
          style:
              TextStyle(
            color:
                valueColor ??
                    const Color(
                      0xFF102A43,
                    ),
            fontSize: 25,
            fontWeight:
                FontWeight
                    .w900,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TNG LARGE SUMMARY ROW
  // ==========================================================================

  Widget _compactSummaryRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style:
                  TextStyle(
                color:
                    const Color(
                  0xFF302C31,
                ),

                // Large labels.
                fontSize:
                    bold
                        ? 35
                        : 32,

                fontWeight:
                    bold
                        ? FontWeight
                            .w900
                        : FontWeight
                            .w800,

                height: 1.1,
              ),
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Text(
            value,
            style:
                TextStyle(
              color:
                  bold
                      ? _primaryColor
                      : const Color(
                          0xFF17283E,
                        ),

              // Large amount values.
              fontSize:
                  bold
                      ? 36
                      : 33,

              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SURCHARGE NOTICE
  // ==========================================================================

  Widget _buildProviderSurchargeNotice(
  AppLocalizations loc,
) {
  if (!_hasProviderSurcharge) {
    return const SizedBox.shrink();
  }

  final double surcharge =
      _providerSurchargeAmount;

  final double receivedAmount =
      (_reloadAmount - surcharge)
          .clamp(
            0,
            double.infinity,
          )
          .toDouble();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(
      20,
    ),
    decoration: BoxDecoration(
      color: const Color(
        0xFFFFF7E8,
      ),
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      border: Border.all(
        color: const Color(
          0xFFFFC65C,
        ),
        width: 2,
      ),
    ),
    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Color(
            0xFFE67E00,
          ),
          size: 34,
        ),

        const SizedBox(
          width: 14,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                loc.eWalletProviderSurchargeTitle,
                style:
                    const TextStyle(
                  color: Color(
                    0xFF7A5000,
                  ),
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                loc.eWalletProviderSurchargeMessage(
                  _formatMoney(
                    surcharge,
                  ),
                  _formatMoney(
                    _reloadAmount,
                  ),
                  _formatMoney(
                    receivedAmount,
                  ),
                ),
                style:
                    const TextStyle(
                  color: Color(
                    0xFF76520A,
                  ),
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w700,
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
}