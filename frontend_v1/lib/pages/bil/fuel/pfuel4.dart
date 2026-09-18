import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_gaming_options_service.dart';
import 'package:frontend_v1/pages/payment/bill/fuel_qr_payment_page.dart';

// ============================================================================
// FUEL SELECTION RESULT
// ============================================================================

class DigitalVoucherSelectionResult {
  final String productCode;
  final String productName;
  final String imageUrl;

  final String fieldId;
  final String fieldType;

  final String? optionCode;
  final String? optionName;
  final String? optionDescription;

  final double baseAmount;
  final double adjustmentAmount;
  final double totalAmount;

  final String processingTime;

  // Localized customer-facing note.
  final String note;

  const DigitalVoucherSelectionResult({
    required this.productCode,
    required this.productName,
    required this.imageUrl,
    required this.fieldId,
    required this.fieldType,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.baseAmount,
    required this.adjustmentAmount,
    required this.totalAmount,
    required this.processingTime,
    required this.note,
  });
}

// ============================================================================
// FUEL PAGE 4
//
// API DRIVEN:
//
// catalog
//   -> product
//   -> pricing field
//
// type == select
//   -> /v2/options
//
// type == money
//   -> validation.min / validation.max
//
// ONLY PROVIDER NOTES ARE MAPPED TO ARB FOR LOCALIZATION.
// UNKNOWN PRODUCT:
//   -> fallback to original IIMMPACT note.
// ============================================================================

class PFUEL4PAGE extends StatefulWidget {
  final String productCode;
  final String productName;
  final String imageUrl;

  const PFUEL4PAGE({
    super.key,
    required this.productCode,
    required this.productName,
    required this.imageUrl,
  });

  @override
  State<PFUEL4PAGE> createState() =>
      _PFUEL4PAGEState();
}

