import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbt3.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class P4OPTIONCOMPOUND extends StatelessWidget {
  const P4OPTIONCOMPOUND({super.key});

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
          // MODERN HEADER
          // ============================================================
          Positioned(
            top: 80,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              badgeText: loc.compoundServiceLabel,
              title: loc.compoundTitle,
              subtitle: loc.compoundSubtitle,
            ),
          ),

          // ============================================================
          // OPTION BUTTONS
          // ============================================================
          Positioned(
            top: 520,
            left: 60,
            right: 60,
            child: Row(
              children: [
                // ======================================================
                // SINGLE COMPOUND
                // ======================================================
                Expanded(
                  child: _ModernTextServiceButton(
                    height: 470,
                    visualText: '#',
                    label: loc.singleCompoundButton,
                    supportingText:
                        loc.singleCompoundSupportingText,
                    accentColor: const Color(0xFFE34E45),
                    accentLightColor:
                        const Color(0xFFFFE7E5),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => P4PAGE(
                            title: loc.singlecompoundTitle,
                            type: 'PBT',
                            hint: loc.inputCompoundHint,
                            biz: 'SINGLECOMPOUND',
                          ),
                          transitionsBuilder:
                              (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 38),

                // ======================================================
                // MULTIPLE COMPOUNDS BY PLATE
                // ======================================================
                Expanded(
                  child: _ModernTextServiceButton(
                    height: 470,
                    visualText: 'ABC 1234',
                    label: loc.multiCompoundButton,
                    supportingText:
                        loc.multiCompoundSupportingText,
                    accentColor: const Color(0xFF1469E8),
                    accentLightColor:
                        const Color(0xFFE6F0FF),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => P4PAGE(
                            title: loc.multicompoundTitle,
                            type: 'PBT',
                            hint: loc.inputPlateHint,
                            biz: 'MULTICOMPOUND',
                          ),
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
            bottom: 120,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PBT3PAGE(),
                  ),
                );
              },
            ),
          ),

          // ============================================================
          // FOOTER
          // ============================================================
          Positioned(
            bottom: 35,
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
// MODERN + GOVERNMENT PAGE HEADER
// KEEPS BADGE + TITLE + SUBTITLE
// ============================================================================
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
    const accentColor = Color(0xFFE34E45);

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
          // LEFT ICON
          // ==========================================================
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE34E45),
                  Color(0xFFF06A61),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.26),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(width: 28),

          // ==========================================================
          // TEXT AREA
          // ==========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // BADGE - KEPT
                // ------------------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEA),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.gavel_rounded,
                        size: 20,
                        color: accentColor,
                      ),

                      const SizedBox(width: 8),

                      Text(
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
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ------------------------------------------------------
                // TITLE 
                // ------------------------------------------------------
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

                // ------------------------------------------------------
                // SUBTITLE - KEPT
                // ------------------------------------------------------
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
                  Color(0xFFE34E45),
                  Color(0xFFF27A72),
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
// MODERN TEXT-BASED SERVICE BUTTON
// Used because this page has no logo or image.
// ============================================================================
class _ModernTextServiceButton extends StatefulWidget {
  final String visualText;
  final String label;
  final String supportingText;
  final VoidCallback onPressed;
  final double height;
  final Color accentColor;
  final Color accentLightColor;
  final bool comingSoon;

  const _ModernTextServiceButton({
    super.key,
    required this.visualText,
    required this.label,
    required this.supportingText,
    required this.onPressed,
    required this.accentColor,
    required this.accentLightColor,
    this.height = 470,
    this.comingSoon = false,
  });

  @override
  State<_ModernTextServiceButton> createState() =>
      _ModernTextServiceButtonState();
}

class _ModernTextServiceButtonState extends State<_ModernTextServiceButton> {
  bool _isPressed = false;
  bool _isFocused = false;

  void _setPressed(bool value) {
    if (!mounted || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.comingSoon;
    final accent = widget.accentColor;
    final light = widget.accentLightColor;
    final emphasized = enabled && (_isPressed || _isFocused);
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
        height: widget.height,
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
            onTap: enabled ? widget.onPressed : null,
            canRequestFocus: enabled,
            onHighlightChanged: enabled ? _setPressed : null,
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
                      height: widget.height * 0.51,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: widget.height * 0.36,
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
                                            child: Text(
                                              widget.visualText,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: accent,
                                                fontSize: widget.visualText.length > 3
                                                    ? 38 : 100,
                                                fontWeight: FontWeight.w900,
                                                height: 1.1,
                                                letterSpacing: widget.visualText.length > 3
                                                    ? 1 : 0,
                                              ),
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
                                        widget.label.toUpperCase(),
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
                                        widget.supportingText,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Color(0xFF56657A),
                                          fontSize: 22,
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
                if (widget.comingSoon)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.28),
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 34,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74343),
                            borderRadius:
                                BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.20),
                                blurRadius: 18,
                                offset:
                                    const Offset(0, 8),
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
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
