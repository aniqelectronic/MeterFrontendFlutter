import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/p2.dart';
import 'package:frontend_v1/pages/tourist/eksplorasi/pbentongexploration.dart';
import 'package:frontend_v1/pages/tourist/eksplorasi/pexploration_perak.dart';
import 'package:frontend_v1/pages/tourist/map/pmapgoogle.dart';
import 'package:frontend_v1/pages/tourist/waktusolat/pwaktusolat.dart';
import 'package:frontend_v1/pages/tourist/weather/weather_page.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class PTOURISTPAGE extends StatelessWidget {
  const PTOURISTPAGE({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Background image.
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
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.19),
                    Colors.white.withOpacity(0.10),
                  ],
                ),
              ),
            ),
          ),

          // Page header (unchanged).
          Positioned(
            top: 40,
            left: 58,
            right: 58,
            child: _ModernPageHeader(
              badgeText: loc.tourismServiceLabel,
              title: loc.p3othersTitle,
              subtitle: loc.p3othersSubtitle,
            ),
          ),

          // Service cards now begin directly below the header.
          // The former "Tahukah Anda" / KnowledgeSlider card is removed.
          Positioned(
            top: 325,
            left: 52,
            right: 52,
            bottom: 255,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 12, bottom: 35),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ModernServiceButton(
                          height: 500,
                          icon: Icons.travel_explore_rounded,
                          label: loc.p3eksplorasiButton,
                          supportingText: loc.explorationSupportingText,
                          accentColor: const Color(0xFFE56C16),
                          accentLightColor: const Color(0xFFFFEBDC),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PExplorationBentongPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: _ModernServiceButton(
                          height: 500,
                          icon: Icons.map_rounded,
                          label: loc.p3map,
                          supportingText: loc.mapSupportingText,
                          accentColor: const Color(0xFF1469E8),
                          accentLightColor: const Color(0xFFE6F0FF),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PMAPGOOGLEPAGE(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _ModernServiceButton(
                          height: 500,
                          icon: FlutterIslamicIcons.mosque,
                          label: loc.p3waktusolat,
                          supportingText: loc.prayerTimeSupportingText,
                          accentColor: const Color(0xFF008F72),
                          accentLightColor: const Color(0xFFE0F8F1),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PWAKTUSOLATPAGE(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: _ModernServiceButton(
                          height: 500,
                          icon: Icons.cloud_rounded,
                          label: loc.weatherButton,
                          supportingText: loc.weatherSupportingText,
                          accentColor: const Color(0xFF0B7894),
                          accentLightColor: const Color(0xFFE1F7FB),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PWeatherPage(),
                              ),
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

          // Back button (same navigation as before).
          Positioned(
            bottom: 93,
            left: 210,
            right: 210,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const P2Page()),
                );
              },
            ),
          ),

          // Footer (unchanged).
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: const TextStyle(
                  color: Color(0xFF26364A),
                  fontSize: 17,
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

// Page header.
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
    const accentColor = Color(0xFFE56C16);
    const darkAccent = Color(0xFFB94B00);
    const lightAccent = Color(0xFFF08B3E);

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFD5E4F7), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A66).withOpacity(0.14),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkAccent, lightAccent],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBDC),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.explore_rounded,
                        size: 20,
                        color: accentColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          badgeText.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: accentColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF122C4C),
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1.02,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607188),
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Container(
            width: 8,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [darkAccent, lightAccent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Service card with a larger text area for all four kiosk languages.
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
    this.height = 530,
    this.comingSoon = false,
  });

  @override
  State<_ModernServiceButton> createState() => _ModernServiceButtonState();
}

class _ModernServiceButtonState extends State<_ModernServiceButton> {
  bool _isPressed = false;
  bool _isFocused = false;
  bool _isHovered = false;
  bool _isActivating = false;

  void _setPressed(bool value) {
    if (!mounted || widget.comingSoon) return;
    setState(() => _isPressed = value);
  }

