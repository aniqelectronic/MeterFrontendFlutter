import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/pages/bil/telco/mobilereload/pmobilereload4.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/modern_provider_card.dart';

// ============================================================================
// MOBILE RELOAD PRODUCT MODEL
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
// MOBILE RELOAD PAGE 3
// ============================================================================

class PMOBILERELOAD3PAGE extends StatefulWidget {
  const PMOBILERELOAD3PAGE({
    super.key,
  });

  @override
  State<PMOBILERELOAD3PAGE> createState() =>
      _PMOBILERELOAD3PAGEState();
}

// ============================================================================
// STATE
// ============================================================================

class _PMOBILERELOAD3PAGEState
    extends State<PMOBILERELOAD3PAGE> {
  // ==========================================================================
  // PAGE STATE
  // ==========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  final List<_MobileReloadProduct> _products = [];

  // ==========================================================================
  // NETWORK
  // ==========================================================================

  final Map<String, ProviderNetworkStatus>
      _networkStatuses = {};

  final Map<String, String?> _lastUpdated = {};

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController _scrollController =
      ScrollController();

  bool _showScrollUp = false;
  bool _showScrollDown = false;

  // ==========================================================================
  // PAGE COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF7B4DCC);

  static const Color _darkColor =
      Color(0xFF56339B);

  static const Color _lightColor =
      Color(0xFFF1EAFF);

  // ==========================================================================
  // CARD COLORS
  // ==========================================================================

  static const List<Color> _accentColors = [
    Color(0xFF7B4DCC),
    Color(0xFF1469E8),
    Color(0xFF15946B),
    Color(0xFFE56B21),
    Color(0xFFD64D8B),
    Color(0xFF1687D9),
    Color(0xFFE59522),
    Color(0xFF7356D8),
    Color(0xFF128B75),
    Color(0xFFE53935),
  ];

  static const List<Color> _lightAccentColors = [
    Color(0xFFF1EAFF),
    Color(0xFFE5F0FF),
    Color(0xFFE2F7EF),
    Color(0xFFFFECDD),
    Color(0xFFFFE6F2),
    Color(0xFFE3F3FF),
    Color(0xFFFFF3D9),
    Color(0xFFEDE9FF),
    Color(0xFFE2F7F1),
    Color(0xFFFFE8E7),
  ];

  // ==========================================================================
  // TEMPORARILY HIDDEN PRODUCTS
  // ==========================================================================

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
  // LOAD MOBILE RELOAD PRODUCTS
  //
  // MOBILE_DATA
  // +
  // MOBILE_PREPAID
  // ==========================================================================

  Future<void> _loadMobileReloadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;

        _showScrollUp = false;
        _showScrollDown = false;
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
          'Catalog tree is missing.',
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

      // ======================================================================
      // ALLOWED CATEGORIES
      // ======================================================================

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

        for (final dynamic rawCode in codesRaw) {
          final String code =
              rawCode
                  .toString()
                  .trim()
                  .toUpperCase();

          if (code.isEmpty) {
            continue;
          }

          if (!productCodes.contains(code)) {
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
      // PRODUCTS
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

      // ======================================================================
      // BUILD PRODUCTS
      // ======================================================================

      for (final String productCode
          in productCodes) {
        // ====================================================================
        // HIDDEN PRODUCTS
        // ====================================================================

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
            'Mobile Reload product not found: '
            '$productCode',
          );

          continue;
        }

        final Map<String, dynamic> product =
            Map<String, dynamic>.from(
          rawProduct,
        );

        // ====================================================================
        // ACTIVE ONLY
        // ====================================================================

        final bool isActive =
            product['is_active'] == true;

        if (!isActive) {
          continue;
        }

        // ====================================================================
        // NAME
        // ====================================================================

        final String name =
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

        // ====================================================================
        // DENOMINATION
        // ====================================================================

        final String denomination =
            product['denomination']
                    ?.toString()
                    .trim() ??
                '';

        // ====================================================================
        // CURRENCY
        // ====================================================================

        final String currency =
            product['denomination_currency']
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
          _MobileReloadProduct(
            productCode:
                productCode,

            name:
                name,

            imageUrl:
                imageUrl,

            processingTime:
                processingTime,

            denomination:
                denomination,

            currency:
                currency,

            note:
                note,
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
        _products
          ..clear()
          ..addAll(
            loadedProducts,
          );

        _networkStatuses.clear();

        for (final product in loadedProducts) {
          _networkStatuses[
                  product.productCode] =
              ProviderNetworkStatus.loading;
        }

        _isLoading = false;
      });

      // ======================================================================
      // LOAD NETWORK STATUSES
      // ======================================================================

      await _loadInitialNetworkStatuses();

      if (!mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _handleScroll();
        },
      );

      // ======================================================================
      // DEBUG
      // ======================================================================

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
        'Categories: MOBILE_DATA + MOBILE_PREPAID',
      );
      debugPrint(
        'Products: ${_products.length}',
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

    // =========================================================================
    // IIMMPACT ERROR
    // =========================================================================

    on IimmpactCatalogException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _products.clear();

        _isLoading = false;

        _errorMessage =
            error.message;

        _showScrollUp = false;

        _showScrollDown = false;
      });
    }

    // =========================================================================
    // UNKNOWN ERROR
    // =========================================================================

    catch (error, stackTrace) {
      debugPrint(
        'Mobile Reload catalog error: '
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

        _isLoading = false;

        _errorMessage =
            error.toString();

        _showScrollUp = false;

        _showScrollDown = false;
      });
    }
  }

  // ==========================================================================
  // INITIAL NETWORK STATUS
  // ==========================================================================

  Future<void> _loadInitialNetworkStatuses() async {
    if (_products.isEmpty) {
      return;
    }

    await Future.wait(
      _products.map(
        (
          _MobileReloadProduct product,
        ) {
          return _refreshNetworkStatus(
            product.productCode,
          );
        },
      ),
    );
  }

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  Future<ProviderNetworkStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _networkStatuses[productCode] =
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
          _networkStatuses[productCode] =
              status;

          _lastUpdated[productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Mobile Reload network status error '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _networkStatuses[productCode] =
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

    // ========================================================================
    // INSTANT
    // ========================================================================

    if (normalized == 'instant') {
      return loc.processingInstant;
    }

    // ========================================================================
    // 24 HOURS
    // ========================================================================

    if (normalized == '24_hours') {
      return loc.processing24Hours;
    }

    // ========================================================================
    // 3 DAYS
    // ========================================================================

    if (normalized == '3_days') {
      return loc.processing3Days;
    }

    // ========================================================================
    // PIN
    // ========================================================================

    if (normalized == 'pin') {
      return 'PIN';
    }

    // ========================================================================
    // LINK
    // ========================================================================

    if (normalized == 'link') {
      return 'LINK';
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

      return loc.telcoUpdateWithinHours(
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
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handleProviderTap(
    _MobileReloadProduct product,
  ) async {
    // ========================================================================
    // REFRESH NETWORK
    // ========================================================================

    final ProviderNetworkStatus status =
        await _refreshNetworkStatus(
      product.productCode,
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
        providerName:
            product.name,

        productCode:
            product.productCode,
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
      'MOBILE RELOAD SELECTED',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'Code: ${product.productCode}',
    );
    debugPrint(
      'Name: ${product.name}',
    );
    debugPrint(
      'Denomination: ${product.denomination}',
    );
    debugPrint(
      'Currency: ${product.currency}',
    );
    debugPrint(
      'Processing: ${product.processingTime}',
    );
    debugPrint(
      '========================================',
    );
    debugPrint('');

    // ========================================================================
    // NEXT PAGE
    //
    // ORIGINAL FLOW KEPT.
    // ========================================================================

    await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (_) =>
                PMOBILERELOAD4PAGE(
          productCode:
              product.productCode,

          providerName:
              product.name,

          providerImageUrl:
              product.imageUrl,
        ),
      ),
    );
  }

  // ==========================================================================
  // INTERRUPTION WARNING
  // ==========================================================================

  Future<bool> _showInterruptionWarning({
    required String providerName,
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
                      providerName,
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
  // SCROLL HANDLER
  // ==========================================================================

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        !mounted ||
        _isLoading) {
      return;
    }

    final double current =
        _scrollController.offset;

    final double maximum =
        _scrollController
            .position
            .maxScrollExtent;

    final bool hasScrollableContent =
        maximum > 10;

    final bool showUp =
        hasScrollableContent &&
            current > 10;

    final bool showDown =
        hasScrollableContent &&
            current <
                maximum - 10;

    if (_showScrollUp != showUp ||
        _showScrollDown != showDown) {
      setState(() {
        _showScrollUp =
            showUp;

        _showScrollDown =
            showDown;
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
  // SCROLL TOP
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
    //
    // LIHAT LAGI
    // ========================================================================

    if (!_showScrollUp &&
        _showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'mobile-reload-top-more',
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
    // KE ATAS + LIHAT LAGI
    // ========================================================================

    if (_showScrollUp &&
        _showScrollDown) {
      return Row(
        key:
            const ValueKey(
          'mobile-reload-middle-controls',
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
    // KEMBALI KE ATAS
    // ========================================================================

    if (_showScrollUp &&
        !_showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'mobile-reload-bottom-top',
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
  // BUILD PAGE
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
          // HEADER
          // ==================================================================

          Positioned(
            top:
                45,

            left:
                55,

            right:
                55,

            child:
                _MobileReloadHeader(
              serviceLabel:
                  loc.mobileReloadServiceLabel,

              title:
                  loc.mobileReloadProviderTitle,

              subtitle:
                  loc.mobileReloadProviderSubtitle,
            ),
          ),

          // ==================================================================
          // CONTENT
          // ==================================================================

          Positioned(
            top:
                355,

            left:
                45,

            right:
                45,

            bottom:
                300,

            child:
                _isLoading
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
          // BOTTOM FADE
          // ==================================================================

          if (!_isLoading &&
              _errorMessage == null &&
              _products.isNotEmpty &&
              _showScrollDown)
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

          if (!_isLoading &&
              _errorMessage == null &&
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
            bottom:
                25,

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
  // LOADING
  // ==========================================================================

  Widget _buildLoading(
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
                  _primaryColor.withOpacity(
                0.22,
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
                      Icons.phone_android_rounded,

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

        Row(
          children: [
            Expanded(
              child:
                  _buildLoadingProviderCard(),
            ),

            const SizedBox(
              width:
                  30,
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
  // PRODUCTS
  // ==========================================================================

  Widget _buildProducts(
    AppLocalizations loc,
  ) {
    if (_products.isEmpty) {
      return Center(
        child:
            Container(
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

          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              const Icon(
                Icons.phone_android_rounded,

                size:
                    70,

                color:
                    _primaryColor,
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
          right:
              25,

          bottom:
              145,
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

  // ==========================================================================
  // PRODUCT ROWS
  // ==========================================================================

  List<Widget> _buildProductRows(
    AppLocalizations loc,
  ) {
    final List<Widget> rows = [];

    for (
      int i = 0;
      i < _products.length;
      i += 2
    ) {
      final _MobileReloadProduct left =
          _products[i];

      final _MobileReloadProduct? right =
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
                  _buildProductCard(
                product:
                    left,

                index:
                    i,

                loc:
                    loc,
              ),
            ),

            const SizedBox(
              width:
                  30,
            ),

            Expanded(
              child:
                  right == null
                      ? const SizedBox()
                      : _buildProductCard(
                          product:
                              right,

                          index:
                              i + 1,

                          loc:
                              loc,
                        ),
            ),
          ],
        ),
      );

      if (i + 2 < _products.length) {
        rows.add(
          const SizedBox(
            height:
                36,
          ),
        );
      }
    }

    return rows;
  }

  // ==========================================================================
  // MODERN PROVIDER CARD
  // ==========================================================================

  Widget _buildProductCard({
    required _MobileReloadProduct product,
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
          _networkStatuses[
                  product.productCode] ??
              ProviderNetworkStatus.loading,

      networkLabel:
          loc.networkLabel,

      processingTime:
          product.processingTime,

      processingLabel:
          loc.processingTimeLabel,

      processingTimeFormatter:
          _formatProcessingTime,

      fallbackIcon:
          Icons.phone_android_rounded,

      onPressed:
          () {
        _handleProviderTap(
          product,
        );
      },
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
            0xFFE3DDF0,
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
          Container(
            width:
                double.infinity,

            height:
                205,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFECE8F4,
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
                0xFFE2DEE9,
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

          Container(
            width:
                210,

            height:
                54,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAE6F1,
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
                    _loadMobileReloadProducts,

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
// SCROLL DISCOVERY CONTROL
//
// IMPORTANT:
// Colors are passed into this widget.
//
// It no longer accesses _primaryColor or _darkColor directly.
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
                        : widget.accentColor.withOpacity(
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
                // ============================================================
                // LEFT ARROW
                // ============================================================

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

                // ============================================================
                // LABEL
                // ============================================================

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

                // ============================================================
                // RIGHT ARROW
                // ============================================================

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
//
// IMPORTANT:
// Colors are also passed here.
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

// ============================================================================
// MOBILE RELOAD HEADER
// ============================================================================

class _MobileReloadHeader
    extends StatelessWidget {
  final String serviceLabel;

  final String title;

  final String subtitle;

  const _MobileReloadHeader({
    required this.serviceLabel,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color accentColor =
        Color(
      0xFF7B4DCC,
    );

    const Color darkAccent =
        Color(
      0xFF56339B,
    );

    const Color lightAccent =
        Color(
      0xFF8C61D7,
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
              Icons.signal_cellular_alt_rounded,

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
                      0xFFF1EAFF,
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
                        Icons.phone_android_rounded,

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
                          serviceLabel.toUpperCase(),

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
                  subtitle,

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