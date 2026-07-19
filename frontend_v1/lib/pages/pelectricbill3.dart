import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/p4bil.dart';
import 'package:frontend_v1/pages/pbil3.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/services/iimmpact_network_status_service.dart';

enum BillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

class PELECTRICBILL3PAGE extends StatefulWidget {
  const PELECTRICBILL3PAGE({super.key});

  @override
  State<PELECTRICBILL3PAGE> createState() =>
      _PELECTRICBILL3PAGEState();
}

  class _PELECTRICBILL3PAGEState
      extends State<PELECTRICBILL3PAGE> {

  final Map<String, BillerStatus> _billerStatuses = {
    'TNB': BillerStatus.loading,
    'SESCO': BillerStatus.loading,
    'SESB': BillerStatus.loading,
    'NUR': BillerStatus.loading,
    'FP': BillerStatus.loading,
  };

  final Map<String, String?> _lastUpdated = {};

  final ScrollController _scrollController = ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialNetworkStatuses();
      _handleScroll();
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || !mounted) {
      return;
    }

    final maxScroll =
        _scrollController.position.maxScrollExtent;

    final current =
        _scrollController.offset;

    final newShowScrollUp =
        current > 10;

    final newShowScrollDown =
        current < maxScroll - 10;

    if (showScrollUp != newShowScrollUp ||
        showScrollDown != newShowScrollDown) {
      setState(() {
        showScrollUp = newShowScrollUp;
        showScrollDown = newShowScrollDown;
      });
    }
  }

  Future<void> _loadInitialNetworkStatuses() async {
    await Future.wait([
      _refreshNetworkStatus('TNB'),
      _refreshNetworkStatus('SESCO'),
      _refreshNetworkStatus('SESB'),
      _refreshNetworkStatus('NUR'),
      _refreshNetworkStatus('FP'),
    ]);
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
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final status = result.isHealthy
          ? BillerStatus.healthy
          : BillerStatus.interruption;

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] = status;
          _lastUpdated[productCode] = result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Network status error for $productCode: $error',
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
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: Colors.orange,
              width: 4,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
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
                AppLocalizations.of(context)!
                    .networkInterruptionTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 25),

              Text(
                AppLocalizations.of(context)!
                    .networkInterruptionMessage(
                  billerName,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 35,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (_lastUpdated[productCode] != null) ...[
                const SizedBox(height: 20),
                Text(
                  '${AppLocalizations.of(context)!.networkLastUpdated}: '
                  '${_lastUpdated[productCode]}',
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
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 248, 2, 2),
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFB9C7D8),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .backButton,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: SizedBox(
                      height: 75,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .continueButton,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
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
  required String productCode,
  required String billerName,
  required VoidCallback navigate,
}) async {
  final status = await _refreshNetworkStatus(
    productCode,
  );

  if (!mounted) return;

  if (status == BillerStatus.interruption) {
    final shouldContinue =
        await _showInterruptionWarning(
      billerName: billerName,
      productCode: productCode,
    );

    if (!shouldContinue) {
      return;
    }
  }

  if (!mounted) return;

  navigate();
}

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
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

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
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================= BACKGROUND =================
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ================= TITLE =================
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.pbilelectric3Title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ================= SUBTITLE =================
          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.pbil3Subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(255, 62, 62, 62),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ================= SCROLLABLE AREA =================
          Positioned(
            top: 430,
            left: 0,
            right: 0,
            bottom: 400,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 12,
              radius: const Radius.circular(20),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  right: 20,
                  bottom: 30,
                ),
                child: SizedBox(
                    height: 1200,
                    child: Stack(
                      children: [
                    // ================= TNB BUTTON =================
                    Positioned(
                      top: 50,
                      left: -500,
                      right: 0,
                      child: _KioskMainButton(
                        width: 400,
                        height: 500,
                        imagePath: "lib/images/electric/tnb.png",
                        label:
                            AppLocalizations.of(context)!
                                .tnbButton,
                        networkStatus:
                            _billerStatuses['TNB'] ??
                                BillerStatus.loading,
                        networkLabel: AppLocalizations.of(context)!.networkLabel,                                               
                        onPressed: () {
                          _handleBillerTap(
                            productCode: 'TNB',
                            billerName: 'TENAGA NASIONAL BERHAD',
                            navigate: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => P4BILPAGE(
                                    title: AppLocalizations.of(context)!
                                        .electricAccountTitle,
                                    hint: AppLocalizations.of(context)!
                                        .electricAccountHint,
                                    productCode: 'TNB',
                                    billerName: 'TENAGA NASIONAL BERHAD',
                                    serviceType: BillServiceType.electric,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        comingSoon: false,
                      ),
                    ),

                    // ================= SARAWAK ENERGY BIL =================
                    Positioned(
                      top: 50,
                      left: 0,
                      right: -500,
                      child: _KioskMainButton(
                        width: 400,
                        height: 500,
                        imagePath:
                            "lib/images/electric/sarawakenergy.png",
                        label:
                            AppLocalizations.of(context)!
                                .sarawakenergyButton,
                        networkStatus:
                            _billerStatuses['FP'] ??
                                BillerStatus.loading,
                        networkLabel: AppLocalizations.of(context)!.networkLabel,
                        onPressed: () {
                          _handleBillerTap(
                            productCode: 'FP',
                            billerName: 'Sarawak ENERGY',
                            navigate: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => P4BILPAGE(
                                    title: AppLocalizations.of(context)!
                                        .electricAccountTitle,
                                    hint: AppLocalizations.of(context)!
                                        .electricAccountHint,
                                    productCode: 'SESCO',
                                    billerName: 'Sarawak ENERGY',
                                    serviceType: BillServiceType.electric,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        comingSoon: false,
                      ),
                    ),

                  // ================= Sabah Electricity BIl =================
                    
                    Positioned(
                      top: 650,
                      left: -500,
                      right: 0,
                      child: _KioskMainButton(
                        width: 400,
                        height: 500,
                        imagePath: "lib/images/electric/sabahelectricity.png",
                        label: AppLocalizations.of(context)!
                                .sabahelectricityButton,
                        networkStatus:
                            _billerStatuses['SESB'] ??
                                BillerStatus.loading,
                        networkLabel: AppLocalizations.of(context)!.networkLabel,
                        onPressed: () {
                          _handleBillerTap(
                            productCode: 'SESB',
                            billerName: 'Sabah ELECTRICITY',
                            navigate: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => P4BILPAGE(
                                    title: AppLocalizations.of(context)!
                                        .electricAccountTitle,
                                    hint: AppLocalizations.of(context)!
                                        .electricAccountHint,
                                    productCode: 'SESB',
                                    billerName: 'Sabah ELECTRICITY',
                                    serviceType: BillServiceType.electric,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        comingSoon: false,
                      ),
                    ),

                    // ================= NUR POWER BILL =================

                    Positioned(
                      top: 650,
                      left: 0,
                      right: -500,
                      child: _KioskMainButton(
                        width: 400,
                        height: 500,
                        imagePath: "lib/images/electric/nurpower.png",
                        label: AppLocalizations.of(context)!.nurpowerButton,   
                          networkStatus:
                            _billerStatuses['NUR'] ??
                                BillerStatus.loading,
                        networkLabel: AppLocalizations.of(context)!.networkLabel,
                        onPressed: () {
                          _handleBillerTap(
                            productCode: 'NUR',
                            billerName: 'NUR POWER',
                            navigate: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => P4BILPAGE(
                                    title: AppLocalizations.of(context)!
                                        .electricAccountTitle,
                                    hint: AppLocalizations.of(context)!
                                        .electricAccountHint,
                                    productCode: 'NUR',
                                    billerName: 'NUR POWER', serviceType: BillServiceType.electric,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        comingSoon: false,
                      ),
                    ),
                    
                  ],
                ),
              ),
              ),
            ),
          ),

          // ================= SCROLL UP INDICATOR =================
        if (showScrollUp)
          Positioned(
            right: 25,
            top: 370,
            child: _ScrollIndicatorButton(
              icon: Icons.keyboard_arrow_up_rounded,
              label: AppLocalizations.of(context)!.scrollup,
              onPressed: _scrollUp,
            ),
          ),

          // ================= SCROLL DOWN INDICATOR =================
        if (showScrollDown)
          Positioned(
            right: 25,
            bottom: 350,
            child: _ScrollIndicatorButton(
              icon: Icons.keyboard_arrow_down_rounded,
              label: AppLocalizations.of(context)!.scrolldown,
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
                    builder: (_) => const PBIL3PAGE(),
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
            child: Center(
              child: Text(
                Data.copyrightText,
                style: const TextStyle(
                  color: Colors.black,
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

/// =======================================================
/// REUSABLE KIOSK BUTTON
/// =======================================================
class _KioskMainButton extends StatefulWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool comingSoon;

  final BillerStatus networkStatus;
  final String networkLabel;

  const _KioskMainButton({
    super.key,
    this.icon,
    this.imagePath,
    required this.label,
    required this.onPressed,
    required this.networkStatus,
    required this.networkLabel,
    this.width = 200,
    this.height = 150,
    this.comingSoon = false,
  });

  @override
  State<_KioskMainButton> createState() => _KioskMainButtonState();
}

class _KioskMainButtonState extends State<_KioskMainButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.comingSoon;

    return Center(
      child: GestureDetector(
        onTapDown: (_) => isEnabled ? setState(() => _isPressed = true) : null,
        onTapUp: (_) => isEnabled ? setState(() => _isPressed = false) : null,
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // MAIN BUTTON BODY
              Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(
                    color: widget.comingSoon ? Colors.grey : Colors.black,
                    width: 4,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.comingSoon
                        ? [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)]
                        : [const Color(0xFFF4F8FF), const Color(0xFFCCD9F2)],
                  ),
                  boxShadow: _isPressed || widget.comingSoon
                      ? []
                      : [
                          const BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 12),
                            blurRadius: 0,
                          ),
                        ],
                ),
                child: Opacity(
                  opacity: widget.comingSoon ? 0.5 : 1.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ICON POD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: widget.icon != null
                            ? Icon(widget.icon, size: 140, color: Colors.black)
                            : Image.asset(widget.imagePath!,width: 200, height: 200, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 18),

                      _NetworkStatusBadge(
                        status: widget.networkStatus,
                        label: widget.networkLabel,
                      )
                    ],
                  ),
                ),
              ),

              // COMING SOON OVERLAY
              if (widget.comingSoon)
                Positioned.fill(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        width: widget.width * 1.1,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .comingsoonText
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollIndicatorButton extends StatelessWidget {
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
      borderRadius: BorderRadius.circular(22),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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

class _NetworkStatusBadge extends StatelessWidget {
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
        horizontal: 20,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: foregroundColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == BillerStatus.loading)
            SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(
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
          const SizedBox(width: 10),
          Text(
            '$label: $statusText',
            style: TextStyle(
              color: foregroundColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}