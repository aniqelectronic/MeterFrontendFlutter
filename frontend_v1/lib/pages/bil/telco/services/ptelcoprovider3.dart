// ============================================================================
// TELCO PROVIDER SELECTION PAGE
// ============================================================================
//
// SHARED PAGE FOR:
//
// - Telco Bill Payment
// - Mobile PIN
//
// IMPORTANT:
//
// Provider lists are NOT hardcoded.
//
// The parent only sends:
//
// categoryId
//
// Examples:
//
// MOBILE_PIN
// MOBILE_POSTPAID
//
// This page then:
//
// /v2/catalog
//      ↓
// tree.groups
//      ↓
// categories
//      ↓
// category.id == widget.categoryId
//      ↓
// product_codes
//      ↓
// products[code]
//      ↓
// is_active == true
//      ↓
// UI
//
// If IIMMPACT adds a new provider to the category,
// it automatically appears here.
// ============================================================================

import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';

import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/bil/telco/ptelco4.dart';

import 'package:frontend_v1/pages/bil/telco/mobilepin/pmobilepin4.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

// ============================================================================
// STATUS
// ============================================================================

enum TelcoBillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

// ============================================================================
// TELCO PRODUCT
//
// Everything comes from catalog.
// ============================================================================

class TelcoProviderItem {
  final String productCode;

  final String name;

  final String imageUrl;

  final String processingTime;

  final bool isActive;

  final Color accentColor;

  final Color lightAccentColor;

  const TelcoProviderItem({
    required this.productCode,
    required this.name,
    required this.imageUrl,
    required this.processingTime,
    required this.isActive,
    required this.accentColor,
    required this.lightAccentColor,
  });
}

// ============================================================================
// PAGE
// ============================================================================

class PTELCOPROVIDER3PAGE
    extends StatefulWidget {
  final String serviceLabel;

  final String title;

  final String subtitle;

  final IconData headerIcon;

  final Color headerColor;

  // ==========================================================================
  // CATEGORY
  //
  // Examples:
  //
  // MOBILE_PIN
  // MOBILE_POSTPAID
  // ==========================================================================

  final String categoryId;

  final TelcoInputType inputType;

  const PTELCOPROVIDER3PAGE({
    super.key,
    required this.serviceLabel,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.headerColor,
    required this.categoryId,
    required this.inputType,
  });

  @override
  State<PTELCOPROVIDER3PAGE>
      createState() =>
          _PTELCOPROVIDER3PAGEState();
}

// ============================================================================
// STATE
// ============================================================================

