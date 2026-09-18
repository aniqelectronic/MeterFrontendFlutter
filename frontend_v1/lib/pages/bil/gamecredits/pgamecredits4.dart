import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_gaming_options_service.dart';
import 'package:frontend_v1/pages/bil/gamecredits/pgamecredits5.dart';

// ============================================================================
// GAME CREDITS PAGE 4
//
// FLOW:
//
// PGAMECREDITS3PAGE
//      ↓
// selected productCode
//      ↓
// /v2/catalog
//      ↓
// products[productCode]
//      ↓
// detect pricing/select field dynamically
//      ↓
// /v2/options
//      ↓
// active options only
//      ↓
// user selects one credit/package
//      ↓
// order summary
//
// IMPORTANT:
//
// - Product name comes from catalog
// - Product image comes from catalog
// - Processing time comes from catalog
// - Pricing field comes from catalog
// - Options come from /v2/options
// - Only active options are shown
// - NOTE / IMPORTANT NOTE IS NOT DISPLAYED
// - Price is customer payment price in RM
// - Scroll hint only appears when more content exists below
// ============================================================================

class PGAMECREDITS4PAGE extends StatefulWidget {
  final String productCode;
  final String productName;
  final String imageUrl;

  const PGAMECREDITS4PAGE({
    super.key,
    required this.productCode,
    required this.productName,
    required this.imageUrl,
  });

  @override
  State<PGAMECREDITS4PAGE> createState() =>
      _PGAMECREDITS4PAGEState();
}

