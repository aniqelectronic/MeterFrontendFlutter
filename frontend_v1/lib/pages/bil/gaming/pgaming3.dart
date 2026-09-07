import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:frontend_v1/pages/bil/gaming/pgaming4.dart';

// ============================================================================
// GAMING PLATFORM STATUS
// ============================================================================
enum GamingStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

// ============================================================================
// GAMING PLATFORM MODEL
// ============================================================================
class GamingPlatform {
  final String productCode;
  final String name;
  final String imageUrl;
  final String processingTime;
  final bool isActive;

  const GamingPlatform({
    required this.productCode,
    required this.name,
    required this.imageUrl,
    required this.processingTime,
    required this.isActive,
  });
}

// ============================================================================
// GAMING PLATFORM PAGE
// SAME DESIGN / FLOW AS ELECTRIC PAGE
// ============================================================================
class PGAMING3PAGE extends StatefulWidget {
  const PGAMING3PAGE({super.key});

  @override
  State<PGAMING3PAGE> createState() => _PGAMING3PAGEState();
}

class _PGAMING3PAGEState extends State<PGAMING3PAGE> {
  // ==========================================================================
  // DATA
  // ==========================================================================

  final List<GamingPlatform> _platforms = [];

  final Map<String, GamingStatus> _platformStatuses = {};
  final Map<String, String?> _lastUpdated = {};

