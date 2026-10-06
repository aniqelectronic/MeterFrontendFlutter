import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/modern_provider_card.dart';

// ============================================================================
// ENTERTAINMENT BILLER MODEL
// ============================================================================

class EntertainmentBiller {
  final String productCode;
  final String billerName;
  final String imageUrl;

  final Color accentColor;
  final Color lightAccentColor;

  const EntertainmentBiller({
    required this.productCode,
    required this.billerName,
    required this.imageUrl,
    required this.accentColor,
    required this.lightAccentColor,
  });
}

// ============================================================================
// ENTERTAINMENT BILL PROVIDER PAGE
// ============================================================================

class PENTERTAINMENTBILL3PAGE extends StatefulWidget {
  const PENTERTAINMENTBILL3PAGE({
    super.key,
  });

  @override
  State<PENTERTAINMENTBILL3PAGE> createState() =>
      _PENTERTAINMENTBILL3PAGEState();
}

class _PENTERTAINMENTBILL3PAGEState
    extends State<PENTERTAINMENTBILL3PAGE> {
  // ==========================================================================
  // ASTRO PROVIDER
  //
  // Keeping your current Entertainment logic:
  //
  // ASB = ASTRO
  // ==========================================================================

  static const EntertainmentBiller _astroBiller =
      EntertainmentBiller(
    productCode: 'ASB',
    billerName: 'ASTRO',
    imageUrl:
        'https://dashboard.iimmpact.com/img/ASB.png',
    accentColor: Color(
      0xFFE32675,
    ),
    lightAccentColor: Color(
      0xFFFFE6F1,
    ),
  );

  // ==========================================================================
  // NETWORK STATUS
  //
  // Now uses the shared ProviderNetworkStatus from:
  //
  // modern_provider_card.dart
  // ==========================================================================

  final Map<String, ProviderNetworkStatus>
      _billerStatuses = {
    _astroBiller.productCode:
        ProviderNetworkStatus.loading,
  };

  final Map<String, String?> _lastUpdated = {};

  // ==========================================================================
  // PROCESSING TIME FROM CATALOG
  // ==========================================================================

  final Map<String, String> _processingTimes = {};

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _refreshNetworkStatus(
          _astroBiller.productCode,
        );

        _loadCatalogProcessingTime();
      },
    );
  }

  // ==========================================================================
  // LOAD ASTRO PROCESSING TIME FROM CATALOG
  // ==========================================================================

  Future<void> _loadCatalogProcessingTime() async {
    try {
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        debugPrint(
          'Entertainment catalog error: '
          'products not found.',
        );

        return;
      }

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final dynamic rawProduct =
          products[_astroBiller.productCode];

      if (rawProduct is! Map) {
        debugPrint(
          'Entertainment catalog product not found: '
          '${_astroBiller.productCode}',
        );

        return;
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      final String processingTime =
          product['processing_time']
                  ?.toString()
                  .trim() ??
              '';

      if (!mounted) {
        return;
      }

      setState(() {
        if (processingTime.isNotEmpty) {
          _processingTimes[
                  _astroBiller.productCode] =
              processingTime;
        }
      });

      debugPrint(
        'Entertainment processing time loaded: '
        '$processingTime',
      );
    }

    on IimmpactCatalogException catch (error) {
      debugPrint(
        'Entertainment catalog error: '
        '${error.message}',
      );
    }

    catch (error, stackTrace) {
      debugPrint(
        'Unexpected entertainment catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );
    }
  }

  // ==========================================================================
  // REFRESH ASTRO NETWORK STATUS
  // ==========================================================================

  Future<ProviderNetworkStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            ProviderNetworkStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode:
            productCode,
      );

      final ProviderNetworkStatus status =
          result.isHealthy
              ? ProviderNetworkStatus.healthy
              : ProviderNetworkStatus.interruption;

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              status;

          _lastUpdated[productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Entertainment network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              ProviderNetworkStatus.unavailable;
        });
      }

      return ProviderNetworkStatus.unavailable;
    }
  }

  // ==========================================================================
  // ENTERTAINMENT PROCESSING TIME
  //
  // Keeps your original special translation behavior:
  //
  // instant
  // 24_hours
  // 48_hours
  // 72_hours
  // 2_days
  // 3_days
  // 5_days
  // etc.
  // ==========================================================================

  String _formatEntertainmentProcessingTime(
    BuildContext context,
    String value,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    final String normalized =
        value
            .toLowerCase()
            .trim();

    // ========================================================================
    // INSTANT
    // ========================================================================

    if (normalized == 'instant') {
      return loc.processingInstant;
    }

    // ========================================================================
    // 24 HOURS
    // ========================================================================

    if (normalized == '24_hours') {
      return loc.processing24Hours;
    }

    // ========================================================================
    // 3 DAYS
    // ========================================================================

    if (normalized == '3_days') {
      return loc.processing3Days;
    }

    // ========================================================================
    // GENERIC HOURS
    // ========================================================================

    if (normalized.endsWith(
      '_hours',
    )) {
      final String hours =
          normalized.replaceAll(
        '_hours',
        '',
      );

      return loc.entertainmentUpdateWithinHours(
        hours,
      );
    }

    // ========================================================================
    // GENERIC DAYS
    // ========================================================================

    if (normalized.endsWith(
      '_days',
    )) {
      final String days =
          normalized.replaceAll(
        '_days',
        '',
      );

      return loc.entertainmentUpdateWithinDays(
        days,
      );
    }

    return value.replaceAll(
      '_',
      ' ',
    );
  }

  // ==========================================================================
  // NETWORK INTERRUPTION WARNING
  // ==========================================================================

  Future<bool> _showInterruptionWarning({
    required String billerName,
    required String productCode,
  }) async {
    final loc =
        AppLocalizations.of(context)!;

    final bool? result =
        await showDialog<bool>(
      context:
          context,

      barrierDismissible:
          false,

      builder:
          (
        BuildContext dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,

          insetPadding:
              const EdgeInsets.symmetric(
            horizontal:
                80,
          ),

          child: Container(
            width:
                800,

            padding:
                const EdgeInsets.fromLTRB(
              45,
              42,
              45,
              38,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(
                38,
              ),

              border:
                  Border.all(
                color:
                    const Color(
                  0xFFF2A520,
                ),

                width:
                    3,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.25,
                  ),

                  blurRadius:
                      35,

                  offset:
                      const Offset(
                    0,
                    18,
                  ),
                ),
              ],
            ),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                // ============================================================
                // WARNING ICON
                // ============================================================

                Container(
                  width:
                      125,

                  height:
                      125,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF2D9,
                    ),

                    shape:
                        BoxShape.circle,

                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFF2A520,
                      ).withOpacity(
                        0.30,
                      ),

                      width:
                          2,
                    ),
                  ),

                  child:
                      const Icon(
                    Icons.warning_amber_rounded,

                    color:
                        Color(
                      0xFFD87900,
                    ),

                    size:
                        78,
                  ),
                ),

                const SizedBox(
                  height:
                      28,
                ),

                // ============================================================
                // TITLE
                // ============================================================

                Text(
                  loc.networkInterruptionTitle,

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),

                    fontSize:
                        40,

                    fontWeight:
                        FontWeight.w900,

                    height:
                        1.1,
                  ),
                ),

                const SizedBox(
                  height:
                      24,
                ),

                // ============================================================
                // MESSAGE
                // ============================================================

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        28,

                    vertical:
                        25,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF9ED,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),

                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFF4D69D,
                      ),

                      width:
                          1.5,
                    ),
                  ),

                  child: Text(
                    loc.networkInterruptionMessage(
                      billerName,
                    ),

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF4B4234,
                      ),

                      fontSize:
                          29,

                      height:
                          1.4,

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                // ============================================================
                // LAST UPDATED
                // ============================================================

                if (_lastUpdated[
                        productCode] !=
                    null) ...[
                  const SizedBox(
                    height:
                        20,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.schedule_rounded,

                        size:
                            24,

                        color:
                            Color(
                          0xFF758399,
                        ),
                      ),

                      const SizedBox(
                        width:
                            8,
                      ),

                      Flexible(
                        child: Text(
                          '${loc.networkLastUpdated}: '
                          '${_lastUpdated[productCode]}',

                          textAlign:
                              TextAlign.center,

                          style:
                              const TextStyle(
                            fontSize:
                                21,

                            color:
                                Color(
                              0xFF758399,
                            ),

                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(
                  height:
                      36,
                ),

                // ============================================================
                // BUTTONS
                // ============================================================

                Row(
                  children: [
                    // ========================================================
                    // BACK
                    // ========================================================

                    Expanded(
                      child:
                          SizedBox(
                        height:
                            78,

                        child:
                            OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );
                          },

                          icon:
                              const Icon(
                            Icons.arrow_back_rounded,

                            size:
                                29,
                          ),

                          label:
                              Text(
                            loc.backButton,

                            style:
                                const TextStyle(
                              fontSize:
                                  24,

                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          style:
                              OutlinedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xFFFFE8E8,
                            ),

                            foregroundColor:
                                const Color(
                              0xFFC62828,
                            ),

                            side:
                                const BorderSide(
                              color:
                                  Color(
                                0xFFE57373,
                              ),

                              width:
                                  2,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width:
                          22,
                    ),

                    // ========================================================
                    // CONTINUE
                    // ========================================================

                    Expanded(
                      child:
                          SizedBox(
                        height:
                            78,

                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          },

                          icon:
                              const Icon(
                            Icons.arrow_forward_rounded,

                            size:
                                29,
                          ),

                          label:
                              Text(
                            loc.continueButton,

                            style:
                                const TextStyle(
                              fontSize:
                                  24,

                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF168A50,
                            ),

                            foregroundColor:
                                Colors.white,

                            elevation:
                                0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // ==========================================================================
  // ASTRO TAP
  // ==========================================================================

  Future<void> _handleAstroTap() async {
    final ProviderNetworkStatus status =
        await _refreshNetworkStatus(
      _astroBiller.productCode,
    );

    if (!mounted) {
      return;
    }

    // ========================================================================
    // INTERRUPTION
    // ========================================================================

    if (status ==
        ProviderNetworkStatus.interruption) {
      final bool shouldContinue =
          await _showInterruptionWarning(
        billerName:
            _astroBiller.billerName,

        productCode:
            _astroBiller.productCode,
      );

      if (!shouldContinue) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    // ========================================================================
    // UNAVAILABLE
    // ========================================================================

    if (status ==
        ProviderNetworkStatus.unavailable) {
      final loc =
          AppLocalizations.of(context)!;

      await showDialog<void>(
        context:
            context,

        builder:
            (
          BuildContext dialogContext,
        ) {
          return AlertDialog(
            title:
                Text(
              loc.alertTitle,

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            content:
                Text(
              loc.networkUnavailableMessage(
                _astroBiller.billerName,
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },

                child:
                    Text(
                  loc.electricOk,
                ),
              ),
            ],
          );
        },
      );

      return;
    }

    if (!mounted) {
      return;
    }

    // ========================================================================
    // PAGE 4
    //
    // ORIGINAL ENTERTAINMENT FLOW KEPT.
    // ========================================================================

    final loc =
        AppLocalizations.of(context)!;

    await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            P4BILPAGE(
          title:
              loc.entertainmentAccountTitle,

          hint:
              loc.entertainmentAccountHint,

          productCode:
              _astroBiller.productCode,

          billerName:
              _astroBiller.billerName,

          serviceType:
              BillServiceType.entertainment,
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    return Scaffold(
      body:
          Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================

          Positioned.fill(
            child:
                Image.asset(
              'lib/images/pnew.png',

              fit:
                  BoxFit.cover,
            ),
          ),

          // ==================================================================
          // OVERLAY
          // ==================================================================

          Positioned.fill(
            child:
                Container(
              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,

                  end:
                      Alignment.bottomCenter,

                  colors: [
                    Colors.white.withOpacity(
                      0.02,
                    ),

                    Colors.white.withOpacity(
                      0.13,
                    ),

                    Colors.white.withOpacity(
                      0.04,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================================
          // HEADER
          // ==================================================================

          Positioned(
            top:
                75,

            left:
                65,

            right:
                65,

            child:
                _ModernEntertainmentHeader(
              title:
                  loc.entertainmentBillTitle,

              subtitle:
                  loc.pbil3Subtitle,
            ),
          ),

          // ==================================================================
          // PROVIDER AREA
          // ==================================================================

          Positioned(
            top:
                390,

            left:
                45,

            right:
                45,

            bottom:
                305,

            child:
                Container(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                22,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.20,
                ),

                borderRadius:
                    BorderRadius.circular(
                  36,
                ),

                border:
                    Border.all(
                  color:
                      Colors.white.withOpacity(
                    0.60,
                  ),

                  width:
                      1.5,
                ),
              ),

              // ==============================================================
              // ONLY ASTRO CURRENTLY
              // ==============================================================

              child:
                  Align(
                alignment:
                    Alignment.topLeft,

                child:
                    SizedBox(
                  width:
                      450,

                  // ModernProviderCard default height is 510
                  height:
                      510,

                  child:
                      ModernProviderCard(
                    imageUrl:
                        _astroBiller.imageUrl,

                    label:
                        _astroBiller.billerName,

                    accentColor:
                        _astroBiller.accentColor,

                    lightAccentColor:
                        _astroBiller.lightAccentColor,

                    networkStatus:
                        _billerStatuses[
                                _astroBiller
                                    .productCode] ??
                            ProviderNetworkStatus
                                .loading,

                    networkLabel:
                        loc.networkLabel,

                    processingTime:
                        _processingTimes[
                                _astroBiller
                                    .productCode] ??
                            '',

                    processingLabel:
                        loc.processingTimeLabel,

                    processingTimeFormatter:
                        _formatEntertainmentProcessingTime,

                    fallbackIcon:
                        Icons.live_tv_rounded,

                    onPressed:
                        _handleAstroTap,
                  ),
                ),
              ),
            ),
          ),

          // ==================================================================
          // BACK
          // ==================================================================

          Positioned(
            bottom:
                105,

            left:
                300,

            right:
                300,

            child:
                KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const PBIL3PAGE(),
                  ),
                );
              },
            ),
          ),

          // ==================================================================
          // FOOTER
          // ==================================================================

          Positioned(
            bottom:
                25,

            left:
                0,

            right:
                0,

            child:
                Text(
              Data.copyrightText,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF26364A,
                ),

                fontSize:
                    20,

                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODERN ENTERTAINMENT HEADER
// ============================================================================

class _ModernEntertainmentHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernEntertainmentHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color accentColor =
        Color(
      0xFFE32675,
    );

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        24,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.96,
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

          width:
              2,
        ),

        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF173A66,
            ).withOpacity(
              0.14,
            ),

            blurRadius:
                30,

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
          // ==================================================================
          // LEFT ICON
          // ==================================================================

          Container(
            width:
                105,

            height:
                105,

            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,

                end:
                    Alignment.bottomRight,

                colors: [
                  Color(
                    0xFFB21558,
                  ),

                  Color(
                    0xFFF04F9A,
                  ),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      accentColor.withOpacity(
                    0.28,
                  ),

                  blurRadius:
                      20,

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
              Icons.live_tv_rounded,

              color:
                  Colors.white,

              size:
                  56,
            ),
          ),

          const SizedBox(
            width:
                28,
          ),

          // ==================================================================
          // TEXT
          // ==================================================================

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ============================================================
                // BADGE
                // ============================================================

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        18,

                    vertical:
                        7,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFE9F2,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                  ),

                  child:
                      const Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      Icon(
                        Icons.live_tv_rounded,

                        size:
                            20,

                        color:
                            accentColor,
                      ),

                      SizedBox(
                        width:
                            8,
                      ),

                      Text(
                        'ENTERTAINMENT SERVICES',

                        maxLines:
                            1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            TextStyle(
                          color:
                              accentColor,

                          fontSize:
                              17,

                          fontWeight:
                              FontWeight.w900,

                          letterSpacing:
                              1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height:
                      12,
                ),

                // ============================================================
                // TITLE
                // ============================================================

                Text(
                  title.toUpperCase(),

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF122C4C,
                    ),

                    fontSize:
                        52,

                    fontWeight:
                        FontWeight.w900,

                    height:
                        1.02,

                    letterSpacing:
                        -0.8,
                  ),
                ),

                const SizedBox(
                  height:
                      9,
                ),

                // ============================================================
                // SUBTITLE
                // ============================================================

                Text(
                  subtitle.toUpperCase(),

                  maxLines:
                      2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF607188,
                    ),

                    fontSize:
                        22,

                    fontWeight:
                        FontWeight.w600,

                    height:
                        1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width:
                24,
          ),

          // ==================================================================
          // RIGHT ACCENT
          // ==================================================================

          Container(
            width:
                8,

            height:
                105,

            decoration:
                BoxDecoration(
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
                  Color(
                    0xFFB21558,
                  ),

                  Color(
                    0xFFF04F9A,
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