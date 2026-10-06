import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/p2.dart';
import 'package:frontend_v1/pages/tourist/eksplorasi/pexploration_melaka.dart';

import 'package:frontend_v1/pages/tourist/eksplorasi/pexploration_putrajaya.dart';
import 'package:frontend_v1/pages/tourist/map/pmapgoogle.dart';
import 'package:frontend_v1/pages/tourist/waktusolat/pwaktusolat.dart';
import 'package:frontend_v1/pages/tourist/weather/weather_page.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/knowledge_slider.dart';

class PTOURISTPAGE extends StatelessWidget {
  const PTOURISTPAGE({
    super.key,
  });

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
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.19),
                    Colors.white.withOpacity(0.10),
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // PAGE HEADER
          // ============================================================
          Positioned(
            top: 40,
            left: 58,
            right: 58,
            child: _ModernPageHeader(
              badgeText: loc.tourismServiceLabel,
              title: loc.p3othersTitle,
              subtitle: loc.p3othersSubtitle,
            ),
          ),

          // ============================================================
          // SAME KNOWLEDGE SLIDER AS PBT
          // ============================================================
          const Positioned(
            top: 325,
            left: 58,
            right: 58,
            child: KnowledgeSlider(
              height: 250,

              /// SAME SIZE AS PBT
              titleFontSize: 32,
              subtitleFontSize: 25,
              factFontSize: 25,
              counterFontSize: 25,

              /// AUTO CHANGE EVERY 8 SECONDS
              slideDuration: Duration(
                seconds: 8,
              ),
            ),
          ),

          // ============================================================
          // TOURISM SERVICE BUTTONS
          // ============================================================
          Positioned(
            top: 605,
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
                  // ==================================================
                  // FIRST ROW
                  // ==================================================
                  Row(
                    children: [
                      /// =================================================
                      /// EXPLORATION
                      /// =================================================
                      Expanded(
                        child: _ModernServiceButton(
                          height: 450,

                          icon:
                              Icons.travel_explore_rounded,

                          label:
                              loc.p3eksplorasiButton,

                          supportingText:
                              loc.explorationSupportingText,

                          accentColor:
                              const Color(
                            0xFFE56C16,
                          ),

                          accentLightColor:
                              const Color(
                            0xFFFFEBDC,
                          ),

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PExplorationMelakaPage(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 28,
                      ),

                      /// =================================================
                      /// MAP
                      /// =================================================
                      Expanded(
                        child: _ModernServiceButton(
                          height: 450,

                          icon:
                              Icons.map_rounded,

                          label:
                              loc.p3map,

                          supportingText:
                              loc.mapSupportingText,

                          accentColor:
                              const Color(
                            0xFF1469E8,
                          ),

                          accentLightColor:
                              const Color(
                            0xFFE6F0FF,
                          ),

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

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // SECOND ROW
                  // ==================================================
                  Row(
                    children: [
                      /// =================================================
                      /// PRAYER TIME
                      /// =================================================
                      Expanded(
                        child: _ModernServiceButton(
                          height: 450,

                          icon:
                              FlutterIslamicIcons.mosque,

                          label:
                              loc.p3waktusolat,

                          supportingText:
                              loc.prayerTimeSupportingText,

                          accentColor:
                              const Color(
                            0xFF008F72,
                          ),

                          accentLightColor:
                              const Color(
                            0xFFE0F8F1,
                          ),

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

                      const SizedBox(
                        width: 28,
                      ),

                      /// =================================================
                      /// WEATHER
                      /// =================================================
                      Expanded(
                        child: _ModernServiceButton(
                          height: 450,

                          icon:
                              Icons.cloud_rounded,

                          label:
                              loc.weatherButton,

                          supportingText:
                              loc.weatherSupportingText,

                          accentColor:
                              const Color(
                            0xFF0B7894,
                          ),

                          accentLightColor:
                              const Color(
                            0xFFE1F7FB,
                          ),

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PWeatherPage(),
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

          // ============================================================
          // BACK BUTTON
          // ============================================================
          Positioned(
            bottom: 93,
            left: 210,
            right: 210,

            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const P2Page(),
                  ),
                );
              },
            ),
          ),

          // ============================================================
          // FOOTER
          // ============================================================
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,

            child: Center(
              child: Text(
                Data.copyrightText,

                style: const TextStyle(
                  color: Color(
                    0xFF26364A,
                  ),
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
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
// MODERN GOVERNMENT TOURISM HEADER
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
    const Color accentColor =
        Color(0xFFE56C16);

    const Color darkAccent =
        Color(0xFFB94B00);

    const Color lightAccent =
        Color(0xFFF08B3E);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        24,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.96,
        ),

        borderRadius:
            BorderRadius.circular(
          32,
        ),

        border: Border.all(
          color: const Color(
            0xFFD5E4F7,
          ),
          width: 2,
        ),

        boxShadow: [
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

      child: Row(
        children: [
          // ==========================================================
          // LEFT TOURISM ICON
          // ==========================================================
          Container(
            width: 105,
            height: 105,

            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  darkAccent,
                  lightAccent,
                ],
              ),

              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      accentColor
                          .withOpacity(
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

            child: const Icon(
              Icons.travel_explore_rounded,

              color: Colors.white,

              size: 56,
            ),
          ),

          const SizedBox(
            width: 28,
          ),

          // ==========================================================
          // HEADER INFORMATION
          // ==========================================================
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                /// =================================================
                /// SERVICE BADGE
                /// =================================================
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color:
                        const Color(
                      0xFFFFEBDC,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                  ),

                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      const Icon(
                        Icons
                            .explore_rounded,

                        size: 20,

                        color:
                            accentColor,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Flexible(
                        child: Text(
                          badgeText
                              .toUpperCase(),

                          maxLines: 1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              const TextStyle(
                            color:
                                accentColor,

                            fontSize: 17,

                            fontWeight:
                                FontWeight
                                    .w900,

                            letterSpacing:
                                1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                /// =================================================
                /// TITLE
                /// =================================================
                Text(
                  title.toUpperCase(),

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF122C4C,
                    ),

                    fontSize: 52,

                    fontWeight:
                        FontWeight.w900,

                    height: 1.02,

                    letterSpacing:
                        -0.8,
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                /// =================================================
                /// SUBTITLE
                /// =================================================
                Text(
                  subtitle,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF607188,
                    ),

                    fontSize: 30,

                    fontWeight:
                        FontWeight.w600,

                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 24,
          ),

          // ==========================================================
          // RIGHT ORANGE ACCENT
          // ==========================================================
          Container(
            width: 8,
            height: 105,

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),

              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topCenter,

                end:
                    Alignment.bottomCenter,

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
// MODERN TOURISM SERVICE BUTTON
// ============================================================================

class _ModernServiceButton
    extends StatefulWidget {
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
    this.height = 450,
    this.comingSoon = false,
  });

  @override
  State<_ModernServiceButton>
      createState() =>
          _ModernServiceButtonState();
}

class _ModernServiceButtonState
    extends State<_ModernServiceButton> {
  bool _isPressed = false;
  bool _isFocused = false;

  void _setPressed(
    bool value,
  ) {
    if (!mounted ||
        widget.comingSoon) {
      return;
    }

    setState(
      () {
        _isPressed = value;
      },
    );
  }

  Widget _buildServiceIcons() {
    if (widget.icon != null) {
      return FittedBox(
        fit: BoxFit.contain,

        child: Icon(
          widget.icon,

          size: 300,

          color:
              widget.accentColor,
        ),
      );
    }

    if (widget.imagePath != null) {
      return Image.asset(
        widget.imagePath!,

        fit: BoxFit.contain,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final enabled =
        !widget.comingSoon;

    final radius =
        BorderRadius.circular(
      26,
    );

    final emphasized =
        _isPressed || _isFocused;

    final borderColor =
        emphasized
            ? widget.accentColor
            : Color.lerp(
                const Color(
                  0xFFB9C8DA,
                ),
                widget.accentColor,
                0.28,
              )!;

    return AnimatedScale(
      scale:
          _isPressed
              ? 0.985
              : 1,

      duration:
          const Duration(
        milliseconds: 120,
      ),

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 160,
        ),

        height:
            widget.height,

        decoration:
            BoxDecoration(
          borderRadius:
              radius,

          boxShadow: [
            BoxShadow(
              color:
                  const Color(
                0xFF18324F,
              ).withOpacity(
                _isPressed
                    ? 0.05
                    : 0.11,
              ),

              blurRadius:
                  _isPressed
                      ? 8
                      : 18,

              offset: Offset(
                0,
                _isPressed
                    ? 2
                    : 7,
              ),
            ),
          ],
        ),

        child: Material(
          color:
              Colors.white,

          clipBehavior:
              Clip.antiAlias,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                radius,

            side:
                BorderSide(
              color:
                  borderColor,

              width: 2,
            ),
          ),

          child: InkWell(
            onTap:
                enabled
                    ? widget.onPressed
                    : null,

            onHighlightChanged:
                _setPressed,

            onFocusChange:
                (
                  focused,
                ) {
              if (mounted) {
                setState(
                  () {
                    _isFocused =
                        focused;
                  },
                );
              }
            },

            splashColor:
                widget.accentColor
                    .withOpacity(
              0.10,
            ),

            highlightColor:
                widget.accentColor
                    .withOpacity(
              0.04,
            ),

            child: Stack(
              fit:
                  StackFit.expand,

              children: [
                Opacity(
                  opacity:
                      enabled
                          ? 1
                          : 0.45,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,

                    children: [
                      /// ==========================================
                      /// ICON AREA
                      /// ==========================================
                      SizedBox(
                        height:
                            widget.height *
                                0.42,

                        child:
                            LayoutBuilder(
                          builder:
                              (
                                context,
                                headerBounds,
                              ) {
                            return Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,

                                  height:
                                      headerBounds
                                              .maxHeight *
                                          0.72,

                                  child: Ink(
                                    decoration:
                                        BoxDecoration(
                                      gradient:
                                          LinearGradient(
                                        begin:
                                            Alignment
                                                .topLeft,

                                        end:
                                            Alignment
                                                .bottomRight,

                                        colors: [
                                          widget
                                              .accentLightColor,

                                          Color.lerp(
                                            Colors
                                                .white,

                                            widget
                                                .accentLightColor,

                                            0.40,
                                          )!,
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

                                  child:
                                      IgnorePointer(
                                    child:
                                        ExcludeSemantics(
                                      child:
                                          AnimatedContainer(
                                        duration:
                                            const Duration(
                                          milliseconds:
                                              160,
                                        ),

                                        padding:
                                            const EdgeInsets
                                                .fromLTRB(
                                          18,
                                          20,
                                          18,
                                          16,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Color.lerp(
                                            Colors.white,

                                            widget
                                                .accentLightColor,

                                            0.18,
                                          ),

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            22,
                                          ),

                                          border:
                                              Border.all(
                                            color:
                                                widget
                                                    .accentColor
                                                    .withOpacity(
                                              0.22,
                                            ),

                                            width:
                                                1.5,
                                          ),

                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  widget
                                                      .accentColor
                                                      .withOpacity(
                                                _isPressed
                                                    ? 0.08
                                                    : 0.15,
                                              ),

                                              blurRadius:
                                                  _isPressed
                                                      ? 10
                                                      : 18,

                                              offset:
                                                  Offset(
                                                0,
                                                _isPressed
                                                    ? 3
                                                    : 7,
                                              ),
                                            ),
                                          ],
                                        ),

                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [
                                            Expanded(
                                              child:
                                                  Center(
                                                child:
                                                    SizedBox(
                                                  width:
                                                      126,

                                                  height:
                                                      126,

                                                  child:
                                                      _buildServiceIcons(),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(
                                              width:
                                                  8,
                                            ),

                                            Container(
                                              width:
                                                  38,

                                              height:
                                                  38,

                                              decoration:
                                                  BoxDecoration(
                                                color:
                                                    widget.accentColor,

                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12,
                                                ),
                                              ),

                                              child:
                                                  const Icon(
                                                Icons
                                                    .arrow_forward_rounded,

                                                color:
                                                    Colors.white,

                                                size:
                                                    25,
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

                      /// ==========================================
                      /// TEXT AREA
                      /// ==========================================
                      Expanded(
                        child:
                            Padding(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            26,
                            24,
                            26,
                            26,
                          ),

                          child:
                              LayoutBuilder(
                            builder:
                                (
                                  context,
                                  bounds,
                                ) {
                              return SizedBox(
                                width:
                                    bounds
                                        .maxWidth,

                                height:
                                    bounds
                                        .maxHeight,

                                child:
                                    FittedBox(
                                  fit:
                                      BoxFit
                                          .scaleDown,

                                  alignment:
                                      Alignment
                                          .topLeft,

                                  child:
                                      SizedBox(
                                    width:
                                        bounds
                                            .maxWidth,

                                    child:
                                        Column(
                                      mainAxisSize:
                                          MainAxisSize
                                              .min,

                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [
                                        Text(
                                          widget
                                              .label
                                              .toUpperCase(),

                                          softWrap:
                                              true,

                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF142D4E,
                                            ),

                                            fontSize:
                                                32,

                                            fontWeight:
                                                FontWeight
                                                    .w800,

                                            height:
                                                1.16,
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              16,
                                        ),

                                        Text(
                                          widget
                                              .supportingText,

                                          softWrap:
                                              true,

                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF526175,
                                            ),

                                            fontSize:
                                                25,

                                            fontWeight:
                                                FontWeight
                                                    .w500,

                                            height:
                                                1.35,
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

                /// ================================================
                /// OUTER ACTIVE BORDER
                /// ================================================
                Positioned.fill(
                  child:
                      IgnorePointer(
                    child:
                        AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds:
                            160,
                      ),

                      decoration:
                          BoxDecoration(
                        borderRadius:
                            radius,

                        border:
                            Border.all(
                          color:
                              borderColor,

                          width:
                              emphasized
                                  ? 3
                                  : 2,
                        ),
                      ),
                    ),
                  ),
                ),

                /// ================================================
                /// COMING SOON
                /// ================================================
                if (widget.comingSoon)
                  Center(
                    child:
                        Container(
                      margin:
                          const EdgeInsets
                              .all(
                        18,
                      ),

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            20,

                        vertical:
                            14,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF334155,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),

                      child:
                          Text(
                        AppLocalizations
                                .of(
                          context,
                        )!
                            .comingsoonText
                            .toUpperCase(),

                        textAlign:
                            TextAlign
                                .center,

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize:
                              24,

                          fontWeight:
                              FontWeight
                                  .w700,
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