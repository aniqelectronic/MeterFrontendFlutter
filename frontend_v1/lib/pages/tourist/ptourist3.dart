import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/p2.dart';
import 'package:frontend_v1/pages/tourist/eksplorasi/pbentongexploration.dart';
import 'package:frontend_v1/pages/tourist/map/pmapgoogle.dart';
import 'package:frontend_v1/pages/tourist/waktusolat/pwaktusolat.dart';
import 'package:frontend_v1/pages/tourist/weather/pweather_bentong.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class PTOURISTPAGE extends StatefulWidget {
  const PTOURISTPAGE({super.key});

  @override
  State<PTOURISTPAGE> createState() => _PTOURISTPAGEState();
}

class _PTOURISTPAGEState extends State<PTOURISTPAGE> {
  static const Duration _slideDuration = Duration(seconds: 8);

  final PageController _knowledgeController = PageController();
  Timer? _knowledgeTimer;
  int _currentKnowledgeIndex = 0;

  @override
  void initState() {
    super.initState();
    _startKnowledgeTimer();
  }

  @override
  void dispose() {
    _knowledgeTimer?.cancel();
    _knowledgeController.dispose();
    super.dispose();
  }

  void _startKnowledgeTimer() {
    _knowledgeTimer?.cancel();
    _knowledgeTimer = Timer.periodic(_slideDuration, (_) {
      if (!mounted || !_knowledgeController.hasClients) return;
      _goToKnowledge(_currentKnowledgeIndex + 1);
    });
  }

  void _goToKnowledge(int index) {
    final int normalizedIndex = index % 20;

    _knowledgeController.animateToPage(
      normalizedIndex,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );

    _startKnowledgeTimer();
  }

  void _previousKnowledge() {
    final int previousIndex =
        (_currentKnowledgeIndex - 1 + 20) % 20;
    _goToKnowledge(previousIndex);
  }

  void _nextKnowledge() {
    _goToKnowledge(_currentKnowledgeIndex + 1);
  }

