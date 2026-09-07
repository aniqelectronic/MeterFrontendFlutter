import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_gaming_options_service.dart';
import 'package:frontend_v1/pages/bil/gaming/pgaming5.dart';

// ============================================================================
// GAMING PURCHASE PAGE
//
// FLOW:
// PGAMING3PAGE
//      -> select gaming platform
// PGAMING4PAGE
//      -> load product from /v2/catalog
//      -> detect select field dynamically
//      -> load available options from /v2/options
//      -> user selects ONE amount/package
//      -> calculate customer-facing price_adjustment
//      -> continue to PGAMING5 confirmation
//
// IMPORTANT:
// - NO QUANTITY.
// - One selected gaming voucher/package per transaction.
// - pricing.discount is internal.
// - pricing.price_adjustment affects what customer pays.
// ============================================================================
class PGAMING4PAGE extends StatefulWidget {
  final String productCode;
  final String platformName;
  final String imageUrl;

  const PGAMING4PAGE({
    super.key,
    required this.productCode,
    required this.platformName,
    required this.imageUrl,
  });

  @override
  State<PGAMING4PAGE> createState() =>
      _PGAMING4PAGEState();
}

class _PGAMING4PAGEState
    extends State<PGAMING4PAGE> {
  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  // ==========================================================================
  // DATA
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
      Color(0xFF7048E8);

  static const Color _darkColor =
      Color(0xFF5630C7);

  static const Color _lightColor =
      Color(0xFFEDE7FF);

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
        : widget.platformName;
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

  bool get _isProductActive =>
      _product?['is_active'] == true;

  // ==========================================================================
  // SELECT FIELD
  //
  // Current catalog examples:
  //
  // GSMY     -> package
  // STEAMMY  -> package
  // CC       -> amount
  // MOL      -> amount
  // OF       -> amount
  // UNI      -> amount
  //
  // We still detect the field from catalog first.
  // ==========================================================================

  String get _fieldId {
    final dynamic fieldsRaw =
        _product?['fields'];

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

        final String type =
            field['type']
                    ?.toString()
                    .trim()
                    .toLowerCase() ??
                '';

        if (type != 'select') {
          continue;
        }

        final String id =
            field['id']
                    ?.toString()
                    .trim() ??
                '';

        if (id.isNotEmpty) {
          return id;
        }
      }
    }

    // Safe fallback for current catalog.
    if (_code == 'GSMY' ||
        _code == 'STEAMMY') {
      return 'package';
    }

    return 'amount';
  }

  // ==========================================================================
  // PRICING
  // ==========================================================================

  double get _selectedBaseAmount =>
      _selectedOption?.priceAmount ?? 0;

  PriceAdjustmentResult
      get _priceAdjustmentResult {
    final adjustment =
        _catalogPricing.priceAdjustment;

    if (adjustment == null) {
      return PriceAdjustmentResult.none(
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
      _priceAdjustmentResult.amountAfter;

  bool get _hasAdjustment =>
      _adjustmentAmount.abs() >= 0.005;

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
      // 1. LOAD /v2/catalog
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

      final dynamic rawProduct =
          productsRaw[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'Gaming product $_code '
          'was not found in catalog.',
        );
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      // ======================================================================
      // CUSTOMER-FACING PRICING
      //
      // Do not use provider discount.
      // CatalogPricing is used so price_adjustment can be applied.
      // ======================================================================

      final CatalogPricing pricing =
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
        _catalogPricing = pricing;
      });

      // ======================================================================
      // 2. LOAD /v2/options
      // ======================================================================

      final GamingOptionsResult result =
          await IimmpactGamingOptionsService
              .getOptions(
        productCode: _code,
        fieldId: _fieldId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _options = result.options
          .where((option) => option.isActive)
          .toList();

        _selectedOption =
            _options.isEmpty
                ? null
                : _options.first;

        _isLoading = false;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'GAMING PRODUCT LOADED',
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
    } on IimmpactCatalogException catch (error) {
      _setLoadError(
        error.message,
      );
    } on GamingOptionsException catch (error) {
      _setLoadError(
        error.message,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Gaming purchase load error: '
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
  // CONTINUE
  //
  // PGAMING4 only handles selection.
  // The selected data is passed to PGAMING5 for confirmation.
  // ==========================================================================
  Future<void> _handleContinue() async {
    final loc =
        AppLocalizations.of(context)!;

    if (!_isProductActive) {
      _showMessage(
        loc.gamingProductUnavailable,
      );
      return;
    }

    final GamingOption? selected =
        _selectedOption;

    if (selected == null) {
      _showMessage(
        loc.gamingSelectOptionRequired,
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PGAMING5PAGE(
          productCode: _code,
          platformName: _productName,
          imageUrl: _imageUrl,
          fieldId: _fieldId,
          optionCode: selected.code,
          optionName:
              selected.displayName,
          optionDescription:
              selected.description,
          baseAmount:
              _selectedBaseAmount,
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
  // REDEMPTION GUIDE
  // ==========================================================================

  List<String> _redemptionSteps(
    AppLocalizations loc,
  ) {
    switch (_code) {
      case 'CC':
        return [
          loc.gamingRedeemCcStep1,
          loc.gamingRedeemCcStep2,
          loc.gamingRedeemCcStep3,
          loc.gamingRedeemCcStep4,
        ];

      case 'GSMY':
        return [
          loc.gamingRedeemGarenaStep1,
          loc.gamingRedeemGarenaStep2,
          loc.gamingRedeemGarenaStep3,
          loc.gamingRedeemGarenaStep4,
        ];

      case 'MOL':
        return [
          loc.gamingRedeemRazerStep1,
          loc.gamingRedeemRazerStep2,
          loc.gamingRedeemRazerStep3,
          loc.gamingRedeemRazerStep4,
        ];

      case 'OF':
        return [
          loc.gamingRedeemOffgamersStep1,
          loc.gamingRedeemOffgamersStep2,
          loc.gamingRedeemOffgamersStep3,
          loc.gamingRedeemOffgamersStep4,
        ];

      case 'STEAMMY':
        return [
          loc.gamingRedeemSteamStep1,
          loc.gamingRedeemSteamStep2,
          loc.gamingRedeemSteamStep3,
          loc.gamingRedeemSteamStep4,
        ];

      case 'UNI':
        return [
          loc.gamingRedeemUnipinStep1,
          loc.gamingRedeemUnipinStep2,
          loc.gamingRedeemUnipinStep3,
          loc.gamingRedeemUnipinStep4,
        ];

      default:
        return [
          loc.gamingRedeemGenericStep1,
          loc.gamingRedeemGenericStep2,
          loc.gamingRedeemGenericStep3,
        ];
    }
  }

  // ==========================================================================
  // FORMATTERS
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
        amount >= 0 ? '+' : '-';

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
      case 'pin':
        return loc.gamingDeliveryPin;

      case 'link':
        return loc.gamingDeliveryLink;

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
                      : _errorMessage !=
                              null
                          ? _buildError(
                              loc,
                            )
                          : _buildContent(
                              loc,
                            ),
                ),

                // ============================================================
                // ACTION BUTTONS + FOOTER
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
              0xFF5630C7,
            ),
            Color(
              0xFF7048E8,
            ),
            Color(
              0xFF9A78F2,
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
      child: Row(
        children: [
          // ==================================================================
          // LOGO
          // ==================================================================
          Container(
            width: 95,
            height: 95,
            padding:
                const EdgeInsets.all(
              12,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),
            child: _imageUrl.isEmpty
                ? const Icon(
                    Icons
                        .sports_esports_rounded,
                    color:
                        _primaryColor,
                    size: 58,
                  )
                : Image.network(
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
                            .sports_esports_rounded,
                        color:
                            _primaryColor,
                        size: 58,
                      );
                    },
                  ),
          ),

          const SizedBox(
            width: 25,
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
                    fontSize: 34,
                    fontWeight:
                        FontWeight
                            .w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  loc.gamingPurchaseSubtitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 22,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .confirmation_number_rounded,
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
      child: Scrollbar(
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
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              // ==============================================================
              // PRODUCT
              // ==============================================================
              _buildProductCard(
                loc,
              ),

              const SizedBox(
                height: 28,
              ),

              // ==============================================================
              // HOW TO REDEEM BUTTON
              //
              // The full guide is shown in a popup to save page space.
              // ==============================================================
              _buildRedemptionButton(
                loc,
              ),

              const SizedBox(
                height: 28,
              ),

              // ==============================================================
              // SELECT OPTION
              // ==============================================================
              _buildOptionSection(
                loc,
              ),

              const SizedBox(
                height: 28,
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
            0xFFD9D2F6,
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
            child: _imageUrl.isEmpty
                ? const Icon(
                    Icons
                        .sports_esports_rounded,
                    color:
                        _primaryColor,
                    size: 65,
                  )
                : Image.network(
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
                            .sports_esports_rounded,
                        color:
                            _primaryColor,
                        size: 65,
                      );
                    },
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
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),
                    fontSize: 31,
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  loc.gamingPlatformCategory,
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
                  height: 14,
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
  // HOW TO REDEEM BUTTON
  //
  // We intentionally keep the full redemption instructions out of the main
  // page so the amount/package choices and order summary have more space.
  // ==========================================================================
  Widget _buildRedemptionButton(
    AppLocalizations loc,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showRedemptionGuide(
            loc,
          );
        },
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        child: Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFFFF9E8,
            ),
            borderRadius:
                BorderRadius.circular(
              24,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFF3C766,
              ),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFFA96500,
                ).withOpacity(
                  0.08,
                ),
                blurRadius: 14,
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
              Container(
                width: 72,
                height: 72,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFFE7A3,
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
                      .redeem_rounded,
                  color:
                      Color(
                    0xFFA96500,
                  ),
                  size: 48,
                ),
              ),

              const SizedBox(
                width: 22,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      loc.gamingHowToRedeem,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF744900,
                        ),
                        fontSize: 30,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      loc.gamingRedeemButtonHint,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF7A6744,
                        ),
                        fontSize: 25,
                        height: 1.3,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Container(
                width: 64,
                height: 64,
                decoration:
                    const BoxDecoration(
                  color:
                      _primaryColor,
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons
                      .arrow_forward_rounded,
                  color:
                      Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HOW TO REDEEM POPUP
  //
  // Large kiosk-friendly text.
  // Scrollable for longer translations.
  // Has an explicit close button at the bottom.
  // ==========================================================================
  Future<void> _showRedemptionGuide(
    AppLocalizations loc,
  ) async {
    final List<String> steps =
        _redemptionSteps(
      loc,
    );

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible:
          false,
      barrierLabel:
          loc.gamingClose,
      barrierColor:
          const Color(
        0xFF07182E,
      ).withOpacity(
        0.72,
      ),
      transitionDuration:
          const Duration(
        milliseconds: 250,
      ),
      pageBuilder:
          (
        BuildContext dialogContext,
        Animation<double> animation,
        Animation<double>
            secondaryAnimation,
      ) {
        return SafeArea(
          child: Center(
            child: Material(
              color:
                  Colors.transparent,
              child: Container(
                width: 760,
                constraints:
                    const BoxConstraints(
                  maxHeight: 1350,
                ),
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                    36,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFF3C766,
                    ),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(
                        0.32,
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
                    // ========================================================
                    // POPUP HEADER
                    // ========================================================
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.fromLTRB(
                        34,
                        30,
                        24,
                        27,
                      ),
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(
                          0xFFFFF7DF,
                        ),
                        borderRadius:
                            BorderRadius.only(
                          topLeft:
                              Radius.circular(
                            33,
                          ),
                          topRight:
                              Radius.circular(
                            33,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .center,
                        children: [
                          Container(
                            width:
                                78,
                            height:
                                78,
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFFFE7A3,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                22,
                              ),
                            ),
                            child:
                                const Icon(
                              Icons
                                  .redeem_rounded,
                              color:
                                  Color(
                                0xFFA96500,
                              ),
                              size:
                                  46,
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
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  loc
                                      .gamingHowToRedeem,
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(
                                      0xFF744900,
                                    ),
                                    fontSize:
                                        38,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                    height:
                                        1.1,
                                  ),
                                ),

                                const SizedBox(
                                  height:
                                      8,
                                ),

                                Text(
                                  _productName,
                                  maxLines:
                                      2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(
                                      0xFF7B6948,
                                    ),
                                    fontSize:
                                        25,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed:
                                () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                            tooltip:
                                loc.gamingClose,
                            icon:
                                const Icon(
                              Icons
                                  .close_rounded,
                              size:
                                  42,
                              color:
                                  Color(
                                0xFF744900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ========================================================
                    // SCROLLABLE CONTENT
                    // ========================================================
                    Flexible(
                      child:
                          SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(
                          36,
                          30,
                          36,
                          24,
                        ),
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .stretch,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(
                                22,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFF7F4FF,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      const Color(
                                    0xFFD9D2F6,
                                  ),
                                  width:
                                      2,
                                ),
                              ),
                              child:
                                  Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  const Icon(
                                    Icons
                                        .info_outline_rounded,
                                    color:
                                        _primaryColor,
                                    size:
                                        34,
                                  ),

                                  const SizedBox(
                                    width:
                                        15,
                                  ),

                                  Expanded(
                                    child:
                                        Text(
                                      loc
                                          .gamingRedeemAfterPurchase,
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF4B4E57,
                                        ),
                                        fontSize:
                                            25,
                                        height:
                                            1.4,
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
                              height:
                                  28,
                            ),

                            ...List.generate(
                              steps.length,
                              (
                                int index,
                              ) {
                                return Container(
                                  margin:
                                      const EdgeInsets.only(
                                    bottom:
                                        20,
                                  ),
                                  padding:
                                      const EdgeInsets.all(
                                    24,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFFAFBFC,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      22,
                                    ),
                                    border:
                                        Border.all(
                                      color:
                                          const Color(
                                        0xFFDDE4EC,
                                      ),
                                      width:
                                          2,
                                    ),
                                  ),
                                  child:
                                      Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Container(
                                        width:
                                            54,
                                        height:
                                            54,
                                        alignment:
                                            Alignment
                                                .center,
                                        decoration:
                                            const BoxDecoration(
                                          color:
                                              _primaryColor,
                                          shape:
                                              BoxShape
                                                  .circle,
                                        ),
                                        child:
                                            Text(
                                          '${index + 1}',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,
                                            fontSize:
                                                26,
                                            fontWeight:
                                                FontWeight.w900,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            20,
                                      ),

                                      Expanded(
                                        child:
                                            Text(
                                          steps[
                                              index],
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF26364A,
                                            ),
                                            fontSize:
                                                28,
                                            height:
                                                1.45,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.all(
                                22,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFFFF7E6,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      const Color(
                                    0xFFF2CE79,
                                  ),
                                  width:
                                      2,
                                ),
                              ),
                              child:
                                  Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  const Icon(
                                    Icons
                                        .shield_outlined,
                                    color:
                                        Color(
                                      0xFFA96500,
                                    ),
                                    size:
                                        34,
                                  ),

                                  const SizedBox(
                                    width:
                                        15,
                                  ),

                                  Expanded(
                                    child:
                                        Text(
                                      loc
                                          .gamingKeepCodeSafe,
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF744900,
                                        ),
                                        fontSize:
                                            25,
                                        height:
                                            1.4,
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ========================================================
                    // CLOSE BUTTON
                    // ========================================================
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.fromLTRB(
                        36,
                        20,
                        36,
                        32,
                      ),
                      child:
                          SizedBox(
                        height:
                            86,
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
                                .close_rounded,
                            size:
                                34,
                          ),
                          label:
                              Text(
                            loc.gamingClose,
                            style:
                                const TextStyle(
                              fontSize:
                                  28,
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
                                0,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder:
          (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final Animation<double>
            curvedAnimation =
            CurvedAnimation(
          parent:
              animation,
          curve:
              Curves.easeOutBack,
          reverseCurve:
              Curves.easeIn,
        );

        return FadeTransition(
          opacity:
              animation,
          child:
              ScaleTransition(
            scale:
                Tween<double>(
              begin:
                  0.90,
              end:
                  1.0,
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
          Text(
            loc.gamingSelectAmount,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF102A43,
              ),
              fontSize: 35,
              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            loc.gamingSelectAmountHint,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF60758D,
              ),
              fontSize: 30,
              fontWeight:
                  FontWeight
                      .w600,
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
                    BorderRadius
                        .circular(
                  18,
                ),
              ),
              child: Text(
                loc.gamingNoOptionsAvailable,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFFE65100,
                  ),
                  fontSize: 30,
                  fontWeight:
                      FontWeight
                          .w800,
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
            minHeight: 150,
          ),
          padding:
              const EdgeInsets.all(
            20,
          ),
          decoration:
              BoxDecoration(
            color: selected
                ? const Color(
                    0xFFF0EBFF,
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
              color: selected
                  ? _primaryColor
                  : const Color(
                      0xFFD6DEE8,
                    ),
              width:
                  selected
                      ? 3
                      : 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color:
                          _primaryColor
                              .withOpacity(
                        0.12,
                      ),
                      blurRadius:
                          15,
                      offset:
                          const Offset(
                        0,
                        6,
                      ),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Expanded(
                    child: Text(
                      option
                              .displayName
                              .isEmpty
                          ? option.code
                          : option
                              .displayName,
                      maxLines: 3,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color: selected
                            ? _darkColor
                            : const Color(
                                0xFF17283E,
                              ),
                        fontSize: 35,
                        fontWeight:
                            FontWeight
                                .w900,
                        height: 1.2,
                      ),
                    ),
                  ),

                  if (selected)
                    const Padding(
                      padding:
                          EdgeInsets
                              .only(
                        left: 8,
                      ),
                      child: Icon(
                        Icons
                            .check_circle_rounded,
                        color:
                            _primaryColor,
                        size: 30,
                      ),
                    ),
                ],
              ),

              if (option.description
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 8,
                ),

                Text(
                  option.description,
                  maxLines: 3,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF68778A,
                    ),
                    fontSize: 25,
                    fontWeight:
                        FontWeight
                            .w600,
                    height: 1.25,
                  ),
                ),
              ],

              const SizedBox(
                height: 16,
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
                  fontSize: 30,
                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),
            ],
          ),
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
              loc.gamingUnableToLoad,
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
              height: 25,
            ),

            SizedBox(
              width: 300,
              height: 75,
              child:
                  ElevatedButton
                      .icon(
                onPressed:
                    _loadProductAndOptions,
                icon:
                    const Icon(
                  Icons
                      .refresh_rounded,
                  size: 30,
                ),
                label: Text(
                  loc.gamingTryAgain,
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
  // BOTTOM ACTIONS
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
        28,
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
                  height: 100,
                  child:
                      ElevatedButton
                          .icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .arrow_back_rounded,
                      size: 33,
                    ),
                    label: Text(
                      loc.buttonBack,
                      style:
                          const TextStyle(
                        fontSize: 40,
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
                  height: 100,
                  child:
                      ElevatedButton
                          .icon(
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
                      size: 33,
                    ),
                    label: Text(
                      loc.gamingReviewSelection,
                      style:
                          const TextStyle(
                        fontSize: 40,
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
                  FontWeight
                      .w800,
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
  // INFORMATION DIALOG
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
                  0xFFD9D2F6,
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

