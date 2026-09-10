import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/payment/bill/console_store_qr_payment_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_gaming_options_service.dart';

// ============================================================================
// CONSOLE & APP STORES PAGE 4
//
// IMPORTANT:
//
// CUSTOMER PRICE:
// selected option -> price.amount
//
// IIMMPACT AMOUNT:
// selected option -> code
//
// Example:
//
// Apple $2
//
// selected.code        = "2"
// selected.priceAmount = 8.60
//
// Therefore:
//
// IIMMPACT amount = 2
// Customer price  = RM 8.60
//
// NO PRODUCT HARDCODING:
// APPLE / NINTENDO / PSN are NOT checked manually.
// ============================================================================

class PCONSOLESTORES4PAGE extends StatefulWidget {
  final String productCode;
  final String productName;
  final String imageUrl;

  const PCONSOLESTORES4PAGE({
    super.key,
    required this.productCode,
    required this.productName,
    required this.imageUrl,
  });

  @override
  State<PCONSOLESTORES4PAGE> createState() =>
      _PCONSOLESTORES4PAGEState();
}

class _PCONSOLESTORES4PAGEState
    extends State<PCONSOLESTORES4PAGE> {
  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  final ValueNotifier<bool> _showScrollHint =
      ValueNotifier<bool>(false);

  // ==========================================================================
  // API
  // ==========================================================================

  Map<String, dynamic>? _product;

  List<GamingOption> _options =
      <GamingOption>[];

  GamingOption? _selectedOption;

  CatalogPricing _catalogPricing =
      CatalogPricing.empty();

  bool _isLoading = true;

  String? _errorMessage;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF3949AB);

  static const Color _darkColor =
      Color(0xFF283593);

  static const Color _lightColor =
      Color(0xFFE8EAF6);

  static const Color _selectedBackground =
      Color(0xFFEEF0FF);

  static const Color _selectedBorder =
      Color(0xFF3949AB);

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

    if (value.isNotEmpty) {
      return value;
    }

    return widget.productName;
  }

  String get _imageUrl {
    final String value =
        _product?['image_url']
                ?.toString()
                .trim() ??
            '';

    if (value.isNotEmpty) {
      return value;
    }

    return widget.imageUrl;
  }

  String get _processingTime =>
      _product?['processing_time']
              ?.toString()
              .trim() ??
          '';

  String get _productNote =>
      _product?['note']
              ?.toString()
              .trim() ??
          '';

  bool get _isProductActive =>
      _product?['is_active'] == true;

  // ==========================================================================
  // DYNAMIC PRICING FIELD
  // ==========================================================================

  Map<String, dynamic>? get _pricingField {
    final dynamic fieldsRaw =
        _product?['fields'];

    if (fieldsRaw is! List) {
      return null;
    }

    // First preference:
    // select + pricing
    for (final dynamic rawField in fieldsRaw) {
      if (rawField is! Map) {
        continue;
      }

      final Map<String, dynamic> field =
          Map<String, dynamic>.from(
        rawField,
      );

      final String type =
          field['type']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      final String role =
          field['role']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      if (type == 'select' &&
          role == 'pricing') {
        return field;
      }
    }

    // Fallback:
    // first select field
    for (final dynamic rawField in fieldsRaw) {
      if (rawField is! Map) {
        continue;
      }

      final Map<String, dynamic> field =
          Map<String, dynamic>.from(
        rawField,
      );

      final String type =
          field['type']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      if (type == 'select') {
        return field;
      }
    }

    return null;
  }

  String get _fieldId =>
      _pricingField?['id']
              ?.toString()
              .trim() ??
          '';

  String get _fieldLabel =>
      _pricingField?['label']
              ?.toString()
              .trim() ??
          '';

  // ==========================================================================
  // CUSTOMER PRICE
  //
  // This remains selected.priceAmount.
  //
  // Example Apple $2:
  // RM 8.60
  // ==========================================================================

  double get _baseAmount =>
      _selectedOption?.priceAmount ??
      0;

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
  // IIMMPACT AMOUNT
  //
  // IMPORTANT FIX:
  //
  // Do NOT send selected.priceAmount.
  //
  // Use selected option CODE.
  //
  // Apple $2:
  //
  // code       = "2"
  // priceAmount = 8.60
  //
  // IIMMPACT receives amount = 2
  //
  // This is still dynamic.
  // ==========================================================================

  double? _resolveIimmpactAmount(
    GamingOption option,
  ) {
    final String code =
        option.code.trim();

    if (code.isEmpty) {
      return null;
    }

    // Direct integer / numeric code.
    final double? parsed =
        double.tryParse(
      code,
    );

    if (parsed == null ||
        parsed <= 0) {
      return null;
    }

    return parsed;
  }

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );

    _loadProductAndOptions();
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _scrollController.removeListener(
      _handleScroll,
    );

    _scrollController.dispose();

    _showScrollHint.dispose();

    super.dispose();
  }

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position =
        _scrollController.position;

    final bool canScroll =
        position.maxScrollExtent >
        5;

    final bool isAtBottom =
        position.pixels >=
            position.maxScrollExtent -
                10;

    final bool shouldShow =
        canScroll &&
        !isAtBottom;

    if (_showScrollHint.value !=
        shouldShow) {
      _showScrollHint.value =
          shouldShow;
    }
  }

  void _checkScrollHintAfterLayout() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted ||
            !_scrollController
                .hasClients) {
          return;
        }

        final ScrollPosition position =
            _scrollController.position;

        final bool canScroll =
            position.maxScrollExtent >
            5;

        final bool isAtBottom =
            position.pixels >=
                position
                        .maxScrollExtent -
                    10;

        final bool shouldShow =
            canScroll &&
            !isAtBottom;

        if (_showScrollHint.value !=
            shouldShow) {
          _showScrollHint.value =
              shouldShow;
        }
      },
    );
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position =
        _scrollController.position;

    final double destination =
        (_scrollController.offset +
                500)
            .clamp(
      0.0,
      position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration:
          const Duration(
        milliseconds: 400,
      ),
      curve:
          Curves.easeOut,
    );
  }

  // ==========================================================================
  // LOAD PRODUCT + OPTIONS
  // ==========================================================================

  Future<void>
      _loadProductAndOptions() async {
    if (mounted) {
      setState(() {
        _isLoading =
            true;

        _errorMessage =
            null;

        _product =
            null;

        _options =
            <GamingOption>[];

        _selectedOption =
            null;
      });
    }

    _showScrollHint.value =
        false;

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
          'Catalog products missing.',
        );
      }

      // ======================================================================
      // PRODUCT
      // ======================================================================

      final dynamic rawProduct =
          productsRaw[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'Console store product '
          '$_code not found.',
        );
      }

      final Map<String, dynamic>
          product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      if (product['is_active'] !=
          true) {
        throw Exception(
          'Console store product '
          '$_code unavailable.',
        );
      }

      // ======================================================================
      // CUSTOMER PRICING
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
        _product =
            product;

        _catalogPricing =
            pricing;
      });

      // ======================================================================
      // FIELD
      // ======================================================================

      final String fieldId =
          _fieldId;

      if (fieldId.isEmpty) {
        throw Exception(
          'Pricing field not found '
          'for $_code.',
        );
      }

      // ======================================================================
      // OPTIONS
      // ======================================================================

      final GamingOptionsResult
          result =
          await IimmpactGamingOptionsService
              .getOptions(
        productCode:
            _code,
        fieldId:
            fieldId,
      );

      if (!mounted) {
        return;
      }

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

      activeOptions.sort(
        (
          GamingOption a,
          GamingOption b,
        ) {
          return a.priceAmount
              .compareTo(
            b.priceAmount,
          );
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _options =
            activeOptions;

        _selectedOption =
            null;

        _isLoading =
            false;

        _errorMessage =
            null;
      });

      _checkScrollHintAfterLayout();

      // ======================================================================
      // DEBUG
      // ======================================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'CONSOLE STORE PAGE 4 LOADED',
      );
      debugPrint(
        '========================================',
      );

      debugPrint(
        'Product Code : $_code',
      );

      debugPrint(
        'Product Name : $_productName',
      );

      debugPrint(
        'Field ID     : $_fieldId',
      );

      debugPrint(
        'Field Label  : $_fieldLabel',
      );

      debugPrint(
        'Options      : ${_options.length}',
      );

      debugPrint(
        'Processing   : $_processingTime',
      );

      for (final GamingOption option
          in _options) {
        debugPrint(
          'OPTION => '
          'code=${option.code}, '
          'name=${option.displayName}, '
          'description=${option.description}, '
          'price=${option.priceAmount}, '
          'iimmpactAmount='
          '${_resolveIimmpactAmount(option)}, '
          'active=${option.isActive}',
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
        'Console Store Page 4 '
        'load error: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      _setLoadError(
        error.toString(),
      );
    }
  }

  // ==========================================================================
  // ERROR
  // ==========================================================================

  void _setLoadError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    _showScrollHint.value =
        false;

    setState(() {
      _errorMessage =
          message;

      _isLoading =
          false;

      _selectedOption =
          null;
    });
  }

  // ==========================================================================
  // FORMATTING
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

      case 'pin':
        return 'PIN';

      case 'link':
        return 'LINK';

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

  String _optionName(
    GamingOption option,
  ) {
    final String name =
        option.displayName.trim();

    if (name.isNotEmpty) {
      return name;
    }

    final String code =
        option.code.trim();

    if (code.isNotEmpty) {
      return code;
    }

    return '-';
  }

  // ==========================================================================
  // SELECT
  // ==========================================================================

  void _selectOption(
    GamingOption option,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedOption =
          option;
    });

    _checkScrollHintAfterLayout();
  }

  // ==========================================================================
  // CONTINUE
  //
  // THIS IS THE MAIN PAYMENT FIX.
  // ==========================================================================

  Future<void> _handleContinue() async {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    if (!_isProductActive) {
      _showMessage(
        loc.consoleStoreProductUnavailable,
      );

      return;
    }

    final GamingOption? selected =
        _selectedOption;

    if (selected == null) {
      _showMessage(
        loc.consoleStoreSelectPackageRequired,
      );

      return;
    }

    // ========================================================================
    // IMPORTANT:
    //
    // IIMMPACT amount comes from option code.
    //
    // NOT:
    //
    // selected.priceAmount
    //
    // selected.priceAmount is RM customer price.
    // ========================================================================

    final double? iimmpactAmount =
        _resolveIimmpactAmount(
      selected,
    );

    if (iimmpactAmount == null ||
        iimmpactAmount <= 0) {
      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'INVALID CONSOLE OPTION CODE',
      );
      debugPrint(
        '========================================',
      );

      debugPrint(
        'Product Code : $_code',
      );

      debugPrint(
        'Option Code  : ${selected.code}',
      );

      debugPrint(
        'Option Name  : '
        '${selected.displayName}',
      );

      debugPrint(
        'RM Price     : '
        '${selected.priceAmount}',
      );

      debugPrint(
        '========================================',
      );
      debugPrint('');

      _showMessage(
        loc.consoleStoreInvalidOptionValue,
      );

      return;
    }

    if (_baseAmount <= 0 ||
        _totalAmount <= 0) {
      _showMessage(
        loc.paymentAmountMustBeMoreThanZero,
      );

      return;
    }

    // ========================================================================
    // DEBUG
    // ========================================================================

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'CONSOLE STORE PAYMENT VALUES',
    );
    debugPrint(
      '========================================',
    );

    debugPrint(
      'Product Code       : $_code',
    );

    debugPrint(
      'Product Name       : $_productName',
    );

    debugPrint(
      'Field ID           : $_fieldId',
    );

    debugPrint(
      'Option Code        : ${selected.code}',
    );

    debugPrint(
      'Option Name        : '
      '${selected.displayName}',
    );

    debugPrint(
      'Option Description : '
      '${selected.description}',
    );

    // ========================================================================
    // MOST IMPORTANT DEBUG
    // ========================================================================

    debugPrint(
      'IIMMPACT Amount    : '
      '$iimmpactAmount',
    );

    debugPrint(
      'RM Base Price      : '
      '$_baseAmount',
    );

    debugPrint(
      'RM Adjustment      : '
      '$_adjustmentAmount',
    );

    debugPrint(
      'RM Customer Total  : '
      '$_totalAmount',
    );

    debugPrint(
      'Processing         : '
      '$_processingTime',
    );

    debugPrint(
      '========================================',
    );
    debugPrint('');

    // ========================================================================
    // PAYMENT
    // ========================================================================

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                ConsoleStoreQrPaymentPage(
          productCode:
              _code,

          productName:
              _productName,

          imageUrl:
              _imageUrl,

          optionCode:
              selected.code,

          optionName:
              selected.displayName,

          optionDescription:
              selected.description,

          // ================================================================
          // IMPORTANT:
          //
          // APPLE $2:
          // sends 2
          //
          // NOT RM8.60
          // ================================================================

          iimmpactAmount:
              iimmpactAmount,

          // ================================================================
          // CUSTOMER RM PRICE
          // ================================================================

          baseAmount:
              _baseAmount,

          serviceAdjustment:
              _adjustmentAmount,

          totalAmount:
              _totalAmount,

          processingTime:
              _processingTime,

          productNote:
              _productNote,
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
    final AppLocalizations loc =
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
            child: IgnorePointer(
              child: Container(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(
                        0.02,
                      ),
                      Colors.white.withOpacity(
                        0.10,
                      ),
                      Colors.white.withOpacity(
                        0.03,
                      ),
                    ],
                  ),
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
                          ? _buildLoading(
                              loc,
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
        65,
        30,
        65,
        0,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 22,
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
            Color(0xFF283593),
            Color(0xFF3949AB),
            Color(0xFF5C6BC0),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.16,
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

      child: Row(
        children: [
          Container(
            width: 105,
            height: 105,

            padding:
                const EdgeInsets.all(
              14,
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
                _buildLogo(
              62,
            ),
          ),

          const SizedBox(
            width: 24,
          ),

          Expanded(
            child: Column(
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
                    fontSize: 35,
                    fontWeight:
                        FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  loc
                      .consoleStoreCategoryLabel,

                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          const Icon(
            Icons.devices_other_rounded,
            color:
                Colors.white,
            size: 62,
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
        width: 680,

        padding:
            const EdgeInsets.all(
          40,
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
                _lightColor,
            width: 2,
          ),
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const SizedBox(
              width: 75,
              height: 75,

              child:
                  CircularProgressIndicator(
                strokeWidth: 6,
                color:
                    _primaryColor,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            Text(
              loc.providerLoading,

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
              height: 10,
            ),

            Text(
              loc.providerLoadingSubtitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF66758A,
                ),
                fontSize: 21,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // CONTENT
  // ==========================================================================

  Widget _buildContent(
    AppLocalizations loc,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          _showScrollHint,

      builder: (
        BuildContext context,
        bool showHint,
        Widget? child,
      ) {
        return Stack(
          children: [
            Positioned.fill(
              child: Scrollbar(
                controller:
                    _scrollController,

                thumbVisibility:
                    true,

                trackVisibility:
                    true,

                interactive:
                    false,

                thickness: 11,

                radius:
                    const Radius.circular(
                  20,
                ),

                child:
                    SingleChildScrollView(
                  controller:
                      _scrollController,

                  physics:
                      const ClampingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    65,
                    32,
                    75,
                    110,
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,

                    children: [
                      _buildProductCard(
                        loc,
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      _buildOptionSection(
                        loc,
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      _buildSummary(
                        loc,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (showHint)
              Positioned(
                left: 0,
                right: 0,
                bottom: 18,

                child: Center(
                  child:
                      _buildScrollHint(
                    loc,
                  ),
                ),
              ),
          ],
        );
      },
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
            0xFFD3DCE8,
          ),
          width: 2,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 135,
            height: 120,

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
                _buildLogo(
              65,
            ),
          ),

          const SizedBox(
            width: 25,
          ),

          Expanded(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  _productName,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize: 32,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  loc
                      .consoleStoreCategoryLabel,

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
                  height: 13,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
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
                      child: Text(
                        '${loc.processingTimeLabel}: '
                        '${_formatProcessingTime(loc)}',

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

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
  // OPTIONS
  // ==========================================================================

  Widget _buildOptionSection(
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
        mainAxisSize:
            MainAxisSize.min,

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            loc
                .consoleStoreSelectPackageTitle,

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
            height: 7,
          ),

          Text(
            loc
                .consoleStoreSelectPackageSubtitle,

            style:
                const TextStyle(
              color:
                  Color(
                0xFF66758A,
              ),
              fontSize: 23,
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
                25,
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

                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFFFCC80,
                  ),
                  width: 2,
                ),
              ),

              child: Text(
                loc
                    .consoleStoreNoPackagesAvailable,

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
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                final double itemWidth =
                    (
                          constraints
                                  .maxWidth -
                              16
                        ) /
                        2;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,

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
        _selectedOption?.code ==
            option.code;

    final String description =
        option.description.trim();

    return Material(
      color:
          Colors.transparent,

      child: InkWell(
        onTap: () {
          _selectOption(
            option,
          );
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

          curve:
              Curves.easeOut,

          width:
              double.infinity,

          constraints:
              const BoxConstraints(
            minHeight: 180,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),

          decoration:
              BoxDecoration(
            color:
                selected
                    ? _selectedBackground
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
                      ? _selectedBorder
                      : const Color(
                        0xFFD6DEE8,
                      ),

              width:
                  selected
                      ? 3
                      : 2,
            ),
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: Text(
                      _optionName(
                        option,
                      ),

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

                        fontSize: 25,

                        fontWeight:
                            FontWeight.w900,

                        height: 1.16,
                      ),
                    ),
                  ),

                  if (selected) ...[
                    const SizedBox(
                      width: 8,
                    ),

                    const Icon(
                      Icons
                          .check_circle_rounded,
                      color:
                          _primaryColor,
                      size: 31,
                    ),
                  ],
                ],
              ),

              if (description.isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),

                Text(
                  description,

                  maxLines: 4,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF68778A,
                    ),

                    fontSize: 20,

                    fontWeight:
                        FontWeight.w600,

                    height: 1.25,
                  ),
                ),
              ],

              const SizedBox(
                height: 20,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE6F6EC,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    100,
                  ),
                ),

                child: Text(
                  _formatMoney(
                    option.priceAmount,
                  ),

                  style:
                      const TextStyle(
                    color:
                        _greenColor,

                    fontSize: 24,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SUMMARY
  // ==========================================================================

  Widget _buildSummary(
    AppLocalizations loc,
  ) {
    final GamingOption? option =
        _selectedOption;

    return Container(
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
        mainAxisSize:
            MainAxisSize.min,

        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          Text(
            loc
                .consoleStoreOrderSummaryTitle,

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

          _summaryRow(
            loc.consoleStoreProductLabel,
            _productName,
          ),

          const Divider(
            height: 35,
          ),

          _summaryRow(
            loc
                .consoleStoreSelectedPackageLabel,

            option == null
                ? '-'
                : _optionName(
                    option,
                  ),
          ),

          if (option != null &&
              option.description
                  .trim()
                  .isNotEmpty) ...[
            const Divider(
              height: 35,
            ),

            _summaryRow(
              loc
                  .consoleStorePackageDescriptionLabel,

              option.description.trim(),
            ),
          ],

          const Divider(
            height: 35,
          ),

          _summaryRow(
            loc.consoleStoreSubtotalLabel,

            _formatMoney(
              _baseAmount,
            ),
          ),

          if (_hasAdjustment) ...[
            const Divider(
              height: 35,
            ),

            _summaryRow(
              loc
                  .consoleStoreServiceAdjustmentLabel,

              _formatSignedMoney(
                _adjustmentAmount,
              ),
            ),
          ],

          const Divider(
            height: 35,
          ),

          _summaryRow(
            loc
                .consoleStoreTotalAmountLabel,

            _formatMoney(
              _totalAmount,
            ),

            strong:
                true,

            highlight:
                true,
          ),

          const Divider(
            height: 35,
          ),

          _summaryRow(
            loc.processingTimeLabel,

            _formatProcessingTime(
              loc,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool strong = false,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Text(
            label,

            style:
                TextStyle(
              color:
                  const Color(
                0xFF17283E,
              ),

              fontSize:
                  strong
                      ? 29
                      : 25,

              fontWeight:
                  strong
                      ? FontWeight.w900
                      : FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(
          width: 20,
        ),

        Flexible(
          child: Text(
            value,

            textAlign:
                TextAlign.right,

            style:
                TextStyle(
              color:
                  highlight
                      ? _primaryColor
                      : const Color(
                        0xFF17283E,
                      ),

              fontSize:
                  strong
                      ? 31
                      : 25,

              fontWeight:
                  strong
                      ? FontWeight.w900
                      : FontWeight.w700,
            ),
          ),
        ),
      ],
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

        child: Column(
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
              loc
                  .consoleStoreUnableToLoadOptions,

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
              height: 14,
            ),

            Text(
              loc
                  .consoleStoreUnableToLoadOptionsSubtitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF66758A,
                ),
                fontSize: 23,
                height: 1.35,
                fontWeight:
                    FontWeight.w600,
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
                    _loadProductAndOptions,

                icon:
                    const Icon(
                  Icons.refresh_rounded,
                  size: 30,
                ),

                label: Text(
                  loc.retryButton,

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
        65,
        18,
        65,
        60,
      ),

      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 95,

                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    icon:
                        const Icon(
                      Icons.arrow_back_rounded,
                      size: 32,
                    ),

                    label: Text(
                      loc.buttonBack,

                      style:
                          const TextStyle(
                        fontSize: 36,
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

                      side:
                          const BorderSide(
                        color:
                            Color(
                          0xFFD5DCE5,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 24,
              ),

              Expanded(
                child: SizedBox(
                  height: 95,

                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _isLoading ||
                                _selectedOption ==
                                    null
                            ? null
                            : _handleContinue,

                    icon:
                        const Icon(
                      Icons.arrow_forward_rounded,
                      size: 32,
                    ),

                    label: Text(
                      loc.continueButton,

                      style:
                          const TextStyle(
                        fontSize: 36,
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

                      disabledBackgroundColor:
                          const Color(
                        0xFFC5CCD5,
                      ),

                      disabledForegroundColor:
                          Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 40,
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
  // SCROLL HINT
  // ==========================================================================

  Widget _buildScrollHint(
    AppLocalizations loc,
  ) {
    return ExcludeSemantics(
      child: Material(
        color:
            Colors.transparent,

        child: InkWell(
          onTap:
              _scrollDown,

          borderRadius:
              BorderRadius.circular(
            50,
          ),

          child: Container(
            padding:
                const EdgeInsets.fromLTRB(
              24,
              12,
              18,
              12,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF102A43,
              ).withOpacity(
                0.95,
              ),

              borderRadius:
                  BorderRadius.circular(
                50,
              ),

              border:
                  Border.all(
                color:
                    Colors.white,
                width: 2,
              ),
            ),

            child: Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  color:
                      Colors.white,
                  size: 26,
                ),

                const SizedBox(
                  width: 10,
                ),

                Text(
                  loc
                      .scrollForMoreInformation,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                const Icon(
                  Icons
                      .keyboard_arrow_down_rounded,
                  color:
                      Colors.white,
                  size: 35,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // LOGO
  // ==========================================================================

  Widget _buildLogo(
    double fallbackSize,
  ) {
    if (_imageUrl.isEmpty) {
      return Icon(
        Icons.devices_other_rounded,
        size:
            fallbackSize,
        color:
            _primaryColor,
      );
    }

    return Image.network(
      _imageUrl,

      fit:
          BoxFit.contain,

      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent?
            loadingProgress,
      ) {
        if (loadingProgress ==
            null) {
          return child;
        }

        return const Center(
          child:
              CircularProgressIndicator(
            strokeWidth: 3,
            color:
                _primaryColor,
          ),
        );
      },

      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return Icon(
          Icons.devices_other_rounded,
          size:
              fallbackSize,
          color:
              _primaryColor,
        );
      },
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

    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context:
          context,

      barrierDismissible:
          false,

      builder: (
        BuildContext dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,

          child: Container(
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
                    _lightColor,
                width: 2,
              ),
            ),

            child: Column(
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
                    onPressed: () {
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
                    ),

                    child: Text(
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