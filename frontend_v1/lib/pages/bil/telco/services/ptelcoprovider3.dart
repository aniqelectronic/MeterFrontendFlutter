// ============================================================================
// TELCO PROVIDER SELECTION PAGE
// ============================================================================
//
// Shared provider selection page for:
// - Telco Bill Payment
// - Mobile PIN
//
// This page:
// - displays available Telco providers;
// - loads provider logos from IIMMPACT;
// - checks each provider's network/service status using
//   IimmpactNetworkStatusService;
// - displays the current network status;
// - warns the user when a provider has a service interruption;
// - rechecks the provider status when the user selects a provider.
//
// The actual payment / Mobile PIN process is handled by the next page.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/pages/bil/telco/ptelco4.dart';
import 'package:frontend_v1/pages/bil/telco/mobilepin/pmobilepin4.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

enum TelcoBillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

class TelcoProviderItem {
  final String productCode;
  final String name;
  final String imageUrl;
  final Color accentColor;
  final Color lightAccentColor;

  const TelcoProviderItem({
    required this.productCode,
    required this.name,
    required this.imageUrl,
    required this.accentColor,
    required this.lightAccentColor,
  });
}

class PTELCOPROVIDER3PAGE extends StatefulWidget {
  final String serviceLabel;
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final Color headerColor;
  final List<TelcoProviderItem> providers;

  final TelcoInputType inputType;

  const PTELCOPROVIDER3PAGE({
    super.key,
    required this.serviceLabel,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.headerColor,
    required this.providers,
    required this.inputType,
  });

  @override
  State<PTELCOPROVIDER3PAGE> createState() =>
      _PTELCOPROVIDER3PAGEState();
}