class _PFUEL4PAGEState
    extends State<PFUEL4PAGE> {
  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  final TextEditingController _amountController =
      TextEditingController();

  // ==========================================================================
  // CATALOG
  // ==========================================================================

  Map<String, dynamic>? _product;
  Map<String, dynamic>? _pricingField;

  CatalogPricing _catalogPricing =
      CatalogPricing.empty();

  // ==========================================================================
  // SELECT FIELD
  // ==========================================================================

  List<GamingOption> _options = [];

  GamingOption? _selectedOption;

  // ==========================================================================
  // MONEY FIELD
  // ==========================================================================

  double _minimumAmount = 0;
  double _maximumAmount = 0;
  double _selectedAmount = 0;

  static const double _amountStep = 1.00;

  // ==========================================================================
  // PAGE STATE
  // ==========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFFD62828);

  static const Color _darkColor =
      Color(0xFF9F1D20);

  static const Color _lightColor =
      Color(0xFFFFE5E5);

  static const Color _greenColor =
      Color(0xFF16813B);

  static const Color _redColor =
      Color(0xFFD93A3A);

  // ==========================================================================
  // PRODUCT
  // ==========================================================================

  String get _code =>
      widget.productCode
          .trim()
          .toUpperCase();

  String get _productName {
    final String value =
        _product?['name']
                ?.toString()
                .trim() ??
            '';

    return value.isNotEmpty
        ? value
        : widget.productName;
  }

  String get _imageUrl {
    final String value =
        _product?['image_url']
                ?.toString()
                .trim() ??
            '';

    return value.isNotEmpty
        ? value
        : widget.imageUrl;
  }

  String get _processingTime =>
      _product?['processing_time']
              ?.toString()
              .trim() ??
          '';

  // ==========================================================================
  // ORIGINAL NOTE FROM IIMMPACT
  // ==========================================================================

  String get _rawNote =>
      _product?['note']
              ?.toString()
              .trim() ??
          '';

  // ==========================================================================
  // LOCALIZED PROVIDER NOTE
  //
  // Known Fuel products use ARB.
  //
  // If IIMMPACT adds a new Fuel later:
  //
  // default -> original English catalog note.
  //
  // This means a new product will NOT break the page.
  // ==========================================================================

String _localizedNote(
  AppLocalizations loc,
) {
  final String originalNote = _rawNote.trim();

  if (originalNote.isEmpty) {
    return '';
  }

  switch (_code) {
    // ========================================================================
    // SHELL
    // Hardcoded translations based on the selected kiosk language.
    // ========================================================================
    case 'SHELL':
      final String languageCode =
          Localizations.localeOf(context).languageCode.toLowerCase();

      switch (languageCode) {
        // Malay
        case 'ms':
          return 'Untuk menebus, tunjukkan baucar digital anda kepada juruwang.';

        // Mandarin Malaysia
        case 'zh':
          return '兑换时，请向收银员出示您的电子礼券。';

        // Tamil
        case 'ta':
          return 'மீட்டெடுக்க, உங்கள் மின்னணு வவுச்சரை காசாளரிடம் காட்டவும்.';

        // English and unsupported languages
        default:
          return 'To redeem, present your digital voucher to the cashier.';
      }

    // ========================================================================
    // NEW/UNKNOWN FUEL PROVIDER
    //
    // If IIMMPACT adds Petron, Petronas, Caltex or another provider,
    // display the original note received from the catalog.
    // ========================================================================
    default:
      return originalNote;
  }
}

  bool get _isProductActive =>
      _product?['is_active'] == true;

  // ==========================================================================
  // PRICING FIELD
  // ==========================================================================

  String get _fieldId =>
      _pricingField?['id']
              ?.toString()
              .trim() ??
          '';

  String get _fieldType =>
      _pricingField?['type']
              ?.toString()
              .trim()
              .toLowerCase() ??
          '';

  bool get _isSelectField =>
      _fieldType == 'select';

  bool get _isMoneyField =>
      _fieldType == 'money';

  // ==========================================================================
  // SELECTED BASE AMOUNT
  // ==========================================================================

  double get _selectedBaseAmount {
    if (_isSelectField) {
      return _selectedOption
              ?.priceAmount ??
          0;
    }

    if (_isMoneyField) {
      return _selectedAmount;
    }

    return 0;
  }


  List<double> get _catalogDenominations {
  final String raw =
      _product?['denomination']
              ?.toString()
              .trim() ??
          '';

  if (raw.isEmpty) {
    return const [];
  }

  // Range products such as "1-5000"
  // are handled by money field and do not need
  // select denomination mapping here.
  if (raw.contains('-')) {
    return const [];
  }

  return raw
      .split(',')
      .map(
        (String value) =>
            double.tryParse(
              value.trim(),
            ),
      )
      .whereType<double>()
      .toList();
}

double get _selectedTopupAmount {
  // ========================================================================
  // MONEY FIELD
  //
  // User-selected amount itself is the denomination.
  //
  // Example:
  // Shopee RM100
  // -> topup amount = 100
  // ========================================================================

  if (_isMoneyField) {
    return _selectedAmount;
  }

  // ========================================================================
  // SELECT FIELD
  // ========================================================================

  if (_isSelectField) {
    final GamingOption? selected =
        _selectedOption;

    if (selected == null) {
      return 0;
    }

    final List<double> denominations =
        _catalogDenominations;

    // ======================================================================
    // If catalog denomination count matches options count,
    // map selected option to the same position.
    //
    // Example DISCORD:
    //
    // denominations:
    // [1, 12]
    //
    // options:
    // [Monthly RM43, Yearly RM432]
    //
    // Monthly -> 1
    // Yearly  -> 12
    // ======================================================================

    if (denominations.length ==
            _options.length &&
        denominations.isNotEmpty) {
      final int index =
          _options.indexOf(
        selected,
      );

      if (index >= 0 &&
          index <
              denominations.length) {
        return denominations[index];
      }
    }

    // ======================================================================
    // Normal vouchers:
    //
    // denomination and option price are already the same.
    //
    // ECT:
    // denomination 50,100
    //
    // GM:
    // denomination 10,20
    //
    // so priceAmount is safe as fallback.
    // ======================================================================

    return selected.priceAmount;
  }

  return 0;
}

  // ==========================================================================
  // PRICE ADJUSTMENT
  // ==========================================================================

  PriceAdjustmentResult
      get _priceAdjustmentResult {
    final adjustment =
        _catalogPricing
            .priceAdjustment;

    if (adjustment == null) {
      return PriceAdjustmentResult
          .none(
        _selectedBaseAmount,
      );
    }

    return adjustment.apply(
      _selectedBaseAmount,
    );
  }

  double get _adjustmentAmount =>
      _priceAdjustmentResult
          .adjustmentAmount;

  double get _totalAmount =>
      _priceAdjustmentResult
          .amountAfter;

  bool get _hasAdjustment =>
      _adjustmentAmount.abs() >=
      0.005;

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _loadProduct();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD PRODUCT
  // ==========================================================================

  Future<void> _loadProduct() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;

        _options = [];
        _selectedOption = null;

        _minimumAmount = 0;
        _maximumAmount = 0;
        _selectedAmount = 0;
      });
    }

    try {
      // ======================================================================
      // CATALOG
      // ======================================================================

      final Map<String, dynamic>
          catalog =
          await IimmpactCatalogService
              .getCatalog();

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products are missing.',
        );
      }

      // ======================================================================
      // PRODUCT
      // ======================================================================

      final dynamic rawProduct =
          productsRaw[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'Fuel voucher $_code '
          'was not found in catalog.',
        );
      }

      final Map<String, dynamic>
          product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      // ======================================================================
      // ACTIVE
      // ======================================================================

      if (product['is_active'] !=
          true) {
        throw Exception(
          'Fuel voucher $_code '
          'is currently inactive.',
        );
      }

      // ======================================================================
      // PRICING
      // ======================================================================

      final CatalogPricing pricing =
          CatalogPricing
              .fromCatalogResponse(
        catalogJson: catalog,
        productCode: _code,
      );

      // ======================================================================
      // FIND PRICING FIELD
      // ======================================================================

      final Map<String, dynamic>?
          field =
          _findPricingField(
        product,
      );

      if (field == null) {
        throw Exception(
          'Pricing field not found '
          'for $_code.',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _pricingField = field;
        _catalogPricing = pricing;
      });

      // ======================================================================
      // FIELD TYPE
      // ======================================================================

      final String type =
          field['type']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      // ======================================================================
      // SELECT
      // ======================================================================

      if (type == 'select') {
        await _loadSelectOptions(
          field,
        );
      }

      // ======================================================================
      // MONEY
      // ======================================================================

      else if (type == 'money') {
        _loadMoneyConfiguration(
          product: product,
          field: field,
        );
      }

      // ======================================================================
      // UNSUPPORTED
      // ======================================================================

      else {
        throw Exception(
          'Unsupported Fuel '
          'pricing field type: $type',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'FUEL PAGE 4 LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Code       : $_code',
      );
      debugPrint(
        'Product    : $_productName',
      );
      debugPrint(
        'Field ID   : $_fieldId',
      );
      debugPrint(
        'Field Type : $_fieldType',
      );
      debugPrint(
        'Processing : $_processingTime',
      );
      debugPrint(
        'Raw note   : $_rawNote',
      );

      if (_isSelectField) {
        debugPrint(
          'Options    : ${_options.length}',
        );
      }

      if (_isMoneyField) {
        debugPrint(
          'Minimum    : $_minimumAmount',
        );

        debugPrint(
          'Maximum    : $_maximumAmount',
        );
      }

      debugPrint(
        '========================================',
      );
      debugPrint('');
    } on IimmpactCatalogException catch (
      error
    ) {
      _setLoadError(
        error.message,
      );
    } on GamingOptionsException catch (
      error
    ) {
      _setLoadError(
        error.message,
      );
    } catch (
      error,
      stackTrace
    ) {
      debugPrint(
        'Fuel voucher Page 4 error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _setLoadError(
        error.toString(),
      );
    }
  }

  // ==========================================================================
  // FIND PRICING FIELD
  // ==========================================================================

  Map<String, dynamic>?
      _findPricingField(
    Map<String, dynamic> product,
  ) {
    final dynamic fieldsRaw =
        product['fields'];

    if (fieldsRaw is! List) {
      return null;
    }

    // ========================================================================
    // FIRST:
    // role == pricing
    // ========================================================================

    for (final dynamic rawField
        in fieldsRaw) {
      if (rawField is! Map) {
        continue;
      }

      final Map<String, dynamic>
          field =
          Map<String, dynamic>.from(
        rawField,
      );

      final String role =
          field['role']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      if (role == 'pricing') {
        return field;
      }
    }

    // ========================================================================
    // FALLBACK
    // ========================================================================

    for (final dynamic rawField
        in fieldsRaw) {
      if (rawField is! Map) {
        continue;
      }

      final Map<String, dynamic>
          field =
          Map<String, dynamic>.from(
        rawField,
      );

      final String type =
          field['type']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      if (type == 'select' ||
          type == 'money') {
        return field;
      }
    }

    return null;
  }

  // ==========================================================================
  // LOAD SELECT OPTIONS
  // ==========================================================================

  Future<void> _loadSelectOptions(
    Map<String, dynamic> field,
  ) async {
    final String fieldId =
        field['id']
                ?.toString()
                .trim() ??
            '';

    if (fieldId.isEmpty) {
      throw Exception(
        'Select field ID is missing.',
      );
    }

    final GamingOptionsResult result =
        await IimmpactGamingOptionsService
            .getOptions(
      productCode: _code,
      fieldId: fieldId,
    );

    final List<GamingOption>
        activeOptions =
        result.options
            .where(
              (
                GamingOption option,
              ) =>
                  option.isActive,
            )
            .toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _options = activeOptions;

      _selectedOption =
          activeOptions.isEmpty
              ? null
              : activeOptions.first;
    });
  }

  // ==========================================================================
  // MONEY CONFIGURATION
  // ==========================================================================

  void _loadMoneyConfiguration({
    required Map<String, dynamic>
        product,
    required Map<String, dynamic>
        field,
  }) {
    double minimum = 0;
    double maximum = 0;

    // ========================================================================
    // validation.min / validation.max
    // ========================================================================

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

    // ========================================================================
    // FALLBACK:
    // denomination = x-y
    // ========================================================================

    if (minimum <= 0 ||
        maximum <= 0) {
      final String denomination =
          product['denomination']
                  ?.toString()
                  .trim() ??
              '';

      final (
        double rangeMin,
        double rangeMax,
      ) =
          _parseAmountRange(
        denomination,
      );

      if (minimum <= 0) {
        minimum = rangeMin;
      }

      if (maximum <= 0) {
        maximum = rangeMax;
      }
    }

    if (minimum <= 0 ||
        maximum <= 0 ||
        maximum < minimum) {
      throw Exception(
        'Invalid Fuel '
        'amount range for $_code.',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _minimumAmount = minimum;
      _maximumAmount = maximum;

      _selectedAmount = minimum;

      _updateAmountController(
        minimum,
      );
    });
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  double _toDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ??
              '',
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

  void _setLoadError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  // ==========================================================================
  // MONEY
  // ==========================================================================

  String _formatMoney(
    double amount,
  ) {
    return 'RM '
        '${amount.toStringAsFixed(2)}';
  }

  String _formatSignedMoney(
    double amount,
  ) {
    final String sign =
        amount >= 0
            ? '+'
            : '-';

    return '$sign RM '
        '${amount.abs().toStringAsFixed(2)}';
  }

  String _formatInputAmount(
    double amount,
  ) {
    return amount.toStringAsFixed(
      2,
    );
  }

  // ==========================================================================
  // PROCESSING
  // ==========================================================================

  String _formatProcessingTime(
    AppLocalizations loc,
  ) {
    final String value =
        _processingTime
            .trim()
            .toLowerCase();

    switch (value) {
      case 'pin':
        return loc
            .digitalVoucherDeliveryPin;

      case 'link':
        return loc
            .digitalVoucherDeliveryLink;

      case 'instant':
        return loc.processingInstant;

      case '24_hours':
        return loc.processing24Hours;

      case '3_days':
        return loc.processing3Days;

      default:
        if (value.isEmpty) {
          return '-';
        }

        return value
            .replaceAll(
              '_',
              ' ',
            )
            .toUpperCase();
    }
  }

  // ==========================================================================
  // OPTION
  // ==========================================================================

  void _selectOption(
    GamingOption option,
  ) {
    setState(() {
      _selectedOption = option;
    });
  }

  // ==========================================================================
  // AMOUNT
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

  void _setAmount(
    double amount,
  ) {
    final double safeAmount =
        amount
            .clamp(
              _minimumAmount,
              _maximumAmount,
            )
            .toDouble();

    setState(() {
      _selectedAmount =
          safeAmount;

      _updateAmountController(
        safeAmount,
      );
    });
  }

  void _increaseAmount() {
    final loc =
        AppLocalizations.of(context)!;

    if (_selectedAmount >=
        _maximumAmount) {
      _showMessage(
        loc.digitalVoucherMaximumAmount(
          _formatMoney(
            _maximumAmount,
          ),
        ),
      );

      return;
    }

    _setAmount(
      _selectedAmount +
          _amountStep,
    );
  }

  void _decreaseAmount() {
    final loc =
        AppLocalizations.of(context)!;

    if (_selectedAmount <=
        _minimumAmount) {
      _showMessage(
        loc.digitalVoucherMinimumAmount(
          _formatMoney(
            _minimumAmount,
          ),
        ),
      );

      return;
    }

    _setAmount(
      _selectedAmount -
          _amountStep,
    );
  }

  void _setQuickAmount(
    double amount,
  ) {
    if (amount <
            _minimumAmount ||
        amount >
            _maximumAmount) {
      return;
    }

    _setAmount(
      amount,
    );
  }

  // ==========================================================================
  // QUICK AMOUNTS
  //
  // UI shortcut only.
  //
  // Provider validity still comes from catalog min/max.
  // ==========================================================================

  List<double> get _quickAmounts {
    final List<double> candidates = [
      20,
      50,
      100,
      200,
    ];

    final List<double> result =
        candidates
            .where(
              (
                double amount,
              ) =>
                  amount >=
                      _minimumAmount &&
                  amount <=
                      _maximumAmount,
            )
            .toList();

    if (!result.any(
      (
        double amount,
      ) =>
          (
            amount -
                _minimumAmount
          ).abs() <
          0.001,
    )) {
      result.insert(
        0,
        _minimumAmount,
      );
    }

    return result;
  }

  // ==========================================================================
  // CUSTOM AMOUNT KEYBOARD
  // ==========================================================================

  void _openAmountKeyboard() {
    if (!_isMoneyField) {
      return;
    }

    final loc =
        AppLocalizations.of(context)!;

    String temporaryValue =
        _amountController.text;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel:
          loc.digitalVoucherEnterAmount,
      barrierColor:
          Colors.black.withOpacity(
        0.55,
      ),
      transitionDuration:
          const Duration(
        milliseconds: 220,
      ),
      transitionBuilder:
          (
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
          reverseCurve:
              Curves.easeIn,
        );

        return FadeTransition(
          opacity: animation,
          child:
              ScaleTransition(
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
      pageBuilder:
          (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return StatefulBuilder(
          builder:
              (
            keyboardContext,
            setKeyboardState,
          ) {
            void updateValue(
              String value,
            ) {
              temporaryValue = value;

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
                final List<String>
                    parts =
                    temporaryValue
                        .split('.');

                final String decimals =
                    parts.length > 1
                        ? parts.last
                        : '';

                if (decimals.length >=
                    2) {
                  return;
                }
              }

              final String prospective =
                  '$temporaryValue$number';

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
                  9) {
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
                temporaryValue
                    .substring(
                  0,
                  temporaryValue
                          .length -
                      1,
                ),
              );
            }

            void pressClear() {
              updateValue('');
            }

            void pressCancel() {
              Navigator.pop(
                dialogContext,
              );
            }

            void pressDone() {
              final double parsed =
                  double.tryParse(
                        temporaryValue,
                      ) ??
                      0;

              if (parsed <
                  _minimumAmount) {
                _showMessage(
                  loc.digitalVoucherMinimumAmount(
                    _formatMoney(
                      _minimumAmount,
                    ),
                  ),
                );

                return;
              }

              if (parsed >
                  _maximumAmount) {
                _showMessage(
                  loc.digitalVoucherMaximumAmount(
                    _formatMoney(
                      _maximumAmount,
                    ),
                  ),
                );

                return;
              }

              _setAmount(
                parsed,
              );

              Navigator.pop(
                dialogContext,
              );
            }

            return Material(
              color:
                  Colors.transparent,
              child:
                  SafeArea(
                child:
                    Center(
                  child:
                      Padding(
                    padding:
                        const EdgeInsets.all(
                      35,
                    ),
                    child:
                        ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth:
                            820,
                        maxHeight:
                            1150,
                      ),
                      child:
                          Container(
                        width:
                            820,
                        padding:
                            const EdgeInsets.fromLTRB(
                          38,
                          32,
                          38,
                          36,
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
                          border:
                              Border.all(
                            color:
                                Colors.white,
                            width:
                                3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(
                                0.30,
                              ),
                              blurRadius:
                                  35,
                              spreadRadius:
                                  5,
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
                          child:
                              Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              // ==================================================
                              // HEADER
                              // ==================================================

                              Row(
                                children: [
                                  Container(
                                    width:
                                        64,
                                    height:
                                        64,
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          _lightColor,
                                      borderRadius:
                                          BorderRadius.circular(
                                        18,
                                      ),
                                    ),
                                    child:
                                        const Icon(
                                      Icons.keyboard_alt_rounded,
                                      color:
                                          _primaryColor,
                                      size:
                                          37,
                                    ),
                                  ),

                                  const SizedBox(
                                    width:
                                        18,
                                  ),

                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.digitalVoucherEnterAmount,
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF102A43,
                                            ),
                                            fontSize:
                                                30,
                                            fontWeight:
                                                FontWeight.w900,
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              4,
                                        ),

                                        Text(
                                          loc.digitalVoucherKeypadHint,
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF60758D,
                                            ),
                                            fontSize:
                                                20,
                                            fontWeight:
                                                FontWeight.w600,
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
                                      Icons.close_rounded,
                                      size:
                                          36,
                                      color:
                                          Color(
                                        0xFF60758D,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height:
                                    28,
                              ),

                              // ==================================================
                              // DISPLAY
                              // ==================================================

                              Container(
                                width:
                                    double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      28,
                                  vertical:
                                      25,
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
                                    width:
                                        3,
                                  ),
                                ),
                                child:
                                    Row(
                                  children: [
                                    const Text(
                                      'RM',
                                      style:
                                          TextStyle(
                                        color:
                                            Color(
                                          0xFF53677E,
                                        ),
                                        fontSize:
                                            34,
                                        fontWeight:
                                            FontWeight.w900,
                                      ),
                                    ),

                                    const SizedBox(
                                      width:
                                          20,
                                    ),

                                    Expanded(
                                      child:
                                          Text(
                                        temporaryValue.isEmpty
                                            ? '0.00'
                                            : temporaryValue,
                                        textAlign:
                                            TextAlign.right,
                                        maxLines:
                                            1,
                                        style:
                                            const TextStyle(
                                          color:
                                              Color(
                                            0xFF102A43,
                                          ),
                                          fontSize:
                                              46,
                                          fontWeight:
                                              FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height:
                                    14,
                              ),

                              Align(
                                alignment:
                                    Alignment.centerLeft,
                                child:
                                    Text(
                                  loc.digitalVoucherAmountRange(
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
                                    fontSize:
                                        19,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height:
                                    28,
                              ),

                              // ==================================================
                              // 1 2 3
                              // ==================================================

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '1',
                                      () =>
                                          pressNumber(
                                        '1',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        16,
                                  ),
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '2',
                                      () =>
                                          pressNumber(
                                        '2',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        16,
                                  ),
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '3',
                                      () =>
                                          pressNumber(
                                        '3',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height:
                                    16,
                              ),

                              // ==================================================
                              // 4 5 6
                              // ==================================================

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '4',
                                      () =>
                                          pressNumber(
                                        '4',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        16,
                                  ),
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '5',
                                      () =>
                                          pressNumber(
                                        '5',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        16,
                                  ),
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '6',
                                      () =>
                                          pressNumber(
                                        '6',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height:
                                    16,
                              ),

                              // ==================================================
                              // 7 8 9
                              // ==================================================

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '7',
                                      () =>
                                          pressNumber(
                                        '7',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        16,
                                  ),
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '8',
                                      () =>
                                          pressNumber(
                                        '8',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        16,
                                  ),
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '9',
                                      () =>
                                          pressNumber(
                                        '9',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height:
                                    16,
                              ),

                              // ==================================================
                              // . 0 DELETE
                              // ==================================================

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '.',
                                      pressDecimal,
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        16,
                                  ),
                                  Expanded(
                                    child:
                                        _keyboardButton(
                                      '0',
                                      () =>
                                          pressNumber(
                                        '0',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        16,
                                  ),
                                  Expanded(
                                    child:
                                        _keyboardIconButton(
                                      Icons.backspace_outlined,
                                      pressDelete,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height:
                                    26,
                              ),

                              // ==================================================
                              // CLEAR + DONE
                              // ==================================================

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        SizedBox(
                                      height:
                                          78,
                                      child:
                                          OutlinedButton.icon(
                                        onPressed:
                                            pressClear,
                                        icon:
                                            const Icon(
                                          Icons.delete_sweep_outlined,
                                          size:
                                              29,
                                        ),
                                        label:
                                            Text(
                                          loc.digitalVoucherClear,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                22,
                                            fontWeight:
                                                FontWeight.w900,
                                          ),
                                        ),
                                        style:
                                            OutlinedButton.styleFrom(
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
                                            width:
                                                2,
                                          ),
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width:
                                        18,
                                  ),

                                  Expanded(
                                    flex:
                                        2,
                                    child:
                                        SizedBox(
                                      height:
                                          78,
                                      child:
                                          ElevatedButton.icon(
                                        onPressed:
                                            pressDone,
                                        icon:
                                            const Icon(
                                          Icons.check_circle_rounded,
                                          size:
                                              31,
                                        ),
                                        label:
                                            Text(
                                          loc.digitalVoucherDone,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                24,
                                            fontWeight:
                                                FontWeight.w900,
                                          ),
                                        ),
                                        style:
                                            ElevatedButton.styleFrom(
                                          backgroundColor:
                                              _greenColor,
                                          foregroundColor:
                                              Colors.white,
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
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
                                height:
                                    14,
                              ),

                              // ==================================================
                              // CANCEL
                              // ==================================================

                              SizedBox(
                                width:
                                    double.infinity,
                                height:
                                    68,
                                child:
                                    TextButton.icon(
                                  onPressed:
                                      pressCancel,
                                  icon:
                                      const Icon(
                                    Icons.close_rounded,
                                    size:
                                        28,
                                  ),
                                  label:
                                      Text(
                                    loc.digitalVoucherCancel,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          21,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                  style:
                                      TextButton.styleFrom(
                                    backgroundColor:
                                        _redColor,
                                    foregroundColor:
                                        Colors.white,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
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

  // ==========================================================================
  // KEYPAD BUTTONS
  // ==========================================================================

  Widget _keyboardButton(
    String label,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 92,
      child:
          ElevatedButton(
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
        child:
            Text(
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

  Widget _keyboardIconButton(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 92,
      child:
          ElevatedButton(
        onPressed:
            onPressed,
        style:
            ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor:
              const Color(
            0xFFFFF3E0,
          ),
          foregroundColor:
              const Color(
            0xFFE65100,
          ),
          side:
              const BorderSide(
            color:
                Color(
              0xFFFFB46A,
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
        child:
            Icon(
          icon,
          size: 38,
        ),
      ),
    );
  }

  // ==========================================================================
  // CONTINUE
  // ==========================================================================

void _handleContinue() {
  final loc =
      AppLocalizations.of(context)!;

  if (!_isProductActive) {
    _showMessage(
      loc.digitalVoucherProductUnavailable,
    );

    return;
  }

  // ==========================================================================
  // SELECT TYPE
  // ==========================================================================

  if (_isSelectField) {
    final GamingOption? option =
        _selectedOption;

    if (option == null) {
      _showMessage(
        loc.digitalVoucherSelectOptionRequired,
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FuelQrPaymentPage(
          productName:
              _productName,

          productCode:
              _code,

          // ================================================================
          // KEEP API IMAGE URL
          // ================================================================

          imageUrl:
              _imageUrl,

          fieldId:
              _fieldId,

          fieldType:
              _fieldType,

          optionCode:
              option.code,

          optionName:
              option.displayName,

          optionDescription:
              option.description,

          baseAmount:
              _selectedBaseAmount,

          topupAmount:
              _selectedTopupAmount,

          serviceAdjustment:
              _adjustmentAmount,

          totalAmount:
              _totalAmount,

          processingTime:
              _processingTime,

          // ================================================================
          // ALREADY LOCALIZED NOTE
          // ================================================================

          note:
              _localizedNote(
            loc,
          ),
        ),
      ),
    );

    return;
  }

  // ==========================================================================
  // MONEY TYPE
  // ==========================================================================

  if (_isMoneyField) {
    if (_selectedAmount <
            _minimumAmount ||
        _selectedAmount >
            _maximumAmount) {
      _showMessage(
        loc.digitalVoucherInvalidAmount,
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FuelQrPaymentPage(
          productName:
              _productName,

          productCode:
              _code,

          imageUrl:
              _imageUrl,

          fieldId:
              _fieldId,

          fieldType:
              _fieldType,

          // No option for money/free amount.
          optionCode:
              null,

          optionName:
              null,

          optionDescription:
              null,

          baseAmount:
              _selectedBaseAmount,

          topupAmount:
              _selectedTopupAmount,

          serviceAdjustment:
              _adjustmentAmount,

          totalAmount:
              _totalAmount,

          processingTime:
              _processingTime,

          note:
              _localizedNote(
            loc,
          ),
        ),
      ),
    );

    return;
  }

  _showMessage(
    loc.digitalVoucherInvalidAmount,
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
        AppLocalizations.of(context)!;

    return Scaffold(
      body:
          Stack(
        children: [
          const Positioned.fill(
            child:
                DecoratedBox(
              decoration:
                  BoxDecoration(
                image:
                    DecorationImage(
                  image:
                      AssetImage(
                    'lib/images/pnew.png',
                  ),
                  fit:
                      BoxFit.cover,
                ),
              ),
            ),
          ),

          SafeArea(
            child:
                Column(
              children: [
                _buildHeader(
                  loc,
                ),

                Expanded(
                  child:
                      _isLoading
                          ? const Center(
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    5,
                                color:
                                    _primaryColor,
                              ),
                            )
                          : _errorMessage !=
                                  null
                              ? _buildError(
                                  loc,
                                )
                              : _buildContent(
                                  loc,
                                ),
                ),

                _buildBottomArea(
                  loc,
                ),
              ],
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
        70,
        30,
        70,
        0,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 25,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFFC83261,
            ),
            Color(
              0xFFE65175,
            ),
            Color(
              0xFFF17C9C,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.15,
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
      child:
          Row(
        children: [
          Container(
            width: 95,
            height: 95,
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
                22,
              ),
            ),
            child:
                _buildImage(
              size: 60,
            ),
          ),

          const SizedBox(
            width: 25,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _productName
                      .toUpperCase(),
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 34,
                    fontWeight:
                        FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  loc.fuelPurchaseSubtitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.card_giftcard_rounded,
            color:
                Colors.white,
            size: 60,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CONTENT
  // ==========================================================================

  Widget _buildContent(
    AppLocalizations loc,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 20,
      ),
      child:
          Scrollbar(
        controller:
            _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 12,
        radius:
            const Radius.circular(
          20,
        ),
        interactive: true,
        child:
            SingleChildScrollView(
          controller:
              _scrollController,
          physics:
              const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            70,
            35,
            70,
            30,
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              _buildProductCard(
                loc,
              ),

              // ==============================================================
              // IMPORTANT NOTE
              // ==============================================================

              if (_rawNote.isNotEmpty) ...[
                const SizedBox(
                  height: 28,
                ),

                _buildImportantNote(
                  loc,
                ),
              ],

              const SizedBox(
                height: 28,
              ),

              if (_isSelectField)
                _buildOptionSection(
                  loc,
                )
              else if (_isMoneyField)
                _buildMoneySection(
                  loc,
                ),

              const SizedBox(
                height: 28,
              ),

              _buildSummary(
                loc,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PRODUCT CARD
  // ==========================================================================

  Widget _buildProductCard(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFF1CBD6,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child:
          Row(
        children: [
          Container(
            width: 135,
            height: 115,
            padding:
                const EdgeInsets.all(
              18,
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
                    _lightColor,
                width: 2,
              ),
            ),
            child:
                _buildImage(
              size: 70,
            ),
          ),

          const SizedBox(
            width: 25,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _productName,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize: 31,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  loc.fuelPageTitle,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF66758A,
                    ),
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 25,
                      color:
                          Color(
                        0xFF66758A,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child:
                          Text(
                        '${loc.digitalVoucherDelivery}: '
                        '${_formatProcessingTime(loc)}',
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF66758A,
                          ),
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // IMAGE
  // ==========================================================================

  Widget _buildImage({
    required double size,
  }) {
    if (_imageUrl.isEmpty) {
      return Icon(
        Icons.card_giftcard_rounded,
        size: size,
        color:
            _primaryColor,
      );
    }

    return Image.network(
      _imageUrl,
      fit:
          BoxFit.contain,
      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return Icon(
          Icons.card_giftcard_rounded,
          size: size,
          color:
              _primaryColor,
        );
      },
    );
  }

  // ==========================================================================
  // IMPORTANT NOTE
  // ==========================================================================

  Widget _buildImportantNote(
    AppLocalizations loc,
  ) {
    final String displayNote =
        _localizedNote(
      loc,
    );

    return Container(
      padding:
          const EdgeInsets.all(
        25,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFFF9E8,
        ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFF3C766,
          ),
          width: 2,
        ),
      ),
      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFFE7A3,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child:
                const Icon(
              Icons.info_outline_rounded,
              color:
                  Color(
                0xFFA96500,
              ),
              size: 38,
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  loc.digitalVoucherImportantNote,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF9A5800,
                    ),
                    fontSize: 27,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                Text(
                  displayNote,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF7B5B2A,
                    ),
                    fontSize: 23,
                    height: 1.42,
                    fontWeight:
                        FontWeight.w600,
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
  // OPTION SECTION
  // ==========================================================================

  Widget _buildOptionSection(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD3DCE8,
          ),
          width: 2,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            _fieldId
                        .toLowerCase() ==
                    'package'
                ? loc.digitalVoucherSelectPackage
                : loc.digitalVoucherSelectAmount,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF102A43,
              ),
              fontSize: 35,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            _fieldId
                        .toLowerCase() ==
                    'package'
                ? loc.digitalVoucherSelectPackageHint
                : loc.digitalVoucherSelectAmountHint,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF60758D,
              ),
              fontSize: 25,
              height: 1.35,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          if (_options.isEmpty)
            Container(
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
                  0xFFFFF3E0,
                ),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child:
                  Text(
                loc.digitalVoucherNoOptionsAvailable,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFFE65100,
                  ),
                  fontSize: 27,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            )
          else
            LayoutBuilder(
              builder:
                  (
                context,
                constraints,
              ) {
                final double itemWidth =
                    (
                          constraints
                                  .maxWidth -
                              18
                        ) /
                        2;

                return Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children:
                      _options.map(
                    (
                      GamingOption option,
                    ) {
                      return SizedBox(
                        width:
                            itemWidth,
                        child:
                            _buildOptionCard(
                          option,
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // OPTION CARD
  // ==========================================================================

  Widget _buildOptionCard(
    GamingOption option,
  ) {
    final bool selected =
        identical(
      _selectedOption,
      option,
    );

    final String title =
        option.displayName
                .trim()
                .isNotEmpty
            ? option.displayName
            : option.code;

    return Material(
      color:
          Colors.transparent,
      child:
          InkWell(
        onTap:
            () {
          _selectOption(
            option,
          );
        },
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          constraints:
              const BoxConstraints(
            minHeight: 165,
          ),
          padding:
              const EdgeInsets.all(
            21,
          ),
          decoration:
              BoxDecoration(
            color:
                selected
                    ? const Color(
                        0xFFFFEDF2,
                      )
                    : const Color(
                        0xFFFAFBFC,
                      ),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border:
                Border.all(
              color:
                  selected
                      ? _primaryColor
                      : const Color(
                          0xFFD6DEE8,
                        ),
              width:
                  selected
                      ? 3
                      : 2,
            ),
            boxShadow:
                selected
                    ? [
                        BoxShadow(
                          color:
                              _primaryColor.withOpacity(
                            0.12,
                          ),
                          blurRadius: 15,
                          offset:
                              const Offset(
                            0,
                            6,
                          ),
                        ),
                      ]
                    : null,
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        Text(
                      title,
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color:
                            selected
                                ? _darkColor
                                : const Color(
                                    0xFF17283E,
                                  ),
                        fontSize: 29,
                        fontWeight:
                            FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                  ),

                  if (selected)
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        left: 8,
                      ),
                      child:
                          Icon(
                        Icons.check_circle_rounded,
                        color:
                            _primaryColor,
                        size: 31,
                      ),
                    ),
                ],
              ),

              if (option.description
                  .trim()
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 9,
                ),

                Text(
                  option.description,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF68778A,
                    ),
                    fontSize: 22,
                    height: 1.3,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(
                height: 15,
              ),

              Text(
                _formatMoney(
                  option
                      .priceAmount,
                ),
                style:
                    const TextStyle(
                  color:
                      _greenColor,
                  fontSize: 29,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // MONEY SECTION
  // ==========================================================================

  Widget _buildMoneySection(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD3DCE8,
          ),
          width: 2,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            loc.digitalVoucherSelectAmount,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF102A43,
              ),
              fontSize: 35,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            loc.digitalVoucherTapAmountHint,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF60758D,
              ),
              fontSize: 23,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          Row(
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
                      FontWeight.w900,
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
                      height: 95,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            22,
                      ),
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
                          width: 3,
                        ),
                      ),
                      child:
                          Row(
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            color:
                                _primaryColor,
                            size: 30,
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(
                            child:
                                Text(
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
                                    FontWeight.w900,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.keyboard_alt_rounded,
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

              const SizedBox(
                width: 18,
              ),

              SizedBox(
                width: 105,
                height: 95,
                child:
                    ElevatedButton(
                  onPressed:
                      _decreaseAmount,
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
                    elevation: 0,
                    padding:
                        EdgeInsets.zero,
                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xFFFFB46A,
                      ),
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
                  child:
                      const Icon(
                    Icons.remove_rounded,
                    size: 55,
                  ),
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              SizedBox(
                width: 105,
                height: 95,
                child:
                    ElevatedButton(
                  onPressed:
                      _increaseAmount,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFE8F5E9,
                    ),
                    foregroundColor:
                        const Color(
                      0xFF2E7D32,
                    ),
                    elevation: 0,
                    padding:
                        EdgeInsets.zero,
                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xFF66BB6A,
                      ),
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
                  child:
                      const Icon(
                    Icons.add_rounded,
                    size: 55,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          Text(
            loc.digitalVoucherAmountRange(
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
              fontSize: 21,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          Wrap(
            spacing: 14,
            runSpacing: 14,
            children:
                _quickAmounts
                    .map(
              (
                double amount,
              ) {
                return _QuickAmountButton(
                  label:
                      _formatMoney(
                    amount,
                  ),
                  onPressed:
                      () {
                    _setQuickAmount(
                      amount,
                    );
                  },
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SUMMARY
  // ==========================================================================

  Widget _buildSummary(
    AppLocalizations loc,
  ) {
    final String selectedLabel;

    if (_isSelectField) {
      final GamingOption? option =
          _selectedOption;

      selectedLabel =
          option == null
              ? '-'
              : option.displayName
                      .trim()
                      .isNotEmpty
                  ? option.displayName
                  : option.code;
    } else {
      selectedLabel =
          _formatMoney(
        _selectedAmount,
      );
    }

    return Container(
      padding:
          const EdgeInsets.all(
        30,
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
              const Color(
            0xFFD3DCE8,
          ),
          width: 2,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.digitalVoucherOrderSummary,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF102A43,
              ),
              fontSize: 34,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          _SummaryRow(
            label:
                _productName,
            value:
                _formatMoney(
              _selectedBaseAmount,
            ),
          ),

          const Divider(
            height: 38,
          ),

          _SummaryRow(
            label:
                _isSelectField
                    ? loc.digitalVoucherSelectedPackage
                    : loc.digitalVoucherSelectedAmount,
            value:
                selectedLabel,
          ),

          if (_hasAdjustment) ...[
            const Divider(
              height: 38,
            ),

            _SummaryRow(
              label:
                  loc.digitalVoucherServiceAdjustment,
              value:
                  _formatSignedMoney(
                _adjustmentAmount,
              ),
              valueColor:
                  _adjustmentAmount >
                          0
                      ? const Color(
                          0xFFE65100,
                        )
                      : const Color(
                          0xFF138A72,
                        ),
            ),
          ],

          const Divider(
            height: 38,
          ),

          _SummaryRow(
            label:
                loc.digitalVoucherTotalPayment,
            value:
                _formatMoney(
              _totalAmount,
            ),
            isTotal: true,
          ),

          const Divider(
            height: 38,
          ),

          _SummaryRow(
            label:
                loc.digitalVoucherDelivery,
            value:
                _formatProcessingTime(
              loc,
            ),
          ),
        ],
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
        width: 700,
        margin:
            const EdgeInsets.all(
          70,
        ),
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
            30,
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
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color:
                  _redColor,
              size: 80,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              loc.digitalVoucherUnableToLoad,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize: 30,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(
              width: 300,
              height: 75,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _loadProduct,
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                  size: 30,
                ),
                label:
                    Text(
                  loc.digitalVoucherTryAgain,
                  style:
                      const TextStyle(
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _primaryColor,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BOTTOM
  // ==========================================================================

  Widget _buildBottomArea(
    AppLocalizations loc,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        70,
        18,
        70,
        60,
      ),
      child:
          Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    SizedBox(
                  height: 100,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon:
                        const Icon(
                      Icons.arrow_back_rounded,
                      size: 33,
                    ),
                    label:
                        Text(
                      loc.buttonBack,
                      style:
                          const TextStyle(
                        fontSize: 40,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.white,
                      foregroundColor:
                          Colors.black,
                      elevation: 1,
                      side:
                          const BorderSide(
                        color:
                            Color(
                          0xFFD5DCE5,
                        ),
                        width: 2,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 24,
              ),

              Expanded(
                child:
                    SizedBox(
                  height: 100,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleContinue,
                    icon:
                        const Icon(
                      Icons.arrow_forward_rounded,
                      size: 33,
                    ),
                    label:
                        Text(
                      loc.digitalVoucherReviewSelection,
                      style:
                          const TextStyle(
                        fontSize: 34,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _greenColor,
                      foregroundColor:
                          Colors.white,
                      elevation: 3,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
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
            height: 16,
          ),

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
                  Color(
                0xFF17375E,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    final loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible:
          false,
      builder:
          (
        BuildContext dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          child:
              Container(
            width: 680,
            padding:
                const EdgeInsets.all(
              38,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFF1CBD6,
                ),
                width: 2,
              ),
            ),
            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color:
                      _primaryColor,
                  size: 75,
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  message,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize: 27,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 76,
                  child:
                      ElevatedButton(
                    onPressed:
                        () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _primaryColor,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                    child:
                        Text(
                      loc.electricOk,
                      style:
                          const TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.w900,
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
}

// ============================================================================
// QUICK AMOUNT
// ============================================================================

class _QuickAmountButton
    extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickAmountButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      height: 58,
      child:
          OutlinedButton(
        onPressed:
            onPressed,
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              const Color(
            0xFF17375E,
          ),
          backgroundColor:
              Colors.white,
          side:
              const BorderSide(
            color:
                Color(
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
                BorderRadius.circular(
              14,
            ),
          ),
        ),
        child:
            Text(
          label,
          style:
              const TextStyle(
            fontSize: 21,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SUMMARY ROW
// ============================================================================

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
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child:
              Text(
            label,
            style:
                TextStyle(
              color:
                  isTotal
                      ? const Color(
                          0xFF102A43,
                        )
                      : const Color(
                          0xFF63758A,
                        ),
              fontSize:
                  isTotal
                      ? 31
                      : 24,
              fontWeight:
                  isTotal
                      ? FontWeight.w900
                      : FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(
          width: 20,
        ),

        Flexible(
          child:
              Text(
            value,
            textAlign:
                TextAlign.right,
            style:
                TextStyle(
              color:
                  valueColor ??
                      (
                        isTotal
                            ? _PFUEL4PAGEState
                                ._greenColor
                            : const Color(
                                0xFF102A43,
                              )
                      ),
              fontSize:
                  isTotal
                      ? 34
                      : 26,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}