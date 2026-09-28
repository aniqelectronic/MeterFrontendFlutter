//page where user can select option for Telco Bill Payment or Mobile PIN

import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:frontend_v1/pages/bil/telco/postpaid/ptelcobill3.dart';
import 'package:frontend_v1/pages/bil/telco/mobilepin/pmobilepin3.dart';

import 'package:frontend_v1/pages/bil/telco/mobilereload/pmobilereload3.dart';

class PTELCO3PAGE extends StatelessWidget {
  const PTELCO3PAGE({super.key});

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

          // Soft overlay
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
    top: 70,
    left: 65,
    right: 65,
    child: _ModernTelcoHeader(
      badgeText: loc.telcoServiceLabel,
      title: loc.telcoPageTitle,
      subtitle: loc.telcoPageSubtitle,
    ),
  ),

          // ============================================================
          // OPTION CARDS
          // ============================================================

          Positioned(
            top: 450,
            left: 55,
            right: 55,
            child: Column(
              children: [
                // ========================================================
                // FIRST ROW
                // ========================================================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====================================================
                    // BILL PAYMENT
                    // ====================================================

                    Expanded(
                      child: _TelcoOptionCard(
                        icon: Icons.receipt_long_rounded,
                        title: loc.telcoBillPaymentTitle,
                        description:
                            loc.telcoBillPaymentDescription,
                        accentColor:
                            const Color(0xFF15946B),
                        accentLightColor:
                            const Color(0xFFE2F7EF),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PTELCOBILL3PAGE(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 34),

                    // ====================================================
                    // MOBILE PIN
                    // ====================================================

                    Expanded(
                      child: _TelcoOptionCard(
                        icon: Icons.phone_android_rounded,
                        title: loc.telcoMobilePinTitle,
                        description:
                            loc.telcoMobilePinDescription,
                        accentColor:
                            const Color(0xFF1769D2),
                        accentLightColor:
                            const Color(0xFFE4F0FF),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PMOBILEPIN3PAGE(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ========================================================
                // MOBILE RELOAD
                // ========================================================

                Row(
                  children: [
                    Expanded(
                      child: _TelcoOptionCard(
                        icon: Icons.signal_cellular_alt_rounded,
                        title: loc.telcoMobileReloadTitle,
                        description: loc.telcoMobileReloadDescription,
                        accentColor: const Color(0xFF7B4DCC),
                        accentLightColor: const Color(0xFFF1EAFF),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PMOBILERELOAD3PAGE(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 34),

                    // Empty right side so Mobile Reload
                    // has exactly the same width as Bill / Mobile PIN
                    const Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ],
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
// TELCO OPTION CARD
// ============================================================================
class _TelcoOptionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final Color accentLightColor;
  final VoidCallback onPressed;

  const _TelcoOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.accentLightColor,
    required this.onPressed,
  });

  @override
  State<_TelcoOptionCard> createState() =>
      _TelcoOptionCardState();
}

class _TelcoOptionCardState extends State<_TelcoOptionCard> {
  bool _isPressed = false;
  bool _isFocused = false;

  void _setPressed(bool value) {
    if (!mounted || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    final light = widget.accentLightColor;
    final emphasized = _isPressed || _isFocused;
    final radius = BorderRadius.circular(26);
    final borderColor = emphasized
        ? accent
        : Color.lerp(const Color(0xFFB9C8DA), accent, 0.28)!;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 450.0,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18324F)
                  .withOpacity(_isPressed ? 0.05 : 0.11),
              blurRadius: _isPressed ? 8 : 18,
              offset: Offset(0, _isPressed ? 2 : 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: _setPressed,
            onFocusChange: (value) {
              if (!mounted || _isFocused == value) return;
              setState(() => _isFocused = value);
            },
            splashColor: accent.withOpacity(0.10),
            highlightColor: accent.withOpacity(0.04),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 450.0 * 0.51,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 450.0 * 0.36,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    light,
                                    Color.lerp(Colors.white, light, 0.40)!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 24,
                            left: 22,
                            right: 22,
                            bottom: 10,
                            child: IgnorePointer(
                              child: ExcludeSemantics(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Color.lerp(Colors.white, light, 0.18),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: accent.withOpacity(0.22),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(
                                          _isPressed ? 0.08 : 0.15,
                                        ),
                                        blurRadius: _isPressed ? 10 : 18,
                                        offset: Offset(0, _isPressed ? 3 : 7),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Icon(
                                              widget.icon,
                                              size: 120,
                                              color: accent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: accent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.title.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Color(0xFF142D4E),
                                          fontSize: 38,
                                          fontWeight: FontWeight.w800,
                                          height: 1.16,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        widget.description,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Color(0xFF56657A),
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
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
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(
                          color: borderColor,
                          width: emphasized ? 3 : 2,
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


class _ModernTelcoHeader extends StatelessWidget {
  final String badgeText;
  final String title;
  final String subtitle;

  const _ModernTelcoHeader({
    required this.badgeText,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF15946B);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFD5E4F7),
          width: 2,
        ),
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
          // ==========================================================
          // LEFT TELCO ICON
          // ==========================================================
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF087456),
                  Color(0xFF18A578),
                ],
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
              Icons.sim_card_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(width: 28),

          // ==========================================================
          // EXISTING TEXT
          // ==========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // EXISTING SERVICE BADGE
                // ------------------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F6F0),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sim_card_rounded,
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

                // ------------------------------------------------------
                // EXISTING TITLE
                // ------------------------------------------------------
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

                // ------------------------------------------------------
                // EXISTING SUBTITLE
                // ------------------------------------------------------
                Text(
                  subtitle.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607188),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ==========================================================
          // RIGHT ACCENT BAR
          // ==========================================================
          Container(
            width: 8,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF087456),
                  Color(0xFF18A578),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}