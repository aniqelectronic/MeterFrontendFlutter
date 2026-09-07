import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';
import 'package:frontend_v1/pages/bil/telco/mobilereload/pmobilereload4.dart';

// ============================================================================
// MOBILE RELOAD PAGE 3
// ============================================================================
//
// SOURCE:
// GET /v2/catalog
//
// MOBILE RELOAD =
//
// MOBILE_DATA
// +
// MOBILE_PREPAID
//
// Nothing is hardcoded except the two IIMMPACT category IDs.
//
// Product:
// - code
// - name
// - image
// - active status
// - processing time
//
// are taken directly from /v2/catalog.
//
// ============================================================================


enum MobileReloadStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

class PMOBILERELOAD3PAGE extends StatefulWidget {
  const PMOBILERELOAD3PAGE({
    super.key,
  });

  @override
  State<PMOBILERELOAD3PAGE> createState() =>
      _PMOBILERELOAD3PAGEState();
}

class _PMOBILERELOAD3PAGEState
    extends State<PMOBILERELOAD3PAGE> {
  // ==========================================================================
  // STATE
  // ==========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  final List<_MobileReloadProduct> _products = [];

  final ScrollController _scrollController =
      ScrollController();

  bool _showScrollUp = false;

  bool _showScrollDown = false;

  final Map<String, MobileReloadStatus> _networkStatuses = {};
  final Map<String, String?> _lastUpdated = {};

  Future<void> _loadInitialNetworkStatuses() async {
    await Future.wait(
      _products.map(
        (product) =>
            _refreshNetworkStatus(
          product.productCode,
        ),
      ),
    );
  }

  Future<MobileReloadStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _networkStatuses[productCode] =
            MobileReloadStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final MobileReloadStatus status =
          result.isHealthy
              ? MobileReloadStatus.healthy
              : MobileReloadStatus.interruption;

      if (mounted) {
        setState(() {
          _networkStatuses[productCode] = status;
          _lastUpdated[productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Mobile Reload network status error '
        'for $productCode: $error',
      );

      if (mounted) {
        setState(() {
          _networkStatuses[productCode] =
              MobileReloadStatus.unavailable;
        });
      }

      return MobileReloadStatus.unavailable;
    }
  }

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF7B4DCC);

  static const Color _darkColor =
      Color(0xFF56339B);

  static const Color _lightColor =
      Color(0xFFF1EAFF);


  // ============================================================================
  // TEMPORARILY HIDDEN PRODUCTS
  //
  // EST  = Eastel Prepaid
  // ESTP = Eastel Pin
  // VIBE = Vibe Mobile Prepaid
  //
  // Currently hidden because of IIMMPACT-side issues.
  // Remove the codes from this set when IIMMPACT fixes them.
  // ============================================================================
  static const Set<String> _temporarilyHiddenProducts = {
    'EST',
    'ESTP',
    'VIBE',
  };

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );

    _loadMobileReloadProducts();
  }

  // ==========================================================================
  // LOAD MOBILE RELOAD FROM /v2/catalog
  // ==========================================================================

  Future<void> _loadMobileReloadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      // ======================================================================
      // TREE
      // ======================================================================

      final dynamic treeRaw =
          catalog['tree'];

      if (treeRaw is! Map) {
        throw Exception(
          'Catalog tree is missing.',
        );
      }

      final Map<String, dynamic> tree =
          Map<String, dynamic>.from(
        treeRaw,
      );

      final dynamic groupsRaw =
          tree['groups'];

      if (groupsRaw is! List) {
        throw Exception(
          'Catalog groups are missing.',
        );
      }

      // ======================================================================
      // FIND MOBILE GROUP
      // ======================================================================

      Map<String, dynamic>? mobileGroup;

      for (final dynamic rawGroup in groupsRaw) {
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

        if (groupId == 'MOBILE') {
          mobileGroup = group;
          break;
        }
      }

      if (mobileGroup == null) {
        throw Exception(
          'MOBILE catalog group was not found.',
        );
      }

      // ======================================================================
      // CATEGORIES
      // ======================================================================

      final dynamic categoriesRaw =
          mobileGroup['categories'];

      if (categoriesRaw is! List) {
        throw Exception(
          'Mobile categories are missing.',
        );
      }

      // ----------------------------------------------------------------------
      // IMPORTANT
      //
      // These are the TWO catalog categories shown in our kiosk as:
      //
      // MOBILE RELOAD
      //
      // ----------------------------------------------------------------------

      const Set<String> allowedCategories = {
        'MOBILE_DATA',
        'MOBILE_PREPAID',
      };

      final List<String> productCodes = [];

      for (final dynamic rawCategory
          in categoriesRaw) {
        if (rawCategory is! Map) {
          continue;
        }

        final Map<String, dynamic> category =
            Map<String, dynamic>.from(
          rawCategory,
        );

        final String categoryId =
            category['id']
                    ?.toString()
                    .trim()
                    .toUpperCase() ??
                '';

        if (!allowedCategories.contains(
          categoryId,
        )) {
          continue;
        }

        final dynamic codesRaw =
            category['product_codes'];

        if (codesRaw is! List) {
          continue;
        }

        for (final dynamic rawCode
            in codesRaw) {
          final String code =
              rawCode
                  .toString()
                  .trim()
                  .toUpperCase();

          if (code.isEmpty) {
            continue;
          }

          if (!productCodes.contains(
            code,
          )) {
            productCodes.add(
              code,
            );
          }
        }
      }

      if (productCodes.isEmpty) {
        throw Exception(
          'No Mobile Reload products are available.',
        );
      }

      // ======================================================================
      // PRODUCTS OBJECT
      // ======================================================================

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

      final List<_MobileReloadProduct>
          loadedProducts = [];

