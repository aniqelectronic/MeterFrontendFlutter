import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';

import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';

import 'package:frontend_v1/pages/bil/loan/ploan4.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/widgets/modern_provider_card.dart';

// ============================================================================
// LOAN PROVIDER PAGE
//
// CURRENT PRODUCT:
//
// PTPTN
//
// Product information comes from:
//
// GET /v2/catalog
//
// The card design comes from:
//
// lib/widgets/modern_provider_card.dart
// ============================================================================

class PLOAN3PAGE extends StatefulWidget {
  const PLOAN3PAGE({
    super.key,
  });

  @override
  State<PLOAN3PAGE> createState() =>
      _PLOAN3PAGEState();
}

// ============================================================================
// STATE
// ============================================================================

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
  //
  // Uses shared status from:
  //
  // modern_provider_card.dart
  // ==========================================================================

  ProviderNetworkStatus _networkStatus =
      ProviderNetworkStatus.loading;

  String? _lastUpdated;

  // ==========================================================================
  // PRODUCT DATA
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
  // COLORS
  // ==========================================================================

  static const Color _accentColor =
      Color(
    0xFF3F51B5,
  );

  static const Color _lightAccentColor =
      Color(
    0xFFE8EAF6,
  );

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
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
  // LOAD PTPTN FROM /v2/catalog
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
      // CATALOG
      // ======================================================================

      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      // ======================================================================
      // PRODUCTS
      // ======================================================================

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Invalid catalog response: '
          'products not found.',
        );
      }

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      // ======================================================================
      // PTPTN
      // ======================================================================

      final dynamic ptptnRaw =
          products[
            _ptptnProductCode
          ];

      if (ptptnRaw is! Map) {
        throw Exception(
          'PTPTN product not found in catalog.',
        );
      }

      final Map<String, dynamic> product =
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

      // ======================================================================
      // DEBUG
      // ======================================================================

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
        'note=${product['note']}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');
    }

    // =========================================================================
    // CATALOG SERVICE ERROR
    // =========================================================================

    on IimmpactCatalogException catch (error) {
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
    }

    // =========================================================================
    // OTHER ERROR
    // =========================================================================

    catch (error, stackTrace) {
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

  Future<ProviderNetworkStatus>
      _refreshNetworkStatus() async {
    if (mounted) {
      setState(() {
        _networkStatus =
            ProviderNetworkStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode:
            _ptptnProductCode,
      );

      final ProviderNetworkStatus status =
          result.isHealthy
              ? ProviderNetworkStatus.healthy
              : ProviderNetworkStatus.interruption;

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
              ProviderNetworkStatus.unavailable;
        });
      }

      return ProviderNetworkStatus.unavailable;
    }
  }

  // ==========================================================================
  // PROVIDER TAP
  // ==========================================================================

  Future<void> _handlePtptnTap() async {
    // ========================================================================
    // CATALOG STILL LOADING
    //
    // Card can already be displayed, but do not continue yet.
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
    // RECHECK NETWORK
    // ========================================================================

    final ProviderNetworkStatus status =
        await _refreshNetworkStatus();

    if (!mounted) {
      return;
    }

    // ========================================================================
    // INACTIVE PRODUCT
    // ========================================================================

    if (!_isActive) {
      await _showUnavailableDialog();

      return;
    }

    // ========================================================================
    // NETWORK INTERRUPTION
    // ========================================================================

    if (status ==
        ProviderNetworkStatus.interruption) {
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
    // NETWORK UNAVAILABLE
    // ========================================================================

    if (status ==
        ProviderNetworkStatus.unavailable) {
      await _showUnavailableDialog();

      return;
    }

    if (!mounted) {
      return;
    }

    // ========================================================================
    // NEXT PAGE
    //
    // ORIGINAL PTPTN FLOW KEPT.
    // ========================================================================

    await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (_) =>
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
  // INTERRUPTION WARNING
  // ==========================================================================

  Future<bool> _showInterruptionWarning() async {
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

          child:
              Container(
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

            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                // ============================================================
                // WARNING
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

                  child:
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

                if (_lastUpdated != null) ...[
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
                        child:
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
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(
                  height:
                      35,
                ),

                // ============================================================
                // ACTIONS
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
                          onPressed:
                              () {
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
                          onPressed:
                              () {
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
  // UNAVAILABLE DIALOG
  // ==========================================================================

  Future<void> _showUnavailableDialog() async {
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
            loc.serviceUnavailableTitle,
          ),

          content:
              Text(
            loc.ptptnUnavailableMessage,
          ),

          actions: [
            TextButton(
              onPressed:
                  () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child:
                  Text(
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
                      0.12,
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
                82,

            left:
                65,

            right:
                65,

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
            top:
                410,

            left:
                65,

            right:
                65,

            bottom:
                310,

            child:
                _buildContent(
              loc,
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
              onPressed:
                  () {
                Navigator.pushReplacement(
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
            bottom:
                25,

            left:
                0,

            right:
                0,

            child:
                Center(
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
    // ========================================================================
    // CATALOG ERROR
    // ========================================================================

    if (_catalogError != null) {
      return Center(
        child:
            Container(
          width:
              680,

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

              width:
                  2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.10,
                ),

                blurRadius:
                    25,

                offset:
                    const Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),

          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width:
                    110,

                height:
                    110,

                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFFFEBEE,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    const Icon(
                  Icons.cloud_off_rounded,

                  size:
                      65,

                  color:
                      Color(
                    0xFFD32F2F,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    22,
              ),

              Text(
                loc.catalogUnavailableTitle,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize:
                      32,

                  color:
                      Color(
                    0xFF17283E,
                  ),

                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height:
                    15,
              ),

              Text(
                loc.catalogUnavailableMessage,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize:
                      23,

                  color:
                      Color(
                    0xFF647187,
                  ),

                  fontWeight:
                      FontWeight.w600,

                  height:
                      1.35,
                ),
              ),

              const SizedBox(
                height:
                    25,
              ),

              SizedBox(
                height:
                    72,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _loadPage,

                  icon:
                      const Icon(
                    Icons.refresh_rounded,

                    size:
                        28,
                  ),

                  label:
                      Text(
                    loc.retryButton,

                    style:
                        const TextStyle(
                      fontSize:
                          23,

                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        _accentColor,

                    foregroundColor:
                        Colors.white,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          35,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ========================================================================
    // PTPTN CARD
    //
    // Uses shared ModernProviderCard.
    // ========================================================================

    return Align(
      alignment:
          Alignment.topLeft,

      child:
          SizedBox(
        width:
            450,

        height:
            510,

        child:
            ModernProviderCard(
          // ==================================================================
          // CATALOG IMAGE
          // ==================================================================

          imageUrl:
              _imageUrl,

          // ==================================================================
          // PRODUCT NAME
          // ==================================================================

          label:
              _productName,

          // ==================================================================
          // CARD COLORS
          // ==================================================================

          accentColor:
              _accentColor,

          lightAccentColor:
              _lightAccentColor,

          // ==================================================================
          // STATUS
          //
          // If PTPTN is inactive after catalog finishes, visually display it
          // as unavailable too.
          //
          // While catalog is loading, continue showing network state.
          // ==================================================================

          networkStatus:
              !_isCatalogLoading &&
                      _ptptnProduct != null &&
                      !_isActive
                  ? ProviderNetworkStatus.unavailable
                  : _networkStatus,

          networkLabel:
              loc.networkLabel,

          // ==================================================================
          // PROCESSING TIME
          //
          // Uses the common formatter in ModernProviderCard.
          // ==================================================================

          processingTime:
              _processingTime,

          processingLabel:
              loc.processingTimeLabel,

          // ==================================================================
          // FALLBACK
          // ==================================================================

          fallbackIcon:
              Icons.school_rounded,

          // ==================================================================
          // TAP
          // ==================================================================

          onPressed:
              _handlePtptnTap,
        ),
      ),
    );
  }
}

// ============================================================================
// LOAN HEADER
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

    const Color darkAccent =
        Color(
      0xFF303F9F,
    );

    final loc =
        AppLocalizations.of(context)!;

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
          // ICON
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
                  darkAccent,

                  Color(
                    0xFF5C6BC0,
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
              Icons.school_rounded,

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
                // SERVICE LABEL
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
                      0xFFEDEFFF,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      100,
                    ),
                  ),

                  child:
                      Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      const Icon(
                        Icons.school_rounded,

                        size:
                            20,

                        color:
                            accentColor,
                      ),

                      const SizedBox(
                        width:
                            8,
                      ),

                      Flexible(
                        child:
                            Text(
                          loc.loanServiceLabel
                              .toUpperCase(),

                          maxLines:
                              1,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
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
                  subtitle,

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
                        30,

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
                  darkAccent,

                  Color(
                    0xFF5C6BC0,
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