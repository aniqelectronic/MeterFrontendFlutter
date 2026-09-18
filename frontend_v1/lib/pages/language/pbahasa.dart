import 'package:flutter/material.dart';

import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/pages/option/p2.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

class PBAHASAPAGE extends StatefulWidget {
  const PBAHASAPAGE({
    super.key,
  });

  @override
  State<PBAHASAPAGE> createState() => _PBAHASAPAGEState();
}

class _PBAHASAPAGEState extends State<PBAHASAPAGE> {
  final ScrollController _languageScrollController =
      ScrollController();

  @override
  void dispose() {
    _languageScrollController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // NAVIGATION
  // ==========================================================================
  void _navigate(
    BuildContext context,
    Widget page,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '/p1',
        ),
        builder: (_) => page,
      ),
    );
  }

  // ==========================================================================
  // LANGUAGE BUTTON
  // ==========================================================================
  Widget _languageButton({
    required String title,
    required String subtitle,
    required String languageCode,
    required IconData icon,
    required Color mainColor,
    required Color lightColor,
    required VoidCallback onTap,
  }) {
    return _PremiumLanguageButton(
      title: title,
      subtitle: subtitle,
      languageCode: languageCode,
      icon: icon,
      mainColor: mainColor,
      lightColor: lightColor,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
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

          // Light overlay improves text readability.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.10),
                    Colors.white.withOpacity(0.28),
                    Colors.white.withOpacity(0.14),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================================
          // HEADER
          // ==================================================================
          const Positioned(
            top: 82,
            left: 70,
            right: 70,
            child: _LanguageHeader(),
          ),

          // ==================================================================
          // LANGUAGE SELECTION PANEL
          // ==================================================================
          Positioned(
            top: 400,
            left: 65,
            right: 65,
            bottom: 400,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                36,
                40,
                26,
                44,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                borderRadius: BorderRadius.circular(46),
                border: Border.all(
                  color: Colors.white.withOpacity(0.95),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF152A45)
                        .withOpacity(0.14),
                    blurRadius: 36,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: Color(0xFF526274),
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'SENTUH PILIHAN BAHASA',
                        style: TextStyle(
                          color: Color(0xFF526274),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ==========================================================
                  // SCROLLABLE LANGUAGE LIST
                  // ==========================================================
                  Expanded(
                    child: Scrollbar(
                      controller: _languageScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 9,
                      radius: const Radius.circular(30),
                      interactive: true,
                      child: SingleChildScrollView(
                        controller: _languageScrollController,
                        physics:
                            const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          right: 14,
                          bottom: 4,
                        ),
                        child: Column(
                          children: [
                            // ================================================
                            // BAHASA MELAYU
                            // ================================================
                            _languageButton(
                              title: 'BAHASA MELAYU',
                              subtitle:
                                  'Tekan untuk meneruskan',
                              languageCode: 'BM',
                              icon: Icons.flag_rounded,
                              mainColor:
                                  const Color(0xFF9A6A23),
                              lightColor:
                                  const Color(0xFFFFF2D6),
                              onTap: () {
                                App.setLocale(
                                  context,
                                  const Locale('ms'),
                                );

                                _navigate(
                                  context,
                                  const P2Page(),
                                );
                              },
                            ),

                            const SizedBox(height: 28),

                            // ================================================
                            // ENGLISH
                            // ================================================
                            _languageButton(
                              title: 'ENGLISH',
                              subtitle:
                                  'Press to continue',
                              languageCode: 'EN',
                              icon: Icons.public_rounded,
                              mainColor:
                                  const Color(0xFF405C73),
                              lightColor:
                                  const Color(0xFFE8F0F5),
                              onTap: () {
                                App.setLocale(
                                  context,
                                  const Locale('en'),
                                );

                                _navigate(
                                  context,
                                  const P2Page(),
                                );
                              },
                            ),

                            const SizedBox(height: 28),

                            // ================================================
                            // MALAYSIAN MANDARIN
                            // ================================================
                            _languageButton(
                              title: '中文',
                              subtitle: '轻触以继续',
                              languageCode: '中文',
                              icon:
                                  Icons.translate_rounded,
                              mainColor:
                                  const Color(0xFFB63A3A),
                              lightColor:
                                  const Color(0xFFFFEAEA),
                              onTap: () {
                                App.setLocale(
                                  context,
                                  const Locale('zh'),
                                );

                                _navigate(
                                  context,
                                  const P2Page(),
                                );
                              },
                            ),


                            const SizedBox(height: 28),

                           // ================================================
                           // TAMIL
                           // ================================================
                           _languageButton(
                             title: 'தமிழ்',
                             subtitle: 'தொடர இங்கே தொடவும்',
                             languageCode: 'தமிழ்',
                             icon: Icons.translate_rounded,
                             mainColor: const Color(0xFF6A1B9A),
                             lightColor: const Color(0xFFF3E5F5),
                             onTap: () {
                               App.setLocale(
                                 context,
                                 const Locale('ta'),
                               );
                           
                               _navigate(
                                 context,
                                 const P2Page(),
                               );
                             },
                           ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          

          // ==================================================================
          // HOME BUTTON
          // ==================================================================
          Positioned(
            bottom: 185,
            left: 300,
            right: 300,
            child: KioskHomeButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(
                      name: '/p1',
                    ),
                    builder: (_) =>
                        const P1BentongPage(),
                  ),
                  (route) => false,
                );
              },
            ),
          ),

          // ==================================================================
          // FOOTER
          // ==================================================================
          Positioned(
            bottom: 82,
            left: 30,
            right: 30,
            child: Text(
              Data.copyrightText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2D3947),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODERN + GOVERNMENT LANGUAGE HEADER
// KEEPS EXISTING BADGE + TITLE + SUBTITLE
// ============================================================================

class _LanguageHeader extends StatelessWidget {
  const _LanguageHeader();

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF1265BC);
    const Color darkAccent = Color(0xFF064AA3);
    const Color lightAccent = Color(0xFF1478D4);

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
          // LEFT LANGUAGE ICON
          // ==========================================================

          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  darkAccent,
                  lightAccent,
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
              Icons.language_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(width: 28),

          // ==========================================================
          // EXISTING HEADER INFORMATION
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // EXISTING BADGE — PILIHAN BAHASA
                // ------------------------------------------------------

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F3FF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 20,
                        color: accentColor,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'PILIHAN BAHASA',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ------------------------------------------------------
                // EXISTING TITLE — PILIH BAHASA
                // ------------------------------------------------------

                const Text(
                  'PILIH BAHASA',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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

                const Text(
                  'Choose Your Preferred Language',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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

          // ==========================================================
          // RIGHT GOVERNMENT-BLUE ACCENT
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
                  darkAccent,
                  lightAccent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PREMIUM LANGUAGE BUTTON
// ============================================================================
class _PremiumLanguageButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final String languageCode;
  final IconData icon;
  final Color mainColor;
  final Color lightColor;
  final VoidCallback onTap;

  const _PremiumLanguageButton({
    required this.title,
    required this.subtitle,
    required this.languageCode,
    required this.icon,
    required this.mainColor,
    required this.lightColor,
    required this.onTap,
  });

  @override
  State<_PremiumLanguageButton> createState() =>
      _PremiumLanguageButtonState();
}

class _PremiumLanguageButtonState
    extends State<_PremiumLanguageButton> {
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
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : 1,
        duration: const Duration(
          milliseconds: 120,
        ),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 160,
          ),
          width: double.infinity,
          height: 210,
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: _isPressed
                  ? widget.mainColor
                  : widget.mainColor.withOpacity(0.70),
              width: _isPressed ? 4 : 3,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.mainColor
                          .withOpacity(0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF273B52)
                          .withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // ==============================================================
              // ICON
              // ==============================================================
              Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: widget.lightColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.mainColor
                        .withOpacity(0.20),
                    width: 2,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 76,
                  color: widget.mainColor,
                ),
              ),

              const SizedBox(width: 30),

              // ==============================================================
              // TITLE AND SUBTITLE
              // ==============================================================
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1F2E3D),
                        fontSize: 43,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 11),

                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF5F6D7C),
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.mainColor,
                            borderRadius:
                                BorderRadius.circular(50),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 13,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.mainColor
                                .withOpacity(0.25),
                            borderRadius:
                                BorderRadius.circular(50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // ==============================================================
              // LANGUAGE CODE AND ARROW
              // ==============================================================
              Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.lightColor,
                      borderRadius:
                          BorderRadius.circular(100),
                    ),
                    child: Text(
                      widget.languageCode,
                      style: TextStyle(
                        color: widget.mainColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing:
                            widget.languageCode == '中文'
                                ? 0
                                : 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 150,
                    ),
                    transform:
                        Matrix4.translationValues(
                      _isPressed ? 6 : 0,
                      0,
                      0,
                    ),
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: widget.mainColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.mainColor
                              .withOpacity(0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
