import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/pelectricbill3.dart';
import 'package:frontend_v1/pages/pwaterbill3.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/pbroadbandbill3.dart';

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

    final double current =
        _scrollController.offset;

    final bool newShowScrollUp =
        current > 10;

    final bool newShowScrollDown =
        current < maxScroll - 10;

    if (showScrollUp != newShowScrollUp ||
        showScrollDown != newShowScrollDown) {
      setState(() {
        showScrollUp = newShowScrollUp;
        showScrollDown = newShowScrollDown;
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
          // =========================================================
          // BACKGROUND
          // =========================================================
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'lib/images/pnew.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // =========================================================
          // TITLE
          // =========================================================
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                loc.pbil3Title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(
                    255,
                    3,
                    89,
                    210,
                  ),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // =========================================================
          // SUBTITLE
          // =========================================================
          Positioned(
            top: 240,
            left: 30,
            right: 30,
            child: Center(
              child: Text(
                loc.pbil3Subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(
                    255,
                    62,
                    62,
                    62,
                  ),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // =========================================================
          // SCROLLABLE BUTTON AREA
          // =========================================================
          Positioned(
            top: 410,
            left: 0,
            right: 0,
            bottom: 380,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              thickness: 12,
              radius: const Radius.circular(20),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  right: 20,
                  bottom: 40,
                ),
                child: SizedBox(
                  height: 1350,
                  child: Stack(
                    children: [
                      // =================================================
                      // ELECTRICITY BUTTON
                      // =================================================
                      Positioned(
                        top: 40,
                        left: -500,
                        right: 0,
                        child: _KioskMainButton(
                          width: 400,
                          height: 400,
                          icon: const IconData(
                            0xf0744,
                            fontFamily: 'MaterialIcons',
                          ),
                          iconColor: Colors.yellow,
                          label: loc.electricitybutton,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PELECTRICBILL3PAGE(),
                              ),
                            );
                          },
                          comingSoon: false,
                        ),
                      ),

                      // =================================================
                      // WATER BILL BUTTON
                      // =================================================
                      Positioned(
                        top: 40,
                        left: 0,
                        right: -500,
                        child: _KioskMainButton(
                          width: 400,
                          height: 400,
                          imagePath: 'lib/images/water.png',
                          label: loc.waterButton,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PWATERBILL3PAGE(),
                              ),
                            );
                          },
                          comingSoon: false,
                        ),
                      ),

                      // =================================================
                      // BROADBAND BILL BUTTON
                      // =================================================
                      Positioned(
                        top: 540,
                        left: -500,
                        right: 0,
                        child: _KioskMainButton(
                          width: 400,
                          height: 400,
                          imagePath:
                              'lib/images/broadband/bill_broadband.png',
                          label: loc.billbroadbandButton,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PBROADBANDBILL3PAGE(),
                              ),
                            );
                          },
                          comingSoon: false,
                        ),
                      ),

                      // =================================================
                      // TELCO BUTTON
                      // =================================================
                      Positioned(
                        top: 540,
                        left: 0,
                        right: -500,
                        child: _KioskMainButton(
                          width: 400,
                          height: 400,
                          imagePath: 'lib/images/telco.png',
                          label: loc.telkoButton,
                          onPressed: () {},
                          comingSoon: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =========================================================
          // SCROLL-UP BUTTON
          // =========================================================
          if (showScrollUp)
            Positioned(
              right: 25,
              top: 355,
              child: _ScrollIndicatorButton(
                icon: Icons.keyboard_arrow_up_rounded,
                label: loc.scrollup,
                onPressed: _scrollUp,
              ),
            ),

          // =========================================================
          // SCROLL-DOWN BUTTON
          // =========================================================
          if (showScrollDown)
            Positioned(
              right: 25,
              bottom: 330,
              child: _ScrollIndicatorButton(
                icon: Icons.keyboard_arrow_down_rounded,
                label: loc.scrolldown,
                onPressed: _scrollDown,
                iconBelowText: true,
              ),
            ),

          // =========================================================
          // BACK BUTTON
          // =========================================================
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

          // =========================================================
          // FOOTER
          // =========================================================
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
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

/// ================================================================
/// REUSABLE KIOSK MAIN BUTTON
/// ================================================================
class _KioskMainButton extends StatefulWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? imagePath;
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool comingSoon;

  const _KioskMainButton({
    super.key,
    this.icon,
    this.iconColor,
    this.imagePath,
    required this.label,
    required this.onPressed,
    this.width = 200,
    this.height = 150,
    this.comingSoon = false,
  });

  @override
  State<_KioskMainButton> createState() =>
      _KioskMainButtonState();
}

class _KioskMainButtonState extends State<_KioskMainButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled =
        !widget.comingSoon;

    return Center(
      child: GestureDetector(
        onTapDown: (_) {
          if (!isEnabled) {
            return;
          }

          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          if (!isEnabled) {
            return;
          }

          setState(() {
            _isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        onTap: isEnabled
            ? widget.onPressed
            : null,
        child: AnimatedScale(
          scale: _isPressed
              ? 0.95
              : 1.0,
          duration: const Duration(
            milliseconds: 100,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // =====================================================
              // MAIN BUTTON BODY
              // =====================================================
              Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(45),
                  border: Border.all(
                    color: widget.comingSoon
                        ? Colors.grey
                        : Colors.black,
                    width: 4,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.comingSoon
                        ? const [
                            Color(0xFFE0E0E0),
                            Color(0xFFBDBDBD),
                          ]
                        : const [
                            Color(0xFFF4F8FF),
                            Color(0xFFCCD9F2),
                          ],
                  ),
                  boxShadow:
                      _isPressed || widget.comingSoon
                          ? []
                          : const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 12),
                                blurRadius: 0,
                              ),
                            ],
                ),
                child: Opacity(
                  opacity: widget.comingSoon
                      ? 0.5
                      : 1.0,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      // =============================================
                      // ICON / IMAGE POD
                      // =============================================
                      Container(
                        width: 210,
                        height: 210,
                        padding:
                            const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.1),
                              offset:
                                  const Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: widget.icon != null
                            ? Icon(
                                widget.icon,
                                size: 140,
                                color:
                                    widget.iconColor ??
                                        Colors.black,
                              )
                            : Image.asset(
                                widget.imagePath!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.contain,
                              ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.label.toUpperCase(),
                            textAlign:
                                TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight:
                                  FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =====================================================
              // COMING SOON OVERLAY
              // =====================================================
              if (widget.comingSoon)
                Positioned.fill(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        width:
                            widget.width * 1.1,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red
                              .withOpacity(0.9),
                          borderRadius:
                              BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.3),
                              blurRadius: 10,
                              offset:
                                  const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .comingsoonText
                              .toUpperCase(),
                          textAlign:
                              TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
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
    );
  }
}

/// ================================================================
/// SCROLL INDICATOR BUTTON
/// ================================================================
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
      size: 58,
      color: Colors.black,
    );

    final Widget textWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.black,
      ),
    );

    return Material(
      color: Colors.white.withOpacity(0.90),
      borderRadius: BorderRadius.circular(22),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
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