  // Hold visual feedback briefly so it is visible before changing pages.
  // The activation guard prevents repeated taps during this short interval.
  Future<void> _handleTap() async {
    if (_isActivating || widget.comingSoon) return;

    setState(() => _isActivating = true);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Reset before navigation so the card appears normal when returning.
    setState(() {
      _isPressed = false;
    });
    try {
      widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isActivating = false);
      }
    }
  }

  Widget _buildServiceIcons() {
    if (widget.icon != null) {
      return FittedBox(
        fit: BoxFit.contain,
        child: Icon(widget.icon, size: 300, color: widget.accentColor),
      );
    }

    if (widget.imagePath != null) {
      return Image.asset(widget.imagePath!, fit: BoxFit.contain);
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.comingSoon;
    final radius = BorderRadius.circular(26);
    final depressed = _isPressed || _isActivating;
    final emphasized = depressed || _isFocused || _isHovered;
    final borderColor = emphasized
        ? widget.accentColor
        : Color.lerp(
            const Color(0xFFB9C8DA),
            widget.accentColor,
            0.28,
          )!;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: AnimatedScale(
        scale: depressed ? 0.952 : (_isHovered ? 0.994 : 1.0),
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF18324F).withOpacity(
                  depressed ? 0.05 : (_isHovered ? 0.16 : 0.11),
                ),
                blurRadius: depressed ? 6 : (_isHovered ? 22 : 18),
                offset: Offset(0, depressed ? 2 : 7),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: borderColor,
                width: depressed ? 3.5 : (emphasized ? 2.8 : 2.0),
              ),
            ),
            child: InkWell(
              onTap: enabled ? _handleTap : null,
              onHighlightChanged: _setPressed,
              onHover: (hovered) {
                if (mounted && !widget.comingSoon) {
                  setState(() => _isHovered = hovered);
                }
              },
              onFocusChange: (focused) {
                if (mounted) setState(() => _isFocused = focused);
              },
              splashColor: widget.accentColor.withOpacity(0.20),
              highlightColor: widget.accentColor.withOpacity(0.10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: enabled ? 1 : 0.45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon panel: slightly less tall to free up text space.
                        SizedBox(
                          height: widget.height * 0.38,
                          child: LayoutBuilder(
                            builder: (context, headerBounds) {
                              return Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: headerBounds.maxHeight * 0.72,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            widget.accentLightColor,
                                            Color.lerp(
                                              Colors.white,
                                              widget.accentLightColor,
                                              0.40,
                                            )!,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 20,
                                    right: 20,
                                    top: 22,
                                    bottom: 8,
                                    child: IgnorePointer(
                                      child: ExcludeSemantics(
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 160,
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            18,
                                            20,
                                            18,
                                            16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.lerp(
                                              Colors.white,
                                              widget.accentLightColor,
                                              0.18,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            border: Border.all(
                                              color: widget.accentColor
                                                  .withOpacity(0.22),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: widget.accentColor
                                                    .withOpacity(
                                                  depressed ? 0.06 : 0.15,
                                                ),
                                                blurRadius:
                                                    depressed ? 7 : 18,
                                                offset: Offset(
                                                  0,
                                                  depressed ? 2 : 7,
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 142,
                                                    height: 142,
                                                    child: _buildServiceIcons(),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 110,
                                                ),
                                                width: 42,
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: Color.lerp(
                                                    widget.accentColor,
                                                    Colors.black,
                                                    depressed ? 0.16 : 0.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: depressed
                                                      ? []
                                                      : [
                                                          BoxShadow(
                                                            color: widget
                                                                .accentColor
                                                                .withOpacity(0.18),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(0, 3),
                                                          ),
                                                        ],
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 27,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // Larger title and supporting text. The scale-down
                        // safeguard avoids overflow for longer ARB strings.
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                            child: LayoutBuilder(
                              builder: (context, bounds) {
                                return SizedBox(
                                  width: bounds.maxWidth,
                                  height: bounds.maxHeight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width: bounds.maxWidth,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.label.toUpperCase(),
                                            softWrap: true,
                                            style: const TextStyle(
                                              color: Color(0xFF142D4E),
                                              fontSize: 38,
                                              fontWeight: FontWeight.w800,
                                              height: 1.14,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            widget.supportingText,
                                            softWrap: true,
                                            style: const TextStyle(
                                              color: Color(0xFF526175),
                                              fontSize: 36,
                                              fontWeight: FontWeight.w500,
                                              height: 1.30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // A lightweight press/hover tint makes feedback obvious
                  // without changing the original layout or text.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 110),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(
                            depressed ? 0.10 : (_isHovered ? 0.025 : 0.0),
                          ),
                          borderRadius: radius,
                        ),
                      ),
                    ),
                  ),

                  // Keep the active border and press feedback.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(
                            color: borderColor,
                            width: depressed ? 3.5 : (emphasized ? 2.8 : 2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (widget.comingSoon)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.all(18),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .comingsoonText
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
