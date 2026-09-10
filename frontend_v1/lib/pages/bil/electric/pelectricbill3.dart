import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

// ============================================================================
// BILLER STATUS
// ============================================================================

enum BillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

// ============================================================================
// ELECTRIC PRODUCT MODEL
//
// All product information comes from:
//
// /v2/catalog
//
// tree.groups
//      ↓
// categories
//      ↓
// category.id == ELEC
//      ↓
// category.product_codes
//      ↓
// products[productCode]
//
// Nothing such as TNB / SESCO / SESB / NUR is manually listed here.
// ============================================================================

class _ElectricProduct {
  final String code;
  final String name;
  final String imageUrl;
  final String processingTime;
  final bool isActive;

  const _ElectricProduct({
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.processingTime,
    required this.isActive,
  });
}

// ============================================================================
// ELECTRIC BILL PROVIDER PAGE
// ============================================================================

class PELECTRICBILL3PAGE extends StatefulWidget {
  const PELECTRICBILL3PAGE({
    super.key,
  });

  @override
  State<PELECTRICBILL3PAGE> createState() =>
      _PELECTRICBILL3PAGEState();
}

class _PELECTRICBILL3PAGEState
    extends State<PELECTRICBILL3PAGE> {
  // ==========================================================================
  // PRODUCTS FROM CATALOG
  // ==========================================================================

  final List<_ElectricProduct> _electricProducts = [];

  bool _catalogLoading = true;

  String? _catalogError;

  // ==========================================================================
  // NETWORK STATUS
  //
  // Also dynamic.
  //
  // Example after catalog loads:
  //
  // {
  //   'TNB': healthy,
  //   'SESCO': healthy,
  //   ...
  // }
  //
  // No provider codes are declared beforehand.
  // ==========================================================================

  final Map<String, BillerStatus> _billerStatuses = {};

  final Map<String, String?> _lastUpdated = {};

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = false;

  // ==========================================================================
  // UI COLORS
  //
  // These are only decorative UI colors.
  //
  // They are NOT provider configuration.
  //
  // If API adds more providers, colors automatically repeat.
  // ==========================================================================

  static const List<Color> _accentColors = [
    Color(0xFF1469E8),
    Color(0xFF128B75),
    Color(0xFF1779B9),
    Color(0xFFE59522),
    Color(0xFF7356D8),
    Color(0xFFD64D8B),
  ];

  static const List<Color> _lightAccentColors = [
    Color(0xFFE5F0FF),
    Color(0xFFE2F7F1),
    Color(0xFFE5F5FF),
    Color(0xFFFFF3D9),
    Color(0xFFEDE9FF),
    Color(0xFFFFE6F2),
  ];

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadElectricCatalog();
      },
    );
  }

  // ==========================================================================
  // LOAD ELECTRICITY PROVIDERS FROM CATALOG
  //
  // IMPORTANT:
  //
  // We ONLY identify the ELEC category.
  //
  // Provider codes themselves come from:
  //
  // category.product_codes
  //
  // Example current API:
  //
  // ELEC
  // ├── NUR
  // ├── SESB
  // ├── SESCO
  // └── TNB
  //
  // If tomorrow API adds:
  //
  // └── NEWCODE
  //
  // NEWCODE automatically appears without modifying this file.
  // ==========================================================================

  Future<void> _loadElectricCatalog() async {
    if (mounted) {
      setState(() {
        _catalogLoading = true;
        _catalogError = null;

        showScrollUp = false;
        showScrollDown = false;
      });
    }

    try {
      // ======================================================================
      // 1. GET CATALOG
      // ======================================================================

      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      // ======================================================================
      // 2. TREE
      // ======================================================================

      final dynamic treeRaw =
          catalog['tree'];

      if (treeRaw is! Map) {
        throw Exception(
          'Catalog tree not found.',
        );
      }

      final Map<String, dynamic> tree =
          Map<String, dynamic>.from(
        treeRaw,
      );

      // ======================================================================
      // 3. GROUPS
      // ======================================================================

      final dynamic groupsRaw =
          tree['groups'];

      if (groupsRaw is! List) {
        throw Exception(
          'Catalog groups not found.',
        );
      }

      // ======================================================================
      // 4. FIND ELEC CATEGORY
      // ======================================================================

      final List<String> electricCodes = [];

      for (final dynamic groupRaw in groupsRaw) {
        if (groupRaw is! Map) {
          continue;
        }

        final Map<String, dynamic> group =
            Map<String, dynamic>.from(
          groupRaw,
        );

        final dynamic categoriesRaw =
            group['categories'];

        if (categoriesRaw is! List) {
          continue;
        }

        for (final dynamic categoryRaw
            in categoriesRaw) {
          if (categoryRaw is! Map) {
            continue;
          }

          final Map<String, dynamic> category =
              Map<String, dynamic>.from(
            categoryRaw,
          );

          final String categoryId =
              category['id']
                      ?.toString()
                      .trim()
                      .toUpperCase() ??
                  '';

          // ==================================================================
          // ELECTRICITY CATEGORY ONLY
          // ==================================================================

          if (categoryId != 'ELEC') {
            continue;
          }

          final dynamic productCodesRaw =
              category['product_codes'];

          if (productCodesRaw is! List) {
            continue;
          }

          for (final dynamic rawCode
              in productCodesRaw) {
            final String code =
                rawCode
                        ?.toString()
                        .trim()
                        .toUpperCase() ??
                    '';

            if (code.isEmpty) {
              continue;
            }

            if (!electricCodes.contains(code)) {
              electricCodes.add(
                code,
              );
            }
          }
        }
      }

      // ======================================================================
      // 5. PRODUCTS
      // ======================================================================

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products not found.',
        );
      }

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      // ======================================================================
      // 6. BUILD ELECTRIC PRODUCTS
      // ======================================================================

      final List<_ElectricProduct> loadedProducts = [];

      for (final String code in electricCodes) {
        final dynamic rawProduct =
            products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'Electric catalog product not found: $code',
          );

          continue;
        }

        final Map<String, dynamic> product =
            Map<String, dynamic>.from(
          rawProduct,
        );

        // ====================================================================
        // ACTIVE
        // ====================================================================

        final bool isActive =
            product['is_active'] == true;

        if (!isActive) {
          debugPrint(
            'Electric product inactive: $code',
          );

          continue;
        }

        // ====================================================================
        // PRODUCT CODE
        // ====================================================================

        final String productCode =
            product['code']
                    ?.toString()
                    .trim()
                    .toUpperCase() ??
                code;

        // ====================================================================
        // NAME
        // ====================================================================

        final String productName =
            product['name']
                    ?.toString()
                    .trim() ??
                productCode;

        // ====================================================================
        // IMAGE
        // ====================================================================

        final String imageUrl =
            product['image_url']
                    ?.toString()
                    .trim() ??
                '';

        // ====================================================================
        // PROCESSING TIME
        // ====================================================================

        final String processingTime =
            product['processing_time']
                    ?.toString()
                    .trim() ??
                '';

        loadedProducts.add(
          _ElectricProduct(
            code: productCode,
            name: productName,
            imageUrl: imageUrl,
            processingTime: processingTime,
            isActive: isActive,
          ),
        );
      }

      // ======================================================================
      // UPDATE UI
      // ======================================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _electricProducts
          ..clear()
          ..addAll(
            loadedProducts,
          );

        _catalogLoading = false;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'ELECTRICITY CATALOG LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Products: '
        '${_electricProducts.map((e) => e.code).toList()}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // 7. LOAD NETWORK STATUS
      // ======================================================================

      await _loadNetworkStatuses();

      if (!mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _handleScroll();
        },
      );
    }

    // =========================================================================
    // CATALOG ERROR
    // =========================================================================

    on IimmpactCatalogException catch (error) {
      debugPrint(
        'Electric catalog error: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _electricProducts.clear();

        _catalogLoading = false;

        _catalogError =
            error.message;

        showScrollUp = false;
        showScrollDown = false;
      });
    }

    // =========================================================================
    // UNKNOWN ERROR
    // =========================================================================

    catch (error, stackTrace) {
      debugPrint(
        'Unexpected electric catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _electricProducts.clear();

        _catalogLoading = false;

        _catalogError =
            error.toString();

        showScrollUp = false;
        showScrollDown = false;
      });
    }
  }

  // ==========================================================================
  // LOAD NETWORK STATUS FOR ALL ACTIVE PROVIDERS
  // ==========================================================================

  Future<void> _loadNetworkStatuses() async {
    if (_electricProducts.isEmpty) {
      return;
    }

    await Future.wait(
      _electricProducts.map(
        (
          _ElectricProduct product,
        ) {
          return _refreshNetworkStatus(
            product.code,
          );
        },
      ),
    );
  }

  // ==========================================================================
  // REFRESH NETWORK STATUS
  //
  // Uses catalog product code directly.
  // ==========================================================================

  Future<BillerStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            BillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final BillerStatus status =
          result.isHealthy
              ? BillerStatus.healthy
              : BillerStatus.interruption;

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              status;

          _lastUpdated[productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Electric network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              BillerStatus.unavailable;
        });
      }

      return BillerStatus.unavailable;
    }
  }

  // ==========================================================================
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handleBillerTap(
    _ElectricProduct product,
  ) async {
    final BillerStatus status =
        await _refreshNetworkStatus(
      product.code,
    );

    if (!mounted) {
      return;
    }

    // ========================================================================
    // INTERRUPTION
    // ========================================================================

    if (status ==
        BillerStatus.interruption) {
      final bool shouldContinue =
          await _showInterruptionWarning(
        billerName:
            product.name,
        productCode:
            product.code,
      );

      if (!shouldContinue) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    // ========================================================================
    // UNAVAILABLE
    // ========================================================================

    if (status ==
        BillerStatus.unavailable) {
      final loc =
          AppLocalizations.of(context)!;

      await showDialog<void>(
        context: context,
        builder:
            (
          BuildContext dialogContext,
        ) {
          return AlertDialog(
            title: Text(
              loc.alertTitle,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            content: Text(
              loc.networkUnavailableMessage(
                product.name,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: Text(
                  loc.electricOk,
                ),
              ),
            ],
          );
        },
      );

      return;
    }

    if (!mounted) {
      return;
    }

    // ========================================================================
    // PAGE 4
    //
    // product.code and product.name come directly from catalog.
    // ========================================================================

    final loc =
        AppLocalizations.of(context)!;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            P4BILPAGE(
          title:
              loc.electricAccountTitle,
          hint:
              loc.electricAccountHint,
          productCode:
              product.code,
          billerName:
              product.name,
          serviceType:
              BillServiceType.electric,
        ),
      ),
    );
  }

  // ==========================================================================
  // INTERRUPTION WARNING
  // ==========================================================================

  Future<bool> _showInterruptionWarning({
    required String billerName,
    required String productCode,
  }) async {
    final loc =
        AppLocalizations.of(context)!;

    final bool? result =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (
        BuildContext dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 80,
          ),
          child: Container(
            width: 800,
            padding:
                const EdgeInsets.fromLTRB(
              45,
              42,
              45,
              38,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                38,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFF2A520,
                ),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.25,
                  ),
                  blurRadius: 35,
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
                // ============================================================
                // WARNING ICON
                // ============================================================

                Container(
                  width: 125,
                  height: 125,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF2D9,
                    ),
                    shape:
                        BoxShape.circle,
                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFF2A520,
                      ).withOpacity(
                        0.30,
                      ),
                      width: 2,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons
                        .warning_amber_rounded,
                    color:
                        Color(
                      0xFFD87900,
                    ),
                    size: 78,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                // ============================================================
                // TITLE
                // ============================================================

                Text(
                  loc.networkInterruptionTitle,
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
                        FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // ============================================================
                // MESSAGE
                // ============================================================

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
                        const Color(
                      0xFFFFF9ED,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFF4D69D,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    loc.networkInterruptionMessage(
                      billerName,
                    ),
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF4B4234,
                      ),
                      fontSize: 29,
                      height: 1.4,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                // ============================================================
                // LAST UPDATED
                // ============================================================

                if (_lastUpdated[
                        productCode] !=
                    null) ...[
                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 24,
                        color:
                            Color(
                          0xFF758399,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Flexible(
                        child: Text(
                          '${loc.networkLastUpdated}: '
                          '${_lastUpdated[productCode]}',
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 21,
                            color:
                                Color(
                              0xFF758399,
                            ),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(
                  height: 36,
                ),

                // ============================================================
                // ACTIONS
                // ============================================================

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child:
                            OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .arrow_back_rounded,
                            size: 29,
                          ),
                          label: Text(
                            loc.backButton,
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          style:
                              OutlinedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xFFFFE8E8,
                            ),
                            foregroundColor:
                                const Color(
                              0xFFC62828,
                            ),
                            side:
                                const BorderSide(
                              color:
                                  Color(
                                0xFFE57373,
                              ),
                              width: 2,
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
                      width: 22,
                    ),

                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .arrow_forward_rounded,
                            size: 29,
                          ),
                          label: Text(
                            loc.continueButton,
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF168A50,
                            ),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // ==========================================================================
  // SCROLL POSITION
  // ==========================================================================

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        !mounted ||
        _catalogLoading) {
      return;
    }

    final double maxScroll =
        _scrollController.position.maxScrollExtent;

    final double currentScroll =
        _scrollController.offset;

    final bool shouldShowScrollUp =
        currentScroll > 10;

    final bool shouldShowScrollDown =
        maxScroll > 10 &&
        currentScroll <
            maxScroll - 10;

    if (showScrollUp != shouldShowScrollUp ||
        showScrollDown !=
            shouldShowScrollDown) {
      setState(() {
        showScrollUp =
            shouldShowScrollUp;

        showScrollDown =
            shouldShowScrollDown;
      });
    }
  }

  // ==========================================================================
  // SCROLL UP
  // ==========================================================================

  void _scrollUp() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double destination =
        (_scrollController.offset - 600)
            .clamp(
      0.0,
      _scrollController
          .position.maxScrollExtent,
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
  // SCROLL DOWN
  // ==========================================================================

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double destination =
        (_scrollController.offset + 600)
            .clamp(
      0.0,
      _scrollController
          .position.maxScrollExtent,
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
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _scrollController.removeListener(
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
                      0.12,
                    ),
                    Colors.white.withOpacity(
                      0.04,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================================
          // HEADER
          // ==================================================================

          Positioned(
            top: 82,
            left: 65,
            right: 65,
            child:
                _ModernPageHeader(
              title:
                  loc.pbilelectric3Title,
              subtitle:
                  loc.pbil3Subtitle,
            ),
          ),

          // ==================================================================
          // PROVIDER AREA
          // ==================================================================

          Positioned(
            top: 400,
            left: 45,
            right: 45,
            bottom: 305,
            child:
                _buildProviderArea(
              loc,
            ),
          ),

          // ==================================================================
          // SCROLL UP
          // ==================================================================

          if (!_catalogLoading &&
              _electricProducts.isNotEmpty &&
              showScrollUp)
            Positioned(
              right: 18,
              top: 365,
              child:
                  _ScrollIndicatorButton(
                icon:
                    Icons
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

          if (!_catalogLoading &&
              _electricProducts.isNotEmpty &&
              showScrollDown)
            Positioned(
              right: 18,
              bottom: 290,
              child:
                  _ScrollIndicatorButton(
                icon:
                    Icons
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
            child:
                KioskBackButton(
              onPressed: () {
                Navigator
                    .pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PBIL3PAGE(),
                  ),
                );
              },
            ),
          ),

          // ==================================================================
          // FOOTER
          // ==================================================================

          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Center(
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
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PROVIDER AREA
  // ==========================================================================

  Widget _buildProviderArea(
    AppLocalizations loc,
  ) {
    // ========================================================================
    // MODERN LOADING
    // ========================================================================

    if (_catalogLoading) {
      return _buildModernLoading(
        loc,
      );
    }

    // ========================================================================
    // ERROR
    // ========================================================================

    if (_catalogError != null) {
      return Center(
        child: Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            35,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.96,
            ),
            borderRadius:
                BorderRadius.circular(
              28,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFD7E2F0,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF17375E,
                ).withOpacity(
                  0.10,
                ),
                blurRadius: 22,
                offset:
                    const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFEAF2FC,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons.cloud_off_rounded,
                  size: 55,
                  color:
                      Color(
                    0xFF0A2E70,
                  ),
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              Text(
                loc.billUnknownError,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 27,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(
                    0xFF0A2E70,
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              SizedBox(
                height: 70,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _loadElectricCatalog,
                  icon:
                      const Icon(
                    Icons.refresh_rounded,
                    size: 28,
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
                        const Color(
                      0xFF1469E8,
                    ),
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 35,
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
            ],
          ),
        ),
      );
    }

    // ========================================================================
    // NO ACTIVE PROVIDERS
    // ========================================================================

    if (_electricProducts.isEmpty) {
      return Center(
        child: Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            35,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.96,
            ),
            borderRadius:
                BorderRadius.circular(
              28,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFD7E2F0,
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
                    .power_off_rounded,
                size: 65,
                color:
                    Color(
                  0xFF60758D,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                loc.networkStatusUnknown,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF17283E,
                  ),
                  fontSize: 27,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ========================================================================
    // DYNAMIC PROVIDER GRID
    // ========================================================================

    return Scrollbar(
      controller:
          _scrollController,
      thumbVisibility:
          true,
      trackVisibility:
          true,
      interactive:
          true,
      thickness:
          11,
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
          right: 24,
          bottom: 55,
        ),
        child: Column(
          children: [
            // ================================================================
            // TWO CARDS PER ROW
            // ================================================================

            for (
              int index = 0;
              index < _electricProducts.length;
              index += 2
            )
              Padding(
                padding:
                    EdgeInsets.only(
                  bottom:
                      index + 2 <
                              _electricProducts
                                  .length
                          ? 36
                          : 0,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Expanded(
                      child:
                          _buildElectricCard(
                        product:
                            _electricProducts[
                                index],
                        index:
                            index,
                        loc:
                            loc,
                      ),
                    ),

                    const SizedBox(
                      width: 34,
                    ),

                    Expanded(
                      child:
                          index + 1 <
                                  _electricProducts
                                      .length
                              ? _buildElectricCard(
                                  product:
                                      _electricProducts[
                                          index +
                                              1],
                                  index:
                                      index +
                                          1,
                                  loc:
                                      loc,
                                )
                              : const SizedBox(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // MODERN LOADING
  //
  // Generic loading ARB:
  //
  // providerLoading
  // providerLoadingSubtitle
  //
  // Can be reused by Water, Broadband, IDD, Gaming, E-Wallet, etc.
  // ==========================================================================

  Widget _buildModernLoading(
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        // ====================================================================
        // LOADING MESSAGE
        // ====================================================================

        Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 30,
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
                0xFFCFE0F7,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF174F92,
                ).withOpacity(
                  0.12,
                ),
                blurRadius: 24,
                offset:
                    const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              // ==============================================================
              // LOADING ICON
              // ==============================================================

              Container(
                width: 100,
                height: 100,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE8F2FF,
                  ),
                  shape:
                      BoxShape.circle,
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFC7DCF7,
                    ),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment:
                      Alignment.center,
                  children: [
                    const SizedBox(
                      width: 70,
                      height: 70,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 5,
                        color:
                            Color(
                          0xFF1469E8,
                        ),
                        backgroundColor:
                            Color(
                          0xFFD7E6F8,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons
                          .electric_bolt_rounded,
                      color:
                          Color(
                        0xFF1469E8,
                      ),
                      size: 40,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 25,
              ),

              // ==============================================================
              // TEXT
              // ==============================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.providerLoading,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF16324F,
                        ),
                        fontSize: 30,
                        fontWeight:
                            FontWeight.w900,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    Text(
                      loc.providerLoadingSubtitle,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF6A7B90,
                        ),
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 28,
        ),

        // ====================================================================
        // SKELETON PROVIDER CARDS
        // ====================================================================

        Row(
          children: [
            Expanded(
              child:
                  _buildLoadingProviderCard(),
            ),

            const SizedBox(
              width: 34,
            ),

            Expanded(
              child:
                  _buildLoadingProviderCard(),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // LOADING SKELETON CARD
  // ==========================================================================

  Widget _buildLoadingProviderCard() {
    return Container(
      height: 330,
      padding:
          const EdgeInsets.all(
        27,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.94,
        ),
        borderRadius:
            BorderRadius.circular(
          34,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFDCE5EF,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF1A3A5C,
            ).withOpacity(
              0.07,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==================================================================
          // FAKE LOGO AREA
          // ==================================================================

          Container(
            width: 150,
            height: 115,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE9EFF6,
              ),
              borderRadius:
                  BorderRadius.circular(
                24,
              ),
            ),
          ),

          const Spacer(),

          // ==================================================================
          // FAKE NAME
          // ==================================================================

          Container(
            width:
                double.infinity,
            height: 25,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE1E8F0,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Container(
            width: 170,
            height: 20,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEDF2F7,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          // ==================================================================
          // FAKE NETWORK STATUS
          // ==================================================================

          Container(
            width: 185,
            height: 48,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE8EEF5,
              ),
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BUILD DYNAMIC ELECTRIC CARD
  // ==========================================================================

  Widget _buildElectricCard({
    required _ElectricProduct product,
    required int index,
    required AppLocalizations loc,
  }) {
    final Color accentColor =
        _accentColors[
          index %
              _accentColors.length
        ];

    final Color lightAccentColor =
        _lightAccentColors[
          index %
              _lightAccentColors.length
        ];

    return _ElectricProviderCard(
      imageUrl:
          product.imageUrl,

      label:
          product.name,

      accentColor:
          accentColor,

      lightAccentColor:
          lightAccentColor,

      networkStatus:
          _billerStatuses[
                  product.code] ??
              BillerStatus.loading,

      networkLabel:
          loc.networkLabel,

      processingTime:
          product.processingTime,

      processingLabel:
          loc.processingTimeLabel,

      onPressed: () {
        _handleBillerTap(
          product,
        );
      },
    );
  }
}

// ============================================================================
// MODERN HEADER
// ============================================================================

class _ModernPageHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernPageHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color accentColor =
        Color(0xFF1469E8);

    final loc =
        AppLocalizations.of(context)!;

    return Column(
      children: [
        // ====================================================================
        // ELECTRICITY BADGE
        // ====================================================================

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          decoration:
              BoxDecoration(
            color:
                accentColor.withOpacity(
              0.10,
            ),
            borderRadius:
                BorderRadius.circular(
              100,
            ),
            border:
                Border.all(
              color:
                  accentColor.withOpacity(
                0.24,
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
                    .electric_bolt_rounded,
                color:
                    accentColor,
                size: 25,
              ),

              const SizedBox(
                width: 9,
              ),

              Text(
                loc.electricitybutton
                    .toUpperCase(),
                style:
                    const TextStyle(
                  color:
                      accentColor,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing:
                      1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 17,
        ),

        // ====================================================================
        // TITLE
        // ====================================================================

        ShaderMask(
          blendMode:
              BlendMode.srcIn,
          shaderCallback:
              (
            bounds,
          ) {
            return const LinearGradient(
              colors: [
                Color(
                  0xFF064CAC,
                ),
                Color(
                  0xFF1987EB,
                ),
              ],
            ).createShader(
              bounds,
            );
          },
          child: Text(
            title.toUpperCase(),
            textAlign:
                TextAlign.center,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 62,
              fontWeight:
                  FontWeight.w900,
              height: 1.05,
              letterSpacing:
                  -0.8,
            ),
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        // ====================================================================
        // SUBTITLE
        // ====================================================================

        Container(
          constraints:
              const BoxConstraints(
            maxWidth: 850,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 14,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.91,
            ),
            borderRadius:
                BorderRadius.circular(
              23,
            ),
            border:
                Border.all(
              color:
                  Colors.black.withOpacity(
                0.17,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF113968,
                ).withOpacity(
                  0.10,
                ),
                blurRadius: 22,
                offset:
                    const Offset(
                  0,
                  9,
                ),
              ),
            ],
          ),
          child: Text(
            subtitle.toUpperCase(),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF435166,
              ),
              fontSize: 28,
              fontWeight:
                  FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ELECTRIC PROVIDER CARD
// ============================================================================

class _ElectricProviderCard
    extends StatefulWidget {
  final String imageUrl;
  final String label;

  final VoidCallback onPressed;

  final Color accentColor;
  final Color lightAccentColor;

  final BillerStatus networkStatus;
  final String networkLabel;

  final String processingTime;
  final String processingLabel;

  const _ElectricProviderCard({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onPressed,
    required this.accentColor,
    required this.lightAccentColor,
    required this.networkStatus,
    required this.networkLabel,
    required this.processingTime,
    required this.processingLabel,
  });

  @override
  State<_ElectricProviderCard> createState() =>
      _ElectricProviderCardState();
}

// ============================================================================
// ELECTRIC PROVIDER CARD STATE
// ============================================================================

class _ElectricProviderCardState
    extends State<_ElectricProviderCard> {
  bool _isPressed = false;

  // ==========================================================================
  // PRESS STATE
  // ==========================================================================

  void _changePressedState(
    bool value,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  // ==========================================================================
  // PROCESSING TIME LOCALIZATION
  // ==========================================================================

  String _formatProcessingTime(
    BuildContext context,
    String value,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    switch (
        value.toLowerCase().trim()) {
      case 'instant':
        return loc.processingInstant;

      case '24_hours':
        return loc.processing24Hours;

      case '3_days':
        return loc.processing3Days;

      case 'pin':
        return 'PIN';

      default:
        return value.replaceAll(
          '_',
          ' ',
        );
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isEnabled =
        widget.networkStatus !=
            BillerStatus.unavailable;

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTapDown:
          isEnabled
              ? (_) {
                  _changePressedState(
                    true,
                  );
                }
              : null,

      onTapUp:
          isEnabled
              ? (_) {
                  _changePressedState(
                    false,
                  );
                }
              : null,

      onTapCancel:
          isEnabled
              ? () {
                  _changePressedState(
                    false,
                  );
                }
              : null,

      onTap:
          isEnabled
              ? widget.onPressed
              : null,

      child:
          AnimatedScale(
        scale:
            _isPressed
                ? 0.965
                : 1,

        duration:
            const Duration(
          milliseconds: 130,
        ),

        curve:
            Curves.easeOut,

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 170,
          ),

          curve:
              Curves.easeOut,

          height: 510,

          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              isEnabled
                  ? 0.96
                  : 0.72,
            ),

            borderRadius:
                BorderRadius.circular(
              40,
            ),

            border:
                Border.all(
              color:
                  _isPressed
                      ? widget.accentColor
                      : Colors.black,
              width:
                  _isPressed
                      ? 4
                      : 3,
            ),

            boxShadow:
                _isPressed
                    ? [
                        BoxShadow(
                          color:
                              widget
                                  .accentColor
                                  .withOpacity(
                            0.18,
                          ),
                          blurRadius:
                              18,
                          offset:
                              const Offset(
                            0,
                            8,
                          ),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF19375C,
                          ).withOpacity(
                            0.16,
                          ),
                          blurRadius:
                              30,
                          spreadRadius:
                              1,
                          offset:
                              const Offset(
                            0,
                            15,
                          ),
                        ),
                      ],
          ),

          child:
              ClipRRect(
            borderRadius:
                BorderRadius.circular(
              37,
            ),
            child: Stack(
              children: [
                // ============================================================
                // DECORATIVE CIRCLE
                // ============================================================

                Positioned(
                  right: -50,
                  top: -50,
                  child:
                      AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    width:
                        _isPressed
                            ? 225
                            : 210,
                    height:
                        _isPressed
                            ? 225
                            : 210,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color:
                          widget
                              .lightAccentColor
                              .withOpacity(
                        0.90,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 95,
                  top: 110,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color:
                          widget
                              .accentColor
                              .withOpacity(
                        0.08,
                      ),
                    ),
                  ),
                ),

                // ============================================================
                // CONTENT
                // ============================================================

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    30,
                    28,
                    30,
                    28,
                  ),
                  child:
                      Opacity(
                    opacity:
                        isEnabled
                            ? 1
                            : 0.50,
                    child: Column(
                      children: [
                        // ====================================================
                        // LOGO + ARROW
                        // ====================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Container(
                              width: 220,
                              height: 180,
                              padding:
                                  const EdgeInsets.all(
                                24,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                  34,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      widget
                                          .accentColor
                                          .withOpacity(
                                    0.20,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black
                                            .withOpacity(
                                      0.08,
                                    ),
                                    blurRadius: 16,
                                    offset:
                                        const Offset(
                                      0,
                                      8,
                                    ),
                                  ),
                                ],
                              ),
                              child:
                                  _buildLogo(),
                            ),

                            AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 160,
                              ),
                              transform:
                                  Matrix4.translationValues(
                                _isPressed
                                    ? 6
                                    : 0,
                                0,
                                0,
                              ),
                              width: 58,
                              height: 58,
                              decoration:
                                  BoxDecoration(
                                color:
                                    widget.accentColor,
                                shape:
                                    BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        widget
                                            .accentColor
                                            .withOpacity(
                                      0.25,
                                    ),
                                    blurRadius: 14,
                                    offset:
                                        const Offset(
                                      0,
                                      7,
                                    ),
                                  ),
                                ],
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .arrow_forward_rounded,
                                color:
                                    Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ====================================================
                        // PROVIDER NAME
                        // ====================================================

                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,
                          child: Text(
                            widget.label
                                .toUpperCase(),
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            textAlign:
                                TextAlign.left,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF15253A,
                              ),
                              fontSize: 34,
                              fontWeight:
                                  FontWeight.w900,
                              height: 1.08,
                              letterSpacing:
                                  0.3,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ====================================================
                        // NETWORK STATUS
                        // ====================================================

                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,
                          child:
                              _NetworkStatusBadge(
                            status:
                                widget
                                    .networkStatus,
                            label:
                                widget
                                    .networkLabel,
                          ),
                        ),

                        // ====================================================
                        // PROCESSING TIME
                        // ====================================================

                        if (widget
                            .processingTime
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 14,
                          ),

                          Align(
                            alignment:
                                Alignment
                                    .centerLeft,
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons
                                      .schedule_rounded,
                                  size: 23,
                                  color:
                                      Color(
                                    0xFF647187,
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                Flexible(
                                  child: Text(
                                    '${widget.processingLabel}: '
                                    '${_formatProcessingTime(
                                      context,
                                      widget.processingTime,
                                    )}',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF647187,
                                      ),
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(
                          height: 18,
                        ),

                        // ====================================================
                        // DECORATIVE LINE
                        // ====================================================

                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 7,
                              decoration:
                                  BoxDecoration(
                                color:
                                    widget
                                        .accentColor,
                                borderRadius:
                                    BorderRadius.circular(
                                  50,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Container(
                              width: 13,
                              height: 7,
                              decoration:
                                  BoxDecoration(
                                color:
                                    widget
                                        .accentColor
                                        .withOpacity(
                                  0.28,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // LOGO FROM API
  // ==========================================================================

  Widget _buildLogo() {
    if (widget.imageUrl.isEmpty) {
      return Icon(
        Icons
            .electric_bolt_rounded,
        size: 90,
        color:
            widget.accentColor,
      );
    }

    return Image.network(
      widget.imageUrl,
      fit:
          BoxFit.contain,
      loadingBuilder:
          (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Center(
          child:
              CircularProgressIndicator(
            strokeWidth: 3,
            color:
                widget.accentColor,
          ),
        );
      },
      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        debugPrint(
          'Failed to load electric logo: '
          '${widget.imageUrl}',
        );

        return Icon(
          Icons
              .electric_bolt_rounded,
          size: 90,
          color:
              widget.accentColor,
        );
      },
    );
  }
}

// ============================================================================
// NETWORK STATUS BADGE
// ============================================================================

class _NetworkStatusBadge
    extends StatelessWidget {
  final BillerStatus status;
  final String label;

  const _NetworkStatusBadge({
    required this.status,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    late final String statusText;

    late final Color backgroundColor;
    late final Color borderColor;
    late final Color foregroundColor;

    late final IconData icon;

    switch (status) {
      // ======================================================================
      // LOADING
      // ======================================================================

      case BillerStatus.loading:
        statusText =
            loc.networkStatusChecking;

        backgroundColor =
            const Color(
          0xFFF0F4F8,
        );

        borderColor =
            const Color(
          0xFFC7D2DE,
        );

        foregroundColor =
            const Color(
          0xFF536272,
        );

        icon =
            Icons.sync_rounded;

        break;

      // ======================================================================
      // HEALTHY
      // ======================================================================

      case BillerStatus.healthy:
        statusText =
            loc.networkStatusGood;

        backgroundColor =
            const Color(
          0xFFE2F8EC,
        );

        borderColor =
            const Color(
          0xFF78C99B,
        );

        foregroundColor =
            const Color(
          0xFF08783E,
        );

        icon =
            Icons
                .check_circle_rounded;

        break;

      // ======================================================================
      // INTERRUPTION
      // ======================================================================

      case BillerStatus.interruption:
        statusText =
            loc.networkStatusSlow;

        backgroundColor =
            const Color(
          0xFFFFF0D7,
        );

        borderColor =
            const Color(
          0xFFF1B95D,
        );

        foregroundColor =
            const Color(
          0xFFB75B00,
        );

        icon =
            Icons
                .warning_amber_rounded;

        break;

      // ======================================================================
      // UNAVAILABLE
      // ======================================================================

      case BillerStatus.unavailable:
        statusText =
            loc.networkStatusUnknown;

        backgroundColor =
            const Color(
          0xFFF1F1F1,
        );

        borderColor =
            const Color(
          0xFFC8C8C8,
        );

        foregroundColor =
            const Color(
          0xFF555555,
        );

        icon =
            Icons
                .help_outline_rounded;

        break;
    }

    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 54,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
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
          width: 1.7,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          if (status ==
              BillerStatus.loading)
            SizedBox(
              width: 24,
              height: 24,
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
              size: 26,
              color:
                  foregroundColor,
            ),

          const SizedBox(
            width: 9,
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
                letterSpacing:
                    0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SCROLL INDICATOR BUTTON
// ============================================================================

class _ScrollIndicatorButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool iconBelowText;

  const _ScrollIndicatorButton({
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
      size: 52,
      color:
          const Color(
        0xFF1469E8,
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
        fontSize: 17,
        fontWeight:
            FontWeight.w900,
      ),
    );

    return Material(
      color:
          Colors.white.withOpacity(
        0.96,
      ),
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      elevation: 5,
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
            horizontal: 13,
            vertical: 10,
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
              width: 2,
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