import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

import 'package:frontend_v1/pages/bil/telco/mobilereload/services/mobile_reload_options_service.dart';

import 'package:frontend_v1/pages/bil/telco/mobilereload/pmobilereload6.dart';

// ============================================================================
// MOBILE RELOAD PAGE 5
// ============================================================================
//
// PAGE 4
//   -> enter phone number
//
// PAGE 5
//   -> load /v2/catalog
//   -> determine MOBILE_DATA or MOBILE_PREPAID
//   -> detect pricing field dynamically
//
// MOBILE_DATA:
//   type = select
//   -> /v2/options
//   -> show internet PLAN cards
//
// MOBILE_PREPAID:
//   type = select
//   -> /v2/options
//   -> show simple reload AMOUNT cards
//
// MOBILE_PREPAID:
//   type = money
//   -> catalog validation min/max
//   -> custom amount UI
//
// IMPORTANT:
// Do NOT decide the UI only from field type.
// Category + field configuration decides the UI.
// ============================================================================

enum MobileReloadProductCategory {
  mobileData,
  mobilePrepaid,
  unknown,
}

enum MobileReloadSelectionMode {
  internetPlan,
  prepaidOptions,
  prepaidCustomAmount,
}

class PMOBILERELOAD5PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;
  final String phoneNumber;

  const PMOBILERELOAD5PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
    required this.phoneNumber,
  });

  @override
  State<PMOBILERELOAD5PAGE> createState() =>
      _PMOBILERELOAD5PAGEState();
}

