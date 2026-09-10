import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/pages/bil/idd/piddbill4.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

// ============================================================================
// BILLER STATUS
// ============================================================================

enum IddBillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

// ============================================================================
// IDD PRODUCT MODEL
// ============================================================================
//
// Product information comes directly from:
//
// /v2/catalog
//
// tree.groups
//      ↓
// category.id == IDD
//      ↓
// category.product_codes
//      ↓
// products[code]
//      ↓
// is_active == true
//
// Newly-added active IDD products automatically appear.
// ============================================================================

class _IddProduct {
  final String code;
  final String name;
  final String imageUrl;
  final String processingTime;

  const _IddProduct({
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.processingTime,
  });
}

// ============================================================================
// IDD PROVIDER PAGE
// ============================================================================

class PIDDBILL3PAGE extends StatefulWidget {
  const PIDDBILL3PAGE({
    super.key,
  });

  @override
  State<PIDDBILL3PAGE> createState() =>
      _PIDDBILL3PAGEState();
}

// ============================================================================
// IDD PROVIDER PAGE STATE
// ============================================================================

class _PIDDBILL3PAGEState
    extends State<PIDDBILL3PAGE> {
  // ==========================================================================
  // PRODUCTS
  // ==========================================================================

  final List<_IddProduct> _iddProducts = [];

  bool _catalogLoading = true;

  String? _catalogError;

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  final Map<String, IddBillerStatus>
      _billerStatuses = {};

  final Map<String, String?>
      _lastUpdated = {};

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = false;

  // ==========================================================================
  // DECORATIVE COLORS
  //
  // These are UI-only.
  //
  // They are NOT mapped to specific IDD providers.
  // If more providers are added, colors repeat automatically.
  // ==========================================================================

  static const List<Color> _accentColors = [
    Color(0xFF1469E8),
    Color(0xFF15946B),
    Color(0xFF7356D8),
    Color(0xFFE56B21),
    Color(0xFFD64D8B),
    Color(0xFF1687D9),
  ];

  static const List<Color> _lightAccentColors = [
    Color(0xFFE5F0FF),
    Color(0xFFE2F7EF),
    Color(0xFFEDE9FF),
    Color(0xFFFFECDD),
    Color(0xFFFFE6F2),
    Color(0xFFE3F3FF),
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
        _loadIddCatalog();
      },
    );
  }

  // ==========================================================================
  // LOAD IDD CATALOG
  // ==========================================================================

  Future<void> _loadIddCatalog() async {
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
      // 4. FIND IDD CATEGORY
      // ======================================================================

      final List<String> iddCodes = [];

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

          if (categoryId != 'IDD') {
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

            if (!iddCodes.contains(code)) {
              iddCodes.add(
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
      // 6. BUILD ACTIVE IDD PRODUCTS
      // ======================================================================

      final List<_IddProduct> loadedProducts = [];

      for (final String code in iddCodes) {
        final dynamic rawProduct =
            products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'IDD catalog product not found: $code',
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

        if (product['is_active'] != true) {
          debugPrint(
            'IDD product inactive: $code',
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
          _IddProduct(
            code: productCode,
            name: productName,
            imageUrl: imageUrl,
            processingTime: processingTime,
          ),
        );
      }

      // ======================================================================
      // 7. UPDATE UI
      // ======================================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _iddProducts
          ..clear()
          ..addAll(
            loadedProducts,
          );

        _billerStatuses.clear();
        _lastUpdated.clear();

        for (final _IddProduct product
            in loadedProducts) {
          _billerStatuses[
                  product.code] =
              IddBillerStatus.loading;
        }

        _catalogLoading = false;
        _catalogError = null;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'IDD CATALOG LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Products: '
        '${_iddProducts.map((e) => e.code).toList()}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // 8. NETWORK STATUS
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
        'IDD catalog error: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _iddProducts.clear();
        _billerStatuses.clear();
        _lastUpdated.clear();

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
        'Unexpected IDD catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _iddProducts.clear();
        _billerStatuses.clear();
        _lastUpdated.clear();

        _catalogLoading = false;

        _catalogError =
            error.toString();

        showScrollUp = false;
        showScrollDown = false;
      });
    }
  }

  // ==========================================================================
  // LOAD NETWORK STATUS
  // ==========================================================================

  Future<void> _loadNetworkStatuses() async {
    if (_iddProducts.isEmpty) {
      return;
    }

    await Future.wait(
      _iddProducts.map(
        (
          _IddProduct product,
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

  Future<IddBillerStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            IddBillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final IddBillerStatus status =
          result.isHealthy
              ? IddBillerStatus.healthy
              : IddBillerStatus.interruption;

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
        'IDD network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              IddBillerStatus.unavailable;
        });
      }

      return IddBillerStatus.unavailable;
    }
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                38,
              ),
              border: Border.all(
                color: const Color(
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
                    color: const Color(
                      0xFFFFF2D9,
                    ),
                    shape:
                        BoxShape.circle,
                    border: Border.all(
                      color:
                          const Color(
                        0xFFF2A520,
                      ).withOpacity(
                        0.30,
                      ),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
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
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 25,
                  ),
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFFFF9ED,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                    border: Border.all(
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
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handleBillerTap(
    _IddProduct product,
  ) async {
    final IddBillerStatus status =
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
        IddBillerStatus.interruption) {
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
        IddBillerStatus.unavailable) {
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

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PIDDBILL4PAGE(
          productCode:
              product.code,
          billerName:
              product.name,
        ),
      ),
    );
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
        _scrollController
            .position
            .maxScrollExtent;

    final double currentScroll =
        _scrollController.offset;

    final bool shouldShowScrollUp =
        currentScroll > 10;

    final bool shouldShowScrollDown =
        maxScroll > 10 &&
        currentScroll <
            maxScroll - 10;

    if (showScrollUp !=
            shouldShowScrollUp ||
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
                _ModernIddPageHeader(
              title:
                  loc.iddPageTitle,
              subtitle:
                  loc.iddPageSubtitle,
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
              _catalogError == null &&
              _iddProducts.isNotEmpty &&
              showScrollUp)
            Positioned(
              right: 18,
              top: 365,
              child:
                  _IddScrollIndicatorButton(
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
              _catalogError == null &&
              _iddProducts.isNotEmpty &&
              showScrollDown)
            Positioned(
              right: 18,
              bottom: 290,
              child:
                  _IddScrollIndicatorButton(
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
      return _buildLoading(
        loc,
      );
    }

    // ========================================================================
    // ERROR
    // ========================================================================

    if (_catalogError != null) {
      return _buildError(
        loc,
      );
    }

    // ========================================================================
    // EMPTY
    // ========================================================================

    if (_iddProducts.isEmpty) {
      return _buildEmptyState(
        loc,
      );
    }

    // ========================================================================
    // PROVIDERS
    // ========================================================================

    return Scrollbar(
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
            const EdgeInsets.only(
          right: 24,
          bottom: 55,
        ),
        child: Column(
          children: [
            for (
              int index = 0;
              index < _iddProducts.length;
              index += 2
            )
              Padding(
                padding:
                    EdgeInsets.only(
                  bottom:
                      index + 2 <
                              _iddProducts.length
                          ? 36
                          : 0,
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          _buildIddCard(
                        product:
                            _iddProducts[
                              index
                            ],
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
                                  _iddProducts
                                      .length
                              ? _buildIddCard(
                                  product:
                                      _iddProducts[
                                        index +
                                            1
                                      ],
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
  // ==========================================================================

  Widget _buildLoading(
    AppLocalizations loc,
  ) {
    const Color color =
        Color(0xFF1469E8);

    return Column(
      children: [
        // ====================================================================
        // MAIN LOADING CARD
        // ====================================================================

        Container(
          width: double.infinity,
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
            border: Border.all(
              color:
                  color.withOpacity(
                0.20,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    color.withOpacity(
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
              // ICON + SPINNER
              // ==============================================================

              Container(
                width: 100,
                height: 100,
                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(
                    0.10,
                  ),
                  shape:
                      BoxShape.circle,
                  border: Border.all(
                    color:
                        color.withOpacity(
                      0.18,
                    ),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment:
                      Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 5,
                        color: color,
                        backgroundColor:
                            color.withOpacity(
                          0.12,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons
                          .phone_in_talk_rounded,
                      color: color,
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
  // LOADING SKELETON
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
        border: Border.all(
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
              0xFF1469E8,
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

          Container(
            width: double.infinity,
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
          border: Border.all(
            color:
                const Color(
              0xFFE57373,
            ),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.10,
              ),
              blurRadius: 25,
              offset:
                  const Offset(
                0,
                12,
              ),
            ),
          ],
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 115,
              height: 115,
              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFFFEBEE,
                ),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.cloud_off_rounded,
                color:
                    Color(
                  0xFFD32F2F,
                ),
                size: 65,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            Text(
              loc.providerLoadError,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize: 35,
                fontWeight:
                    FontWeight.w900,
                height: 1.15,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              loc.providerLoadErrorSubtitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF657386,
                ),
                fontSize: 24,
                fontWeight:
                    FontWeight.w600,
                height: 1.35,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width: double.infinity,
              height: 80,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _loadIddCatalog,
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                  size: 30,
                ),
                label: Text(
                  loc.retryButton,
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
                      const Color(
                    0xFF1469E8,
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
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // EMPTY
  // ==========================================================================

  Widget _buildEmptyState(
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
          border: Border.all(
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
            Container(
              width: 115,
              height: 115,
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
                Icons
                    .phone_in_talk_rounded,
                color:
                    Color(
                  0xFF1469E8,
                ),
                size: 65,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            Text(
              loc.iddNoServices,
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
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD IDD CARD
  // ==========================================================================

  Widget _buildIddCard({
    required _IddProduct product,
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

    return _IddProviderCard(
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
              IddBillerStatus.loading,

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
// MODERN IDD HEADER
// ============================================================================

class _ModernIddPageHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernIddPageHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    const Color accentColor =
        Color(0xFF1469E8);

    return Column(
      children: [
        // ====================================================================
        // IDD BADGE
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
            border: Border.all(
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
                    .phone_in_talk_rounded,
                color:
                    accentColor,
                size: 25,
              ),

              const SizedBox(
                width: 9,
              ),

              Text(
                loc.iddHeaderLabel
                    .toUpperCase(),
                style:
                    const TextStyle(
                  color:
                      accentColor,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 1.4,
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
            border: Border.all(
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
// IDD PROVIDER CARD
// ============================================================================

class _IddProviderCard
    extends StatefulWidget {
  final String imageUrl;
  final String label;

  final VoidCallback onPressed;

  final Color accentColor;
  final Color lightAccentColor;

  final IddBillerStatus networkStatus;

  final String networkLabel;

  final String processingTime;

  final String processingLabel;

  const _IddProviderCard({
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
  State<_IddProviderCard> createState() =>
      _IddProviderCardState();
}

// ============================================================================
// IDD PROVIDER CARD STATE
// ============================================================================

class _IddProviderCardState
    extends State<_IddProviderCard> {
  bool _isPressed = false;

  // ==========================================================================
  // ENABLED
  // ==========================================================================

  bool get _isEnabled =>
      widget.networkStatus !=
      IddBillerStatus.unavailable;

  // ==========================================================================
  // PRESS STATE
  // ==========================================================================

  void _changePressedState(
    bool value,
  ) {
    if (!mounted ||
        !_isEnabled) {
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
            .trim()
            .toLowerCase();

    switch (normalized) {
      case 'instant':
        return loc.processingInstant;

      case '24_hours':
        return loc.processing24Hours;

      case '3_days':
        return loc.processing3Days;

      case 'pin':
        return 'PIN';

      default:
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
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTapDown:
          _isEnabled
              ? (_) {
                  _changePressedState(
                    true,
                  );
                }
              : null,

      onTapUp:
          _isEnabled
              ? (_) {
                  _changePressedState(
                    false,
                  );
                }
              : null,

      onTapCancel:
          _isEnabled
              ? () {
                  _changePressedState(
                    false,
                  );
                }
              : null,

      onTap:
          _isEnabled
              ? widget.onPressed
              : null,

      child: AnimatedScale(
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
              _isEnabled
                  ? 0.96
                  : 0.72,
            ),

            borderRadius:
                BorderRadius.circular(
              40,
            ),

            border: Border.all(
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

          child: ClipRRect(
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
                      milliseconds:
                          180,
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
                  child: Opacity(
                    opacity:
                        _isEnabled
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
                                border: Border.all(
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
                                    blurRadius:
                                        16,
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
                                milliseconds:
                                    160,
                              ),
                              transform:
                                  Matrix4
                                      .translationValues(
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
                                      0.25,
                                    ),
                                    blurRadius:
                                        14,
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
                        // NAME
                        // ====================================================

                        Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Text(
                            widget.label
                                .toUpperCase(),
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
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
                              Alignment.centerLeft,
                          child:
                              _IddNetworkStatusBadge(
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
  // LOGO
  // ==========================================================================

  Widget _buildLogo() {
    if (widget.imageUrl.isEmpty) {
      return Icon(
        Icons
            .phone_in_talk_rounded,
        size: 90,
        color:
            widget.accentColor,
      );
    }

    return Image.network(
      widget.imageUrl,
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
          'Failed to load IDD logo: '
          '${widget.imageUrl}',
        );

        return Icon(
          Icons
              .phone_in_talk_rounded,
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

class _IddNetworkStatusBadge
    extends StatelessWidget {
  final IddBillerStatus status;

  final String label;

  const _IddNetworkStatusBadge({
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
      case IddBillerStatus.loading:
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

      case IddBillerStatus.healthy:
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

      case IddBillerStatus.interruption:
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

      case IddBillerStatus.unavailable:
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
        border: Border.all(
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
              IddBillerStatus.loading)
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
              style: TextStyle(
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

class _IddScrollIndicatorButton
    extends StatelessWidget {
  final IconData icon;

  final String label;

  final VoidCallback onPressed;

  final bool iconBelowText;

  const _IddScrollIndicatorButton({
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
            border: Border.all(
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