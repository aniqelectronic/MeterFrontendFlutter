import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/language/pbahasa.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/pages/faq/faq_page.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

import 'pbt3.dart';
import 'pbil3.dart';

class P2Page extends StatefulWidget {
  const P2Page({super.key});

  @override
  State<P2Page> createState() => _P2PageState();
}

class _P2PageState extends State<P2Page> {
  static const Duration _knowledgeSlideDuration = Duration(seconds: 8);

  final ScrollController _scrollController = ScrollController();
  final PageController _knowledgeController = PageController();

  Timer? _knowledgeTimer;
  int _currentKnowledgeIndex = 0;

  bool showScrollUp = false;
  bool showScrollDown = true;

  @override
  void initState() {
    super.initState();

    _startKnowledgeTimer();
    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
    });
  }

  void _handleScroll() {
    _updateScrollIndicators();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients || !mounted) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    setState(() {
      showScrollUp = current > 10;
      showScrollDown = current < (maxScroll - 10);
    });
  }

  @override
  void dispose() {
    _knowledgeTimer?.cancel();
    _knowledgeController.dispose();

    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _startKnowledgeTimer() {
    _knowledgeTimer?.cancel();
    _knowledgeTimer = Timer.periodic(_knowledgeSlideDuration, (_) {
      if (!mounted || !_knowledgeController.hasClients) return;
      _goToKnowledge(_currentKnowledgeIndex + 1);
    });
  }

  void _goToKnowledge(int index) {
    final normalizedIndex = index % 20;
    _knowledgeController.animateToPage(
      normalizedIndex,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
    _startKnowledgeTimer();
  }

  void _previousKnowledge() {
    _goToKnowledge((_currentKnowledgeIndex - 1 + 20) % 20);
  }

  void _nextKnowledge() {
    _goToKnowledge(_currentKnowledgeIndex + 1);
  }

  List<String> _knowledgeItems(AppLocalizations loc) {
    return [
      loc.knowledgeFact01, loc.knowledgeFact02, loc.knowledgeFact03,
      loc.knowledgeFact04, loc.knowledgeFact05, loc.knowledgeFact06,
      loc.knowledgeFact07, loc.knowledgeFact08, loc.knowledgeFact09,
      loc.knowledgeFact10, loc.knowledgeFact11, loc.knowledgeFact12,
      loc.knowledgeFact13, loc.knowledgeFact14, loc.knowledgeFact15,
      loc.knowledgeFact16, loc.knowledgeFact17, loc.knowledgeFact18,
      loc.knowledgeFact19, loc.knowledgeFact20,
    ];
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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final knowledgeItems = _knowledgeItems(loc);

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
          // Makes the content clearer without changing your image.
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
            top: 58,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              title: loc.p2Title,
              subtitle: loc.p3Subtitle,
            ),
          ),

          Positioned(
            top: 330,
            left: 58,
            right: 58,
            child: _KnowledgeSlider(
              controller: _knowledgeController,
              title: loc.didYouKnowTitle,
              subtitle: loc.didYouKnowSubtitle,
              items: knowledgeItems,
              currentIndex: _currentKnowledgeIndex,
              onPageChanged: (index) {
                setState(() => _currentKnowledgeIndex = index);
                _startKnowledgeTimer();
              },
              onPrevious: _previousKnowledge,
              onNext: _nextKnowledge,
              onIndicatorPressed: _goToKnowledge,
            ),
          ),

          // ============================================================
          // SCROLLABLE SERVICE AREA
          // ============================================================
          Positioned(
            top: 610,
            left: 60,
            right: 60,
            bottom: 320,
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
                  top: 18,
                  right: 24,
                  bottom: 88,
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
                            height: 450,
                            icon: Icons.account_balance_rounded,
                            label: loc.pbtText,
                            supportingText:
                                loc.pbtSupportingText,
                            accentColor: const Color(0xFF1469E8),
                            accentLightColor: const Color(0xFFE6F0FF),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PBT3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: _ModernServiceButton(
                            height: 450,
                            icon: Icons.receipt_long_rounded,
                            label: loc.bilText,
                            supportingText:
                                loc.billSupportingText,
                            accentColor: const Color(0xFF008F72),
                            accentLightColor: const Color(0xFFE0F8F1),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PBIL3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // SECOND ROW
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 450,
                            icon: Icons.travel_explore_rounded,
                            label: loc.touristText,
                            supportingText:
                                loc.touristSupportingText,
                            accentColor: const Color(0xFFE56C16),
                            accentLightColor: const Color(0xFFFFEBDC),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PTOURISTPAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 28),

                        Expanded(
                          child: _ModernServiceButton(
                            height: 450,
                            icon: Icons.help_outline_rounded,
                            label: loc.faqButton,
                            supportingText: loc.faqSupportingText,
                            accentColor: const Color(0xFF7A4DD8),
                            accentLightColor: const Color(0xFFF0E9FF),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FaqPage(
                                    councilHotlineNumber:
                                        Data.aduanMajlisBentong,
                                    operationsHotlineNumber:
                                        Data.telefonNo,
                                  ),
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
          ),

          // ============================================================
          // TOP SCROLL INDICATOR
          // ============================================================
          if (showScrollUp)
            Positioned(
              right: 20,
              top: 565,
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
              bottom: 325,
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
            left: 220,
            right: 220,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PBAHASAPAGE(),
                  ),
                );
              },
            ),
          ),

          // ============================================================
          // FOOTER
          // ============================================================
          Positioned(
            bottom: 22,
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
// DID YOU KNOW / TAHUKAH ANDA SLIDER
// ============================================================================
class _KnowledgeSlider extends StatelessWidget {
  final PageController controller;
  final String title;
  final String subtitle;
  final List<String> items;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onIndicatorPressed;

  const _KnowledgeSlider({
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onIndicatorPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063D91), Color(0xFF126BD4), Color(0xFF1A8BE6)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.80), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF073E87).withOpacity(0.26),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 20, 24, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC84B),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFF633C00),
                          size: 33,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _KnowledgeNavigationButton(
                        icon: Icons.chevron_left_rounded,
                        onPressed: onPrevious,
                      ),
                      const SizedBox(width: 10),
                      _KnowledgeNavigationButton(
                        icon: Icons.chevron_right_rounded,
                        onPressed: onNext,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: PageView.builder(
                      controller: controller,
                      itemCount: items.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            items[index],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.30,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${currentIndex + 1}/${items.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.84),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(items.length, (index) {
                            final isActive = index == currentIndex;
                            return GestureDetector(
                              onTap: () => onIndicatorPressed(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: isActive ? 23 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFFFD166)
                                      : Colors.white.withOpacity(0.38),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 35),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KnowledgeNavigationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _KnowledgeNavigationButton({required this.icon, required this.onPressed});

  @override
  State<_KnowledgeNavigationButton> createState() =>
      _KnowledgeNavigationButtonState();
}

class _KnowledgeNavigationButtonState
    extends State<_KnowledgeNavigationButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_pressed ? 0.28 : 0.16),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.45),
              width: 1.5,
            ),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}

