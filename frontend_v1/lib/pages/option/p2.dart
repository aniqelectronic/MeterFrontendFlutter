import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/language/pbahasa.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/pages/faq/faq_page.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'pbt3.dart';
import 'pbil3.dart';
import 'package:frontend_v1/pages/pbt/cukai/p4_option_cukai_bentong.dart';
import 'package:frontend_v1/pages/pbt/sewaan/p4_option_sewaan_bentong.dart';
import 'package:frontend_v1/pages/bil/water/pwaterbill3.dart';
import 'package:frontend_v1/pages/bil/electric/pelectricbill3.dart';
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
    if (!_scrollController.hasClients || !mounted) {
      return;
    }
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
  @override
  void dispose() {
    _scrollController.removeListener(
      _handleScroll,
    );
    _scrollController.dispose();
    super.dispose();
  }
  // SCROLL UP ONE SECTION
  void _scrollUp() {
    if (!_scrollController.hasClients) {
      return;
    }
    final destination =
        (_scrollController.offset - 600).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      destination,
      duration: const Duration(
        milliseconds: 450,
      ),
      curve: Curves.easeOutCubic,
    );
  }
  // SCROLL DOWN ONE SECTION
  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }
    final destination =
        (_scrollController.offset + 600).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      destination,
      duration: const Duration(
        milliseconds: 450,
      ),
      curve: Curves.easeOutCubic,
    );
  }
  // DIRECTLY BACK TO TOP
  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(
        milliseconds: 550,
      ),
      curve: Curves.easeOutCubic,
    );
  }
  // BUILD THE CORRECT SCROLL CONTROL
  Widget _buildScrollAction(
    AppLocalizations loc,
  ) {
    /// ============================================================
    /// TOP
    /// only more content below
    /// ============================================================
    if (!showScrollUp && showScrollDown) {
      return _ScrollDiscoveryControl(
        key: const ValueKey(
          'top-more',
        ),
        mode: _ScrollControlMode.more,
        label: loc.scrollViewMore,
        onPressed: _scrollDown,
      );
    }
    /// ============================================================
    /// MIDDLE
    /// can go up AND down
    /// ============================================================
    if (showScrollUp && showScrollDown) {
      return Row(
        key: const ValueKey(
          'middle-controls',
        ),
        mainAxisSize: MainAxisSize.min,
        children: [
          _ScrollDiscoveryControl(
            mode: _ScrollControlMode.up,
            label: loc.scrollUpShort,
            onPressed: _scrollUp,
          ),
          const SizedBox(
            width: 22,
          ),
          _ScrollDiscoveryControl(
            mode: _ScrollControlMode.more,
            label: loc.scrollViewMore,
            onPressed: _scrollDown,
          ),
        ],
      );
    }
    /// ============================================================
    /// BOTTOM
    /// only back to top
    /// ============================================================
    if (showScrollUp && !showScrollDown) {
      return _ScrollDiscoveryControl(
        key: const ValueKey(
          'bottom-top',
        ),
        mode: _ScrollControlMode.top,
        label: loc.scrollBackTop,
        onPressed: _scrollToTop,
      );
    }
    return const SizedBox.shrink();
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
                    Colors.white.withOpacity(
                      0.05,
                    ),
                    Colors.white.withOpacity(
                      0.16,
                    ),
                    Colors.white.withOpacity(
                      0.08,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // HEADER
          Positioned(
            top: 58,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              title: loc.p2Title,
              subtitle: loc.p3Subtitle,
            ),
          ),
          // SCROLLABLE SERVICE AREA
          Positioned(
            top: 330,
            left: 60,
            right: 60,
            bottom: 315,
            child:
                Scrollbar(
              controller:
                  _scrollController,
              thumbVisibility: true,
              trackVisibility: false,
              thickness: 8,
              radius:
                  const Radius.circular(
                20,
              ),
              child:
                  SingleChildScrollView(
                controller:
                    _scrollController,
                physics:
                    const BouncingScrollPhysics(
                  parent:
                      AlwaysScrollableScrollPhysics(),
                ),
                padding:
                    const EdgeInsets.only(
                  top: 18,
                  right: 24,
                  bottom: 145,
                ),
                child:
                    Column(
                  children: [
                    // MAIN SERVICES HEADING (cards below remain unchanged)
                    _P2SectionHeading(
                      title: loc.p2MainServicesTitle,
                      icon: Icons.dashboard_rounded,
                      accentColor: const Color(0xFF1469E8),
                    ),
                    const SizedBox(height: 24),
                    // FIRST ROW
                    Row(
                      children: [
                        // PBT
                        Expanded(
                          child:
                              _ModernServiceButton(
                            height: 320,
                            backgroundImage: 'lib/images/majlis_bg.png',
                            imagePath: 'lib/images/municipal_service_icon.png',
                            icon: Icons.account_balance_rounded,
                            label: '${loc.pbtText} ${Config.pbtArea}',
                            supportingText: loc.pbtSupportingText,
                            accentColor:
                                const Color(
                              0xFF1469E8,
                            ),
                            accentLightColor:
                                const Color(
                              0xFFE6F0FF,
                            ),
                            onPressed:
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const PBT3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 28,
                        ),
                        // BILL / UTILITY
                        Expanded(
                          child:
                              _ModernServiceButton(
                            height: 320,
                            backgroundImage: 'lib/images/utility_bg.png',
                            imagePath: 'lib/images/utility_service_icon.png',
                            icon: Icons.receipt_long_rounded,
                            showUtilityIcons: false,
                            label: loc.bilText,
                            supportingText: loc.billSupportingText,
                            accentColor:
                                const Color(
                              0xFF008F72,
                            ),
                            accentLightColor:
                                const Color(
                              0xFFE0F8F1,
                            ),
                            onPressed:
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const PBIL3PAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 26,
                    ),
                    // SECOND ROW
                    Row(
                      children: [
                        // TOURIST
                        Expanded(
                          child:
                              _ModernServiceButton(
                            height: 320,
                            backgroundImage: 'lib/images/tourist_bg.png',
                            imagePath: 'lib/images/tourist_service_icon.png',
                            icon: Icons.travel_explore_rounded,
                            label: loc.touristText,
                            supportingText: loc.touristSupportingText,
                            accentColor:
                                const Color(
                              0xFFE56C16,
                            ),
                            accentLightColor:
                                const Color(
                              0xFFFFEBDC,
                            ),
                            onPressed:
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const PTOURISTPAGE(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 28),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                    const SizedBox(height: 34),
                    // FREQUENTLY USED SERVICES - direct shortcuts
                    _P2SectionHeading(
                      title: loc.p2FrequentlyUsedTitle,
                      icon: Icons.star_outline_rounded,
                      accentColor: const Color(0xFF6D4AD8),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickServiceButton(
                            icon: Icons.account_balance_rounded,
                            label: loc.taxButton,
                            color: const Color(0xFF7B4DE3),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const P4OPTIONCUKAIBENTONG(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: _QuickServiceButton(
                            icon: Icons.home_work_rounded,
                            label: loc.rentPBTText,
                            color: const Color(0xFF008F72),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const P4OPTIONSEWAANBENTONG(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickServiceButton(
                            icon: Icons.water_drop_rounded,
                            label: loc.waterButton,
                            color: const Color(0xFF1687D9),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PWATERBILL3PAGE(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: _QuickServiceButton(
                            icon: Icons.electric_bolt_rounded,
                            label: loc.electricitybutton,
                            color: const Color(0xFFE0A100),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PELECTRICBILL3PAGE(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 52),
                    // HELP & INFORMATION — FAQ is a support feature, not a payment service.
                    _P2SectionHeading(
                      title: loc.p2HelpInformationTitle,
                      icon: Icons.help_outline_rounded,
                      accentColor: const Color(0xFF7A4DD8),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 320,
                            backgroundImage: 'lib/images/faq_bg.png',
                            imagePath: 'lib/images/faq_service_icon.png',
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
                                    councilHotlineNumber: Data.aduanMajlisBentong,
                                    operationsHotlineNumber: Data.telefonNo,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 28),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // CONTENT FADE
          //
          // only visible while content still exists below
          if (showScrollDown)
            Positioned(
              left: 45,
              right: 45,
              bottom: 270,
              height: 165,
              child:
                  IgnorePointer(
                child:
                    Container(
                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops:
                          const [
                        0.0,
                        0.30,
                        0.65,
                        1.0,
                      ],
                      colors:
                          [
                        Colors.white.withOpacity(
                          0.00,
                        ),
                        Colors.white.withOpacity(
                          0.16,
                        ),
                        Colors.white.withOpacity(
                          0.62,
                        ),
                        Colors.white.withOpacity(
                          0.94,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // MODERN SCROLL CONTROLS
          Positioned(
            left: 0,
            right: 0,
            bottom: 270,
            child:
                Center(
              child:
                  AnimatedSwitcher(
                duration:
                    const Duration(
                  milliseconds: 250,
                ),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder:
                    (
                  child,
                  animation,
                ) {
                  return FadeTransition(
                    opacity:
                        animation,
                    child:
                        ScaleTransition(
                      scale:
                          Tween<double>(
                        begin: 0.94,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent:
                              animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child:
                          child,
                    ),
                  );
                },
                child:
                    _buildScrollAction(
                  loc,
                ),
              ),
            ),
          ),
          // BACK BUTTON
          Positioned(
            bottom: 100,
            left: 220,
            right: 220,
            child:
                KioskBackButton(
              onPressed:
                  () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            const PBAHASAPAGE(),
                  ),
                );
              },
            ),
          ),
          // FOOTER
          Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child:
                Center(
              child:
                  Text(
                Data.copyrightText,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF26364A,
                  ),
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
// PAGE HEADER
class _ModernPageHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ModernPageHeader({
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        30,
        25,
        30,
        25,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.94,
        ),
        borderRadius:
            BorderRadius.circular(
          32,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD5E4F7,
          ),
          width: 2,
        ),
        boxShadow:
            [
          BoxShadow(
            color:
                const Color(
              0xFF173A66,
            ).withOpacity(
              0.14,
            ),
            blurRadius: 30,
            offset:
                const Offset(
              0,
              12,
            ),
          ),
        ],
      ),
      child:
          Row(
        children: [
          Container(
            width: 105,
            height: 105,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    [
                  Color(
                    0xFF064AA3,
                  ),
                  Color(
                    0xFF1478D4,
                  ),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                30,
              ),
              boxShadow:
                  [
                BoxShadow(
                  color:
                      const Color(
                    0xFF095AB8,
                  ).withOpacity(
                    0.28,
                  ),
                  blurRadius: 20,
                  offset:
                      const Offset(
                    0,
                    8,
                  ),
                ),
              ],
            ),
            child:
                const Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
          const SizedBox(
            width: 28,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFE9F3FF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                  ),
                  child:
                      Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        [
                      const Icon(
                        Icons.apps_rounded,
                        size: 20,
                        color:
                            Color(
                          0xFF1265BC,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Flexible(
                        child:
                            Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .serviceSelectionLabel
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF1265BC,
                            ),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF122C4C,
                    ),
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1.02,
                    letterSpacing:
                        -0.8,
                  ),
                ),
                const SizedBox(
                  height: 9,
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF607188,
                    ),
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 24,
          ),
          Container(
            width: 8,
            height: 105,
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              gradient:
                  const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    [
                  Color(
                    0xFF0751A8,
                  ),
                  Color(
                    0xFF2196E8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// SERVICE BUTTON - illustrated backgrounds, original navigation callbacks
// Design B: raised PBT3-style icon panel over original illustrated backgrounds.
class _ModernServiceButton extends StatefulWidget {
  final IconData? icon;
  final String? imagePath;
  final String backgroundImage;
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
    required this.backgroundImage,
    required this.label,
    required this.supportingText,
    required this.onPressed,
    required this.accentColor,
    required this.accentLightColor,
    this.height = 320,
    this.comingSoon = false,
    this.showUtilityIcons = false,
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
      if (!painter.didExceedMaxLines && painter.height <= maxHeight) {
        return size;
      }
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
                side: BorderSide(
                  color: borderColor,
                  width: active ? 3 : 2,
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.995),
                      softTint,
                    ],
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 130),
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
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
                                            size: 100,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 2,
                              color: const Color(0xFFE7EDF5),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                    width: _pressed ? 50 : 54,
                                    height: _pressed ? 50 : 54,
                                    decoration: BoxDecoration(
                                      color: widget.accentColor,
                                      borderRadius: BorderRadius.circular(17),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.accentColor.withOpacity(
                                            _pressed ? 0.13 : 0.25,
                                          ),
                                          blurRadius: _pressed ? 4 : 9,
                                          offset: Offset(0, _pressed ? 2 : 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 33,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .comingsoonText
                                    .toUpperCase(),
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
// SCROLL CONTROL (unchanged)
class _PressArrowBadge extends StatelessWidget {
  final Color color;
  final bool pressed;
  final double size;
  const _PressArrowBadge({
    required this.color,
    required this.pressed,
    required this.size,
  });
  @override
  Widget build(BuildContext context) {
    final fill = pressed ? Color.lerp(color, Colors.black, 0.10)! : color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 110),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(pressed ? 0.18 : 0.32),
            blurRadius: pressed ? 6 : 12,
            offset: Offset(0, pressed ? 2 : 5),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: size * 0.58,
      ),
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
class _P2SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  const _P2SectionHeading({
    required this.title,
    required this.icon,
    required this.accentColor,
  });
  @override
  Widget build(BuildContext context) {
    final iconBackground = Color.lerp(Colors.white, accentColor, 0.10)!;
    final iconBorder = Color.lerp(Colors.white, accentColor, 0.30)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 15, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDCE6F1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A66).withOpacity(0.09),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: iconBorder,
                width: 1.4,
              ),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 31,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title.toUpperCase(),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF102C50),
                fontSize: 36,
                fontWeight: FontWeight.w900,
                height: 1.10,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Frequently used service cards: same raised icon-panel / accent-line
// visual language as the existing P2 cards, without descriptions.
class _QuickServiceButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _QuickServiceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });
  @override
  State<_QuickServiceButton> createState() => _QuickServiceButtonState();
}
class _QuickServiceButtonState extends State<_QuickServiceButton> {
  bool _pressed = false;
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final active = _pressed || _focused;
    final radius = BorderRadius.circular(26);
    final softTint = Color.lerp(Colors.white, widget.color, 0.075)!;
    final iconTint = Color.lerp(Colors.white, widget.color, 0.11)!;
    final borderColor = active
        ? widget.color
        : Color.lerp(widget.color, Colors.white, 0.28)!;
    return Semantics(
      button: true,
      label: widget.label,
      child: RepaintBoundary(
        child: AnimatedScale(
          scale: _pressed ? 0.972 : 1.0,
          duration: const Duration(milliseconds: 105),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            height: 210,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_pressed ? 0.10 : 0.20),
                  blurRadius: _pressed ? 7 : 18,
                  spreadRadius: _pressed ? 0 : 0.5,
                  offset: Offset(0, _pressed ? 2 : 7),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(_pressed ? 0.02 : 0.045),
                  blurRadius: _pressed ? 4 : 8,
                  offset: Offset(0, _pressed ? 1 : 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(
                  color: borderColor,
                  width: active ? 3 : 2.1,
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      softTint,
                      Colors.white.withOpacity(0.98),
                    ],
                  ),
                ),
                child: InkWell(
                  onTap: widget.onPressed,
                  onHighlightChanged: (value) {
                    if (mounted) setState(() => _pressed = value);
                  },
                  onFocusChange: (value) {
                    if (mounted) setState(() => _focused = value);
                  },
                  splashColor: widget.color.withOpacity(0.17),
                  highlightColor: widget.color.withOpacity(0.055),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 15, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 130),
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                color: iconTint,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: widget.color.withOpacity(active ? 0.48 : 0.26),
                                  width: active ? 2.2 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.color.withOpacity(_pressed ? 0.07 : 0.13),
                                    blurRadius: _pressed ? 5 : 10,
                                    offset: Offset(0, _pressed ? 2 : 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.color,
                                size: 56,
                              ),
                            ),
                            const Spacer(),
                            _PressArrowBadge(
                              color: widget.color,
                              pressed: _pressed,
                              size: 50,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            width: _pressed ? 68 : 54,
                            height: 5,
                            decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, bounds) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: bounds.maxWidth,
                                  height: bounds.maxHeight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width: bounds.maxWidth,
                                      child: Text(
                                        widget.label.toUpperCase(),
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF102C50),
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          height: 1.08,
                                          letterSpacing: -0.25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
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
      ),
    );
  }
}
