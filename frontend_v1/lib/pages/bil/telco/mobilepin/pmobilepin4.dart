import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/bil/telco/mobilepin/pmobilepin5.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

// ============================================================================
// MOBILE PIN PAGE 4 - SELECT PIN VALUE
// ============================================================================
//
// FLOW:
//
// Mobile PIN provider selection
//        ↓
// PMOBILEPIN4PAGE
// Select ONE PIN denomination
//        ↓
// PMOBILEPIN5PAGE
// Enter recipient mobile number using kiosk numeric keypad
//        ↓
// BilQrPaymentPage
//        ↓
// PegePay success
//        ↓
// IIMMPACT POST /v2/topup
//        ↓
// PIN returned
//        ↓
// Receipt
//
// ============================================================================
//
// CURRENT BUSINESS RULE:
//
// ONE Mobile PIN per transaction.
//
// FUTURE:
//
// Multiple PIN quantity can be added later if required.
//
// ============================================================================
//
// PRICING:
//
// pricing.discount
// = IIMMPACT/provider internal discount.
// = NOT passed to customer.
//
// pricing.price_adjustment
// = customer-facing adjustment.
//
// Example:
//
// PIN value:
// RM 10.00
//
// price_adjustment:
// + RM 0.50
//
// Customer total:
// RM 10.50
//
// IIMMPACT receives:
// amount = 10.00
//
// PegePay receives:
// amount = 10.50
//
// ============================================================================

class PMOBILEPIN4PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;

  const PMOBILEPIN4PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
  });

  @override
  State<PMOBILEPIN4PAGE> createState() =>
      _PMOBILEPIN4PAGEState();
}