  bool _isLoadingCatalog = true;

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  final ScrollController _scrollController = ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = true;

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGamingPlatforms();
      _handleScroll();
    });
  }

  // ==========================================================================
  // LOAD GAMING PLATFORMS FROM /v2/catalog
  //
  // It reads:
  //
  // GAMES
  //   -> GAMING_PLATFORMS
  //      -> product_codes
  //
  // Then gets product:
  // - name
  // - image_url
  // - processing_time
  // - is_active
  // ==========================================================================

  Future<void> _loadGamingPlatforms() async {
    if (mounted) {
      setState(() {
        _isLoadingCatalog = true;
      });
    }

    try {
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      final dynamic treeRaw = catalog['tree'];
      final dynamic productsRaw = catalog['products'];

      if (treeRaw is! Map || productsRaw is! Map) {
        debugPrint(
          'Gaming catalog error: tree/products not found.',
        );

        if (mounted) {
          setState(() {
            _isLoadingCatalog = false;
          });
        }

        return;
      }

      final Map<String, dynamic> tree =
          Map<String, dynamic>.from(treeRaw);

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(productsRaw);

      final dynamic groupsRaw = tree['groups'];

      if (groupsRaw is! List) {
        debugPrint(
          'Gaming catalog error: groups not found.',
        );

        if (mounted) {
          setState(() {
            _isLoadingCatalog = false;
          });
        }

        return;
      }

      List<String> gamingProductCodes = [];

      for (final dynamic rawGroup in groupsRaw) {
        if (rawGroup is! Map) {
          continue;
        }

        final Map<String, dynamic> group =
            Map<String, dynamic>.from(rawGroup);

        if (group['id']?.toString() != 'GAMES') {
          continue;
        }

        final dynamic categoriesRaw = group['categories'];

        if (categoriesRaw is! List) {
          continue;
        }

        for (final dynamic rawCategory in categoriesRaw) {
          if (rawCategory is! Map) {
            continue;
          }

          final Map<String, dynamic> category =
              Map<String, dynamic>.from(rawCategory);

          if (category['id']?.toString() !=
              'GAMING_PLATFORMS') {
            continue;
          }

          final dynamic productCodesRaw =
              category['product_codes'];

          if (productCodesRaw is List) {
            gamingProductCodes = productCodesRaw
                .map(
                  (dynamic code) =>
                      code.toString().trim(),
                )
                .where(
                  (String code) => code.isNotEmpty,
                )
                .toList();
          }

          break;
        }

        break;
      }

      final List<GamingPlatform> loadedPlatforms = [];

      for (final String code in gamingProductCodes) {
        final dynamic rawProduct = products[code];

        if (rawProduct is! Map) {
          debugPrint(
            'Gaming product not found: $code',
          );
          continue;
        }

        final Map<String, dynamic> product =
            Map<String, dynamic>.from(rawProduct);

        loadedPlatforms.add(
          GamingPlatform(
            productCode: code,
            name:
                product['name']?.toString().trim().isNotEmpty ==
                        true
                    ? product['name']
                        .toString()
                        .trim()
                    : code,
            imageUrl:
                product['image_url']?.toString().trim() ?? '',
            processingTime:
                product['processing_time']
                        ?.toString()
                        .trim() ??
                    '',
            isActive: product['is_active'] == true,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _platforms
          ..clear()
          ..addAll(loadedPlatforms);

        _platformStatuses.clear();

        for (final GamingPlatform platform
            in loadedPlatforms) {
          _platformStatuses[platform.productCode] =
              platform.isActive
                  ? GamingStatus.loading
                  : GamingStatus.unavailable;
        }

        _isLoadingCatalog = false;
      });

      // Same concept as Electricity:
      // load network status for every active provider.
      await Future.wait(
        loadedPlatforms
            .where(
              (GamingPlatform platform) =>
                  platform.isActive,
            )
            .map(
              (GamingPlatform platform) =>
                  _refreshNetworkStatus(
                platform.productCode,
              ),
            ),
      );

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleScroll();
        });
      }
    } on IimmpactCatalogException catch (error) {
      debugPrint(
        'Gaming catalog error: ${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCatalog = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected gaming catalog error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCatalog = false;
      });
    }
  }

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  Future<GamingStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _platformStatuses[productCode] =
            GamingStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final GamingStatus status = result.isHealthy
          ? GamingStatus.healthy
          : GamingStatus.interruption;

      if (mounted) {
        setState(() {
          _platformStatuses[productCode] = status;
          _lastUpdated[productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _platformStatuses[productCode] =
              GamingStatus.unavailable;
        });
      }

      return GamingStatus.unavailable;
    }
  }

  // ==========================================================================
  // INTERRUPTION WARNING
  // SAME AS ELECTRIC
  // ==========================================================================

  Future<bool> _showInterruptionWarning({
    required String platformName,
    required String productCode,
  }) async {
    final loc = AppLocalizations.of(context)!;

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 80,
          ),
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
                      platformName,
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

  // ==========================================================================
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handlePlatformTap(
    GamingPlatform platform,
  ) async {
    if (!platform.isActive) {
      return;
    }

    final GamingStatus status =
        await _refreshNetworkStatus(
      platform.productCode,
    );

    if (!mounted) {
      return;
    }

    if (status == GamingStatus.interruption) {
      final bool shouldContinue =
          await _showInterruptionWarning(
        platformName: platform.name,
        productCode: platform.productCode,
      );

      if (!shouldContinue) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PGAMING4PAGE(
          productCode: platform.productCode,
          platformName: platform.name,
          imageUrl: platform.imageUrl,
        ),
      ),
    );
  }

  // ==========================================================================
  // SCROLL POSITION
  // ==========================================================================

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

  // ==========================================================================
  // SCROLL UP
  // ==========================================================================

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
      duration: const Duration(
        milliseconds: 400,
      ),
      curve: Curves.easeOut,
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
        (_scrollController.offset + 600).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration: const Duration(
        milliseconds: 400,
      ),
      curve: Curves.easeOut,
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
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================
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

          // ==================================================================
          // HEADER
          // SAME POSITION AS ELECTRIC
          // ==================================================================
          Positioned(
            top: 82,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              title: loc.gamingPlatformButton,
              subtitle: loc.gamingPlatformSupportingText,
            ),
          ),

          // ==================================================================
          // PLATFORM AREA
          // SAME POSITION AS ELECTRIC
          // ==================================================================
          Positioned(
            top: 400,
            left: 45,
            right: 45,
            bottom: 305,
            child: _isLoadingCatalog
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: Color(0xFF7048E8),
                    ),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    interactive: true,
                    thickness: 11,
                    radius: const Radius.circular(20),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics:
                          const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        right: 24,
                        bottom: 55,
                      ),
                      child: Column(
                        children: _buildPlatformRows(
                          loc,
                        ),
                      ),
                    ),
                  ),
          ),

          // ==================================================================
          // SCROLL UP
          // ==================================================================
          if (showScrollUp)
            Positioned(
              right: 18,
              top: 365,
              child: _ScrollIndicatorButton(
                icon:
                    Icons.keyboard_arrow_up_rounded,
                label: loc.scrollup,
                onPressed: _scrollUp,
              ),
            ),

          // ==================================================================
          // SCROLL DOWN
          // ==================================================================
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

          // ==================================================================
          // BACK
          // SAME AS ELECTRIC
          // ==================================================================
          Positioned(
            bottom: 105,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PBIL3PAGE(),
                  ),
                );
              },
            ),
          ),

          // ==================================================================
          // FOOTER
          // ==================================================================
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

  // ==========================================================================
  // BUILD 2-COLUMN ROWS
  // ==========================================================================

  List<Widget> _buildPlatformRows(
    AppLocalizations loc,
  ) {
    final List<Widget> widgets = [];

    for (int i = 0; i < _platforms.length; i += 2) {
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
            Expanded(
              child: _GamingProviderCard(
                platform: left,
                networkStatus:
                    _platformStatuses[
                            left.productCode] ??
                        GamingStatus.loading,
                networkLabel: loc.networkLabel,
                processingLabel:
                    loc.processingTimeLabel,
                onPressed: () {
                  _handlePlatformTap(left);
                },
              ),
            ),

            const SizedBox(width: 34),

            Expanded(
              child: right == null
                  ? const SizedBox()
                  : _GamingProviderCard(
                      platform: right,
                      networkStatus:
                          _platformStatuses[
                                  right.productCode] ??
                              GamingStatus.loading,
                      networkLabel:
                          loc.networkLabel,
                      processingLabel:
                          loc.processingTimeLabel,
                      onPressed: () {
                        _handlePlatformTap(right);
                      },
                    ),
            ),
          ],
        ),
      );

      if (i + 2 < _platforms.length) {
        widgets.add(
          const SizedBox(height: 36),
        );
      }
    }

    return widgets;
  }
}

