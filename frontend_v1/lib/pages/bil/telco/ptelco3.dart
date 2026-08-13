//page where user can select option for Telco Bill Payment or Mobile PIN

import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:frontend_v1/pages/bil/telco/postpaid/ptelcobill3.dart';
import 'package:frontend_v1/pages/bil/telco/mobilepin/pmobilepin3.dart';

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
            child: Column(
              children: [
                // SERVICE BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15946B).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: const Color(0xFF15946B).withOpacity(0.28),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sim_card_rounded,
                        size: 25,
                        color: Color(0xFF15946B),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          loc.telcoServiceLabel.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF15946B),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // TITLE
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFF087456),
                        Color(0xFF18A578),
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                     loc.telcoPageTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 62,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      height: 1.05,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SUBTITLE
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 870,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
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
                    loc.telcoPageSubtitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF435166),
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // OPTION CARDS
          // ============================================================
          Positioned(
            top: 470,
            left: 55,
            right: 55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================================================
                // BILL PAYMENT
                // ======================================================
                Expanded(
                  child: _TelcoOptionCard(
                    icon: Icons.receipt_long_rounded,
                    title: loc.telcoBillPaymentTitle,
                    description: loc.telcoBillPaymentDescription,
                    accentColor: const Color(0xFF15946B),
                    accentLightColor: const Color(0xFFE2F7EF),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PTELCOBILL3PAGE(),
                      ),
                    );
                  },
                  ),
                ),

                const SizedBox(width: 34),

                // ======================================================
                // MOBILE PIN
                // ======================================================
                Expanded(
                  child: _TelcoOptionCard(
                    icon: Icons.phone_android_rounded,
                    title: loc.telcoMobilePinTitle,
                    description: loc.telcoMobilePinDescription,
                    accentColor: const Color(0xFF1769D2),
                    accentLightColor: const Color(0xFFE4F0FF),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PMOBILEPIN3PAGE(),
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