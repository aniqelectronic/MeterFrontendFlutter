import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/ewallet/pewallet4.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/modern_provider_card.dart';

// ============================================================================
// E-WALLET PROVIDER MODEL
// ============================================================================
//
// Keep current E-Wallet provider structure:
//
// TNG
//   -> Touch 'n Go PIN
//
// TNGD
//   -> Touch 'n Go PINLESS
//
// TRUE
//   -> TrueMoney E-Wallet
//
// Processing time still comes from:
//
// /v2/catalog
//
// ============================================================================

class _EWalletProvider {
  final String productCode;
  final String providerName;
  final String imageUrl;

  final Color accentColor;
  final Color lightAccentColor;

  const _EWalletProvider({
    required this.productCode,
    required this.providerName,
    required this.imageUrl,
    required this.accentColor,
    required this.lightAccentColor,
  });
}

// ============================================================================
// PAGE
// ============================================================================

class PEWALLET3PAGE extends StatefulWidget {
  const PEWALLET3PAGE({
    super.key,
  });

  @override
  State<PEWALLET3PAGE> createState() =>
      _PEWALLET3PAGEState();
}

// ============================================================================
// STATE
// ============================================================================

class _PEWALLET3PAGEState
    extends State<PEWALLET3PAGE> {
  // ==========================================================================
  // PROVIDERS
  // ==========================================================================

  static const _EWalletProvider _tngProvider =
      _EWalletProvider(
    productCode: 'TNG',

    providerName: "TOUCH 'N GO PIN",

    imageUrl:
        'https://dashboard.iimmpact.com/img/TNG.png',

    accentColor:
        Color(
      0xFF1469E8,
    ),

    lightAccentColor:
        Color(
      0xFFE5F0FF,
    ),
  );

  static const _EWalletProvider _tngdProvider =
      _EWalletProvider(
    productCode: 'TNGD',

    providerName: "TOUCH 'N GO PINLESS",

    imageUrl:
        'https://dashboard.iimmpact.com/img/TNGD.png',

    accentColor:
        Color(
      0xFF00AEEF,
    ),

    lightAccentColor:
        Color(
      0xFFE5F8FF,
    ),
  );

  static const _EWalletProvider _trueProvider =
      _EWalletProvider(
    productCode: 'TRUE',

    providerName: 'TRUEMONEY E-WALLET',

    imageUrl:
        'https://dashboard.iimmpact.com/img/TRUE.png',

    accentColor:
        Color(
      0xFFFF6D00,
    ),

    lightAccentColor:
        Color(
      0xFFFFE9D9,
    ),
  );

  static const List<_EWalletProvider> _providers = [
    _tngProvider,
    _tngdProvider,
    _trueProvider,
  ];

  // ==========================================================================
  // NETWORK
  //
  // Uses shared ProviderNetworkStatus from:
  //
  // modern_provider_card.dart
  // ==========================================================================

  final Map<String, ProviderNetworkStatus> _statuses = {
    'TNG':
        ProviderNetworkStatus.loading,

    'TNGD':
        ProviderNetworkStatus.loading,

    'TRUE':
        ProviderNetworkStatus.loading,
  };

  final Map<String, String?> _lastUpdated = {};

  // ==========================================================================
  // PROCESSING TIMES
  // ==========================================================================

  final Map<String, String> _processingTimes = {};

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
    0xFFEF6C35,
  );

  static const Color _darkColor =
      Color(
    0xFFD35400,
  );

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
        _loadInitialStatuses();

        _loadCatalogProcessingTimes();

        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            _handleScroll();
          },
        );
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
  // LOAD E-WALLET PROCESSING TIMES
  // ==========================================================================

  Future<void> _loadCatalogProcessingTimes() async {
    try {
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        debugPrint(
          'E-Wallet catalog error: products not found.',
        );

        return;
      }

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final Map<String, String> loadedTimes = {};

      for (final _EWalletProvider provider
          in _providers) {
        final String code =
            provider.productCode;

        final dynamic rawProduct =
            products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'E-Wallet catalog product not found: '
            '$code',
          );

          continue;
        }

        final Map<String, dynamic> product =
            Map<String, dynamic>.from(
          rawProduct,
        );

        final String processingTime =
            product['processing_time']
                    ?.toString()
                    .trim() ??
                '';

        if (processingTime.isNotEmpty) {
          loadedTimes[code] =
              processingTime;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _processingTimes
          ..clear()
          ..addAll(
            loadedTimes,
          );
      });

      debugPrint(
        'E-Wallet processing times loaded: '
        '$_processingTimes',
      );

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _handleScroll();
        },
      );
    }

    on IimmpactCatalogException catch (error) {
      debugPrint(
        'E-Wallet catalog error: '
        '${error.message}',
      );
    }

    catch (error, stackTrace) {
      debugPrint(
        'Unexpected E-Wallet catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );
    }
  }

  // ==========================================================================
  // INITIAL NETWORK STATUS
  // ==========================================================================

  Future<void> _loadInitialStatuses() async {
    await Future.wait(
      _providers.map(
        (
          _EWalletProvider provider,
        ) {
          return _refreshStatus(
            provider.productCode,
          );
        },
      ),
    );
  }

  // ==========================================================================
  // REFRESH NETWORK STATUS
  // ==========================================================================

  Future<ProviderNetworkStatus> _refreshStatus(
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
    } catch (error, stackTrace) {
      debugPrint(
        'E-Wallet network status error '
        'for $productCode: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
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
  // E-WALLET PROCESSING TIME FORMATTER
  //
  // Keeps the existing E-Wallet-specific ARB translations.
  // ==========================================================================

  String _formatEWalletProcessingTime(
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

      return loc.eWalletUpdateWithinHours(
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

      return loc.eWalletUpdateWithinDays(
        days,
      );
    }

    return value.replaceAll(
      '_',
      ' ',
    );
  }

  // ==========================================================================
  // NETWORK INTERRUPTION WARNING
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
  // PROVIDER TAP
  //
  // IMPORTANT:
  //
  // Existing E-Wallet flow is preserved.
  // ==========================================================================

  Future<void> _handleProviderTap(
    _EWalletProvider provider,
  ) async {
    // ========================================================================
    // REFRESH STATUS
    // ========================================================================

    final ProviderNetworkStatus status =
        await _refreshStatus(
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
        providerName:
            provider.providerName,

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
    // KEEP ORIGINAL PAGE 4 FLOW
    // ========================================================================

    await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (_) =>
                PEWALLET4PAGE(
          productCode:
              provider.productCode,

          providerName:
              provider.providerName,

          providerImageUrl:
              provider.imageUrl,
        ),
      ),
    );
  }

  // ==========================================================================
  // SCROLL POSITION
  // ==========================================================================

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        !mounted) {
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
    // LIHAT LAGI
    // ========================================================================

    if (!showScrollUp &&
        showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'ewallet-top-more',
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

    if (showScrollUp &&
        showScrollDown) {
      return Row(
        key:
            const ValueKey(
          'ewallet-middle-controls',
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

    if (showScrollUp &&
        !showScrollDown) {
      return _ScrollDiscoveryControl(
        key:
            const ValueKey(
          'ewallet-bottom-top',
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
  // BUILD PROVIDER CARD
  // ==========================================================================

  Widget _buildProviderCard({
    required _EWalletProvider provider,
    required String displayLabel,
    required AppLocalizations loc,
  }) {
    return ModernProviderCard(
      imageUrl:
          provider.imageUrl,

      label:
          displayLabel,

      accentColor:
          provider.accentColor,

      lightAccentColor:
          provider.lightAccentColor,

      networkStatus:
          _statuses[
                  provider.productCode] ??
              ProviderNetworkStatus.loading,

      networkLabel:
          loc.networkLabel,

      processingTime:
          _processingTimes[
                  provider.productCode] ??
              '',

      processingLabel:
          loc.processingTimeLabel,

      // ======================================================================
      // E-WALLET PROCESSING TRANSLATION
      // ======================================================================

      processingTimeFormatter:
          _formatEWalletProcessingTime,

      fallbackIcon:
          Icons.account_balance_wallet_rounded,

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
                82,

            left:
                65,

            right:
                65,

            child:
                _ModernEWalletHeader(
              title:
                  loc.eWalletProviderTitle,

              subtitle:
                  loc.eWalletProviderSubtitle,
            ),
          ),

          // ==================================================================
          // PROVIDER AREA
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
                Scrollbar(
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

                  // ==========================================================
                  // Extra bottom space for modern scroll control.
                  // ==========================================================

                  bottom:
                      145,
                ),

                child:
                    Column(
                  children: [
                    // ========================================================
                    // ROW 1
                    //
                    // TNG PIN + TNG PINLESS
                    // ========================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        // ====================================================
                        // TNG PIN
                        // ====================================================

                        Expanded(
                          child:
                              _buildProviderCard(
                            provider:
                                _tngProvider,

                            displayLabel:
                                loc.touchNGoPin,

                            loc:
                                loc,
                          ),
                        ),

                        const SizedBox(
                          width:
                              34,
                        ),

                        // ====================================================
                        // TNG PINLESS
                        // ====================================================

                        Expanded(
                          child:
                              _buildProviderCard(
                            provider:
                                _tngdProvider,

                            displayLabel:
                                loc.touchNGoPinless,

                            loc:
                                loc,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height:
                          36,
                    ),

                    // ========================================================
                    // ROW 2
                    //
                    // TRUE MONEY
                    // ========================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child:
                              _buildProviderCard(
                            provider:
                                _trueProvider,

                            displayLabel:
                                loc.trueMoneyEWallet,

                            loc:
                                loc,
                          ),
                        ),

                        const SizedBox(
                          width:
                              34,
                        ),

                        const Expanded(
                          child:
                              SizedBox(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================================
          // CONTENT FADE
          // ==================================================================

          if (showScrollDown)
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
}

// ============================================================================
// E-WALLET HEADER
// ============================================================================

class _ModernEWalletHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernEWalletHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color accentColor =
        Color(
      0xFFEF6C35,
    );

    const Color darkAccent =
        Color(
      0xFFD35400,
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
                    0xFFFF8A3D,
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
              Icons.account_balance_wallet_rounded,

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
                        const Color(
                      0xFFFFEFE7,
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
                        Icons.account_balance_wallet_rounded,

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
                          loc.eWalletServiceLabel
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
                    0xFFFF8A3D,
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
// MODERN SCROLL CONTROL
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
                          0xFF6F3015,
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