class _PMOBILEPIN4PAGEState
    extends State<PMOBILEPIN4PAGE> {
  // ==========================================================================
  // STATE
  // ==========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  Map<String, dynamic>? _product;

  List<double> _denominations = [];

  double? _selectedAmount;

  CatalogPricing _catalogPricing =
      CatalogPricing.empty();

  // ==========================================================================
  // PRODUCT VALUES
  // ==========================================================================

  String get _productName {
    final String value =
        _product?['name']
                ?.toString()
                .trim() ??
            '';

    if (value.isNotEmpty) {
      return value;
    }

    return widget.providerName;
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

    return widget.providerImageUrl;
  }

  String get _catalogNote {
    return _product?['note']
            ?.toString()
            .trim() ??
        '';
  }

  String get _currency {
    final String value =
        _product?['denomination_currency']
                ?.toString()
                .trim()
                .toUpperCase() ??
            '';

    if (value.isNotEmpty) {
      return value;
    }

    return 'MYR';
  }

  bool get _isProductActive {
    return _product?['is_active'] ==
        true;
  }

  String get _processingTime {
    return _product?['processing_time']
            ?.toString()
            .trim() ??
        '';
  }

  // ==========================================================================
  // PRICING
  // ==========================================================================

  /// Actual PIN face value.
  ///
  /// Example:
  /// RM5
  /// RM10
  /// RM30
  double get _pinAmount {
    return _selectedAmount ?? 0.0;
  }

  // --------------------------------------------------------------------------
  // IMPORTANT
  //
  // Mobile PIN customer pricing uses ONLY:
  //
  // price_adjustment
  //
  // providerDiscount remains internal and is NOT shown to the customer.
  // --------------------------------------------------------------------------

  PriceAdjustmentResult get _pinAdjustment {
    final adjustment =
        _catalogPricing.priceAdjustment;

    if (adjustment == null) {
      return PriceAdjustmentResult.none(
        _pinAmount,
      );
    }

    return adjustment.apply(
      _pinAmount,
    );
  }

  /// Customer-facing adjustment.
  double get _adjustmentAmount {
    return _pinAdjustment
        .adjustmentAmount;
  }

  /// Final amount customer pays.
  double get _totalAmount {
    return _pinAdjustment.amountAfter;
  }

  bool get _hasPriceAdjustment {
    return _adjustmentAmount.abs() >=
        0.005;
  }

  bool get _adjustmentIsFee {
    return _adjustmentAmount > 0;
  }

  bool get _adjustmentIsDiscount {
    return _adjustmentAmount < 0;
  }

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _loadProduct();
  }

  // ==========================================================================
  // LOAD IIMMPACT CATALOG
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
      // GET /v2/catalog
      // ======================================================================

      final Map<String, dynamic>
          catalog =
          await IimmpactCatalogService
              .getCatalog();

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products object is missing.',
        );
      }

      final Map<String, dynamic>
          products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final String normalizedCode =
          widget.productCode
              .trim()
              .toUpperCase();

      final dynamic rawProduct =
          products[normalizedCode];

      if (rawProduct is! Map) {
        throw Exception(
          'Product $normalizedCode '
          'was not found in catalog.',
        );
      }

      final Map<String, dynamic>
          product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      // ======================================================================
      // DENOMINATIONS
      // ======================================================================

      final List<double>
          denominations =
          _parseDenominations(
        product['denomination']
                ?.toString() ??
            '',
      );

      if (denominations.isEmpty) {
        throw Exception(
          'No Mobile PIN denominations '
          'are available.',
        );
      }

      // ======================================================================
      // PRICING
      // ======================================================================

      final CatalogPricing
          catalogPricing =
          CatalogPricing
              .fromCatalogResponse(
        catalogJson:
            catalog,
        productCode:
            normalizedCode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _product =
            product;

        _catalogPricing =
            catalogPricing;

        _denominations =
            denominations;

        // Keep first catalog value selected by default.
        _selectedAmount =
            denominations.first;

        _isLoading =
            false;
      });

      // ======================================================================
      // DEBUG
      // ======================================================================

      debugPrint('');
      debugPrint(
        '========================================',
      );

      debugPrint(
        'MOBILE PIN CATALOG PRODUCT LOADED',
      );

      debugPrint(
        '========================================',
      );

      debugPrint(
        'Product Code       : '
        '$normalizedCode',
      );

      debugPrint(
        'Name               : '
        '$_productName',
      );

      debugPrint(
        'Active             : '
        '$_isProductActive',
      );

      debugPrint(
        'Processing         : '
        '$_processingTime',
      );

      debugPrint(
        'Currency           : '
        '$_currency',
      );

      debugPrint(
        'Denominations      : '
        '$_denominations',
      );

      debugPrint(
        'Provider Discount  : '
        '${_catalogPricing.providerDiscount?.displayValue ?? '-'} '
        '(INTERNAL ONLY)',
      );

      debugPrint(
        'Price Adjustment   : '
        '${_catalogPricing.priceAdjustment?.displayValue ?? '-'}',
      );

      debugPrint(
        'Catalog Note       : '
        '$_catalogNote',
      );

      debugPrint(
        '========================================',
      );

      debugPrint('');
    } on IimmpactCatalogException catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Mobile PIN catalog error: '
        '${error.message}',
      );

      setState(() {
        _isLoading =
            false;

        _errorMessage =
            error.message;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected Mobile PIN '
        'catalog error: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading =
            false;

        _errorMessage =
            error.toString();
      });
    }
  }

  // ==========================================================================
  // DENOMINATION PARSER
  // ==========================================================================

  List<double> _parseDenominations(
    String rawValue,
  ) {
    final String normalized =
        rawValue.trim();

    if (normalized.isEmpty) {
      return [];
    }

    // ========================================================================
    // MULTIPLE VALUES
    //
    // Example:
    //
    // 5,10,30,50,100
    // ========================================================================

    if (normalized.contains(',')) {
      final List<double> values =
          normalized
              .split(',')
              .map(
                (value) =>
                    double.tryParse(
                  value.trim(),
                ),
              )
              .whereType<double>()
              .where(
                (value) =>
                    value > 0,
              )
              .toSet()
              .toList();

      values.sort();

      return values;
    }

    // ========================================================================
    // SINGLE VALUE
    // ========================================================================

    final double? single =
        double.tryParse(
      normalized,
    );

    if (single != null &&
        single > 0) {
      return [
        single,
      ];
    }

    return [];
  }

  // ==========================================================================
  // FORMATTERS
  // ==========================================================================

  String _formatMoney(
    double value,
  ) {
    return 'RM '
        '${value.toStringAsFixed(2)}';
  }

  String _formatButtonAmount(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return 'RM '
          '${value.toStringAsFixed(0)}';
    }

    return 'RM '
        '${value.toStringAsFixed(2)}';
  }

  String _formatSignedMoney(
    double value,
  ) {
    final String sign =
        value >= 0
            ? '+'
            : '-';

    return '$sign RM '
        '${value.abs().toStringAsFixed(2)}';
  }

  // ==========================================================================
  // SELECT AMOUNT
  // ==========================================================================

  void _selectAmount(
    double amount,
  ) {
    setState(() {
      _selectedAmount =
          amount;
    });
  }

  // ==========================================================================
  // LOCALIZED PROVIDER NOTE
  // ==========================================================================

  String _localizedProviderNote(
    AppLocalizations loc,
  ) {
    switch (
        widget.productCode
            .trim()
            .toUpperCase()) {
      case 'CP':
        return loc.mobilePinNoteCelcom;

      case 'DIP':
      case 'DP':
        return loc.mobilePinNoteDigi;

      case 'MCP':
        return loc.mobilePinNoteHelloSim;

      case 'MP':
        return loc.mobilePinNoteMaxis;

      case 'RP':
        return loc.mobilePinNoteRedOne;

      case 'S':
        return loc.mobilePinNoteSpeakOut;

      case 'TP':
        return loc.mobilePinNoteTuneTalk;

      case 'UNP':
        return loc.mobilePinNoteUnifi;

      case 'UP':
        return loc.mobilePinNoteUMobile;

      case 'XP':
        return loc.mobilePinNoteXox;

      case 'YESP':
        return loc.mobilePinNoteYes;

      default:
        return _catalogNote;
    }
  }

  // ==========================================================================
  // PROCEED TO MOBILE NUMBER PAGE
  // ==========================================================================

  void _handleProceed() {
    final loc =
        AppLocalizations.of(context)!;

    // ========================================================================
    // PRODUCT NOT ACTIVE
    // ========================================================================

    if (!_isProductActive) {
      _showMessage(
        loc.mobilePinUnavailableTitle,
        loc.mobilePinUnavailableMessage,
        Icons.cloud_off_rounded,
        const Color(
          0xFFD32F2F,
        ),
      );

      return;
    }

    // ========================================================================
    // NO PIN VALUE
    // ========================================================================

    if (_selectedAmount == null) {
      _showMessage(
        loc.mobilePinSelectAmountTitle,
        loc.mobilePinSelectAmountMessage,
        Icons.payments_rounded,
        const Color(
          0xFFE08A00,
        ),
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
      'MOBILE PIN VALUE SELECTED',
    );

    debugPrint(
      '========================================',
    );

    debugPrint(
      'Provider       : '
      '$_productName',
    );

    debugPrint(
      'Product Code   : '
      '${widget.productCode}',
    );

    debugPrint(
      'PIN Face Value : '
      '$_pinAmount',
    );

    debugPrint(
      'Adjustment     : '
      '$_adjustmentAmount',
    );

    debugPrint(
      'Customer Total : '
      '$_totalAmount',
    );

    debugPrint(
      '========================================',
    );

    debugPrint('');

    // ========================================================================
    // PAGE 5
    //
    // Enter recipient mobile number using numeric keypad.
    // ========================================================================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                PMOBILEPIN5PAGE(
          productCode:
              widget.productCode,

          providerName:
              _productName,

          providerImageUrl:
              _imageUrl,

          // Actual PIN denomination.
          pinAmount:
              _pinAmount,

          // Customer-facing total after price adjustment.
          totalAmount:
              _totalAmount,
        ),
      ),
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    showGeneralDialog<void>(
      context:
          context,

      barrierDismissible:
          false,

      barrierLabel:
          title,

      barrierColor:
          Colors.black.withOpacity(
        0.65,
      ),

      transitionDuration:
          const Duration(
        milliseconds:
            220,
      ),

      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return FadeTransition(
          opacity:
              animation,

          child:
              ScaleTransition(
            scale:
                Tween<double>(
              begin:
                  0.88,
              end:
                  1,
            ).animate(
              CurvedAnimation(
                parent:
                    animation,
                curve:
                    Curves.easeOutBack,
              ),
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
          child:
              Center(
            child:
                Material(
              color:
                  Colors.transparent,

              child:
                  Container(
                width:
                    780,

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
                        color.withOpacity(
                      0.30,
                    ),
                    width:
                        3,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(
                        0.28,
                      ),
                      blurRadius:
                          38,
                      offset:
                          const Offset(
                        0,
                        16,
                      ),
                    ),
                  ],
                ),

                child:
                    Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Container(
                      width:
                          120,
                      height:
                          120,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            color.withOpacity(
                          0.12,
                        ),
                      ),

                      child:
                          Icon(
                        icon,
                        color:
                            color,
                        size:
                            68,
                      ),
                    ),

                    const SizedBox(
                      height:
                          25,
                    ),

                    Text(
                      title,
                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17283E,
                        ),
                        fontSize:
                            46,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                          18,
                    ),

                    Text(
                      message,
                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF5F6F82,
                        ),
                        fontSize:
                            30,
                        fontWeight:
                            FontWeight.w600,
                        height:
                            1.4,
                      ),
                    ),

                    const SizedBox(
                      height:
                          30,
                    ),

                    SizedBox(
                      width:
                          double.infinity,

                      height:
                          82,

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
                              color,

                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              22,
                            ),
                          ),
                        ),

                        child:
                            Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .telcoOkButton,

                          style:
                              const TextStyle(
                            fontSize:
                                31,
                            fontWeight:
                                FontWeight.w900,
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
        AppLocalizations.of(context)!;

    return Scaffold(
      body:
          Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================

          Positioned.fill(
            child:
                Image.asset(
              'lib/images/pnew.png',
              fit:
                  BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child:
                Container(
              color:
                  Colors.white.withOpacity(
                0.06,
              ),
            ),
          ),

          // ==================================================================
          // PAGE STATE
          // ==================================================================

          if (_isLoading)
            _buildLoading(
              loc,
            )
          else if (_errorMessage !=
              null)
            _buildError(
              loc,
            )
          else
            _buildContent(
              loc,
            ),

          // ==================================================================
          // COPYRIGHT
          // ==================================================================

          Positioned(
            bottom:
                22,
            left:
                0,
            right:
                0,

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
                    21,
                fontWeight:
                    FontWeight.w800,
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
      child:
          Container(
        width:
            620,

        padding:
            const EdgeInsets.all(
          45,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white.withOpacity(
            0.97,
          ),

          borderRadius:
              BorderRadius.circular(
            36,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.16,
              ),
              blurRadius:
                  30,
              offset:
                  const Offset(
                0,
                14,
              ),
            ),
          ],
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const SizedBox(
              width:
                  95,
              height:
                  95,

              child:
                  CircularProgressIndicator(
                strokeWidth:
                    7,
                color:
                    Color(
                  0xFF1769D2,
                ),
              ),
            ),

            const SizedBox(
              height:
                  28,
            ),

            Text(
              loc.mobilePinLoadingTitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize:
                    41,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height:
                  12,
            ),

            Text(
              loc.mobilePinLoadingMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF657386,
                ),
                fontSize:
                    28,
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
  // ERROR
  // ==========================================================================

  Widget _buildError(
    AppLocalizations loc,
  ) {
    return Center(
      child:
          Container(
        width:
            700,

        padding:
            const EdgeInsets.all(
          45,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white.withOpacity(
            0.97,
          ),

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
            width:
                2,
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
                  Color(
                0xFFD32F2F,
              ),
              size:
                  90,
            ),

            const SizedBox(
              height:
                  25,
            ),

            Text(
              loc.mobilePinCatalogErrorTitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize:
                    44,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height:
                  15,
            ),

            Text(
              loc.mobilePinCatalogErrorMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF657386,
                ),
                fontSize:
                    29,
                fontWeight:
                    FontWeight.w600,
                height:
                    1.4,
              ),
            ),

            const SizedBox(
              height:
                  30,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      SizedBox(
                    height:
                        82,

                    child:
                        OutlinedButton.icon(
                      onPressed:
                          () {
                        Navigator.pop(
                          context,
                        );
                      },

                      icon:
                          const Icon(
                        Icons.arrow_back_rounded,
                      ),

                      label:
                          Text(
                        loc.buttonBack,

                        style:
                            const TextStyle(
                          fontSize:
                              29,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width:
                      20,
                ),

                Expanded(
                  child:
                      SizedBox(
                    height:
                        82,

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
                        loc.mobilePinRetry,

                        style:
                            const TextStyle(
                          fontSize:
                              29,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF1769D2,
                        ),

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
  // MAIN CONTENT
  // ==========================================================================

  Widget _buildContent(
    AppLocalizations loc,
  ) {
    return Positioned(
      top:
          55,
      left:
          60,
      right:
          60,
      bottom:
          70,

      child:
          SingleChildScrollView(
        physics:
            const ClampingScrollPhysics(),

        child:
            Column(
          children: [
            // ================================================================
            // HEADER
            // ================================================================

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    30,
                vertical:
                    25,
              ),

              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(
                      0xFF0D47A1,
                    ),
                    Color(
                      0xFF1769D2,
                    ),
                    Color(
                      0xFF42A5F5,
                    ),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  32,
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(
                      0xFF1769D2,
                    ).withOpacity(
                      0.20,
                    ),
                    blurRadius:
                        22,
                    offset:
                        const Offset(
                      0,
                      10,
                    ),
                  ),
                ],
              ),

              child:
                  Row(
                children: [
                  Container(
                    width:
                        80,
                    height:
                        80,

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white.withOpacity(
                        0.18,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons.sim_card_download_rounded,
                      color:
                          Colors.white,
                      size:
                          48,
                    ),
                  ),

                  const SizedBox(
                    width:
                        22,
                  ),

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          loc.mobilePinPurchaseTitle
                              .toUpperCase(),

                          maxLines:
                              2,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                            fontSize:
                                22,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing:
                                1.2,
                          ),
                        ),

                        const SizedBox(
                          height:
                              5,
                        ),

                        Text(
                          _productName
                              .toUpperCase(),

                          maxLines:
                              2,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                44,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height:
                  25,
            ),

            // ================================================================
            // PROVIDER
            // ================================================================

            _buildProviderCard(
              loc,
            ),

            // ================================================================
            // NOTE
            // ================================================================

            if (_localizedProviderNote(
              loc,
            ).trim().isNotEmpty) ...[
              const SizedBox(
                height:
                    22,
              ),

              _buildImportantNote(
                loc,
              ),
            ],

            const SizedBox(
              height:
                  25,
            ),

            // ================================================================
            // DENOMINATION
            // ================================================================

            _buildDenominationCard(
              loc,
            ),

            const SizedBox(
              height:
                  25,
            ),

            // ================================================================
            // ORDER SUMMARY
            // ================================================================

            _buildOrderSummary(
              loc,
            ),

            const SizedBox(
              height:
                  50,
            ),

            // ================================================================
            // ACTIONS
            // ================================================================

            _buildActions(
              loc,
            ),

            const SizedBox(
              height:
                  70,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // PROVIDER CARD
  // ==========================================================================

  Widget _buildProviderCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

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
          30,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFC8DBF3,
          ),
          width:
              2,
        ),
      ),

      child:
          Row(
        children: [
          Container(
            width:
                155,
            height:
                120,

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
                24,
              ),

              border:
                  Border.all(
                color:
                    Colors.black12,
              ),
            ),

            child:
                Image.network(
              _imageUrl,

              fit:
                  BoxFit.contain,

              loadingBuilder: (
                context,
                child,
                progress,
              ) {
                if (progress ==
                    null) {
                  return child;
                }

                return const Center(
                  child:
                      CircularProgressIndicator(
                    strokeWidth:
                        3,
                    color:
                        Color(
                      0xFF1769D2,
                    ),
                  ),
                );
              },

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.sim_card_rounded,
                  color:
                      Color(
                    0xFF1769D2,
                  ),
                  size:
                      65,
                );
              },
            ),
          ),

          const SizedBox(
            width:
                25,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  loc.mobilePinSelectedProvider
                      .toUpperCase(),

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF718096,
                    ),
                    fontSize:
                        21,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height:
                      7,
                ),

                Text(
                  _productName,

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize:
                        39,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height:
                      10,
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        15,
                    vertical:
                        8,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        _isProductActive
                            ? const Color(
                                0xFFE4F7EE,
                              )
                            : const Color(
                                0xFFFFE6E6,
                              ),

                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                  ),

                  child:
                      Text(
                    _isProductActive
                        ? loc.mobilePinAvailable
                        : loc.mobilePinUnavailable,

                    style:
                        TextStyle(
                      color:
                          _isProductActive
                              ? const Color(
                                  0xFF08783E,
                                )
                              : const Color(
                                  0xFFC62828,
                                ),
                      fontSize:
                          20,
                      fontWeight:
                          FontWeight.w900,
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
  // IMPORTANT NOTE
  // ==========================================================================

  Widget _buildImportantNote(
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
          0xFFFFF8E8,
        ),

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFFFC766,
          ),
          width:
              1.8,
        ),
      ),

      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.info_outline_rounded,
            color:
                Color(
              0xFFE07900,
            ),
            size:
                36,
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
                  loc.mobilePinImportantNote,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFFC56700,
                    ),
                    fontSize:
                        24,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height:
                      8,
                ),

                Text(
                  _localizedProviderNote(
                    loc,
                  ),

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF684E24,
                    ),
                    fontSize:
                        26,
                    fontWeight:
                        FontWeight.w600,
                    height:
                        1.4,
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
  // DENOMINATION CARD
  // ==========================================================================

  Widget _buildDenominationCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

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
          30,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD1DEED,
          ),
          width:
              2,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_rounded,
                color:
                    Color(
                  0xFF1769D2,
                ),
                size:
                    34,
              ),

              const SizedBox(
                width:
                    13,
              ),

              Expanded(
                child:
                    Text(
                  loc.mobilePinSelectAmount,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize:
                        34,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                22,
          ),

          Wrap(
            spacing:
                16,

            runSpacing:
                16,

            children:
                _denominations
                    .map(
                      (
                        amount,
                      ) =>
                          _buildAmountButton(
                        amount,
                      ),
                    )
                    .toList(),
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
            0xFFC8DBF3,
          ),
          width:
              2,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color:
                    Color(
                  0xFF1769D2,
                ),
                size:
                    35,
              ),

              const SizedBox(
                width:
                    13,
              ),

              Expanded(
                child:
                    Text(
                  loc.mobilePinOrderSummary,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize:
                        34,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                25,
          ),

          // ==================================================================
          // PIN VALUE
          // ==================================================================

          _summaryRow(
            _productName,
            _formatMoney(
              _pinAmount,
            ),
          ),

          // ==================================================================
          // CUSTOMER PRICE ADJUSTMENT
          // ==================================================================

          if (_hasPriceAdjustment) ...[
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical:
                    18,
              ),

              child:
                  Divider(
                height:
                    1,
                thickness:
                    1.5,
                color:
                    Color(
                  0xFFD9E1EA,
                ),
              ),
            ),

            _summaryRow(
              loc.mobilePinServiceAdjustment,

              _formatSignedMoney(
                _adjustmentAmount,
              ),

              valueColor:
                  _adjustmentIsDiscount
                      ? const Color(
                          0xFF16813B,
                        )
                      : _adjustmentIsFee
                          ? const Color(
                              0xFFE65100,
                            )
                          : null,
            ),
          ],

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical:
                  22,
            ),

            child:
                Divider(
              thickness:
                  2,
            ),
          ),

          // ==================================================================
          // TOTAL
          // ==================================================================

          Row(
            children: [
              Expanded(
                child:
                    Text(
                  loc.mobilePinTotalAmount,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize:
                        35,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(
                width:
                    20,
              ),

              Text(
                _formatMoney(
                  _totalAmount,
                ),

                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF1769D2,
                  ),
                  fontSize:
                      46,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                16,
          ),

          // ==================================================================
          // NEXT STEP HINT
          // ==================================================================

          Container(
            width:
                double.infinity,

            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  20,
              vertical:
                  17,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF2F7FD,
              ),

              borderRadius:
                  BorderRadius.circular(
                18,
              ),

              border:
                  Border.all(
                color:
                    const Color(
                  0xFFD1E1F1,
                ),
              ),
            ),

            child:
                Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color:
                      Color(
                    0xFF1769D2,
                  ),
                  size:
                      28,
                ),

                const SizedBox(
                  width:
                      12,
                ),

                Expanded(
                  child:
                      Text(
                    loc.mobilePinNextStepMobileNumber,

                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF536A83,
                      ),
                      fontSize:
                          22,
                      fontWeight:
                          FontWeight.w700,
                      height:
                          1.3,
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
  // ACTION BUTTONS
  // ==========================================================================

  Widget _buildActions(
    AppLocalizations loc,
  ) {
    return Row(
      children: [
        // ====================================================================
        // BACK
        // ====================================================================

        Expanded(
          child:
              SizedBox(
            height:
                94,

            child:
                OutlinedButton.icon(
              onPressed:
                  () {
                Navigator.pop(
                  context,
                );
              },

              icon:
                  const Icon(
                Icons.arrow_back_rounded,
                size:
                    36,
              ),

              label:
                  Text(
                loc.buttonBack,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize:
                      34,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(
                  0xFF17283E,
                ),

                backgroundColor:
                    Colors.white,

                side:
                    const BorderSide(
                  color:
                      Color(
                    0xFF17283E,
                  ),
                  width:
                      2,
                ),

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
        ),

        const SizedBox(
          width:
              22,
        ),

        // ====================================================================
        // CONTINUE TO MOBILE NUMBER
        // ====================================================================

        Expanded(
          flex:
              2,

          child:
              SizedBox(
            height:
                94,

            child:
                ElevatedButton.icon(
              onPressed:
                  _handleProceed,

              icon:
                  const Icon(
                Icons.arrow_forward_rounded,
                size:
                    36,
              ),

              label:
                  Text(
                loc.mobilePinContinue
                    .toUpperCase(),

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize:
                      34,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF1769D2,
                ),

                foregroundColor:
                    Colors.white,

                elevation:
                    3,

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
        ),
      ],
    );
  }

  // ==========================================================================
  // AMOUNT BUTTON
  // ==========================================================================

  Widget _buildAmountButton(
    double amount,
  ) {
    final bool selected =
        _selectedAmount ==
            amount;

    return SizedBox(
      width:
          230,
      height:
          105,

      child:
          ElevatedButton(
        onPressed:
            () {
          _selectAmount(
            amount,
          );
        },

        style:
            ElevatedButton.styleFrom(
          elevation:
              selected
                  ? 3
                  : 0,

          backgroundColor:
              selected
                  ? const Color(
                      0xFFE2F3FF,
                    )
                  : Colors.white,

          foregroundColor:
              const Color(
            0xFF17283E,
          ),

          side:
              BorderSide(
            color:
                selected
                    ? const Color(
                        0xFF1769D2,
                      )
                    : const Color(
                        0xFFD4DEE9,
                      ),

            width:
                selected
                    ? 3
                    : 2,
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
            Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Text(
              _formatButtonAmount(
                amount,
              ),

              style:
                  TextStyle(
                color:
                    selected
                        ? const Color(
                            0xFF0D5CBD,
                          )
                        : const Color(
                            0xFF17283E,
                          ),

                fontSize:
                    34,

                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height:
                  5,
            ),

            Text(
              _formatMoney(
                amount,
              ),

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF718096,
                ),
                fontSize:
                    21,
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
  // SUMMARY ROW
  // ==========================================================================

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Expanded(
          child:
              Text(
            label,

            style:
                const TextStyle(
              color:
                  Color(
                0xFF52667E,
              ),
              fontSize:
                  27,
              fontWeight:
                  FontWeight.w700,
              height:
                  1.3,
            ),
          ),
        ),

        const SizedBox(
          width:
              20,
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
                      const Color(
                        0xFF17283E,
                      ),

              fontSize:
                  28,

              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}