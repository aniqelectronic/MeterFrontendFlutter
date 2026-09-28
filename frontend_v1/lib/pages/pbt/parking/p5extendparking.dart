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
            top: 90,
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
// MODERN + GOVERNMENT PAGE HEADER
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
    return Column(
      children: [
        // ================================================================
        // TITLE CARD
        // ================================================================
        Container(
          padding: const EdgeInsets.fromLTRB(
            30,
            24,
            30,
            24,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFD5E4F7),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF173A66).withOpacity(0.14),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              // ==========================================================
              // LEFT PARKING ICON
              // ==========================================================
              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF064AA3),
                      Color(0xFF1478D4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF095AB8)
                          .withOpacity(0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ),

              const SizedBox(width: 28),

              // ==========================================================
              // TEXT AREA
              // ==========================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Parking service badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F3FF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.directions_car_filled_rounded,
                            size: 20,
                            color: Color(0xFF1265BC),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            badgeText.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF1265BC),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Main title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF122C4C),
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 9),

                    // Subtitle
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF607188),
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // ==========================================================
              // RIGHT ACCENT BAR
              // ==========================================================
              Container(
                width: 8,
                height: 105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0751A8),
                      Color(0xFF2196E8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 55),

        // ================================================================
        // VEHICLE PLATE
        // ================================================================
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF15253A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF15253A).withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(width: 16),

              Text(
                plateNumber.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  height: 1,
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

class _ModernServiceButtonState extends State<_ModernServiceButton> {
  bool _isPressed = false;
  bool _isFocused = false;

  void _setPressed(bool value) {
    if (!mounted || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    final light = widget.accentLightColor;
    final emphasized = _isPressed || _isFocused;
    final radius = BorderRadius.circular(26);
    final borderColor = emphasized
        ? accent
        : Color.lerp(const Color(0xFFB9C8DA), accent, 0.28)!;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18324F)
                  .withOpacity(_isPressed ? 0.05 : 0.11),
              blurRadius: _isPressed ? 8 : 18,
              offset: Offset(0, _isPressed ? 2 : 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: _setPressed,
            onFocusChange: (value) {
              if (!mounted || _isFocused == value) return;
              setState(() => _isFocused = value);
            },
            splashColor: accent.withOpacity(0.10),
            highlightColor: accent.withOpacity(0.04),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: widget.height * 0.51,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: widget.height * 0.36,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    light,
                                    Color.lerp(Colors.white, light, 0.40)!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 24,
                            left: 22,
                            right: 22,
                            bottom: 10,
                            child: IgnorePointer(
                              child: ExcludeSemantics(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Color.lerp(Colors.white, light, 0.18),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: accent.withOpacity(0.22),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(
                                          _isPressed ? 0.08 : 0.15,
                                        ),
                                        blurRadius: _isPressed ? 10 : 18,
                                        offset: Offset(0, _isPressed ? 3 : 7),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Icon(
                                              widget.icon,
                                              size: 120,
                                              color: accent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: accent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.label.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Color(0xFF142D4E),
                                          fontSize: 38,
                                          fontWeight: FontWeight.w800,
                                          height: 1.16,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        widget.supportingText,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Color(0xFF56657A),
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
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
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(
                          color: borderColor,
                          width: emphasized ? 3 : 2,
                        ),
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
