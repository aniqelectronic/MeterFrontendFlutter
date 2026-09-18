import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/pages/bil/gamecredits/pgamecredits4.dart';

enum GameCreditStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

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

class PGAMECREDITS3PAGE extends StatefulWidget {
  const PGAMECREDITS3PAGE({
    super.key,
  });

  @override
  State<PGAMECREDITS3PAGE> createState() =>
      _PGAMECREDITS3PAGEState();
}

class _PGAMECREDITS3PAGEState
    extends State<PGAMECREDITS3PAGE> {
  final List<_GameCreditProduct> _products = [];

  bool _catalogLoading = true;
  String? _catalogError;

  final Map<String, GameCreditStatus> _statuses = {};
  final Map<String, String?> _lastUpdated = {};

  final ScrollController _scrollController =
      ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = false;

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

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCatalog();
    });
  }

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
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      // ================================================================
      // TREE
      // ================================================================

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

      // ================================================================
      // GROUPS
      // ================================================================

      final dynamic groupsRaw = tree['groups'];

      if (groupsRaw is! List) {
        throw Exception(
          'Catalog groups not found.',
        );
      }

      // ================================================================
      // FIND GAME_CREDITS
      // ================================================================

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

        // Only look inside GAMES group
        if (groupId != 'GAMES') {
          continue;
        }

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

          if (categoryId != 'GAME_CREDITS') {
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

            if (!gameCreditCodes.contains(code)) {
              gameCreditCodes.add(code);
            }
          }
        }
      }

      // ================================================================
      // PRODUCTS
      // ================================================================

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

      // ================================================================
      // BUILD ACTIVE PRODUCTS
      // ================================================================

      final List<_GameCreditProduct> loadedProducts = [];

      for (final String code in gameCreditCodes) {
        final dynamic rawProduct =
            products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'Game Credit catalog product not found: $code',
          );

          continue;
        }

        final Map<String, dynamic> product =
            Map<String, dynamic>.from(
          rawProduct,
        );

        // ==============================================================
        // ACTIVE FILTER
        // ==============================================================

        if (product['is_active'] != true) {
          debugPrint(
            'Game Credit product inactive: $code',
          );

          continue;
        }

        final String productCode =
            product['code']
                    ?.toString()
                    .trim()
                    .toUpperCase() ??
                code;

        final String productName =
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

        final String note =
            product['note']
                    ?.toString()
                    .trim() ??
                '';

        loadedProducts.add(
          _GameCreditProduct(
            code: productCode,
            name: productName,
            imageUrl: imageUrl,
            processingTime: processingTime,
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

        _statuses.clear();
        _lastUpdated.clear();

        for (final _GameCreditProduct product
            in loadedProducts) {
          _statuses[product.code] =
              GameCreditStatus.loading;
        }

        _catalogLoading = false;
        _catalogError = null;
      });

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

      await _loadNetworkStatuses();

      if (!mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleScroll();
      });
    } on IimmpactCatalogException catch (error) {
      debugPrint(
        'Game Credits catalog error: ${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _products.clear();
        _statuses.clear();
        _lastUpdated.clear();

        _catalogLoading = false;
        _catalogError = error.message;

        showScrollUp = false;
        showScrollDown = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected Game Credits catalog error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _products.clear();
        _statuses.clear();
        _lastUpdated.clear();

        _catalogLoading = false;
        _catalogError = error.toString();

        showScrollUp = false;
        showScrollDown = false;
      });
    }
  }

  Future<void> _loadNetworkStatuses() async {
    if (_products.isEmpty) {
      return;
    }

    await Future.wait(
      _products.map(
        (_GameCreditProduct product) {
          return _refreshNetworkStatus(
            product.code,
          );
        },
      ),
    );
  }

  Future<GameCreditStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _statuses[productCode] =
            GameCreditStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final GameCreditStatus status =
          result.isHealthy
              ? GameCreditStatus.healthy
              : GameCreditStatus.interruption;

      if (mounted) {
        setState(() {
          _statuses[productCode] = status;
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
              GameCreditStatus.unavailable;
        });
      }

      return GameCreditStatus.unavailable;
    }
  }

  Future<bool> _showInterruptionWarning({
    required String productName,
    required String productCode,
  }) async {
    final loc =
        AppLocalizations.of(context)!;

    final bool? result =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext dialogContext,
      ) {
        return Dialog(
          backgroundColor: Colors.transparent,
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
                  BorderRadius.circular(38),
              border: Border.all(
                color:
                    const Color(0xFFF2A520),
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
                      const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFFF2D9),
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color:
                        Color(0xFFD87900),
                    size: 78,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  loc.networkInterruptionTitle,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF17283E),
                    fontSize: 40,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFFF9ED),
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Text(
                    loc.networkInterruptionMessage(
                      productName,
                    ),
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF4B4234),
                      fontSize: 29,
                      height: 1.4,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                if (_lastUpdated[
                        productCode] !=
                    null) ...[
                  const SizedBox(height: 20),
                  Text(
                    '${loc.networkLastUpdated}: '
                    '${_lastUpdated[productCode]}',
                    style:
                        const TextStyle(
                      fontSize: 21,
                      color:
                          Color(0xFF758399),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child:
                            OutlinedButton(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );
                          },
                          child: Text(
                            loc.backButton,
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 22),

                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child:
                            ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          },
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF168A50,
                            ),
                            foregroundColor:
                                Colors.white,
                          ),
                          child: Text(
                            loc.continueButton,
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w900,
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

  Future<void> _handleProductTap(
    _GameCreditProduct product,
  ) async {
    final GameCreditStatus status =
        await _refreshNetworkStatus(
      product.code,
    );

    if (!mounted) {
      return;
    }

    if (status ==
        GameCreditStatus.interruption) {
      final bool continuePurchase =
          await _showInterruptionWarning(
        productName: product.name,
        productCode: product.code,
      );

      if (!continuePurchase) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    if (status ==
        GameCreditStatus.unavailable) {
      final loc =
          AppLocalizations.of(context)!;

      await showDialog<void>(
        context: context,
        builder: (
          BuildContext dialogContext,
        ) {
          return AlertDialog(
            title: Text(
              loc.alertTitle,
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

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
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
          const Duration(milliseconds: 400),
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
          const Duration(milliseconds: 400),
      curve: Curves.easeOut,
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
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

          Positioned(
            top: 82,
            left: 65,
            right: 65,
            child:
                _GameCreditHeader(
              title:
                  loc.gameCreditsPageTitle,
              subtitle:
                  loc.gameCreditsPageSubtitle,
            ),
          ),

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

          if (!_catalogLoading &&
              _catalogError == null &&
              _products.isNotEmpty &&
              showScrollUp)
            Positioned(
              right: 18,
              top: 365,
              child:
                  _ScrollButton(
                icon:
                    Icons
                        .keyboard_arrow_up_rounded,
                label:
                    loc.scrollup,
                onPressed:
                    _scrollUp,
              ),
            ),

          if (!_catalogLoading &&
              _catalogError == null &&
              _products.isNotEmpty &&
              showScrollDown)
            Positioned(
              right: 18,
              bottom: 290,
              child:
                  _ScrollButton(
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
                      Color(0xFF26364A),
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

  Widget _buildProviderArea(
    AppLocalizations loc,
  ) {
    if (_catalogLoading) {
      return _buildLoading(
        loc,
      );
    }

    if (_catalogError != null) {
      return Center(
        child: Container(
          width: 680,
          padding:
              const EdgeInsets.all(42),
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.97,
            ),
            borderRadius:
                BorderRadius.circular(35),
            border: Border.all(
              color:
                  const Color(0xFFE57373),
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
                    Color(0xFFD32F2F),
                size: 85,
              ),

              const SizedBox(height: 25),

              Text(
                loc.providerLoadError,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Color(0xFF17283E),
                  fontSize: 35,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                loc.providerLoadErrorSubtitle,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Color(0xFF657386),
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 80,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _loadCatalog,
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
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Container(
          width: 680,
          padding:
              const EdgeInsets.all(42),
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.97,
            ),
            borderRadius:
                BorderRadius.circular(35),
          ),
          child: Text(
            loc.gameCreditsNoServices,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(0xFF17283E),
              fontSize: 30,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      );
    }

    return Scrollbar(
      controller:
          _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 11,
      radius:
          const Radius.circular(20),
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
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          _GameCreditCard(
                        product:
                            _products[index],
                        status:
                            _statuses[
                                    _products[
                                            index]
                                        .code] ??
                                GameCreditStatus
                                    .loading,
                        accentColor:
                            _accentColors[
                              index %
                                  _accentColors
                                      .length
                            ],
                        lightAccentColor:
                            _lightAccentColors[
                              index %
                                  _lightAccentColors
                                      .length
                            ],
                        onPressed: () {
                          _handleProductTap(
                            _products[index],
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 34),

                    Expanded(
                      child:
                          index + 1 <
                                  _products.length
                              ? _GameCreditCard(
                                  product:
                                      _products[
                                        index + 1
                                      ],
                                  status:
                                      _statuses[
                                              _products[
                                                      index +
                                                          1]
                                                  .code] ??
                                          GameCreditStatus
                                              .loading,
                                  accentColor:
                                      _accentColors[
                                        (index + 1) %
                                            _accentColors
                                                .length
                                      ],
                                  lightAccentColor:
                                      _lightAccentColors[
                                        (index + 1) %
                                            _lightAccentColors
                                                .length
                                      ],
                                  onPressed: () {
                                    _handleProductTap(
                                      _products[
                                        index + 1
                                      ],
                                    );
                                  },
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


  // ============================================================================
// MODERN LOADING
// SAME DESIGN AS IDD
// ============================================================================

Widget _buildLoading(
  AppLocalizations loc,
) {
  const Color color =
      Color(0xFF009688);

  return Column(
    children: [
      // ======================================================================
      // MAIN LOADING CARD
      // ======================================================================

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
            // ================================================================
            // ICON + SPINNER
            // ================================================================

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
                        .videogame_asset_rounded,
                    color: color,
                    size: 40,
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 25,
            ),

            // ================================================================
            // TEXT
            // ================================================================

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

      // ======================================================================
      // SKELETON PROVIDER CARDS
      // ======================================================================

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
              0xFF009688,
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
          // LOGO PLACEHOLDER
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

          // NAME PLACEHOLDER
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

          // SMALL TEXT PLACEHOLDER
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

          // STATUS PLACEHOLDER
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
}

// ============================================================================
// MODERN + GOVERNMENT GAME CREDITS HEADER
// KEEPS EXISTING BADGE + TITLE + SUBTITLE
// ============================================================================

class _GameCreditHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _GameCreditHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF009688);
    const Color darkAccent = Color(0xFF00695C);
    const Color lightAccent = Color(0xFF26A69A);

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
          // LEFT GAME CREDITS ICON
          // ==========================================================

          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  darkAccent,
                  lightAccent,
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
              Icons.videogame_asset_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(width: 28),

          // ==========================================================
          // EXISTING HEADER INFORMATION
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // EXISTING GAME CREDITS BADGE
                // ------------------------------------------------------

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F6F3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videogame_asset_rounded,
                        size: 20,
                        color: accentColor,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'GAME CREDITS',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
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
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607188),
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ==========================================================
          // RIGHT TEAL ACCENT BAR
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

class _GameCreditCard
    extends StatefulWidget {
  final _GameCreditProduct product;
  final GameCreditStatus status;

  final Color accentColor;
  final Color lightAccentColor;

  final VoidCallback onPressed;

  const _GameCreditCard({
    required this.product,
    required this.status,
    required this.accentColor,
    required this.lightAccentColor,
    required this.onPressed,
  });

  @override
  State<_GameCreditCard> createState() =>
      _GameCreditCardState();
}

class _GameCreditCardState
    extends State<_GameCreditCard> {
  bool _pressed = false;

  bool get _enabled =>
      widget.status !=
      GameCreditStatus.unavailable;

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context)!;

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTapDown:
          _enabled
              ? (_) {
                  setState(() {
                    _pressed = true;
                  });
                }
              : null,

      onTapUp:
          _enabled
              ? (_) {
                  setState(() {
                    _pressed = false;
                  });
                }
              : null,

      onTapCancel:
          _enabled
              ? () {
                  setState(() {
                    _pressed = false;
                  });
                }
              : null,

      onTap:
          _enabled
              ? widget.onPressed
              : null,

      child: AnimatedScale(
        scale:
            _pressed ? 0.965 : 1,
        duration:
            const Duration(
          milliseconds: 130,
        ),
        child: Container(
          height: 500,
          padding:
              const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(
              _enabled ? 0.96 : 0.70,
            ),
            borderRadius:
                BorderRadius.circular(40),
            border: Border.all(
              color:
                  _pressed
                      ? widget.accentColor
                      : Colors.black,
              width:
                  _pressed ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF19375C)
                        .withOpacity(0.16),
                blurRadius: 30,
                offset:
                    const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 220,
                    height: 175,
                    padding:
                        const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(32),
                      border: Border.all(
                        color:
                            widget.accentColor
                                .withOpacity(
                          0.20,
                        ),
                      ),
                    ),
                    child:
                        _buildLogo(),
                  ),

                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color:
                          widget.accentColor,
                      shape:
                          BoxShape.circle,
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

              Text(
                widget.product.name
                    .toUpperCase(),
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color:
                      Color(0xFF15253A),
                  fontSize: 32,
                  fontWeight:
                      FontWeight.w900,
                  height: 1.08,
                ),
              ),

              const SizedBox(height: 18),

              _buildNetworkStatus(loc),

              if (widget
                  .product
                  .processingTime
                  .isNotEmpty) ...[
                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 22,
                      color:
                          Color(0xFF647187),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        '${loc.processingTimeLabel}: '
                        '${_processingTime(
                          context,
                        )}',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
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
              ],

              const SizedBox(height: 18),

              Container(
                width: 60,
                height: 7,
                decoration: BoxDecoration(
                  color:
                      widget.accentColor,
                  borderRadius:
                      BorderRadius.circular(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (widget
        .product
        .imageUrl
        .isEmpty) {
      return Icon(
        Icons.videogame_asset_rounded,
        size: 90,
        color:
            widget.accentColor,
      );
    }

    return Image.network(
      widget.product.imageUrl,
      fit:
          BoxFit.contain,
      loadingBuilder: (
        context,
        child,
        progress,
      ) {
        if (progress == null) {
          return child;
        }

        return Center(
          child:
              CircularProgressIndicator(
            color:
                widget.accentColor,
          ),
        );
      },
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Icon(
          Icons.videogame_asset_rounded,
          size: 90,
          color:
              widget.accentColor,
        );
      },
    );
  }

  Widget _buildNetworkStatus(
    AppLocalizations loc,
  ) {
    String text;
    Color background;
    Color foreground;
    IconData icon;

    switch (widget.status) {
      case GameCreditStatus.loading:
        text =
            loc.networkStatusChecking;
        background =
            const Color(0xFFF0F4F8);
        foreground =
            const Color(0xFF536272);
        icon =
            Icons.sync_rounded;
        break;

      case GameCreditStatus.healthy:
        text =
            loc.networkStatusGood;
        background =
            const Color(0xFFE2F8EC);
        foreground =
            const Color(0xFF08783E);
        icon =
            Icons.check_circle_rounded;
        break;

      case GameCreditStatus.interruption:
        text =
            loc.networkStatusSlow;
        background =
            const Color(0xFFFFF0D7);
        foreground =
            const Color(0xFFB75B00);
        icon =
            Icons.warning_amber_rounded;
        break;

      case GameCreditStatus.unavailable:
        text =
            loc.networkStatusUnknown;
        background =
            const Color(0xFFF1F1F1);
        foreground =
            const Color(0xFF555555);
        icon =
            Icons.help_outline_rounded;
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          if (widget.status ==
              GameCreditStatus.loading)
            SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(
                strokeWidth: 3,
                color: foreground,
              ),
            )
          else
            Icon(
              icon,
              size: 24,
              color: foreground,
            ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              '${loc.networkLabel}: $text',
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
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

  String _processingTime(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    switch (widget
        .product
        .processingTime
        .toLowerCase()) {
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
        return widget
            .product
            .processingTime
            .replaceAll('_', ' ')
            .toUpperCase();
    }
  }
}

class _ScrollButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool iconBelowText;

  const _ScrollButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconBelowText = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget =
        Icon(
      icon,
      size: 52,
      color:
          const Color(0xFF009688),
    );

    final Widget textWidget =
        Text(
      label,
      textAlign:
          TextAlign.center,
      style:
          const TextStyle(
        color:
            Color(0xFF15253A),
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
          BorderRadius.circular(22),
      elevation: 5,
      child: InkWell(
        onTap: onPressed,
        borderRadius:
            BorderRadius.circular(22),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: Colors.black,
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