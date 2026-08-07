import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/payment.dart';
import 'package:frontend_v1/widgets/clock_card.dart';

// Change this import only if your SirimTime file is stored elsewhere.
import 'package:frontend_v1/services/sirim/sirim_time.dart';

import '../p4.dart';
import '../../config.dart';

class P5PARKINGPAGE extends StatefulWidget {
  final String plate;
  final String biz;

  const P5PARKINGPAGE({
    super.key,
    required this.plate,
    required this.biz,
  });

  @override
  State<P5PARKINGPAGE> createState() => _P5PARKINGPAGEState();
}

class _P5PARKINGPAGEState extends State<P5PARKINGPAGE> {
  static const Color _primaryBlue = Color(0xFF075FD8);
  static const Color _darkBlue = Color(0xFF102A4C);
  static const Color _softBlue = Color(0xFFF1F7FF);
  static const Color _successGreen = Color(0xFF168A45);
  static const Color _softGreen = Color(0xFFECF8F0);

  int hours = 1;
  final double rate = Data.ratePerHour;
  DateTime startTime = SirimTime.now();
  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showParkingRateInfoDialog();
      }
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        startTime = SirimTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  DateTime get maxEndTime {
    return DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      18,
      0,
    );
  }

  DateTime get endTime {
    final calculated = startTime.add(Duration(hours: hours));

    if (calculated.isAfter(maxEndTime)) {
      return maxEndTime;
    }

    return calculated;
  }

  double get totalPrice => hours * rate;

  bool get canAddHour {
    // Allow one final paid hour whenever the current parking end time
    // has not yet reached 6:00 PM.
    //
    // Example:
    // Start: 9:11 AM
    // 8 hours -> 5:11 PM
    // User may add one more hour.
    // 9 hours -> displayed/capped at 6:00 PM and charged as 9 hours.
    return endTime.isBefore(maxEndTime);
  }

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  void _addHour() {
    if (!canAddHour) return;

    setState(() {
      hours++;
    });
  }

  void _minusHour() {
    if (hours <= 1) return;

    setState(() {
      hours--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildTopTitle(),
          _buildClock(),
          _buildParkingCard(loc),
          _buildBottomButtons(loc),
          _buildCopyright(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/pnew.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopTitle() {
    return Positioned(
      top: 55,
      left: 0,
      right: 0,
      child: Column(
        children: [
          const Text(
            'PARK&PAY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 78,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 100,
            height: 6,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClock() {
    return const Positioned(
      top: 200,
      left: 205,
      right: 205,
      child: ClockCard(fontScale: 0.78),
    );
  }

  Widget _buildParkingCard(AppLocalizations loc) {
    return Positioned(
      top: 590,
      left: 52,
      right: 52,
      bottom: 330,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(42),
          border: Border.all(
            color: _primaryBlue,
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF102A4C).withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: Column(
            children: [
              _buildCardHeader(loc),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(34, 28, 34, 30),
                  child: Column(
                    children: [
                      _buildGuideBanner(loc),
                      const SizedBox(height: 28),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildDurationPanel(loc),
                            ),
                            const SizedBox(width: 26),
                            Container(
                              width: 1.5,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 12),
                              color: const Color(0xFFE0E8F2),
                            ),
                            const SizedBox(width: 26),
                            Expanded(
                              child: _buildSummaryPanel(loc),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(34, 24, 34, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEEF5FF),
            Color(0xFFF8FBFF),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFDCE9F8),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.p5parkingNumberPlate,
                  style: const TextStyle(
                    color: Color(0xFF60728A),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.plate.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _darkBlue,
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFBDE7CA),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: _successGreen,
                  size: 27,
                ),
                const SizedBox(width: 8),
                Text(
                  'RM ${rate.toStringAsFixed(2)} / ${loc.time}',
                  style: const TextStyle(
                    color: _successGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideBanner(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: _softBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFCFE2FB),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: _primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              loc.parkingDurationGuide,
              style: const TextStyle(
                color: _darkBlue,
                fontSize: 25,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPanel(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE0EAF5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: _primaryBlue,
                size: 30,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  loc.p5parkingText1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _darkBlue,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _durationButton(
                icon: Icons.remove_rounded,
                onPressed: hours > 1 ? _minusHour : null,
                semanticLabel: loc.parkingDecreaseDuration,
              ),
              Container(
                width: 145,
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    '$hours',
                    key: ValueKey(hours),
                    style: const TextStyle(
                      color: _darkBlue,
                      fontSize: 105,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
              _durationButton(
                icon: Icons.add_rounded,
                onPressed: canAddHour ? _addHour : null,
                semanticLabel: loc.parkingIncreaseDuration,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            loc.time.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF5D6D82),
              fontSize: 27,
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD9E5F2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF61758F),
                  size: 24,
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    loc.parkingMaximumUntil(formatTime(maxEndTime)),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF61758F),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel(AppLocalizations loc) {
    return Column(
      children: [
        _timeSummaryCard(
          icon: Icons.play_arrow_rounded,
          label: loc.p5parkingStart,
          value: formatTime(startTime),
          iconBackground: const Color(0xFFEAF3FF),
          iconColor: _primaryBlue,
        ),
        const SizedBox(height: 14),
        _timeSummaryCard(
          icon: Icons.stop_rounded,
          label: loc.p5parkingEnd,
          value: formatTime(endTime),
          iconBackground: const Color(0xFFFFF1E8),
          iconColor: const Color(0xFFE97022),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFBCE5C8),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.p5parkingTotal,
                style: const TextStyle(
                  color: Color(0xFF557064),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'RM ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _successGreen,
                    fontSize: 53,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _durationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String semanticLabel,
  }) {
    final isEnabled = onPressed != null;

    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: isEnabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: isEnabled ? _primaryBlue : const Color(0xFFE1E6EC),
              borderRadius: BorderRadius.circular(22),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: _primaryBlue.withOpacity(0.24),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isEnabled ? Colors.white : const Color(0xFF9AA6B3),
              size: 45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE0EAF5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF68798E),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: _darkBlue,
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(AppLocalizations loc) {
    return Positioned(
      bottom: 148,
      left: 78,
      right: 78,
      child: Row(
        children: [
          Expanded(
            child: _bottomActionButton(
              label: loc.backButton,
              icon: Icons.arrow_back_rounded,
              backgroundColor: const Color(0xFFF2F3F5),
              foregroundColor: const Color(0xFF20242A),
              borderColor: const Color(0xFF5D6269),
              onPressed: () {
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
              },
            ),
          ),
          const SizedBox(width: 34),
          Expanded(
            child: _bottomActionButton(
              label: loc.continueButton,
              icon: Icons.arrow_forward_rounded,
              iconOnRight: true,
              backgroundColor: _successGreen,
              foregroundColor: Colors.white,
              borderColor: const Color(0xFF0F6D35),
              onPressed: () => _showConfirmation(context, loc),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
    required VoidCallback onPressed,
    bool iconOnRight = false,
  }) {
    final children = <Widget>[
      Icon(
        icon,
        size: 40,
      ),
      const SizedBox(width: 13),
      Flexible(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 0.3,
          ),
        ),
      ),
    ];

    return SizedBox(
      height: 102,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.28),
          side: BorderSide(
            color: borderColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: iconOnRight ? children.reversed.toList() : children,
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Positioned(
      bottom: 64,
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
    );
  }

  void _showParkingRateInfoDialog() {
    final loc = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 70,
            vertical: 90,
          ),
          child: Container(
            width: 820,
            padding: const EdgeInsets.fromLTRB(36, 34, 36, 34),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: const Color(0xFFD8E6F6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF102A4C).withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF075FD8),
                        Color(0xFF3388F0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryBlue.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    size: 58,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  loc.parkingInfoTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 39,
                    fontWeight: FontWeight.w900,
                    color: _darkBlue,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  loc.p5parkingText1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF68798E),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFBCE5C8),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        loc.parkingRateLabel,
                        style: const TextStyle(
                          fontSize: 26,
                          color: Color(0xFF557064),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        loc.parkingRatePerHour(
                          Data.ratePerHour.toStringAsFixed(2),
                        ),
                        style: const TextStyle(
                          fontSize: 47,
                          color: _successGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFD98200),
                        size: 32,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          loc.parkingStartTimeDisclaimer,
                          style: const TextStyle(
                            fontSize: 25,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5B4A24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  loc.parkingContactTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _darkBlue,
                  ),
                ),
                const SizedBox(height: 14),
                _contactRow(
                  icon: Icons.phone_in_talk_rounded,
                  label: loc.parkingCouncilHotline,
                  value: Data.aduanMajlisBentong,
                ),
                const SizedBox(height: 10),
                _contactRow(
                  icon: Icons.support_agent_rounded,
                  label: loc.parkingCityCarParkHotline,
                  value: Data.telefonNo,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 82,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      size: 36,
                    ),
                    label: Text(
                      loc.parkingInfoOk,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: _primaryBlue.withOpacity(0.28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
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

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FD),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 29,
              color: _primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _darkBlue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF202A36),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmation(
    BuildContext context,
    AppLocalizations loc,
  ) {
    Timer? dialogTimer;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            dialogTimer ??= Timer.periodic(
              const Duration(seconds: 1),
              (_) {
                if (!mounted) return;

                setState(() {
                  startTime = SirimTime.now();
                });

                setDialogState(() {});
              },
            );

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 54,
                vertical: 65,
              ),
              child: Container(
                width: 880,
                padding: const EdgeInsets.fromLTRB(34, 32, 34, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF102A4C).withOpacity(0.26),
                      blurRadius: 42,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: _softBlue,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.fact_check_rounded,
                            size: 41,
                            color: _primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            loc.confirmDialogTitle,
                            style: const TextStyle(
                              fontSize: 39,
                              fontWeight: FontWeight.w900,
                              color: _darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFEEF5FF),
                            Color(0xFFF8FBFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            loc.p5parkingNumberPlate,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF65778C),
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.plate.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: _darkBlue,
                              letterSpacing: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 17),
                    _confirmationInfoRow(
                      icon: Icons.schedule_rounded,
                      label: loc.p5tempoh,
                      value: '$hours ${loc.time}',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _confirmationTimeCard(
                            label: loc.parkingStartTimeLabel,
                            value: formatTime(startTime),
                            icon: Icons.play_arrow_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _confirmationTimeCard(
                            label: loc.parkingEndTimeLabel,
                            value: formatTime(endTime),
                            icon: Icons.stop_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 40,
                            color: _successGreen,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              loc.p5Total,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF557064),
                              ),
                            ),
                          ),
                          Text(
                            'RM ${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: _successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E8),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFFD98200),
                            size: 29,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.parkingStartTimeDisclaimer,
                              style: const TextStyle(
                                fontSize: 24,
                                height: 1.35,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5B4A24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 82,
                            child: OutlinedButton(
                              onPressed: () {
                                dialogTimer?.cancel();
                                Navigator.pop(dialogContext);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF30363D),
                                side: const BorderSide(
                                  color: Color(0xFF9DA6B0),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                loc.cancelButton,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: SizedBox(
                            height: 82,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                dialogTimer?.cancel();

                                Navigator.pop(dialogContext);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: const RouteSettings(
                                      name: '/payment',
                                    ),
                                    builder: (_) => PAYMENTPAGE(
                                      biz: widget.biz,
                                      data: PaymentData(
                                        plate: widget.plate,
                                        hour: hours,
                                        amount:
                                            totalPrice.toStringAsFixed(2),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.check_rounded,
                                size: 35,
                              ),
                              label: Text(
                                loc.confirmButton,
                                style: const TextStyle(
                                  fontSize: 31,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: _primaryBlue.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
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
      },
    ).then((_) {
      dialogTimer?.cancel();
    });
  }

  Widget _confirmationInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 31,
              color: _primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF68798E),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmationTimeCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: _softBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: _primaryBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF68798E),
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w900,
                color: _darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
