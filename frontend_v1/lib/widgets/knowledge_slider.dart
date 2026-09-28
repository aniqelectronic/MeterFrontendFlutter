import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

/// Self-contained localized knowledge slider with automatic navigation.
class KnowledgeSlider extends StatefulWidget {
  final Duration slideDuration;
  final double height;
  final double titleFontSize;
  final double subtitleFontSize;
  final double factFontSize;
  final double counterFontSize;

  const KnowledgeSlider({
    super.key,
    this.slideDuration = const Duration(seconds: 8),
    this.height = 250,
    this.titleFontSize = 32,
    this.subtitleFontSize = 20,
    this.factFontSize = 25,
    this.counterFontSize = 25,
  });

  @override
  State<KnowledgeSlider> createState() => _KnowledgeSliderState();
}

class _KnowledgeSliderState extends State<KnowledgeSlider> {
  final PageController _knowledgeController = PageController();
  Timer? _knowledgeTimer;
  int _currentKnowledgeIndex = 0;

  @override
  void initState() {
    super.initState();
    _startKnowledgeTimer();
  }

  @override
  void didUpdateWidget(covariant KnowledgeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slideDuration != widget.slideDuration) {
      _startKnowledgeTimer();
    }
  }

  @override
  void dispose() {
    _knowledgeTimer?.cancel();
    _knowledgeController.dispose();
    super.dispose();
  }

  void _startKnowledgeTimer() {
    _knowledgeTimer?.cancel();
    _knowledgeTimer = Timer.periodic(
      widget.slideDuration,
      (_) {
        if (!mounted || !_knowledgeController.hasClients) return;
        _goToKnowledge(_currentKnowledgeIndex + 1);
      },
    );
  }
  void _goToKnowledge(int index) {
    if (!mounted || !_knowledgeController.hasClients) return;
    final count = _knowledgeItems(AppLocalizations.of(context)!).length;
    if (count == 0) return;
    final normalizedIndex = index % count;
    _knowledgeController.animateToPage(
      normalizedIndex,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
    _startKnowledgeTimer();
  }
  void _previousKnowledge() {
    _goToKnowledge(
      _currentKnowledgeIndex - 1,
    );
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
    return _KnowledgeSlider(
      controller: _knowledgeController,
      title: loc.didYouKnowTitle,
      subtitle: loc.didYouKnowSubtitle,
      items: _knowledgeItems(loc),
      currentIndex: _currentKnowledgeIndex,
      height: widget.height,
      titleFontSize: widget.titleFontSize,
      subtitleFontSize: widget.subtitleFontSize,
      factFontSize: widget.factFontSize,
      counterFontSize: widget.counterFontSize,
      onPageChanged: (index) {
        setState(() => _currentKnowledgeIndex = index);
        _startKnowledgeTimer();
      },
      onPrevious: _previousKnowledge,
      onNext: _nextKnowledge,
      onIndicatorPressed: _goToKnowledge,
    );
  }
}

class _KnowledgeSlider extends StatelessWidget {
  final double height;
  final double titleFontSize;
  final double subtitleFontSize;
  final double factFontSize;
  final double counterFontSize;
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
    required this.height,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.factFontSize,
    required this.counterFontSize,
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
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE5F0FF),
            Color(0xFFF9FBFF),
            Color(0xFFFFFFFF),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF9CBCE6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18324F).withOpacity(0.11),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                26,
                20,
                24,
                16,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7E2),
                        border: Border.all(color: const Color(0xFFE8CC8E), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF18324F).withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFFA66B09),
                          size: 33,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFF142D4E),
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color:
                                    const Color(0xFF56657A),
                                fontSize: subtitleFontSize,
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
                            style: TextStyle(
                              color: const Color(0xFF142D4E),
                              fontSize: factFontSize,
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
                          color:
                              const Color(0xFF1469E8),
                          fontSize: counterFontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children:
                              List.generate(items.length, (index) {
                            final isActive =
                                index == currentIndex;
                            return GestureDetector(
                              onTap: () =>
                                  onIndicatorPressed(index),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 220),
                                margin:
                                    const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: isActive ? 23 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF1469E8)
                                      : const Color(0xFFCBDCF2),
                                  borderRadius:
                                      BorderRadius.circular(20),
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
  const _KnowledgeNavigationButton({
    required this.icon,
    required this.onPressed,
  });
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
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFFE5F0FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFB7CEEB),
              width: 1.5,
            ),
          ),
          child: Icon(
            widget.icon,
            color: const Color(0xFF142D4E),
            size: 34,
          ),
        ),
      ),
    );
  }
}
