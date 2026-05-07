import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

class ClockCard extends StatefulWidget {
  final double fontScale;
  const ClockCard({super.key, this.fontScale = 1.0});

  @override
  State<ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends State<ClockCard> {
  String _time = "--:--";
  String _date = "-- -- ----";
  String _weekday = "";
  bool _isSyncing = true;

  Timer? _ticker;
  Duration _ntpOffset = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  Future<void> _startClock() async {
    _updateTime();
    try {
      // Syncing with SIRIM Malaysia NTP Server
      final offsetMs = await NTP.getNtpOffset(
        lookUpAddress: "mst.sirim.my",
        timeout: const Duration(seconds: 3),
      );
      if (mounted) {
        setState(() {
          _ntpOffset = Duration(milliseconds: offsetMs);
          _isSyncing = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSyncing = false);
      debugPrint("SIRIM Sync Failed: $e");
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now().add(_ntpOffset);
    if (!mounted) return;
    setState(() {
      _time = "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}";
      _date = "${_twoDigits(now.day)} ${_monthName(now.month)} ${now.year}";
      _weekday = _weekdayName(now.weekday);
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _monthName(int m) {
    const months = ["JAN", "FEB", "MAC", "APR", "MEI", "JUN", "JUL", "OGOS", "SEPT", "OKT", "NOV", "DIS"];
    return months[m - 1];
  }

  String _weekdayName(int d) {
    const days = ["ISNIN", "SELASA", "RABU", "KHAMIS", "JUMAAT", "SABTU", "AHAD"];
    return days[d - 1];
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.fontScale;
    
    // THEME COLORS
    const mainText = Color(0xFF1A2A44);      // Dark Navy
    const secondaryText = Color(0xFF5A6A85); // Muted Slate
    const accentBlue = Color(0xFF0052D4);    // Malaysian Blue
    const glassColor = Color(0xCCFFFFFF);   // 80% White Frost

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 580 * scale,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 35),
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(32),
              // --- THE BLACK BORDER ---
              border: Border.all(
                color: Colors.black, 
                width: 3.0 * scale,
              ),
              // ------------------------
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Sync Status Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PulseDot(isActive: !_isSyncing),
                    const SizedBox(width: 12),
                    Text(
                      "MASA STANDARD MALAYSIA",
                      style: TextStyle(
                        color: secondaryText,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),

                // Digital Time
                Text(
                  _time,
                  style: TextStyle(
                    fontSize: 120 * scale,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: mainText,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: -2,
                  ),
                ),

                const SizedBox(height: 15),

                // Day & Date Info Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _weekday,
                        style: TextStyle(
                          fontSize: 24 * scale,
                          color: accentBlue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Container(width: 1.5, height: 24, color: accentBlue.withOpacity(0.2)),
                      const SizedBox(width: 18),
                      Text(
                        _date,
                        style: TextStyle(
                          fontSize: 24 * scale,
                          color: mainText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // Official Footer
                Text(
                  "DISELARASKAN DENGAN MASA STANDARD MALAYSIA (SIRIM)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13 * scale,
                    color: secondaryText,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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

// Glowing Pulse Animation for the Sync Indicator
class _PulseDot extends StatefulWidget {
  final bool isActive;
  const _PulseDot({required this.isActive});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: widget.isActive ? const Color(0xFF00C853) : Colors.orange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (widget.isActive ? Colors.green : Colors.orange).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}