import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_gaming_options_service.dart';
import 'package:frontend_v1/pages/payment/bill/idd_qr_payment_page.dart';

// ============================================================================
// IDD PAGE 4
//
// FLOW:
//
// PIDDBILL3PAGE
//      ↓
// productCode
//      ↓
// /v2/catalog
//      ↓
// products[productCode]
//      ↓
// fields[]
//      ↓
// detect pricing/select field
//      ↓
// /v2/options
//      ↓
// ACTIVE options only
//      ↓
// user selects amount
//      ↓
// quantity
//      ↓
// order summary
//
// IMPORTANT:
//
// NOTHING BELOW HARDCODES:
//
// - Redtone denominations
// - Ultratone denominations
// - Available option list
// - Product name
// - Product logo
// - Processing time
// - Active status
// - Price adjustment
//
// All of those come from IIMMPACT.
//
// Current catalog:
//
// RI -> Redtone IDD
// UT -> Ultratone IDD
//
// But this Page 4 does NOT contain RI/UT-specific amount logic.
// ============================================================================

class PIDDBILL4PAGE extends StatefulWidget {
  final String productCode;
  final String billerName;

  const PIDDBILL4PAGE({
    super.key,
    required this.productCode,
    required this.billerName,
  });

  @override
  State<PIDDBILL4PAGE> createState() =>
      _PIDDBILL4PAGEState();
}

class _PIDDBILL4PAGEState extends State<PIDDBILL4PAGE> {
  // ==========================================================================
  // CONTROLLER
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

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
      Color(0xFF1469E8);

  static const Color _darkBlue =
      Color(0xFF064CAC);

  static const Color _lightBlue =
      Color(0xFFE5F0FF);

  static const Color _selectedBackground =
      Color(0xFFE6F5FA);

  static const Color _selectedBorder =
      Color(0xFF0099BE);

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
  //
  // Comes from catalog.
  // billerName is only fallback.
  // ==========================================================================

  String get _productName {
    final String value =
        _product?['name']
                ?.toString()
                .trim() ??
            '';

    return value.isNotEmpty
        ? value
        : widget.billerName;
  }

  // ==========================================================================
  // IMAGE
  // ==========================================================================

  String get _imageUrl =>
      _product?['image_url']
              ?.toString()
              .trim() ??
          '';

  // ==========================================================================
  // PROCESSING TIME
  // ==========================================================================

  String get _processingTime =>
      _product?['processing_time']
              ?.toString()
              .trim() ??
          '';

  // ==========================================================================
  // ACTIVE STATUS
  // ==========================================================================

  bool get _isProductActive =>
      _product?['is_active'] == true;

  // ==========================================================================
  // CURRENCY
  // ==========================================================================

  String get _currency {
    final String value =
        _product?['denomination_currency']
                ?.toString()
                .trim()
                .toUpperCase() ??
            '';

    return value.isEmpty
        ? 'MYR'
        : value;
  }

  String get _currencyDisplay {
    if (_currency == 'MYR') {
      return 'RM';
    }

    return _currency;
  }

  // ==========================================================================
  // PRICING FIELD
  //
  // Do NOT hardcode:
  //
  // fieldId = "amount"
  //
  // Instead we inspect the product fields returned by /v2/catalog.
  //
  // Preference:
  //
  // type == select
  // role == pricing
  //
  // Fallback:
  //
  // first select field
  // ==========================================================================

  Map<String, dynamic>? get _pricingField {
    final dynamic fieldsRaw =
        _product?['fields'];

    if (fieldsRaw is! List) {
      return null;
    }

    // ========================================================================
    // PREFERENCE:
    // SELECT + PRICING
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
    // FIRST SELECT FIELD
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
  // SELECTED BASE AMOUNT
  // ==========================================================================

  double get _baseAmount =>
      _selectedOption?.priceAmount ?? 0;

  // ==========================================================================
  // PRICE ADJUSTMENT
  //
  // pricing.discount:
  // internal/provider pricing
  //
  // pricing.price_adjustment:
  // customer-facing adjustment
  //
  // We only apply price_adjustment.
  // ==========================================================================

  PriceAdjustmentResult get _singleItemAdjustment {
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

  // ==========================================================================
  // SINGLE ITEM PAYABLE
  // ==========================================================================

  double get _singleItemPayable =>
      _singleItemAdjustment.amountAfter;

  // ==========================================================================
  // SINGLE ITEM ADJUSTMENT
  // ==========================================================================

  double get _singleItemAdjustmentAmount =>
      _singleItemAdjustment.adjustmentAmount;

  // ==========================================================================
  // SUBTOTAL
  // ==========================================================================

    double get _subtotal => _baseAmount;


  // ==========================================================================
  // TOTAL ADJUSTMENT
  // ==========================================================================

  double get _adjustmentTotal =>
      _singleItemAdjustmentAmount;

  // ==========================================================================
  // FINAL TOTAL
  // ==========================================================================

  double get _totalAmount =>
      _singleItemPayable ;

  // ==========================================================================
  // HAS ADJUSTMENT
  // ==========================================================================

  bool get _hasAdjustment =>
      _adjustmentTotal.abs() >= 0.005;

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _loadProductAndOptions();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD PRODUCT + OPTIONS
  // ==========================================================================

  Future<void> _loadProductAndOptions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // ======================================================================
      // 1. GET /v2/catalog
      // ======================================================================

      final Map<String, dynamic> catalog =
          await IimmpactCatalogService
              .getCatalog();

      // ======================================================================
      // 2. GET PRODUCTS
      // ======================================================================

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products missing.',
        );
      }