class _PTELCOPROVIDER3PAGEState
    extends State<PTELCOPROVIDER3PAGE> {
  // ==========================================================================
  // PROVIDERS
  // ==========================================================================

  final List<TelcoProviderItem>
      _providers = [];

  bool _catalogLoading = true;

  String? _catalogError;

  // ==========================================================================
  // NETWORK
  // ==========================================================================

  final Map<String, TelcoBillerStatus>
      _billerStatuses = {};

  final Map<String, String?>
      _lastUpdated = {};

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController
      _scrollController =
      ScrollController();

  bool showScrollUp = false;

  bool showScrollDown = false;

  // ==========================================================================
  // UI COLORS
  //
  // Only decorative.
  //
  // These do NOT determine provider identity.
  //
  // If new providers are added, colors repeat.
  // ==========================================================================

  static const List<Color>
      _accentColors = [
    Color(0xFF1469E8),
    Color(0xFFFFB800),
    Color(0xFF8A55D8),
    Color(0xFF15946B),
    Color(0xFFE53935),
    Color(0xFF7356D8),
    Color(0xFFE56B21),
    Color(0xFFD64D8B),
    Color(0xFF5F43B2),
    Color(0xFF1687D9),
  ];

  static const List<Color>
      _lightAccentColors = [
    Color(0xFFE5F0FF),
    Color(0xFFFFF4D5),
    Color(0xFFF0E8FF),
    Color(0xFFE2F7EF),
    Color(0xFFFFE8E7),
    Color(0xFFEDE9FF),
    Color(0xFFFFECDD),
    Color(0xFFFFE6F2),
    Color(0xFFEDE8FF),
    Color(0xFFE3F3FF),
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
        _loadTelcoCatalog();
      },
    );
  }

  // ==========================================================================
  // LOAD TELCO PROVIDERS
  // ==========================================================================

  Future<void> _loadTelcoCatalog() async {
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
      // CATALOG
      // ======================================================================

      final Map<String, dynamic> catalog =
          await IimmpactCatalogService
              .getCatalog();

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
      // CATEGORY
      // ======================================================================

      final String wantedCategory =
          widget.categoryId
              .trim()
              .toUpperCase();

      final List<String> productCodes = [];

      for (final dynamic groupRaw
          in groupsRaw) {
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

          if (categoryId !=
              wantedCategory) {
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

            if (!productCodes.contains(
              code,
            )) {
              productCodes.add(
                code,
              );
            }
          }
        }
      }

      // ======================================================================
      // PRODUCTS MAP
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
      // BUILD PRODUCTS
      // ======================================================================

      final List<TelcoProviderItem>
          loadedProviders = [];

      for (
        int index = 0;
        index < productCodes.length;
        index++
      ) {
        final String code =
            productCodes[index];

        final dynamic rawProduct =
            products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'Telco product missing: $code',
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
            'Telco product inactive: $code',
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
        // PROCESSING TIME
        // ====================================================================

        final String processingTime =
            product['processing_time']
                    ?.toString()
                    .trim() ??
                '';

        // ====================================================================
        // DECORATIVE COLOR
        // ====================================================================

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

        loadedProviders.add(
          TelcoProviderItem(
            productCode:
                productCode,

            name:
                name,

            imageUrl:
                imageUrl,

            processingTime:
                processingTime,

            isActive:
                isActive,

            accentColor:
                accentColor,

            lightAccentColor:
                lightAccentColor,
          ),
        );
      }

      // ======================================================================
      // UPDATE
      // ======================================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _providers
          ..clear()
          ..addAll(
            loadedProviders,
          );

        _catalogLoading = false;

        _billerStatuses.clear();

        for (final provider
            in loadedProviders) {
          _billerStatuses[
                  provider.productCode] =
              TelcoBillerStatus.loading;
        }
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'TELCO PROVIDERS LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Category: '
        '${widget.categoryId}',
      );
      debugPrint(
        'Products: '
        '${_providers.map((e) => e.productCode).toList()}',
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

    on IimmpactCatalogException catch (
      error
    ) {
      if (!mounted) {
        return;
      }

      setState(() {
        _providers.clear();

        _catalogLoading = false;

        _catalogError =
            error.message;
      });
    }

    catch (
      error,
      stackTrace
    ) {
      debugPrint(
        'Telco catalog error: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _providers.clear();

        _catalogLoading = false;

        _catalogError =
            error.toString();
      });
    }
  }

  // ==========================================================================
  // LOAD NETWORK STATUSES
  // ==========================================================================

  Future<void>
      _loadNetworkStatuses() async {
    if (_providers.isEmpty) {
      return;
    }

    await Future.wait(
      _providers.map(
        (
          TelcoProviderItem provider,
        ) {
          return _refreshNetworkStatus(
            provider.productCode,
          );
        },
      ),
    );
  }

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  Future<TelcoBillerStatus>
      _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[
                productCode] =
            TelcoBillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService
              .getStatus(
        productCode:
            productCode,
      );

      final TelcoBillerStatus status =
          result.isHealthy
              ? TelcoBillerStatus.healthy
              : TelcoBillerStatus.interruption;

      if (mounted) {
        setState(() {
          _billerStatuses[
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
        'Telco network status error '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[
                  productCode] =
              TelcoBillerStatus.unavailable;
        });
      }

      return TelcoBillerStatus.unavailable;
    }
  }

  // ==========================================================================
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handleProviderTap(
    TelcoProviderItem provider,
  ) async {
    final TelcoBillerStatus status =
        await _refreshNetworkStatus(
      provider.productCode,
    );

    if (!mounted) {
      return;
    }

    if (status ==
        TelcoBillerStatus.interruption) {
      final bool shouldContinue =
          await _showInterruptionWarning(
        billerName:
            provider.name,
        productCode:
            provider.productCode,
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
        TelcoBillerStatus.unavailable) {
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
            ),
            content:
                Text(
              loc.networkUnavailableMessage(
                provider.name,
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

    // ========================================================================
    // MOBILE PIN
    // ========================================================================

    if (widget.inputType ==
        TelcoInputType.mobilePin) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  PMOBILEPIN4PAGE(
            productCode:
                provider.productCode,

            providerName:
                provider.name,

            providerImageUrl:
                provider.imageUrl,
          ),
        ),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    // ========================================================================
    // POSTPAID BILL
    // ========================================================================

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                PTELCO4PAGE(
          productCode:
              provider.productCode,

          providerName:
              provider.name,

          providerImageUrl:
              provider.imageUrl,

          inputType:
              widget.inputType,
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
                      Colors.black
                          .withOpacity(
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
                    Icons
                        .warning_amber_rounded,
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
                            Icons
                                .arrow_back_rounded,
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
                            Icons
                                .arrow_forward_rounded,
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

    return result ??
        false;
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

    final double current =
        _scrollController.offset;

    final bool up =
        current > 10;

    final bool down =
        maxScroll > 10 &&
        current <
            maxScroll - 10;

    if (showScrollUp != up ||
        showScrollDown != down) {
      setState(() {
        showScrollUp =
            up;

        showScrollDown =
            down;
      });
    }
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      (_scrollController.offset - 600)
          .clamp(
        0.0,
        _scrollController
            .position
            .maxScrollExtent,
      ),
      duration:
          const Duration(
        milliseconds:
            400,
      ),
      curve:
          Curves.easeOut,
    );
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      (_scrollController.offset + 600)
          .clamp(
        0.0,
        _scrollController
            .position
            .maxScrollExtent,
      ),
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
  // PROVIDER ROWS
  // ==========================================================================

  List<Widget> _buildProviderRows(
    AppLocalizations loc,
  ) {
    final List<Widget> rows =
        [];

    for (
      int i = 0;
      i < _providers.length;
      i += 2
    ) {
      final TelcoProviderItem left =
          _providers[i];

      final TelcoProviderItem? right =
          i + 1 <
                  _providers.length
              ? _providers[
                  i + 1
                ]
              : null;

      rows.add(
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Expanded(
              child:
                  _TelcoProviderCard(
                provider:
                    left,

                networkStatus:
                    _billerStatuses[
                            left.productCode] ??
                        TelcoBillerStatus.loading,

                networkLabel:
                    loc.networkLabel,

                onPressed:
                    () {
                  _handleProviderTap(
                    left,
                  );
                },
              ),
            ),

            const SizedBox(
              width:
                  34,
            ),

            Expanded(
              child:
                  right == null
                      ? const SizedBox()
                      : _TelcoProviderCard(
                          provider:
                              right,

                          networkStatus:
                              _billerStatuses[
                                      right.productCode] ??
                                  TelcoBillerStatus.loading,

                          networkLabel:
                              loc.networkLabel,

                          onPressed:
                              () {
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
          _providers.length) {
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
                    Colors.white
                        .withOpacity(
                      0.02,
                    ),
                    Colors.white
                        .withOpacity(
                      0.12,
                    ),
                    Colors.white
                        .withOpacity(
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
                40,
            left:
                40,
            right:
                40,

            child:
                _TelcoModernHeader(
              serviceLabel:
                  widget.serviceLabel,

              title:
                  widget.title,

              subtitle:
                  widget.subtitle,

              icon:
                  widget.headerIcon,

              accentColor:
                  widget.headerColor,
            ),
          ),

          // ==================================================================
          // BODY
          // ==================================================================

          Positioned(
            top:
                450,
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

          if (!_catalogLoading &&
              _providers.isNotEmpty &&
              showScrollUp)
            Positioned(
              right:
                  18,
              top:
                  365,
              child:
                  _ScrollIndicatorButton(
                icon:
                    Icons.keyboard_arrow_up_rounded,

                label:
                    loc.scrollup,

                onPressed:
                    _scrollUp,
              ),
            ),

          if (!_catalogLoading &&
              _providers.isNotEmpty &&
              showScrollDown)
            Positioned(
              right:
                  18,
              bottom:
                  290,
              child:
                  _ScrollIndicatorButton(
                icon:
                    Icons.keyboard_arrow_down_rounded,

                label:
                    loc.scrolldown,

                onPressed:
                    _scrollDown,

                iconBelowText:
                    true,
              ),
            ),

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
    if (_catalogLoading) {
      return _buildModernLoading(
        loc,
      );
    }

    if (_catalogError != null) {
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
          ),

          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              const Icon(
                Icons.cloud_off_rounded,
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
                loc.billUnknownError,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize:
                      27,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                    25,
              ),

              ElevatedButton.icon(
                onPressed:
                    _loadTelcoCatalog,

                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),

                label:
                    Text(
                  loc.retryButton,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_providers.isEmpty) {
      return Center(
        child:
            Text(
          loc.networkStatusUnknown,

          style:
              const TextStyle(
            fontSize:
                27,
            fontWeight:
                FontWeight.w800,
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
              55,
        ),

        child:
            Column(
          children:
              _buildProviderRows(
            loc,
          ),
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
                  widget.headerColor
                      .withOpacity(
                0.20,
              ),
              width:
                  2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    widget.headerColor
                        .withOpacity(
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
                      widget.headerColor
                          .withOpacity(
                    0.10,
                  ),
                  shape:
                      BoxShape.circle,
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
                            widget.headerColor,
                        backgroundColor:
                            widget.headerColor
                                .withOpacity(
                          0.12,
                        ),
                      ),
                    ),

                    Icon(
                      widget.headerIcon,
                      color:
                          widget.headerColor,
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
  // LOADING SKELETON
  // ==========================================================================

  Widget _buildLoadingProviderCard() {
    return Container(
      height:
          330,

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
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width:
                150,
            height:
                115,

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
            width:
                double.infinity,
            height:
                25,

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
                13,
          ),

          Container(
            width:
                170,
            height:
                20,

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
            height:
                22,
          ),

          Container(
            width:
                185,
            height:
                48,

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

  @override
  void dispose() {
    _scrollController.removeListener(
      _handleScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _TelcoModernHeader
    extends StatelessWidget {
  final String serviceLabel;

  final String title;

  final String subtitle;

  final IconData icon;

  final Color accentColor;

  const _TelcoModernHeader({
    required this.serviceLabel,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal:
                24,
            vertical:
                10,
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

              width:
                  1.5,
            ),
          ),

          child:
              Row(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Icon(
                icon,
                color:
                    accentColor,
                size:
                    25,
              ),

              const SizedBox(
                width:
                    9,
              ),

              Text(
                serviceLabel.toUpperCase(),

                style:
                    TextStyle(
                  color:
                      accentColor,
                  fontSize:
                      17,
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
          height:
              20,
        ),

        ShaderMask(
          blendMode:
              BlendMode.srcIn,

          shaderCallback:
              (
            bounds,
          ) {
            return LinearGradient(
              colors: [
                accentColor,
                accentColor.withOpacity(
                  0.72,
                ),
              ],
            ).createShader(
              bounds,
            );
          },

          child:
              Text(
            title.toUpperCase(),

            textAlign:
                TextAlign.center,

            maxLines:
                2,

            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize:
                  50,
              fontWeight:
                  FontWeight.w900,
              height:
                  1.05,
            ),
          ),
        ),

        const SizedBox(
          height:
              20,
        ),

        Container(
          constraints:
              const BoxConstraints(
            maxWidth:
                850,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal:
                30,
            vertical:
                14,
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

              width:
                  1.5,
            ),
          ),

          child:
              Text(
            subtitle.toUpperCase(),

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Color(
                0xFF435166,
              ),
              fontSize:
                  28,
              fontWeight:
                  FontWeight.w700,
              height:
                  1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PROVIDER CARD
// ============================================================================

class _TelcoProviderCard
    extends StatefulWidget {
  final TelcoProviderItem provider;

  final VoidCallback onPressed;

  final TelcoBillerStatus networkStatus;

  final String networkLabel;

  const _TelcoProviderCard({
    required this.provider,
    required this.onPressed,
    required this.networkStatus,
    required this.networkLabel,
  });

  @override
  State<_TelcoProviderCard>
      createState() =>
          _TelcoProviderCardState();
}

// ============================================================================
// CARD STATE
// ============================================================================

class _TelcoProviderCardState
    extends State<_TelcoProviderCard> {
  bool _isPressed = false;

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

    if (normalized ==
        'instant') {
      return loc.processingInstant;
    }

    if (normalized ==
        '24_hours') {
      return loc.processing24Hours;
    }

    if (normalized ==
        '3_days') {
      return loc.processing3Days;
    }

    if (normalized ==
        'pin') {
      return 'PIN';
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final TelcoProviderItem provider =
        widget.provider;

    final bool isEnabled =
        widget.networkStatus !=
            TelcoBillerStatus.unavailable;

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTapDown:
          isEnabled
              ? (_) {
                  setState(
                    () {
                      _isPressed =
                          true;
                    },
                  );
                }
              : null,

      onTapUp:
          isEnabled
              ? (_) {
                  setState(
                    () {
                      _isPressed =
                          false;
                    },
                  );
                }
              : null,

      onTapCancel:
          isEnabled
              ? () {
                  setState(
                    () {
                      _isPressed =
                          false;
                    },
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
          milliseconds:
              130,
        ),

        curve:
            Curves.easeOut,

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds:
                170,
          ),

          height:
              480,

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
                      ? provider.accentColor
                      : Colors.black,

              width:
                  _isPressed
                      ? 4
                      : 3,
            ),

            boxShadow: [
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

            child:
                Stack(
              children: [
                Positioned(
                  right:
                      -50,
                  top:
                      -50,

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
                          provider
                              .lightAccentColor
                              .withOpacity(
                        0.90,
                      ),
                    ),
                  ),
                ),

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

                    child:
                        Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Container(
                              width:
                                  220,

                              height:
                                  180,

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
                                      provider
                                          .accentColor
                                          .withOpacity(
                                    0.20,
                                  ),

                                  width:
                                      1.5,
                                ),
                              ),

                              child:
                                  _buildLogo(
                                provider,
                              ),
                            ),

                            Container(
                              width:
                                  58,

                              height:
                                  58,

                              decoration:
                                  BoxDecoration(
                                color:
                                    provider.accentColor,

                                shape:
                                    BoxShape.circle,
                              ),

                              child:
                                  const Icon(
                                Icons.arrow_forward_rounded,

                                color:
                                    Colors.white,

                                size:
                                    32,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Align(
                          alignment:
                              Alignment.centerLeft,

                          child:
                              Text(
                            provider.name
                                .toUpperCase(),

                            maxLines:
                                3,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF15253A,
                              ),

                              fontSize:
                                  35,

                              fontWeight:
                                  FontWeight.w900,

                              height:
                                  1.10,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                              21,
                        ),

                        Align(
                          alignment:
                              Alignment.centerLeft,

                          child:
                              _NetworkStatusBadge(
                            status:
                                widget.networkStatus,

                            label:
                                widget.networkLabel,
                          ),
                        ),

                        if (provider
                            .processingTime
                            .isNotEmpty) ...[
                          const SizedBox(
                            height:
                                14,
                          ),

                          Align(
                            alignment:
                                Alignment.centerLeft,

                            child:
                                Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size:
                                      22,
                                  color:
                                      Color(
                                    0xFF647187,
                                  ),
                                ),

                                const SizedBox(
                                  width:
                                      8,
                                ),

                                Expanded(
                                  child:
                                      Text(
                                    '${AppLocalizations.of(context)!.processingTimeLabel}: '
                                    '${_formatProcessingTime(
                                      context,
                                      provider.processingTime,
                                    )}',

                                    maxLines:
                                        2,

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

                                      height:
                                          1.15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(
                          height:
                              22,
                        ),

                        Row(
                          children: [
                            Container(
                              width:
                                  60,

                              height:
                                  7,

                              decoration:
                                  BoxDecoration(
                                color:
                                    provider.accentColor,

                                borderRadius:
                                    BorderRadius.circular(
                                  50,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width:
                                  8,
                            ),

                            Container(
                              width:
                                  13,

                              height:
                                  7,

                              decoration:
                                  BoxDecoration(
                                color:
                                    provider
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

  Widget _buildLogo(
    TelcoProviderItem provider,
  ) {
    if (provider.imageUrl.isEmpty) {
      return Icon(
        Icons.sim_card_rounded,
        size:
            90,
        color:
            provider.accentColor,
      );
    }

    return Image.network(
      provider.imageUrl,

      fit:
          BoxFit.contain,

      loadingBuilder:
          (
        context,
        child,
        progress,
      ) {
        if (progress ==
            null) {
          return child;
        }

        return Center(
          child:
              CircularProgressIndicator(
            strokeWidth:
                3,
            color:
                provider.accentColor,
          ),
        );
      },

      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return Icon(
          Icons.sim_card_rounded,
          size:
              90,
          color:
              provider.accentColor,
        );
      },
    );
  }
}

// ============================================================================
// NETWORK BADGE
// ============================================================================

class _NetworkStatusBadge
    extends StatelessWidget {
  final TelcoBillerStatus status;

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
      case TelcoBillerStatus.loading:
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

      case TelcoBillerStatus.healthy:
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
            Icons.check_circle_rounded;

        break;

      case TelcoBillerStatus.interruption:
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
            Icons.warning_amber_rounded;

        break;

      case TelcoBillerStatus.unavailable:
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
            Icons.help_outline_rounded;

        break;
    }

    return Container(
      constraints:
          const BoxConstraints(
        minHeight:
            58,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal:
            18,
        vertical:
            14,
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
              1.7,
        ),
      ),

      child:
          Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          if (status ==
              TelcoBillerStatus.loading)
            SizedBox(
              width:
                  26,

              height:
                  26,

              child:
                  CircularProgressIndicator(
                strokeWidth:
                    3,

                color:
                    foregroundColor,
              ),
            )
          else
            Icon(
              icon,

              size:
                  28,

              color:
                  foregroundColor,
            ),

          const SizedBox(
            width:
                9,
          ),

          Flexible(
            child:
                Text(
              '$label: $statusText',

              maxLines:
                  1,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  TextStyle(
                color:
                    foregroundColor,

                fontSize:
                    18,

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
      size:
          52,
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

        fontSize:
            17,

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

      elevation:
          5,

      child:
          InkWell(
        onTap:
            onPressed,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        child:
            Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal:
                13,
            vertical:
                10,
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

          child:
              Column(
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