class _PTELCOPROVIDER3PAGEState
    extends State<PTELCOPROVIDER3PAGE> {
  final Map<String, TelcoBillerStatus> _billerStatuses = {};
  final Map<String, String?> _lastUpdated = {};

  // ==========================================================================
  // PROCESSING TIME FROM IIMMPACT CATALOG
  // ==========================================================================
  final Map<String, String> _processingTimes = {};

  final ScrollController _scrollController = ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = true;

  @override
  void initState() {
    super.initState();

    for (final provider in widget.providers) {
      _billerStatuses[provider.productCode] =
          TelcoBillerStatus.loading;
    }

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialNetworkStatuses();

      _loadCatalogProcessingTimes();

      _handleScroll();
    });
  }

  // ============================================================
  // LOAD PROCESSING TIME FROM IIMMPACT CATALOG
  // ============================================================
  Future<void> _loadCatalogProcessingTimes() async {
    try {
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      final dynamic productsRaw = catalog['products'];

      if (productsRaw is! Map) {
        debugPrint(
          'Telco catalog error: products not found.',
        );
        return;
      }

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final Map<String, String> loadedTimes = {};

      // IMPORTANT:
      // Reuse whatever providers were passed into this page.
      //
      // Example Bill Payment:
      // CB, DB, RB, UB, XB, YESB
      //
      // Mobile PIN will automatically use its own
      // product codes.
      for (final TelcoProviderItem provider
          in widget.providers) {
        final dynamic rawProduct =
            products[provider.productCode];

        if (rawProduct is! Map) {
          debugPrint(
            'Telco catalog product not found: '
            '${provider.productCode}',
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
          loadedTimes[provider.productCode] =
              processingTime;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _processingTimes
          ..clear()
          ..addAll(loadedTimes);
      });

      debugPrint(
        'Telco processing times loaded: '
        '$_processingTimes',
      );
    } on IimmpactCatalogException catch (error) {
      debugPrint(
        'Telco catalog error: ${error.message}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected Telco catalog error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // SCROLL POSITION
  // ============================================================
  void _handleScroll() {
    if (!_scrollController.hasClients || !mounted) {
      return;
    }

    final double maxScroll =
        _scrollController.position.maxScrollExtent;

    final double currentScroll =
        _scrollController.offset;

    final bool shouldShowScrollUp =
        currentScroll > 10;

    final bool shouldShowScrollDown =
        currentScroll < maxScroll - 10;

    if (showScrollUp != shouldShowScrollUp ||
        showScrollDown != shouldShowScrollDown) {
      setState(() {
        showScrollUp = shouldShowScrollUp;
        showScrollDown = shouldShowScrollDown;
      });
    }
  }

  // ============================================================
  // INITIAL NETWORK CHECK
  // ============================================================
  Future<void> _loadInitialNetworkStatuses() async {
    await Future.wait(
      widget.providers.map(
        (provider) =>
            _refreshNetworkStatus(provider.productCode),
      ),
    );
  }

  // ============================================================
  // REFRESH NETWORK STATUS
  // ============================================================
  Future<TelcoBillerStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            TelcoBillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final TelcoBillerStatus status =
          result.isHealthy
              ? TelcoBillerStatus.healthy
              : TelcoBillerStatus.interruption;

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] = status;
          _lastUpdated[productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Telco network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              TelcoBillerStatus.unavailable;
        });
      }

      return TelcoBillerStatus.unavailable;
    }
  }

  // ============================================================
  // NETWORK INTERRUPTION WARNING
  // ============================================================
  Future<bool> _showInterruptionWarning({
    required String billerName,
    required String productCode,
  }) async {
    final loc = AppLocalizations.of(context)!;

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 80),
          child: Container(
            width: 800,
            padding: const EdgeInsets.fromLTRB(
              45,
              42,
              45,
              38,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: const Color(0xFFF2A520),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2D9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF2A520)
                          .withOpacity(0.30),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD87900),
                    size: 78,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  loc.networkInterruptionTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF17283E),
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 25,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9ED),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF4D69D),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    loc.networkInterruptionMessage(
                      billerName,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4B4234),
                      fontSize: 29,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (_lastUpdated[productCode] != null) ...[
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 24,
                        color: Color(0xFF758399),
                      ),

                      const SizedBox(width: 8),

                      Flexible(
                        child: Text(
                          '${loc.networkLastUpdated}: '
                          '${_lastUpdated[productCode]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            color: Color(0xFF758399),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 36),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 29,
                          ),
                          label: Text(
                            loc.backButton,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFFE8E8),
                            foregroundColor:
                                const Color(0xFFC62828),
                            side: const BorderSide(
                              color: Color(0xFFE57373),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 22),

                    Expanded(
                      child: SizedBox(
                        height: 78,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 29,
                          ),
                          label: Text(
                            loc.continueButton,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF168A50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(22),
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

// ============================================================
// PROVIDER PRESS
// ============================================================

Future<void> _handleProviderTap(
  TelcoProviderItem provider,
) async {
  // ==========================================================
  // 1. CHECK PROVIDER NETWORK STATUS AGAIN
  // ==========================================================

  final TelcoBillerStatus status =
      await _refreshNetworkStatus(
    provider.productCode,
  );

  if (!mounted) {
    return;
  }

  // ==========================================================
  // 2. INTERRUPTION WARNING
  // ==========================================================

  if (status ==
      TelcoBillerStatus.interruption) {
    final bool shouldContinue =
        await _showInterruptionWarning(
      billerName: provider.name,
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

  // ==========================================================
  // 3. MOBILE PIN
  //
  // Mobile PIN does NOT require phone/account input.
  //
  // Go directly to:
  // denomination -> quantity -> summary.
  // ==========================================================

  if (widget.inputType ==
      TelcoInputType.mobilePin) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
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

  // ==========================================================
  // 4. TELCO POSTPAID BILL
  //
  // Bill payment still requires account/mobile input.
  // ==========================================================

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
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

  // ============================================================
  // SCROLL
  // ============================================================
  void _scrollUp() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double destination =
        (_scrollController.offset - 600).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double destination =
        (_scrollController.offset + 600).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD PROVIDER ROWS
  // ============================================================
  List<Widget> _buildProviderRows(
    AppLocalizations loc,
  ) {
    final List<Widget> rows = [];

    for (int i = 0; i < widget.providers.length; i += 2) {
      final TelcoProviderItem left =
          widget.providers[i];

      final TelcoProviderItem? right =
          i + 1 < widget.providers.length
              ? widget.providers[i + 1]
              : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TelcoProviderCard(
              provider: left,

              networkStatus:
                  _billerStatuses[left.productCode] ??
                      TelcoBillerStatus.loading,

              networkLabel:
                  loc.networkLabel,

              // NEW
              processingTime:
                  _processingTimes[left.productCode] ?? '',

              processingLabel:
                  loc.processingTimeLabel,

              onPressed: () =>
                  _handleProviderTap(left),
            ),
            ),

            const SizedBox(width: 34),

            Expanded(
              child: right == null
                  ? const SizedBox()
                  : _TelcoProviderCard(
                    provider: right,

                    networkStatus:
                        _billerStatuses[
                                right.productCode] ??
                            TelcoBillerStatus.loading,

                    networkLabel:
                        loc.networkLabel,

                    processingTime:
                        _processingTimes[right.productCode] ?? '',

                    processingLabel:
                        loc.processingTimeLabel,

                    onPressed: () =>
                        _handleProviderTap(right),
                  ),
            ),
          ],
        ),
      );

      if (i + 2 < widget.providers.length) {
        rows.add(
          const SizedBox(height: 36),
        );
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND
          // ============================================================
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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.02),
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // HEADER
          // ============================================================
          Positioned(
            top: 40,
            left: 40,
            right: 40,
            child: _TelcoModernHeader(
              serviceLabel: widget.serviceLabel,
              title: widget.title,
              subtitle: widget.subtitle,
              icon: widget.headerIcon,
              accentColor: widget.headerColor,
            ),
          ),

          // ============================================================
          // PROVIDERS
          // ============================================================
          Positioned(
            top: 450,
            left: 45,
            right: 45,
            bottom: 305,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              thickness: 11,
              radius: const Radius.circular(20),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  right: 24,
                  bottom: 55,
                ),
                child: Column(
                  children: _buildProviderRows(loc),
                ),
              ),
            ),
          ),

          // ============================================================
          // SCROLL UP
          // ============================================================
          if (showScrollUp)
            Positioned(
              right: 18,
              top: 365,
              child: _ScrollIndicatorButton(
                icon: Icons.keyboard_arrow_up_rounded,
                label: loc.scrollup,
                onPressed: _scrollUp,
              ),
            ),

          // ============================================================
          // SCROLL DOWN
          // ============================================================
          if (showScrollDown)
            Positioned(
              right: 18,
              bottom: 290,
              child: _ScrollIndicatorButton(
                icon:
                    Icons.keyboard_arrow_down_rounded,
                label: loc.scrolldown,
                onPressed: _scrollDown,
                iconBelowText: true,
              ),
            ),

          // ============================================================
          // BACK
          // ============================================================
          Positioned(
            bottom: 105,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // ============================================================
          // COPYRIGHT
          // ============================================================
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF26364A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
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
// HEADER
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: accentColor.withOpacity(0.24),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 25,
              ),
              const SizedBox(width: 9),
              Text(
                serviceLabel.toUpperCase(),
                style: TextStyle(
                  color: accentColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                accentColor,
                accentColor.withOpacity(0.72),
              ],
            ).createShader(bounds);
          },
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.8,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Container(
          constraints: const BoxConstraints(
            maxWidth: 850,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.91),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: Colors.black.withOpacity(0.17),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF113968).withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Text(
            subtitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF435166),
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
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
class _TelcoProviderCard extends StatefulWidget {
  final TelcoProviderItem provider;
  final VoidCallback onPressed;
  final TelcoBillerStatus networkStatus;
  final String networkLabel;

