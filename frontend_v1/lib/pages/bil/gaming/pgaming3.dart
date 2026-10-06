import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/modern_provider_card.dart';

import 'package:frontend_v1/pages/bil/gaming/pgaming4.dart';

// ============================================================================
// GAMING PLATFORM MODEL
//
// Everything except decorative UI colours comes from:
//
// GET /v2/catalog
//
// GAMES
//   -> GAMING_PLATFORMS
// ============================================================================

class GamingPlatform {
  final String productCode;
  final String name;
  final String imageUrl;
  final String processingTime;

  final Color accentColor;
  final Color lightAccentColor;

  const GamingPlatform({
    required this.productCode,
    required this.name,
    required this.imageUrl,
    required this.processingTime,
    required this.accentColor,
    required this.lightAccentColor,
  });
}

// ============================================================================
// GAMING PAGE 3
// ============================================================================

class PGAMING3PAGE extends StatefulWidget {
  const PGAMING3PAGE({
    super.key,
  });

  @override
  State<PGAMING3PAGE> createState() =>
      _PGAMING3PAGEState();
}

// ============================================================================
// STATE
// ============================================================================

class _PGAMING3PAGEState
    extends State<PGAMING3PAGE> {
  // ==========================================================================
  // PLATFORM DATA
  // ==========================================================================

  final List<GamingPlatform> _platforms = [];

  // ==========================================================================
  // NETWORK STATUS
  //
  // Now uses ProviderNetworkStatus from:
  //
  // modern_provider_card.dart
  // ==========================================================================

  final Map<String, ProviderNetworkStatus>
      _platformStatuses = {};

  final Map<String, String?> _lastUpdated = {};

  // ==========================================================================
  // CATALOG
  // ==========================================================================

  bool _isLoadingCatalog = true;

  String? _catalogError;

  // ==========================================================================
  // CARD COLOURS
  //
  // Decorative only.
  //
  // Nothing is hardcoded to a specific provider.
  // New providers automatically reuse these colours.
  // ==========================================================================

  static const List<Color> _accentColors = [
    Color(0xFF7048E8),
    Color(0xFF00897B),
    Color(0xFFE65100),
    Color(0xFF3949AB),
    Color(0xFF455A64),
    Color(0xFF8E24AA),
    Color(0xFF1469E8),
    Color(0xFFD64D8B),
  ];

  static const List<Color> _lightAccentColors = [
    Color(0xFFEDE7FF),
    Color(0xFFE0F2F1),
    Color(0xFFFFE9DD),
    Color(0xFFE8EAF6),
    Color(0xFFECEFF1),
    Color(0xFFF3E5F5),
    Color(0xFFE5F0FF),
    Color(0xFFFFE6F2),
  ];

  // ==========================================================================
  // PAGE COLOURS
  // ==========================================================================

  static const Color _primaryColor =
      Color(
    0xFF7048E8,
  );

  static const Color _darkColor =
      Color(
    0xFF5630C7,
  );

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = false;

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
        _loadGamingPlatforms();
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
  // LOAD GAMING PLATFORMS
  //
  // GET /v2/catalog
  //
  // tree
  //   -> groups
  //      -> GAMES
  //         -> categories
  //            -> GAMING_PLATFORMS
  //               -> product_codes
  //
  // Products are then obtained from:
  //
  // products[code]
  //
  // IMPORTANT:
  //
  // Only is_active == true is displayed.
  // ==========================================================================

  Future<void> _loadGamingPlatforms() async {
    if (mounted) {
      setState(() {
        _isLoadingCatalog = true;

        _catalogError = null;

        showScrollUp = false;
        showScrollDown = false;
      });
    }

    try {
      // ======================================================================
      // CATALOG
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
      // GROUPS
      // ======================================================================

      final dynamic groupsRaw =
          tree['groups'];

      if (groupsRaw is! List) {
        throw Exception(
          'Catalog groups not found.',
        );
      }

      final List<String> gamingProductCodes = [];

      // ======================================================================
      // FIND:
      //
      // GAMES
      //   -> GAMING_PLATFORMS
      // ======================================================================

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

        if (groupId != 'GAMES') {
          continue;
        }

        // ====================================================================
        // CATEGORIES
        // ====================================================================

        final dynamic categoriesRaw =
            group['categories'];

        if (categoriesRaw is! List) {
          continue;
        }

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

          if (categoryId !=
              'GAMING_PLATFORMS') {
            continue;
          }

          // ==================================================================
          // PRODUCT CODES
          // ==================================================================

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

            if (!gamingProductCodes.contains(
              code,
            )) {
              gamingProductCodes.add(
                code,
              );
            }
          }
        }
      }

      // ======================================================================
      // BUILD ACTIVE PLATFORM LIST
      // ======================================================================

      final List<GamingPlatform>
          loadedPlatforms = [];

      for (
        int index = 0;
        index < gamingProductCodes.length;
        index++
      ) {
        final String catalogCode =
            gamingProductCodes[index];

        final dynamic rawProduct =
            products[catalogCode];

        if (rawProduct is! Map) {
          debugPrint(
            'Gaming product not found: '
            '$catalogCode',
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
            'Gaming product inactive: '
            '$catalogCode',
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
                catalogCode;

        // ====================================================================
        // NAME
        // ====================================================================

        final String rawName =
            product['name']
                    ?.toString()
                    .trim() ??
                '';

        final String name =
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
        // ADD
        // ====================================================================

        loadedPlatforms.add(
          GamingPlatform(
            productCode:
                productCode,

            name:
                name,

            imageUrl:
                imageUrl,

            processingTime:
                processingTime,

            accentColor:
                _accentColors[
              index %
                  _accentColors.length
            ],

            lightAccentColor:
                _lightAccentColors[
              index %
                  _lightAccentColors.length
            ],
          ),
        );
      }

      if (!mounted) {
        return;
      }

      // ======================================================================
      // UPDATE UI
      // ======================================================================

      setState(() {
        _platforms
          ..clear()
          ..addAll(
            loadedPlatforms,
          );

        _platformStatuses.clear();

        _lastUpdated.clear();

        for (final GamingPlatform platform
            in loadedPlatforms) {
          _platformStatuses[
                  platform.productCode] =
              ProviderNetworkStatus.loading;
        }

        _isLoadingCatalog = false;

        _catalogError = null;
      });

      // ======================================================================
      // DEBUG
      // ======================================================================

      debugPrint(
        'Gaming platforms loaded: '
        '${loadedPlatforms.map(
          (platform) =>
              platform.productCode,
        ).toList()}',
      );

      // ======================================================================
      // NETWORK STATUS
      // ======================================================================

      await Future.wait(
        loadedPlatforms.map(
          (
            GamingPlatform platform,
          ) {
            return _refreshNetworkStatus(
              platform.productCode,
            );
          },
        ),
      );

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
    // IIMMPACT ERROR
    // =========================================================================

    on IimmpactCatalogException catch (error) {
      debugPrint(
        'Gaming catalog error: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCatalog = false;

        _catalogError =
            error.message;

        _platforms.clear();

        _platformStatuses.clear();

        _lastUpdated.clear();

        showScrollUp = false;
        showScrollDown = false;
      });
    }

    // =========================================================================
    // OTHER ERROR
    // =========================================================================

    catch (error, stackTrace) {
      debugPrint(
        'Unexpected gaming catalog error: '
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
        _isLoadingCatalog = false;

        _catalogError =
            error.toString();

        _platforms.clear();

        _platformStatuses.clear();

        _lastUpdated.clear();

        showScrollUp = false;
        showScrollDown = false;
      });
    }
  }

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  Future<ProviderNetworkStatus>
      _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _platformStatuses[productCode] =
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
          _platformStatuses[
                  productCode] =
              status;

          _lastUpdated[
                  productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Gaming network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _platformStatuses[
                  productCode] =
              ProviderNetworkStatus.unavailable;
        });
      }

      return ProviderNetworkStatus.unavailable;
    }
  }

  // ==========================================================================
  // GAMING PROCESSING TIME FORMAT
  //
  // Preserves existing Gaming behaviour.
  // ==========================================================================

  String _formatGamingProcessingTime(
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
  // INTERRUPTION WARNING
  // ==========================================================================

  Future<bool> _showInterruptionWarning({
    required String platformName,
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
                      platformName,
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
                // ACTIONS
                // ============================================================

                Row(
                  children: [
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
  // PLATFORM TAP
  //
  // IMPORTANT:
  //
  // Active catalog products remain selectable even if the separate
  // network-status endpoint itself is unavailable.
  // ==========================================================================

  Future<void> _handlePlatformTap(
    GamingPlatform platform,
  ) async {
    final ProviderNetworkStatus status =
        await _refreshNetworkStatus(
      platform.productCode,
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
        platformName:
            platform.name,

        productCode:
            platform.productCode,
      );

      if (!shouldContinue) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    // ========================================================================
    // IMPORTANT:
    //
    // Do NOT stop on ProviderNetworkStatus.unavailable.
    //
    // Existing Gaming logic allows catalog-active products to continue even
    // if the separate network status request fails.
    // ========================================================================

    await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (_) =>
                PGAMING4PAGE(
          productCode:
              platform.productCode,

          platformName:
              platform.name,

          imageUrl:
              platform.imageUrl,
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
        _isLoadingCatalog) {
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
    // ========================================================================

    if (!showScrollUp &&
        showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'gaming-top-more',
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
    // ========================================================================

    if (showScrollUp &&
        showScrollDown) {
      return Row(
        key:
            const ValueKey(
          'gaming-middle-controls',
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
    // ========================================================================

    if (showScrollUp &&
        !showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'gaming-bottom-top',
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
                  loc.gamingPlatformButton,

              subtitle:
                  loc.gamingPlatformSupportingText,
            ),
          ),

          // ==================================================================
          // PLATFORM AREA
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
                _buildPlatformArea(
              loc,
            ),
          ),

          // ==================================================================
          // CONTENT FADE
          // ==================================================================

          if (!_isLoadingCatalog &&
              _catalogError == null &&
              _platforms.isNotEmpty &&
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
          // SCROLL CONTROL
          // ==================================================================

          if (!_isLoadingCatalog &&
              _catalogError == null &&
              _platforms.isNotEmpty)
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
  // PLATFORM AREA
  // ==========================================================================

  Widget _buildPlatformArea(
    AppLocalizations loc,
  ) {
    // ========================================================================
    // LOADING
    // ========================================================================

    if (_isLoadingCatalog) {
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

    if (_platforms.isEmpty) {
      return _buildEmptyState(
        loc,
      );
    }

    // ========================================================================
    // PROVIDER LIST
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
          children:
              _buildPlatformRows(
            loc,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PLATFORM ROWS
  // ==========================================================================

  List<Widget> _buildPlatformRows(
    AppLocalizations loc,
  ) {
    final List<Widget> widgets = [];

    for (
      int i = 0;
      i < _platforms.length;
      i += 2
    ) {
      final GamingPlatform left =
          _platforms[i];

      final GamingPlatform? right =
          i + 1 < _platforms.length
              ? _platforms[i + 1]
              : null;

      widgets.add(
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ================================================================
            // LEFT
            // ================================================================

            Expanded(
              child:
                  _buildGamingCard(
                platform:
                    left,

                loc:
                    loc,
              ),
            ),

            const SizedBox(
              width:
                  34,
            ),

            // ================================================================
            // RIGHT
            // ================================================================

            Expanded(
              child:
                  right == null
                      ? const SizedBox()
                      : _buildGamingCard(
                          platform:
                              right,

                          loc:
                              loc,
                        ),
            ),
          ],
        ),
      );

      if (i + 2 <
          _platforms.length) {
        widgets.add(
          const SizedBox(
            height:
                36,
          ),
        );
      }
    }

    return widgets;
  }

  // ==========================================================================
  // SHARED MODERN PROVIDER CARD
  // ==========================================================================

  Widget _buildGamingCard({
    required GamingPlatform platform,
    required AppLocalizations loc,
  }) {
    return ModernProviderCard(
      imageUrl:
          platform.imageUrl,

      label:
          platform.name,

      accentColor:
          platform.accentColor,

      lightAccentColor:
          platform.lightAccentColor,

      networkStatus:
          _platformStatuses[
                  platform.productCode] ??
              ProviderNetworkStatus.loading,

      networkLabel:
          loc.networkLabel,

      processingTime:
          platform.processingTime,

      processingLabel:
          loc.processingTimeLabel,

      // ======================================================================
      // GAMING FORMAT
      // ======================================================================

      processingTimeFormatter:
          _formatGamingProcessingTime,

      fallbackIcon:
          Icons.sports_esports_rounded,

      // ======================================================================
      // IMPORTANT:
      //
      // Preserve current Gaming behaviour.
      //
      // An ACTIVE catalog product can still be selected even if the separate
      // network-status endpoint fails.
      // ======================================================================

      allowTapWhenUnavailable:
          true,

      onPressed:
          () {
        _handlePlatformTap(
          platform,
        );
      },
    );
  }

  // ==========================================================================
  // LOADING
  // ==========================================================================

  Widget _buildLoading(
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        // ====================================================================
        // MAIN LOADING CARD
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
              Container(
                width:
                    100,

                height:
                    100,

                decoration:
                    BoxDecoration(
                  color:
                      _primaryColor.withOpacity(
                    0.10,
                  ),

                  shape:
                      BoxShape.circle,

                  border:
                      Border.all(
                    color:
                        _primaryColor.withOpacity(
                      0.18,
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
                      Icons.sports_esports_rounded,

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
  // LOADING CARD
  //
  // Matches ModernProviderCard height.
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
            0xFFE5E0F2,
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
          // FAKE LOGO
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
                0xFFEDEAF5,
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
          // FAKE NAME
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
                0xFFE3E0EB,
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
                0xFFF0EDF5,
              ),

              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
          ),

          const Spacer(),

          // ==================================================================
          // FAKE NETWORK
          // ==================================================================

          Container(
            width:
                210,

            height:
                54,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAE7F1,
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

                size:
                    65,
              ),
            ),

            const SizedBox(
              height:
                  25,
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

                fontSize:
                    35,

                fontWeight:
                    FontWeight.w900,

                height:
                    1.15,
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
                    _loadGamingPlatforms,

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
              0xFFD7D0F1,
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
                  0xFFF1EDFF,
                ),

                shape:
                    BoxShape.circle,
              ),

              child:
                  const Icon(
                Icons.sports_esports_rounded,

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
// GAMING HEADER
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
        Color(
      0xFF7048E8,
    );

    const Color darkAccent =
        Color(
      0xFF5630C7,
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

                  Color(
                    0xFF8B5CF6,
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
              Icons.sports_esports_rounded,

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
                      0xFFF1EDFF,
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
                        Icons.sports_esports_rounded,

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
                          loc.gamingPlatformButton
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
                  darkAccent,

                  Color(
                    0xFF8B5CF6,
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
// SCROLL MODE
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
// SCROLL CONTROL STATE
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
                          0xFF2F2454,
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