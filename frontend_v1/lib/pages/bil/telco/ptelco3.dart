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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() => _pressed = true);
      },

      onTapUp: (_) {
        setState(() => _pressed = false);
      },

      onTapCancel: () {
        setState(() => _pressed = false);
      },

      onTap: widget.onPressed,

      child: AnimatedScale(
        scale: _pressed ? 0.965 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          height: 450,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color:
                  _pressed ? widget.accentColor : Colors.black,
              width: _pressed ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(
                  _pressed ? 0.25 : 0.14,
                ),
                blurRadius: _pressed ? 18 : 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(37),
            child: Stack(
              children: [
                // Background circle
                Positioned(
                  right: -55,
                  top: -60,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _pressed ? 260 : 235,
                    height: _pressed ? 260 : 235,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.accentLightColor.withOpacity(0.95),
                    ),
                  ),
                ),

                // Small decoration
                Positioned(
                  right: 115,
                  top: 125,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.accentColor.withOpacity(0.08),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    35,
                    35,
                    30,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ICON + ARROW
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 135,
                            height: 125,
                            decoration: BoxDecoration(
                              color: widget.accentLightColor,
                              borderRadius:
                                  BorderRadius.circular(34),
                              border: Border.all(
                                color: widget.accentColor
                                    .withOpacity(0.22),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              widget.icon,
                              size: 70,
                              color: widget.accentColor,
                            ),
                          ),

                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 150),
                            transform: Matrix4.translationValues(
                              _pressed ? 7 : 0,
                              0,
                              0,
                            ),
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor
                                      .withOpacity(0.28),
                                  blurRadius: 15,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // TITLE
                      Text(
                        widget.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF15253A),
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // DESCRIPTION
                      Text(
                        widget.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF647187),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Container(
                            width: 62,
                            height: 7,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              borderRadius:
                                  BorderRadius.circular(50),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 14,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MODERN + GOVERNMENT TELCO HEADER
// KEEPS EXISTING BADGE + TITLE + SUBTITLE
// ============================================================================
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
                    fontSize: 22,
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