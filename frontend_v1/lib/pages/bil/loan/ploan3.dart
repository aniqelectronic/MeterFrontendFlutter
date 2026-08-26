import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:frontend_v1/pages/bil/loan/ploan4.dart';

// ============================================================================
// LOAN PROVIDER STATUS
// ============================================================================

enum LoanProviderStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

// ============================================================================
// LOAN PROVIDER PAGE
// ============================================================================

class PLOAN3PAGE extends StatefulWidget {
  const PLOAN3PAGE({
    super.key,
  });

  @override
  State<PLOAN3PAGE> createState() =>
      _PLOAN3PAGEState();
}

class _PLOAN3PAGEState
    extends State<PLOAN3PAGE> {
  // ==========================================================================
  // PTPTN PRODUCT CODE
  // ==========================================================================

  static const String _ptptnProductCode =
      'PTPTN';

  // ==========================================================================
  // CATALOG PRODUCT
  // ==========================================================================

  Map<String, dynamic>? _ptptnProduct;

  bool _isCatalogLoading = true;

  String? _catalogError;

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  LoanProviderStatus _networkStatus =
      LoanProviderStatus.loading;

  String? _lastUpdated;

  // ==========================================================================
  // PRODUCT VALUES
  // ==========================================================================

  String get _productName {
    final String value =
        _ptptnProduct?['name']
                ?.toString()
                .trim() ??
            '';

    return value.isNotEmpty
        ? value
        : 'PTPTN';
  }

  String get _imageUrl {
    return _ptptnProduct?['image_url']
            ?.toString()
            .trim() ??
        '';
  }

  String get _note {
    return _ptptnProduct?['note']
            ?.toString()
            .trim() ??
        '';
  }

  String get _processingTime {
    return _ptptnProduct?['processing_time']
            ?.toString()
            .trim() ??
        '';
  }

  bool get _isActive {
    return _ptptnProduct?['is_active'] ==
        true;
  }

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        _loadPage();
      },
    );
  }

  // ==========================================================================
  // LOAD PAGE
  // ==========================================================================

  Future<void> _loadPage() async {
    await Future.wait([
      _loadCatalog(),
      _refreshNetworkStatus(),
    ]);
  }

  // ==========================================================================
  // LOAD PTPTN FROM IIMMPACT CATALOG
  // ==========================================================================

  Future<void> _loadCatalog() async {
    if (mounted) {
      setState(() {
        _isCatalogLoading = true;
        _catalogError = null;
      });
    }

    try {
      // ======================================================================
      // GET /v2/catalog
      // ======================================================================

      final Map<String, dynamic>
          catalog =
          await IimmpactCatalogService
              .getCatalog();

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Invalid catalog response: products not found.',
        );
      }

      final Map<String, dynamic>
          products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final dynamic ptptnRaw =
          products[
              _ptptnProductCode];

      if (ptptnRaw is! Map) {
        throw Exception(
          'PTPTN product not found in catalog.',
        );
      }

      final Map<String, dynamic>
          product =
          Map<String, dynamic>.from(
        ptptnRaw,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _ptptnProduct =
            product;

        _isCatalogLoading =
            false;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'PTPTN CATALOG LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'name=${product['name']}',
      );
      debugPrint(
        'active=${product['is_active']}',
      );
      debugPrint(
        'processing=${product['processing_time']}',
      );
      debugPrint(
        'image=${product['image_url']}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');
    } on IimmpactCatalogException catch (
        error) {
      debugPrint(
        'PTPTN catalog error: '
        '${error.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _catalogError =
            error.message;

        _isCatalogLoading =
            false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected PTPTN catalog error: '
        '$error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _catalogError =
            error.toString();

        _isCatalogLoading =
            false;
      });
    }
  }

  // ==========================================================================
  // NETWORK STATUS
  // ==========================================================================

  Future<LoanProviderStatus>
      _refreshNetworkStatus() async {
    if (mounted) {
      setState(() {
        _networkStatus =
            LoanProviderStatus
                .loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService
              .getStatus(
        productCode:
            _ptptnProductCode,
      );

      final LoanProviderStatus status =
          result.isHealthy
              ? LoanProviderStatus
                  .healthy
              : LoanProviderStatus
                  .interruption;

      if (mounted) {
        setState(() {
          _networkStatus =
              status;

          _lastUpdated =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'PTPTN network status error: '
        '$error',
      );

      if (mounted) {
        setState(() {
          _networkStatus =
              LoanProviderStatus
                  .unavailable;
        });
      }

      return LoanProviderStatus
          .unavailable;
    }
  }

  // ==========================================================================
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handlePtptnTap() async {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    // ========================================================================
    // WAIT UNTIL CATALOG HAS FINISHED
    //
    // Card is visible immediately,
    // but user cannot continue while catalog is still loading.
    // ========================================================================

    if (_isCatalogLoading) {
      return;
    }

    // ========================================================================
    // CATALOG ERROR
    // ========================================================================

    if (_catalogError != null ||
        _ptptnProduct == null) {
      await _showUnavailableDialog();

      return;
    }

    // ========================================================================
    // RECHECK LATEST NETWORK STATUS
    // ========================================================================

    final status =
        await _refreshNetworkStatus();

    if (!mounted) {
      return;
    }

    // ========================================================================
    // PRODUCT DISABLED
    // ========================================================================

    if (!_isActive) {
      await _showUnavailableDialog();

      return;
    }

    // ========================================================================
    // NETWORK INTERRUPTION
    // ========================================================================

    if (status ==
        LoanProviderStatus
            .interruption) {
      final bool continueAnyway =
          await _showInterruptionWarning();

      if (!continueAnyway) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    // ========================================================================
    // NEXT PAGE
    // ========================================================================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PLOAN4PAGE(
          productCode:
              _ptptnProductCode,

          providerName:
              _productName,

          providerImageUrl:
              _imageUrl,
        ),
      ),
    );
  }

  // ==========================================================================
  // NETWORK INTERRUPTION DIALOG
  // ==========================================================================

  Future<bool>
      _showInterruptionWarning() async {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    final bool? result =
        await showDialog<bool>(
      context: context,
      barrierDismissible:
          false,
      builder: (
        dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,

          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 80,
          ),

          child: Container(
            width: 800,

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
                width: 3,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black
                          .withOpacity(
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
                Container(
                  width: 125,
                  height: 125,

                  decoration:
                      const BoxDecoration(
                    color:
                        Color(
                      0xFFFFF2D9,
                    ),

                    shape:
                        BoxShape.circle,
                  ),

                  child:
                      const Icon(
                    Icons
                        .warning_amber_rounded,

                    color:
                        Color(
                      0xFFD87900,
                    ),

                    size: 78,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

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

                    fontSize: 40,

                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                Text(
                  loc.networkInterruptionMessage(
                    _productName,
                  ),

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF4B4234,
                    ),

                    fontSize: 29,

                    fontWeight:
                        FontWeight
                            .w600,

                    height: 1.4,
                  ),
                ),

                if (_lastUpdated !=
                    null) ...[
                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    '${loc.networkLastUpdated}: '
                    '$_lastUpdated',

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      fontSize:
                          20,

                      color:
                          Color(
                        0xFF758399,
                      ),

                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 35,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          SizedBox(
                        height: 78,

                        child:
                            OutlinedButton(
                          onPressed:
                              () {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );
                          },

                          child:
                              Text(
                            loc.backButton,

                            style:
                                const TextStyle(
                              fontSize:
                                  24,

                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 22,
                    ),

                    Expanded(
                      child:
                          SizedBox(
                        height: 78,

                        child:
                            ElevatedButton(
                          onPressed:
                              () {
                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          },

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF168A50,
                            ),

                            foregroundColor:
                                Colors.white,
                          ),

                          child:
                              Text(
                            loc.continueButton,

                            style:
                                const TextStyle(
                              fontSize:
                                  24,

                              fontWeight:
                                  FontWeight
                                      .w900,
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

    return result ??
        false;
  }

  // ==========================================================================
  // UNAVAILABLE
  // ==========================================================================

  Future<void>
      _showUnavailableDialog() async {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    await showDialog<void>(
      context: context,

      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: Text(
            loc.serviceUnavailableTitle,
          ),

          content: Text(
            loc.ptptnUnavailableMessage,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child: Text(
                loc.close,
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // UI
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================

          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',

              fit:
                  BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment
                          .topCenter,

                  end:
                      Alignment
                          .bottomCenter,

                  colors: [
                    Colors.white
                        .withOpacity(
                      0.02,
                    ),

                    Colors.white
                        .withOpacity(
                      0.12,
                    ),

                    Colors.white
                        .withOpacity(
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
            top: 82,
            left: 65,
            right: 65,

            child:
                _LoanPageHeader(
              title:
                  loc.loanProviderTitle,

              subtitle:
                  loc.loanProviderSubtitle,
            ),
          ),

          // ==================================================================
          // CONTENT
          // ==================================================================

          Positioned(
            top: 410,
            left: 65,
            right: 100,
            bottom: 310,

            child:
                _buildContent(
              loc,
            ),
          ),

          // ==================================================================
          // BACK
          // ==================================================================

          Positioned(
            bottom: 105,
            left: 300,
            right: 300,

            child:
                KioskBackButton(
              onPressed: () {
                Navigator
                    .pushReplacement(
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

          // ==================================================================
          // FOOTER
          // ==================================================================

          Positioned(
            bottom: 25,
            left: 0,
            right: 0,

            child: Center(
              child: Text(
                Data.copyrightText,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF26364A,
                  ),

                  fontSize: 20,

                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CONTENT
  // ==========================================================================

  Widget _buildContent(
    AppLocalizations loc,
  ) {
    // =========================================================================
    // CATALOG ERROR
    //
    // IMPORTANT:
    // Do not treat _ptptnProduct == null as error while catalog is loading.
    // =========================================================================

    if (_catalogError !=
        null) {
      return Center(
        child: Container(
          padding:
              const EdgeInsets.all(
            40,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white,

            borderRadius:
                BorderRadius.circular(
              30,
            ),

            border:
                Border.all(
              color:
                  const Color(
                0xFFE57373,
              ),

              width: 2,
            ),
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              const Icon(
                Icons
                    .cloud_off_rounded,

                size: 85,

                color:
                    Color(
                  0xFFD32F2F,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                loc.catalogUnavailableTitle,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 32,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Text(
                loc.catalogUnavailableMessage,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 23,

                  color:
                      Color(
                    0xFF647187,
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              ElevatedButton.icon(
                onPressed:
                    _loadPage,

                icon:
                    const Icon(
                  Icons
                      .refresh_rounded,
                ),

                label:
                    Text(
                  loc.retryButton,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // =========================================================================
    // PTPTN CARD
    //
    // SHOW IMMEDIATELY
    // =========================================================================

    return Column(
      mainAxisAlignment:
          MainAxisAlignment.start,

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        SizedBox(
          width: 500,

          child:
              _LoanProviderCard(
            imageUrl:
                _imageUrl,

            label:
                _productName,

            note:
                _note,

            processingTime:
                _processingTime,

            // While catalog is loading, keep card visually enabled.
            // Tap is blocked in _handlePtptnTap().
            isActive:
                _isCatalogLoading
                    ? true
                    : _isActive,

            networkStatus:
                _networkStatus,

            networkLabel:
                loc.networkLabel,

            processingLabel:
                loc.processingTimeLabel,

            onPressed:
                _handlePtptnTap,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _LoanPageHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LoanPageHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color accentColor =
        Color(
      0xFF3F51B5,
    );

    return Column(
      children: [
        // ====================================================================
        // SERVICE LABEL
        // ====================================================================

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 14,
          ),

          decoration:
              BoxDecoration(
            color:
                accentColor
                    .withOpacity(
              0.10,
            ),

            borderRadius:
                BorderRadius.circular(
              100,
            ),

            border:
                Border.all(
              color:
                  accentColor
                      .withOpacity(
                0.24,
              ),

              width: 1.5,
            ),
          ),

          child: Row(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              const Icon(
                Icons
                    .school_rounded,

                color:
                    accentColor,

                size: 34,
              ),

              const SizedBox(
                width: 12,
              ),

              Text(
                AppLocalizations
                    .of(
                  context,
                )!
                    .loanServiceLabel
                    .toUpperCase(),

                style:
                    const TextStyle(
                  color:
                      accentColor,

                  fontSize: 22,

                  fontWeight:
                      FontWeight
                          .w900,

                  letterSpacing:
                      1.2,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        // ====================================================================
        // TITLE
        // ====================================================================

        ShaderMask(
          blendMode:
              BlendMode.srcIn,

          shaderCallback:
              (
            bounds,
          ) {
            return const LinearGradient(
              colors: [
                Color(
                  0xFF303F9F,
                ),

                Color(
                  0xFF5C6BC0,
                ),
              ],
            ).createShader(
              bounds,
            );
          },

          child: Text(
            title.toUpperCase(),

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Colors.white,

              fontSize: 52,

              fontWeight:
                  FontWeight
                      .w900,

              height: 1.05,

              letterSpacing:
                  0.4,
            ),
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        // ====================================================================
        // SUBTITLE
        // ====================================================================

        Container(
          constraints:
              const BoxConstraints(
            maxWidth: 850,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 18,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white
                    .withOpacity(
              0.91,
            ),

            borderRadius:
                BorderRadius.circular(
              23,
            ),

            border:
                Border.all(
              color:
                  Colors.black
                      .withOpacity(
                0.17,
              ),

              width: 1.5,
            ),
          ),

          child: Text(
            subtitle,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Color(
                0xFF435166,
              ),

              fontSize: 30,

              fontWeight:
                  FontWeight
                      .w700,

              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PTPTN PROVIDER CARD
// ============================================================================

class _LoanProviderCard
    extends StatefulWidget {
  final String imageUrl;

  final String label;

  final String note;

  final String processingTime;

  final bool isActive;

  final LoanProviderStatus
      networkStatus;

  final String networkLabel;

  final String processingLabel;

  final VoidCallback onPressed;

  const _LoanProviderCard({
    required this.imageUrl,
    required this.label,
    required this.note,
    required this.processingTime,
    required this.isActive,
    required this.networkStatus,
    required this.networkLabel,
    required this.processingLabel,
    required this.onPressed,
  });

  @override
  State<_LoanProviderCard>
      createState() =>
          _LoanProviderCardState();
}

// ============================================================================
// PROVIDER CARD STATE
// ============================================================================

class _LoanProviderCardState
    extends State<
        _LoanProviderCard> {
  bool _isPressed =
      false;

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color accentColor =
        Color(
      0xFF3F51B5,
    );

    const Color lightAccentColor =
        Color(
      0xFFE8EAF6,
    );

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() {
          _isPressed =
              true;
        });
      },

      onTapUp: (_) {
        setState(() {
          _isPressed =
              false;
        });
      },

      onTapCancel: () {
        setState(() {
          _isPressed =
              false;
        });
      },

      onTap:
          widget.onPressed,

      child:
          AnimatedScale(
        scale:
            _isPressed
                ? 0.965
                : 1,

        duration:
            const Duration(
          milliseconds:
              130,
        ),

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds:
                170,
          ),

          height: 520,

          padding:
              const EdgeInsets.all(
            32,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white
                    .withOpacity(
              0.96,
            ),

            borderRadius:
                BorderRadius.circular(
              40,
            ),

            border:
                Border.all(
              color:
                  _isPressed
                      ? accentColor
                      : Colors.black,

              width:
                  _isPressed
                      ? 4
                      : 3,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF19375C,
                ).withOpacity(
                  0.16,
                ),

                blurRadius:
                    30,

                offset:
                    const Offset(
                  0,
                  15,
                ),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==============================================================
              // LOGO + ARROW
              // ==============================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Container(
                    width: 280,
                    height: 190,

                    padding:
                        const EdgeInsets.all(
                      25,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        32,
                      ),

                      border:
                          Border.all(
                        color:
                            accentColor
                                .withOpacity(
                          0.18,
                        ),
                      ),
                    ),

                    // ========================================================
                    // IMAGE
                    //
                    // If catalog has not returned yet:
                    // show small loading spinner.
                    //
                    // After image URL arrives:
                    // load the PTPTN image.
                    // ========================================================

                    child:
                        widget.imageUrl
                                .isEmpty
                            ? const Center(
                                child:
                                    SizedBox(
                                  width:
                                      50,
                                  height:
                                      50,

                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        4,

                                    color:
                                        accentColor,
                                  ),
                                ),
                              )
                            : Image.network(
                                widget.imageUrl,

                                fit:
                                    BoxFit
                                        .contain,

                                loadingBuilder:
                                    (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress ==
                                      null) {
                                    return child;
                                  }

                                  return const Center(
                                    child:
                                        SizedBox(
                                      width:
                                          50,
                                      height:
                                          50,

                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            4,

                                        color:
                                            accentColor,
                                      ),
                                    ),
                                  );
                                },

                                errorBuilder:
                                    (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const Icon(
                                    Icons
                                        .school_rounded,

                                    size:
                                        95,

                                    color:
                                        accentColor,
                                  );
                                },
                              ),
                  ),

                  Container(
                    width: 62,
                    height: 62,

                    decoration:
                        const BoxDecoration(
                      color:
                          accentColor,

                      shape:
                          BoxShape.circle,
                    ),

                    child:
                        const Icon(
                      Icons
                          .arrow_forward_rounded,

                      color:
                          Colors.white,

                      size: 34,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ==============================================================
              // PRODUCT NAME
              // ==============================================================

              Text(
                widget.label
                    .toUpperCase(),

                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF15253A,
                  ),

                  fontSize: 42,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==============================================================
              // NETWORK STATUS
              // ==============================================================

              _LoanStatusBadge(
                status:
                    widget
                        .networkStatus,

                networkLabel:
                    widget
                        .networkLabel,
              ),

              // ==============================================================
              // PROCESSING TIME
              // ==============================================================

              if (widget
                  .processingTime
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 16,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .schedule_rounded,

                      color:
                          Color(
                        0xFF647187,
                      ),

                      size: 25,
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Text(
                      '${widget.processingLabel}: '
                      '${_formatProcessingTime(
                        widget.processingTime,
                      )}',

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF647187,
                        ),

                        fontSize: 20,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(
                height: 22,
              ),

              // ==============================================================
              // DECORATIVE LINE
              // ==============================================================

              Row(
                children: [
                  Container(
                    width: 60,
                    height: 7,

                    decoration:
                        BoxDecoration(
                      color:
                          accentColor,

                      borderRadius:
                          BorderRadius
                              .circular(
                        50,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Container(
                    width: 13,
                    height: 7,

                    decoration:
                        BoxDecoration(
                      color:
                          lightAccentColor,

                      borderRadius:
                          BorderRadius
                              .circular(
                        50,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // FORMAT PROCESSING TIME
  // ==========================================================================

  static String _formatProcessingTime(
    String value,
  ) {
    switch (value) {
      case 'instant':
        return 'Instant';

      case '24_hours':
        return '24 Hours';

      case '3_days':
        return '3 Days';

      default:
        return value.replaceAll(
          '_',
          ' ',
        );
    }
  }
}

// ============================================================================
// NETWORK STATUS
// ============================================================================

class _LoanStatusBadge
    extends StatelessWidget {
  final LoanProviderStatus status;

  final String networkLabel;

  const _LoanStatusBadge({
    required this.status,
    required this.networkLabel,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    late String text;

    late Color background;

    late Color foreground;

    late IconData icon;

    switch (status) {
      // ======================================================================
      // CHECKING
      // ======================================================================

      case LoanProviderStatus.loading:
        text =
            loc.networkStatusChecking;

        background =
            const Color(
          0xFFF0F4F8,
        );

        foreground =
            const Color(
          0xFF536272,
        );

        icon =
            Icons.sync_rounded;

        break;

      // ======================================================================
      // GOOD
      // ======================================================================

      case LoanProviderStatus.healthy:
        text =
            loc.networkStatusGood;

        background =
            const Color(
          0xFFE2F8EC,
        );

        foreground =
            const Color(
          0xFF08783E,
        );

        icon =
            Icons.check_circle_rounded;

        break;

      // ======================================================================
      // INTERRUPTION
      // ======================================================================

      case LoanProviderStatus.interruption:
        text =
            loc.networkStatusSlow;

        background =
            const Color(
          0xFFFFF0D7,
        );

        foreground =
            const Color(
          0xFFB75B00,
        );

        icon =
            Icons.warning_amber_rounded;

        break;

      // ======================================================================
      // UNKNOWN
      // ======================================================================

      case LoanProviderStatus.unavailable:
        text =
            loc.networkStatusUnknown;

        background =
            const Color(
          0xFFF1F1F1,
        );

        foreground =
            const Color(
          0xFF555555,
        );

        icon =
            Icons.help_outline_rounded;

        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 13,
      ),

      decoration:
          BoxDecoration(
        color:
            background,

        borderRadius:
            BorderRadius.circular(
          30,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          // ==================================================================
          // ONLY NETWORK CHECKING HAS SPINNER
          // ==================================================================

          if (status ==
              LoanProviderStatus
                  .loading)
            SizedBox(
              width: 24,
              height: 24,

              child:
                  CircularProgressIndicator(
                strokeWidth: 3,

                color:
                    foreground,
              ),
            )
          else
            Icon(
              icon,

              color:
                  foreground,

              size: 27,
            ),

          const SizedBox(
            width: 9,
          ),

          Text(
            '$networkLabel: $text',

            style:
                TextStyle(
              color:
                  foreground,

              fontSize: 19,

              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),
        ],
      ),
    );
  }
}