class _PGAMECREDITS4PAGEState
    extends State<PGAMECREDITS4PAGE> {
  // ==========================================================================
  // CONTROLLER
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  // ==========================================================================
  // SCROLL INDICATOR
  // ==========================================================================

  bool _showScrollHint = false;

  // ==========================================================================
  // API DATA
  // ==========================================================================

  Map<String, dynamic>? _product;

  List<GamingOption> _options = [];

  GamingOption? _selectedOption;

  CatalogPricing _catalogPricing =
      CatalogPricing.empty();

  bool _isLoading = true;

  String? _errorMessage;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF009688);

  static const Color _darkColor =
      Color(0xFF087A70);

  static const Color _lightColor =
      Color(0xFFE0F5F2);

  static const Color _selectedBackground =
      Color(0xFFE3F7F4);

  static const Color _selectedBorder =
      Color(0xFF009688);

  static const Color _greenColor =
      Color(0xFF16813B);

  static const Color _redColor =
      Color(0xFFD93A3A);

  // ==========================================================================
  // PRODUCT CODE
  // ==========================================================================

  String get _code =>
      widget.productCode
          .trim()
          .toUpperCase();

  // ==========================================================================
  // PRODUCT NAME
  // ==========================================================================

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

  // ==========================================================================
  // IMAGE
  // ==========================================================================

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

  // ==========================================================================
  // PROCESSING TIME
  // ==========================================================================

  String get _processingTime =>
      _product?['processing_time']
              ?.toString()
              .trim() ??
          '';

  // ==========================================================================
  // PRODUCT ACTIVE
  // ==========================================================================

  bool get _isProductActive =>
      _product?['is_active'] == true;

  // ==========================================================================
  // PRICING FIELD
  //
  // DO NOT HARDCODE:
  //
  // package
  // amount
  //
  // Detect pricing field from catalog.
  // ==========================================================================

  Map<String, dynamic>? get _pricingField {
    final dynamic fieldsRaw =
        _product?['fields'];

    if (fieldsRaw is! List) {
      return null;
    }

    // ========================================================================
    // FIRST PREFERENCE:
    // select + pricing
    // ========================================================================

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

    // ========================================================================
    // FALLBACK:
    // first select
    // ========================================================================

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

  // ==========================================================================
  // FIELD ID
  // ==========================================================================

  String get _fieldId =>
      _pricingField?['id']
              ?.toString()
              .trim() ??
          '';

  // ==========================================================================
  // PRICE
  // ==========================================================================

  double get _baseAmount =>
      _selectedOption?.priceAmount ?? 0;

  // ==========================================================================
  // PRICE ADJUSTMENT
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
      _priceAdjustmentResult.amountAfter;

  bool get _hasAdjustment =>
      _adjustmentAmount.abs() >= 0.005;

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );

    _loadProductAndOptions();
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      _handleScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // SCROLL POSITION
  // ==========================================================================

  void _handleScroll() {
    if (!mounted ||
        !_scrollController.hasClients) {
      return;
    }

    final double maxScroll =
        _scrollController
            .position
            .maxScrollExtent;

    final double currentScroll =
        _scrollController.offset;

    final bool shouldShow =
        maxScroll > 20 &&
        currentScroll <
            maxScroll - 20;

    if (_showScrollHint !=
        shouldShow) {
      setState(() {
        _showScrollHint =
            shouldShow;
      });
    }
  }

  // ==========================================================================
  // CHECK WHETHER PAGE CAN SCROLL
  // ==========================================================================

  void _checkScrollAvailability() {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted ||
            !_scrollController
                .hasClients) {
          return;
        }

        _handleScroll();
      },
    );
  }

  // ==========================================================================
  // SCROLL DOWN BUTTON
  // ==========================================================================

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double destination =
        (
          _scrollController.offset +
              500
        ).clamp(
      0.0,
      _scrollController
          .position
          .maxScrollExtent,
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

  Future<void> _loadProductAndOptions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _showScrollHint = false;
      });
    }

    try {
      // ======================================================================
      // 1. GET CATALOG
      // ======================================================================

      final Map<String, dynamic> catalog =
          await IimmpactCatalogService
              .getCatalog();

      // ======================================================================
      // 2. PRODUCTS
      // ======================================================================

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products missing.',
        );
      }

      // ======================================================================
      // 3. SELECTED PRODUCT
      // ======================================================================

      final dynamic rawProduct =
          productsRaw[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'Game credit product $_code not found.',
        );
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      // ======================================================================
      // 4. ACTIVE CHECK
      // ======================================================================

      if (product['is_active'] != true) {
        throw Exception(
          'Game credit product $_code unavailable.',
        );
      }

      // ======================================================================
      // 5. CUSTOMER PRICING
      // ======================================================================

      final CatalogPricing pricing =
          CatalogPricing.fromCatalogResponse(
        catalogJson: catalog,
        productCode: _code,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _catalogPricing = pricing;
      });

      // ======================================================================
      // 6. DETECT PRICING FIELD
      // ======================================================================

      final String fieldId =
          _fieldId;

      if (fieldId.isEmpty) {
        throw Exception(
          'Game credit pricing field not found.',
        );
      }

      // ======================================================================
      // 7. GET OPTIONS
      // ======================================================================

      final GamingOptionsResult result =
          await IimmpactGamingOptionsService
              .getOptions(
        productCode: _code,
        fieldId: fieldId,
      );

      if (!mounted) {
        return;
      }

      // ======================================================================
      // 8. ACTIVE OPTIONS ONLY
      // ======================================================================

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

      // ======================================================================
      // 9. SORT LOWEST PRICE -> HIGHEST PRICE
      // ======================================================================

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

      // ======================================================================
      // 10. UPDATE
      // ======================================================================

      setState(() {
        _options = activeOptions;

        _selectedOption =
            _options.isEmpty
                ? null
                : _options.first;

        _isLoading = false;
        _errorMessage = null;
      });

      // ======================================================================
      // CHECK SCROLL AFTER CONTENT BUILDS
      // ======================================================================

      _checkScrollAvailability();

      // ======================================================================
      // DEBUG
      // ======================================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'GAME CREDITS PAGE 4 LOADED',
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
        'Options      : ${_options.length}',
      );
      debugPrint(
        'Processing   : $_processingTime',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');
    }

    // =========================================================================
    // CATALOG ERROR
    // =========================================================================

    on IimmpactCatalogException catch (error) {
      _setLoadError(
        error.message,
      );
    }

    // =========================================================================
    // OPTIONS ERROR
    // =========================================================================

    on GamingOptionsException catch (error) {
      _setLoadError(
        error.message,
      );
    }

    // =========================================================================
    // UNKNOWN ERROR
    // =========================================================================

    catch (error, stackTrace) {
      debugPrint(
        'Game Credits Page 4 load error: '
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
  // SET ERROR
  // ==========================================================================

  void _setLoadError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = message;
      _isLoading = false;
      _showScrollHint = false;
    });
  }

  // ==========================================================================
  // MONEY
  //
  // /options price.amount is the actual RM selling price.
  // denomination_currency may be FC Points / Diamonds / etc.
  // ==========================================================================

  String _formatMoney(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _formatSignedMoney(
    double amount,
  ) {
    final String sign =
        amount >= 0 ? '+' : '-';

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
      case 'link':
        return loc.gameCreditsDeliveryLink;

      case 'pin':
        return loc.gameCreditsDeliveryPin;

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
  // OPTION NAME
  // ==========================================================================

  String _optionName(
    GamingOption option,
  ) {
    final String displayName =
        option.displayName.trim();

    if (displayName.isNotEmpty) {
      return displayName;
    }

    final String code =
        option.code.trim();

    return code.isNotEmpty
        ? code
        : '-';
  }

  Future<void> _handleContinue() async {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    // ==========================================================================
    // PRODUCT MUST STILL BE ACTIVE
    // ==========================================================================

    if (!_isProductActive) {
      _showMessage(
        loc.gameCreditsProductUnavailable,
      );

      return;
    }

    // ==========================================================================
    // USER MUST SELECT AN OPTION
    // ==========================================================================

    final GamingOption? selected =
        _selectedOption;

    if (selected == null) {
      _showMessage(
        loc.gameCreditsSelectAmountRequired,
      );

      return;
    }

    // ==========================================================================
    // DEBUG
    // ==========================================================================

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'GAME CREDIT SELECTION',
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
      'Image URL          : $_imageUrl',
    );
    debugPrint(
      'Field ID           : $_fieldId',
    );
    debugPrint(
      'Option Code        : ${selected.code}',
    );
    debugPrint(
      'Option Name        : ${selected.displayName}',
    );
    debugPrint(
      'Option Description : ${selected.description}',
    );
    debugPrint(
      'Base Amount        : $_baseAmount',
    );
    debugPrint(
      'Adjustment         : $_adjustmentAmount',
    );
    debugPrint(
      'Total              : $_totalAmount',
    );
    debugPrint(
      'Processing         : $_processingTime',
    );

    debugPrint(
  'OPTION CODE        : ${selected.code}',
);

    debugPrint(
      'OPTION NAME        : ${selected.displayName}',
    );

    debugPrint(
      'OPTION DESCRIPTION : ${selected.description}',
    );

    debugPrint(
      'RM PRICE           : ${selected.priceAmount}',
    );

    debugPrint(
      'IIMMPACT AMOUNT    : '
      '${double.tryParse(selected.code.trim())}',
    );
    
    debugPrint(
      '========================================',
    );
    debugPrint('');

    // ==========================================================================
    // GO TO PAGE 5
    // ==========================================================================

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PGAMECREDITS5PAGE(
          productCode:
              _code,

          productName:
              _productName,

          imageUrl:
              _imageUrl,

          fieldId:
              _fieldId,

          optionCode:
              selected.code,

          optionName:
              selected.displayName,

          optionDescription:
              selected.description,

          // ================================================================
          // DENOMINATION FOR IIMMPACT
          //
          // MLBB:
          // code = "14"
          // RM price = 1.09
          // ================================================================

          iimmpactAmount:
              double.tryParse(
                selected.code.trim(),
              ) ??
              _baseAmount,

          // Customer price
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
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================

          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
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

          // ==================================================================
          // PAGE
          // ==================================================================

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
                // BODY
                // ============================================================

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 5,
                            color:
                                _primaryColor,
                          ),
                        )
                      : _errorMessage != null
                          ? _buildError(
                              loc,
                            )
                          : _buildScrollableArea(
                              loc,
                            ),
                ),

                // ============================================================
                // BOTTOM BUTTONS
                // ============================================================

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
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF087A70),
            Color(0xFF009688),
            Color(0xFF35B7A8),
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
          // ==================================================================
          // LOGO
          // ==================================================================

          Container(
            width: 105,
            height: 105,
            padding:
                const EdgeInsets.all(
              14,
            ),
            decoration: BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),
            child: _buildLogo(
              62,
            ),
          ),

          const SizedBox(
            width: 24,
          ),

          // ==================================================================
          // TITLE
          // ==================================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _productName.toUpperCase(),
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
                  loc.gameCreditsCategoryLabel,
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

          const Icon(
            Icons
                .videogame_asset_rounded,
            color:
                Colors.white,
            size: 62,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SCROLLABLE BODY + SCROLL HINT
  // ==========================================================================

  Widget _buildScrollableArea(
    AppLocalizations loc,
  ) {
    return Stack(
      children: [
        // ====================================================================
        // ACTUAL CONTENT
        // ====================================================================

        Positioned.fill(
          child: _buildContent(
            loc,
          ),
        ),

        // ====================================================================
        // SCROLL FOR MORE INFORMATION
        //
        // Only appears when:
        //
        // - content is actually scrollable
        // - user has not reached the bottom
        //
        // Tapping it also scrolls downward.
        // ====================================================================

        if (_showScrollHint)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child:
                  _buildScrollHint(
                loc,
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // SCROLL HINT
  // ==========================================================================

  Widget _buildScrollHint(
    AppLocalizations loc,
  ) {
    return Material(
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
          decoration: BoxDecoration(
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
            border: Border.all(
              color:
                  Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.20,
                ),
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
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .touch_app_rounded,
                color:
                    Colors.white,
                size: 26,
              ),

              const SizedBox(
                width: 10,
              ),

              Text(
                loc.scrollForMoreInformation,
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
        right: 18,
      ),
      child: Scrollbar(
        controller:
            _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        thickness: 11,
        radius:
            const Radius.circular(
          20,
        ),
        child: SingleChildScrollView(
          controller:
              _scrollController,
          physics:
              const BouncingScrollPhysics(),

          // Extra bottom space so scroll hint does not cover summary.
          padding:
              const EdgeInsets.fromLTRB(
            65,
            32,
            62,
            105,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // ==============================================================
              // PRODUCT CARD
              // ==============================================================

              _buildProductCard(
                loc,
              ),

              const SizedBox(
                height: 30,
              ),

              // ==============================================================
              // NOTE FROM CATALOG IS INTENTIONALLY NOT DISPLAYED
              // ==============================================================

              // ==============================================================
              // SELECT OPTION
              // ==============================================================

              _buildAmountSection(
                loc,
              ),

              const SizedBox(
                height: 30,
              ),

              // ==============================================================
              // SUMMARY
              // ==============================================================

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
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFD3DCE8,
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
      child: Row(
        children: [
          // ==================================================================
          // LOGO
          // ==================================================================

          Container(
            width: 135,
            height: 120,
            padding:
                const EdgeInsets.all(
              18,
            ),
            decoration: BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
              border: Border.all(
                color:
                    _lightColor,
                width: 2,
              ),
            ),
            child: _buildLogo(
              65,
            ),
          ),

          const SizedBox(
            width: 25,
          ),

          // ==================================================================
          // DETAILS
          // ==================================================================

          Expanded(
            child: Column(
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
                  loc.gameCreditsCategoryLabel,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF66758A,
                    ),
                    fontSize: 25,
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
                      Icons
                          .schedule_rounded,
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
  // SELECT AMOUNT
  // ==========================================================================

  Widget _buildAmountSection(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFD3DCE8,
          ),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==================================================================
          // TITLE
          // ==================================================================

          Text(
            loc.gameCreditsSelectAmountTitle,
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
            loc.gameCreditsSelectAmountSubtitle,
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

          // ==================================================================
          // NO OPTIONS
          // ==================================================================

          if (_options.isEmpty)
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                25,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFFFFF3E0,
                ),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color:
                      const Color(
                    0xFFFFCC80,
                  ),
                  width: 2,
                ),
              ),
              child: Text(
                loc.gameCreditsNoAmountsAvailable,
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

          // ==================================================================
          // OPTIONS
          // ==================================================================

          else
            LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                // ============================================================
                // THREE OPTIONS PER ROW
                // ============================================================

                final double itemWidth =
                    (
                          constraints
                                  .maxWidth -
                              24
                        ) /
                        3;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      _options.map(
                    (
                      GamingOption option,
                    ) {
                      return SizedBox(
                        width:
                            itemWidth,
                        child:
                            _buildAmountCard(
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

  Widget _buildAmountCard(
    GamingOption option,
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
          18,
        ),
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 160,
          ),
          constraints:
              const BoxConstraints(
            minHeight: 160,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: selected
                ? _selectedBackground
                : const Color(
                    0xFFFAFBFC,
                  ),
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: selected
                  ? _selectedBorder
                  : const Color(
                      0xFFD6DEE8,
                    ),
              width:
                  selected ? 3 : 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color:
                          _selectedBorder
                              .withOpacity(
                        0.12,
                      ),
                      blurRadius:
                          12,
                      offset:
                          const Offset(
                        0,
                        5,
                      ),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // ==============================================================
              // OPTION NAME
              // ==============================================================

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
                      style: TextStyle(
                        color: selected
                            ? _darkColor
                            : const Color(
                                0xFF17283E,
                              ),
                        fontSize: 23,
                        fontWeight:
                            FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),

                  if (selected)
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        left: 6,
                      ),
                      child: Icon(
                        Icons
                            .check_circle_rounded,
                        color:
                            _primaryColor,
                        size: 27,
                      ),
                    ),
                ],
              ),

              // ==============================================================
              // DESCRIPTION FROM /OPTIONS
              // ==============================================================

              if (option.description
                  .trim()
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 9,
                ),

                Text(
                  option.description.trim(),
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF68778A,
                    ),
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],

              const SizedBox(
                height: 12,
              ),

              // ==============================================================
              // PRICE
              // ==============================================================

              Text(
                _formatMoney(
                  option.priceAmount,
                ),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color:
                      _greenColor,
                  fontSize: 23,
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
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),
        borderRadius:
            BorderRadius.circular(
          26,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFD3DCE8,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.05,
            ),
            blurRadius: 15,
            offset:
                const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          // ==================================================================
          // TITLE
          // ==================================================================

          Text(
            loc.gameCreditsOrderSummaryTitle,
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

          // ==================================================================
          // PRODUCT
          // ==================================================================

          _summaryRow(
            loc.gameCreditsProductLabel,
            _productName,
          ),

          const Divider(
            height: 35,
          ),

          // ==================================================================
          // SELECTED OPTION
          // ==================================================================

          _summaryRow(
            loc.gameCreditsSelectedOptionLabel,
            option == null
                ? '-'
                : _optionName(
                    option,
                  ),
          ),

          // ==================================================================
          // DESCRIPTION
          // ==================================================================

          if (option != null &&
              option.description
                  .trim()
                  .isNotEmpty) ...[
            const Divider(
              height: 35,
            ),

            _summaryRow(
              loc.gameCreditsCreditLabel,
              option.description.trim(),
            ),
          ],

          const Divider(
            height: 35,
          ),

          // ==================================================================
          // SUBTOTAL
          // ==================================================================

          _summaryRow(
            loc.gameCreditsSubtotalLabel,
            _formatMoney(
              _baseAmount,
            ),
          ),

          // ==================================================================
          // SERVICE ADJUSTMENT
          // ==================================================================

          if (_hasAdjustment) ...[
            const Divider(
              height: 35,
            ),

            _summaryRow(
              loc.gameCreditsServiceAdjustmentLabel,
              _formatSignedMoney(
                _adjustmentAmount,
              ),
            ),
          ],

          const Divider(
            height: 35,
          ),

          // ==================================================================
          // TOTAL
          // ==================================================================

          _summaryRow(
            loc.gameCreditsTotalAmountLabel,
            _formatMoney(
              _totalAmount,
            ),
            strong: true,
            highlight: true,
          ),

          const Divider(
            height: 35,
          ),

          // ==================================================================
          // PROCESSING TIME
          // ==================================================================

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

  // ==========================================================================
  // SUMMARY ROW
  // ==========================================================================

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
            style: TextStyle(
              color:
                  const Color(
                0xFF17283E,
              ),
              fontSize:
                  strong ? 29 : 25,
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
            style: TextStyle(
              color: highlight
                  ? _primaryColor
                  : const Color(
                      0xFF17283E,
                    ),
              fontSize:
                  strong ? 31 : 25,
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
        decoration: BoxDecoration(
          color:
              Colors.white,
          borderRadius:
              BorderRadius.circular(
            30,
          ),
          border: Border.all(
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
              loc.gameCreditsUnableToLoadOptions,
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
              loc.gameCreditsUnableToLoadOptionsSubtitle,
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
  // BOTTOM AREA
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
              // ==============================================================
              // BACK
              // ==============================================================

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
                      Icons
                          .arrow_back_rounded,
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

              // ==============================================================
              // CONTINUE
              // ==============================================================

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
                      Icons
                          .arrow_forward_rounded,
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
            height: 40,
          ),

          // ==================================================================
          // COPYRIGHT
          // ==================================================================

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
  // LOGO
  // ==========================================================================

  Widget _buildLogo(
    double fallbackSize,
  ) {
    if (_imageUrl.isEmpty) {
      return Icon(
        Icons
            .videogame_asset_rounded,
        size: fallbackSize,
        color:
            _primaryColor,
      );
    }

    return Image.network(
      _imageUrl,
      fit:
          BoxFit.contain,
      loadingBuilder: (
        context,
        child,
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
        context,
        error,
        stackTrace,
      ) {
        return Icon(
          Icons
              .videogame_asset_rounded,
          size: fallbackSize,
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
      context: context,
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
            decoration: BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
              border: Border.all(
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
                  Icons
                      .info_outline_rounded,
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
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
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