// ============================================================================
// MODERN PAGE HEADER
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
    return Column(
      children: [
        // Small category badge.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1769E0).withOpacity(0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFF1769E0).withOpacity(0.18),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app_rounded,
                size: 25,
                color: Color(0xFF1769E0),
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!
                    .serviceSelectionLabel
                    .toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1769E0),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Main title.
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
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white,
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
              fontSize: 25,
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

class _ModernServiceButtonState extends State<_ModernServiceButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted || widget.comingSoon) return;

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.comingSoon;

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
              widget.comingSoon ? 0.65 : 0.94,
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: _isPressed
                  ? widget.accentColor
                  : Colors.black,
              width: _isPressed ? 4 : 3,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF19375C).withOpacity(0.14),
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
            borderRadius: BorderRadius.circular(38),
            child: Stack(
              children: [
                // Decorative accent shape.
                Positioned(
                  right: -45,
                  top: -45,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _isPressed ? 205 : 190,
                    height: _isPressed ? 205 : 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentLightColor.withOpacity(0.88),
                    ),
                  ),
                ),

                // Small secondary decorative circle.
                Positioned(
                  right: 105,
                  top: 78,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor.withOpacity(0.08),
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
                    opacity: widget.comingSoon ? 0.5 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon and arrow row.
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 132,
                              height: 132,
                              decoration: BoxDecoration(
                                color: widget.accentLightColor,
                                borderRadius: BorderRadius.circular(34),
                                border: Border.all(
                                  color:
                                      widget.accentColor.withOpacity(0.12),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: widget.icon != null
                                    ? Icon(
                                        widget.icon,
                                        size: _isPressed ? 77 : 72,
                                        color: widget.accentColor,
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
                              duration: const Duration(milliseconds: 160),
                              transform: Matrix4.translationValues(
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
                                    color:
                                        widget.accentColor.withOpacity(0.24),
                                    blurRadius: 14,
                                    offset: const Offset(0, 7),
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

                        // Label.
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

                        // Supporting text.
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

                        // Bottom accent.
                        Row(
                          children: [
                            Container(
                              width: 58,
                              height: 7,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 7,
                              decoration: BoxDecoration(
                                color:
                                    widget.accentColor.withOpacity(0.28),
                                borderRadius: BorderRadius.circular(50),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 34,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74343),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
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
      shadowColor: const Color(0xFF14345A).withOpacity(0.25),
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