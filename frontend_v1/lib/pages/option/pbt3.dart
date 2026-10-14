import 'package:frontend_v1/widgets/knowledge_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/p2.dart';
import 'package:frontend_v1/pages/pbt/compound/p4optioncompound.dart';
import 'package:frontend_v1/pages/pbt/cukai/p4_option_cukai_bentong.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';

import 'package:frontend_v1/pages/pbt/newp4.dart';

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
  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }
  Widget _buildScrollAction(AppLocalizations loc) {
    // TOP: only more content below
    if (!showScrollUp && showScrollDown) {
      return _ScrollDiscoveryControl(
        key: const ValueKey('top-more'),
        mode: _ScrollControlMode.more,
        label: loc.scrollViewMore,
        onPressed: _scrollDown,
      );
    }
    // MIDDLE: both directions available
    if (showScrollUp && showScrollDown) {
      return Row(
        key: const ValueKey('middle-controls'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _ScrollDiscoveryControl(
            mode: _ScrollControlMode.up,
            label: loc.scrollUpShort,
            onPressed: _scrollUp,
          ),
          const SizedBox(width: 22),
          _ScrollDiscoveryControl(
            mode: _ScrollControlMode.more,
            label: loc.scrollViewMore,
            onPressed: _scrollDown,
          ),
        ],
      );
    }
    // BOTTOM: direct return to the top
    if (showScrollUp && !showScrollDown) {
      return _ScrollDiscoveryControl(
        key: const ValueKey('bottom-top'),
        mode: _ScrollControlMode.top,
        label: loc.scrollBackTop,
        onPressed: _scrollToTop,
      );
    }
    return const SizedBox.shrink();
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
          // BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),
          // SOFT BACKGROUND OVERLAY
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
          // MODERN HEADER
          Positioned(
            top: 45,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              badgeText: '${loc.pbtText} ${Data.pbtArea}',
              title: loc.p3Title,
              subtitle: loc.p3Subtitle,
            ),
          ),
          // DID YOU KNOW / TAHUKAH ANDA
          Positioned(
            top: 325,
            left: 58,
            right: 58,
            child: const KnowledgeSlider(
              height: 250,
              titleFontSize: 32,
              subtitleFontSize: 25,
              factFontSize: 25,
              counterFontSize: 25,
              slideDuration: Duration(seconds: 8),
            ),
          ),
          // SCROLLABLE SERVICE BUTTON AREA
          Positioned(
            top: 605,
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
                  bottom: 145,
                ),
                child: Column(
                  children: [
                    // FIRST ROW
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 300,
                            imagePath: 'lib/images/pbt_parking_icon.png',
                            icon: Icons.local_parking_rounded,
                            label: loc.parkirButton,
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
                        const SizedBox(width: 24),
                        Expanded(
                          child: _ModernServiceButton(
                            height: 300,
                            imagePath: 'lib/images/pbt_compound_icon.png',
                            icon: Icons.gavel_rounded,
                            label: loc.compoundButton,
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
                    const SizedBox(height: 22),
                    // SECOND ROW
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 300,
                            imagePath: 'lib/images/pbt_tax_icon.png',
                            icon: Icons.account_balance_rounded,
                            label: loc.taxButton,
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
                        const SizedBox(width: 24),
                        Expanded(
                          child: _ModernServiceButton(
                            height: 300,
                            imagePath: 'lib/images/pbt_license_icon.png',
                            icon: Icons.badge_rounded,
                            label: loc.licenseButton,
                            accentColor: const Color(0xFFE56C16),
                            accentLightColor:
                                const Color(0xFFFFEBDC),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NEWP4PAGE(
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
                    const SizedBox(height: 22),
                    // THIRD ROW
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 300,
                            imagePath: 'lib/images/pbt_rental_icon.png',
                            icon: Icons.home_work_rounded,
                            label: loc.rentPBTText,
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
                        const SizedBox(width: 24),
                        // Keeps the final card aligned to the left.
                        const Expanded(
                          child: SizedBox(
                            height: 300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // CONTENT FADE
          // Shows that more PBT services continue below.
          if (showScrollDown)
            Positioned(
              left: 45,
              right: 45,
              bottom: 300,
              height: 170,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [
                        0.0,
                        0.30,
                        0.68,
                        1.0,
                      ],
                      colors: [
                        Colors.white.withOpacity(0.00),
                        Colors.white.withOpacity(0.14),
                        Colors.white.withOpacity(0.62),
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // MODERN SCROLL CONTROLS
          //
          // TOP:
          // [ LIHAT LAGI  ↓ ]
          //
          // MIDDLE:
          // [ ↑  KE ATAS ]  [ LIHAT LAGI  ↓ ]
          //
          // BOTTOM:
          // [ ↑  KEMBALI KE ATAS ]
          Positioned(
            left: 0,
            right: 0,
            bottom: 300,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.94,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _buildScrollAction(loc),
              ),
            ),
          ),
          // BACK BUTTON
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
          // FOOTER
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
// KNOWLEDGE SLIDER
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
    return Container(
      padding: const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
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
          // LEFT ICON
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
                  color: const Color(0xFF095AB8).withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
          const SizedBox(width: 28),
          // TEXT AREA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small service badge.
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
                        Icons.apartment_rounded,
                        size: 20,
                        color: Color(0xFF1265BC),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        badgeText.toUpperCase(),
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
                // Main page title.
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
                // Subtitle.
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
          // RIGHT ACCENT BAR
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
// MODERN MAIN SERVICE BUTTON
class _ModernServiceButton extends StatefulWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
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
    required this.onPressed,
    required this.accentColor,
    required this.accentLightColor,
    this.height = 300,
    this.comingSoon = false,
  });
  @override
  State<_ModernServiceButton> createState() => _ModernServiceButtonState();
}
class _ModernServiceButtonState extends State<_ModernServiceButton> {
  bool _pressed = false;
  bool _focused = false;
  void _setPressed(bool value) {
    if (!mounted || widget.comingSoon) return;
    setState(() => _pressed = value);
  }
  double _bestLabelFontSize({
    required BuildContext context,
    required String text,
    required double maxWidth,
    required double maxHeight,
  }) {
    final direction = Directionality.of(context);
    for (double size = 38; size >= 24; size -= 1) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: const Color(0xFF102C50),
            fontSize: size,
            fontWeight: FontWeight.w900,
            height: 1.04,
            letterSpacing: -0.30,
          ),
        ),
        maxLines: 2,
        textDirection: direction,
      )..layout(maxWidth: maxWidth);
      if (!painter.didExceedMaxLines && painter.height <= maxHeight) return size;
    }
    return 24;
  }
  @override
  Widget build(BuildContext context) {
    final enabled = !widget.comingSoon;
    final active = _pressed || _focused;
    final radius = BorderRadius.circular(28);
    final borderColor = active
        ? widget.accentColor
        : Color.lerp(widget.accentColor, Colors.white, 0.36)!;
    final softTint = Color.lerp(Colors.white, widget.accentColor, 0.05)!;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: RepaintBoundary(
        child: AnimatedScale(
          scale: _pressed ? 0.970 : 1.0,
          duration: const Duration(milliseconds: 105),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withOpacity(_pressed ? 0.09 : 0.20),
                  blurRadius: _pressed ? 7 : 18,
                  spreadRadius: _pressed ? 0 : 0.5,
                  offset: Offset(0, _pressed ? 2 : 7),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(_pressed ? 0.02 : 0.045),
                  blurRadius: _pressed ? 4 : 9,
                  offset: Offset(0, _pressed ? 1 : 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: borderColor, width: active ? 3 : 2),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withOpacity(0.995), softTint],
                  ),
                ),
                child: InkWell(
                  onTap: enabled ? widget.onPressed : null,
                  onHighlightChanged: _setPressed,
                  onFocusChange: (focused) {
                    if (mounted) setState(() => _focused = focused);
                  },
                  splashColor: widget.accentColor.withOpacity(0.13),
                  highlightColor: widget.accentColor.withOpacity(0.045),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 7,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 164,
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 130),
                                  width: 156,
                                  height: 156,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: widget.accentColor.withOpacity(active ? 0.34 : 0.17),
                                      width: active ? 2.2 : 1.4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.accentColor.withOpacity(_pressed ? 0.06 : 0.13),
                                        blurRadius: _pressed ? 5 : 13,
                                        offset: Offset(0, _pressed ? 2 : 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    clipBehavior: Clip.hardEdge,
                                    child: widget.imagePath != null
                                        ? _SharpAssetImage(path: widget.imagePath!)
                                        : Icon(
                                            widget.icon ?? Icons.apps_rounded,
                                            color: widget.accentColor,
                                            size: 92,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Container(height: 2, color: const Color(0xFFE7EDF5)),
                            const SizedBox(height: 7),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final text = widget.label.toUpperCase();
                                        final fontSize = _bestLabelFontSize(
                                          context: context,
                                          text: text,
                                          maxWidth: constraints.maxWidth,
                                          maxHeight: constraints.maxHeight,
                                        );
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            text,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: const Color(0xFF102C50),
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.w900,
                                              height: 1.04,
                                              letterSpacing: -0.30,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    width: _pressed ? 48 : 52,
                                    height: _pressed ? 48 : 52,
                                    decoration: BoxDecoration(
                                      color: widget.accentColor,
                                      borderRadius: BorderRadius.circular(17),
                                      border: Border.all(color: Colors.white, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.accentColor.withOpacity(_pressed ? 0.13 : 0.25),
                                          blurRadius: _pressed ? 4 : 9,
                                          offset: Offset(0, _pressed ? 2 : 4),
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
                            ),
                          ],
                        ),
                      ),
                      if (widget.comingSoon)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.68),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.comingsoonText.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
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
          ),
        ),
      ),
    );
  }
}
class _SharpAssetImage extends StatelessWidget {
  final String path;
  const _SharpAssetImage({required this.path});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = (constraints.maxWidth * dpr * 3.0).round();
        final cacheHeight = (constraints.maxHeight * dpr * 3.0).round();
        return RepaintBoundary(
          child: Image.asset(
            path,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            filterQuality: FilterQuality.medium,
            isAntiAlias: false,
            gaplessPlayback: true,
            cacheWidth: cacheWidth > 0 ? cacheWidth : null,
            cacheHeight: cacheHeight > 0 ? cacheHeight : null,
          ),
        );
      },
    );
  }
}
enum _ScrollControlMode {
  up,
  more,
  top,
}
class _ScrollDiscoveryControl extends StatefulWidget {
  final _ScrollControlMode mode;
  final String label;
  final VoidCallback onPressed;
  const _ScrollDiscoveryControl({
    super.key,
    required this.mode,
    required this.label,
    required this.onPressed,
  });
  @override
  State<_ScrollDiscoveryControl> createState() =>
      _ScrollDiscoveryControlState();
}
class _ScrollDiscoveryControlState
    extends State<_ScrollDiscoveryControl> {
  bool _pressed = false;
  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() {
      _pressed = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    final bool isUp =
        widget.mode == _ScrollControlMode.up ||
        widget.mode == _ScrollControlMode.top;
    final IconData arrow = isUp
        ? Icons.keyboard_arrow_up_rounded
        : Icons.keyboard_arrow_down_rounded;
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: _setPressed,
          borderRadius: BorderRadius.circular(100),
          splashColor: const Color(0xFF1469E8).withOpacity(0.10),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            constraints: const BoxConstraints(
              minHeight: 88,
            ),
            padding: const EdgeInsets.fromLTRB(
              30,
              13,
              22,
              13,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: _pressed
                    ? const Color(0xFF1469E8)
                    : const Color(0xFFC4D8EE),
                width: _pressed ? 2.5 : 1.7,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF173B66).withOpacity(
                    _pressed ? 0.09 : 0.17,
                  ),
                  blurRadius: _pressed ? 8 : 20,
                  offset: Offset(
                    0,
                    _pressed ? 2 : 7,
                  ),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUp) ...[
                  _ScrollArrowCircle(
                    icon: arrow,
                    pressed: _pressed,
                  ),
                  const SizedBox(width: 14),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 88,
                    maxWidth: 190,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.label.toUpperCase(),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF163B67),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                if (!isUp) ...[
                  const SizedBox(width: 14),
                  _ScrollArrowCircle(
                    icon: arrow,
                    pressed: _pressed,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _ScrollArrowCircle extends StatelessWidget {
  final IconData icon;
  final bool pressed;
  const _ScrollArrowCircle({
    required this.icon,
    required this.pressed,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pressed
              ? const [
                  Color(0xFF0B4FAE),
                  Color(0xFF0A73E8),
                ]
              : const [
                  Color(0xFF1469E8),
                  Color(0xFF0A82F5),
                ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1469E8).withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 48,
      ),
    );
  }
}
