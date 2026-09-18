import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

// ============================================================================
// BROADBAND BILLER STATUS
// ============================================================================

enum BroadbandBillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

// ============================================================================
// BROADBAND PRODUCT
//
// Product information comes from:
//
// /v2/catalog
//
// tree.groups
//      ↓
// categories
//      ↓
// category.id == BROADBAND
//      ↓
// product_codes
//      ↓
// products[code]
// ============================================================================

class _BroadbandProduct {
  final String code;
  final String name;
  final String imageUrl;
  final String processingTime;
  final bool isActive;

  const _BroadbandProduct({
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.processingTime,
    required this.isActive,
  });
}

// ============================================================================
// BROADBAND BILL PROVIDER PAGE
// ============================================================================

class PBROADBANDBILL3PAGE extends StatefulWidget {
  const PBROADBANDBILL3PAGE({
    super.key,
  });

  @override
  State<PBROADBANDBILL3PAGE> createState() =>
      _PBROADBANDBILL3PAGEState();
}

class _PBROADBANDBILL3PAGEState
    extends State<PBROADBANDBILL3PAGE> {
  // ==========================================================================
  // PRODUCTS FROM CATALOG
  // ==========================================================================

  final List<_BroadbandProduct> _broadbandProducts = [];

  bool _catalogLoading = true;

  String? _catalogError;

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  final Map<String, BroadbandBillerStatus> _billerStatuses = {};

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
  // Decorative only.
  //
  // Provider identity does NOT depend on these.
  //
  // If API adds more providers, colors repeat automatically.
  // ==========================================================================

  static const List<Color> _accentColors = [
    Color(0xFF6255D9),
    Color(0xFF9A3CCE),
    Color(0xFF4E7CE5),
    Color(0xFF8B50C7),
    Color(0xFF5470C6),
    Color(0xFFB85FC6),
  ];

  static const List<Color> _lightAccentColors = [
    Color(0xFFECE9FF),
    Color(0xFFF4E6FC),
    Color(0xFFE8EEFF),
    Color(0xFFF2E9FC),
    Color(0xFFE9EDFA),
    Color(0xFFF8EAFB),
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
        _loadBroadbandCatalog();
      },
    );
  }

  // ==========================================================================
  // LOAD BROADBAND PROVIDERS FROM /v2/catalog
  //
  // We only identify category:
  //
  // BROADBAND
  //
  // Actual provider codes come from product_codes.
  // ==========================================================================

  Future<void> _loadBroadbandCatalog() async {
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
      // 4. FIND BROADBAND CATEGORY
      // ======================================================================

      final List<String> broadbandCodes = [];

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

          if (categoryId != 'BROADBAND') {
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

            if (!broadbandCodes.contains(
              code,
            )) {
              broadbandCodes.add(
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
      // 6. BUILD ACTIVE PRODUCTS
      // ======================================================================

      final List<_BroadbandProduct> loadedProducts = [];

      for (final String code
          in broadbandCodes) {
        final dynamic rawProduct =
            products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'Broadband product not found: $code',
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
            'Broadband product inactive: $code',
          );

          continue;
        }

        // ====================================================================
        // CODE
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
          _BroadbandProduct(
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
        _broadbandProducts
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
        'BROADBAND CATALOG LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Products: '
        '${_broadbandProducts.map((e) => e.code).toList()}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // 7. NETWORK STATUS
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
        'Broadband catalog error: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _broadbandProducts.clear();

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
        'Unexpected broadband catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _broadbandProducts.clear();

        _catalogLoading = false;

        _catalogError =
            error.toString();

        showScrollUp = false;
        showScrollDown = false;
      });
    }
  }

  // ==========================================================================
  // LOAD NETWORK STATUS FOR ALL PROVIDERS
  // ==========================================================================

  Future<void> _loadNetworkStatuses() async {
    if (_broadbandProducts.isEmpty) {
      return;
    }

    await Future.wait(
      _broadbandProducts.map(
        (
          _BroadbandProduct product,
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
  // ==========================================================================

  Future<BroadbandBillerStatus>
      _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            BroadbandBillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final BroadbandBillerStatus status =
          result.isHealthy
              ? BroadbandBillerStatus.healthy
              : BroadbandBillerStatus.interruption;

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
        'Broadband network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              BroadbandBillerStatus.unavailable;
        });
      }

      return BroadbandBillerStatus.unavailable;
    }
  }

  // ==========================================================================
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handleBillerTap(
    _BroadbandProduct product,
  ) async {
    final BroadbandBillerStatus status =
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
        BroadbandBillerStatus.interruption) {
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
        BroadbandBillerStatus.unavailable) {
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
    // ========================================================================

    final loc =
        AppLocalizations.of(context)!;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            P4BILPAGE(
          title:
              loc.broadbandAccountTitle,
          hint:
              loc.broadbandAccountHint,
          productCode:
              product.code,
          billerName:
              product.name,
          serviceType:
              BillServiceType.broadband,
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
                // ICON
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
                // BUTTONS
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
  // SCROLL LISTENER
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

    final bool newShowScrollUp =
        currentScroll > 10;

    final bool newShowScrollDown =
        maxScroll > 10 &&
        currentScroll <
            maxScroll - 10;

    if (showScrollUp != newShowScrollUp ||
        showScrollDown !=
            newShowScrollDown) {
      setState(() {
        showScrollUp =
            newShowScrollUp;

        showScrollDown =
            newShowScrollDown;
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
                      0.13,
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
            top: 75,
            left: 65,
            right: 65,
            child:
                _ModernBroadbandHeader(
              title:
                  loc.broadbandSelectionTitle,
              subtitle:
                  loc.pbil3Subtitle,
            ),
          ),

          // ==================================================================
          // PROVIDER AREA
          // ==================================================================

          Positioned(
            top: 390,
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
              _broadbandProducts.isNotEmpty &&
              showScrollUp)
            Positioned(
              right: 18,
              top: 355,
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
              _broadbandProducts.isNotEmpty &&
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
                Navigator.pushReplacement(
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
                  0xFF33256D,
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
                    0xFFF0ECFF,
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
                    0xFF6255D9,
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
                    0xFF33256D,
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
                      _loadBroadbandCatalog,
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
                      0xFF6255D9,
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
    // EMPTY
    // ========================================================================

    if (_broadbandProducts.isEmpty) {
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
                Icons.router_outlined,
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

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        16,
        14,
        20,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.20,
        ),
        borderRadius:
            BorderRadius.circular(
          36,
        ),
        border:
            Border.all(
          color:
              Colors.white.withOpacity(
            0.60,
          ),
          width: 1.5,
        ),
      ),
      child: Scrollbar(
        controller:
            _scrollController,
        thumbVisibility:
            true,
        trackVisibility:
            true,
        interactive:
            true,
        thickness: 11,
        radius:
            const Radius.circular(
          20,
        ),
        child:
            GridView.builder(
          controller:
              _scrollController,
          padding:
              const EdgeInsets.only(
            right: 24,
            bottom: 45,
          ),
          physics:
              const BouncingScrollPhysics(),
          itemCount:
              _broadbandProducts.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                2,
            crossAxisSpacing:
                34,
            mainAxisSpacing:
                36,
            childAspectRatio:
                1.0,
          ),
          itemBuilder:
              (
            context,
            index,
          ) {
            final _BroadbandProduct product =
                _broadbandProducts[
                  index
                ];

            return _buildBroadbandCard(
              product:
                  product,
              index:
                  index,
              loc:
                  loc,
            );
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // MODERN LOADING
  // ==========================================================================

  Widget _buildModernLoading(
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        // ====================================================================
        // LOADING CARD
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
                0xFFDDD7FA,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF6255D9,
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
              // ICON
              // ==============================================================

              Container(
                width: 100,
                height: 100,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF0EDFF,
                  ),
                  shape:
                      BoxShape.circle,
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFD9D2FA,
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
                          0xFF6255D9,
                        ),
                        backgroundColor:
                            Color(
                          0xFFE1DDF6,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.router_rounded,
                      color:
                          Color(
                        0xFF6255D9,
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
                          0xFF33256D,
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
        // SKELETONS
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
  // SKELETON CARD
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
            0xFFE2DFEF,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF33256D,
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
          // LOGO PLACEHOLDER
          // ==================================================================

          Container(
            width: 150,
            height: 115,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE9E7F5,
              ),
              borderRadius:
                  BorderRadius.circular(
                24,
              ),
            ),
          ),

          const Spacer(),

          // ==================================================================
          // TEXT PLACEHOLDER
          // ==================================================================

          Container(
            width:
                double.infinity,
            height: 25,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE1DFEC,
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
                0xFFEFEDF6,
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

          Container(
            width: 185,
            height: 48,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAE8F3,
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
  // BUILD BROADBAND CARD
  // ==========================================================================

  Widget _buildBroadbandCard({
    required _BroadbandProduct product,
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

    return _BroadbandProviderCard(
      product:
          product,

      accentColor:
          accentColor,

      lightAccentColor:
          lightAccentColor,

      networkStatus:
          _billerStatuses[
                  product.code] ??
              BroadbandBillerStatus.loading,

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
// MODERN BROADBAND HEADER
// ============================================================================

class _ModernBroadbandHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernBroadbandHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF6255D9);

    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFD5E4F7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A66).withOpacity(0.14),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          // ==========================================================
          // LEFT BROADBAND ICON
          // ==========================================================

          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF493CB5),
                  Color(0xFF8B4FD0),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.router_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(width: 28),

          // ==========================================================
          // EXISTING TEXT
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // EXISTING BROADBAND BADGE
                // ------------------------------------------------------

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDFF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.router_rounded,
                        size: 20,
                        color: accentColor,
                      ),

                      const SizedBox(width: 8),

                      Flexible(
                        child: Text(
                          loc.billbroadbandButton.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: accentColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ------------------------------------------------------
                // EXISTING TITLE
                // ------------------------------------------------------

                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF122C4C),
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1.02,
                    letterSpacing: -0.8,
                  ),
                ),

                const SizedBox(height: 9),

                // ------------------------------------------------------
                // EXISTING SUBTITLE
                // ------------------------------------------------------

                Text(
                  subtitle.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607188),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ==========================================================
          // RIGHT BROADBAND ACCENT
          // ==========================================================

          Container(
            width: 8,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF493CB5),
                  Color(0xFF9A3CCE),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BROADBAND PROVIDER CARD
// ============================================================================

class _BroadbandProviderCard
    extends StatefulWidget {
  final _BroadbandProduct product;

  final Color accentColor;
  final Color lightAccentColor;

  final BroadbandBillerStatus networkStatus;
  final String networkLabel;

  final String processingTime;
  final String processingLabel;

  final VoidCallback onPressed;

  const _BroadbandProviderCard({
    required this.product,
    required this.accentColor,
    required this.lightAccentColor,
    required this.networkStatus,
    required this.networkLabel,
    required this.processingTime,
    required this.processingLabel,
    required this.onPressed,
  });

  @override
  State<_BroadbandProviderCard> createState() =>
      _BroadbandProviderCardState();
}

// ============================================================================
// PROVIDER CARD STATE
// ============================================================================

class _BroadbandProviderCardState
    extends State<_BroadbandProviderCard> {
  bool _isPressed = false;

  void _setPressed(
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
  // PROCESSING TIME
  // ==========================================================================

  String _formatProcessingTime(
    BuildContext context,
    String value,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    final String normalized =
        value
            .toLowerCase()
            .trim();

    if (normalized == 'instant') {
      return loc.processingInstant;
    }

    if (normalized == '24_hours') {
      return loc.processing24Hours;
    }

    if (normalized == '3_days') {
      return loc.processing3Days;
    }

    // ========================================================================
    // GENERIC HOURS
    //
    // Example:
    //
    // 48_hours
    // 72_hours
    // ========================================================================

    if (normalized.endsWith(
      '_hours',
    )) {
      final String hours =
          normalized.replaceAll(
        '_hours',
        '',
      );

      return loc.broadbandUpdateWithinHours(
        hours,
      );
    }

    // ========================================================================
    // GENERIC DAYS
    //
    // Example:
    //
    // 2_days
    // 5_days
    // ========================================================================

    if (normalized.endsWith(
      '_days',
    )) {
      final String days =
          normalized.replaceAll(
        '_days',
        '',
      );

      return loc.broadbandUpdateWithinDays(
        days,
      );
    }

    return value.replaceAll(
      '_',
      ' ',
    );
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
            BroadbandBillerStatus.unavailable;

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTapDown:
          isEnabled
              ? (_) {
                  _setPressed(
                    true,
                  );
                }
              : null,

      onTapUp:
          isEnabled
              ? (_) {
                  _setPressed(
                    false,
                  );
                }
              : null,

      onTapCancel:
          isEnabled
              ? () {
                  _setPressed(
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
              38,
            ),

            border:
                Border.all(
              color:
                  _isPressed
                      ? widget
                          .accentColor
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
                              17,
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
                              28,
                          spreadRadius:
                              1,
                          offset:
                              const Offset(
                            0,
                            14,
                          ),
                        ),
                      ],
          ),

          child:
              ClipRRect(
            borderRadius:
                BorderRadius.circular(
              35,
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
                            ? 215
                            : 200,
                    height:
                        _isPressed
                            ? 215
                            : 200,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color:
                          widget
                              .lightAccentColor
                              .withOpacity(
                        0.92,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 92,
                  top: 105,
                  child: Container(
                    width: 34,
                    height: 34,
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
                    27,
                    27,
                    27,
                    25,
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
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 210,
                              height: 170,
                              padding:
                                  const EdgeInsets.all(
                                22,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                  32,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      widget
                                          .accentColor
                                          .withOpacity(
                                    0.20,
                                  ),
                                  width:
                                      1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black
                                            .withOpacity(
                                      0.07,
                                    ),
                                    blurRadius:
                                        15,
                                    offset:
                                        const Offset(
                                      0,
                                      7,
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
                              width: 54,
                              height: 54,
                              decoration:
                                  BoxDecoration(
                                color:
                                    widget
                                        .accentColor,
                                shape:
                                    BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        widget
                                            .accentColor
                                            .withOpacity(
                                      0.24,
                                    ),
                                    blurRadius:
                                        13,
                                    offset:
                                        const Offset(
                                      0,
                                      6,
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
                                size: 30,
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
                              Alignment.centerLeft,
                          child: Text(
                            widget
                                .product
                                .name
                                .toUpperCase(),
                            textAlign:
                                TextAlign.left,
                            maxLines: 3,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF15253A,
                              ),
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.w900,
                              height: 1.10,
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

                        SizedBox(
                          width:
                              double.infinity,
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
                                Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons
                                      .schedule_rounded,
                                  size: 22,
                                  color:
                                      Color(
                                    0xFF647187,
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                Expanded(
                                  child: Text(
                                    '${widget.processingLabel}: '
                                    '${_formatProcessingTime(
                                      context,
                                      widget.processingTime,
                                    )}',
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF647187,
                                      ),
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.w700,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(
                          height: 20,
                        ),

                        // ====================================================
                        // ACCENT BARS
                        // ====================================================

                        Row(
                          children: [
                            Container(
                              width: 58,
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
    if (widget.product.imageUrl.isEmpty) {
      return Icon(
        Icons.router_rounded,
        size: 85,
        color:
            widget.accentColor,
      );
    }

    return Image.network(
      widget.product.imageUrl,
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
          'Failed to load broadband logo: '
          '${widget.product.imageUrl}',
        );

        return Icon(
          Icons.router_rounded,
          size: 85,
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
  final BroadbandBillerStatus status;
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
      case BroadbandBillerStatus.loading:
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

      case BroadbandBillerStatus.healthy:
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

      case BroadbandBillerStatus.interruption:
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

      case BroadbandBillerStatus.unavailable:
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
        minHeight: 58,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color:
            backgroundColor,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              borderColor,
          width: 1.7,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          if (status ==
              BroadbandBillerStatus.loading)
            SizedBox(
              width: 26,
              height: 26,
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
              size: 28,
              color:
                  foregroundColor,
            ),

          const SizedBox(
            width: 8,
          ),

          Flexible(
            child: Text(
              '$label: $statusText',
              textAlign:
                  TextAlign.center,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  TextStyle(
                color:
                    foregroundColor,
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                height: 1.1,
                letterSpacing:
                    0.3,
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
        0xFF6255D9,
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