      // ======================================================================
      // 3. FIND SELECTED IDD PRODUCT
      // ======================================================================

      final dynamic rawProduct =
          productsRaw[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'IDD product $_code not found.',
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
          'IDD product $_code unavailable.',
        );
      }

      // ======================================================================
      // 5. PRICING
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
          'IDD pricing field not found.',
        );
      }

      // ======================================================================
      // 7. GET /v2/options
      //
      // Dynamic:
      //
      // productCode = selected product
      // fieldId     = detected catalog field
      //
      // NO denomination strings are manually parsed here.
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

      final List<GamingOption> activeOptions =
          result.options
              .where(
                (option) =>
                    option.isActive,
              )
              .toList();

      // ======================================================================
      // SORT LOWEST -> HIGHEST
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
      // UPDATE UI
      // ======================================================================

      setState(() {
        _options = activeOptions;

        _selectedOption =
            _options.isEmpty
                ? null
                : _options.first;

        _isLoading = false;
      });
      // ======================================================================
      // DEBUG
      // ======================================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'IDD PAGE 4 LOADED',
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
        'IDD Page 4 load error: $error',
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
    });
  }


  // ==========================================================================
  // FORMAT MONEY
  // ==========================================================================

  String _formatMoney(
    double amount, {
    bool decimals = true,
  }) {
    if (!decimals &&
        amount == amount.roundToDouble()) {
      return '$_currencyDisplay '
          '${amount.toInt()}';
    }

    return '$_currencyDisplay '
        '${amount.toStringAsFixed(2)}';
  }

  // ==========================================================================
  // SIGNED MONEY
  // ==========================================================================

  String _formatSignedMoney(
    double amount,
  ) {
    final String sign =
        amount >= 0 ? '+' : '-';

    return '$sign '
        '${_formatMoney(
          amount.abs(),
        )}';
  }

  // ==========================================================================
  // PROCESSING TIME LOCALIZATION
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
        return loc.iddDeliveryPin;

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

        return _processingTime
            .replaceAll(
              '_',
              ' ',
            )
            .toUpperCase();
    }
  }

  // ==========================================================================
  // OPTION DISPLAY NAME
  //
  // Prefer the display name returned by /options.
  //
  // If the API gives an empty display name,
  // show its API price instead.
  // ==========================================================================

  String _optionDisplayName(
    GamingOption option,
  ) {
    final String displayName =
        option.displayName.trim();

    if (displayName.isNotEmpty) {
      return displayName;
    }

    return _formatMoney(
      option.priceAmount,
      decimals: false,
    );
  }

  // ==========================================================================
  // CONTINUE
  //
  // PAGE 5 IS NOT CONNECTED YET.
  //
  // All values are ready for Page 5.
  // ==========================================================================

  Future<void> _handleContinue() async {
    final loc =
        AppLocalizations.of(context)!;

    if (!_isProductActive) {
      _showMessage(
        loc.iddProductUnavailable,
      );

      return;
    }

    final GamingOption? selected =
        _selectedOption;

    if (selected == null) {
      _showMessage(
        loc.iddSelectAmountRequired,
      );

      return;
    }

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'IDD SELECTION',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'Product Code   : $_code',
    );
    debugPrint(
      'Product Name   : $_productName',
    );
    debugPrint(
      'Image URL      : $_imageUrl',
    );
    debugPrint(
      'Field ID       : $_fieldId',
    );
    debugPrint(
      'Option Code    : ${selected.code}',
    );
    debugPrint(
      'Option Name    : ${selected.displayName}',
    );
    debugPrint(
      'Base Amount    : $_baseAmount',
    );
    debugPrint(
      'Subtotal       : $_subtotal',
    );
    debugPrint(
      'Adjustment     : $_adjustmentTotal',
    );
    debugPrint(
      'Total          : $_totalAmount',
    );
    debugPrint(
      'Processing     : $_processingTime',
    );
    debugPrint(
      '========================================',
    );
    debugPrint('');
    
      // ========================================================================
      // GO TO IDD QR PAYMENT
      // ========================================================================

      final IddQrPaymentResult? result =
          await Navigator.push<IddQrPaymentResult>(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(
            name: '/payment',
          ),
          builder: (_) =>
              IddQrPaymentPage(
            providerName:
                _productName,

            productCode:
                _code,

            optionCode:
                selected.code,

            optionName:
                _optionDisplayName(
              selected,
            ),

            baseAmount:
                _baseAmount,

            serviceAdjustment:
                _adjustmentTotal,

            totalAmount:
                _totalAmount,

            processingTime:
                _processingTime,
          ),
        ),
      );

      if (!mounted ||
          result == null) {
        return;
      }

      // ========================================================================
      // PAYMENT SUCCESS
      //
      // Later this result will go to the IDD receipt.
      // ========================================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'IDD PAYMENT SUCCESS',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Product       : ${result.productCode}',
      );
      debugPrint(
        'Provider      : ${result.providerName}',
      );
      debugPrint(
        'Option Code   : ${result.optionCode}',
      );
      debugPrint(
        'Option Name   : ${result.optionName}',
      );
      debugPrint(
        'Base Amount   : ${result.baseAmount}',
      );
      debugPrint(
        'Adjustment    : ${result.serviceAdjustment}',
      );
      debugPrint(
        'Total         : ${result.totalAmount}',
      );
      debugPrint(
        'Ref ID        : ${result.refId}',
      );
      debugPrint(
        'Order No      : ${result.orderNo}',
      );
      debugPrint(
        'Bank Trx No   : ${result.bankTransactionNo}',
      );
      debugPrint(
        'Status        : ${result.providerStatus}',
      );
      debugPrint(
        'Serial Number : ${result.serialNumber}',
      );
      debugPrint(
        'PIN           : ${result.pin}',
      );
      debugPrint(
        'Expiry        : ${result.expiry}',
      );
      debugPrint(
        'Voucher Link  : ${result.voucherLink}',
      );
      debugPrint(
        'Note          : ${result.note}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');
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
                          : _buildContent(
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
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF064CAC),
            Color(0xFF1469E8),
            Color(0xFF41A0F2),
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
            decoration:
                BoxDecoration(
              color: Colors.white,
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

          // ==================================================================
          // TITLE
          // ==================================================================

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
                    fontSize: 37,
                    fontWeight:
                        FontWeight
                            .w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  loc.iddCategoryLabel,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 24,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .phone_in_talk_rounded,
            color:
                Colors.white,
            size: 62,
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
        child:
            SingleChildScrollView(
          controller:
              _scrollController,
          physics:
              const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            65,
            32,
            62,
            35,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
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
              // SELECT AMOUNT
              // ==============================================================

              _buildAmountSection(
                loc,
              ),

              const SizedBox(
                height: 30,
              ),

              // ==============================================================
              // ORDER SUMMARY
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
          // PRODUCT LOGO
          // ==================================================================

          Container(
            width: 135,
            height: 120,
            padding:
                const EdgeInsets.all(
              18,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
              border:
                  Border.all(
                color:
                    _lightBlue,
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

          // ==================================================================
          // PRODUCT DETAILS
          // ==================================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  _productName,
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
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
                  loc.iddCategoryLabel,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF66758A,
                    ),
                    fontSize: 25,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),

                const SizedBox(
                  height: 13,
                ),

                // ============================================================
                // PROCESSING TIME
                // ============================================================

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
                              FontWeight
                                  .w700,
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
  // SELECT AMOUNT SECTION
  // ==========================================================================

  Widget _buildAmountSection(
    AppLocalizations loc,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
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
                .start,
        children: [
          // ==================================================================
          // TITLE
          // ==================================================================

          Text(
            loc.iddSelectAmountTitle,
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
            height: 7,
          ),

          Text(
            loc.iddSelectAmountSubtitle,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF66758A,
              ),
              fontSize: 23,
              fontWeight:
                  FontWeight
                      .w600,
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
                loc.iddNoAmountsAvailable,
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
                      FontWeight
                          .w800,
                ),
              ),
            )

          // ==================================================================
          // DYNAMIC OPTIONS
          // ==================================================================

          else
            LayoutBuilder(
              builder:
                  (
                context,
                constraints,
              ) {
                // ============================================================
                // THREE PER ROW
                // ============================================================

                final double itemWidth =
                    (
                          constraints.maxWidth -
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
  // AMOUNT CARD
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
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 160,
          ),
          constraints:
              const BoxConstraints(
            minHeight: 118,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 18,
          ),
          decoration:
              BoxDecoration(
            color: selected
                ? _selectedBackground
                : const Color(
                    0xFFFAFBFC,
                  ),
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border:
                Border.all(
              color: selected
                  ? _selectedBorder
                  : const Color(
                      0xFFD6DEE8,
                    ),
              width: selected
                  ? 3
                  : 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color:
                          _selectedBorder
                              .withOpacity(
                        0.10,
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
                CrossAxisAlignment
                    .start,
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              // ==============================================================
              // OPTION NAME FROM API
              // ==============================================================

              Text(
                _optionDisplayName(
                  option,
                ),
                maxLines: 2,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    TextStyle(
                  color: selected
                      ? const Color(
                          0xFF0095B8,
                        )
                      : const Color(
                          0xFF17283E,
                        ),
                  fontSize: 27,
                  fontWeight:
                      FontWeight
                          .w900,
                  height: 1.1,
                ),
              ),

              const SizedBox(
                height: 9,
              ),

              // ==============================================================
              // ACTUAL PRICE FROM API
              // ==============================================================

              Text(
                _formatMoney(
                  option.priceAmount,
                ),
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF68778A,
                  ),
                  fontSize: 21,
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ==========================================================================
  // ORDER SUMMARY
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
            CrossAxisAlignment
                .stretch,
        children: [
          // ==================================================================
          // TITLE
          // ==================================================================

          Text(
            loc.iddOrderSummaryTitle,
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
            height: 25,
          ),

          // ==================================================================
          // PRODUCT / AMOUNT
          // ==================================================================

          _summaryRow(
            _productName,
            _formatMoney(
              _baseAmount,
              decimals: false,
            ),
            strong: true,
          ),

          const Divider(
            height: 35,
          ),

          // ==================================================================
          // SUBTOTAL
          // ==================================================================

          _summaryRow(
            loc.iddSubtotalLabel,
            _formatMoney(
              _subtotal,
            ),
          ),

          // ==================================================================
          // PRICE ADJUSTMENT
          // ==================================================================

          if (_hasAdjustment) ...[
            const Divider(
              height: 35,
            ),

            _summaryRow(
              loc.iddServiceAdjustmentLabel,
              _formatSignedMoney(
                _adjustmentTotal,
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
            loc.iddTotalAmountLabel,
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
          // PROCESSING / DELIVERY TYPE
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
          CrossAxisAlignment
              .start,
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
              fontSize: strong
                  ? 29
                  : 25,
              fontWeight: strong
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
              color: highlight
                  ? const Color(
                      0xFF009BB7,
                    )
                  : const Color(
                      0xFF17283E,
                    ),
              fontSize: strong
                  ? 31
                  : 25,
              fontWeight: strong
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
          color: Colors.white,
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
              Icons
                  .cloud_off_rounded,
              color:
                  _redColor,
              size: 80,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              loc.iddUnableToLoadOptions,
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
                    FontWeight
                        .w900,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              loc.iddUnableToLoadOptionsSubtitle,
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
                    FontWeight
                        .w600,
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
                  Icons
                      .refresh_rounded,
                  size: 30,
                ),
                label: Text(
                  loc.retryButton,
                  style:
                      const TextStyle(
                    fontSize: 23,
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
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BOTTOM BUTTONS
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
                            FontWeight
                                .w900,
                      ),
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          _greenColor,
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
            .phone_in_talk_rounded,
        size: fallbackSize,
        color:
            _primaryColor,
      );
    }

    return Image.network(
      _imageUrl,
      fit: BoxFit.contain,
      loadingBuilder:
          (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
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
      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return Icon(
          Icons
              .phone_in_talk_rounded,
          size: fallbackSize,
          color:
              _primaryColor,
        );
      },
    );
  }

  // ==========================================================================
  // MESSAGE POPUP
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
      barrierDismissible: false,
      builder:
          (
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
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
              border:
                  Border.all(
                color:
                    _lightBlue,
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
                        FontWeight
                            .w700,
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
                    child: Text(
                      loc.electricOk,
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
              ],
            ),
          ),
        );
      },
    );
  }
}