// ============================================================================
// MODERN HEADER
// SAME STRUCTURE AS ELECTRIC
// ============================================================================
class _ModernPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernPageHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor =
        Color(0xFF7048E8);

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
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
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.sports_esports_rounded,
                color: accentColor,
                size: 25,
              ),

              const SizedBox(
                width: 9,
              ),

              Text(
                AppLocalizations.of(context)!
                    .gamingPlatformButton
                    .toUpperCase(),
                style: const TextStyle(
                  color: accentColor,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 17,
        ),

        ShaderMask(
          blendMode:
              BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF5630C7),
                Color(0xFF8B5CF6),
              ],
            ).createShader(
              bounds,
            );
          },
          child: Text(
            title.toUpperCase(),
            textAlign:
                TextAlign.center,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 62,
              fontWeight:
                  FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.8,
            ),
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        Container(
          constraints:
              const BoxConstraints(
            maxWidth: 850,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 14,
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
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF113968,
                ).withOpacity(
                  0.10,
                ),
                blurRadius: 22,
                offset:
                    const Offset(
                  0,
                  9,
                ),
              ),
            ],
          ),
          child: Text(
            subtitle.toUpperCase(),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF435166,
              ),
              fontSize: 28,
              fontWeight:
                  FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// GAMING PROVIDER CARD
