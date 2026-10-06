import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/modern_provider_card.dart';

// ============================================================================
// BROADBAND PRODUCT
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
// BROADBAND PAGE 3
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
  // PRODUCTS
  // ==========================================================================

  final List<_BroadbandProduct> _broadbandProducts = [];

  bool _catalogLoading = true;
  String? _catalogError;

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  final Map<String, ProviderNetworkStatus> _billerStatuses = {};

  final Map<String, String?> _lastUpdated = {};

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController _scrollController = ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = false;

  // ==========================================================================
  // CARD COLOURS
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

  @override
  void dispose() {
    _scrollController.removeListener(
      _handleScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD BROADBAND CATALOG
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
      // GET CATALOG
      // ======================================================================

      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      // ======================================================================
      // TREE
      // ======================================================================

      final dynamic treeRaw = catalog['tree'];

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
      // GROUPS
      // ======================================================================

      final dynamic groupsRaw = tree['groups'];

      if (groupsRaw is! List) {
        throw Exception(
          'Catalog groups not found.',
        );
      }

      // ======================================================================
      // FIND BROADBAND CATEGORY
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

        for (final dynamic categoryRaw in categoriesRaw) {
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

          for (final dynamic rawCode in productCodesRaw) {
            final String code =
                rawCode
                        ?.toString()
                        .trim()
                        .toUpperCase() ??
                    '';

            if (code.isEmpty) {
              continue;
            }

            if (!broadbandCodes.contains(code)) {
              broadbandCodes.add(
                code,
              );
            }
          }
        }
      }

      if (broadbandCodes.isEmpty) {
        debugPrint(
          'BROADBAND category found no product codes.',
        );
      }

      // ======================================================================
      // PRODUCTS
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
      // BUILD ACTIVE PRODUCTS
      // ======================================================================

      final List<_BroadbandProduct> loadedProducts = [];

      for (final String code in broadbandCodes) {
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
        // PROCESSING
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
        'Products: '
        '${_broadbandProducts.map((e) => e.code).toList()}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');

      // ======================================================================
      // NETWORK STATUS
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
  // LOAD NETWORK STATUSES
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

  Future<ProviderNetworkStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            ProviderNetworkStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final ProviderNetworkStatus status =
          result.isHealthy
              ? ProviderNetworkStatus.healthy
              : ProviderNetworkStatus.interruption;

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
              ProviderNetworkStatus.unavailable;
        });
      }

      return ProviderNetworkStatus.unavailable;
    }
  }

  // ==========================================================================
  // BROADBAND PROCESSING TIME
  //
  // Keeps existing special broadband translations:
  //
  // instant
  // 24_hours
  // 48_hours
  // 72_hours
  // 2_days
  // 3_days
  // 5_days
  // etc.
  // ==========================================================================

  String _formatBroadbandProcessingTime(
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
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handleBillerTap(
    _BroadbandProduct product,
  ) async {
    // ========================================================================
    // CHECK AGAIN WHEN USER SELECTS PROVIDER
    // ========================================================================

    final ProviderNetworkStatus status =
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
        ProviderNetworkStatus.interruption) {
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
        ProviderNetworkStatus.unavailable) {
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
    // ORIGINAL BROADBAND FLOW KEPT.
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
      context:
          context,

      barrierDismissible:
          false,

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
            width:
                800,

            padding:
                const EdgeInsets.fromLTRB(
              45,
              42,
              45,
              38,
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
                  0xFFF2A520,
                ),

                width:
                    3,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.25,
                  ),

                  blurRadius:
                      35,

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
                  width:
                      125,

                  height:
                      125,

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

                      width:
                          2,
                    ),
                  ),

                  child:
                      const Icon(
                    Icons.warning_amber_rounded,

                    color:
                        Color(
                      0xFFD87900,
                    ),

                    size:
                        78,
                  ),
                ),

                const SizedBox(
                  height:
                      28,
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

                    fontSize:
                        40,

                    fontWeight:
                        FontWeight.w900,

                    height:
                        1.1,
                  ),
                ),

                const SizedBox(
                  height:
                      24,
                ),

                // ============================================================
                // MESSAGE
                // ============================================================

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        28,

                    vertical:
                        25,
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

                      width:
                          1.5,
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

                      fontSize:
                          29,

                      height:
                          1.4,

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
                    height:
                        20,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.schedule_rounded,

                        size:
                            24,

                        color:
                            Color(
                          0xFF758399,
                        ),
                      ),

                      const SizedBox(
                        width:
                            8,
                      ),

                      Flexible(
                        child: Text(
                          '${loc.networkLastUpdated}: '
                          '${_lastUpdated[productCode]}',

                          textAlign:
                              TextAlign.center,

                          style:
                              const TextStyle(
                            fontSize:
                                21,

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
                  height:
                      36,
                ),

                // ============================================================
                // BUTTONS
                // ============================================================

                Row(
                  children: [
                    // ========================================================
                    // BACK
                    // ========================================================

                    Expanded(
                      child: SizedBox(
                        height:
                            78,

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
                            Icons.arrow_back_rounded,

                            size:
                                29,
                          ),

                          label: Text(
                            loc.backButton,

                            style:
                                const TextStyle(
                              fontSize:
                                  24,

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

                    // ========================================================
                    // CONTINUE
                    // ========================================================

                    Expanded(
                      child: SizedBox(
                        height:
                            78,

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
                            Icons.arrow_forward_rounded,

                            size:
                                29,
                          ),

                          label: Text(
                            loc.continueButton,

                            style:
                                const TextStyle(
                              fontSize:
                                  24,

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

                            elevation:
                                0,

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
  // SCROLL
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

    final bool hasScrollableContent =
        maxScroll > 10;

    final bool shouldShowScrollUp =
        hasScrollableContent &&
            currentScroll > 10;

    final bool shouldShowScrollDown =
        hasScrollableContent &&
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
        milliseconds:
            400,
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
        milliseconds:
            400,
      ),

      curve:
          Curves.easeOut,
    );
  }

  // ==========================================================================
  // SCROLL TO TOP
  // ==========================================================================

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,

      duration:
          const Duration(
        milliseconds:
            550,
      ),

      curve:
          Curves.easeOutCubic,
    );
  }

  // ==========================================================================
  // BUILD SCROLL ACTION
  // ==========================================================================

  Widget _buildScrollAction(
    AppLocalizations loc,
  ) {
    // ========================================================================
    // TOP
    // ========================================================================

    if (!showScrollUp &&
        showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'broadband-top-more',
        ),

        mode:
            _ScrollControlMode.more,

        label:
            loc.scrollViewMore,

        onPressed:
            _scrollDown,
      );
    }

    // ========================================================================
    // MIDDLE
    // ========================================================================

    if (showScrollUp &&
        showScrollDown) {
      return Row(
        key:
            const ValueKey(
          'broadband-middle-controls',
        ),

        mainAxisSize:
            MainAxisSize.min,

        children: [
          _ScrollDiscoveryControl(
            mode:
                _ScrollControlMode.up,

            label:
                loc.scrollUpShort,

            onPressed:
                _scrollUp,
          ),

          const SizedBox(
            width:
                22,
          ),

          _ScrollDiscoveryControl(
            mode:
                _ScrollControlMode.more,

            label:
                loc.scrollViewMore,

            onPressed:
                _scrollDown,
          ),
        ],
      );
    }

    // ========================================================================
    // BOTTOM
    // ========================================================================

    if (showScrollUp &&
        !showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'broadband-bottom-top',
        ),

        mode:
            _ScrollControlMode.top,

        label:
            loc.scrollBackTop,

        onPressed:
            _scrollToTop,
      );
    }

    return const SizedBox.shrink();
  }

  // ==========================================================================
  // BUILD PAGE
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

              fit:
                  BoxFit.cover,
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
            top:
                75,

            left:
                65,

            right:
                65,

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
            top:
                390,

            left:
                45,

            right:
                45,

            bottom:
                305,

            child:
                _buildProviderArea(
              loc,
            ),
          ),

          // ==================================================================
          // BOTTOM FADE
          // ==================================================================

          if (!_catalogLoading &&
              _broadbandProducts.isNotEmpty &&
              showScrollDown)
            Positioned(
              left:
                  35,

              right:
                  35,

              bottom:
                  270,

              height:
                  175,

              child:
                  IgnorePointer(
                child: Container(
                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.topCenter,

                      end:
                          Alignment.bottomCenter,

                      stops:
                          const [
                        0.0,
                        0.30,
                        0.68,
                        1.0,
                      ],

                      colors: [
                        Colors.white.withOpacity(
                          0.00,
                        ),

                        Colors.white.withOpacity(
                          0.14,
                        ),

                        Colors.white.withOpacity(
                          0.62,
                        ),

                        Colors.white.withOpacity(
                          0.95,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ==================================================================
          // MODERN SCROLL CONTROL
          // ==================================================================

          if (!_catalogLoading &&
              _broadbandProducts.isNotEmpty)
            Positioned(
              left:
                  0,

              right:
                  0,

              bottom:
                  270,

              child:
                  Center(
                child:
                    AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds:
                        250,
                  ),

                  switchInCurve:
                      Curves.easeOutCubic,

                  switchOutCurve:
                      Curves.easeInCubic,

                  transitionBuilder:
                      (
                    Widget child,
                    Animation<double>
                        animation,
                  ) {
                    return FadeTransition(
                      opacity:
                          animation,

                      child:
                          ScaleTransition(
                        scale:
                            Tween<double>(
                          begin:
                              0.94,

                          end:
                              1.0,
                        ).animate(
                          CurvedAnimation(
                            parent:
                                animation,

                            curve:
                                Curves.easeOutCubic,
                          ),
                        ),

                        child:
                            child,
                      ),
                    );
                  },

                  child:
                      _buildScrollAction(
                    loc,
                  ),
                ),
              ),
            ),

          // ==================================================================
          // BACK
          // ==================================================================

          Positioned(
            bottom:
                105,

            left:
                300,

            right:
                300,

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
            bottom:
                25,

            left:
                0,

            right:
                0,

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

                fontSize:
                    20,

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
    // LOADING
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

              width:
                  2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF33256D,
                ).withOpacity(
                  0.10,
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

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width:
                    100,

                height:
                    100,

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

                  size:
                      55,

                  color:
                      Color(
                    0xFF6255D9,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    22,
              ),

              Text(
                loc.billUnknownError,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize:
                      27,

                  fontWeight:
                      FontWeight.bold,

                  color:
                      Color(
                    0xFF33256D,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    25,
              ),

              SizedBox(
                height:
                    70,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _loadBroadbandCatalog,

                  icon:
                      const Icon(
                    Icons.refresh_rounded,

                    size:
                        28,
                  ),

                  label: Text(
                    loc.retryButton,

                    style:
                        const TextStyle(
                      fontSize:
                          23,

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
                      horizontal:
                          35,
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

              width:
                  2,
            ),
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              const Icon(
                Icons.router_outlined,

                size:
                    65,

                color:
                    Color(
                  0xFF60758D,
                ),
              ),

              const SizedBox(
                height:
                    20,
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

                  fontSize:
                      27,

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
    // DYNAMIC GRID
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

          width:
              1.5,
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

        thickness:
            11,

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
            right:
                24,

            bottom:
                145,
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

            // ==============================================================
            // ModernProviderCard default height = 510
            // ==============================================================

            mainAxisExtent:
                510,
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
        Container(
          width:
              double.infinity,

          padding:
              const EdgeInsets.symmetric(
            horizontal:
                35,

            vertical:
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
              30,
            ),

            border:
                Border.all(
              color:
                  const Color(
                0xFFDDD7FA,
              ),

              width:
                  2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF6255D9,
                ).withOpacity(
                  0.12,
                ),

                blurRadius:
                    24,

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
              Container(
                width:
                    100,

                height:
                    100,

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

                    width:
                        2,
                  ),
                ),

                child: Stack(
                  alignment:
                      Alignment.center,

                  children: [
                    const SizedBox(
                      width:
                          70,

                      height:
                          70,

                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            5,

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

                      size:
                          40,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width:
                    25,
              ),

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

                        fontSize:
                            30,

                        fontWeight:
                            FontWeight.w900,

                        height:
                            1.15,
                      ),
                    ),

                    const SizedBox(
                      height:
                          9,
                    ),

                    Text(
                      loc.providerLoadingSubtitle,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF6A7B90,
                        ),

                        fontSize:
                            20,

                        fontWeight:
                            FontWeight.w600,

                        height:
                            1.35,
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
              28,
        ),

        Row(
          children: [
            Expanded(
              child:
                  _buildLoadingProviderCard(),
            ),

            const SizedBox(
              width:
                  34,
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
  // LOADING CARD
  // ==========================================================================

  Widget _buildLoadingProviderCard() {
    return Container(
      height:
          510,

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

          width:
              2,
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF33256D,
            ).withOpacity(
              0.07,
            ),

            blurRadius:
                18,

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
            width:
                double.infinity,

            height:
                210,

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

          const SizedBox(
            height:
                28,
          ),

          Container(
            width:
                double.infinity,

            height:
                28,

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
            height:
                15,
          ),

          Container(
            width:
                170,

            height:
                22,

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

          const Spacer(),

          Container(
            width:
                210,

            height:
                54,

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
  //
  // Uses shared:
  //
  // lib/widgets/modern_provider_card.dart
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

    return ModernProviderCard(
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
              ProviderNetworkStatus.loading,

      networkLabel:
          loc.networkLabel,

      processingTime:
          product.processingTime,

      processingLabel:
          loc.processingTimeLabel,

      // ======================================================================
      // BROADBAND-SPECIFIC FORMATTER
      // ======================================================================

      processingTimeFormatter:
          _formatBroadbandProcessingTime,

      fallbackIcon:
          Icons.router_rounded,

      onPressed: () {
        _handleBillerTap(
          product,
        );
      },
    );
  }
}

// ============================================================================
// BROADBAND HEADER
// ============================================================================

class _ModernBroadbandHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernBroadbandHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color accentColor =
        Color(
      0xFF6255D9,
    );

    final loc =
        AppLocalizations.of(context)!;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        24,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.96,
        ),

        borderRadius:
            BorderRadius.circular(
          32,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD5E4F7,
          ),

          width:
              2,
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF173A66,
            ).withOpacity(
              0.14,
            ),

            blurRadius:
                30,

            offset:
                const Offset(
              0,
              12,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          // ==================================================================
          // ICON
          // ==================================================================

          Container(
            width:
                105,

            height:
                105,

            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,

                end:
                    Alignment.bottomRight,

                colors: [
                  Color(
                    0xFF493CB5,
                  ),

                  Color(
                    0xFF8B4FD0,
                  ),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      accentColor.withOpacity(
                    0.28,
                  ),

                  blurRadius:
                      20,

                  offset:
                      const Offset(
                    0,
                    8,
                  ),
                ),
              ],
            ),

            child:
                const Icon(
              Icons.router_rounded,

              color:
                  Colors.white,

              size:
                  56,
            ),
          ),

          const SizedBox(
            width:
                28,
          ),

          // ==================================================================
          // TEXT
          // ==================================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        18,

                    vertical:
                        7,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF0EDFF,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                  ),

                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      const Icon(
                        Icons.router_rounded,

                        size:
                            20,

                        color:
                            accentColor,
                      ),

                      const SizedBox(
                        width:
                            8,
                      ),

                      Flexible(
                        child: Text(
                          loc.billbroadbandButton
                              .toUpperCase(),

                          maxLines:
                              1,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            color:
                                accentColor,

                            fontSize:
                                17,

                            fontWeight:
                                FontWeight.w900,

                            letterSpacing:
                                1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height:
                      12,
                ),

                Text(
                  title.toUpperCase(),

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF122C4C,
                    ),

                    fontSize:
                        52,

                    fontWeight:
                        FontWeight.w900,

                    height:
                        1.02,

                    letterSpacing:
                        -0.8,
                  ),
                ),

                const SizedBox(
                  height:
                      9,
                ),

                Text(
                  subtitle.toUpperCase(),

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF607188,
                    ),

                    fontSize:
                        22,

                    fontWeight:
                        FontWeight.w600,

                    height:
                        1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width:
                24,
          ),

          // ==================================================================
          // RIGHT ACCENT
          // ==================================================================

          Container(
            width:
                8,

            height:
                105,

            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),

              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topCenter,

                end:
                    Alignment.bottomCenter,

                colors: [
                  Color(
                    0xFF493CB5,
                  ),

                  Color(
                    0xFF9A3CCE,
                  ),
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
// SCROLL CONTROL MODE
// ============================================================================

enum _ScrollControlMode {
  up,
  more,
  top,
}

// ============================================================================
// SCROLL CONTROL
// ============================================================================

class _ScrollDiscoveryControl
    extends StatefulWidget {
  final _ScrollControlMode mode;

  final String label;

  final VoidCallback onPressed;

  const _ScrollDiscoveryControl({
    super.key,
    required this.mode,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_ScrollDiscoveryControl> createState() =>
      _ScrollDiscoveryControlState();
}

class _ScrollDiscoveryControlState
    extends State<_ScrollDiscoveryControl> {
  bool _pressed = false;

  void _setPressed(
    bool value,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isUp =
        widget.mode ==
                _ScrollControlMode.up ||
            widget.mode ==
                _ScrollControlMode.top;

    final IconData arrow =
        isUp
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded;

    return AnimatedScale(
      scale:
          _pressed
              ? 0.96
              : 1.0,

      duration:
          const Duration(
        milliseconds:
            120,
      ),

      curve:
          Curves.easeOutCubic,

      child: Material(
        color:
            Colors.transparent,

        child: InkWell(
          onTap:
              widget.onPressed,

          onHighlightChanged:
              _setPressed,

          borderRadius:
              BorderRadius.circular(
            100,
          ),

          splashColor:
              const Color(
            0xFF6255D9,
          ).withOpacity(
            0.10,
          ),

          highlightColor:
              Colors.transparent,

          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds:
                  140,
            ),

            constraints:
                const BoxConstraints(
              minHeight:
                  88,
            ),

            padding:
                const EdgeInsets.fromLTRB(
              30,
              13,
              22,
              13,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.98,
              ),

              borderRadius:
                  BorderRadius.circular(
                100,
              ),

              border:
                  Border.all(
                color:
                    _pressed
                        ? const Color(
                            0xFF6255D9,
                          )
                        : const Color(
                            0xFFD5CFF0,
                          ),

                width:
                    _pressed
                        ? 2.5
                        : 1.7,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      const Color(
                    0xFF33256D,
                  ).withOpacity(
                    _pressed
                        ? 0.09
                        : 0.17,
                  ),

                  blurRadius:
                      _pressed
                          ? 8
                          : 20,

                  offset:
                      Offset(
                    0,

                    _pressed
                        ? 2
                        : 7,
                  ),
                ),
              ],
            ),

            child: Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                if (isUp) ...[
                  _ScrollArrowCircle(
                    icon:
                        arrow,

                    pressed:
                        _pressed,
                  ),

                  const SizedBox(
                    width:
                        14,
                  ),
                ],

                ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    minWidth:
                        88,

                    maxWidth:
                        190,
                  ),

                  child: FittedBox(
                    fit:
                        BoxFit.scaleDown,

                    child: Text(
                      widget.label
                          .toUpperCase(),

                      maxLines:
                          1,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF33256D,
                        ),

                        fontSize:
                            24,

                        fontWeight:
                            FontWeight.w900,

                        letterSpacing:
                            0.5,
                      ),
                    ),
                  ),
                ),

                if (!isUp) ...[
                  const SizedBox(
                    width:
                        14,
                  ),

                  _ScrollArrowCircle(
                    icon:
                        arrow,

                    pressed:
                        _pressed,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SCROLL ARROW CIRCLE
// ============================================================================

class _ScrollArrowCircle
    extends StatelessWidget {
  final IconData icon;

  final bool pressed;

  const _ScrollArrowCircle({
    required this.icon,
    required this.pressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds:
            140,
      ),

      width:
          66,

      height:
          66,

      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,

          end:
              Alignment.bottomRight,

          colors:
              pressed
                  ? const [
                      Color(
                        0xFF493CB5,
                      ),

                      Color(
                        0xFF6255D9,
                      ),
                    ]
                  : const [
                      Color(
                        0xFF6255D9,
                      ),

                      Color(
                        0xFF9A3CCE,
                      ),
                    ],
        ),

        shape:
            BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF6255D9,
            ).withOpacity(
              0.30,
            ),

            blurRadius:
                12,

            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Icon(
        icon,

        color:
            Colors.white,

        size:
            48,
      ),
    );
  }
}