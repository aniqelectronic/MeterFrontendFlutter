import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

// ============================================================================
// BROADBAND BILLER STATUS
// ============================================================================
enum BroadbandBillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

// ============================================================================
// BROADBAND BILLER MODEL
// ============================================================================
class BroadbandBiller {
  final String productCode;
  final String billerName;
  final String imageUrl;
  final Color accentColor;
  final Color lightAccentColor;

  const BroadbandBiller({
    required this.productCode,
    required this.billerName,
    required this.imageUrl,
    required this.accentColor,
    required this.lightAccentColor,
  });
}

// ============================================================================
// BROADBAND BILL PROVIDER PAGE
// ============================================================================
class PBROADBANDBILL3PAGE extends StatefulWidget {
  const PBROADBANDBILL3PAGE({
    super.key,
  });

  @override
  State<PBROADBANDBILL3PAGE> createState() =>
      _PBROADBANDBILL3PAGEState();
}

class _PBROADBANDBILL3PAGEState
    extends State<PBROADBANDBILL3PAGE> {
  final ScrollController _scrollController =
      ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = true;

  // ==========================================================================
  // BROADBAND PROVIDERS
  // ==========================================================================
  static const List<BroadbandBiller> _broadbandBillers = [
    BroadbandBiller(
      productCode: 'TM',
      billerName: 'Telekom Malaysia',
      imageUrl:
          'https://dashboard.iimmpact.com/img/TM.png',
      accentColor: Color(0xFF6255D9),
      lightAccentColor: Color(0xFFECE9FF),
    ),

    BroadbandBiller(
      productCode: 'UNB',
      billerName: 'Unifi',
      imageUrl:
          'https://dashboard.iimmpact.com/img/UNB.png',
      accentColor: Color(0xFF9A3CCE),
      lightAccentColor: Color(0xFFF4E6FC),
    ),
  ];

  late final Map<String, BroadbandBillerStatus>
      _billerStatuses = {
    for (final biller in _broadbandBillers)
      biller.productCode:
          BroadbandBillerStatus.loading,
  };

  final Map<String, String?> _lastUpdated = {};

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadInitialNetworkStatuses();
        _handleScroll();
      },
    );
  }

  // ==========================================================================
  // SCROLL POSITION LISTENER
  // ==========================================================================
  void _handleScroll() {
    if (!_scrollController.hasClients ||
        !mounted) {
      return;
    }

    final double maxScroll =
        _scrollController.position.maxScrollExtent;

    final double currentScroll =
        _scrollController.offset;

    final bool newShowScrollUp =
        currentScroll > 10;

    final bool newShowScrollDown =
        currentScroll < maxScroll - 10;

    if (showScrollUp != newShowScrollUp ||
        showScrollDown != newShowScrollDown) {
      setState(() {
        showScrollUp = newShowScrollUp;
        showScrollDown = newShowScrollDown;
      });
    }
  }

  // ==========================================================================
  // LOAD INITIAL NETWORK STATUS
  // ==========================================================================
  Future<void>
      _loadInitialNetworkStatuses() async {
    await Future.wait(
      _broadbandBillers.map(
        (biller) => _refreshNetworkStatus(
          biller.productCode,
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _handleScroll();
      },
    );
  }

  // ==========================================================================
  // REFRESH NETWORK STATUS
  // ==========================================================================
  Future<BroadbandBillerStatus>
      _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            BroadbandBillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService
              .getStatus(
        productCode: productCode,
      );

      final BroadbandBillerStatus status =
          result.isHealthy
              ? BroadbandBillerStatus.healthy
              : BroadbandBillerStatus.interruption;

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
        'Broadband network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              BroadbandBillerStatus.unavailable;
        });
      }

      return BroadbandBillerStatus.unavailable;
    }
  }

  // ==========================================================================
  // NETWORK INTERRUPTION WARNING
  // ==========================================================================
  Future<bool> _showInterruptionWarning({
    required String billerName,
    required String productCode,
  }) async {
    final loc =
        AppLocalizations.of(context)!;

    final bool? result =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(
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
              borderRadius:
                  BorderRadius.circular(38),
              border: Border.all(
                color:
                    const Color(0xFFF2A520),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.25),
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
                    color: const Color(
                      0xFFFFF2D9,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFFF2A520,
                      ).withOpacity(0.30),
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
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF17283E),
                    fontSize: 40,
                    fontWeight:
                        FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 25,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFFF9ED),
                    borderRadius:
                        BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(
                        0xFFF4D69D,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    loc.networkInterruptionMessage(
                      billerName,
                    ),
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4B4234),
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
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 24,
                        color:
                            Color(0xFF758399),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${loc.networkLastUpdated}: '
                          '${_lastUpdated[productCode]}',
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 21,
                            color:
                                Color(0xFF758399),
                            fontWeight:
                                FontWeight.w600,
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
                        child:
                            OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );
                          },
                          icon: const Icon(
                            Icons
                                .arrow_back_rounded,
                            size: 29,
                          ),
                          label: Text(
                            loc.backButton,
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          style: OutlinedButton
                              .styleFrom(
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
                              color: Color(
                                0xFFE57373,
                              ),
                              width: 2,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(22),
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
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          },
                          icon: const Icon(
                            Icons
                                .arrow_forward_rounded,
                            size: 29,
                          ),
                          label: Text(
                            loc.continueButton,
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          style: ElevatedButton
                              .styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF168A50,
                            ),
                            foregroundColor:
                                Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(22),
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
  // BILLER TAP HANDLER
  // ==========================================================================
  Future<void> _handleBillerTap({
    required BroadbandBiller biller,
  }) async {
    final BroadbandBillerStatus status =
        await _refreshNetworkStatus(
      biller.productCode,
    );

    if (!mounted) {
      return;
    }

    if (status ==
        BroadbandBillerStatus.interruption) {
      final bool shouldContinue =
          await _showInterruptionWarning(
        billerName: biller.billerName,
        productCode:
            biller.productCode,
      );

      if (!shouldContinue) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    final loc =
        AppLocalizations.of(context)!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P4BILPAGE(
          title:
              loc.broadbandAccountTitle,
          hint:
              loc.broadbandAccountHint,
          productCode:
              biller.productCode,
          billerName:
              biller.billerName,
          serviceType:
              BillServiceType.broadband,
        ),
      ),
    );
  }

  // ==========================================================================
  // MANUAL SCROLL CONTROLS
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
          .position.maxScrollExtent,
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
          .position.maxScrollExtent,
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
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context)!;

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

          // Soft readability overlay.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Colors.white
                        .withOpacity(0.02),
                    Colors.white
                        .withOpacity(0.13),
                    Colors.white
                        .withOpacity(0.04),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================================
          // MODERN HEADER
          // ==================================================================
          Positioned(
            top: 75,
            left: 65,
            right: 65,
            child: _ModernBroadbandHeader(
              title:
                  loc.broadbandSelectionTitle,
              subtitle:
                  loc.pbil3Subtitle,
            ),
          ),

          // ==================================================================
          // PROVIDER GRID
          // ==================================================================
          Positioned(
            top: 390,
            left: 45,
            right: 45,
            bottom: 305,
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
                14,
                16,
                14,
                20,
              ),
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.20),
                borderRadius:
                    BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white
                      .withOpacity(0.60),
                  width: 1.5,
                ),
              ),
              child: Scrollbar(
                controller:
                    _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                thickness: 11,
                radius:
                    const Radius.circular(20),
                child: GridView.builder(
                  controller:
                      _scrollController,
                  padding:
                      const EdgeInsets.only(
                    right: 24,
                    bottom: 45,
                  ),
                  physics:
                      const BouncingScrollPhysics(),
                  itemCount:
                      _broadbandBillers.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 34,
                    mainAxisSpacing: 36,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final BroadbandBiller
                        biller =
                        _broadbandBillers[index];

                    return _BroadbandProviderCard(
                      biller: biller,
                      networkStatus:
                          _billerStatuses[
                            biller.productCode
                          ] ??
                          BroadbandBillerStatus
                              .loading,
                      networkLabel:
                          loc.networkLabel,
                      onPressed: () {
                        _handleBillerTap(
                          biller: biller,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // ==================================================================
          // SCROLL-UP BUTTON
          // ==================================================================
          if (showScrollUp)
            Positioned(
              right: 18,
              top: 355,
              child:
                  _ScrollIndicatorButton(
                icon: Icons
                    .keyboard_arrow_up_rounded,
                label: loc.scrollup,
                onPressed: _scrollUp,
              ),
            ),

          // ==================================================================
          // SCROLL-DOWN BUTTON
          // ==================================================================
          if (showScrollDown)
            Positioned(
              right: 18,
              bottom: 290,
              child:
                  _ScrollIndicatorButton(
                icon: Icons
                    .keyboard_arrow_down_rounded,
                label: loc.scrolldown,
                onPressed: _scrollDown,
                iconBelowText: true,
              ),
            ),

          // ==================================================================
          // BACK BUTTON
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
                    builder: (_) =>
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
            bottom: 25,
            left: 0,
            right: 0,
            child: Text(
              Data.copyrightText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF26364A),
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODERN BROADBAND HEADER
// ============================================================================
class _ModernBroadbandHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernBroadbandHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor =
        Color(0xFF6255D9);

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color:
                accentColor.withOpacity(0.10),
            borderRadius:
                BorderRadius.circular(100),
            border: Border.all(
              color:
                  accentColor.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: const Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.router_rounded,
                color: accentColor,
                size: 25,
              ),
              SizedBox(width: 9),
              Text(
                'BROADBAND SERVICES',
                style: TextStyle(
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

        const SizedBox(height: 17),

        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF493CB5),
                Color(0xFF9A3CCE),
              ],
            ).createShader(bounds);
          },
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 61,
              fontWeight:
                  FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.7,
            ),
          ),
        ),

        const SizedBox(height: 14),

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
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(0.92),
            borderRadius:
                BorderRadius.circular(23),
            border: Border.all(
              color: Colors.black
                  .withOpacity(0.17),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF33256D,
                ).withOpacity(0.10),
                blurRadius: 22,
                offset:
                    const Offset(0, 9),
              ),
            ],
          ),
          child: Text(
            subtitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF435166),
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
// MODERN BROADBAND PROVIDER CARD
// ============================================================================
class _BroadbandProviderCard
    extends StatefulWidget {
  final BroadbandBiller biller;
  final BroadbandBillerStatus networkStatus;
  final String networkLabel;
  final VoidCallback onPressed;

  const _BroadbandProviderCard({
    required this.biller,
    required this.networkStatus,
    required this.networkLabel,
    required this.onPressed,
  });

  @override
  State<_BroadbandProviderCard> createState() =>
      _BroadbandProviderCardState();
}