for (final String productCode
    in productCodes) {

  // ================================================================
  // TEMPORARILY HIDE PRODUCTS WITH IIMMPACT ISSUE
  // ================================================================

  if (_temporarilyHiddenProducts.contains(
    productCode.trim().toUpperCase(),
  )) {
    debugPrint(
      'Mobile Reload product temporarily hidden: '
      '$productCode',
    );

    continue;
  }

        final dynamic rawProduct =
            products[productCode];

        if (rawProduct is! Map) {
          debugPrint(
            'Mobile Reload catalog product '
            'not found: $productCode',
          );

          continue;
        }

        final Map<String, dynamic> product =
            Map<String, dynamic>.from(
          rawProduct,
        );
        // ================================================================
        // ONLY ACTIVE PRODUCTS
        // ================================================================

        final bool isActive =
            product['is_active'] == true;

        if (!isActive) {
          continue;
        }

        final String name =
            product['name']
                    ?.toString()
                    .trim() ??
                productCode;

        final String imageUrl =
            product['image_url']
                    ?.toString()
                    .trim() ??
                '';

        final String processingTime =
            product['processing_time']
                    ?.toString()
                    .trim() ??
                '';

        final String denomination =
            product['denomination']
                    ?.toString()
                    .trim() ??
                '';

        final String currency =
            product['denomination_currency']
                    ?.toString()
                    .trim() ??
                '';

        final String note =
            product['note']
                    ?.toString()
                    .trim() ??
                '';

        loadedProducts.add(
          _MobileReloadProduct(
            productCode: productCode,
            name: name,
            imageUrl: imageUrl,
            processingTime: processingTime,
            denomination: denomination,
            currency: currency,
            note: note,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _products
          ..clear()
          ..addAll(loadedProducts);

        for (final product in loadedProducts) {
          _networkStatuses[product.productCode] =
              MobileReloadStatus.loading;
        }

        _isLoading = false;
      });

      await _loadInitialNetworkStatuses();

      // Wait until cards are rendered.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _handleScroll();
        },
      );

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'MOBILE RELOAD CATALOG LOADED',
      );
      debugPrint(
        '========================================',
      );

      debugPrint(
        'Categories : MOBILE_DATA + MOBILE_PREPAID',
      );

      debugPrint(
        'Products   : ${_products.length}',
      );

      for (final product in _products) {
        debugPrint(
          '${product.productCode} '
          '- ${product.name}',
        );
      }

      debugPrint(
        '========================================',
      );
      debugPrint('');
    }

    // ========================================================================
    // IIMMPACT ERROR
    // ========================================================================

    on IimmpactCatalogException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage =
            error.message;
      });
    }

    // ========================================================================
    // OTHER ERROR
    // ========================================================================

    catch (error, stackTrace) {
      debugPrint(
        'Mobile Reload catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage =
            error.toString();
      });
    }
  }

  // ==========================================================================
  // PROVIDER TAP
  // ==========================================================================

  void _handleProviderTap(
    _MobileReloadProduct product,
  ) {
    // ========================================================================
    // NEXT PAGE
    //
    // We will connect PMOBILERELOAD4PAGE here next.
    //
    // For now this proves that product data is coming dynamically
    // from /v2/catalog.
    // ========================================================================

    debugPrint('');
    debugPrint(
      '========================================',
    );

    debugPrint(
      'MOBILE RELOAD PRODUCT SELECTED',
    );

    debugPrint(
      '========================================',
    );

    debugPrint(
      'Code       : ${product.productCode}',
    );

    debugPrint(
      'Name       : ${product.name}',
    );

    debugPrint(
      'Denom      : ${product.denomination}',
    );

    debugPrint(
      'Currency   : ${product.currency}',
    );

    debugPrint(
      'Processing : ${product.processingTime}',
    );

    debugPrint(
      '========================================',
    );

    debugPrint('');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PMOBILERELOAD4PAGE(
          productCode: product.productCode,
          providerName: product.name,
          providerImageUrl: product.imageUrl,
        ),
      ),
    );
    
  }

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        !mounted) {
      return;
    }

    final double current =
        _scrollController.offset;

    final double maximum =
        _scrollController
            .position
            .maxScrollExtent;

    final bool showUp =
        current > 10;

    final bool showDown =
        current < maximum - 10;

    if (_showScrollUp != showUp ||
        _showScrollDown != showDown) {
      setState(() {
        _showScrollUp = showUp;
        _showScrollDown = showDown;
      });
    }
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double destination =
        (_scrollController.offset - 600)
            .clamp(
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
      curve: Curves.easeOut,
    );
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double destination =
        (_scrollController.offset + 600)
            .clamp(
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
      curve: Curves.easeOut,
    );
  }

  // ==========================================================================
  // PROCESSING TIME
  // ==========================================================================

  String _formatProcessingTime(
    AppLocalizations loc,
    String value,
  ) {
    final String normalized =
        value
            .trim()
            .toLowerCase();

    if (normalized == 'instant') {
      return loc.processingInstant;
    }

    if (normalized == '24_hours') {
      return loc.processing24Hours;
    }

    if (normalized == '3_days') {
      return loc.processing3Days;
    }

    if (normalized.endsWith(
      '_hours',
    )) {
      final String hours =
          normalized.replaceAll(
        '_hours',
        '',
      );

      return loc.telcoUpdateWithinHours(
        hours,
      );
    }

    if (normalized.endsWith(
      '_days',
    )) {
      final String days =
          normalized.replaceAll(
        '_days',
        '',
      );

      return loc.telcoUpdateWithinDays(
        days,
      );
    }

    return value.replaceAll(
      '_',
      ' ',
    );
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _scrollController
        .removeListener(
      _handleScroll,
    );

    _scrollController.dispose();

    super.dispose();
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
              color: Colors.white.withOpacity(
                0.06,
              ),
            ),
          ),

          // ==================================================================
          // HEADER
          // ==================================================================

          Positioned(
            top: 45,
            left: 55,
            right: 55,
            child: Column(
              children: [
                // ============================================================
                // SERVICE BADGE
                // ============================================================

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        _primaryColor.withOpacity(
                      0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                    border:
                        Border.all(
                      color:
                          _primaryColor.withOpacity(
                        0.28,
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
                            .phone_android_rounded,
                        color:
                            _primaryColor,
                        size: 27,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Text(
                        loc.mobileReloadServiceLabel
                            .toUpperCase(),
                        style:
                            const TextStyle(
                          color:
                              _primaryColor,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // ============================================================
                // TITLE
                // ============================================================

                ShaderMask(
                  blendMode:
                      BlendMode.srcIn,
                  shaderCallback:
                      (bounds) {
                    return const LinearGradient(
                      colors: [
                        _darkColor,
                        _primaryColor,
                      ],
                    ).createShader(
                      bounds,
                    );
                  },
                  child: Text(
                    loc.mobileReloadProviderTitle
                        .toUpperCase(),
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 48,
                      fontWeight:
                          FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // ============================================================
                // SUBTITLE
                // ============================================================

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white.withOpacity(
                      0.94,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      23,
                    ),
                    border:
                        Border.all(
                      color:
                          Colors.black.withOpacity(
                        0.16,
                      ),
                    ),
                  ),
                  child: Text(
                    loc.mobileReloadProviderSubtitle,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF435166,
                      ),
                      fontSize: 25,
                      fontWeight:
                          FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================================================================
          // CONTENT
          // ==================================================================

          Positioned(
            top: 355,
            left: 45,
            right: 45,
            bottom: 300,
            child: _isLoading
                ? _buildLoading(
                    loc,
                  )
                : _errorMessage != null
                    ? _buildError(
                        loc,
                      )
                    : _buildProducts(
                        loc,
                      ),
          ),

          // ==================================================================
          // SCROLL UP
          // ==================================================================

          if (!_isLoading &&
              _errorMessage == null &&
              _showScrollUp)
            Positioned(
              right: 12,
              top: 330,
              child:
                  _MobileReloadScrollButton(
                icon: Icons
                    .keyboard_arrow_up_rounded,
                label:
                    loc.scrollup,
                onPressed:
                    _scrollUp,
              ),
            ),

          // ==================================================================
          // SCROLL DOWN
          // ==================================================================

          if (!_isLoading &&
              _errorMessage == null &&
              _showScrollDown)
            Positioned(
              right: 12,
              bottom: 280,
              child:
                  _MobileReloadScrollButton(
                icon: Icons
                    .keyboard_arrow_down_rounded,
                label:
                    loc.scrolldown,
                onPressed:
                    _scrollDown,
                iconBelowText:
                    true,
              ),
            ),

          // ==================================================================
          // BACK
          // ==================================================================

          Positioned(
            bottom: 105,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
            ),
          ),

          // ==================================================================
          // COPYRIGHT
          // ==================================================================

          Positioned(
            bottom: 25,
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
                fontSize: 20,
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
      child: Container(
        width: 600,
        padding:
            const EdgeInsets.all(
          45,
        ),
        decoration:
            BoxDecoration(
          color:
              Colors.white.withOpacity(
            0.96,
          ),
          borderRadius:
              BorderRadius.circular(
            35,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 7,
              color:
                  _primaryColor,
            ),

            const SizedBox(
              height: 30,
            ),

            Text(
              loc.mobileReloadLoadingTitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize: 38,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              loc.mobileReloadLoadingMessage,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF657386,
                ),
                fontSize: 26,
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
      child: Container(
        width: 680,
        padding:
            const EdgeInsets.all(
          42,
        ),
        decoration:
            BoxDecoration(
          color:
              Colors.white.withOpacity(
            0.97,
          ),
          borderRadius:
              BorderRadius.circular(
            35,
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
              size: 85,
            ),

            const SizedBox(
              height: 22,
            ),

            Text(
              loc.mobileReloadErrorTitle,
              textAlign:
                  TextAlign.center,
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

            const SizedBox(
              height: 14,
            ),

            Text(
              loc.mobileReloadErrorMessage,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF657386,
                ),
                fontSize: 26,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 80,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _loadMobileReloadProducts,
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),
                label: Text(
                  loc.mobileReloadRetry,
                  style:
                      const TextStyle(
                    fontSize: 27,
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
  // PRODUCTS
  // ==========================================================================

  Widget _buildProducts(
    AppLocalizations loc,
  ) {
    return Scrollbar(
      controller:
          _scrollController,
      thumbVisibility:
          true,
      trackVisibility:
          true,
      thickness:
          10,
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
            const EdgeInsets.only(
          right: 25,
          bottom: 50,
        ),
        child:
            Column(
          children:
              _buildProductRows(
            loc,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProductRows(
    AppLocalizations loc,
  ) {
    final List<Widget> rows = [];

    for (int i = 0;
        i < _products.length;
        i += 2) {
      final left =
          _products[i];

      final _MobileReloadProduct?
          right =
          i + 1 < _products.length
              ? _products[i + 1]
              : null;

      rows.add(
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
              _MobileReloadCard(
                product: left,

                networkStatus:
                    _networkStatuses[left.productCode] ??
                        MobileReloadStatus.loading,

                networkLabel:
                    loc.networkLabel,

                processingLabel:
                    loc.processingTimeLabel,

                processingValue:
                    _formatProcessingTime(
                  loc,
                  left.processingTime,
                ),
                onPressed: () {
                  _handleProviderTap(
                    left,
                  );
                },
              ),
            ),

            const SizedBox(
              width: 30,
            ),

            Expanded(
              child: right == null
                  ? const SizedBox()
                  : _MobileReloadCard(
                      product: right,

                      networkStatus:
                          _networkStatuses[right.productCode] ??
                              MobileReloadStatus.loading,

                      networkLabel:
                          loc.networkLabel,

                      processingLabel:
                          loc.processingTimeLabel,

                      processingValue:
                          _formatProcessingTime(
                        loc,
                        right.processingTime,
                      ),
                      onPressed: () {
                        _handleProviderTap(
                          right,
                        );
                      },
                    ),
            ),
          ],
        ),
      );

      if (i + 2 <
          _products.length) {
        rows.add(
          const SizedBox(
            height: 30,
          ),
        );
      }
    }

    return rows;
  }
}

// ============================================================================
// PRODUCT MODEL
// ============================================================================

class _MobileReloadProduct {
  final String productCode;

  final String name;

  final String imageUrl;

  final String processingTime;

  final String denomination;

  final String currency;

  final String note;

  const _MobileReloadProduct({
    required this.productCode,
    required this.name,
    required this.imageUrl,
    required this.processingTime,
    required this.denomination,
    required this.currency,
    required this.note,
  });
}

// ============================================================================
// PRODUCT CARD
// ============================================================================

class _MobileReloadCard
    extends StatefulWidget {
  final _MobileReloadProduct
      product;

  final String
      processingLabel;

  final String
      processingValue;

  final VoidCallback
      onPressed;

  final MobileReloadStatus networkStatus;

  final String networkLabel;

  const _MobileReloadCard({
    required this.product,
    required this.processingLabel,
    required this.processingValue,
    required this.onPressed,
    required this.networkStatus,
    required this.networkLabel,
  });

  @override
  State<_MobileReloadCard>
      createState() =>
          _MobileReloadCardState();
}

class _MobileReloadCardState
    extends State<_MobileReloadCard> {
  bool _pressed =
      false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTapDown:
          (_) {
        setState(() {
          _pressed =
              true;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          _pressed =
              false;
        });
      },

      onTapCancel:
          () {
        setState(() {
          _pressed =
              false;
        });
      },

      onTap:
          widget.onPressed,

      child:
          AnimatedScale(
        scale:
            _pressed
                ? 0.965
                : 1,

        duration:
            const Duration(
          milliseconds:
              130,
        ),

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds:
                170,
          ),

          height:
              410,

          padding:
              const EdgeInsets.all(
            27,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.97,
            ),

            borderRadius:
                BorderRadius.circular(
              35,
            ),

            border:
                Border.all(
              color:
                  _pressed
                      ? const Color(
                          0xFF7B4DCC,
                        )
                      : Colors.black,

              width:
                  _pressed
                      ? 4
                      : 2.5,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.12,
                ),
                blurRadius:
                    25,
                offset:
                    const Offset(
                  0,
                  12,
                ),
              ),
            ],
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
                        Container(
                      height:
                          160,

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF8F9FC,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),
                      ),

                      child:
                          Image.network(
                        widget.product
                            .imageUrl,

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
                            size:
                                70,
                            color:
                                Color(
                              0xFF7B4DCC,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  Container(
                    width:
                        55,
                    height:
                        55,
                    decoration:
                        const BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color:
                          Color(
                        0xFF7B4DCC,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .arrow_forward_rounded,
                      color:
                          Colors.white,
                      size:
                          30,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                widget.product
                    .name
                    .toUpperCase(),

                maxLines:
                    2,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF15253A,
                  ),
                  fontSize:
                      31,
                  fontWeight:
                      FontWeight.w900,
                  height:
                      1.08,
                ),
              ),

              const SizedBox(height: 14),

              _MobileReloadNetworkBadge(
                status: widget.networkStatus,
                label: widget.networkLabel,
              ),

              const SizedBox(
                height: 13,
              ),

              if (widget
                  .processingValue
                  .trim()
                  .isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons
                          .schedule_rounded,
                      color:
                          Color(
                        0xFF647187,
                      ),
                      size:
                          21,
                    ),

                    const SizedBox(
                      width: 7,
                    ),

                    Expanded(
                      child:
                          Text(
                        '${widget.processingLabel}: '
                        '${widget.processingValue}',

                        maxLines:
                            1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF647187,
                          ),
                          fontSize:
                              17,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(
                height: 18,
              ),

              Container(
                width:
                    65,
                height:
                    7,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF7B4DCC,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

    class _MobileReloadNetworkBadge
        extends StatelessWidget {
      final MobileReloadStatus status;
      final String label;

      const _MobileReloadNetworkBadge({
        required this.status,
        required this.label,
      });

      @override
      Widget build(BuildContext context) {
        final loc =
            AppLocalizations.of(context)!;

        late final String statusText;
        late final Color backgroundColor;
        late final Color borderColor;
        late final Color foregroundColor;
        late final IconData icon;

        switch (status) {
          case MobileReloadStatus.loading:
            statusText =
                loc.networkStatusChecking;

            backgroundColor =
                const Color(0xFFF0F4F8);

            borderColor =
                const Color(0xFFC7D2DE);

            foregroundColor =
                const Color(0xFF536272);

            icon =
                Icons.sync_rounded;

            break;

          case MobileReloadStatus.healthy:
            statusText =
                loc.networkStatusGood;

            backgroundColor =
                const Color(0xFFE2F8EC);

            borderColor =
                const Color(0xFF78C99B);

            foregroundColor =
                const Color(0xFF08783E);

            icon =
                Icons.check_circle_rounded;

            break;

          case MobileReloadStatus.interruption:
            statusText =
                loc.networkStatusSlow;

            backgroundColor =
                const Color(0xFFFFF0D7);

            borderColor =
                const Color(0xFFF1B95D);

            foregroundColor =
                const Color(0xFFB75B00);

            icon =
                Icons.warning_amber_rounded;

            break;

          case MobileReloadStatus.unavailable:
            statusText =
                loc.networkStatusUnknown;

            backgroundColor =
                const Color(0xFFF1F1F1);

            borderColor =
                const Color(0xFFC8C8C8);

            foregroundColor =
                const Color(0xFF555555);

            icon =
                Icons.help_outline_rounded;

            break;
        }

        return Container(
          constraints:
              const BoxConstraints(
            minHeight: 52,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 11,
          ),
          decoration:
              BoxDecoration(
            color:
                backgroundColor,
            borderRadius:
                BorderRadius.circular(
              30,
            ),
            border:
                Border.all(
              color:
                  borderColor,
              width:
                  1.5,
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (status ==
                  MobileReloadStatus.loading)
                SizedBox(
                  width: 23,
                  height: 23,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 3,
                    color:
                        foregroundColor,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 25,
                  color:
                      foregroundColor,
                ),

              const SizedBox(
                width: 8,
              ),

              Flexible(
                child: Text(
                  '$label: $statusText',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        foregroundColor,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

// ============================================================================
// SCROLL BUTTON
// ============================================================================

class _MobileReloadScrollButton
    extends StatelessWidget {
  final IconData icon;

  final String label;

  final VoidCallback onPressed;

  final bool iconBelowText;

  const _MobileReloadScrollButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconBelowText = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final Widget iconWidget =
        Icon(
      icon,
      size: 50,
      color:
          const Color(
        0xFF7B4DCC,
      ),
    );

    final Widget textWidget =
        Text(
      label,
      textAlign:
          TextAlign.center,
      style:
          const TextStyle(
        color:
            Color(
          0xFF15253A,
        ),
        fontSize: 16,
        fontWeight:
            FontWeight.w900,
      ),
    );

    return Material(
      color:
          Colors.white.withOpacity(
        0.97,
      ),
      elevation:
          5,
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      child: InkWell(
        onTap:
            onPressed,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            border:
                Border.all(
              color:
                  Colors.black,
              width:
                  2,
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children:
                iconBelowText
                    ? [
                        textWidget,
                        iconWidget,
                      ]
                    : [
                        iconWidget,
                        textWidget,
                      ],
          ),
        ),
      ),
    );
  }
}