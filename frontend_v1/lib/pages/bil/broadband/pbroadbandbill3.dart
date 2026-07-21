import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/bil/p4bil.dart';
import 'package:frontend_v1/pages/option/pbil3.dart';
import 'package:frontend_v1/services/iimmpact_network_status_service.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

enum BroadbandBillerStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

class PBROADBANDBILL3PAGE extends StatefulWidget {
  const PBROADBANDBILL3PAGE({super.key});

  @override
  State<PBROADBANDBILL3PAGE> createState() =>
      _PBROADBANDBILL3PAGEState();
}

class _PBROADBANDBILL3PAGEState
    extends State<PBROADBANDBILL3PAGE> {
  final Map<String, BroadbandBillerStatus>
      _billerStatuses = {
    'TM': BroadbandBillerStatus.loading,
    'UNB': BroadbandBillerStatus.loading,
  };

  final Map<String, String?> _lastUpdated = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialNetworkStatuses();
    });
  }

  Future<void> _loadInitialNetworkStatuses() async {
    await Future.wait([
      _refreshNetworkStatus('TM'),
      _refreshNetworkStatus('UNB'),
    ]);
  }

  Future<BroadbandBillerStatus> _refreshNetworkStatus(
    String productCode,
  ) async {
    if (mounted) {
      setState(() {
        _billerStatuses[productCode] =
            BroadbandBillerStatus.loading;
      });
    }

    try {
      final result =
          await IimmpactNetworkStatusService.getStatus(
        productCode: productCode,
      );

      final status = result.isHealthy
          ? BroadbandBillerStatus.healthy
          : BroadbandBillerStatus.interruption;

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] = status;
          _lastUpdated[productCode] =
              result.lastUpdated;
        });
      }

      return status;
    } catch (error) {
      debugPrint(
        'Broadband network status error for '
        '$productCode: $error',
      );

      if (mounted) {
        setState(() {
          _billerStatuses[productCode] =
              BroadbandBillerStatus.unavailable;
        });
      }

      return BroadbandBillerStatus.unavailable;
    }
  }

  Future<bool> _showInterruptionWarning({
    required String billerName,
    required String productCode,
  }) async {
    final loc = AppLocalizations.of(context)!;

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
                                const Color(0xFFE53935),
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

  Future<void> _handleBillerTap({
    required String productCode,
    required String billerName,
  }) async {
    final status =
        await _refreshNetworkStatus(productCode);

    if (!mounted) {
      return;
    }

    if (status ==
        BroadbandBillerStatus.interruption) {
      final shouldContinue =
          await _showInterruptionWarning(
        billerName: billerName,
        productCode: productCode,
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
          title: loc.broadbandAccountTitle,
          hint: loc.broadbandAccountHint,
          productCode: productCode,
          billerName: billerName,

          // Add broadband to BillServiceType first.
          serviceType: BillServiceType.broadband,
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

          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Text(
              loc.broadbandSelectionTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0359D2),
                fontSize: 70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Text(
              loc.pbil3Subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3E3E3E),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            top: 430,
            left: 70,
            right: 70,
            bottom: 350,
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 70,
                runSpacing: 60,
                children: [
                  _BroadbandButton(
                    width: 400,
                    height: 500,
                    imagePath:
                        'lib/images/broadband/tm.png',
                    label: loc.tmBroadbandButton,
                    networkStatus:
                        _billerStatuses['TM'] ??
                            BroadbandBillerStatus.loading,
                    networkLabel: loc.networkLabel,
                    onPressed: () {
                      _handleBillerTap(
                        productCode: 'TM',
                        billerName:
                            'TELEKOM MALAYSIA',
                      );
                    },
                  ),

                  _BroadbandButton(
                    width: 400,
                    height: 500,
                    imagePath:
                        'lib/images/broadband/unb.png',
                    label: loc.unbBroadbandButton,
                    networkStatus:
                        _billerStatuses['UNB'] ??
                            BroadbandBillerStatus.loading,
                    networkLabel: loc.networkLabel,
                    onPressed: () {
                      _handleBillerTap(
                        productCode: 'UNB',
                        billerName: 'UNIFI',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

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
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BroadbandButton extends StatefulWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final BroadbandBillerStatus networkStatus;
  final String networkLabel;

  const _BroadbandButton({
    required this.imagePath,
    required this.label,
    required this.onPressed,
    required this.networkStatus,
    required this.networkLabel,
    this.width = 400,
    this.height = 500,
  });

  @override
  State<_BroadbandButton> createState() =>
      _BroadbandButtonState();
}

class _BroadbandButtonState
    extends State<_BroadbandButton> {
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
        duration: const Duration(
          milliseconds: 100,
        ),
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
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                child: Image.asset(
                  widget.imagePath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Text(
                  widget.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

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

class _NetworkStatusBadge extends StatelessWidget {
  final BroadbandBillerStatus status;
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
      case BroadbandBillerStatus.loading:
        statusText = loc.networkStatusChecking;
        backgroundColor =
            const Color(0xFFE8EEF6);
        foregroundColor =
            const Color(0xFF455A64);
        icon = Icons.sync_rounded;
        break;

      case BroadbandBillerStatus.healthy:
        statusText = loc.networkStatusGood;
        backgroundColor =
            const Color(0xFFDDF7E8);
        foregroundColor =
            const Color(0xFF08783E);
        icon = Icons.check_circle_rounded;
        break;

      case BroadbandBillerStatus.interruption:
        statusText = loc.networkStatusSlow;
        backgroundColor =
            const Color(0xFFFFE8C2);
        foregroundColor =
            const Color(0xFFB75B00);
        icon = Icons.warning_amber_rounded;
        break;

      case BroadbandBillerStatus.unavailable:
        statusText = loc.networkStatusUnknown;
        backgroundColor =
            const Color(0xFFE8E8E8);
        foregroundColor =
            const Color(0xFF555555);
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
          if (status ==
              BroadbandBillerStatus.loading)
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

          Flexible(
            child: Text(
              '$label: $statusText',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}