class _BroadbandProviderCardState
    extends State<_BroadbandProviderCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        _setPressed(true);
      },

      onTapUp: (_) {
        _setPressed(false);
      },

      onTapCancel: () {
        _setPressed(false);
      },

      onTap: widget.onPressed,

      child: AnimatedScale(
        scale:
            _isPressed ? 0.965 : 1,
        duration: const Duration(
          milliseconds: 130,
        ),
        curve: Curves.easeOut,

        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 170,
          ),
          curve: Curves.easeOut,

          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(0.96),
            borderRadius:
                BorderRadius.circular(38),

            border: Border.all(
              color: _isPressed
                  ? widget.biller.accentColor
                  : Colors.black,
              width: _isPressed ? 4 : 3,
            ),

            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget
                          .biller.accentColor
                          .withOpacity(0.18),
                      blurRadius: 17,
                      offset:
                          const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(
                        0xFF19375C,
                      ).withOpacity(0.16),
                      blurRadius: 28,
                      spreadRadius: 1,
                      offset:
                          const Offset(0, 14),
                    ),
                  ],
          ),

          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(35),

            child: Stack(
              children: [
                // ==========================================================
                // DECORATIVE BACKGROUND
                // ==========================================================
                Positioned(
                  right: -50,
                  top: -50,
                  child: AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    width:
                        _isPressed ? 215 : 200,
                    height:
                        _isPressed ? 215 : 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget
                          .biller.lightAccentColor
                          .withOpacity(0.92),
                    ),
                  ),
                ),

                Positioned(
                  right: 92,
                  top: 105,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget
                          .biller.accentColor
                          .withOpacity(0.08),
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    27,
                    27,
                    27,
                    25,
                  ),

                  child: Column(
                    children: [
                      // ====================================================
                      // IIMMPACT LOGO + ARROW
                      // ====================================================
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Container(
                            width: 210,
                            height: 170,

                            padding:
                                const EdgeInsets
                                    .all(22),

                            decoration:
                                BoxDecoration(
                              color: Colors.white,

                              borderRadius:
                                  BorderRadius
                                      .circular(32),

                              border: Border.all(
                                color: widget
                                    .biller
                                    .accentColor
                                    .withOpacity(
                                  0.20,
                                ),
                                width: 1.5,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(
                                    0.07,
                                  ),
                                  blurRadius: 15,
                                  offset:
                                      const Offset(
                                    0,
                                    7,
                                  ),
                                ),
                              ],
                            ),

                            // =================================================
                            // LOGO FROM IIMMPACT
                            // =================================================
                            child: Image.network(
                              widget.biller.imageUrl,
                              fit: BoxFit.contain,

                              loadingBuilder: (
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
                                    strokeWidth: 3,
                                    color: widget
                                        .biller
                                        .accentColor,
                                  ),
                                );
                              },

                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                debugPrint(
                                  'Failed to load broadband logo: '
                                  '${widget.biller.imageUrl}',
                                );

                                return Icon(
                                  Icons.router_rounded,
                                  size: 85,
                                  color: widget
                                      .biller
                                      .accentColor,
                                );
                              },
                            ),
                          ),

                          AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 160,
                            ),

                            transform: Matrix4
                                .translationValues(
                              _isPressed ? 6 : 0,
                              0,
                              0,
                            ),

                            width: 54,
                            height: 54,

                            decoration:
                                BoxDecoration(
                              color: widget.biller
                                  .accentColor,
                              shape:
                                  BoxShape.circle,

                              boxShadow: [
                                BoxShadow(
                                  color: widget
                                      .biller
                                      .accentColor
                                      .withOpacity(
                                    0.24,
                                  ),
                                  blurRadius: 13,
                                  offset:
                                      const Offset(
                                    0,
                                    6,
                                  ),
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons
                                  .arrow_forward_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // ====================================================
                      // PROVIDER NAME
                      // ====================================================
                      Align(
                        alignment:
                            Alignment.centerLeft,

                        child: Text(
                          widget.biller.billerName
                              .toUpperCase(),

                          textAlign:
                              TextAlign.left,

                          maxLines: 3,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            color:
                                Color(0xFF15253A),

                            fontSize: 30,

                            fontWeight:
                                FontWeight.w900,

                            height: 1.10,

                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ====================================================
                      // NETWORK STATUS
                      // ====================================================
                      SizedBox(
                        width: double.infinity,

                        child:
                            _NetworkStatusBadge(
                          status: widget
                              .networkStatus,

                          label:
                              widget.networkLabel,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ====================================================
                      // ACCENT BARS
                      // ====================================================
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 7,

                            decoration:
                                BoxDecoration(
                              color: widget.biller
                                  .accentColor,

                              borderRadius:
                                  BorderRadius
                                      .circular(50),
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
                              color: widget.biller
                                  .accentColor
                                  .withOpacity(
                                0.28,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(50),
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
// NETWORK STATUS BADGE
// ============================================================================
class _NetworkStatusBadge
    extends StatelessWidget {
  final BroadbandBillerStatus status;
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
      case BroadbandBillerStatus.loading:
        statusText =
            loc.networkStatusChecking;

        backgroundColor =
            const Color(0xFFF0F4F8);

        borderColor =
            const Color(0xFFC7D2DE);

        foregroundColor =
            const Color(0xFF536272);

        icon = Icons.sync_rounded;
        break;

      case BroadbandBillerStatus.healthy:
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

      case BroadbandBillerStatus.interruption:
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

      case BroadbandBillerStatus.unavailable:
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
        minHeight: 58,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: borderColor,
          width: 1.7,
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          if (status ==
              BroadbandBillerStatus.loading)
            SizedBox(
              width: 26,
              height: 26,

              child:
                  CircularProgressIndicator(
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

          const SizedBox(
            width: 8,
          ),

          Flexible(
            child: Text(
              '$label: $statusText',

              textAlign:
                  TextAlign.center,

              maxLines: 2,

              overflow:
                  TextOverflow.ellipsis,

              style: TextStyle(
                color: foregroundColor,

                fontSize: 18,

                fontWeight:
                    FontWeight.w900,

                height: 1.1,

                letterSpacing: 0.3,
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
    final Widget iconWidget = Icon(
      icon,
      size: 52,
      color:
          const Color(0xFF6255D9),
    );

    final Widget textWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF15253A),
        fontSize: 17,
        fontWeight:
            FontWeight.w900,
      ),
    );

    return Material(
      color:
          Colors.white.withOpacity(0.96),

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