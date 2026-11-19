import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/language/pbahasa.dart';
import 'package:frontend_v1/pages/faq/faq_page.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/pages/pbt/cukai/p4_option_cukai_bentong.dart';
import 'package:frontend_v1/pages/pbt/sewaan/p4_option_sewaan_bentong.dart';
import 'package:frontend_v1/pages/bil/water/pwaterbill3.dart';
import 'package:frontend_v1/pages/bil/electric/pelectricbill3.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'pbt3.dart';
import 'pbil3.dart';

// P2 SERVICE SELECTION
// Layout and navigation match the supplied P2Page. Only service-card styling
// and section-heading styling are redesigned. This page shows titles only.
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
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final canScrollUp = offset > 10;
    final canScrollDown = offset < maxScroll - 10;

    if (canScrollUp != showScrollUp || canScrollDown != showScrollDown) {
      setState(() {
        showScrollUp = canScrollUp;
        showScrollDown = canScrollDown;
      });
    }
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

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildScrollAction(AppLocalizations loc) {
    if (!showScrollUp && showScrollDown) {
      return _ScrollDiscoveryControl(
        key: const ValueKey('top-more'),
        mode: _ScrollControlMode.more,
        label: loc.scrollViewMore,
        onPressed: _scrollDown,
      );
    }

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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Original background and overlay: unchanged.
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),
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

          // Original page-header component and location: unchanged.
          Positioned(
            top: 58,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              title: loc.p2Title,
              subtitle: loc.p3Subtitle,
            ),
          ),

          // Same scrollable service area and section order as the source.
          Positioned(
            top: 330,
            left: 48,
            right: 48,
            bottom: 315,
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
                  right: 18,
                  bottom: 145,
                ),
                child: Column(
                  children: [
                    _P2SectionHeading(
                      title: loc.p2MainServicesTitle,
                      icon: Icons.dashboard_rounded,
                      accentColor: const Color(0xFF1469E8),
                    ),
                    const SizedBox(height: 24),

                    // FIRST ROW: council + utility. Navigation unchanged.
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 395,
                            imagePath: 'lib/images/municipal_service_icon.png',
                            icon: Icons.account_balance_rounded,
                            label: '${loc.pbtText}\n${Config.pbtArea}',
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
                            height: 395,
                            imagePath: 'lib/images/utility_service_icon.png',
                            icon: Icons.receipt_long_rounded,
                            label: loc.bilText,
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
                    const SizedBox(height: 26),

                    // SECOND ROW: Info Setempat on the left, as originally.
                    Row(
                      children: [
                        Expanded(
                          child: _ModernServiceButton(
                            height: 395,
                            imagePath: 'lib/images/tourist_service_icon.png',
                            icon: Icons.travel_explore_rounded,
                            label: loc.touristText,
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
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                    const SizedBox(height: 34),

                    // FREQUENTLY USED: same two-by-two arrangement.
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

                    // HELP: FAQ stays half-width on the left.
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
                            height: 350,
                            imagePath: 'lib/images/faq_service_icon.png',
                            icon: Icons.help_outline_rounded,
                            label: loc.faqButton,
                            accentColor: const Color(0xFF7A4DD8),
                            accentLightColor: const Color(0xFFF0E9FF),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FaqPage(
                                    councilHotlineNumber:
                                        Data.aduanMajlisBentong,
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

          // Subtle bottom fade: same behavior, less visual obstruction.
          if (showScrollDown)
            Positioned(
              left: 45,
              right: 45,
              bottom: 270,
              height: 114,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.36, 0.72, 1.0],
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.34),
                        Colors.white.withOpacity(0.78),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Original scroll controls: same position and actions.
          Positioned(
            left: 0,
            right: 0,
            bottom: 270,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.94, end: 1.0).animate(
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

          // Original Back button, route, and positioning: unchanged.
          Positioned(
            bottom: 100,
            left: 300,
            right: 300,
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

          // Original copyright styling and positioning: unchanged.
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

// PAGE HEADER: kept visually identical to the supplied file.
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
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 25),
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
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF064AA3), Color(0xFF1478D4)],
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
              Icons.touch_app_rounded,
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
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!
                              .serviceSelectionLabel
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1265BC),
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
                colors: [Color(0xFF0751A8), Color(0xFF2196E8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MAIN SERVICE: large icon, full-width title zone, clear call-to-action.
// Entire card is tappable, not only the decorative arrow.
class _ModernServiceButton extends StatefulWidget {
  final IconData icon;
  final String? imagePath;
  final String label;
  final VoidCallback onPressed;
  final Color accentColor;
  final Color accentLightColor;
  final double height;
  final bool comingSoon;

  const _ModernServiceButton({
    super.key,
    required this.icon,
    this.imagePath,
    required this.label,
    required this.onPressed,
    required this.accentColor,
    required this.accentLightColor,
    this.height = 395,
    this.comingSoon = false,
  });

  @override
  State<_ModernServiceButton> createState() => _ModernServiceButtonState();
}

class _ModernServiceButtonState extends State<_ModernServiceButton> {
  bool _pressed = false;
  bool _focused = false;
  bool _hovered = false;
  bool _activating = false;

  void _setPressed(bool pressed) {
    if (!mounted || widget.comingSoon) return;
    setState(() => _pressed = pressed);
  }

  // Let the touch feedback remain visible briefly before opening the page.
  // Prevent a second tap from opening the same destination twice.
  Future<void> _handleTap() async {
    if (_activating || widget.comingSoon) return;

    setState(() => _activating = true);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() {
      _activating = false;
      _pressed = false;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.comingSoon;
    final depressed = _pressed || _activating;
    final active = depressed || _focused || _hovered;
    final borderRadius = BorderRadius.circular(30);
    final borderColor = active
        ? widget.accentColor
        : Color.lerp(widget.accentColor, Colors.white, 0.53)!;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: RepaintBoundary(
        child: AnimatedScale(
          scale: depressed ? 0.952 : (_hovered ? 0.994 : 1.0),
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            height: widget.height,
            duration: const Duration(milliseconds: 130),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withOpacity(
                    depressed ? 0.07 : (_hovered ? 0.22 : 0.17),
                  ),
                  blurRadius: depressed ? 6 : (_hovered ? 21 : 17),
                  offset: Offset(0, depressed ? 2 : 7),
                ),
                BoxShadow(
                  color: const Color(0xFF142D4E).withOpacity(0.045),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
                side: BorderSide(
                  color: borderColor,
                  width: depressed ? 3.5 : (active ? 2.8 : 1.7),
                ),
              ),
              child: InkWell(
                onTap: enabled ? _handleTap : null,
                onHighlightChanged: _setPressed,
                onHover: (hovered) {
                  if (mounted && !widget.comingSoon) {
                    setState(() => _hovered = hovered);
                  }
                },
                onFocusChange: (focused) {
                  if (mounted) setState(() => _focused = focused);
                },
                splashColor: widget.accentColor.withOpacity(0.20),
                highlightColor: widget.accentColor.withOpacity(0.10),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: widget.height * 0.45,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        widget.accentLightColor,
                                        Color.lerp(
                                          widget.accentLightColor,
                                          Colors.white,
                                          0.64,
                                        )!,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -70,
                                left: -65,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.accentColor.withOpacity(0.035),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  width: widget.height < 370 ? 112 : 132,
                                  height: widget.height < 370 ? 112 : 132,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(29),
                                    border: Border.all(
                                      color: widget.accentColor.withOpacity(
                                        active ? 0.36 : 0.19,
                                      ),
                                      width: active ? 2.1 : 1.4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.accentColor.withOpacity(
                                          _pressed ? 0.06 : 0.14,
                                        ),
                                        blurRadius: _pressed ? 7 : 15,
                                        offset: Offset(0, _pressed ? 2 : 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: widget.imagePath != null
                                        ? _SharpAssetImage(
                                            path: widget.imagePath!,
                                          )
                                        : Icon(
                                            widget.icon,
                                            color: widget.accentColor,
                                            size: 86,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 18,
                                top: 19,
                                child: _CardArrow(
                                  accentColor: widget.accentColor,
                                  pressed: depressed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2,
                          color: widget.accentColor.withOpacity(0.42),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(22, 17, 22, 19),
                            child: LayoutBuilder(
                              builder: (context, bounds) {
                                return _AutoFitKioskTitle(
                                  title: widget.label,
                                  maxWidth: bounds.maxWidth,
                                  maxHeight: bounds.maxHeight,
                                  preferredSize: 38,
                                  minimumSize: 18,
                                  maxLines: 5,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // A short tint makes the selected card unmistakable.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: depressed ? 1.0 : (_hovered ? 0.30 : 0.0),
                          duration: const Duration(milliseconds: 110),
                          child: ColoredBox(
                            color: widget.accentColor.withOpacity(0.11),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                    if (widget.comingSoon)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.70),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .comingsoonText
                                  .toUpperCase(),
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
    );
  }
}

// Icon arrow is visual guidance; the surrounding card receives the tap.
class _CardArrow extends StatelessWidget {
  final Color accentColor;
  final bool pressed;

  const _CardArrow({
    required this.accentColor,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: pressed ? 48 : 52,
      height: pressed ? 48 : 52,
      decoration: BoxDecoration(
        color: Color.lerp(
          accentColor,
          Colors.black,
          pressed ? 0.13 : 0.0,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2.4),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(pressed ? 0.13 : 0.24),
            blurRadius: pressed ? 5 : 10,
            offset: Offset(0, pressed ? 2 : 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 31,
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
        final cacheWidth = (constraints.maxWidth * dpr * 2).round();
        final cacheHeight = (constraints.maxHeight * dpr * 2).round();

        return RepaintBoundary(
          child: Image.asset(
            path,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            fit: BoxFit.contain,
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

// Measures actual string layout, so Malay/English/Chinese/Tamil labels
// have the maximum possible font size without depending on FittedBox scaling.
class _AutoFitKioskTitle extends StatelessWidget {
  final String title;
  final double maxWidth;
  final double maxHeight;
  final double preferredSize;
  final double minimumSize;
  final int maxLines;

  const _AutoFitKioskTitle({
    required this.title,
    required this.maxWidth,
    required this.maxHeight,
    this.preferredSize = 38,
    this.minimumSize = 18,
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    final text = title.toUpperCase();
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    double selectedSize = minimumSize;

    for (double size = preferredSize; size >= minimumSize; size -= 1) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            height: 1.06,
            letterSpacing: -0.3,
          ),
        ),
        maxLines: maxLines,
        textDirection: direction,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth);

      final fits = !painter.didExceedMaxLines &&
          painter.height <= maxHeight;
      painter.dispose();

      if (fits) {
        selectedSize = size;
        break;
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: maxLines,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF102C50),
          fontSize: selectedSize,
          fontWeight: FontWeight.w900,
          height: 1.06,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// SECTION HEADING: understated surface, clear grouping, retained labels.
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 13, 19, 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDCE6F1),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A66).withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 49,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: Color.lerp(Colors.white, accentColor, 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 30, color: accentColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title.toUpperCase(),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF102C50),
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1.10,
                letterSpacing: -0.20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PILIHAN PANTAS: precision two-tone cards with full-width titles.
// The entire tile is tappable; the original 2 x 2 layout and routes are kept.
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
  bool _hovered = false;
  bool _activating = false;

  Future<void> _handleTap() async {
    if (_activating) return;

    setState(() => _activating = true);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() {
      _activating = false;
      _pressed = false;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final depressed = _pressed || _activating;
    final active = depressed || _focused || _hovered;
    final radius = BorderRadius.circular(24);
    final topTint = Color.lerp(Colors.white, widget.color, 0.075)!;

    return Semantics(
      button: true,
      label: widget.label,
      child: RepaintBoundary(
        child: AnimatedScale(
          scale: depressed ? 0.952 : (_hovered ? 0.994 : 1.0),
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            height: 210,
            duration: const Duration(milliseconds: 145),
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(
                    depressed ? 0.07 : (_hovered ? 0.17 : 0.10),
                  ),
                  blurRadius: depressed ? 6 : (_hovered ? 17 : 13),
                  offset: Offset(0, depressed ? 2 : 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(
                  color: active
                      ? widget.color
                      : const Color(0xFFD6E1EC),
                  width: depressed ? 3.2 : (active ? 2.4 : 1.5),
                ),
              ),
              child: InkWell(
                onTap: _handleTap,
                onHover: (hovered) {
                  if (mounted) setState(() => _hovered = hovered);
                },
                onHighlightChanged: (value) {
                  if (mounted) setState(() => _pressed = value);
                },
                onFocusChange: (value) {
                  if (mounted) setState(() => _focused = value);
                },
                splashColor: widget.color.withOpacity(0.20),
                highlightColor: widget.color.withOpacity(0.10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  color: Color.lerp(
                    Colors.white,
                    widget.color,
                    depressed ? 0.12 : (_hovered ? 0.03 : 0.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 99,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          color: Color.lerp(
                            topTint,
                            widget.color,
                            depressed ? 0.17 : 0.0,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 13, 18, 13),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 145),
                                  width: 73,
                                  height: 73,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(19),
                                    border: Border.all(
                                      color: widget.color.withOpacity(
                                        active ? 0.32 : 0.16,
                                      ),
                                      width: 1.3,
                                    ),
                                  ),
                                  child: Icon(
                                    widget.icon,
                                    size: 47,
                                    color: widget.color,
                                  ),
                                ),
                                const Spacer(),
                                _QuickArrowBadge(
                                  color: widget.color,
                                  pressed: depressed,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 1.5,
                        color: widget.color.withOpacity(0.13),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(19, 12, 17, 14),
                          child: LayoutBuilder(
                            builder: (context, bounds) {
                              return _AutoFitKioskTitle(
                                title: widget.label,
                                maxWidth: bounds.maxWidth,
                                maxHeight: bounds.maxHeight,
                                preferredSize: 34,
                                minimumSize: 20,
                                maxLines: 3,
                              );
                            },
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

// Visual arrow only; the parent card receives all taps.
class _QuickArrowBadge extends StatelessWidget {
  final Color color;
  final bool pressed;

  const _QuickArrowBadge({
    required this.color,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    // Reuse the exact arrow design from Perkhidmatan Utama.
    return _CardArrow(
      accentColor: color,
      pressed: pressed,
    );
  }
}

// SCROLL CONTROLS: same three modes, labels, gestures and visual treatment.
enum _ScrollControlMode { up, more, top }

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

class _ScrollDiscoveryControlState extends State<_ScrollDiscoveryControl> {
  bool _pressed = false;
  bool _activating = false;
  bool _hovered = false;

  Future<void> _handleTap() async {
    if (_activating) return;
    setState(() => _activating = true);
    await Future<void>.delayed(const Duration(milliseconds: 115));
    if (!mounted) return;
    setState(() => _activating = false);
    widget.onPressed();
  }

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final depressed = _pressed || _activating;
    final active = depressed || _hovered;
    final isUp = widget.mode == _ScrollControlMode.up ||
        widget.mode == _ScrollControlMode.top;
    final arrow = isUp
        ? Icons.keyboard_arrow_up_rounded
        : Icons.keyboard_arrow_down_rounded;

    return AnimatedScale(
      scale: depressed ? 0.946 : (_hovered ? 0.992 : 1.0),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onHighlightChanged: _setPressed,
          onHover: (hovered) {
            if (mounted) setState(() => _hovered = hovered);
          },
          borderRadius: BorderRadius.circular(100),
          splashColor: const Color(0xFF1469E8).withOpacity(0.20),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            constraints: const BoxConstraints(minHeight: 88),
            padding: const EdgeInsets.fromLTRB(30, 13, 22, 13),
            decoration: BoxDecoration(
              color: depressed
                  ? const Color(0xFFE4F1FF)
                  : (_hovered ? const Color(0xFFF4F9FF) : Colors.white),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: active
                    ? const Color(0xFF1469E8)
                    : const Color(0xFFC4D8EE),
                width: depressed ? 3.0 : (active ? 2.2 : 1.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF173B66).withOpacity(
                    depressed ? 0.08 : 0.17,
                  ),
                  blurRadius: depressed ? 6 : 20,
                  offset: Offset(0, depressed ? 2 : 7),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUp) ...[
                  _ScrollArrowCircle(icon: arrow, pressed: depressed),
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
                  _ScrollArrowCircle(icon: arrow, pressed: depressed),
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
              ? const [Color(0xFF0B4FAE), Color(0xFF0A73E8)]
              : const [Color(0xFF1469E8), Color(0xFF0A82F5)],
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
      child: Icon(icon, color: Colors.white, size: 48),
    );
  }
}
