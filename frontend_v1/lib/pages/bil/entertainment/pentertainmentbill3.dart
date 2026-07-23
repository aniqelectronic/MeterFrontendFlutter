import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';
import 'package:frontend_v1/services/iimmpact_network_status_service.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

enum BillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

class PENTERTAINMENTBILL3PAGE extends StatefulWidget {
  const PENTERTAINMENTBILL3PAGE({super.key});

  @override
  State<PENTERTAINMENTBILL3PAGE> createState() =>
      _PENTERTAINMENTBILL3PAGEState();
}

class _PENTERTAINMENTBILL3PAGEState
    extends State<PENTERTAINMENTBILL3PAGE> {
  static const String _astroProductCode = 'ASB';
  static const String _astroBillerName = 'ASTRO';

  final Map<String, BillerStatus> _billerStatuses = {
    _astroProductCode: BillerStatus.loading,
  };

  final Map<String, String?> _lastUpdated = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNetworkStatus(_astroProductCode);
    });
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

      final BillerStatus status = result.isHealthy
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
        'Astro network status error: $error',
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
    final loc = AppLocalizations.of(context)!;

    final bool? result = await showDialog<bool>(
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
                  loc.networkInterruptionTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  loc.networkInterruptionMessage(
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
                    '${loc.networkLastUpdated}: '
                    '${_lastUpdated[productCode]}',
                    textAlign: TextAlign.center,
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
                            backgroundColor:
                                const Color(0xFFF80202),
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
                            loc.backButton,
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
                            loc.continueButton,
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

  Future<void> _handleAstroTap() async {
    final BillerStatus status =
        await _refreshNetworkStatus(
      _astroProductCode,
    );

    if (!mounted) {
      return;
    }

    if (status == BillerStatus.interruption) {
      final bool shouldContinue =
          await _showInterruptionWarning(
        billerName: _astroBillerName,
        productCode: _astroProductCode,
      );

      if (!shouldContinue) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    final loc = AppLocalizations.of(context)!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P4BILPAGE(
          title: loc.entertainmentAccountTitle,
          hint: loc.entertainmentAccountHint,
          productCode: _astroProductCode,
          billerName: _astroBillerName,
          serviceType: BillServiceType.entertainment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // =========================================================
          // BACKGROUND
          // =========================================================
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

          // =========================================================
          // TITLE
          // =========================================================
          Positioned(
            top: 120,
            left: 30,
            right: 30,
            child: Text(
              loc.entertainmentBillTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(
                  255,
                  3,
                  89,
                  210,
                ),
                fontSize: 70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // =========================================================
          // SUBTITLE
          // =========================================================
          Positioned(
            top: 240,
            left: 30,
            right: 30,
            child: Text(
              loc.pbil3Subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(
                  255,
                  62,
                  62,
                  62,
                ),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // =========================================================
          // ASTRO BUTTON
          // =========================================================
          Positioned(
            top: 400,
            left: -500,
            right: 0,
            child: Center(
              child: _KioskMainButton(
                width: 400,
                height: 450,

                // Use this when you have downloaded the Astro logo.
                imagePath:
                    'lib/images/entertainment/ASB.png',

                // Or replace imagePath above with:
                // icon: Icons.live_tv_rounded,
                // iconColor: Colors.pink,

                label: loc.astroButton,
                networkStatus:
                    _billerStatuses[_astroProductCode] ??
                        BillerStatus.loading,
                networkLabel: loc.networkLabel,
                onPressed: _handleAstroTap,
              ),
            ),
          ),

          // =========================================================
          // BACK BUTTON
          // =========================================================
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

          // =========================================================
          // FOOTER
          // =========================================================
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                textAlign: TextAlign.center,
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

/// =================================================================
/// ASTRO KIOSK BUTTON
/// =================================================================
class _KioskMainButton extends StatefulWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? imagePath;
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final BillerStatus networkStatus;
  final String networkLabel;

  const _KioskMainButton({
    this.icon,
    this.iconColor,
    this.imagePath,
    required this.label,
    required this.onPressed,
    required this.networkStatus,
    required this.networkLabel,
    this.width = 400,
    this.height = 500,
  }) : assert(
          icon != null || imagePath != null,
          'Either icon or imagePath must be supplied.',
        );

  @override
  State<_KioskMainButton> createState() =>
      _KioskMainButtonState();
}

class _KioskMainButtonState
    extends State<_KioskMainButton> {
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
        scale: _isPressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            border: Border.all(
              color: Colors.black,
              width: 4,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                      offset: Offset(0, 12),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 210,
                height: 210,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: widget.icon != null
                    ? Icon(
                        widget.icon,
                        size: 140,
                        color: widget.iconColor ??
                            Colors.black,
                      )
                    : Image.asset(
                        widget.imagePath!,
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _NetworkStatusBadge(
                status: widget.networkStatus,
                label: widget.networkLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// NETWORK STATUS BADGE
/// =================================================================
class _NetworkStatusBadge extends StatelessWidget {
  final BillerStatus status;
  final String label;

  const _NetworkStatusBadge({
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    late final String statusText;
    late final Color backgroundColor;
    late final Color foregroundColor;
    late final IconData icon;

    switch (status) {
      case BillerStatus.loading:
        statusText = loc.networkStatusChecking;
        backgroundColor = const Color(0xFFE8EEF6);
        foregroundColor = const Color(0xFF455A64);
        icon = Icons.sync_rounded;
        break;

      case BillerStatus.healthy:
        statusText = loc.networkStatusGood;
        backgroundColor = const Color(0xFFDDF7E8);
        foregroundColor = const Color(0xFF08783E);
        icon = Icons.check_circle_rounded;
        break;

      case BillerStatus.interruption:
        statusText = loc.networkStatusSlow;
        backgroundColor = const Color(0xFFFFE8C2);
        foregroundColor = const Color(0xFFB75B00);
        icon = Icons.warning_amber_rounded;
        break;

      case BillerStatus.unavailable:
        statusText = loc.networkStatusUnknown;
        backgroundColor = const Color(0xFFE8E8E8);
        foregroundColor = const Color(0xFF555555);
        icon = Icons.help_outline_rounded;
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