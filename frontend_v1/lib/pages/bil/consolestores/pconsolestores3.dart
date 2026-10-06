import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/modern_provider_card.dart';

import 'package:frontend_v1/pages/bil/consolestores/pconsolestores4.dart';

// ============================================================================
// CONSOLE / APP STORE PRODUCT
//
// Products come dynamically from:
//
// /v2/catalog
//
// tree.groups
//      ↓
// categories
//      ↓
// category.id == CONSOLE_STORES
//      ↓
// product_codes
//      ↓
// products[productCode]
//
// Only:
// is_active == true
//
// is displayed.
// ============================================================================

class _ConsoleStoreProduct {
  final String code;
  final String name;
  final String imageUrl;
  final String processingTime;
  final String note;

  const _ConsoleStoreProduct({
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.processingTime,
    required this.note,
  });
}

// ============================================================================
// PAGE
// ============================================================================

class PCONSOLESTORES3PAGE extends StatefulWidget {
  const PCONSOLESTORES3PAGE({
    super.key,
  });

  @override
  State<PCONSOLESTORES3PAGE> createState() =>
      _PCONSOLESTORES3PAGEState();
}

// ============================================================================
// STATE
// ============================================================================

class _PCONSOLESTORES3PAGEState
    extends State<PCONSOLESTORES3PAGE> {
  // ==========================================================================
  // PRODUCTS
  // ==========================================================================

  final List<_ConsoleStoreProduct> _products = [];

  bool _catalogLoading = true;

  String? _catalogError;

  // ==========================================================================
  // NETWORK
  //
  // Shared ProviderNetworkStatus comes from:
  //
  // modern_provider_card.dart
  // ==========================================================================

  final Map<String, ProviderNetworkStatus> _statuses = {};

  final Map<String, String?> _lastUpdated = {};

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  bool showScrollUp = false;

  bool showScrollDown = false;

  // ==========================================================================
  // PAGE COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(
    0xFF3949AB,
  );

  static const Color _darkColor =
      Color(
    0xFF283593,
  );

  // ==========================================================================
  // DECORATIVE PROVIDER COLORS
  //
  // UI only.
  //
  // Product data itself is NOT hardcoded.
  // ==========================================================================

  static const List<Color> _accentColors = [
    Color(0xFF3949AB),
    Color(0xFFE65100),
    Color(0xFF1565C0),
    Color(0xFF7B1FA2),
    Color(0xFF00897B),
    Color(0xFFD81B60),
  ];

  static const List<Color> _lightAccentColors = [
    Color(0xFFE8EAF6),
    Color(0xFFFFEDE3),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE0F2F1),
    Color(0xFFFCE4EC),
  ];

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadCatalog();
      },
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
  // LOAD CATALOG
  // ==========================================================================

  Future<void> _loadCatalog() async {
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
      // GROUPS
      // ======================================================================

      final dynamic groupsRaw =
          tree['groups'];

      if (groupsRaw is! List) {
        throw Exception(
          'Catalog groups not found.',
        );
      }

      // ======================================================================
      // FIND CONSOLE_STORES
      // ======================================================================

      final List<String> consoleCodes = [];

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
          // ONLY CONSOLE & APP STORES
          // ==================================================================

          if (categoryId !=
              'CONSOLE_STORES') {
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

            if (!consoleCodes.contains(
              code,
            )) {
              consoleCodes.add(
                code,
              );
            }
          }
        }
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

      final List<_ConsoleStoreProduct>
          loadedProducts = [];

      for (final String code
          in consoleCodes) {
        final dynamic rawProduct =
            products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'Console store catalog product '
            'not found: $code',
          );

          continue;
        }

        final Map<String, dynamic> product =
            Map<String, dynamic>.from(
          rawProduct,
        );

        // ====================================================================
        // ACTIVE FILTER
        // ====================================================================

        if (product['is_active'] != true) {
          debugPrint(
            'Console store product inactive: '
            '$code',
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

        final String rawName =
            product['name']
                    ?.toString()
                    .trim() ??
                '';

        final String productName =
            rawName.isNotEmpty
                ? rawName
                : productCode;

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

        // ====================================================================
        // NOTE
        // ====================================================================

        final String note =
            product['note']
                    ?.toString()
                    .trim() ??
                '';

        loadedProducts.add(
          _ConsoleStoreProduct(
            code:
                productCode,

            name:
                productName,

            imageUrl:
                imageUrl,

            processingTime:
                processingTime,

            note:
                note,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      // ======================================================================
      // UPDATE SCREEN
      // ======================================================================

      setState(() {
        _products
          ..clear()
          ..addAll(
            loadedProducts,
          );

        _statuses.clear();

        _lastUpdated.clear();

        for (final _ConsoleStoreProduct product
            in loadedProducts) {
          _statuses[product.code] =
              ProviderNetworkStatus.loading;
        }

        _catalogLoading = false;

        _catalogError = null;
      });

      // ======================================================================
      // DEBUG
      // ======================================================================

      debugPrint('');

      debugPrint(
        '========================================',
      );

      debugPrint(
        'CONSOLE & APP STORES CATALOG LOADED',
      );

      debugPrint(
        '========================================',
      );

      debugPrint(
        'Products: '
        '${_products.map((e) => e.code).toList()}',
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
        'Console store catalog error: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _products.clear();

        _statuses.clear();

        _lastUpdated.clear();

        _catalogLoading = false;

        _catalogError =
            error.message;

        showScrollUp = false;

        showScrollDown = false;
      });
    }

    // =========================================================================
    // OTHER ERROR
    // =========================================================================

    catch (error, stackTrace) {
      debugPrint(
        'Unexpected console store catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _products.clear();

        _statuses.clear();

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
  // LOAD NETWORK STATUSES
  // ==========================================================================

  Future<void> _loadNetworkStatuses() async {
    if (_products.isEmpty) {
      return;
    }

    await Future.wait(
      _products.map(
        (
          _ConsoleStoreProduct product,
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

  Future<ProviderNetworkStatus>
      _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _statuses[productCode] =
            ProviderNetworkStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode:
            productCode,
      );

      final ProviderNetworkStatus status =
          result.isHealthy
              ? ProviderNetworkStatus.healthy
              : ProviderNetworkStatus.interruption;

      if (mounted) {
        setState(() {
          _statuses[productCode] =
              status;

          _lastUpdated[productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Console store network status error '
        'for $productCode: $error',
      );

      if (mounted) {
        setState(() {
          _statuses[productCode] =
              ProviderNetworkStatus.unavailable;
        });
      }

      return ProviderNetworkStatus.unavailable;
    }
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

      case 'link':
        return 'LINK';

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
  // PRODUCT TAP
  // ==========================================================================

  Future<void> _handleProductTap(
    _ConsoleStoreProduct product,
  ) async {
    // ========================================================================
    // REFRESH NETWORK BEFORE CONTINUE
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
        productName:
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
        context:
            context,

        builder:
            (
          BuildContext dialogContext,
        ) {
          return AlertDialog(
            title:
                Text(
              loc.alertTitle,

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            content:
                Text(
              loc.networkUnavailableMessage(
                product.name,
              ),
            ),

            actions: [
              TextButton(
                onPressed:
                    () {
                  Navigator.pop(
                    dialogContext,
                  );
                },

                child:
                    Text(
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
    // DEBUG
    // ========================================================================

    debugPrint('');

    debugPrint(
      '========================================',
    );

    debugPrint(
      'CONSOLE STORE SELECTED',
    );

    debugPrint(
      '========================================',
    );

    debugPrint(
      'Code: ${product.code}',
    );

    debugPrint(
      'Name: ${product.name}',
    );

    debugPrint(
      '========================================',
    );

    debugPrint('');

    // ========================================================================
    // PAGE 4
    // ========================================================================

    await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (_) =>
                PCONSOLESTORES4PAGE(
          productCode:
              product.code,

          productName:
              product.name,

          imageUrl:
              product.imageUrl,
        ),
      ),
    );
  }

  // ==========================================================================
  // INTERRUPTION WARNING
  // ==========================================================================

  Future<bool> _showInterruptionWarning({
    required String productName,
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
            horizontal:
                80,
          ),

          child:
              Container(
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

            child:
                Column(
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

                  child:
                      Text(
                    loc.networkInterruptionMessage(
                      productName,
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
                        child:
                            Text(
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
                      child:
                          SizedBox(
                        height:
                            78,

                        child:
                            OutlinedButton.icon(
                          onPressed:
                              () {
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

                          label:
                              Text(
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
                      child:
                          SizedBox(
                        height:
                            78,

                        child:
                            ElevatedButton.icon(
                          onPressed:
                              () {
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

                          label:
                              Text(
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
  // SCROLL ACTION
  // ==========================================================================

  Widget _buildScrollAction(
    AppLocalizations loc,
  ) {
    // ========================================================================
    // TOP
    //
    // LIHAT LAGI ↓
    // ========================================================================

    if (!showScrollUp &&
        showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'console-store-top-more',
        ),

        mode:
            _ScrollControlMode.more,

        label:
            loc.scrollViewMore,

        onPressed:
            _scrollDown,

        accentColor:
            _primaryColor,

        darkColor:
            _darkColor,
      );
    }

    // ========================================================================
    // MIDDLE
    //
    // ↑ KE ATAS + LIHAT LAGI ↓
    // ========================================================================

    if (showScrollUp &&
        showScrollDown) {
      return Row(
        key:
            const ValueKey(
          'console-store-middle',
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

            accentColor:
                _primaryColor,

            darkColor:
                _darkColor,
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

            accentColor:
                _primaryColor,

            darkColor:
                _darkColor,
          ),
        ],
      );
    }

    // ========================================================================
    // BOTTOM
    //
    // ↑ KEMBALI KE ATAS
    // ========================================================================

    if (showScrollUp &&
        !showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'console-store-bottom-top',
        ),

        mode:
            _ScrollControlMode.top,

        label:
            loc.scrollBackTop,

        onPressed:
            _scrollToTop,

        accentColor:
            _primaryColor,

        darkColor:
            _darkColor,
      );
    }

    return const SizedBox.shrink();
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
            top:
                82,

            left:
                65,

            right:
                65,

            child:
                _ModernPageHeader(
              title:
                  loc.consoleStoresTitle,

              subtitle:
                  loc.consoleStoresSubtitle,
            ),
          ),

          // ==================================================================
          // PRODUCT AREA
          // ==================================================================

          Positioned(
            top:
                400,

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
              _catalogError == null &&
              _products.isNotEmpty &&
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
                child:
                    Container(
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
              _catalogError == null &&
              _products.isNotEmpty)
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
                    Animation<double> animation,
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
              onPressed:
                  () {
                Navigator.pushReplacement(
                  context,

                  MaterialPageRoute(
                    builder:
                        (_) =>
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

            child:
                Center(
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
                      20,

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
      return _buildError(
        loc,
      );
    }

    // ========================================================================
    // EMPTY
    // ========================================================================

    if (_products.isEmpty) {
      return _buildEmptyState(
        loc,
      );
    }

    // ========================================================================
    // DYNAMIC GRID
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
          right:
              24,

          bottom:
              145,
        ),

        child:
            Column(
          children: [
            for (
              int index = 0;
              index < _products.length;
              index += 2
            )
              Padding(
                padding:
                    EdgeInsets.only(
                  bottom:
                      index + 2 <
                              _products.length
                          ? 36
                          : 0,
                ),

                child:
                    Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ========================================================
                    // LEFT
                    // ========================================================

                    Expanded(
                      child:
                          _buildConsoleCard(
                        product:
                            _products[
                          index
                        ],

                        index:
                            index,

                        loc:
                            loc,
                      ),
                    ),

                    const SizedBox(
                      width:
                          34,
                    ),

                    // ========================================================
                    // RIGHT
                    // ========================================================

                    Expanded(
                      child:
                          index + 1 <
                                  _products.length
                              ? _buildConsoleCard(
                                  product:
                                      _products[
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
  // SHARED MODERN PROVIDER CARD
  // ==========================================================================

  Widget _buildConsoleCard({
    required _ConsoleStoreProduct product,
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
      // ======================================================================
      // PRODUCT IMAGE
      // ======================================================================

      imageUrl:
          product.imageUrl,

      // ======================================================================
      // NAME
      // ======================================================================

      label:
          product.name,

      // ======================================================================
      // COLORS
      // ======================================================================

      accentColor:
          accentColor,

      lightAccentColor:
          lightAccentColor,

      // ======================================================================
      // NETWORK
      // ======================================================================

      networkStatus:
          _statuses[
                  product.code] ??
              ProviderNetworkStatus.loading,

      networkLabel:
          loc.networkLabel,

      // ======================================================================
      // PROCESSING TIME
      // ======================================================================

      processingTime:
          product.processingTime,

      processingLabel:
          loc.processingTimeLabel,

      processingTimeFormatter:
          _formatProcessingTime,

      // ======================================================================
      // FALLBACK
      // ======================================================================

      fallbackIcon:
          Icons.devices_other_rounded,

      // ======================================================================
      // TAP
      // ======================================================================

      onPressed:
          () {
        _handleProductTap(
          product,
        );
      },
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
        // MAIN LOADING PANEL
        // ====================================================================

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
                  _primaryColor.withOpacity(
                0.20,
              ),

              width:
                  2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    _primaryColor.withOpacity(
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

          child:
              Row(
            children: [
              // ==============================================================
              // ICON
              // ==============================================================

              Container(
                width:
                    100,

                height:
                    100,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE8EAF6,
                  ),

                  shape:
                      BoxShape.circle,

                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFC5CAE9,
                    ),

                    width:
                        2,
                  ),
                ),

                child:
                    Stack(
                  alignment:
                      Alignment.center,

                  children: [
                    SizedBox(
                      width:
                          70,

                      height:
                          70,

                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            5,

                        color:
                            _primaryColor,

                        backgroundColor:
                            _primaryColor.withOpacity(
                          0.12,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.devices_other_rounded,

                      color:
                          _primaryColor,

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
                child:
                    Column(
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
  // LOADING PROVIDER CARD
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
            0xFFDCE5EF,
          ),

          width:
              2,
        ),

        boxShadow: [
          BoxShadow(
            color:
                _primaryColor.withOpacity(
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

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ==================================================================
          // IMAGE PLACEHOLDER
          // ==================================================================

          Container(
            width:
                double.infinity,

            height:
                205,

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

          const SizedBox(
            height:
                28,
          ),

          // ==================================================================
          // NAME PLACEHOLDER
          // ==================================================================

          Container(
            width:
                double.infinity,

            height:
                28,

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
                0xFFEDF2F7,
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
      child:
          Container(
        width:
            680,

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

            width:
                2,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.10,
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
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width:
                  115,

              height:
                  115,

              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFEDEEFF,
                ),

                shape:
                    BoxShape.circle,
              ),

              child:
                  const Icon(
                Icons.cloud_off_rounded,

                size:
                    65,

                color:
                    _primaryColor,
              ),
            ),

            const SizedBox(
              height:
                  25,
            ),

            Text(
              loc.billUnknownError,

              textAlign:
                  TextAlign.center,

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

            const SizedBox(
              height:
                  14,
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

                fontSize:
                    24,

                fontWeight:
                    FontWeight.w600,

                height:
                    1.35,
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
                  80,

              child:
                  ElevatedButton.icon(
                onPressed:
                    _loadCatalog,

                icon:
                    const Icon(
                  Icons.refresh_rounded,

                  size:
                      30,
                ),

                label:
                    Text(
                  loc.retryButton,

                  style:
                      const TextStyle(
                    fontSize:
                        27,

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
      child:
          Container(
        width:
            680,

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
              0xFFD7E2F0,
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
            Container(
              width:
                  115,

              height:
                  115,

              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFE8EAF6,
                ),

                shape:
                    BoxShape.circle,
              ),

              child:
                  const Icon(
                Icons.storefront_rounded,

                color:
                    _primaryColor,

                size:
                    65,
              ),
            ),

            const SizedBox(
              height:
                  25,
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
                    30,

                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER
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
    final loc =
        AppLocalizations.of(context)!;

    const Color accentColor =
        Color(
      0xFF3949AB,
    );

    const Color darkAccent =
        Color(
      0xFF283593,
    );

    const Color lightAccent =
        Color(
      0xFF5C6BC0,
    );

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

      child:
          Row(
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
                  darkAccent,
                  lightAccent,
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
              Icons.devices_other_rounded,

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
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ============================================================
                // BADGE
                // ============================================================

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
                      0xFFE8EAF6,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                  ),

                  child:
                      Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      const Icon(
                        Icons.devices_other_rounded,

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
                        child:
                            Text(
                          loc.consoleStoresButton
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

                // ============================================================
                // TITLE
                // ============================================================

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

                // ============================================================
                // SUBTITLE
                // ============================================================

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
                        30,

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
                  darkAccent,
                  lightAccent,
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

  final Color accentColor;

  final Color darkColor;

  const _ScrollDiscoveryControl({
    super.key,
    required this.mode,
    required this.label,
    required this.onPressed,
    required this.accentColor,
    required this.darkColor,
  });

  @override
  State<_ScrollDiscoveryControl> createState() =>
      _ScrollDiscoveryControlState();
}

// ============================================================================
// SCROLL STATE
// ============================================================================

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
      _pressed =
          value;
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

      child:
          Material(
        color:
            Colors.transparent,

        child:
            InkWell(
          onTap:
              widget.onPressed,

          onHighlightChanged:
              _setPressed,

          borderRadius:
              BorderRadius.circular(
            100,
          ),

          splashColor:
              widget.accentColor.withOpacity(
            0.10,
          ),

          highlightColor:
              Colors.transparent,

          child:
              AnimatedContainer(
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
                        ? widget.accentColor
                        : widget.accentColor
                            .withOpacity(
                            0.30,
                          ),

                width:
                    _pressed
                        ? 2.5
                        : 1.7,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      widget.darkColor.withOpacity(
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

            child:
                Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                if (isUp) ...[
                  _ScrollArrowCircle(
                    icon:
                        arrow,

                    pressed:
                        _pressed,

                    accentColor:
                        widget.accentColor,

                    darkColor:
                        widget.darkColor,
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

                  child:
                      FittedBox(
                    fit:
                        BoxFit.scaleDown,

                    child:
                        Text(
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
                          0xFF25305F,
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

                    accentColor:
                        widget.accentColor,

                    darkColor:
                        widget.darkColor,
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
// SCROLL ARROW
// ============================================================================

class _ScrollArrowCircle
    extends StatelessWidget {
  final IconData icon;

  final bool pressed;

  final Color accentColor;

  final Color darkColor;

  const _ScrollArrowCircle({
    required this.icon,
    required this.pressed,
    required this.accentColor,
    required this.darkColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final Color lightColor =
        Color.lerp(
              accentColor,
              Colors.white,
              0.18,
            ) ??
            accentColor;

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
                  ? [
                      darkColor,
                      accentColor,
                    ]
                  : [
                      accentColor,
                      lightColor,
                    ],
        ),

        shape:
            BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color:
                accentColor.withOpacity(
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

      child:
          Icon(
        icon,

        color:
            Colors.white,

        size:
            48,
      ),
    );
  }
}