import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';
import 'package:frontend_v1/services/iimmpact_network_status_service.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

enum BillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

/// =======================================================
/// WATER BILLER MODEL
/// =======================================================
class WaterBiller {
  final String productCode;
  final String billerName;
  final String imagePath;

  const WaterBiller({
    required this.productCode,
    required this.billerName,
    required this.imagePath,
  });
}

/// =======================================================
/// WATER BILL PROVIDER PAGE
/// =======================================================
class PWATERBILL3PAGE extends StatefulWidget {
  const PWATERBILL3PAGE({
    super.key,
  });

  @override
  State<PWATERBILL3PAGE> createState() =>
      _PWATERBILL3PAGEState();
}

class _PWATERBILL3PAGEState
    extends State<PWATERBILL3PAGE> {
  final ScrollController _scrollController =
      ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = true;

  /// Change these image paths after adding your logos.
  static const List<WaterBiller> _waterBillers = [
    WaterBiller(
      productCode: 'AKSB',
      billerName: 'Air Kelantan',
      imagePath: 'lib/images/water/aksb.png',
    ),
    WaterBiller(
      productCode: 'IW',
      billerName: 'Indah Water Konsortium',
      imagePath: 'lib/images/water/iw.png',
    ),
    WaterBiller(
      productCode: 'JBA',
      billerName: 'Jabatan Bekalan Air Labuan',
      imagePath: 'lib/images/water/jba.png',
    ),
    WaterBiller(
      productCode: 'KWB',
      billerName: 'Kuching Water Board',
      imagePath: 'lib/images/water/kwb.png',
    ),
    WaterBiller(
      productCode: 'LAKU',
      billerName: 'Lembaga Air Kuching Utara',
      imagePath: 'lib/images/water/laku.png',
    ),
    WaterBiller(
      productCode: 'PAIP',
      billerName: 'Pengurusan Air Pahang Berhad',
      imagePath: 'lib/images/water/paip.png',
    ),
    WaterBiller(
      productCode: 'PWB',
      billerName: 'Lembaga Air Perak',
      imagePath: 'lib/images/water/pwb.png',
    ),
    WaterBiller(
      productCode: 'SADA',
      billerName: 'Syarikat Air Darul Aman',
      imagePath: 'lib/images/water/sada.png',
    ),
    WaterBiller(
      productCode: 'SAINS',
      billerName: 'Syarikat Air Negeri Sembilan',
      imagePath: 'lib/images/water/sains.png',
    ),
    WaterBiller(
      productCode: 'SAJ',
      billerName: 'Ranhill SAJ',
      imagePath: 'lib/images/water/saj.png',
    ),
    WaterBiller(
      productCode: 'SAMB',
      billerName: 'Syarikat Air Melaka Berhad',
      imagePath: 'lib/images/water/samb.png',
    ),
    WaterBiller(
      productCode: 'SAP',
      billerName: 'Syarikat Air Perlis',
      imagePath: 'lib/images/water/sap.png',
    ),
    WaterBiller(
      productCode: 'SATU',
      billerName: 'Syarikat Air Terengganu',
      imagePath: 'lib/images/water/satu.png',
    ),
    WaterBiller(
      productCode: 'SWB',
      billerName: 'Sibu Water Board',
      imagePath: 'lib/images/water/swb.png',
    ),
    WaterBiller(
      productCode: 'SYABAS',
      billerName: 'Air Selangor',
      imagePath: 'lib/images/water/syabas.png',
    ),
  ];

  late final Map<String, BillerStatus>
      _billerStatuses = {
    for (final biller in _waterBillers)
      biller.productCode: BillerStatus.loading,
  };

  final Map<String, String?> _lastUpdated = {};

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadInitialNetworkStatuses();
      },
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final maxScroll =
        _scrollController.position.maxScrollExtent;

    final currentScroll =
        _scrollController.offset;

    if (!mounted) {
      return;
    }

    final newShowScrollUp =
        currentScroll > 10;

    final newShowScrollDown =
        currentScroll < maxScroll - 10;

    if (showScrollUp != newShowScrollUp ||
        showScrollDown != newShowScrollDown) {
      setState(() {
        showScrollUp = newShowScrollUp;
        showScrollDown = newShowScrollDown;
      });
    }
  }

  Future<void>
      _loadInitialNetworkStatuses() async {
    await Future.wait(
      _waterBillers.map(
        (biller) => _refreshNetworkStatus(
          biller.productCode,
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _handleScroll();
      },
    );
  }

  Future<BillerStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            BillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService
              .getStatus(
        productCode: productCode,
      );

      final status = result.isHealthy
          ? BillerStatus.healthy
          : BillerStatus.interruption;

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
        'Water network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              BillerStatus.unavailable;
        });
      }

      return BillerStatus.unavailable;
    }
  }

  Future<bool> _showInterruptionWarning({
    required String billerName,
    required String productCode,
  }) async {
    final loc =
        AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(35),
          ),
          child: Container(
            width: 800,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(35),
              border: Border.all(
                color: Colors.orange,
                width: 4,
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color:
                        Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 75,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  loc.networkInterruptionTitle,
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  loc.networkInterruptionMessage(
                    billerName,
                  ),
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    fontSize: 35,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                if (_lastUpdated[
                        productCode] !=
                    null) ...[
                  const SizedBox(height: 20),
                  Text(
                    '${loc.networkLastUpdated}: '
                    '${_lastUpdated[productCode]}',
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black54,
                    ),
                  ),
                ],

                const SizedBox(height: 35),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 75,
                        child:
                            OutlinedButton(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );
                          },
                          style: OutlinedButton
                              .styleFrom(
                            backgroundColor:
                                const Color(
                              0xFFF80202,
                            ),
                            foregroundColor:
                                Colors.white,
                            side:
                                const BorderSide(
                              color: Color(
                                0xFFB9C7D8,
                              ),
                              width: 2,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                22,
                              ),
                            ),
                          ),
                          child: Text(
                            loc.backButton,
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: SizedBox(
                        height: 75,
                        child:
                            ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          },
                          style: ElevatedButton
                              .styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF2E7D32,
                            ),
                            foregroundColor:
                                Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                22,
                              ),
                            ),
                          ),
                          child: Text(
                            loc.continueButton,
                            style:
                                const TextStyle(
                              fontSize: 24,
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

    return result ?? false;
  }

  Future<void> _handleBillerTap({
    required WaterBiller biller,
  }) async {
    final status =
        await _refreshNetworkStatus(
      biller.productCode,
    );

    if (!mounted) {
      return;
    }

    if (status ==
        BillerStatus.interruption) {
      final shouldContinue =
          await _showInterruptionWarning(
        billerName: biller.billerName,
        productCode:
            biller.productCode,
      );

      if (!shouldContinue) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    final loc =
        AppLocalizations.of(context)!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P4BILPAGE(
          title: loc.waterAccountTitle,
          hint: loc.waterAccountHint,
          productCode:
              biller.productCode,
          billerName:
              biller.billerName,
          serviceType: BillServiceType.water,
        ),
      ),
    );
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) {
      return;
    }

    final destination =
        (_scrollController.offset - 600)
            .clamp(
      0.0,
      _scrollController
          .position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration:
          const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    final destination =
        (_scrollController.offset + 600)
            .clamp(
      0.0,
      _scrollController
          .position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration:
          const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      _handleScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // ================= BACKGROUND =================
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'lib/images/pnew.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ================= TITLE =================
          Positioned(
            top: 100,
            left: 60,
            right: 60,
            child: Text(
              loc.waterBillProviderTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(
                  0xFF0359D2,
                ),
                fontSize: 65,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // ================= SUBTITLE =================
          Positioned(
            top: 220,
            left: 60,
            right: 60,
            child: Text(
              loc.pbil3Subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(
                  0xFF3E3E3E,
                ),
                fontSize: 36,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // ================= GRID =================
          Positioned(
            top: 350,
            left: 55,
            right: 55,
            bottom: 330,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                18,
                20,
                18,
                20,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.25,
                ),
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: Scrollbar(
                controller:
                    _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 12,
                radius:
                    const Radius.circular(20),
                child: GridView.builder(
                  controller:
                      _scrollController,
                  padding:
                      const EdgeInsets.only(
                    right: 20,
                    bottom: 30,
                  ),
                  physics:
                      const BouncingScrollPhysics(),
                  itemCount:
                      _waterBillers.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 35,
                    mainAxisSpacing: 45,
                    childAspectRatio: 0.93,
                  ),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final biller =
                        _waterBillers[
                      index
                    ];

                    return _WaterBillerButton(
                      biller: biller,
                      networkStatus:
                          _billerStatuses[
                            biller.productCode
                          ] ??
                          BillerStatus.loading,
                      networkLabel:
                          loc.networkLabel,
                      onPressed: () {
                        _handleBillerTap(
                          biller: biller,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // ================= SCROLL UP =================
          if (showScrollUp)
            Positioned(
              right: 25,
              top: 370,
              child: _ScrollIndicatorButton(
                icon: Icons
                    .keyboard_arrow_up_rounded,
                label: loc.scrollup,
                onPressed: _scrollUp,
              ),
            ),

          // ================= SCROLL DOWN =================
          if (showScrollDown)
            Positioned(
              right: 25,
              bottom: 350,
              child: _ScrollIndicatorButton(
                icon: Icons
                    .keyboard_arrow_down_rounded,
                label: loc.scrolldown,
                onPressed: _scrollDown,
                iconBelowText: true,
              ),
            ),

          // ================= BACK BUTTON =================
          Positioned(
            bottom: 100,
            left: 300,
            right: 300,
            child: KioskBackButton(
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

          // ================= FOOTER =================
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              Data.copyrightText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
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

/// =======================================================
/// WATER PROVIDER BUTTON
/// =======================================================
class _WaterBillerButton
    extends StatefulWidget {
  final WaterBiller biller;
  final BillerStatus networkStatus;
  final String networkLabel;
  final VoidCallback onPressed;

  const _WaterBillerButton({
    required this.biller,
    required this.networkStatus,
    required this.networkLabel,
    required this.onPressed,
  });

  @override
  State<_WaterBillerButton> createState() =>
      _WaterBillerButtonState();
}

class _WaterBillerButtonState
    extends State<_WaterBillerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale:
            _isPressed ? 0.96 : 1.0,
        duration: const Duration(
          milliseconds: 100,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(38),
            border: Border.all(
              color: Colors.black,
              width: 4,
            ),
            gradient:
                const LinearGradient(
              begin: Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                Color(0xFFF4F8FF),
                Color(0xFFCCD9F2),
              ],
            ),
            boxShadow: _isPressed
                ? []
                : const [
                    BoxShadow(
                      color: Colors.black,
                      offset:
                          Offset(0, 10),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // ================= LOGO =================
              Container(
                width: 190,
                height: 190,
                padding:
                    const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.10),
                      offset:
                          const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Image.asset(
                  widget.biller.imagePath,
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 22),

              // ================= NAME =================
              SizedBox(
                height: 105,
                child: Center(
                  child: Text(
                    widget
                        .biller.billerName
                        .toUpperCase(),
                    textAlign:
                        TextAlign.center,
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 29,
                      height: 1.15,
                      fontWeight:
                          FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _NetworkStatusBadge(
                status:
                    widget.networkStatus,
                label:
                    widget.networkLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// NETWORK STATUS BADGE
/// =======================================================
class _NetworkStatusBadge
    extends StatelessWidget {
  final BillerStatus status;
  final String label;

  const _NetworkStatusBadge({
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context)!;

    late final String statusText;
    late final Color backgroundColor;
    late final Color foregroundColor;
    late final IconData icon;

    switch (status) {
      case BillerStatus.loading:
        statusText =
            loc.networkStatusChecking;
        backgroundColor =
            const Color(0xFFE8EEF6);
        foregroundColor =
            const Color(0xFF455A64);
        icon = Icons.sync_rounded;
        break;

      case BillerStatus.healthy:
        statusText =
            loc.networkStatusGood;
        backgroundColor =
            const Color(0xFFDDF7E8);
        foregroundColor =
            const Color(0xFF08783E);
        icon =
            Icons.check_circle_rounded;
        break;

      case BillerStatus.interruption:
        statusText =
            loc.networkStatusSlow;
        backgroundColor =
            const Color(0xFFFFE8C2);
        foregroundColor =
            const Color(0xFFB75B00);
        icon =
            Icons.warning_amber_rounded;
        break;

      case BillerStatus.unavailable:
        statusText =
            loc.networkStatusUnknown;
        backgroundColor =
            const Color(0xFFE8E8E8);
        foregroundColor =
            const Color(0xFF555555);
        icon =
            Icons.help_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: foregroundColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          if (status ==
              BillerStatus.loading)
            SizedBox(
              width: 21,
              height: 21,
              child:
                  CircularProgressIndicator(
                strokeWidth: 3,
                color: foregroundColor,
              ),
            )
          else
            Icon(
              icon,
              size: 24,
              color: foregroundColor,
            ),

          const SizedBox(width: 9),

          Flexible(
            child: Text(
              '$label: $statusText',
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 16,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// SCROLL INDICATOR
/// =======================================================
class _ScrollIndicatorButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool iconBelowText;

  const _ScrollIndicatorButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconBelowText = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 58,
      color: Colors.black,
    );

    final textWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.black,
      ),
    );

    return Material(
      color: Colors.white.withOpacity(0.90),
      borderRadius:
          BorderRadius.circular(22),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius:
            BorderRadius.circular(22),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: iconBelowText
                ? [
                    textWidget,
                    iconWidget,
                  ]
                : [
                    iconWidget,
                    textWidget,
                  ],
          ),
        ),
      ),
    );
  }
}