// ============================================================================
// TELCO PROVIDER SELECTION PAGE
// ============================================================================
//
// SHARED PAGE FOR:
//
// - Telco Bill Payment
// - Mobile PIN
//
// Provider list comes dynamically from:
//
// /v2/catalog
//
// categoryId determines which provider list is shown.
//
// Examples:
//
// MOBILE_PIN
// MOBILE_POSTPAID
//
// ============================================================================

import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';

import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/bil/telco/ptelco4.dart';

import 'package:frontend_v1/pages/bil/telco/mobilepin/pmobilepin4.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:frontend_v1/widgets/modern_provider_card.dart';

// ============================================================================
// TELCO PRODUCT
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

class PTELCOPROVIDER3PAGE extends StatefulWidget {
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
  State<PTELCOPROVIDER3PAGE> createState() =>
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

  final List<TelcoProviderItem> _providers = [];

  bool _catalogLoading = true;

  String? _catalogError;

  // ==========================================================================
  // NETWORK
  //
  // Uses the shared status from:
  //
  // modern_provider_card.dart
  // ==========================================================================

  final Map<String, ProviderNetworkStatus>
      _billerStatuses = {};

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
  // Provider identity still comes from the catalog.
  // ==========================================================================

  static const List<Color> _accentColors = [
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

  static const List<Color> _lightAccentColors = [
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
      // CATEGORY
      // ======================================================================

      final String wantedCategory =
          widget.categoryId
              .trim()
              .toUpperCase();

      final List<String> productCodes = [];

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

          if (categoryId != wantedCategory) {
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

            if (!productCodes.contains(code)) {
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
      // BUILD PROVIDERS
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
        // DECORATIVE COLORS
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

        _catalogLoading =
            false;

        _billerStatuses.clear();

        for (final provider
            in loadedProviders) {
          _billerStatuses[
                  provider.productCode] =
              ProviderNetworkStatus.loading;
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
        'Category: ${widget.categoryId}',
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

    // =========================================================================
    // IIMMPACT ERROR
    // =========================================================================

    on IimmpactCatalogException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _providers.clear();

        _catalogLoading =
            false;

        _catalogError =
            error.message;

        showScrollUp =
            false;

        showScrollDown =
            false;
      });
    }

    // =========================================================================
    // OTHER ERROR
    // =========================================================================

    catch (error, stackTrace) {
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

        _catalogLoading =
            false;

        _catalogError =
            error.toString();

        showScrollUp =
            false;

        showScrollDown =
            false;
      });
    }
  }

  // ==========================================================================
  // LOAD NETWORK STATUSES
  // ==========================================================================

  Future<void> _loadNetworkStatuses() async {
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
        productCode:
            productCode,
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
        'Telco network status error '
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
  // TELCO PROCESSING TIME
  //
  // Preserves existing Telco translations:
  //
  // instant
  // 24_hours
  // 3_days
  // pin
  // 48_hours
  // 72_hours
  // 2_days
  // 5_days
  // etc.
  // ==========================================================================

  String _formatTelcoProcessingTime(
    BuildContext context,
    String value,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    final String normalized =
        value
            .toLowerCase()
            .trim();

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
    TelcoProviderItem provider,
  ) async {
    final ProviderNetworkStatus status =
        await _refreshNetworkStatus(
      provider.productCode,
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
    //
    // ORIGINAL FLOW KEPT
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
    // POSTPAID / OTHER TELCO FLOW
    //
    // ORIGINAL FLOW KEPT
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
                // ACTION BUTTONS
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

    final double current =
        _scrollController.offset;

    final bool hasScrollableContent =
        maxScroll > 10;

    final bool up =
        hasScrollableContent &&
            current > 10;

    final bool down =
        hasScrollableContent &&
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

  // ==========================================================================
  // SCROLL UP
  // ==========================================================================

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

  // ==========================================================================
  // SCROLL DOWN
  // ==========================================================================

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
  // SCROLL CONTROL
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
          'telco-top-more',
        ),

        mode:
            _ScrollControlMode.more,

        label:
            loc.scrollViewMore,

        onPressed:
            _scrollDown,

        accentColor:
            widget.headerColor,
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
          'telco-middle-controls',
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
                widget.headerColor,
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
                widget.headerColor,
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
          'telco-bottom-top',
        ),

        mode:
            _ScrollControlMode.top,

        label:
            loc.scrollBackTop,

        onPressed:
            _scrollToTop,

        accentColor:
            widget.headerColor,
      );
    }

    return const SizedBox.shrink();
  }

  // ==========================================================================
  // PROVIDER ROWS
  // ==========================================================================

  List<Widget> _buildProviderRows(
    AppLocalizations loc,
  ) {
    final List<Widget> rows = [];

    for (
      int i = 0;
      i < _providers.length;
      i += 2
    ) {
      final TelcoProviderItem left =
          _providers[i];

      final TelcoProviderItem? right =
          i + 1 < _providers.length
              ? _providers[i + 1]
              : null;

      rows.add(
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ================================================================
            // LEFT
            // ================================================================

            Expanded(
              child:
                  _buildProviderCard(
                provider:
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
                      : _buildProviderCard(
                          provider:
                              right,

                          loc:
                              loc,
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
  // SHARED PROVIDER CARD
  //
  // The UI now comes entirely from:
  //
  // lib/widgets/modern_provider_card.dart
  // ==========================================================================

  Widget _buildProviderCard({
    required TelcoProviderItem provider,
    required AppLocalizations loc,
  }) {
    return ModernProviderCard(
      imageUrl:
          provider.imageUrl,

      label:
          provider.name,

      accentColor:
          provider.accentColor,

      lightAccentColor:
          provider.lightAccentColor,

      networkStatus:
          _billerStatuses[
                  provider.productCode] ??
              ProviderNetworkStatus.loading,

      networkLabel:
          loc.networkLabel,

      processingTime:
          provider.processingTime,

      processingLabel:
          loc.processingTimeLabel,

      // ======================================================================
      // TELCO-SPECIFIC PROCESSING FORMATTER
      // ======================================================================

      processingTimeFormatter:
          _formatTelcoProcessingTime,

      fallbackIcon:
          Icons.sim_card_rounded,

      onPressed:
          () {
        _handleProviderTap(
          provider,
        );
      },
    );
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

          // ==================================================================
          // BOTTOM FADE
          // ==================================================================

          if (!_catalogLoading &&
              _providers.isNotEmpty &&
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
          // NEW SCROLL CONTROL
          // ==================================================================

          if (!_catalogLoading &&
              _providers.isNotEmpty)
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
                    child,
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
          //
          // IMPORTANT:
          // Keep Navigator.pop because this page can be opened from multiple
          // Telco parent flows.
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

            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF17375E,
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

          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width:
                    100,

                height:
                    100,

                decoration:
                    BoxDecoration(
                  color:
                      widget.headerColor.withOpacity(
                    0.10,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    Icon(
                  Icons.cloud_off_rounded,

                  size:
                      55,

                  color:
                      widget.headerColor,
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
                      FontWeight.w800,

                  color:
                      Color(
                    0xFF17283E,
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
                      _loadTelcoCatalog,

                  icon:
                      const Icon(
                    Icons.refresh_rounded,

                    size:
                        28,
                  ),

                  label:
                      Text(
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
                        widget.headerColor,

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

    if (_providers.isEmpty) {
      return Center(
        child:
            Container(
          padding:
              const EdgeInsets.all(
            35,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.95,
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
              Icon(
                widget.headerIcon,

                size:
                    65,

                color:
                    widget.headerColor,
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
                  fontSize:
                      27,

                  fontWeight:
                      FontWeight.w800,

                  color:
                      Color(
                    0xFF17283E,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                  widget.headerColor.withOpacity(
                0.20,
              ),

              width:
                  2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    widget.headerColor.withOpacity(
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
                      widget.headerColor.withOpacity(
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
                            widget.headerColor.withOpacity(
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
  //
  // Height now follows the shared ModernProviderCard.
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
                const Color(
              0xFF1A3A5C,
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
}

// ============================================================================
// MODERN TELCO HEADER
// ============================================================================

class _TelcoModernHeader extends StatelessWidget {
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
          // LEFT ICON
          // ==================================================================

          Container(
            width:
                105,

            height:
                105,

            decoration:
                BoxDecoration(
              gradient:
                  LinearGradient(
                begin:
                    Alignment.topLeft,

                end:
                    Alignment.bottomRight,

                colors: [
                  accentColor,

                  Color.lerp(
                        accentColor,
                        Colors.white,
                        0.20,
                      ) ??
                      accentColor,
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
                Icon(
              icon,

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
                // SERVICE LABEL
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
                        accentColor.withOpacity(
                      0.10,
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
                      Icon(
                        icon,

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
                  LinearGradient(
                begin:
                    Alignment.topCenter,

                end:
                    Alignment.bottomCenter,

                colors: [
                  accentColor,

                  Color.lerp(
                        accentColor,
                        Colors.white,
                        0.25,
                      ) ??
                      accentColor,
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
// SCROLL CONTROL
// ============================================================================

enum _ScrollControlMode {
  up,
  more,
  top,
}

// ============================================================================
// SCROLL DISCOVERY CONTROL
// ============================================================================

class _ScrollDiscoveryControl
    extends StatefulWidget {
  final _ScrollControlMode mode;

  final String label;

  final VoidCallback onPressed;

  final Color accentColor;

  const _ScrollDiscoveryControl({
    super.key,
    required this.mode,
    required this.label,
    required this.onPressed,
    required this.accentColor,
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
                      const Color(
                    0xFF173B66,
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
                      widget.label.toUpperCase(),

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

  const _ScrollArrowCircle({
    required this.icon,
    required this.pressed,
    required this.accentColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final Color darkColor =
        Color.lerp(
              accentColor,
              Colors.black,
              0.18,
            ) ??
            accentColor;

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