  List<String> _knowledgeItems(AppLocalizations loc) {
    return [
      loc.knowledgeFact01,
      loc.knowledgeFact02,
      loc.knowledgeFact03,
      loc.knowledgeFact04,
      loc.knowledgeFact05,
      loc.knowledgeFact06,
      loc.knowledgeFact07,
      loc.knowledgeFact08,
      loc.knowledgeFact09,
      loc.knowledgeFact10,
      loc.knowledgeFact11,
      loc.knowledgeFact12,
      loc.knowledgeFact13,
      loc.knowledgeFact14,
      loc.knowledgeFact15,
      loc.knowledgeFact16,
      loc.knowledgeFact17,
      loc.knowledgeFact18,
      loc.knowledgeFact19,
      loc.knowledgeFact20,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final knowledgeItems = _knowledgeItems(loc);

    return Scaffold(
      body: Stack(
        children: [
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
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.19),
                    Colors.white.withOpacity(0.10),
                  ],
                ),
              ),
            ),
          ),

          // =========================
          // PAGE HEADER
          // =========================
          Positioned(
            top: 68,
            left: 58,
            right: 58,
            child: _ModernPageHeader(
              badgeText: loc.tourismServiceLabel,
              title: loc.p3othersTitle,
              subtitle: loc.p3othersSubtitle,
            ),
          ),

          // =========================
          // DID YOU KNOW SLIDER
          // =========================
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

          // =========================
          // SERVICE BUTTONS
          // =========================
          Positioned(
            top: 620,
            left: 52,
            right: 52,
            bottom: 255,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 35,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ModernServiceButton(
                          height: 330,
                          icon: Icons.travel_explore_rounded,
                          label: loc.p3eksplorasiButton,
                          supportingText: loc.explorationSupportingText,
                          accentColor: const Color(0xFFE56C16),
                          accentLightColor: const Color(0xFFFFEBDC),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PExplorationBentongPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: _ModernServiceButton(
                          height: 330,
                          icon: Icons.map_rounded,
                          label: loc.p3map,
                          supportingText: loc.mapSupportingText,
                          accentColor: const Color(0xFF1469E8),
                          accentLightColor: const Color(0xFFE6F0FF),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PMAPGOOGLEPAGE(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _ModernServiceButton(
                          height: 330,
                          icon: FlutterIslamicIcons.mosque,
                          label: loc.p3waktusolat,
                          supportingText: loc.prayerTimeSupportingText,
                          accentColor: const Color(0xFF008F72),
                          accentLightColor: const Color(0xFFE0F8F1),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PWAKTUSOLATPAGE(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: _ModernServiceButton(
                          height: 330,
                          icon: Icons.cloud_rounded,
                          label: loc.weatherButton,
                          supportingText: loc.weatherSupportingText,
                          accentColor: const Color(0xFF0B7894),
                          accentLightColor: const Color(0xFFE1F7FB),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PWeatherPageBentong(),
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

          Positioned(
            bottom: 93,
            left: 210,
            right: 210,
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
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: const TextStyle(
                  color: Color(0xFF26364A),
                  fontSize: 17,
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
      height: 255,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF063D91),
            Color(0xFF126BD4),
            Color(0xFF1A8BE6),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.80),
          width: 2,
        ),
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
            Positioned(
              left: -25,
              bottom: -65,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFC85A).withOpacity(0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 24, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC84B),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.16),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFF633C00),
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _RoundNavigationButton(
                        icon: Icons.chevron_left_rounded,
                        onPressed: onPrevious,
                      ),
                      const SizedBox(width: 10),
                      _RoundNavigationButton(
                        icon: Icons.chevron_right_rounded,
                        onPressed: onNext,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: PageView.builder(
                      controller: controller,
                      itemCount: items.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Align(
                            key: ValueKey(index),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              items[index],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                height: 1.32,
                              ),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            items.length,
                            (index) {
                              final bool isActive =
                                  index == currentIndex;

                              return GestureDetector(
                                onTap: () =>
                                    onIndicatorPressed(index),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 220),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  width: isActive ? 24 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFFFD166)
                                        : Colors.white.withOpacity(0.38),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
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

class _RoundNavigationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundNavigationButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_RoundNavigationButton> createState() =>
      _RoundNavigationButtonState();
}

class _RoundNavigationButtonState
    extends State<_RoundNavigationButton> {
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_pressed ? 0.28 : 0.16),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.45),
              width: 1.5,
            ),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
    );
  }
}

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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 21,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE56C16).withOpacity(0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFFE56C16).withOpacity(0.22),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.explore_rounded,
                size: 22,
                color: Color(0xFFE56C16),
              ),
              const SizedBox(width: 9),
              Text(
                badgeText.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFE56C16),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.02,
            ),
          ),
        ),
        const SizedBox(height: 11),
        Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withOpacity(0.15),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF113968).withOpacity(0.09),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF435166),
              fontSize: 23,
              fontWeight: FontWeight.w700,
              height: 1.20,
            ),
          ),
        ),
      ],
    );
  }
}

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
    this.height = 330,
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
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.comingSoon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isEnabled ? (_) => _setPressed(true) : null,
      onTapUp: isEnabled ? (_) => _setPressed(false) : null,
      onTapCancel: isEnabled ? () => _setPressed(false) : null,
      onTap: isEnabled ? widget.onPressed : null,
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
              widget.comingSoon ? 0.65 : 0.95,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _isPressed ? widget.accentColor : Colors.black,
              width: _isPressed ? 4 : 2.5,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF19375C).withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(29),
            child: Stack(
              children: [
                Positioned(
                  right: -38,
                  top: -38,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _isPressed ? 170 : 158,
                    height: _isPressed ? 170 : 158,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentLightColor.withOpacity(0.88),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 25, 24, 23),
                  child: Opacity(
                    opacity: widget.comingSoon ? 0.5 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 160),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: widget.accentLightColor,
                                borderRadius: BorderRadius.circular(27),
                                border: Border.all(
                                  color: widget.accentColor
                                      .withOpacity(0.18),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: widget.icon != null
                                    ? Icon(
                                        widget.icon,
                                        size: _isPressed ? 61 : 57,
                                        color: widget.accentColor,
                                      )
                                    : Image.asset(
                                        widget.imagePath!,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),
                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 160),
                              transform: Matrix4.translationValues(
                                _isPressed ? 5 : 0,
                                0,
                                0,
                              ),
                              width: 49,
                              height: 49,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.accentColor
                                        .withOpacity(0.24),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 27,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          widget.label.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF15253A),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          widget.supportingText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF647187),
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 6,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                borderRadius:
                                    BorderRadius.circular(50),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Container(
                              width: 11,
                              height: 6,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
