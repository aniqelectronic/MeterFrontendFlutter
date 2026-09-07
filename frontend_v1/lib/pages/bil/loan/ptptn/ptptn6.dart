import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/bill/bil_qr_payment_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

import 'package:frontend_v1/pages/bil/loan/services/ptptn_subproduct_service.dart';

// ============================================================================
// PTPTN PAGE 6
// ============================================================================
//
// FLOW:
//
// PLOAN5
// Select PTPTN / SSPN Account
//        ↓
// PLOAN6
// Enter payment amount
//        ↓
// Read latest:
// GET /v2/catalog
//
// - amount min
// - amount max
// - processing_time
// - note
// - pricing / price_adjustment
//
//        ↓
// Order Summary
//        ↓
// Payment
//
// ============================================================================

class PTPTN6PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;

  final String nric;

  final PtptnSubproduct selectedAccount;

  const PTPTN6PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
    required this.nric,
    required this.selectedAccount,
  });

  @override
  State<PTPTN6PAGE> createState() =>
      _PTPTN6PAGEState();
}

class _PTPTN6PAGEState extends State<PTPTN6PAGE> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF4054C7);

  static const Color _darkColor =
      Color(0xFF263A9E);

  static const Color _primaryLight =
      Color(0xFFEEF1FF);

  static const Color _textDark =
      Color(0xFF17283E);

  static const Color _textMuted =
      Color(0xFF68778B);

  static const Color _borderColor =
      Color(0xFFD6DFEA);

  static const Color _greenColor =
      Color(0xFF168A50);

  static const double _amountStep =
      1.00;

  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final TextEditingController
      _amountController =
      TextEditingController();

  final ScrollController
      _scrollController =
      ScrollController();

  // ==========================================================================
  // CATALOG
  // ==========================================================================

  bool _isCatalogLoading = true;

  String? _catalogError;

  Map<String, dynamic>? _product;

  CatalogPricing _catalogPricing =
      const CatalogPricing.empty();

  double _minimumAmount = 0;
  double _maximumAmount = 0;

  String _processingTime = '';

  String _catalogNote = '';

  double _selectedAmount = 0;

  bool _isNavigating = false;

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  String get _productCode =>
      widget.productCode
          .trim()
          .toUpperCase();

  PtptnSubproduct get account =>
      widget.selectedAccount;

  BillPricingResult get _pricingResult =>
      BillPricingResult.calculate(
        billAmount: _selectedAmount,
        pricing: _catalogPricing,
      );

  double get _totalAmount =>
      _pricingResult.totalAmount;

  double get _serviceAdjustment =>
      _pricingResult.platformAdjustmentAmount;

  bool get _hasServiceAdjustment =>
      _serviceAdjustment.abs() >= 0.005;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _loadCatalog();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD PTPTN CATALOG
  // ==========================================================================

  Future<void> _loadCatalog() async {
    if (mounted) {
      setState(() {
        _isCatalogLoading = true;
        _catalogError = null;
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
          'Catalog products object is missing.',
        );
      }

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final dynamic rawProduct =
          products[_productCode];

      if (rawProduct is! Map) {
        throw Exception(
          'PTPTN product $_productCode '
          'was not found in catalog.',
        );
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      // ======================================================================
      // PRICING
      // ======================================================================

      final CatalogPricing pricing =
          CatalogPricing.fromCatalogResponse(
        catalogJson: catalog,
        productCode: _productCode,
      );

      // ======================================================================
      // PROCESSING TIME
      // ======================================================================

      final String processingTime =
          product['processing_time']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      // ======================================================================
      // NOTE
      // ======================================================================

      final String note =
          product['note']
                  ?.toString()
                  .trim() ??
              '';

      // ======================================================================
      // AMOUNT MIN / MAX
      //
      // Read:
      //
      // fields
      //   -> id = amount
      //      -> validation
      //          -> min
      //          -> max
      //
      // ======================================================================

      double minimum = 0;
      double maximum = 0;

      final dynamic fieldsRaw =
          product['fields'];

      if (fieldsRaw is List) {
        for (final dynamic rawField
            in fieldsRaw) {
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

          if (validationRaw is Map) {
            final Map<String, dynamic>
                validation =
                Map<String, dynamic>.from(
              validationRaw,
            );

            minimum =
                _toDouble(
              validation['min'],
            );

            maximum =
                _toDouble(
              validation['max'],
            );
          }

          break;
        }
      }

      // ======================================================================
      // FALLBACK TO DENOMINATION
      //
      // Only used when the amount field has no min/max.
      //
      // ======================================================================

      if (minimum <= 0 ||
          maximum <= 0) {
        final String denomination =
            product['denomination']
                    ?.toString()
                    .trim() ??
                '';

        final (double, double) range =
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

      // ======================================================================
      // REQUIRE VALID LIMIT
      // ======================================================================

      if (minimum <= 0 ||
          maximum <= 0 ||
          maximum < minimum) {
        throw Exception(
          'Invalid PTPTN payment limits.',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;

        _catalogPricing =
            pricing;

        _minimumAmount =
            minimum;

        _maximumAmount =
            maximum;

        _processingTime =
            processingTime;

        _catalogNote =
            note;

        _selectedAmount =
            minimum;

        _updateAmountController(
          minimum,
        );

        _isCatalogLoading =
            false;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'PTPTN PAYMENT CATALOG LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Product       : $_productCode',
      );
      debugPrint(
        'Minimum       : '
        'RM ${minimum.toStringAsFixed(2)}',
      );
      debugPrint(
        'Maximum       : '
        'RM ${maximum.toStringAsFixed(2)}',
      );
      debugPrint(
        'Processing    : $processingTime',
      );
      debugPrint(
        'Note          : $note',
      );
      debugPrint(
        'Adjustment    : '
        '${pricing.priceAdjustment?.displayValue ?? '-'}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');
    } on IimmpactCatalogException catch (
        error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCatalogLoading =
            false;

        _catalogError =
            error.message;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'PTPTN payment catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isCatalogLoading =
            false;

        _catalogError =
            error.toString();
      });
    }
  }

  // ==========================================================================
  // DOUBLE
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

  // ==========================================================================
  // RANGE
  // ==========================================================================

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

  // ==========================================================================
  // MONEY
  // ==========================================================================

  String _formatAmount(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _formatInputAmount(
    double amount,
  ) {
    return amount.toStringAsFixed(2);
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
  // CATALOG NOTE LOCALIZATION
  // ==========================================================================

  String _localizedCatalogNote(
    AppLocalizations loc,
  ) {
    final String note = _catalogNote.trim();

    if (note.isEmpty) {
      return '';
    }

    // ------------------------------------------------------------------------
    // PTPTN surcharge note
    //
    // Example API:
    // "RM1 surcharge will be imposed on your payment.
    //  Example: Pay RM100, PTPTN receives RM99."
    //
    // We only take the surcharge amount from the API.
    // The sentence itself comes from ARB so it follows kiosk language.
    // ------------------------------------------------------------------------

    final RegExp surchargePattern = RegExp(
      r'RM\s*([0-9]+(?:\.[0-9]+)?)\s+surcharge',
      caseSensitive: false,
    );

    final RegExpMatch? match =
        surchargePattern.firstMatch(note);

    if (match != null) {
      final double? surcharge =
          double.tryParse(
        match.group(1) ?? '',
      );

      if (surcharge != null) {
        return loc.loanPtptnSurchargeNote(
          _formatAmount(surcharge),
        );
      }
    }

    // ------------------------------------------------------------------------
    // UNKNOWN / CHANGED NOTE
    //
    // If IIMMPACT changes the catalog note to something we don't recognize,
    // don't show an incorrect translation.
    //
    // Just display the original catalog note.
    // ------------------------------------------------------------------------

    return note;
  }

  // ==========================================================================
  // UPDATE CONTROLLER
  // ==========================================================================

  void _updateAmountController(
    double amount,
  ) {
    _amountController.text =
        _formatInputAmount(
      amount,
    );

    _amountController.selection =
        TextSelection.fromPosition(
      TextPosition(
        offset:
            _amountController
                .text.length,
      ),
    );
  }

  // ==========================================================================
  // SET AMOUNT
  // ==========================================================================

  void _setPaymentAmount(
    double amount,
  ) {
    if (_minimumAmount <= 0 ||
        _maximumAmount <= 0) {
      return;
    }

    final double safeAmount =
        amount.clamp(
      _minimumAmount,
      _maximumAmount,
    );

    setState(() {
      _selectedAmount =
          safeAmount;

      _updateAmountController(
        safeAmount,
      );
    });
  }

  // ==========================================================================
  // INCREASE
  // ==========================================================================

  void _increaseAmount() {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    if (_isCatalogLoading) {
      return;
    }

    if (_selectedAmount >=
        _maximumAmount) {
      _showMessage(
        loc.loanMaximumPayment(
          _formatAmount(
            _maximumAmount,
          ),
        ),
      );

      return;
    }

    _setPaymentAmount(
      _selectedAmount +
          _amountStep,
    );
  }

  // ==========================================================================
  // DECREASE
  // ==========================================================================

  void _decreaseAmount() {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    if (_isCatalogLoading) {
      return;
    }

    if (_selectedAmount <=
        _minimumAmount) {
      _showMessage(
        loc.loanMinimumPayment(
          _formatAmount(
            _minimumAmount,
          ),
        ),
      );

      return;
    }

    _setPaymentAmount(
      _selectedAmount -
          _amountStep,
    );
  }

  // ==========================================================================
  // CUSTOM KEYBOARD
  // ==========================================================================

  void _openAmountKeyboard() {
    if (_isCatalogLoading ||
        _minimumAmount <= 0 ||
        _maximumAmount <= 0) {
      return;
    }

    final loc =
        AppLocalizations.of(
      context,
    )!;

    String temporaryValue =
        _amountController.text;

    showGeneralDialog<void>(
      context: context,

      barrierDismissible:
          false,

      barrierLabel:
          loc.loanKeyboardTitle,

      barrierColor:
          Colors.black.withOpacity(
        0.58,
      ),

      transitionDuration:
          const Duration(
        milliseconds: 220,
      ),

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
            // ================================================================
            // REFRESH TEMP VALUE
            // ================================================================

            void updateTemporary(
              String newValue,
            ) {
              temporaryValue =
                  newValue;

              setKeyboardState(
                () {},
              );
            }

            // ================================================================
            // NUMBER
            // ================================================================

            void pressNumber(
              String number,
            ) {
              if (temporaryValue ==
                      '0.00' ||
                  temporaryValue ==
                      '0') {
                updateTemporary(
                  number,
                );

                return;
              }

              if (temporaryValue
                  .contains('.')) {
                final List<String>
                    parts =
                    temporaryValue
                        .split('.');

                if (parts.length >
                        1 &&
                    parts.last.length >=
                        2) {
                  return;
                }
              }

              final String prospective =
                  '$temporaryValue'
                  '$number';

              final double? parsed =
                  double.tryParse(
                prospective,
              );

              if (parsed != null &&
                  parsed >
                      _maximumAmount) {
                return;
              }

              if (prospective.length >
                  10) {
                return;
              }

              updateTemporary(
                prospective,
              );
            }

            // ================================================================
            // DECIMAL
            // ================================================================

            void pressDecimal() {
              if (temporaryValue
                  .contains('.')) {
                return;
              }

              if (temporaryValue
                  .isEmpty) {
                updateTemporary(
                  '0.',
                );

                return;
              }

              updateTemporary(
                '$temporaryValue.',
              );
            }

            // ================================================================
            // DELETE
            // ================================================================

            void pressDelete() {
              if (temporaryValue
                  .isEmpty) {
                return;
              }

              updateTemporary(
                temporaryValue.substring(
                  0,
                  temporaryValue.length -
                      1,
                ),
              );
            }

            // ================================================================
            // CLEAR
            // ================================================================

            void pressClear() {
              updateTemporary(
                '',
              );
            }

            // ================================================================
            // CANCEL
            // ================================================================

            void pressCancel() {
              Navigator.pop(
                dialogContext,
              );
            }

            // ================================================================
            // DONE
            // ================================================================

            void pressDone() {
              final double entered =
                  double.tryParse(
                        temporaryValue,
                      ) ??
                      0;

              if (entered <
                  _minimumAmount) {
                Navigator.pop(
                  dialogContext,
                );

                _showMessage(
                  loc.loanMinimumPayment(
                    _formatAmount(
                      _minimumAmount,
                    ),
                  ),
                );

                return;
              }

              if (entered >
                  _maximumAmount) {
                Navigator.pop(
                  dialogContext,
                );

                _showMessage(
                  loc.loanMaximumPayment(
                    _formatAmount(
                      _maximumAmount,
                    ),
                  ),
                );

                return;
              }

              _setPaymentAmount(
                entered,
              );

              Navigator.pop(
                dialogContext,
              );
            }

            // ================================================================
            // UI
            // ================================================================

            return Material(
              color:
                  Colors.transparent,

              child: SafeArea(
                child: Center(
                  child: Container(
                    width: 720,

                    margin:
                        const EdgeInsets.all(
                      35,
                    ),

                    padding:
                        const EdgeInsets.fromLTRB(
                      35,
                      32,
                      35,
                      35,
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
                              Colors.black.withOpacity(
                            0.30,
                          ),

                          blurRadius:
                              35,

                          offset:
                              const Offset(
                            0,
                            16,
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
                          // ==================================================
                          // HEADER
                          // ==================================================

                          Row(
                            children: [
                              Container(
                                width: 65,
                                height: 65,

                                decoration:
                                    BoxDecoration(
                                  color:
                                      _primaryLight,

                                  borderRadius:
                                      BorderRadius.circular(
                                    18,
                                  ),
                                ),

                                child:
                                    const Icon(
                                  Icons
                                      .keyboard_alt_rounded,

                                  color:
                                      _primaryColor,

                                  size: 38,
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
                                      loc.loanEnterPaymentAmount,

                                      style:
                                          const TextStyle(
                                        color:
                                            _textDark,

                                        fontSize:
                                            30,

                                        fontWeight:
                                            FontWeight
                                                .w900,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      loc.loanUseKeypad,

                                      style:
                                          const TextStyle(
                                        color:
                                            _textMuted,

                                        fontSize:
                                            20,

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
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // ==================================================
                          // AMOUNT DISPLAY
                          // ==================================================

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
                                  BorderRadius.circular(
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
                                        _textMuted,

                                    fontSize:
                                        34,

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
                                          _textDark,

                                      fontSize:
                                          46,

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
                            height: 15,
                          ),

                          Align(
                            alignment:
                                Alignment
                                    .centerLeft,

                            child: Text(
                              loc.loanPaymentRange(
                                _formatAmount(
                                  _minimumAmount,
                                ),
                                _formatAmount(
                                  _maximumAmount,
                                ),
                              ),

                              style:
                                  const TextStyle(
                                color:
                                    _textMuted,

                                fontSize:
                                    18,

                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // ==================================================
                          // KEYS
                          // ==================================================

                          _keyboardRow(
                            [
                              _numberKey(
                                '1',
                                () =>
                                    pressNumber(
                                  '1',
                                ),
                              ),
                              _numberKey(
                                '2',
                                () =>
                                    pressNumber(
                                  '2',
                                ),
                              ),
                              _numberKey(
                                '3',
                                () =>
                                    pressNumber(
                                  '3',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _keyboardRow(
                            [
                              _numberKey(
                                '4',
                                () =>
                                    pressNumber(
                                  '4',
                                ),
                              ),
                              _numberKey(
                                '5',
                                () =>
                                    pressNumber(
                                  '5',
                                ),
                              ),
                              _numberKey(
                                '6',
                                () =>
                                    pressNumber(
                                  '6',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _keyboardRow(
                            [
                              _numberKey(
                                '7',
                                () =>
                                    pressNumber(
                                  '7',
                                ),
                              ),
                              _numberKey(
                                '8',
                                () =>
                                    pressNumber(
                                  '8',
                                ),
                              ),
                              _numberKey(
                                '9',
                                () =>
                                    pressNumber(
                                  '9',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _keyboardRow(
                            [
                              _numberKey(
                                '.',
                                pressDecimal,
                              ),
                              _numberKey(
                                '0',
                                () =>
                                    pressNumber(
                                  '0',
                                ),
                              ),
                              _iconKey(
                                Icons
                                    .backspace_outlined,
                                pressDelete,
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 26,
                          ),

                          // ==================================================
                          // CLEAR / DONE
                          // ==================================================

                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 78,

                                  child:
                                      OutlinedButton.icon(
                                    onPressed:
                                        pressClear,

                                    icon:
                                        const Icon(
                                      Icons
                                          .delete_sweep_outlined,

                                      size: 29,
                                    ),

                                    label:
                                        Text(
                                      loc.loanClear,

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            22,

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

                                child: SizedBox(
                                  height: 78,

                                  child:
                                      ElevatedButton.icon(
                                    onPressed:
                                        pressDone,

                                    icon:
                                        const Icon(
                                      Icons
                                          .check_circle_rounded,

                                      size: 31,
                                    ),

                                    label:
                                        Text(
                                      loc.loanDone,

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            24,

                                        fontWeight:
                                            FontWeight
                                                .w900,
                                      ),
                                    ),

                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _greenColor,

                                      foregroundColor:
                                          Colors.white,
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

                            height: 65,

                            child:
                                TextButton.icon(
                              onPressed:
                                  pressCancel,

                              icon:
                                  const Icon(
                                Icons.close_rounded,
                              ),

                              label:
                                  Text(
                                loc.loanCancel,

                                style:
                                    const TextStyle(
                                  fontSize:
                                      21,

                                  fontWeight:
                                      FontWeight
                                          .w800,
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
  // KEYBOARD ROW
  // ==========================================================================

  Widget _keyboardRow(
    List<Widget> children,
  ) {
    return Row(
      children: [
        Expanded(
          child:
              children[0],
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(
          child:
              children[1],
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(
          child:
              children[2],
        ),
      ],
    );
  }

  // ==========================================================================
  // NUMBER KEY
  // ==========================================================================

  Widget _numberKey(
    String label,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 90,

      child:
          ElevatedButton(
        onPressed:
            onPressed,

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              Colors.white,

          foregroundColor:
              _textDark,

          elevation:
              1,

          side:
              const BorderSide(
            color:
                _borderColor,

            width: 2,
          ),
        ),

        child: Text(
          label,

          style:
              const TextStyle(
            fontSize: 37,

            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ICON KEY
  // ==========================================================================

  Widget _iconKey(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 90,

      child:
          ElevatedButton(
        onPressed:
            onPressed,

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(
            0xFFFFF3E0,
          ),

          foregroundColor:
              const Color(
            0xFFE65100,
          ),

          elevation:
              1,
        ),

        child: Icon(
          icon,
          size: 38,
        ),
      ),
    );
  }

  // ==========================================================================
  // PROCESSING TIME
  // ==========================================================================

  String _getProcessingTime(
    AppLocalizations loc,
  ) {
    final String value =
        _processingTime
            .trim()
            .toLowerCase();

    if (value.isEmpty) {
      return '-';
    }

    if (value ==
        'instant') {
      return loc
          .processingInstant;
    }

    final RegExpMatch? hoursMatch =
        RegExp(
      r'^(\d+)_hours?$',
    ).firstMatch(
      value,
    );

    if (hoursMatch != null) {
      return loc
          .loanProcessingWithinHours(
        hoursMatch.group(1) ??
            '',
      );
    }

    final RegExpMatch? daysMatch =
        RegExp(
      r'^(\d+)_days?$',
    ).firstMatch(
      value,
    );

    if (daysMatch != null) {
      return loc
          .loanProcessingWithinDays(
        daysMatch.group(1) ??
            '',
      );
    }

    return value.replaceAll(
      '_',
      ' ',
    );
  }

  // ==========================================================================
  // CONTINUE
  // ==========================================================================

  Future<void> _handleContinue() async {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    if (_isNavigating ||
        _isCatalogLoading) {
      return;
    }

    if (_selectedAmount <
        _minimumAmount) {
      _showMessage(
        loc.loanMinimumPayment(
          _formatAmount(
            _minimumAmount,
          ),
        ),
      );

      return;
    }

    if (_selectedAmount >
        _maximumAmount) {
      _showMessage(
        loc.loanMaximumPayment(
          _formatAmount(
            _maximumAmount,
          ),
        ),
      );

      return;
    }

    setState(() {
      _isNavigating =
          true;
    });

    try {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'PTPTN PAYMENT READY',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Product Code     : $_productCode',
      );
      debugPrint(
        'NRIC             : ${widget.nric}',
      );
      debugPrint(
        'Account Number   : ${account.accountNumber}',
      );
      debugPrint(
        'Subproduct Code  : ${account.subproductCode}',
      );
      debugPrint(
        'Amount           : $_selectedAmount',
      );
      debugPrint(
        'Total            : $_totalAmount',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // QR PAYMENT
      // ======================================================================

      final BilQrPaymentResult? result =
          await Navigator.push<
              BilQrPaymentResult>(
        context,

        MaterialPageRoute(
          settings:
              const RouteSettings(
            name: '/payment',
          ),

          builder:
              (_) =>
                  BilQrPaymentPage(
            // ========================================================================
            // NORMAL PAYMENT
            // ========================================================================

            billType:
                widget.providerName,

            billCode:
                _productCode,

            // IMPORTANT:
            // Use PTPTN/SSPN account returned from /v2/subproducts.
            // Do NOT use NRIC as the payment account.
            accountNumber:
                account.accountNumber,

            billAmount:
                _selectedAmount,

            totalAmount:
                _totalAmount,

            // ========================================================================
            // PTPTN RECEIPT
            // ========================================================================

            usePtptnReceipt:
                true,

            ptptnNric:
                widget.nric,

            ptptnSubproductCode:
                account.subproductCode,

            ptptnAccountType:
                account.displayName,

            ptptnAccountCategory:
                account.description,

            ptptnServiceAdjustment:
                _serviceAdjustment,

            // ========================================================================
            // IIMMPACT /v2/topup
            // ========================================================================
            //
            // The Sub Products API says the selected code must be passed as
            // extras.subproduct_code.
            //
            // U  = Ujrah
            // K  = Conventional
            // S  = SSPN Prime
            // SP = SSPN Plus
            //
            // ========================================================================

            iimmpactExtras: <String, dynamic>{
              'subproduct_code':
                  account.subproductCode,

              'ic_number':
                  widget.nric,
            },
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
        'PTPTN QR PAYMENT SUCCESS',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Order No    : '
        '${result.orderNo}',
      );
      debugPrint(
        'Bank Trx    : '
        '${result.bankTransactionNo}',
      );
      debugPrint(
        'Amount      : '
        '${result.billAmount}',
      );
      debugPrint(
        'Total       : '
        '${result.totalAmount}',
      );
      debugPrint(
        '========================================',
      );

      // ======================================================================
      // NEXT:
      //
      // Call POST /v2/topup using:
      //
      // product = PTPTN
      //
      // account =
      // account.accountNumber
      //
      // amount =
      // result.billAmount
      //
      // extras = {
      //   "ic_number": widget.nric,
      //   "subproduct_code":
      //       account.subproductCode,
      //   "product_code":
      //       account.subproductCode,
      // }
      //
      // Then go to PTPTN receipt page.
      //
      // ======================================================================
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
  // MESSAGE
  // ==========================================================================

  void _showMessage(
    String message,
  ) {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    showGeneralDialog<void>(
      context: context,

      barrierDismissible:
          false,

      barrierLabel:
          loc.loanInformation,

      barrierColor:
          Colors.black.withOpacity(
        0.62,
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
        final CurvedAnimation curved =
            CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,

          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.88,
              end: 1.0,
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
        return SafeArea(
          child: Center(
            child: Material(
              color:
                  Colors.transparent,

              child: Container(
                width: 700,

                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 45,
                ),

                padding:
                    const EdgeInsets.fromLTRB(
                  42,
                  38,
                  42,
                  38,
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
                        _primaryColor
                            .withOpacity(
                      0.38,
                    ),

                    width: 3,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(
                        0.28,
                      ),

                      blurRadius:
                          40,

                      offset:
                          const Offset(
                        0,
                        18,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    // ==========================================================
                    // ICON
                    // ==========================================================

                    Container(
                      width: 115,
                      height: 115,

                      decoration:
                          BoxDecoration(
                        color:
                            _primaryColor
                                .withOpacity(
                          0.11,
                        ),

                        shape:
                            BoxShape.circle,
                      ),

                      child:
                          const Icon(
                        Icons
                            .info_outline_rounded,

                        color:
                            _primaryColor,

                        size: 68,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==========================================================
                    // TITLE
                    // ==========================================================

                    Text(
                      loc.loanInformation
                          .toUpperCase(),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            _textDark,

                        fontSize:
                            40,

                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ==========================================================
                    // MESSAGE
                    // ==========================================================

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF5F7FF,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),

                        border:
                            Border.all(
                          color:
                              _primaryColor
                                  .withOpacity(
                            0.22,
                          ),

                          width: 2,
                        ),
                      ),

                      child: Text(
                        message,

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          color:
                              _textDark,

                          fontSize:
                              30,

                          fontWeight:
                              FontWeight
                                  .w800,

                          height:
                              1.35,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ==========================================================
                    // OK
                    // ==========================================================

                    SizedBox(
                      width:
                          double.infinity,

                      height:
                          88,

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
                              .check_circle_rounded,

                          size: 32,
                        ),

                        label:
                            Text(
                          loc.loanOkButton
                              .toUpperCase(),

                          style:
                              const TextStyle(
                            fontSize:
                                29,

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

                          elevation:
                              3,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              21,
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
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset(
              'lib/images/pnew.png',

              fit:
                  BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ============================================================
                // HEADER
                // ============================================================

                _buildHeader(
                  loc,
                ),

                // ============================================================
                // CONTENT
                // ============================================================

                Expanded(
                  child:
                      _isCatalogLoading
                          ? _buildLoading(
                              loc,
                            )
                          : _catalogError !=
                                  null
                              ? _buildError(
                                  loc,
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    right:
                                        18,
                                  ),

                                  child:
                                      Scrollbar(
                                    controller:
                                        _scrollController,

                                    thumbVisibility:
                                        true,

                                    thickness:
                                        10,

                                    child:
                                        SingleChildScrollView(
                                      controller:
                                          _scrollController,

                                      padding:
                                          const EdgeInsets.fromLTRB(
                                        45,
                                        30,
                                        45,
                                        30,
                                      ),

                                      child:
                                          Column(
                                        children: [
                                          _buildAccountInformation(
                                            loc,
                                          ),

                                          if (_catalogNote
                                              .isNotEmpty) ...[
                                            const SizedBox(
                                              height:
                                                  28,
                                            ),

                                            _buildNote(
                                              loc,
                                            ),
                                          ],

                                          const SizedBox(
                                            height:
                                                30,
                                          ),

                                          _buildAmountSection(
                                            loc,
                                          ),

                                          const SizedBox(
                                            height:
                                                30,
                                          ),

                                          _buildOrderSummary(
                                            loc,
                                          ),

                                          const SizedBox(
                                            height:
                                                50,
                                          ),

                                          _buildActions(
                                            loc,
                                          ),

                                          const SizedBox(
                                            height:
                                                35,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                ),

                // ============================================================
                // COPYRIGHT
                // ============================================================

                Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 18,
                  ),

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
                          FontWeight
                              .w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================================================================
          // NAVIGATION LOCK
          // ==================================================================

          if (_isNavigating)
            Positioned.fill(
              child: Container(
                color:
                    Colors.black.withOpacity(
                  0.25,
                ),

                child:
                    const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        _primaryColor,

                    strokeWidth:
                        6,
                  ),
                ),
              ),
            ),
        ],
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
        45,
        30,
        45,
        0,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 24,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        border:
            Border.all(
          color:
              _primaryColor,

          width: 2.5,
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Container(
            width: 65,
            height: 65,

            decoration:
                BoxDecoration(
              color:
                  _primaryLight,

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child:
                const Icon(
              Icons
                  .payments_rounded,

              color:
                  _primaryColor,

              size: 39,
            ),
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(
            child:
                Column(
              children: [
                Text(
                  loc.loanPaymentTitle
                      .toUpperCase(),

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        _darkColor,

                    fontSize:
                        40,

                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  loc.loanPaymentSubtitle,

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        _textMuted,

                    fontSize:
                        22,

                    fontWeight:
                        FontWeight
                            .w600,
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
  // ACCOUNT INFORMATION
  // ==========================================================================

  Widget _buildAccountInformation(
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
              _borderColor,

          width: 2,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            loc.loanAccountInformation,

            style:
                const TextStyle(
              color:
                  _textDark,

              fontSize:
                  35,

              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          _informationRow(
            Icons.badge_rounded,
            loc.loanNricLabel,
            widget.nric,
          ),

          const Divider(
            height: 32,
          ),

          _informationRow(
            Icons
                .school_rounded,
            loc.loanAccountType,
            account.displayName,
          ),

          const Divider(
            height: 32,
          ),

          _informationRow(
            Icons
                .account_balance_wallet_outlined,
            loc.loanAccountNumber,
            account.accountNumber,
          ),

          const Divider(
            height: 32,
          ),

          _informationRow(
            Icons
                .category_rounded,
            loc.loanAccountCategory,
            account.description,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INFORMATION ROW
  // ==========================================================================

  Widget _informationRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,

          color:
              _primaryColor,

          size: 34,
        ),

        const SizedBox(
          width: 18,
        ),

        Expanded(
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style:
                    const TextStyle(
                  color:
                      _textMuted,

                  fontSize:
                      23,

                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                value.isEmpty
                    ? '-'
                    : value,

                style:
                    const TextStyle(
                  color:
                      _textDark,

                  fontSize:
                      29,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // NOTE
  // ==========================================================================

  Widget _buildNote(
    AppLocalizations loc,
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
        color:
            const Color(
          0xFFFFF8E1,
        ),

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFFFCC80,
          ),

          width: 2,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons
                .info_outline_rounded,

            color:
                Color(
              0xFFE07B00,
            ),

            size: 36,
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  loc.loanImportantNote,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF9A5700,
                    ),

                    fontSize:
                        27,

                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  _localizedCatalogNote(
                    loc,
                  ),
                  style: const TextStyle(
                    color: Color(
                      0xFF745021,
                    ),
                    fontSize: 22,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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
  // AMOUNT
  // ==========================================================================

  Widget _buildAmountSection(
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
              _borderColor,

          width: 2,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            loc.loanSelectPaymentAmount,

            style:
                const TextStyle(
              color:
                  _textDark,

              fontSize:
                  35,

              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            loc.loanAmountInstruction,

            style:
                const TextStyle(
              color:
                  _textMuted,

              fontSize:
                  22,

              fontWeight:
                  FontWeight
                      .w600,
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          Row(
            children: [
              const Text(
                'RM',

                style:
                    TextStyle(
                  color:
                      _textMuted,

                  fontSize:
                      34,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              Expanded(
                child:
                    Material(
                  color:
                      Colors.transparent,

                  child:
                      InkWell(
                    onTap:
                        _openAmountKeyboard,

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),

                    child:
                        Container(
                      height:
                          95,

                      alignment:
                          Alignment.center,

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          20,
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
                          Text(
                        _amountController
                                .text
                                .isEmpty
                            ? '0.00'
                            : _amountController
                                .text,

                        style:
                            const TextStyle(
                          color:
                              _textDark,

                          fontSize:
                              34,

                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              SizedBox(
                width: 90,
                height: 95,

                child:
                    ElevatedButton(
                  onPressed:
                      _decreaseAmount,

                  child:
                      const Icon(
                    Icons
                        .remove_rounded,

                    size: 50,
                  ),
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              SizedBox(
                width: 90,
                height: 95,

                child:
                    ElevatedButton(
                  onPressed:
                      _increaseAmount,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        _greenColor,

                    foregroundColor:
                        Colors.white,
                  ),

                  child:
                      const Icon(
                    Icons
                        .add_rounded,

                    size: 50,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            loc.loanPaymentRange(
              _formatAmount(
                _minimumAmount,
              ),
              _formatAmount(
                _maximumAmount,
              ),
            ),

            style:
                const TextStyle(
              color:
                  _textMuted,

              fontSize:
                  21,

              fontWeight:
                  FontWeight
                      .w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ORDER SUMMARY
  // ==========================================================================

  Widget _buildOrderSummary(
    AppLocalizations loc,
  ) {
    final bool isFee =
        _serviceAdjustment >
            0;

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
              _borderColor,

          width: 2,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            loc.loanOrderSummary,

            style:
                const TextStyle(
              color:
                  _textDark,

              fontSize:
                  35,

              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          _summaryRow(
            loc.loanPaymentAmount,
            _formatAmount(
              _selectedAmount,
            ),
          ),

          if (_hasServiceAdjustment) ...[
            const Divider(
              height: 38,
            ),

            _summaryRow(
              isFee
                  ? loc.loanServiceFee
                  : loc
                      .loanServiceAdjustment,

              _formatSignedAmount(
                _serviceAdjustment,
              ),

              valueColor:
                  isFee
                      ? const Color(
                          0xFFE65100,
                        )
                      : _greenColor,
            ),
          ],

          const Divider(
            height: 38,
          ),

          _summaryRow(
            loc.loanTotalPayment,

            _formatAmount(
              _totalAmount,
            ),

            isTotal:
                true,
          ),

          const Divider(
            height: 38,
          ),

          _summaryRow(
            loc.loanProcessingTime,

            _getProcessingTime(
              loc,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SUMMARY ROW
  // ==========================================================================

  Widget _summaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,

            style:
                TextStyle(
              color:
                  isTotal
                      ? _textDark
                      : _textMuted,

              fontSize:
                  isTotal
                      ? 29
                      : 24,

              fontWeight:
                  isTotal
                      ? FontWeight
                          .w900
                      : FontWeight
                          .w700,
            ),
          ),
        ),

        const SizedBox(
          width: 20,
        ),

        Text(
          value,

          style:
              TextStyle(
            color:
                valueColor ??
                    (isTotal
                        ? _greenColor
                        : _textDark),

            fontSize:
                isTotal
                    ? 32
                    : 26,

            fontWeight:
                FontWeight
                    .w900,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

  Widget _buildActions(
    AppLocalizations loc,
  ) {
    return Row(
      children: [
        // ============================================================
        // BACK BUTTON
        // ============================================================

        Expanded(
          flex: 4,
          child: SizedBox(
            height: 100,
            child: OutlinedButton.icon(
              onPressed: _isNavigating
                  ? null
                  : () {
                      Navigator.pop(context);
                    },

              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 28,
              ),

              label: Text(
                loc.buttonBack.toUpperCase(),
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor: _textDark,
                backgroundColor: Colors.white,

                side: const BorderSide(
                  color: _textDark,
                  width: 2,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 20,
        ),

        // ============================================================
        // CONTINUE BUTTON
        // ============================================================

        Expanded(
          flex: 6,
          child: SizedBox(
            height: 100,
            child: ElevatedButton.icon(
              onPressed:
                  _isCatalogLoading ||
                          _catalogError != null ||
                          _isNavigating
                      ? null
                      : _handleContinue,

              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 29,
              ),

              label: Text(
                loc.loanContinue.toUpperCase(),
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // ==========================================================================
  // LOADING
  // ==========================================================================

  Widget _buildLoading(
    AppLocalizations loc,
  ) {
    return Center(
      child:
          Container(
        width: 600,

        padding:
            const EdgeInsets.all(
          40,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            32,
          ),
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const SizedBox(
              width: 75,
              height: 75,

              child:
                  CircularProgressIndicator(
                strokeWidth:
                    6,

                color:
                    _primaryColor,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            Text(
              loc.loanPaymentLoadingTitle,

              style:
                  const TextStyle(
                color:
                    _textDark,

                fontSize:
                    34,

                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              loc.loanPaymentLoadingMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _textMuted,

                fontSize:
                    23,
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
      child:
          Container(
        width: 650,

        padding:
            const EdgeInsets.all(
          40,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            32,
          ),
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const Icon(
              Icons
                  .cloud_off_rounded,

              color:
                  Color(
                0xFFD32F2F,
              ),

              size: 80,
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              loc.loanPaymentLoadErrorTitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _textDark,

                fontSize:
                    34,

                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              loc.loanPaymentLoadErrorMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _textMuted,

                fontSize:
                    23,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    child:
                        Text(
                      loc.buttonBack,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _loadCatalog,

                    icon:
                        const Icon(
                      Icons
                          .refresh_rounded,
                    ),

                    label:
                        Text(
                      loc.loanRetry,
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _primaryColor,

                      foregroundColor:
                          Colors.white,
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
}