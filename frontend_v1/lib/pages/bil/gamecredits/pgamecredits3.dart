import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';

import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/modern_provider_card.dart';

import 'package:frontend_v1/pages/bil/gamecredits/pgamecredits4.dart';

// ============================================================================
// GAME CREDIT PRODUCT
// ============================================================================
//
// Product data:
//
// /v2/catalog
//
// GAMES
//    ↓
// GAME_CREDITS
//    ↓
// product_codes
//    ↓
// products[code]
//    ↓
// is_active == true
//
// Newly-added active products automatically appear.
// ============================================================================

class _GameCreditProduct {
  final String code;
  final String name;
  final String imageUrl;
  final String processingTime;
  final String note;

  const _GameCreditProduct({
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

class PGAMECREDITS3PAGE extends StatefulWidget {
  const PGAMECREDITS3PAGE({
    super.key,
  });

  @override
  State<PGAMECREDITS3PAGE> createState() =>
      _PGAMECREDITS3PAGEState();
}

// ============================================================================
// STATE
// ============================================================================

class _PGAMECREDITS3PAGEState
    extends State<PGAMECREDITS3PAGE> {
  // ==========================================================================
  // PRODUCTS
  // ==========================================================================

  final List<_GameCreditProduct> _products = [];

  bool _catalogLoading = true;

  String? _catalogError;

  // ==========================================================================
  // NETWORK
  //
  // Shared status from ModernProviderCard.
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
  // SEARCH
  // ==========================================================================

  String _searchQuery = '';

  // ==========================================================================
  // PAGE COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(
    0xFF009688,
  );

  static const Color _darkColor =
      Color(
    0xFF00695C,
  );

  // ==========================================================================
  // DECORATIVE PROVIDER COLORS
  //
  // UI only.
  // New providers reuse the palette automatically.
  // ==========================================================================

  static const List<Color> _accentColors = [
    Color(0xFF009688),
    Color(0xFF7356D8),
    Color(0xFFE56B21),
    Color(0xFFD64D8B),
    Color(0xFF1469E8),
    Color(0xFF15946B),
  ];

  static const List<Color> _lightAccentColors = [
    Color(0xFFE0F5F2),
    Color(0xFFEDE9FF),
    Color(0xFFFFECDD),
    Color(0xFFFFE6F2),
    Color(0xFFE3F0FF),
    Color(0xFFE2F7EF),
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
  // LOAD GAME CREDITS CATALOG
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
      // FIND GAME_CREDITS
      // ======================================================================

      final List<String> gameCreditCodes = [];

      for (final dynamic groupRaw in groupsRaw) {
        if (groupRaw is! Map) {
          continue;
        }

        final Map<String, dynamic> group =
            Map<String, dynamic>.from(
          groupRaw,
        );

        final String groupId =
            group['id']
                    ?.toString()
                    .trim()
                    .toUpperCase() ??
                '';

        // ====================================================================
        // GAMES GROUP ONLY
        // ====================================================================

        if (groupId != 'GAMES') {
          continue;
        }

        final dynamic categoriesRaw =
            group['categories'];

        if (categoriesRaw is! List) {
          continue;
        }

        // ====================================================================
        // GAME_CREDITS CATEGORY
        // ====================================================================

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

          if (categoryId !=
              'GAME_CREDITS') {
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

            if (!gameCreditCodes.contains(
              code,
            )) {
              gameCreditCodes.add(
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

      final List<_GameCreditProduct>
          loadedProducts = [];

      for (final String code
          in gameCreditCodes) {
        final dynamic rawProduct =
            products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'Game Credit catalog product '
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
            'Game Credit product inactive: '
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
          _GameCreditProduct(
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
      // UPDATE UI
      // ======================================================================

      setState(() {
        _products
          ..clear()
          ..addAll(
            loadedProducts,
          );

        _statuses.clear();

        _lastUpdated.clear();

        for (final _GameCreditProduct product
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
        'GAME CREDITS CATALOG LOADED',
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
      // NETWORK
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
        'Game Credits catalog error: '
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
    // UNKNOWN ERROR
    // =========================================================================

    catch (error, stackTrace) {
      debugPrint(
        'Unexpected Game Credits catalog error: '
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
          _GameCreditProduct product,
        ) {
          return _refreshNetworkStatus(
            product.code,
          );
        },
      ),
    );
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
        'Game Credit network status error '
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

  String _formatGameCreditProcessingTime(
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
                // WARNING ICON
                // ============================================================

                Container(
                  width:
                      125,

                  height:
                      125,

                  decoration:
                      const BoxDecoration(
                    color:
                        Color(
                      0xFFFFF2D9,
                    ),

                    shape:
                        BoxShape.circle,
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
                      const EdgeInsets.all(
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
  // PRODUCT TAP
  // ==========================================================================

  Future<void> _handleProductTap(
    _GameCreditProduct product,
  ) async {
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
      final bool continuePurchase =
          await _showInterruptionWarning(
        productName:
            product.name,

        productCode:
            product.code,
      );

      if (!continuePurchase) {
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
    // PAGE 4
    // ========================================================================

    await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (_) =>
                PGAMECREDITS4PAGE(
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
  // FILTERED PRODUCTS
  // ==========================================================================

  List<_GameCreditProduct> get _filteredProducts {
    final String query =
        _searchQuery
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return _products;
    }

    return _products.where(
      (
        _GameCreditProduct product,
      ) {
        return product.name
                .toLowerCase()
                .contains(
                  query,
                ) ||
            product.code
                .toLowerCase()
                .contains(
                  query,
                );
      },
    ).toList();
  }

  // ==========================================================================
  // APPLY SEARCH
  // ==========================================================================

  void _applySearchQuery(
    String value,
  ) {
    setState(() {
      _searchQuery =
          value.trim();

      showScrollUp = false;

      showScrollDown = false;
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            0,
          );
        }

        _handleScroll();
      },
    );
  }

  // ==========================================================================
  // SEARCH KEYBOARD
  // ==========================================================================

  Future<void> _openSearchKeyboard(
    AppLocalizations loc,
  ) async {
    String draft =
        _searchQuery;

    const List<List<String>> keyboardRows = [
      [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '0',
      ],
      [
        'Q',
        'W',
        'E',
        'R',
        'T',
        'Y',
        'U',
        'I',
        'O',
        'P',
      ],
      [
        'A',
        'S',
        'D',
        'F',
        'G',
        'H',
        'J',
        'K',
        'L',
      ],
      [
        'Z',
        'X',
        'C',
        'V',
        'B',
        'N',
        'M',
      ],
    ];

    await showDialog<void>(
      context:
          context,

      barrierDismissible:
          false,

      builder:
          (
        BuildContext dialogContext,
      ) {
        return StatefulBuilder(
          builder:
              (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            // ================================================================
            // ADD
            // ================================================================

            void addCharacter(
              String value,
            ) {
              setDialogState(() {
                draft += value;
              });
            }

            // ================================================================
            // BACKSPACE
            // ================================================================

            void backspace() {
              if (draft.isEmpty) {
                return;
              }

              setDialogState(() {
                draft =
                    draft.substring(
                  0,
                  draft.length - 1,
                );
              });
            }

            // ================================================================
            // CLEAR
            // ================================================================

            void clearAll() {
              setDialogState(() {
                draft = '';
              });
            }

            return Dialog(
              backgroundColor:
                  Colors.transparent,

              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal:
                    80,

                vertical:
                    24,
              ),

              child:
                  Container(
                width:
                    1000,

                height:
                    920,

                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
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
                        const Color(
                      0xFFBFE4DF,
                    ),

                    width:
                        2,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(
                        0.24,
                      ),

                      blurRadius:
                          38,

                      offset:
                          const Offset(
                        0,
                        18,
                      ),
                    ),
                  ],
                ),

                child:
                    SingleChildScrollView(
                  child:
                      Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      // ======================================================
                      // HEADER
                      // ======================================================

                      Row(
                        children: [
                          Container(
                            width:
                                70,

                            height:
                                70,

                            decoration:
                                const BoxDecoration(
                              gradient:
                                  LinearGradient(
                                begin:
                                    Alignment.topLeft,

                                end:
                                    Alignment.bottomRight,

                                colors: [
                                  Color(
                                    0xFF00695C,
                                  ),

                                  Color(
                                    0xFF26A69A,
                                  ),
                                ],
                              ),

                              shape:
                                  BoxShape.circle,
                            ),

                            child:
                                const Icon(
                              Icons.search_rounded,

                              color:
                                  Colors.white,

                              size:
                                  38,
                            ),
                          ),

                          const SizedBox(
                            width:
                                20,
                          ),

                          Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Text(
                                  loc.providerSearchTitle
                                      .toUpperCase(),

                                  style:
                                      const TextStyle(
                                    color:
                                        Color(
                                      0xFF122C4C,
                                    ),

                                    fontSize:
                                        39,

                                    fontWeight:
                                        FontWeight.w900,

                                    height:
                                        1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height:
                            24,
                      ),

                      // ======================================================
                      // SEARCH DISPLAY
                      // ======================================================

                      Container(
                        width:
                            double.infinity,

                        constraints:
                            const BoxConstraints(
                          minHeight:
                              104,
                        ),

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              24,

                          vertical:
                              18,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFF5FAFA,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),

                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFF8FCFC7,
                            ),

                            width:
                                2,
                          ),
                        ),

                        child:
                            Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,

                              color:
                                  Color(
                                0xFF00796B,
                              ),

                              size:
                                  32,
                            ),

                            const SizedBox(
                              width:
                                  15,
                            ),

                            Expanded(
                              child:
                                  Row(
                                children: [
                                  Flexible(
                                    child:
                                        Text(
                                      draft.isEmpty
                                          ? loc.providerSearchHint
                                          : draft,

                                      maxLines:
                                          2,

                                      overflow:
                                          TextOverflow.ellipsis,

                                      style:
                                          TextStyle(
                                        color:
                                            draft.isEmpty
                                                ? const Color(
                                                    0xFF8292A5,
                                                  )
                                                : const Color(
                                                    0xFF15253A,
                                                  ),

                                        fontSize:
                                            35,

                                        fontWeight:
                                            FontWeight.w800,

                                        height:
                                            1.2,
                                      ),
                                    ),
                                  ),

                                  // ==========================================
                                  // CURSOR ONLY AFTER TYPING
                                  // ==========================================

                                  if (draft.isNotEmpty) ...[
                                    const SizedBox(
                                      width:
                                          1,
                                    ),

                                    Container(
                                      width:
                                          3,

                                      height:
                                          40,

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xFF009688,
                                        ),

                                        borderRadius:
                                            BorderRadius.circular(
                                          10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height:
                            22,
                      ),

                      // ======================================================
                      // KEYBOARD
                      // ======================================================

                      ...keyboardRows.map(
                        (
                          List<String> row,
                        ) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom:
                                  12,
                            ),

                            child:
                                Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [
                                for (
                                  int index = 0;
                                  index < row.length;
                                  index++
                                ) ...[
                                  _SearchKeyboardKey(
                                    label:
                                        row[index],

                                    onTap:
                                        () {
                                      addCharacter(
                                        row[index],
                                      );
                                    },
                                  ),

                                  if (index <
                                      row.length - 1)
                                    const SizedBox(
                                      width:
                                          8,
                                    ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height:
                            30,
                      ),

                      // ======================================================
                      // UTILITIES
                      // ======================================================

                      Row(
                        children: [
                          Expanded(
                            flex:
                                2,

                            child:
                                _SearchUtilityButton(
                              icon:
                                  Icons.space_bar_rounded,

                              label:
                                  '',

                              onTap:
                                  () {
                                addCharacter(
                                  ' ',
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width:
                                12,
                          ),

                          Expanded(
                            flex:
                                3,

                            child:
                                _SearchUtilityButton(
                              icon:
                                  Icons.backspace_outlined,

                              label:
                                  loc.keyboardBackspace,

                              onTap:
                                  backspace,
                            ),
                          ),

                          const SizedBox(
                            width:
                                12,
                          ),

                          Expanded(
                            flex:
                                3,

                            child:
                                _SearchUtilityButton(
                              icon:
                                  Icons.delete_sweep_outlined,

                              label:
                                  loc.keyboardClearAll,

                              onTap:
                                  clearAll,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height:
                            24,
                      ),

                      // ======================================================
                      // ACTIONS
                      // ======================================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                SizedBox(
                              height:
                                  92,

                              child:
                                  OutlinedButton.icon(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                    dialogContext,
                                  );
                                },

                                icon:
                                    const Icon(
                                  Icons.close_rounded,

                                  size:
                                      34,
                                ),

                                label:
                                    Text(
                                  loc.close.toUpperCase(),

                                  style:
                                      const TextStyle(
                                    fontSize:
                                        29,

                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),

                                style:
                                    OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color(
                                    0xFF31445A,
                                  ),

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFFBBC8D6,
                                    ),

                                    width:
                                        2,
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width:
                                18,
                          ),

                          Expanded(
                            child:
                                SizedBox(
                              height:
                                  92,

                              child:
                                  ElevatedButton.icon(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                    dialogContext,
                                  );

                                  _applySearchQuery(
                                    draft,
                                  );
                                },

                                icon:
                                    const Icon(
                                  Icons.search_rounded,

                                  size:
                                      34,
                                ),

                                label:
                                    Text(
                                  loc.providerSearchButton
                                      .toUpperCase(),

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
                                      _primaryColor,

                                  foregroundColor:
                                      Colors.white,

                                  elevation:
                                      0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
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
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================================
  // SEARCH BAR
  // ==========================================================================

  Widget _buildSearchBar(
    AppLocalizations loc,
  ) {
    final bool hasSearch =
        _searchQuery
            .trim()
            .isNotEmpty;

    return Material(
      color:
          Colors.transparent,

      child:
          InkWell(
        onTap:
            () {
          _openSearchKeyboard(
            loc,
          );
        },

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        child:
            Container(
          width:
              double.infinity,

          constraints:
              const BoxConstraints(
            minHeight:
                116,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal:
                24,

            vertical:
                16,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.97,
            ),

            borderRadius:
                BorderRadius.circular(
              28,
            ),

            border:
                Border.all(
              color:
                  hasSearch
                      ? _primaryColor
                      : const Color(
                          0xFFC7D8E5,
                        ),

              width:
                  hasSearch
                      ? 2.5
                      : 2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF173B66,
                ).withOpacity(
                  0.11,
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
              Row(
            children: [
              // ==============================================================
              // SEARCH ICON
              // ==============================================================

              Container(
                width:
                    70,

                height:
                    70,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE0F5F2,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child:
                    const Icon(
                  Icons.search_rounded,

                  color:
                      Color(
                    0xFF00796B,
                  ),

                  size:
                      34,
                ),
              ),

              const SizedBox(
                width:
                    18,
              ),

              // ==============================================================
              // TEXT
              // ==============================================================

              Expanded(
                child:
                    Text(
                  hasSearch
                      ? _searchQuery
                      : loc.providerSearchTitle
                          .toUpperCase(),

                  maxLines:
                      1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      TextStyle(
                    color:
                        hasSearch
                            ? const Color(
                                0xFF15253A,
                              )
                            : const Color(
                                0xFF697B90,
                              ),

                    fontSize:
                        30,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              // ==============================================================
              // CLEAR
              // ==============================================================

              if (hasSearch) ...[
                const SizedBox(
                  width:
                      12,
                ),

                Material(
                  color:
                      const Color(
                    0xFFF0F3F7,
                  ),

                  shape:
                      const CircleBorder(),

                  child:
                      InkWell(
                    onTap:
                        () {
                      _applySearchQuery(
                        '',
                      );
                    },

                    customBorder:
                        const CircleBorder(),

                    child:
                        const SizedBox(
                      width:
                          52,

                      height:
                          52,

                      child:
                          Icon(
                        Icons.close_rounded,

                        color:
                            Color(
                          0xFF596A7F,
                        ),

                        size:
                            28,
                      ),
                    ),
                  ),
                ),
              ] else
                const Icon(
                  Icons.keyboard_arrow_right_rounded,

                  color:
                      Color(
                    0xFF6E8094,
                  ),

                  size:
                      36,
                ),
            ],
          ),
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
          'game-credit-top-more',
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
          'game-credit-middle-controls',
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
          'game-credit-bottom-top',
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
                _GameCreditHeader(
              title:
                  loc.gameCreditsPageTitle,

              subtitle:
                  loc.gameCreditsPageSubtitle,
            ),
          ),

          // ==================================================================
          // PROVIDERS
          // ==================================================================

          Positioned(
            top:
                325,

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
          // FADE
          // ==================================================================

          if (!_catalogLoading &&
              _catalogError == null &&
              _filteredProducts.isNotEmpty &&
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

          if (!_catalogLoading &&
              _catalogError == null &&
              _filteredProducts.isNotEmpty)
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
    // NO SERVICES
    // ========================================================================

    if (_products.isEmpty) {
      return _buildNoServices(
        loc,
      );
    }

    final List<_GameCreditProduct>
        visibleProducts =
        _filteredProducts;

    return Column(
      children: [
        // ====================================================================
        // SEARCH
        // ====================================================================

        _buildSearchBar(
          loc,
        ),

        const SizedBox(
          height:
              40,
        ),

        // ====================================================================
        // LIST
        // ====================================================================

        Expanded(
          child:
              visibleProducts.isEmpty
                  ? _buildNoSearchResults(
                      loc,
                    )
                  : Scrollbar(
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
                              index <
                                  visibleProducts.length;
                              index += 2
                            )
                              Padding(
                                padding:
                                    EdgeInsets.only(
                                  bottom:
                                      index + 2 <
                                              visibleProducts
                                                  .length
                                          ? 36
                                          : 0,
                                ),

                                child:
                                    Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    // ========================================
                                    // LEFT
                                    // ========================================

                                    Expanded(
                                      child:
                                          _buildGameCreditCard(
                                        product:
                                            visibleProducts[
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

                                    // ========================================
                                    // RIGHT
                                    // ========================================

                                    Expanded(
                                      child:
                                          index + 1 <
                                                  visibleProducts
                                                      .length
                                              ? _buildGameCreditCard(
                                                  product:
                                                      visibleProducts[
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
                    ),
        ),
      ],
    );
  }

  // ==========================================================================
  // MODERN PROVIDER CARD
  // ==========================================================================

  Widget _buildGameCreditCard({
    required _GameCreditProduct product,
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
          _statuses[
                  product.code] ??
              ProviderNetworkStatus.loading,

      networkLabel:
          loc.networkLabel,

      processingTime:
          product.processingTime,

      processingLabel:
          loc.processingTimeLabel,

      processingTimeFormatter:
          _formatGameCreditProcessingTime,

      fallbackIcon:
          Icons.videogame_asset_rounded,

      onPressed:
          () {
        _handleProductTap(
          product,
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
                      Icons.videogame_asset_rounded,

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
  // LOADING PROVIDER
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
                  85,
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
  // NO SERVICES
  // ==========================================================================

  Widget _buildNoServices(
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
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const Icon(
              Icons.videogame_asset_rounded,

              color:
                  _primaryColor,

              size:
                  85,
            ),

            const SizedBox(
              height:
                  25,
            ),

            Text(
              loc.gameCreditsNoServices,

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

  // ==========================================================================
  // NO SEARCH RESULTS
  // ==========================================================================

  Widget _buildNoSearchResults(
    AppLocalizations loc,
  ) {
    return Center(
      child:
          Container(
        width:
            650,

        padding:
            const EdgeInsets.fromLTRB(
          34,
          34,
          34,
          32,
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
              0xFFBFE4DF,
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
                  90,

              height:
                  90,

              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFE0F5F2,
                ),

                shape:
                    BoxShape.circle,
              ),

              child:
                  const Icon(
                Icons.search_off_rounded,

                color:
                    Color(
                  0xFF00796B,
                ),

                size:
                    50,
              ),
            ),

            const SizedBox(
              height:
                  22,
            ),

            Text(
              loc.providerSearchNoResults,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),

                fontSize:
                    28,

                fontWeight:
                    FontWeight.w900,

                height:
                    1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GAME CREDIT HEADER
// ============================================================================

class _GameCreditHeader
    extends StatelessWidget {
  final String title;

  final String subtitle;

  const _GameCreditHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color accentColor =
        Color(
      0xFF009688,
    );

    const Color darkAccent =
        Color(
      0xFF00695C,
    );

    const Color lightAccent =
        Color(
      0xFF26A69A,
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
              Icons.videogame_asset_rounded,

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
                      0xFFE4F6F3,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                  ),

                  child:
                      const Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      Icon(
                        Icons.videogame_asset_rounded,

                        size:
                            20,

                        color:
                            accentColor,
                      ),

                      SizedBox(
                        width:
                            8,
                      ),

                      Text(
                        'GAME CREDITS',

                        style:
                            TextStyle(
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
// SEARCH KEY
// ============================================================================

class _SearchKeyboardKey
    extends StatefulWidget {
  final String label;

  final VoidCallback onTap;

  const _SearchKeyboardKey({
    required this.label,
    required this.onTap,
  });

  @override
  State<_SearchKeyboardKey> createState() =>
      _SearchKeyboardKeyState();
}

class _SearchKeyboardKeyState
    extends State<_SearchKeyboardKey> {
  bool _pressed = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          _pressed = true;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap();
      },

      onTapCancel:
          () {
        setState(() {
          _pressed = false;
        });
      },

      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds:
              100,
        ),

        width:
            80,

        height:
            90,

        alignment:
            Alignment.center,

        decoration:
            BoxDecoration(
          color:
              _pressed
                  ? const Color(
                      0xFF00796B,
                    )
                  : Colors.white,

          borderRadius:
              BorderRadius.circular(
            14,
          ),

          border:
              Border.all(
            color:
                _pressed
                    ? const Color(
                        0xFF00796B,
                      )
                    : const Color(
                        0xFFB8C8D6,
                      ),

            width:
                2,
          ),

          boxShadow:
              _pressed
                  ? []
                  : [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(
                          0.08,
                        ),

                        blurRadius:
                            8,

                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
        ),

        child:
            Text(
          widget.label,

          style:
              TextStyle(
            color:
                _pressed
                    ? Colors.white
                    : const Color(
                        0xFF17283E,
                      ),

            fontSize:
                40,

            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH UTILITY BUTTON
// ============================================================================

class _SearchUtilityButton
    extends StatefulWidget {
  final IconData icon;

  final String label;

  final VoidCallback onTap;

  const _SearchUtilityButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SearchUtilityButton> createState() =>
      _SearchUtilityButtonState();
}

class _SearchUtilityButtonState
    extends State<_SearchUtilityButton> {
  bool _pressed = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          _pressed = true;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap();
      },

      onTapCancel:
          () {
        setState(() {
          _pressed = false;
        });
      },

      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds:
              100,
        ),

        height:
            86,

        padding:
            const EdgeInsets.symmetric(
          horizontal:
              14,
        ),

        decoration:
            BoxDecoration(
          color:
              _pressed
                  ? const Color(
                      0xFF00695C,
                    )
                  : const Color(
                      0xFFF3F7F8,
                    ),

          borderRadius:
              BorderRadius.circular(
            16,
          ),

          border:
              Border.all(
            color:
                _pressed
                    ? const Color(
                        0xFF00695C,
                      )
                    : const Color(
                        0xFFBCCCD8,
                      ),

            width:
                2,
          ),
        ),

        child:
            Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              widget.icon,

              color:
                  _pressed
                      ? Colors.white
                      : const Color(
                          0xFF315067,
                        ),

              size:
                  36,
            ),

            if (widget.label.isNotEmpty) ...[
              const SizedBox(
                width:
                    8,
              ),

              Flexible(
                child:
                    FittedBox(
                  fit:
                      BoxFit.scaleDown,

                  child:
                      Text(
                    widget.label,

                    maxLines:
                        1,

                    style:
                        TextStyle(
                      color:
                          _pressed
                              ? Colors.white
                              : const Color(
                                  0xFF315067,
                                ),

                      fontSize:
                          25,

                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
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
                          0xFF163B67,
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