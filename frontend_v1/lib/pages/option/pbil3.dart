import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/broadband/pbroadbandbill3.dart';
import 'package:frontend_v1/pages/bil/electric/pelectricbill3.dart';
import 'package:frontend_v1/pages/bil/entertainment/pentertainmentbill3.dart';
import 'package:frontend_v1/pages/bil/water/pwaterbill3.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'p2.dart';

class PBIL3PAGE extends StatefulWidget {
  const PBIL3PAGE({super.key});

  @override
  State<PBIL3PAGE> createState() => _PBIL3PAGEState();
}

class _PBIL3PAGEState extends State<PBIL3PAGE> {
  final ScrollController _scrollController = ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleScroll();
    });
  }

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

          // Soft background overlay.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.04),
                    Colors.white.withOpacity(0.14),
                    Colors.white.withOpacity(0.06),
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // HEADER
          // ============================================================
          Positioned(
            top: 90,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              badgeText: loc.billPaymentServiceLabel,
              title: loc.pbil3Title,
              subtitle: loc.pbil3Subtitle,
            ),
          ),

          // ============================================================
          // SCROLLABLE SERVICE AREA
          // ============================================================
          Positioned(
            top: 410,
            left: 45,
            right: 45,
            bottom: 300,
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
                  bottom: 50,
                ),
                child: Column(
                  children: [
                    // ==================================================
                    // FIRST ROW
                    // ==================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ModernServiceCard(
                            height: 455,
                            icon: Icons.electric_bolt_rounded,
                            label: loc.electricitybutton,
                            supportingText:
                                loc.electricityBillSupportingText,
                            accentColor:
                                const Color(0xFFE0A100),
                            accentLightColor:
                                const Color(0xFFFFF4D0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PELECTRICBILL3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 34),

                        Expanded(
                          child: _ModernServiceCard(
                            height: 455,
                            icon: Icons.water_drop_rounded,
                            label: loc.waterButton,
                            supportingText:
                                loc.waterBillSupportingText,
                            accentColor:
                                const Color(0xFF1687D9),
                            accentLightColor:
                                const Color(0xFFE3F3FF),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PWATERBILL3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 34),

                    // ==================================================
                    // SECOND ROW
                    // ==================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child:_ModernServiceCard(
                        height: 455,
                        icon: Icons.router_rounded,
                        label: loc.billbroadbandButton,
                        supportingText: loc.broadbandBillSupportingText,
                        accentColor: const Color(0xFF7356D8),
                        accentLightColor: const Color(0xFFEDE9FF),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PBROADBANDBILL3PAGE(),
                            ),
                          );
                        },
                      ),
                        ),

                        const SizedBox(width: 34),

                        Expanded(
                          child: _ModernServiceCard(
                            height: 455,
                            icon: Icons.live_tv_rounded,
                            label: loc.billEntertainmentButton,
                            supportingText:
                                loc.entertainmentBillSupportingText,
                            accentColor:
                                const Color(0xFFD64D8B),
                            accentLightColor:
                                const Color(0xFFFFE6F2),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PENTERTAINMENTBILL3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 34),

                    // ==================================================
                    // THIRD ROW
                    // ==================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ModernServiceCard(
                            height: 455,
                            icon: Icons.sim_card_rounded,
                            label: loc.telkoButton,
                            supportingText:
                                loc.telcoBillSupportingText,
                            accentColor:
                                const Color(0xFF15946B),
                            accentLightColor:
                                const Color(0xFFE2F7EF),
                            onPressed: () {},
                            comingSoon: true,
                          ),
                        ),

                        const SizedBox(width: 34),

                        // Empty space to keep the grid balanced.
                        const Expanded(
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // SCROLL-UP BUTTON
          // ============================================================
          if (showScrollUp)
            Positioned(
              right: 18,
              top: 375,
              child: _ScrollIndicatorButton(
                icon: Icons.keyboard_arrow_up_rounded,
                label: loc.scrollup,
                onPressed: _scrollUp,
              ),
            ),

          // ============================================================
          // SCROLL-DOWN BUTTON
          // ============================================================
          if (showScrollDown)
            Positioned(
              right: 18,
              bottom: 285,
              child: _ScrollIndicatorButton(
                icon: Icons.keyboard_arrow_down_rounded,
                label: loc.scrolldown,
                onPressed: _scrollDown,
                iconBelowText: true,
              ),
            ),

          // ============================================================
          // BACK BUTTON
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
                    builder: (_) => const P2Page(),
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
// MODERN PAGE HEADER
// ============================================================================
class _ModernPageHeader extends StatelessWidget {
  final String badgeText;
  final String title;
  final String subtitle;

  const _ModernPageHeader({
    required this.badgeText,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF1469E8);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: accentColor.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 25,
                color: accentColor,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  badgeText.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

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
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.1,
              height: 1.05,
            ),
          ),
        ),

        const SizedBox(height: 15),

        Container(
          constraints: const BoxConstraints(
            maxWidth: 860,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF113968).withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF435166),
              fontSize: 29,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MODERN SERVICE CARD