  final String processingTime;
  final String processingLabel;

  const _TelcoProviderCard({
    required this.provider,
    required this.onPressed,
    required this.networkStatus,
    required this.networkLabel,
    required this.processingTime,
    required this.processingLabel,
  });

  @override
  State<_TelcoProviderCard> createState() =>
      _TelcoProviderCardState();
}

class _TelcoProviderCardState
    extends State<_TelcoProviderCard> {
  bool _isPressed = false;

  // ============================================================
  // FORMAT PROCESSING TIME
  // ============================================================
  String _formatProcessingTime(
    BuildContext context,
    String value,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    final String normalized =
        value.toLowerCase().trim();

    if (normalized == 'instant') {
      return loc.processingInstant;
    }

    if (normalized == '24_hours') {
      return loc.processing24Hours;
    }

    if (normalized == '3_days') {
      return loc.processing3Days;
    }

    // Other values such as:
    // 2_hours
    // 6_hours
    // 48_hours
    if (normalized.endsWith('_hours')) {
      final String hours =
          normalized.replaceAll(
        '_hours',
        '',
      );

      return loc.telcoUpdateWithinHours(
        hours,
      );
    }

    // Other values such as:
    // 2_days
    // 5_days
    if (normalized.endsWith('_days')) {
      final String days =
          normalized.replaceAll(
        '_days',
        '',
      );

      return loc.telcoUpdateWithinDays(
        days,
      );
    }

    // Safe fallback if IIMMPACT introduces
    // another processing_time value.
    return value.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() => _isPressed = true);
      },

      onTapUp: (_) {
        setState(() => _isPressed = false);
      },

      onTapCancel: () {
        setState(() => _isPressed = false);
      },

      onTap: widget.onPressed,

      child: AnimatedScale(
        scale: _isPressed ? 0.965 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          height: 480,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: _isPressed
                  ? provider.accentColor
                  : Colors.black,
              width: _isPressed ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF19375C)
                    .withOpacity(0.16),
                blurRadius: 30,
                spreadRadius: 1,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(37),
            child: Stack(
              children: [
                Positioned(
                  right: -50,
                  top: -50,
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),
                    width: _isPressed ? 225 : 210,
                    height: _isPressed ? 225 : 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.lightAccentColor
                          .withOpacity(0.90),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    28,
                    30,
                    28,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 220,
                            height: 180,
                            padding:
                                const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(34),
                              border: Border.all(
                                color: provider.accentColor
                                    .withOpacity(0.20),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.08),
                                  blurRadius: 16,
                                  offset:
                                      const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.network(
                              provider.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Icon(
                                  Icons.sim_card_rounded,
                                  size: 90,
                                  color:
                                      provider.accentColor,
                                );
                              },
                            ),
                          ),

                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 160),
                            transform:
                                Matrix4.translationValues(
                              _isPressed ? 6 : 0,
                              0,
                              0,
                            ),
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: provider.accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          provider.name.toUpperCase(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF15253A),
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
                            height: 1.10,
                          ),
                        ),
                      ),

                      const SizedBox(height: 21),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: _NetworkStatusBadge(
                          status: widget.networkStatus,
                          label: widget.networkLabel,
                        ),
                      ),

                      // ====================================================
                      // PROCESSING TIME
                      // ====================================================
                      if (widget.processingTime.isNotEmpty) ...[
                        const SizedBox(height: 14),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 22,
                                color: Color(0xFF647187),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  '${widget.processingLabel}: '
                                  '${_formatProcessingTime(
                                    context,
                                    widget.processingTime,
                                  )}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF647187),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 7,
                            decoration: BoxDecoration(
                              color: provider.accentColor,
                              borderRadius:
                                  BorderRadius.circular(50),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 13,
                            height: 7,
                            decoration: BoxDecoration(
                              color: provider.accentColor
                                  .withOpacity(0.28),
                              borderRadius:
                                  BorderRadius.circular(50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NETWORK STATUS
// ============================================================================
class _NetworkStatusBadge extends StatelessWidget {
  final TelcoBillerStatus status;
  final String label;

  const _NetworkStatusBadge({
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    late final String statusText;
    late final Color backgroundColor;
    late final Color borderColor;
    late final Color foregroundColor;
    late final IconData icon;

    switch (status) {
      case TelcoBillerStatus.loading:
        statusText = loc.networkStatusChecking;
        backgroundColor = const Color(0xFFF0F4F8);
        borderColor = const Color(0xFFC7D2DE);
        foregroundColor = const Color(0xFF536272);
        icon = Icons.sync_rounded;
        break;

      case TelcoBillerStatus.healthy:
        statusText = loc.networkStatusGood;
        backgroundColor = const Color(0xFFE2F8EC);
        borderColor = const Color(0xFF78C99B);
        foregroundColor = const Color(0xFF08783E);
        icon = Icons.check_circle_rounded;
        break;

      case TelcoBillerStatus.interruption:
        statusText = loc.networkStatusSlow;
        backgroundColor = const Color(0xFFFFF0D7);
        borderColor = const Color(0xFFF1B95D);
        foregroundColor = const Color(0xFFB75B00);
        icon = Icons.warning_amber_rounded;
        break;

      case TelcoBillerStatus.unavailable:
        statusText = loc.networkStatusUnknown;
        backgroundColor = const Color(0xFFF1F1F1);
        borderColor = const Color(0xFFC8C8C8);
        foregroundColor = const Color(0xFF555555);
        icon = Icons.help_outline_rounded;
        break;
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: 58,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: borderColor,
          width: 1.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == TelcoBillerStatus.loading)
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: foregroundColor,
              ),
            )
          else
            Icon(
              icon,
              size: 28,
              color: foregroundColor,
            ),

          const SizedBox(width: 9),

          Flexible(
            child: Text(
              '$label: $statusText',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
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
class _ScrollIndicatorButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final Widget iconWidget = Icon(
      icon,
      size: 52,
      color: const Color(0xFF1469E8),
    );

    final Widget textWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF15253A),
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );

    return Material(
      color: Colors.white.withOpacity(0.96),
      borderRadius: BorderRadius.circular(22),
      elevation: 5,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: iconBelowText
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