import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbt3.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class P4OPTIONCOMPOUND extends StatelessWidget {
  const P4OPTIONCOMPOUND({super.key});

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
            top: 105,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              badgeText: loc.compoundServiceLabel,
              title: loc.compoundTitle,
              subtitle: loc.compoundSubtitle,
            ),
          ),

          // ============================================================
          // OPTION BUTTONS
          // ============================================================
          Positioned(
            top: 520,
            left: 60,
            right: 60,
            child: Row(
              children: [
                // ======================================================
                // SINGLE COMPOUND
                // ======================================================
                Expanded(
                  child: _ModernTextServiceButton(
                    height: 470,
                    visualText: '#',
                    label: loc.singleCompoundButton,
                    supportingText:
                        loc.singleCompoundSupportingText,
                    accentColor: const Color(0xFFE34E45),
                    accentLightColor:
                        const Color(0xFFFFE7E5),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => P4PAGE(
                            title: loc.singlecompoundTitle,
                            type: 'PBT',
                            hint: loc.inputCompoundHint,
                            biz: 'SINGLECOMPOUND',
                          ),
                          transitionsBuilder:
                              (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 38),

                // ======================================================
                // MULTIPLE COMPOUNDS BY PLATE
                // ======================================================
                Expanded(
                  child: _ModernTextServiceButton(
                    height: 470,
                    visualText: 'ABC 1234',
                    label: loc.multiCompoundButton,
                    supportingText:
                        loc.multiCompoundSupportingText,
                    accentColor: const Color(0xFF1469E8),
                    accentLightColor:
                        const Color(0xFFE6F0FF),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => P4PAGE(
                            title: loc.multicompoundTitle,
                            type: 'PBT',
                            hint: loc.inputPlateHint,
                            biz: 'MULTICOMPOUND',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // BACK BUTTON
          // ============================================================
          Positioned(
            bottom: 120,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PBT3PAGE(),
                  ),
                );
              },
            ),
          ),

          // ============================================================
          // FOOTER
          // ============================================================
          Positioned(
            bottom: 35,
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
// MODERN HEADER
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
        // Category badge.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE34E45).withOpacity(0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFFE34E45).withOpacity(0.22),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 25,
                color: Color(0xFFE34E45),
              ),
              const SizedBox(width: 10),
              Text(
                badgeText.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFE34E45),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Gradient title.
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

        // Subtitle capsule.
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
// MODERN TEXT-BASED SERVICE BUTTON
// Used because this page has no logo or image.
// ============================================================================
class _ModernTextServiceButton extends StatefulWidget {
  final String visualText;
  final String label;
  final String supportingText;
  final VoidCallback onPressed;
  final double height;
  final Color accentColor;
  final Color accentLightColor;
  final bool comingSoon;

  const _ModernTextServiceButton({
    super.key,
    required this.visualText,
    required this.label,
    required this.supportingText,
    required this.onPressed,
    required this.accentColor,
    required this.accentLightColor,
    this.height = 470,
    this.comingSoon = false,
  });

  @override
  State<_ModernTextServiceButton> createState() =>
      _ModernTextServiceButtonState();
}

class _ModernTextServiceButtonState
    extends State<_ModernTextServiceButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted || widget.comingSoon) return;

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = !widget.comingSoon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: enabled ? widget.onPressed : null,
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
              widget.comingSoon ? 0.65 : 0.95,
            ),
            borderRadius: BorderRadius.circular(40),

            // Black border for strong visibility.
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
                // Large decorative background circle.
                Positioned(
                  right: -45,
                  top: -45,
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),
                    width: _isPressed ? 220 : 205,
                    height: _isPressed ? 220 : 205,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentLightColor
                          .withOpacity(0.90),
                    ),
                  ),
                ),

                // Small decorative circle.
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
                    opacity:
                        widget.comingSoon ? 0.5 : 1,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // LARGE VISUAL TEXT AND ARROW
                        // ==================================================
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 140,
                                minHeight: 125,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.accentLightColor,
                                borderRadius:
                                    BorderRadius.circular(34),
                                border: Border.all(
                                  color: widget.accentColor
                                      .withOpacity(0.20),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.visualText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: widget.accentColor,
                                  fontSize:
                                      widget.visualText.length >
                                              3
                                          ? 38
                                          : 84,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  letterSpacing:
                                      widget.visualText.length >
                                              3
                                          ? 1
                                          : 0,
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

                        // ==================================================
                        // MAIN LABEL
                        // ==================================================
                        Text(
                          widget.label.toUpperCase(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF15253A),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                            letterSpacing: 0.4,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // SUPPORTING DESCRIPTION
                        // ==================================================
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

                        const SizedBox(height: 23),

                        // ==================================================
                        // BOTTOM ACCENT
                        // ==================================================
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

                // ======================================================
                // COMING SOON OVERLAY
                // ======================================================
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