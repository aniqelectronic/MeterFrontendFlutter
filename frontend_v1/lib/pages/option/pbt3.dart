import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/p2.dart';
import 'package:frontend_v1/pages/pbt/compound/p4optioncompound.dart';
import 'package:frontend_v1/pages/pbt/cukai/p4_option_cukai_bentong.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/pages/pbt/sewaan/p4_option_sewaan_bentong.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class PBT3PAGE extends StatefulWidget {
  const PBT3PAGE({super.key});

  @override
  State<PBT3PAGE> createState() => _PBT3PAGEState();
}

class _PBT3PAGEState extends State<PBT3PAGE> {
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
    if (!_scrollController.hasClients || !mounted) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    final newShowScrollUp = current > 10;
    final newShowScrollDown = current < maxScroll - 10;

    if (showScrollUp != newShowScrollUp ||
        showScrollDown != newShowScrollDown) {
      setState(() {
        showScrollUp = newShowScrollUp;
        showScrollDown = newShowScrollDown;
      });
    }
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) return;

    final destination = (_scrollController.offset - 600).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) return;

    final destination = (_scrollController.offset + 600).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
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

          // ============================================================
          // SOFT BACKGROUND OVERLAY
          // ============================================================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.16),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // MODERN HEADER
          // ============================================================
          Positioned(
            top: 90,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              badgeText: loc.pbtServiceLabel,
              title: loc.p3Title,
              subtitle: loc.p3Subtitle,
            ),
          ),

          // ============================================================
          // SCROLLABLE SERVICE BUTTON AREA
          // ============================================================
          Positioned(
            top: 385,
            left: 60,
            right: 60,
            bottom: 340,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: false,
              thickness: 8,
              radius: const Radius.circular(20),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                  top: 30,
                  right: 24,
                  bottom: 100,
                ),
                child: Column(
                  children: [
                    // ==================================================
                    // FIRST ROW
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 420,
                            icon: Icons.local_parking_rounded,
                            label: loc.parkirButton,
                            supportingText:
                                loc.parkingSupportingText,
                            accentColor: const Color(0xFF1469E8),
                            accentLightColor:
                                const Color(0xFFE6F0FF),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => P4PAGE(
                                    title: loc.parkirButton,
                                    type: 'PBT',
                                    hint: loc.inputPlateHint,
                                    biz: 'PARKING',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 38),
                        Expanded(
                          child: _ModernServiceButton(
                            height: 420,
                            icon: Icons.gavel_rounded,
                            label: loc.compoundButton,
                            supportingText:
                                loc.compoundSupportingText,
                            accentColor: const Color(0xFFE34E45),
                            accentLightColor:
                                const Color(0xFFFFE7E5),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const P4OPTIONCOMPOUND(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 42),

                    // ==================================================
                    // SECOND ROW
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 420,
                            icon: Icons.account_balance_rounded,
                            label: loc.taxButton,
                            supportingText: loc.taxSupportingText,
                            accentColor: const Color(0xFF7B4DE3),
                            accentLightColor:
                                const Color(0xFFF0E9FF),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const P4OPTIONCUKAIBENTONG(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 38),
                        Expanded(
                          child: _ModernServiceButton(
                            height: 420,
                            icon: Icons.badge_rounded,
                            label: loc.licenseButton,
                            supportingText:
                                loc.licenseSupportingText,
                            accentColor: const Color(0xFFE56C16),
                            accentLightColor:
                                const Color(0xFFFFEBDC),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => P4PAGE(
                                    title: loc.licenseButton,
                                    type: 'PBT',
                                    hint: loc.inputICHint,
                                    biz: 'LESEN',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 42),

                    // ==================================================
                    // THIRD ROW
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 420,
                            icon: Icons.home_work_rounded,
                            label: loc.rentPBTText,
                            supportingText:
                                loc.rentalSupportingText,
                            accentColor: const Color(0xFF008F72),
                            accentLightColor:
                                const Color(0xFFE0F8F1),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const P4OPTIONSEWAANBENTONG(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 38),

                        // Keeps the final card aligned to the left.
                        const Expanded(
                          child: SizedBox(
                            height: 420,
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
          // TOP SCROLL INDICATOR
          // ============================================================
          if (showScrollUp)
            Positioned(
              right: 20,
              top: 405,
              child: _ScrollIndicatorButton(
                icon: Icons.keyboard_arrow_up_rounded,
                label: loc.scrollup,
                onPressed: _scrollUp,
              ),
            ),

          // ============================================================
          // BOTTOM SCROLL INDICATOR
          // ============================================================
          if (showScrollDown)
            Positioned(
              right: 20,
              bottom: 345,
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
            bottom: 100,
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
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1469E8).withOpacity(0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFF1469E8).withOpacity(0.22),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_rounded,
                size: 25,
                color: Color(0xFF1469E8),
              ),
              const SizedBox(width: 10),
              Text(
                badgeText.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1469E8),
                  fontSize: 18,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              height: 1.05,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          constraints: const BoxConstraints(
            maxWidth: 860,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF113968).withOpacity(0.10),
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
              fontSize: 31,
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
// MODERN MAIN SERVICE BUTTON
// ============================================================================
class _ModernServiceButton extends StatefulWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final String supportingText;
  final VoidCallback onPressed;
  final double height;
  final bool comingSoon;
  final Color accentColor;
  final Color accentLightColor;

  const _ModernServiceButton({
    super.key,
    this.icon,
    this.imagePath,
    required this.label,
    required this.supportingText,
    required this.onPressed,
    required this.accentColor,
    required this.accentLightColor,
    this.height = 420,
    this.comingSoon = false,
  });

  @override
  State<_ModernServiceButton> createState() =>
      _ModernServiceButtonState();
}

class _ModernServiceButtonState
    extends State<_ModernServiceButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted || widget.comingSoon) return;

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
      onTapCancel:
          isEnabled ? () => _setPressed(false) : null,
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
              widget.comingSoon ? 0.65 : 0.94,
            ),
            borderRadius: BorderRadius.circular(40),

            // Black border for clearer visibility.
            border: Border.all(
              color: _isPressed
                  ? widget.accentColor
                  : Colors.black,
              width: _isPressed ? 4 : 3,
            ),

            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color:
                          widget.accentColor.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF19375C)
                          .withOpacity(0.16),
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
                // Large decorative circle.
                Positioned(
                  right: -45,
                  top: -45,
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),
                    width: _isPressed ? 205 : 190,
                    height: _isPressed ? 205 : 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentLightColor
                          .withOpacity(0.88),
                    ),
                  ),
                ),

                // Smaller decorative circle.
                Positioned(
                  right: 105,
                  top: 78,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor
                          .withOpacity(0.08),
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
                    opacity:
                        widget.comingSoon ? 0.5 : 1,
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
                            AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 160,
                              ),
                              width: 132,
                              height: 132,
                              decoration: BoxDecoration(
                                color:
                                    widget.accentLightColor,
                                borderRadius:
                                    BorderRadius.circular(34),
                                border: Border.all(
                                  color: widget.accentColor
                                      .withOpacity(0.18),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: widget.icon != null
                                    ? Icon(
                                        widget.icon,
                                        size: _isPressed
                                            ? 77
                                            : 72,
                                        color:
                                            widget.accentColor,
                                      )
                                    : Image.asset(
                                        widget.imagePath!,
                                        height: 76,
                                        width: 76,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),

                            AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 160,
                              ),
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
                                    color: widget
                                        .accentColor
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF15253A),
                            fontSize: 39,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                            letterSpacing: 0.4,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          widget.supportingText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF647187),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1.28,
                          ),
                        ),

                        const SizedBox(height: 23),

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

                // Coming soon overlay.
                if (widget.comingSoon)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.28),
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 34,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74343),
                            borderRadius:
                                BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.20),
                                blurRadius: 18,
                                offset:
                                    const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            AppLocalizations.of(context)!
                                .comingsoonText
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 29,
                              fontWeight:
                                  FontWeight.w900,
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
    final iconWidget = Icon(
      icon,
      size: 54,
      color: const Color(0xFF175EB9),
    );

    final textWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: Color(0xFF24405F),
      ),
    );

    return Material(
      color: Colors.white.withOpacity(0.94),
      borderRadius: BorderRadius.circular(22),
      elevation: 5,
      shadowColor:
          const Color(0xFF14345A).withOpacity(0.25),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
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