class _PMOBILERELOAD5PAGEState
    extends State<PMOBILERELOAD5PAGE> {
  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  final TextEditingController _amountController =
      TextEditingController();

  // ==========================================================================
  // STATE
  // ==========================================================================

  Map<String, dynamic>? _product;

  Map<String, dynamic>? _pricingField;

  MobileReloadProductCategory _category =
      MobileReloadProductCategory.unknown;

  MobileReloadSelectionMode? _mode;

  List<MobileReloadOption> _options = [];

  MobileReloadOption? _selectedOption;

  CatalogPricing _catalogPricing =
      CatalogPricing.empty();

  bool _isLoading = true;

  String? _errorMessage;

  bool _showScrollHint = false;

  // ==========================================================================
  // CUSTOM AMOUNT
  // ==========================================================================

  double _minimumAmount = 0;

  double _maximumAmount = 0;

  double _selectedCustomAmount = 0;

  static const double _amountStep = 1;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF7B4DCC);

  static const Color _darkColor =
      Color(0xFF56339B);

  static const Color _lightColor =
      Color(0xFFF1EAFF);

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
        : widget.providerName;
  }

  String get _imageUrl {
    final String value =
        _product?['image_url']
                ?.toString()
                .trim() ??
            '';

    return value.isNotEmpty
        ? value
        : widget.providerImageUrl;
  }

  String get _processingTime =>
      _product?['processing_time']
              ?.toString()
              .trim() ??
          '';

  bool get _isProductActive =>
      _product?['is_active'] ==
      true;

  // ==========================================================================
  // CURRENT AMOUNT
  // ==========================================================================

  double get _baseAmount {
    if (_mode ==
        MobileReloadSelectionMode
            .prepaidCustomAmount) {
      return _selectedCustomAmount;
    }

    return _selectedOption
            ?.priceAmount ??
        0;
  }

  // ==========================================================================
  // CUSTOMER PRICING
  // ==========================================================================

  PriceAdjustmentResult
      get _priceAdjustmentResult {
    final adjustment =
        _catalogPricing.priceAdjustment;

    if (adjustment == null) {
      return PriceAdjustmentResult.none(
        _baseAmount,
      );
    }

    return adjustment.apply(
      _baseAmount,
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
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );


    _loadProduct();
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      _handleScroll,
    );

    _scrollController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // SCROLL HINT
  // ==========================================================================

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        !mounted) {
      return;
    }

    final double maxScroll =
        _scrollController
            .position
            .maxScrollExtent;

    final double current =
        _scrollController.offset;

    // Show only if:
    // 1. There is actually more content to scroll.
    // 2. User has not reached near the bottom.
    final bool shouldShow =
        maxScroll > 40 &&
        current < maxScroll - 40;

    if (_showScrollHint != shouldShow) {
      setState(() {
        _showScrollHint =
            shouldShow;
      });
    }
  }

  // ==========================================================================
  // LOAD PAGE
  // ==========================================================================

  Future<void> _loadProduct() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // ======================================================================
      // 1. CATALOG
      // ======================================================================

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

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final dynamic rawProduct =
          products[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'Mobile Reload product $_code '
          'was not found.',
        );
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      if (product['is_active'] != true) {
        throw Exception(
          'This Mobile Reload product '
          'is currently unavailable.',
        );
      }

      // ======================================================================
      // 2. CATEGORY
      // ======================================================================

      final MobileReloadProductCategory
          category =
          _findCategory(
        catalog,
      );

      if (category ==
          MobileReloadProductCategory
              .unknown) {
        throw Exception(
          'Mobile Reload category '
          'could not be determined.',
        );
      }

      // ======================================================================
      // 3. PRICING FIELD
      // ======================================================================

      final Map<String, dynamic>?
          pricingField =
          _findPricingField(
        product,
      );

      if (pricingField == null) {
        throw Exception(
          'Pricing field was not found '
          'for $_code.',
        );
      }

      // ======================================================================
      // 4. DETERMINE UI MODE
      // ======================================================================

      final MobileReloadSelectionMode
          mode =
          _determineMode(
        category:
            category,
        pricingField:
            pricingField,
      );

      // ======================================================================
      // 5. PRICING
      // ======================================================================

      final CatalogPricing pricing =
          CatalogPricing
              .fromCatalogResponse(
        catalogJson:
            catalog,
        productCode:
            _code,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;

        _category =
            category;

        _pricingField =
            pricingField;

        _mode =
            mode;

        _catalogPricing =
            pricing;
      });

      // ======================================================================
      // SELECT / OPTIONS
      // ======================================================================

      if (mode ==
              MobileReloadSelectionMode
                  .internetPlan ||
          mode ==
              MobileReloadSelectionMode
                  .prepaidOptions) {
        await _loadOptions(
          pricingField,
        );

        return;
      }

      // ======================================================================
      // MONEY / CUSTOM AMOUNT
      // ======================================================================

      if (mode ==
          MobileReloadSelectionMode
              .prepaidCustomAmount) {
        _configureMoneyField(
          pricingField,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            _handleScroll();
          },
        );

        return;
      }

      throw Exception(
        'Unsupported Mobile Reload configuration.',
      );
    } on IimmpactCatalogException catch (error) {
      _setError(
        error.message,
      );
    } on MobileReloadOptionsException catch (error) {
      _setError(
        error.message,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Mobile Reload Page 5 error: '
        '$error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      _setError(
        error.toString(),
      );
    }
  }

  // ==========================================================================
  // CATEGORY
  // ==========================================================================

  MobileReloadProductCategory _findCategory(
    Map<String, dynamic> catalog,
  ) {
    final dynamic treeRaw =
        catalog['tree'];

    if (treeRaw is! Map) {
      return MobileReloadProductCategory
          .unknown;
    }

    final Map<String, dynamic> tree =
        Map<String, dynamic>.from(
      treeRaw,
    );

    final dynamic groupsRaw =
        tree['groups'];

    if (groupsRaw is! List) {
      return MobileReloadProductCategory
          .unknown;
    }

    for (final dynamic rawGroup
        in groupsRaw) {
      if (rawGroup is! Map) {
        continue;
      }

      final Map<String, dynamic> group =
          Map<String, dynamic>.from(
        rawGroup,
      );

      final String groupId =
          group['id']
                  ?.toString()
                  .trim()
                  .toUpperCase() ??
              '';

      if (groupId != 'MOBILE') {
        continue;
      }

      final dynamic categoriesRaw =
          group['categories'];

      if (categoriesRaw is! List) {
        continue;
      }

      for (final dynamic rawCategory
          in categoriesRaw) {
        if (rawCategory is! Map) {
          continue;
        }

        final Map<String, dynamic>
            category =
            Map<String, dynamic>.from(
          rawCategory,
        );

        final String categoryId =
            category['id']
                    ?.toString()
                    .trim()
                    .toUpperCase() ??
                '';

        final dynamic codesRaw =
            category['product_codes'];

        if (codesRaw is! List) {
          continue;
        }

        final bool containsProduct =
            codesRaw.any(
          (
            dynamic rawCode,
          ) =>
              rawCode
                  .toString()
                  .trim()
                  .toUpperCase() ==
              _code,
        );

        if (!containsProduct) {
          continue;
        }

        if (categoryId ==
            'MOBILE_DATA') {
          return MobileReloadProductCategory
              .mobileData;
        }

        if (categoryId ==
            'MOBILE_PREPAID') {
          return MobileReloadProductCategory
              .mobilePrepaid;
        }
      }
    }

    return MobileReloadProductCategory
        .unknown;
  }

  // ==========================================================================
  // PRICING FIELD
  // ==========================================================================

  Map<String, dynamic>? _findPricingField(
    Map<String, dynamic> product,
  ) {
    final dynamic fieldsRaw =
        product['fields'];

    if (fieldsRaw is! List) {
      return null;
    }

    for (final dynamic rawField
        in fieldsRaw) {
      if (rawField is! Map) {
        continue;
      }

      final Map<String, dynamic> field =
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

    return null;
  }

  // ==========================================================================
  // DETERMINE MODE
  // ==========================================================================

  MobileReloadSelectionMode _determineMode({
    required MobileReloadProductCategory
        category,
    required Map<String, dynamic>
        pricingField,
  }) {
    final String type =
        pricingField['type']
                ?.toString()
                .trim()
                .toLowerCase() ??
            '';

    // ========================================================================
    // INTERNET
    // ========================================================================

    if (category ==
        MobileReloadProductCategory
            .mobileData) {
      if (type == 'select') {
        return MobileReloadSelectionMode
            .internetPlan;
      }
    }

    // ========================================================================
    // PREPAID
    // ========================================================================

    if (category ==
        MobileReloadProductCategory
            .mobilePrepaid) {
      if (type == 'select') {
        return MobileReloadSelectionMode
            .prepaidOptions;
      }

      if (type == 'money') {
        return MobileReloadSelectionMode
            .prepaidCustomAmount;
      }
    }

    throw Exception(
      'Unsupported pricing configuration. '
      'Category=$category Type=$type',
    );
  }

  // ==========================================================================
  // OPTIONS DEPEND ON PHONE?
  // ==========================================================================

  bool _optionsDependOnPhone(
    Map<String, dynamic> field,
  ) {
    final dynamic sourceRaw =
        field['data_source'];

    if (sourceRaw is! Map) {
      return false;
    }

    final Map<String, dynamic> source =
        Map<String, dynamic>.from(
      sourceRaw,
    );

    final String sourceType =
        source['type']
                ?.toString()
                .trim()
                .toLowerCase() ??
            '';

    if (sourceType == 'dynamic') {
      return true;
    }

    final dynamic dependsRaw =
        source['depends_on'];

    if (dependsRaw is List) {
      return dependsRaw.any(
        (
          dynamic value,
        ) =>
            value
                .toString()
                .trim()
                .toLowerCase() ==
            'phone',
      );
    }

    return false;
  }

  // ==========================================================================
  // LOAD OPTIONS
  // ==========================================================================

  Future<void> _loadOptions(
    Map<String, dynamic> field,
  ) async {
    final String fieldId =
        field['id']
                ?.toString()
                .trim() ??
            '';

    if (fieldId.isEmpty) {
      throw Exception(
        'Option field ID is missing.',
      );
    }

    final bool dependsOnPhone =
        _optionsDependOnPhone(
      field,
    );

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'MOBILE RELOAD OPTIONS',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'Product      : $_code',
    );
    debugPrint(
      'Field        : $fieldId',
    );
    debugPrint(
      'Category     : $_category',
    );
    debugPrint(
      'Depends phone: $dependsOnPhone',
    );
    debugPrint(
      'Phone        : ${widget.phoneNumber}',
    );
    debugPrint(
      '========================================',
    );

    final MobileReloadOptionsResult result =
        await MobileReloadOptionsService
            .getOptions(
      productCode:
          _code,

      fieldId:
          fieldId,

      accountNumber:
          dependsOnPhone
              ? widget.phoneNumber
              : null,
    );

    if (!mounted) {
      return;
    }

    final List<MobileReloadOption>
        available =
        result.options
            .where(
              (
                MobileReloadOption option,
              ) =>
                  option.isActive,
            )
            .toList();

    available.sort(
      (
        a,
        b,
      ) =>
          a.priceAmount.compareTo(
        b.priceAmount,
      ),
    );

    setState(() {
      _options =
          available;

      _selectedOption =
          available.isEmpty
              ? null
              : available.first;

      _isLoading =
          false;
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _handleScroll();
      },
    );
  }

  // ==========================================================================
  // MONEY CONFIGURATION
  // ==========================================================================

  void _configureMoneyField(
    Map<String, dynamic> field,
  ) {
    final dynamic validationRaw =
        field['validation'];

    if (validationRaw is! Map) {
      throw Exception(
        'Amount validation is missing.',
      );
    }

    final Map<String, dynamic>
        validation =
        Map<String, dynamic>.from(
      validationRaw,
    );

    final double minimum =
        _toDouble(
      validation['min'],
    );

    final double maximum =
        _toDouble(
      validation['max'],
    );

    if (minimum <= 0 ||
        maximum <= 0 ||
        maximum < minimum) {
      throw Exception(
        'Invalid Mobile Reload '
        'amount range.',
      );
    }

    _minimumAmount =
        minimum;

    _maximumAmount =
        maximum;

    _selectedCustomAmount =
        minimum;

    _updateAmountController(
      minimum,
    );
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

  // ==========================================================================
  // ERROR
  // ==========================================================================

  void _setError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage =
          message;

      _isLoading =
          false;
    });
  }

  // ==========================================================================
  // AMOUNT
  // ==========================================================================

  void _updateAmountController(
    double amount,
  ) {
    _amountController.text =
        amount.toStringAsFixed(
      2,
    );
  }

  void _setCustomAmount(
    double amount,
  ) {
    double value =
        amount;

    if (value <
        _minimumAmount) {
      value =
          _minimumAmount;
    }

    if (value >
        _maximumAmount) {
      value =
          _maximumAmount;
    }

    setState(() {
      _selectedCustomAmount =
          value;

      _updateAmountController(
        value,
      );
    });
  }

  void _increaseAmount() {
    _setCustomAmount(
      _selectedCustomAmount +
          _amountStep,
    );
  }

  void _decreaseAmount() {
    _setCustomAmount(
      _selectedCustomAmount -
          _amountStep,
    );
  }

  // ==========================================================================
  // QUICK AMOUNTS
  // ==========================================================================

  List<double> get _quickAmounts {
    final List<double> candidates = [
      5,
      10,
      20,
      30,
      50,
      100,
      200,
    ];

    return candidates
        .where(
          (
            double value,
          ) =>
              value >=
                  _minimumAmount &&
              value <=
                  _maximumAmount,
        )
        .take(
          4,
        )
        .toList();
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

  String _formatButtonMoney(
    double amount,
  ) {
    if (amount ==
        amount.roundToDouble()) {
      return 'RM '
          '${amount.toStringAsFixed(0)}';
    }

    return _formatMoney(
      amount,
    );
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

  // ==========================================================================
  // PROCESSING TIME
  // ==========================================================================

  String _formatProcessingTime(
    AppLocalizations loc,
  ) {
    final String value =
        _processingTime
            .trim()
            .toLowerCase();

    switch (value) {
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
  // CUSTOM AMOUNT KEYPAD
  // ==========================================================================

  Future<void> _openAmountKeyboard() async {
    String temporary =
        _selectedCustomAmount
            .toStringAsFixed(
      2,
    );

    await showGeneralDialog<void>(
      context:
          context,

      barrierDismissible:
          false,

      barrierLabel:
          'Amount',

      barrierColor:
          Colors.black.withOpacity(
        0.60,
      ),

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
      void pressNumber(
        String number,
      ) {
        if (temporary.length >= 10) {
          return;
        }
        if (temporary == '0.00' ||
            temporary == '0') {
          temporary = number;
        } else {
          if (temporary.contains('.')) {
            final String decimals =
                temporary
                    .split('.')
                    .last;

            if (decimals.length >= 2) {
              return;
            }
          }

          temporary += number;
        }

        // ================================================================
        // DO NOT CHECK MIN/MAX WHILE USER IS TYPING
        //
        // Validation happens only when user presses OK.
        // ================================================================

        setKeyboardState(
          () {},
        );
      }

            void pressDecimal() {
              if (temporary.contains(
                '.',
              )) {
                return;
              }

              temporary +=
                  '.';

              setKeyboardState(
                () {},
              );
            }

            void pressBackspace() {
              if (temporary.isEmpty) {
                return;
              }

              temporary =
                  temporary.substring(
                0,
                temporary.length -
                    1,
              );

              setKeyboardState(
                () {},
              );
            }

            void pressClear() {
              temporary =
                  '';

              setKeyboardState(
                () {},
              );
            }

      Future<void> pressDone() async {
        final loc =
            AppLocalizations.of(context)!;

        final double amount =
            double.tryParse(
                  temporary,
                ) ??
                0;

        // ================================================================
        // BELOW MINIMUM
        // ================================================================

        if (amount < _minimumAmount) {
          // Set final value to catalog minimum.
          _setCustomAmount(
            _minimumAmount,
          );

          // Show information first.
          await _showMessage(
            loc.mobileReloadMinimumAmountMessage(
              _formatMoney(
                _minimumAmount,
              ),
            ),
          );

          // After user presses OK on information popup,
          // close the amount keypad too.
          if (dialogContext.mounted) {
            Navigator.pop(
              dialogContext,
            );
          }

          return;
        }

        // ================================================================
        // ABOVE MAXIMUM
        // ================================================================

        if (amount > _maximumAmount) {
          // Set final value to catalog maximum.
          _setCustomAmount(
            _maximumAmount,
          );

          // Show information first.
          await _showMessage(
            loc.mobileReloadMaximumAmountMessage(
              _formatMoney(
                _maximumAmount,
              ),
            ),
          );

          // After user presses OK on information popup,
          // close the amount keypad too.
          if (dialogContext.mounted) {
            Navigator.pop(
              dialogContext,
            );
          }

          return;
        }

        // ================================================================
        // VALID AMOUNT
        // ================================================================

        _setCustomAmount(
          amount,
        );

        if (dialogContext.mounted) {
          Navigator.pop(
            dialogContext,
          );
        }
      }

            Widget numberButton(
              String value,
            ) {
              return SizedBox(
                height: 90,
                child:
                    ElevatedButton(
                  onPressed: () {
                    pressNumber(
                      value,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white,
                    foregroundColor:
                        const Color(
                      0xFF17283E,
                    ),
                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xFFD3DCE8,
                      ),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 38,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              );
            }

            return SafeArea(
              child: Center(
                child: Material(
                  color:
                      Colors.transparent,
                  child: Container(
                    width: 680,
                    padding:
                        const EdgeInsets.all(
                      32,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF8FAFC,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        32,
                      ),
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
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
                              width: 3,
                            ),
                          ),
                          child: Text(
                            temporary.isEmpty
                                ? 'RM 0.00'
                                : 'RM $temporary',
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF17283E,
                              ),
                              fontSize: 48,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          '${_formatMoney(_minimumAmount)}'
                          ' - '
                          '${_formatMoney(_maximumAmount)}',
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF657386,
                            ),
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.55,
                          children: [
                            numberButton(
                              '1',
                            ),
                            numberButton(
                              '2',
                            ),
                            numberButton(
                              '3',
                            ),
                            numberButton(
                              '4',
                            ),
                            numberButton(
                              '5',
                            ),
                            numberButton(
                              '6',
                            ),
                            numberButton(
                              '7',
                            ),
                            numberButton(
                              '8',
                            ),
                            numberButton(
                              '9',
                            ),

                            ElevatedButton(
                              onPressed:
                                  pressDecimal,
                              child:
                                  const Text(
                                '.',
                                style:
                                    TextStyle(
                                  fontSize: 38,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ),

                            numberButton(
                              '0',
                            ),

                            ElevatedButton(
                              onPressed:
                                  pressBackspace,
                              child:
                                  const Icon(
                                Icons
                                    .backspace_outlined,
                                size: 35,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  SizedBox(
                                height: 78,
                                child:
                                    ElevatedButton(
                                  onPressed:
                                      pressClear,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _redColor,
                                    foregroundColor:
                                        Colors.white,
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .delete_sweep_rounded,
                                    size: 35,
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
                                  ),
                                  label:
                                      const Text(
                                    'OK',
                                    style:
                                        TextStyle(
                                      fontSize: 27,
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
  // CONTINUE
  // ==========================================================================

  void _handleContinue() {
    final loc =
        AppLocalizations.of(context)!;

    if (!_isProductActive) {
      _showMessage(
        loc.mobileReloadUnavailableMessage,
      );

      return;
    }

    if (_mode ==
            MobileReloadSelectionMode
                .internetPlan ||
        _mode ==
            MobileReloadSelectionMode
                .prepaidOptions) {
      if (_selectedOption == null) {
        _showMessage(
          loc.mobileReloadSelectOptionRequired,
        );

        return;
      }
    }

    if (_mode ==
        MobileReloadSelectionMode
            .prepaidCustomAmount) {
      if (_selectedCustomAmount <
              _minimumAmount ||
          _selectedCustomAmount >
              _maximumAmount) {
        _showMessage(
          loc.mobileReloadInvalidAmount,
        );

        return;
      }
    }

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'MOBILE RELOAD PAGE 5 SELECTION',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'Product     : $_code',
    );
    debugPrint(
      'Category    : $_category',
    );
    debugPrint(
      'Mode        : $_mode',
    );
    debugPrint(
      'Phone       : ${widget.phoneNumber}',
    );
    debugPrint(
      'Option code : ${_selectedOption?.code}',
    );
    debugPrint(
      'Option name : ${_selectedOption?.displayName}',
    );
    debugPrint(
      'Base amount : $_baseAmount',
    );
    debugPrint(
      'Adjustment  : $_adjustmentAmount',
    );
    debugPrint(
      'Total       : $_totalAmount',
    );
    debugPrint(
      '========================================',
    );

    // ========================================================================
    // NEXT PAGE
    //
    // We will build PMOBILERELOAD6PAGE next.
    //
    // It should receive:
    //
    // productCode
    // providerName
    // providerImageUrl
    // phoneNumber
    // category
    // fieldId
    // optionCode (if select)
    // optionName
    // optionDescription
    // baseAmount
    // adjustmentAmount
    // totalAmount
    // processingTime
    //
    // ========================================================================

    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PMOBILERELOAD6PAGE(
          productCode:
              _code,
          providerName:
              _productName,
          providerImageUrl:
              _imageUrl,
          phoneNumber:
              widget.phoneNumber,
          category:
              _category.name,
          fieldId:
              _pricingField?['id']
                      ?.toString() ??
                  '',
          optionCode:
              _selectedOption?.code,
          optionName:
              _selectedOption?.displayName,
          optionDescription:
              _selectedOption?.description,
          baseAmount:
              _baseAmount,
          adjustmentAmount:
              _adjustmentAmount,
          totalAmount:
              _totalAmount,
          processingTime:
              _processingTime,
        ),
      ),
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
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
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
            child: Column(
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
                                strokeWidth: 6,
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

                if (!_isLoading &&
                    _errorMessage ==
                        null)
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
    final bool internet =
        _category ==
        MobileReloadProductCategory
            .mobileData;

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
        horizontal: 30,
        vertical: 23,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            _darkColor,
            _primaryColor,
            Color(
              0xFF9A78F2,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
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
            child: Image.network(
              _imageUrl,
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
                      .phone_android_rounded,
                  color:
                      _primaryColor,
                  size: 55,
                );
              },
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
                  _productName
                      .toUpperCase(),
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 34,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  internet
                      ? loc
                          .mobileReloadInternetPlanSubtitle
                      : loc
                          .mobileReloadPrepaidSubtitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            internet
                ? Icons
                    .signal_cellular_alt_rounded
                : Icons
                    .phone_android_rounded,
            size: 58,
            color:
                Colors.white,
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
      child: Scrollbar(
        controller:
            _scrollController,
        thumbVisibility:
            true,
        trackVisibility:
            true,
        thickness:
            12,
        radius:
            const Radius.circular(
          20,
        ),
        child:
            SingleChildScrollView(
          controller:
              _scrollController,
          physics:
              const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            70,
            30,
            70,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              _buildPhoneCard(
                loc,
              ),

              const SizedBox(
                height: 25,
              ),

              if (_mode ==
                  MobileReloadSelectionMode
                      .internetPlan)
                _buildInternetPlans(
                  loc,
                )
              else if (_mode ==
                  MobileReloadSelectionMode
                      .prepaidOptions)
                _buildPrepaidOptions(
                  loc,
                )
              else if (_mode ==
                  MobileReloadSelectionMode
                      .prepaidCustomAmount)
                _buildCustomAmount(
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
  // PHONE CARD
  // ==========================================================================

  Widget _buildPhoneCard(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 22,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD9D2F6,
          ),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
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
              Icons
                  .phone_android_rounded,
              color:
                  _primaryColor,
              size: 40,
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
                  loc.mobileReloadPhoneNumber,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF68778A,
                    ),
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  widget.phoneNumber,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize: 34,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .verified_rounded,
            color:
                _greenColor,
            size: 38,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INTERNET PLAN UI
  // ==========================================================================

  Widget _buildInternetPlans(
    AppLocalizations loc,
  ) {
    return _sectionCard(
      title:
          loc.mobileReloadSelectInternetPlan,
      subtitle:
          loc.mobileReloadSelectInternetPlanHint,
      child:
          _options.isEmpty
              ? _emptyOptions(
                  loc,
                )
              : Column(
                  children:
                      _options.map(
                    (
                      option,
                    ) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 18,
                        ),
                        child:
                            _buildInternetPlanCard(
                          option,
                        ),
                      );
                    },
                  ).toList(),
                ),
    );
  }

  Widget _buildInternetPlanCard(
    MobileReloadOption option,
  ) {
    final bool selected =
        identical(
      _selectedOption,
      option,
    );

    return Material(
      color:
          Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOption =
                option;
          });
        },
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 160,
          ),
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            24,
          ),
          decoration:
              BoxDecoration(
            color:
                selected
                    ? const Color(
                        0xFFF1ECFF,
                      )
                    : const Color(
                        0xFFFAFBFC,
                      ),
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            border:
                Border.all(
              color:
                  selected
                      ? _primaryColor
                      : const Color(
                          0xFFD4DDE8,
                        ),
              width:
                  selected
                      ? 3
                      : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      option.displayName,
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

                    if (option
                        .description
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 9,
                      ),

                      Text(
                        option.description,
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF68778A,
                          ),
                          fontSize: 24,
                          height: 1.35,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 13,
                    ),

                    // Text(
                    //   _formatMoney(
                    //     option.priceAmount,
                    //   ),
                    //   style:
                    //       const TextStyle(
                    //     color:
                    //         _greenColor,
                    //     fontSize: 29,
                    //     fontWeight:
                    //         FontWeight.w900,
                    //   ),
                    // ),
                  ],
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              Icon(
                selected
                    ? Icons
                        .check_circle_rounded
                    : Icons
                        .radio_button_unchecked_rounded,
                color:
                    selected
                        ? _primaryColor
                        : const Color(
                            0xFFAAB6C4,
                          ),
                size: 42,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PREPAID SELECT UI
  // ==========================================================================

  Widget _buildPrepaidOptions(
    AppLocalizations loc,
  ) {
    return _sectionCard(
      title:
          loc.mobileReloadSelectReloadAmount,
      subtitle:
          loc.mobileReloadSelectReloadAmountHint,
      child:
          _options.isEmpty
              ? _emptyOptions(
                  loc,
                )
              : LayoutBuilder(
                  builder:
                      (
                    context,
                    constraints,
                  ) {
                    final double itemWidth =
                        (
                              constraints.maxWidth -
                                  18
                            ) /
                            2;

                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children:
                          _options.map(
                        (
                          option,
                        ) {
                          final bool selected =
                              identical(
                            _selectedOption,
                            option,
                          );

                          return SizedBox(
                            width:
                                itemWidth,
                            child:
                                InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedOption =
                                      option;
                                });
                              },
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                              child:
                                  AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds: 160,
                                ),
                                height: 115,
                                alignment:
                                    Alignment.center,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      selected
                                          ? _lightColor
                                          : Colors.white,
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
                                                0xFFD3DCE8,
                                              ),
                                    width:
                                        selected
                                            ? 3
                                            : 2,
                                  ),
                                ),
                                child:
                                    Text(
                                  _formatButtonMoney(
                                    option.priceAmount,
                                  ),
                                  style:
                                      TextStyle(
                                    color:
                                        selected
                                            ? _darkColor
                                            : const Color(
                                                0xFF17283E,
                                              ),
                                    fontSize: 31,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
    );
  }

  // ==========================================================================
  // CUSTOM AMOUNT UI
  // ==========================================================================

  Widget _buildCustomAmount(
    AppLocalizations loc,
  ) {
    return _sectionCard(
      title:
          loc.mobileReloadEnterReloadAmount,
      subtitle:
          loc.mobileReloadEnterReloadAmountHint,
      child:
          Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 85,
                height: 85,
                child:
                    ElevatedButton(
                  onPressed:
                      _decreaseAmount,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        _lightColor,
                    foregroundColor:
                        _darkColor,
                  ),
                  child:
                      const Icon(
                    Icons.remove_rounded,
                    size: 42,
                  ),
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              Expanded(
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
                    height: 100,
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF8FAFD,
                      ),
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
                        Text(
                      _formatMoney(
                        _selectedCustomAmount,
                      ),
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17283E,
                        ),
                        fontSize: 39,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              SizedBox(
                width: 85,
                height: 85,
                child:
                    ElevatedButton(
                  onPressed:
                      _increaseAmount,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        _primaryColor,
                    foregroundColor:
                        Colors.white,
                  ),
                  child:
                      const Icon(
                    Icons.add_rounded,
                    size: 42,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            '${loc.mobileReloadMinimum}: '
            '${_formatMoney(_minimumAmount)}'
            '    |    '
            '${loc.mobileReloadMaximum}: '
            '${_formatMoney(_maximumAmount)}',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF657386,
              ),
              fontSize: 21,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          if (_quickAmounts
              .isNotEmpty) ...[
            const SizedBox(
              height: 22,
            ),

            Wrap(
              alignment:
                  WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children:
                  _quickAmounts.map(
                (
                  amount,
                ) {
                  return SizedBox(
                    height: 68,
                    child:
                        OutlinedButton(
                      onPressed: () {
                        _setCustomAmount(
                          amount,
                        );
                      },
                      child:
                          Text(
                        _formatButtonMoney(
                          amount,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ],
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
      child: Column(
        children: [
          _SummaryRow(
            label:
                loc.mobileReloadProvider,
            value:
                _productName,
          ),

          const Divider(
            height: 32,
          ),

          _SummaryRow(
            label:
                loc.mobileReloadPhoneNumber,
            value:
                widget.phoneNumber,
          ),

          if (_selectedOption !=
              null) ...[
            const Divider(
              height: 32,
            ),

            _SummaryRow(
              label:
                  _mode ==
                          MobileReloadSelectionMode
                              .internetPlan
                      ? loc
                          .mobileReloadSelectedPlan
                      : loc
                          .mobileReloadReloadAmount,
              value:
                  _mode ==
                          MobileReloadSelectionMode
                              .internetPlan
                      ? _selectedOption!
                          .displayName
                      : _formatMoney(
                          _baseAmount,
                        ),
            ),
          ],

          if (_mode ==
              MobileReloadSelectionMode
                  .prepaidCustomAmount) ...[
            const Divider(
              height: 32,
            ),

            _SummaryRow(
              label:
                  loc.mobileReloadReloadAmount,
              value:
                  _formatMoney(
                _baseAmount,
              ),
            ),
          ],

          if (_hasAdjustment) ...[
            const Divider(
              height: 32,
            ),

            _SummaryRow(
              label:
                  loc.mobileReloadServiceAdjustment,
              value:
                  _formatSignedMoney(
                _adjustmentAmount,
              ),
            ),
          ],

          const Divider(
            height: 34,
          ),

          Container(
            padding:
                const EdgeInsets.all(
              20,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF8EE,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child:
                _SummaryRow(
              label:
                  loc.mobileReloadTotalPayment,
              value:
                  _formatMoney(
                _totalAmount,
              ),
              isTotal:
                  true,
            ),
          ),

          const Divider(
            height: 32,
          ),

          _SummaryRow(
            label:
                loc.processingTimeLabel,
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
  // COMMON SECTION
  // ==========================================================================

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF17283E,
              ),
              fontSize: 34,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            subtitle,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF68778A,
              ),
              fontSize: 23,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          child,
        ],
      ),
    );
  }

  Widget _emptyOptions(
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
            const Color(
          0xFFFFF3E0,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child:
          Text(
        loc.mobileReloadNoOptions,
        textAlign:
            TextAlign.center,
        style:
            const TextStyle(
          color:
              Color(
            0xFFE65100,
          ),
          fontSize: 25,
          fontWeight:
              FontWeight.w800,
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
      padding: const EdgeInsets.fromLTRB(
        70,
        8,
        70,
        55,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================================================================
          // SCROLL FOR MORE
          // ================================================================
         
          AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 180,
            ),
            child: _showScrollHint
                ? Container(
                    key: const ValueKey(
                      'scroll-hint',
                    ),
                    margin: const EdgeInsets.only(
                      bottom: 50, 
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFF1ECFF,
                      ),
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                      border: Border.all(
                        color: _primaryColor.withOpacity(
                          0.40,
                        ),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _primaryColor,
                          size: 38,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Flexible(
                          child: Text(
                            loc
                                .scrollForMoreInformation
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _darkColor,

                              fontSize: 25,

                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _primaryColor,
                          size: 38,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ==================================================================
          // BACK / CONTINUE
          // ==================================================================

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 94,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 36,
                    ),
                    label: Text(
                      loc.buttonBack,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF17283E),
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFF17283E),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 22),

              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 94,
                  child: ElevatedButton.icon(
                    onPressed: _handleContinue,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 36,
                    ),
                    label: Text(
                      loc.buttonContinue.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1769D2),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ==================================================================
          // GAP BETWEEN BUTTONS AND COPYRIGHT
          // ==================================================================

          const SizedBox(
            height: 40,
          ),

          Text(
            Data.copyrightText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(
                0xFF26364A,
              ),
              fontSize: 18,
              fontWeight: FontWeight.w800,
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
      child: Container(
        width: 680,
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
        child: Column(
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
              height: 20,
            ),

            Text(
              loc.mobileReloadErrorTitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 38,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 78,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _loadProduct,
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),
                label:
                    Text(
                  loc.mobileReloadRetry,
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
      ),
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

Future<void> _showMessage(
  String message,
) async {
  if (!mounted) {
    return;
  }

  final loc =
      AppLocalizations.of(context)!;

  await showGeneralDialog<void>(
    context: context,

    barrierDismissible: false,

    barrierLabel:
        loc.electricInformation,

    barrierColor:
        const Color(0xFF120A24)
            .withOpacity(0.72),

    transitionDuration:
        const Duration(
      milliseconds: 280,
    ),

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

              margin:
                  const EdgeInsets.symmetric(
                horizontal: 70,
                vertical: 120,
              ),

              padding:
                  const EdgeInsets.fromLTRB(
                46,
                42,
                46,
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
                      const Color(
                    0xFFD8C7FF,
                  ),
                  width: 3,
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(
                      0.35,
                    ),
                    blurRadius: 45,
                    offset:
                        const Offset(
                      0,
                      22,
                    ),
                  ),

                  BoxShadow(
                    color:
                        _primaryColor.withOpacity(
                      0.22,
                    ),
                    blurRadius: 55,
                    spreadRadius: 4,
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
                    width: 130,
                    height: 130,

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      gradient:
                          const LinearGradient(
                        begin:
                            Alignment.topLeft,
                        end:
                            Alignment.bottomRight,
                        colors: [
                          Color(
                            0xFFA77BFF,
                          ),
                          Color(
                            0xFF56339B,
                          ),
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              _primaryColor
                                  .withOpacity(
                            0.30,
                          ),
                          blurRadius: 26,
                          spreadRadius: 3,
                        ),
                      ],
                    ),

                    child:
                        const Icon(
                      Icons
                          .info_outline_rounded,
                      color:
                          Colors.white,
                      size: 72,
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==========================================================
                  // TITLE
                  // ==========================================================

                  Text(
                    loc.electricInformation,
                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      color:
                          _darkColor,
                      fontSize: 44,
                      fontWeight:
                          FontWeight.w900,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==========================================================
                  // ACCENT LINE
                  // ==========================================================

                  Container(
                    width: 120,
                    height: 6,

                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(
                            0xFFA77BFF,
                          ),
                          Color(
                            0xFF56339B,
                          ),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==========================================================
                  // MESSAGE BOX
                  // ==========================================================

                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 28,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF7F3FF,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),

                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFFE3D7FF,
                        ),
                        width: 2,
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
                            FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 34,
                  ),

                  // ==========================================================
                  // OK
                  // ==========================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 92,

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
                        size: 38,
                      ),

                      label:
                          Text(
                        loc.mobileReloadOkButton,

                        style:
                            const TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing:
                              0.5,
                        ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            _primaryColor,

                        foregroundColor:
                            Colors.white,

                        elevation: 0,

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
      final CurvedAnimation
          curvedAnimation =
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
            begin: 0.82,
            end: 1.0,
          ).animate(
            curvedAnimation,
          ),

          child:
              child,
        ),
      );
    },
  );
}
}

// ============================================================================
// SUMMARY
// ============================================================================

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
                  const Color(
                0xFF657386,
              ),
              fontSize:
                  isTotal
                      ? 28
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
                  isTotal
                      ? const Color(
                          0xFF16813B,
                        )
                      : const Color(
                          0xFF17283E,
                        ),
              fontSize:
                  isTotal
                      ? 34
                      : 25,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}