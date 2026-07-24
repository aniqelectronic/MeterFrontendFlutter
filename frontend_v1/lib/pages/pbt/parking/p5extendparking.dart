import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/parking/parking_controller.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/pages/pbt/parking/p6extendparking.dart';
import 'package:frontend_v1/pages/resit/resit.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class P5EXTENDPARKINGPAGE extends StatefulWidget {
  final String plate;
  final String biz;

  const P5EXTENDPARKINGPAGE({
    super.key,
    required this.plate,
    required this.biz,
  });

  @override
  State<P5EXTENDPARKINGPAGE> createState() =>
      _P5EXTENDPARKINGPAGEState();
}

class _P5EXTENDPARKINGPAGEState
    extends State<P5EXTENDPARKINGPAGE> {
  void _goToExtendPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P6EXTENDPARKINGPAGE(
          plate: widget.plate,
          biz: widget.biz,
        ),
      ),
    );
  }

  // ==========================================================================
  // CHECK WHETHER PARKING CAN STILL BE EXTENDED
  // ==========================================================================
  void _handleExtendParking() {
    final loc = AppLocalizations.of(context)!;

    final String? endTimeStr =
        ParkingController.getParkingEndTime();

    // If there is no stored end time, continue normally.
    if (endTimeStr == null || endTimeStr.trim().isEmpty) {
      _goToExtendPage();
      return;
    }

    try {
      final DateTime now = DateTime.now();

      final List<String> timeParts = endTimeStr.split(':');

      if (timeParts.length < 2) {
        _goToExtendPage();
        return;
      }

      final int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      final DateTime endTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      final DateTime maximumEndTime = DateTime(
        now.year,
        now.month,
        now.day,
        18,
        0,
      );

      if (endTime.isBefore(maximumEndTime)) {
        _goToExtendPage();
      } else {
        _showParkingLimitDialog(
          title: loc.alertTitle,
          message: loc.parkingExpiredAfter6pm,
        );
      }
    } catch (_) {
      // Preserve the original flow if the stored time format is unexpected.
      _goToExtendPage();
    }
  }

  // ==========================================================================
  // MODERN PARKING LIMIT DIALOG
  // ==========================================================================
  void _showParkingLimitDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 90,
          ),
          child: Container(
            width: 680,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEE8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE9553F)
                          .withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Color(0xFFE9553F),
                    size: 72,
                  ),
                ),

                const SizedBox(height: 26),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF164F9C),
                    fontSize: 39,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4E5B6E),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 78,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1469E8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // OPEN RECEIPT PAGE
  // ==========================================================================
  void _openReceiptPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RESITPAGE(
          biz: 'PARKING',
          data: ResitData(
            plate: widget.plate,
            hour:
                ParkingController.getParkingHours() ?? 0,
            amount:
                ParkingController.getParkingAmount() ?? '0',
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // RETURN TO PLATE INPUT PAGE
  // ==========================================================================
  void _goBackToParkingInput() {
    final loc = AppLocalizations.of(context)!;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => P4PAGE(
          title: loc.parkirButton,
          type: 'PBT',
          hint: loc.inputPlateHint,
          biz: 'PARKING',
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
          // ============================================================
          // BACKGROUND
          // ============================================================
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          // Soft background overlay.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.04),
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.06),
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // MODERN HEADER
          // ============================================================
          Positioned(
            top: 105,
            left: 65,
            right: 65,
            child: _ModernPageHeader(
              badgeText: loc.parkingManagementLabel,
              title: loc.p5extendparkingTitle,
              subtitle: loc.p5extendparkingSubtitle,
              plateNumber: widget.plate,
            ),
          ),

          // ============================================================
          // OPTION CARDS
          // ============================================================
          Positioned(
            top: 700,
            left: 60,
            right: 60,
            child: Row(
              children: [
                // ======================================================
                // EXTEND PARKING
                // ======================================================
                Expanded(
                  child: _ModernServiceButton(
                    height: 470,
                    icon: Icons.add_alarm_rounded,
                    label: loc.plusTimeButton,
                    supportingText:
                        loc.extendParkingSupportingText,
                    accentColor:
                        const Color(0xFF1469E8),
                    accentLightColor:
                        const Color(0xFFE5F0FF),
                    onPressed: _handleExtendParking,
                  ),
                ),

                const SizedBox(width: 38),

                // ======================================================
                // VIEW RECEIPT
                // ======================================================
                Expanded(
                  child: _ModernServiceButton(
                    height: 470,
                    icon: Icons.receipt_long_rounded,
                    label: loc.receiptButton,
                    supportingText:
                        loc.parkingReceiptSupportingText,
                    accentColor:
                        const Color(0xFF15946B),
                    accentLightColor:
                        const Color(0xFFE2F7EF),
                    onPressed: _openReceiptPage,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // BACK BUTTON
          // ============================================================
          Positioned(
            bottom: 120,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: _goBackToParkingInput,
            ),
          ),

          // ============================================================
          // FOOTER
          // ============================================================
          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF26364A),
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

// ============================================================================
// MODERN PAGE HEADER
// ============================================================================
class _ModernPageHeader extends StatelessWidget {
  final String badgeText;
  final String title;
  final String subtitle;
  final String plateNumber;

  const _ModernPageHeader({
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.plateNumber,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF1469E8);

    return Column(
      children: [
        // Page category badge.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: accentColor.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_parking_rounded,
                size: 25,
                color: accentColor,
              ),
              const SizedBox(width: 10),
              Text(
                badgeText.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Main title.
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
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.1,
              height: 1.05,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Subtitle capsule.
        Container(
          constraints: const BoxConstraints(
            maxWidth: 860,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF113968).withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF435166),
              fontSize: 29,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),

        const SizedBox(height: 100),

        // Vehicle plate display.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF15253A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 12),
              Text(
                plateNumber.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MODERN SERVICE BUTTON
// ============================================================================
class _ModernServiceButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String supportingText;
  final VoidCallback onPressed;
  final Color accentColor;
  final Color accentLightColor;
  final double height;

  const _ModernServiceButton({
    super.key,
    required this.icon,
    required this.label,
    required this.supportingText,
    required this.onPressed,
    required this.accentColor,
    required this.accentLightColor,
    this.height = 470,
  });

  @override
  State<_ModernServiceButton> createState() =>
      _ModernServiceButtonState();
}

class _ModernServiceButtonState
    extends State<_ModernServiceButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.965 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: _isPressed
                  ? widget.accentColor
                  : Colors.black,
              width: _isPressed ? 4 : 3,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color:
                          widget.accentColor.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF19375C)
                          .withOpacity(0.16),
                      blurRadius: 32,
                      spreadRadius: 1,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.85),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(37),
            child: Stack(
              children: [
                // Large decorative background circle.
                Positioned(
                  right: -45,
                  top: -45,
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),
                    width: _isPressed ? 220 : 205,
                    height: _isPressed ? 220 : 205,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentLightColor
                          .withOpacity(0.90),
                    ),
                  ),
                ),

                // Small decorative circle.
                Positioned(
                  right: 120,
                  top: 100,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.accentColor.withOpacity(0.08),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    34,
                    34,
                    30,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // ICON AND ARROW
                      // ==================================================
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 135,
                            height: 125,
                            decoration: BoxDecoration(
                              color: widget.accentLightColor,
                              borderRadius:
                                  BorderRadius.circular(34),
                              border: Border.all(
                                color: widget.accentColor
                                    .withOpacity(0.20),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              widget.icon,
                              color: widget.accentColor,
                              size: 70,
                            ),
                          ),

                          AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 160,
                            ),
                            transform:
                                Matrix4.translationValues(
                              _isPressed ? 6 : 0,
                              0,
                              0,
                            ),
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor
                                      .withOpacity(0.24),
                                  blurRadius: 14,
                                  offset:
                                      const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // ==================================================
                      // MAIN LABEL
                      // ==================================================
                      Text(
                        widget.label.toUpperCase(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF15253A),
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                          letterSpacing: 0.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ==================================================
                      // SUPPORTING TEXT
                      // ==================================================
                      Text(
                        widget.supportingText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF647187),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.28,
                        ),
                      ),

                      const SizedBox(height: 23),

                      // ==================================================
                      // BOTTOM ACCENT
                      // ==================================================
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 7,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              borderRadius:
                                  BorderRadius.circular(50),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 12,
                            height: 7,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}