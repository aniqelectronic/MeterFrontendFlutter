import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

enum BillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

class PELECTRICBILL3PAGE extends StatefulWidget {
  const PELECTRICBILL3PAGE({super.key});

  @override
  State<PELECTRICBILL3PAGE> createState() =>
      _PELECTRICBILL3PAGEState();
}

class _PELECTRICBILL3PAGEState
    extends State<PELECTRICBILL3PAGE> {
  // ============================================================
  // NETWORK STATUS
  //
  // NOTE:
  // FP is intentionally kept for Sarawak Energy network testing.
  // The real IIMMPACT payment product code remains SESCO.
  // ============================================================
  final Map<String, BillerStatus> _billerStatuses = {
    'TNB': BillerStatus.loading,
    'FP': BillerStatus.loading,
    'SESB': BillerStatus.loading,
    'NUR': BillerStatus.loading,
  };

  final Map<String, String?> _lastUpdated = {};

  final ScrollController _scrollController =
      ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialNetworkStatuses();
      _handleScroll();
    });
  }

  // ============================================================
  // SCROLL POSITION LISTENER
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
  // INITIAL NETWORK STATUS
  // ============================================================
  Future<void> _loadInitialNetworkStatuses() async {
    await Future.wait([
      _refreshNetworkStatus('TNB'),

      // Intentionally invalid/test code.
      _refreshNetworkStatus('FP'),

      _refreshNetworkStatus('SESB'),
      _refreshNetworkStatus('NUR'),
    ]);
  }

  // ============================================================
  // REFRESH A BILLER NETWORK STATUS
  // ============================================================
  Future<BillerStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            BillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final BillerStatus status = result.isHealthy
          ? BillerStatus.healthy
          : BillerStatus.interruption;

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
        'Network status error for $productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              BillerStatus.unavailable;
        });
      }

      return BillerStatus.unavailable;
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
  // BILLER SELECTION HANDLER
  // ============================================================
  Future<void> _handleBillerTap({
    required String productCode,
    required String billerName,
    required VoidCallback navigate,
  }) async {
    final BillerStatus status =
        await _refreshNetworkStatus(productCode);

    if (!mounted) {
      return;
    }

    if (status == BillerStatus.interruption) {
      final bool shouldContinue =
          await _showInterruptionWarning(
        billerName: billerName,
        productCode: productCode,
      );

      if (!shouldContinue) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    navigate();
  }

  // ============================================================
  // MANUAL SCROLL CONTROLS
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
            top: 82,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              title: loc.pbilelectric3Title,
              subtitle: loc.pbil3Subtitle,
            ),
          ),

          // ============================================================
          // PROVIDER AREA
          // ============================================================
          Positioned(
            top: 400,
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
                  children: [
                    // ==================================================
                    // TNB + SARAWAK ENERGY
                    // ==================================================
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // TNB
                        // ==================================================
                        Expanded(
                          child: _ElectricProviderCard(
                            imageUrl:
                                'https://dashboard.iimmpact.com/img/TNB.png',
                            label: loc.tnbButton,
                            accentColor:
                                const Color(0xFF1469E8),
                            lightAccentColor:
                                const Color(0xFFE5F0FF),
                            networkStatus:
                                _billerStatuses['TNB'] ??
                                    BillerStatus.loading,
                            networkLabel:
                                loc.networkLabel,
                            onPressed: () {
                              _handleBillerTap(
                                productCode: 'TNB',
                                billerName:
                                    'TENAGA NASIONAL BERHAD',
                                navigate: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          P4BILPAGE(
                                        title: loc
                                            .electricAccountTitle,
                                        hint: loc
                                            .electricAccountHint,
                                        productCode:
                                            'TNB',
                                        billerName:
                                            'TENAGA NASIONAL BERHAD',
                                        serviceType:
                                            BillServiceType
                                                .electric,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 34),

                        // ==================================================
                        // SARAWAK ENERGY
                        //
                        // IMPORTANT:
                        // Image      = SESCO
                        // Status     = FP (TEST)
                        // Payment    = SESCO
                        // ==================================================
                        Expanded(
                          child: _ElectricProviderCard(
                            imageUrl:
                                'https://dashboard.iimmpact.com/img/SESCO.png',
                            label:
                                loc.sarawakenergyButton,
                            accentColor:
                                const Color(0xFF128B75),
                            lightAccentColor:
                                const Color(0xFFE2F7F1),

                            // Keep FP intentionally.
                            networkStatus:
                                _billerStatuses['FP'] ??
                                    BillerStatus.loading,

                            networkLabel:
                                loc.networkLabel,

                            onPressed: () {
                              // FP is intentionally used here
                              // ONLY for network status testing.
                              _handleBillerTap(
                                productCode: 'FP',
                                billerName:
                                    'SARAWAK ENERGY',

                                // Actual payment still uses
                                // the valid SESCO code.
                                navigate: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          P4BILPAGE(
                                        title: loc
                                            .electricAccountTitle,
                                        hint: loc
                                            .electricAccountHint,
                                        productCode:
                                            'SESCO',
                                        billerName:
                                            'SARAWAK ENERGY',
                                        serviceType:
                                            BillServiceType
                                                .electric,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // ==================================================
                    // SABAH + NUR
                    // ==================================================
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // SABAH ELECTRICITY
                        // ==================================================
                        Expanded(
                          child: _ElectricProviderCard(
                            imageUrl:
                                'https://dashboard.iimmpact.com/img/SESB.png',
                            label:
                                loc.sabahelectricityButton,
                            accentColor:
                                const Color(0xFF1779B9),
                            lightAccentColor:
                                const Color(0xFFE5F5FF),
                            networkStatus:
                                _billerStatuses['SESB'] ??
                                    BillerStatus.loading,
                            networkLabel:
                                loc.networkLabel,
                            onPressed: () {
                              _handleBillerTap(
                                productCode: 'SESB',
                                billerName:
                                    'SABAH ELECTRICITY',
                                navigate: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          P4BILPAGE(
                                        title: loc
                                            .electricAccountTitle,
                                        hint: loc
                                            .electricAccountHint,
                                        productCode:
                                            'SESB',
                                        billerName:
                                            'SABAH ELECTRICITY',
                                        serviceType:
                                            BillServiceType
                                                .electric,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 34),

                        // ==================================================
                        // NUR POWER
                        // ==================================================
                        Expanded(
                          child: _ElectricProviderCard(
                            imageUrl:
                                'https://dashboard.iimmpact.com/img/NUR.png',
                            label:
                                loc.nurpowerButton,
                            accentColor:
                                const Color(0xFFE59522),
                            lightAccentColor:
                                const Color(0xFFFFF3D9),
                            networkStatus:
                                _billerStatuses['NUR'] ??
                                    BillerStatus.loading,
                            networkLabel:
                                loc.networkLabel,
                            onPressed: () {
                              _handleBillerTap(
                                productCode: 'NUR',
                                billerName:
                                    'NUR POWER',
                                navigate: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          P4BILPAGE(
                                        title: loc
                                            .electricAccountTitle,
                                        hint: loc
                                            .electricAccountHint,
                                        productCode:
                                            'NUR',
                                        billerName:
                                            'NUR POWER',
                                        serviceType:
                                            BillServiceType
                                                .electric,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
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
                icon:
                    Icons.keyboard_arrow_up_rounded,
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

          // ============================================================
          // FOOTER
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
// MODERN HEADER
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
        Color(0xFF1469E8);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.10),
            borderRadius:
                BorderRadius.circular(100),
            border: Border.all(
              color:
                  accentColor.withOpacity(0.24),
              width: 1.5,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.electric_bolt_rounded,
                color: accentColor,
                size: 25,
              ),
              SizedBox(width: 9),
              Text(
                'ELECTRICITY SERVICES',
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

        const SizedBox(height: 17),

        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF064CAC),
                Color(0xFF1987EB),
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
              fontSize: 62,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.8,
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
                Colors.white.withOpacity(0.91),
            borderRadius:
                BorderRadius.circular(23),
            border: Border.all(
              color:
                  Colors.black.withOpacity(0.17),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF113968)
                        .withOpacity(0.10),
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
// ELECTRICITY PROVIDER CARD
// ============================================================================
class _ElectricProviderCard
    extends StatefulWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onPressed;
  final Color accentColor;
  final Color lightAccentColor;
  final BillerStatus networkStatus;
  final String networkLabel;
  final bool comingSoon;

  const _ElectricProviderCard({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onPressed,
    required this.accentColor,
    required this.lightAccentColor,
    required this.networkStatus,
    required this.networkLabel,
    this.comingSoon = false,
  });

  @override
  State<_ElectricProviderCard> createState() =>
      _ElectricProviderCardState();
}

class _ElectricProviderCardState
    extends State<_ElectricProviderCard> {
  bool _isPressed = false;

  void _changePressedState(bool value) {
    if (!mounted || widget.comingSoon) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled =
        !widget.comingSoon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isEnabled
          ? (_) =>
              _changePressedState(true)
          : null,
      onTapUp: isEnabled
          ? (_) =>
              _changePressedState(false)
          : null,
      onTapCancel: isEnabled
          ? () =>
              _changePressedState(false)
          : null,
      onTap:
          isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.965 : 1,
        duration:
            const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          height: 480,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              widget.comingSoon
                  ? 0.72
                  : 0.96,
            ),
            borderRadius:
                BorderRadius.circular(40),
            border: Border.all(
              color: _isPressed
                  ? widget.accentColor
                  : widget.comingSoon
                      ? Colors.grey
                      : Colors.black,
              width: _isPressed ? 4 : 3,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.accentColor
                          .withOpacity(0.18),
                      blurRadius: 18,
                      offset:
                          const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color:
                          const Color(0xFF19375C)
                              .withOpacity(0.16),
                      blurRadius: 30,
                      spreadRadius: 1,
                      offset:
                          const Offset(0, 15),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(37),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  right: -50,
                  top: -50,
                  child: AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    width:
                        _isPressed ? 225 : 210,
                    height:
                        _isPressed ? 225 : 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget
                          .lightAccentColor
                          .withOpacity(0.90),
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
                      color: widget
                          .accentColor
                          .withOpacity(0.08),
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
                  child: Opacity(
                    opacity:
                        widget.comingSoon
                            ? 0.50
                            : 1,
                    child: Column(
                      children: [
                        // ================================================
                        // IIMMPACT LOGO + ARROW
                        // ================================================
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
                                      .all(24),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  34,
                                ),
                                border:
                                    Border.all(
                                  color: widget
                                      .accentColor
                                      .withOpacity(
                                    0.20,
                                  ),
                                  width: 1.5,
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

                              // =========================================
                              // IMAGE FROM IIMMPACT
                              // =========================================
                              child:
                                  Image.network(
                                widget.imageUrl,
                                fit:
                                    BoxFit.contain,

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
                                      strokeWidth:
                                          3,
                                      color: widget
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
                                    'Failed to load electricity logo: '
                                    '${widget.imageUrl}',
                                  );

                                  return Icon(
                                    Icons
                                        .electric_bolt_rounded,
                                    size: 90,
                                    color: widget
                                        .accentColor,
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
                              transform: Matrix4
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
                                color: widget
                                    .accentColor,
                                shape:
                                    BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget
                                        .accentColor
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

                        // ================================================
                        // NAME
                        // ================================================
                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,
                          child: Text(
                            widget.label
                                .toUpperCase(),
                            maxLines: 3,
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
                              fontSize: 35,
                              fontWeight:
                                  FontWeight
                                      .w900,
                              height: 1.10,
                              letterSpacing:
                                  0.4,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 21,
                        ),

                        // ================================================
                        // NETWORK STATUS
                        // ================================================
                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,
                          child:
                              _NetworkStatusBadge(
                            status: widget
                                .networkStatus,
                            label: widget
                                .networkLabel,
                          ),
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 7,
                              decoration:
                                  BoxDecoration(
                                color: widget
                                    .accentColor,
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
                                color: widget
                                    .accentColor
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

                if (widget.comingSoon)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white
                          .withOpacity(0.24),
                      alignment:
                          Alignment.center,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: Container(
                          width:
                              double.infinity,
                          margin:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFE74343,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                            border:
                                Border.all(
                              color:
                                  Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Text(
                            AppLocalizations
                                    .of(context)!
                                .comingsoonText
                                .toUpperCase(),
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 27,
                              fontWeight:
                                  FontWeight
                                      .w900,
                              letterSpacing:
                                  2,
                            ),
                          ),
                        ),
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
// ============================================================================
class _NetworkStatusBadge
    extends StatelessWidget {
  final BillerStatus status;
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
      case BillerStatus.loading:
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

      case BillerStatus.healthy:
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

      case BillerStatus.interruption:
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

      case BillerStatus.unavailable:
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
            BorderRadius.circular(30),
        border: Border.all(
          color: borderColor,
          width: 1.7,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          if (status ==
              BillerStatus.loading)
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

          const SizedBox(width: 9),

          Flexible(
            child: Text(
              '$label: $statusText',
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: 0.7,
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
          const Color(0xFF1469E8),
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
                BorderRadius.circular(
              22,
            ),
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