// SAME SIZE / STRUCTURE AS ELECTRIC
// ============================================================================
class _GamingProviderCard
    extends StatefulWidget {
  final GamingPlatform platform;

  final VoidCallback onPressed;

  final GamingStatus networkStatus;
  final String networkLabel;

  final String processingLabel;

  const _GamingProviderCard({
    super.key,
    required this.platform,
    required this.onPressed,
    required this.networkStatus,
    required this.networkLabel,
    required this.processingLabel,
  });

  @override
  State<_GamingProviderCard>
      createState() =>
          _GamingProviderCardState();
}

// ============================================================================
// CARD STATE
// ============================================================================
class _GamingProviderCardState
    extends State<_GamingProviderCard> {
  bool _isPressed = false;

  bool get _isEnabled =>
      widget.platform.isActive;

  // ==========================================================================
  // PRESS STATE
  // ==========================================================================

  void _changePressedState(
    bool value,
  ) {
    if (!mounted || !_isEnabled) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  // ==========================================================================
  // COLOR
  // ==========================================================================

  Color get _accentColor {
    switch (widget.platform.productCode) {
      case 'CC':
        return const Color(0xFF5C6BC0);

      case 'GSMY':
        return const Color(0xFF00897B);

      case 'MOL':
        return const Color(0xFFE65100);

      case 'OF':
        return const Color(0xFF3949AB);

      case 'STEAMMY':
        return const Color(0xFF455A64);

      case 'UNI':
        return const Color(0xFF8E24AA);

      default:
        return const Color(0xFF7048E8);
    }
  }

  Color get _lightAccentColor {
    switch (widget.platform.productCode) {
      case 'CC':
        return const Color(0xFFE8EAFB);

      case 'GSMY':
        return const Color(0xFFE0F2F1);

      case 'MOL':
        return const Color(0xFFFFE9DD);

      case 'OF':
        return const Color(0xFFE8EAF6);

      case 'STEAMMY':
        return const Color(0xFFECEFF1);

      case 'UNI':
        return const Color(0xFFF3E5F5);

      default:
        return const Color(0xFFEDE7FF);
    }
  }

  // ==========================================================================
  // PROCESSING TIME LOCALIZATION
  // ==========================================================================

  String _formatProcessingTime(
    BuildContext context,
    String value,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    switch (
        value.toLowerCase().trim()) {
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
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTapDown: _isEnabled
          ? (_) =>
              _changePressedState(
                true,
              )
          : null,

      onTapUp: _isEnabled
          ? (_) =>
              _changePressedState(
                false,
              )
          : null,

      onTapCancel: _isEnabled
          ? () =>
              _changePressedState(
                false,
              )
          : null,

      onTap: _isEnabled
          ? widget.onPressed
          : null,

      child: AnimatedScale(
        scale:
            _isPressed ? 0.965 : 1,

        duration:
            const Duration(
          milliseconds: 130,
        ),

        curve:
            Curves.easeOut,

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 170,
          ),

          curve:
              Curves.easeOut,

          // EXACT SAME HEIGHT AS ELECTRIC
          height: 510,

          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              _isEnabled
                  ? 0.96
                  : 0.72,
            ),

            borderRadius:
                BorderRadius.circular(
              40,
            ),

            border:
                Border.all(
              color: _isPressed
                  ? _accentColor
                  : _isEnabled
                      ? Colors.black
                      : Colors.grey,

              width:
                  _isPressed ? 4 : 3,
            ),

            boxShadow:
                _isPressed
                    ? [
                        BoxShadow(
                          color:
                              _accentColor
                                  .withOpacity(
                            0.18,
                          ),
                          blurRadius:
                              18,
                          offset:
                              const Offset(
                            0,
                            8,
                          ),
                        ),
                      ]
                    : [
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

          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(
              37,
            ),

            child: Stack(
              children: [
                // ============================================================
                // DECORATIVE CIRCLE
                // ============================================================
                Positioned(
                  right: -50,
                  top: -50,
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
                          _lightAccentColor
                              .withOpacity(
                        0.90,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 95,
                  top: 110,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color:
                          _accentColor
                              .withOpacity(
                        0.08,
                      ),
                    ),
                  ),
                ),

                // ============================================================
                // CONTENT
                // ============================================================
                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    30,
                    28,
                    30,
                    28,
                  ),

                  child: Opacity(
                    opacity:
                        _isEnabled
                            ? 1
                            : 0.50,

                    child: Column(
                      children: [
                        // ====================================================
                        // LOGO + ARROW
                        // ====================================================
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Container(
                              width: 220,
                              height: 180,

                              padding:
                                  const EdgeInsets
                                      .all(
                                24,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  34,
                                ),

                                border:
                                    Border.all(
                                  color:
                                      _accentColor
                                          .withOpacity(
                                    0.20,
                                  ),
                                  width:
                                      1.5,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withOpacity(
                                      0.08,
                                    ),
                                    blurRadius:
                                        16,
                                    offset:
                                        const Offset(
                                      0,
                                      8,
                                    ),
                                  ),
                                ],
                              ),

                              child: widget.platform.imageUrl.isEmpty
                                  ? Icon(
                                      Icons.sports_esports_rounded,
                                      size: 90,
                                      color: _accentColor,
                                    )
                                  : Image.network(
                                      widget.platform.imageUrl,

                                      fit:
                                          BoxFit.contain,

                                      loadingBuilder:
                                          (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress ==
                                            null) {
                                          return child;
                                        }

                                        return Center(
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                3,
                                            color:
                                                _accentColor,
                                          ),
                                        );
                                      },

                                      errorBuilder:
                                          (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        debugPrint(
                                          'Failed to load gaming logo: '
                                          '${widget.platform.imageUrl}',
                                        );

                                        return Icon(
                                          Icons.sports_esports_rounded,
                                          size: 90,
                                          color:
                                              _accentColor,
                                        );
                                      },
                                    ),
                            ),

                            AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds:
                                    160,
                              ),

                              transform:
                                  Matrix4
                                      .translationValues(
                                _isPressed
                                    ? 6
                                    : 0,
                                0,
                                0,
                              ),

                              width: 58,
                              height: 58,

                              decoration:
                                  BoxDecoration(
                                color:
                                    _accentColor,

                                shape:
                                    BoxShape.circle,

                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        _accentColor
                                            .withOpacity(
                                      0.25,
                                    ),
                                    blurRadius:
                                        14,
                                    offset:
                                        const Offset(
                                      0,
                                      7,
                                    ),
                                  ),
                                ],
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

                        // ====================================================
                        // PLATFORM NAME
                        // ====================================================
                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,

                          child: Text(
                            widget.platform.name
                                .toUpperCase(),

                            maxLines: 2,

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            textAlign:
                                TextAlign.left,

                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF15253A,
                              ),

                              fontSize:
                                  34,

                              fontWeight:
                                  FontWeight
                                      .w900,

                              height:
                                  1.08,

                              letterSpacing:
                                  0.3,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ====================================================
                        // NETWORK STATUS
                        // ====================================================
                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,

                          child:
                              _NetworkStatusBadge(
                            status:
                                widget.platform.isActive
                                    ? widget.networkStatus
                                    : GamingStatus
                                        .unavailable,

                            label:
                                widget.networkLabel,
                          ),
                        ),

                        // ====================================================
                        // PROCESSING TIME
                        // ====================================================
                        if (widget
                            .platform
                            .processingTime
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 14,
                          ),

                          Align(
                            alignment:
                                Alignment
                                    .centerLeft,

                            child: Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,

                              children: [
                                const Icon(
                                  Icons
                                      .schedule_rounded,
                                  size:
                                      23,
                                  color:
                                      Color(
                                    0xFF647187,
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                Flexible(
                                  child:
                                      Text(
                                    '${widget.processingLabel}: '
                                    '${_formatProcessingTime(
                                      context,
                                      widget.platform.processingTime,
                                    )}',

                                    maxLines:
                                        1,

                                    overflow:
                                        TextOverflow
                                            .ellipsis,

                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF647187,
                                      ),

                                      fontSize:
                                          18,

                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(
                          height: 18,
                        ),

                        // ====================================================
                        // DECORATIVE LINE
                        // ====================================================
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 7,
                              decoration:
                                  BoxDecoration(
                                color:
                                    _accentColor,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  50,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Container(
                              width: 13,
                              height: 7,

                              decoration:
                                  BoxDecoration(
                                color:
                                    _accentColor
                                        .withOpacity(
                                  0.28,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
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
}

// ============================================================================
// NETWORK STATUS BADGE
// SAME AS ELECTRIC
// ============================================================================
class _NetworkStatusBadge
    extends StatelessWidget {
  final GamingStatus status;
  final String label;

  const _NetworkStatusBadge({
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context)!;

    late final String statusText;

    late final Color backgroundColor;
    late final Color borderColor;
    late final Color foregroundColor;

    late final IconData icon;

    switch (status) {
      case GamingStatus.loading:
        statusText =
            loc.networkStatusChecking;

        backgroundColor =
            const Color(0xFFF0F4F8);

        borderColor =
            const Color(0xFFC7D2DE);

        foregroundColor =
            const Color(0xFF536272);

        icon =
            Icons.sync_rounded;

        break;

      case GamingStatus.healthy:
        statusText =
            loc.networkStatusGood;

        backgroundColor =
            const Color(0xFFE2F8EC);

        borderColor =
            const Color(0xFF78C99B);

        foregroundColor =
            const Color(0xFF08783E);

        icon =
            Icons.check_circle_rounded;

        break;

      case GamingStatus.interruption:
        statusText =
            loc.networkStatusSlow;

        backgroundColor =
            const Color(0xFFFFF0D7);

        borderColor =
            const Color(0xFFF1B95D);

        foregroundColor =
            const Color(0xFFB75B00);

        icon =
            Icons.warning_amber_rounded;

        break;

      case GamingStatus.unavailable:
        statusText =
            loc.networkStatusUnknown;

        backgroundColor =
            const Color(0xFFF1F1F1);

        borderColor =
            const Color(0xFFC8C8C8);

        foregroundColor =
            const Color(0xFF555555);

        icon =
            Icons.help_outline_rounded;

        break;
    }

    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 54,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
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
          width: 1.7,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          if (status ==
              GamingStatus.loading)
            SizedBox(
              width: 24,
              height: 24,

              child:
                  CircularProgressIndicator(
                strokeWidth: 3,
                color:
                    foregroundColor,
              ),
            )
          else
            Icon(
              icon,
              size: 26,
              color:
                  foregroundColor,
            ),

          const SizedBox(
            width: 9,
          ),

          Flexible(
            child: Text(
              '$label: '
              '$statusText',

              maxLines: 1,

              overflow:
                  TextOverflow
                      .ellipsis,

              style:
                  TextStyle(
                color:
                    foregroundColor,

                fontSize: 17,

                fontWeight:
                    FontWeight.w900,

                letterSpacing:
                    0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SCROLL INDICATOR BUTTON
// SAME AS ELECTRIC
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
  Widget build(BuildContext context) {
    final Widget iconWidget =
        Icon(
      icon,
      size: 52,
      color:
          const Color(
        0xFF7048E8,
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
          BorderRadius.circular(
        22,
      ),

      elevation: 5,

      child: InkWell(
        onTap:
            onPressed,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        child: Container(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 13,
            vertical: 10,
          ),

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius
                    .circular(
              22,
            ),

            border:
                Border.all(
              color:
                  Colors.black,
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
