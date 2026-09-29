import 'package:frontend_v1/widgets/knowledge_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/language/pbahasa.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/pages/faq/faq_page.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'pbt3.dart';
import 'pbil3.dart';
import 'dart:ui';

class P2Page extends StatefulWidget {
  const P2Page({super.key});
  @override
  State<P2Page> createState() => _P2PageState();
}
class _P2PageState extends State<P2Page> {
  final ScrollController _scrollController = ScrollController();
  bool showScrollUp = false;
  bool showScrollDown = true;
  @override
  void initState() {
    super.initState();
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
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
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
          // ONLY THIS HEADER DESIGN IS CHANGED
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
          // ============================================================
          // KNOWLEDGE SLIDER
          // ============================================================
          Positioned(
            top: 330,
            left: 58,
            right: 58,
            child: KnowledgeSlider(
              height: 250,
              titleFontSize: 32,
              subtitleFontSize: 25,
              factFontSize: 25,
              counterFontSize: 25,
              slideDuration: Duration(seconds: 8),
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
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 500,
                            icon: Icons.account_balance_rounded,
                            label: '${loc.pbtText} ${Data.pbtArea}',
                            supportingText: loc.pbtSupportingText,
                            accentColor: const Color(0xFF1469E8),
                            accentLightColor:
                                const Color(0xFFE6F0FF),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PBT3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: _ModernServiceButton(
                            height: 500,
                            icon: Icons.receipt_long_rounded,
                            showUtilityIcons: true,
                            label: loc.bilText,
                            supportingText: loc.billSupportingText,
                            accentColor: const Color(0xFF008F72),
                            accentLightColor:
                                const Color(0xFFE0F8F1),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PBIL3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 45),
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 500,
                            icon: Icons.travel_explore_rounded,
                            label: loc.touristText,
                            supportingText:
                                loc.touristSupportingText,
                            accentColor: const Color(0xFFE56C16),
                            accentLightColor:
                                const Color(0xFFFFEBDC),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PTOURISTPAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: _ModernServiceButton(
                            height: 500,
                            icon: Icons.help_outline_rounded,
                            label: loc.faqButton,
                            supportingText:
                                loc.faqSupportingText,
                            accentColor: const Color(0xFF7A4DD8),
                            accentLightColor:
                                const Color(0xFFF0E9FF),
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
          // BACK BUTTON - UNCHANGED
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
// PAGE HEADER
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
    return Container(
      padding: const EdgeInsets.fromLTRB(
        30,
        25,
        30,
        25,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
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
          // LEFT GOVERNMENT BLUE ICON
          // ==========================================================
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF064AA3),
                  Color(0xFF1478D4),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF095AB8).withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
          const SizedBox(width: 28),
          // ==========================================================
          // TITLE AREA
          // ==========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small category label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F3FF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.apps_rounded,
                        size: 20,
                        color: Color(0xFF1265BC),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!
                            .serviceSelectionLabel
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF1265BC),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // MAIN TITLE
                Text(
                  title,
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
                // SUBTITLE
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
          // ==========================================================
          // RIGHT DECORATION
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
                  Color(0xFF0751A8),
                  Color(0xFF2196E8),
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
// ORIGINAL SERVICE BUTTON - UNCHANGED
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
  final bool showUtilityIcons;
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
    this.showUtilityIcons = false,
  });
  @override
  State<_ModernServiceButton> createState() =>
      _ModernServiceButtonState();
}
class _ModernServiceButtonState extends State<_ModernServiceButton> {
  bool _isPressed = false;
  bool _isFocused = false;


  void _setPressed(bool value) {
    if (!mounted || widget.comingSoon) return;
    setState(() => _isPressed = value);
  }

  Widget _buildServiceIcons() {
    if (widget.showUtilityIcons) {
      const icons = [
        Icons.water_drop_rounded,
        Icons.bolt_rounded,
        Icons.wifi_rounded,
        Icons.tv_rounded,
        Icons.phone_android_rounded,
        Icons.sports_esports_rounded,
      ];
      const colors = [
        Color(0xFF1689D8),
        Color(0xFFD58A00),
        Color(0xFF008F72),
        Color(0xFF7A4DD8),
        Color(0xFF1469E8),
        Color(0xFFE56C16),
      ];
      return Column(
        children: List.generate(2, (row) {
          return Expanded(
            child: Row(
              children: List.generate(3, (column) {
                final index = row * 3 + column;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(icons[index], size: 100, color: colors[index]),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      );
    }
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
    final emphasized = _isPressed || _isFocused;
    final borderColor = emphasized
        ? widget.accentColor
        : Color.lerp(const Color(0xFFB9C8DA), widget.accentColor, 0.28)!;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18324F).withOpacity(
                _isPressed ? 0.05 : 0.11,
              ),
              blurRadius: _isPressed ? 8 : 18,
              offset: Offset(0, _isPressed ? 2 : 7),
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
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: enabled ? widget.onPressed : null,
            onHighlightChanged: _setPressed,
            onFocusChange: (focused) {
              if (mounted) setState(() => _isFocused = focused);
            },
            splashColor: widget.accentColor.withOpacity(0.10),
            highlightColor: widget.accentColor.withOpacity(0.04),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: enabled ? 1 : 0.45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Raised icon panel overlaps the soft colour header.
                      SizedBox(
                        height: widget.height * 0.42,
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
                                          Color.lerp(Colors.white,
                                              widget.accentLightColor, 0.40)!,
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
                                        duration: const Duration(milliseconds: 160),
                                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                                        decoration: BoxDecoration(
                                          color: Color.lerp(Colors.white,
                                              widget.accentLightColor, 0.18),
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: widget.accentColor.withOpacity(0.22),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: widget.accentColor.withOpacity(
                                                _isPressed ? 0.08 : 0.15,
                                              ),
                                              blurRadius: _isPressed ? 10 : 18,
                                              offset: Offset(0, _isPressed ? 3 : 7),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: SizedBox(
                                                  width: widget.showUtilityIcons ? 240 : 126,
                                                  height: widget.showUtilityIcons ? 145 : 126,
                                                  child: _buildServiceIcons(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: widget.accentColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 25,
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.label.toUpperCase(),
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Color(0xFF142D4E),
                                            fontSize: 35,
                                            fontWeight: FontWeight.w800,
                                            height: 1.16,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          widget.supportingText,
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Color(0xFF526175),
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500,
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
                if (widget.comingSoon)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!
                            .comingsoonText.toUpperCase(),
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
    );
  }
}

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