// ============================================================================
class _ModernServiceCard extends StatefulWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final String supportingText;
  final VoidCallback onPressed;
  final Color accentColor;
  final Color accentLightColor;
  final double height;
  final bool comingSoon;

  const _ModernServiceCard({
    super.key,
    this.icon,
    this.imagePath,
    required this.label,
    required this.supportingText,
    required this.onPressed,
    required this.accentColor,
    required this.accentLightColor,
    this.height = 455,
    this.comingSoon = false,
  });

  @override
  State<_ModernServiceCard> createState() =>
      _ModernServiceCardState();
}

class _ModernServiceCardState
    extends State<_ModernServiceCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted || widget.comingSoon) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.comingSoon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isEnabled ? (_) => _setPressed(true) : null,
      onTapUp: isEnabled ? (_) => _setPressed(false) : null,
      onTapCancel: isEnabled ? () => _setPressed(false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.965 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              widget.comingSoon ? 0.70 : 0.95,
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: _isPressed
                  ? widget.accentColor
                  : widget.comingSoon
                      ? Colors.grey
                      : Colors.black,
              width: _isPressed ? 4 : 3,
            ),
            boxShadow: _isPressed || widget.comingSoon
                ? [
                    BoxShadow(
                      color:
                          widget.accentColor.withOpacity(0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color:
                          const Color(0xFF19375C).withOpacity(0.16),
                      blurRadius: 32,
                      spreadRadius: 1,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.85),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(37),
            child: Stack(
              children: [
                Positioned(
                  right: -45,
                  top: -45,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _isPressed ? 220 : 205,
                    height: _isPressed ? 220 : 205,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentLightColor.withOpacity(0.90),
                    ),
                  ),
                ),

                Positioned(
                  right: 120,
                  top: 100,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.accentColor.withOpacity(0.08),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    34,
                    34,
                    30,
                    30,
                  ),
                  child: Opacity(
                    opacity: widget.comingSoon ? 0.50 : 1,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 135,
                              height: 125,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: widget.accentLightColor,
                                borderRadius:
                                    BorderRadius.circular(34),
                                border: Border.all(
                                  color: widget.accentColor
                                      .withOpacity(0.20),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: widget.icon != null
                                  ? Icon(
                                      widget.icon,
                                      size: 72,
                                      color: widget.accentColor,
                                    )
                                  : Image.asset(
                                      widget.imagePath!,
                                      fit: BoxFit.contain,
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
                                color: widget.accentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.accentColor
                                        .withOpacity(0.24),
                                    blurRadius: 14,
                                    offset:
                                        const Offset(0, 7),
                                  ),
                                ],
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

                        Text(
                          widget.label.toUpperCase(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF15253A),
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          widget.supportingText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF647187),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1.28,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Container(
                              width: 58,
                              height: 7,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                borderRadius:
                                    BorderRadius.circular(50),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 7,
                              decoration: BoxDecoration(
                                color: widget.accentColor
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
                ),

                if (widget.comingSoon)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.25),
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74343),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withOpacity(0.20),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            AppLocalizations.of(context)!
                                .comingsoonText
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
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
// SCROLL INDICATOR BUTTON
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