import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

class ClockCard extends StatefulWidget {
  final double fontScale;

  const ClockCard({
    super.key,
    this.fontScale = 1.0,
  });

  @override
  State<ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends State<ClockCard> {
  String _time = "--:--";
  String _date = "-- -- ----";
  String _weekday = "";

  Timer? _ticker;
  Timer? _resyncTimer;
  Duration _ntpOffset = Duration.zero;

  int _syncStatus = 1;
  // 0 = green  = synced
  // 1 = yellow = connecting
  // 2 = red    = fallback

  static const List<String> _sirimNtpHosts = [
    "ntp1.sirim.my",
    "ntp2.sirim.my",
  ];

  static const Duration _resyncInterval = Duration(minutes: 15);
  static const Duration _retryInterval = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  Future<void> _startClock() async {
    _updateTime();
    await _syncWithSirim();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });

    _scheduleNextSync();
  }

  void _scheduleNextSync() {
    _resyncTimer?.cancel();

    final interval = _syncStatus == 0 ? _resyncInterval : _retryInterval;

    _resyncTimer = Timer(interval, () async {
      await _syncWithSirim();
      _scheduleNextSync();
    });
  }

  Future<void> _syncWithSirim() async {
    if (!mounted) return;

    setState(() => _syncStatus = 1);

    for (final host in _sirimNtpHosts) {
      try {
        final offsetMs = await NTP.getNtpOffset(
          lookUpAddress: host,
          timeout: const Duration(seconds: 3),
        );

        if (!mounted) return;

        setState(() {
          _ntpOffset = Duration(milliseconds: offsetMs);
          _syncStatus = 0;
        });

        debugPrint("SIRIM Sync OK via $host offset ${offsetMs}ms");
        return;
      } catch (e) {
        debugPrint("SIRIM Sync failed via $host: $e");
      }
    }

    if (!mounted) return;

    setState(() {
      _ntpOffset = Duration.zero;
      _syncStatus = 2;
    });

    debugPrint("SIRIM Sync failed. Using device clock.");
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
    const months = [
      "JAN",
      "FEB",
      "MAC",
      "APR",
      "MEI",
      "JUN",
      "JUL",
      "OGOS",
      "SEPT",
      "OKT",
      "NOV",
      "DIS",
    ];

    if (m < 1 || m > 12) return "";
    return months[m - 1];
  }

  String _weekdayName(int d) {
    const days = [
      "ISNIN",
      "SELASA",
      "RABU",
      "KHAMIS",
      "JUMAAT",
      "SABTU",
      "AHAD",
    ];

    if (d < 1 || d > 7) return "";
    return days[d - 1];
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _resyncTimer?.cancel();
    super.dispose();
  }

  Color _statusColor() {
    switch (_syncStatus) {
      case 0:
        return const Color(0xFF2ECC71);
      case 1:
        return const Color(0xFFF1C40F);
      case 2:
      default:
        return const Color(0xFFE74C3C);
    }
  }

  IconData _statusIcon() {
    switch (_syncStatus) {
      case 0:
        return Icons.check_circle_rounded;
      case 1:
        return Icons.sync_rounded;
      case 2:
      default:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.fontScale;

    const darkNavy = Color(0xFF10233F);
    const softNavy = Color(0xFF53657F);
    const primaryBlue = Color(0xFF1677FF);
    const lightBlue = Color(0xFFEAF4FF);
    const cardWhite = Color(0xEFFFFFFF);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38 * scale),
        child: Container(
          width: 620 * scale,
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38 * scale),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                lightBlue.withOpacity(0.9),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.16),
                blurRadius: 45,
                offset: const Offset(0, 22),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 36 * scale,
              horizontal: 38 * scale,
            ),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(32 * scale),
              border: Border.all(
                color: primaryBlue.withOpacity(0.12),
                width: 1.4,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 22 * scale,
                    horizontal: 20 * scale,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28 * scale),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF8FCFF),
                        Color(0xFFEAF4FF),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _time,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 130 * scale,
                          height: 0.95,
                          fontWeight: FontWeight.w900,
                          color: darkNavy,
                          letterSpacing: -4,
                        ),
                      ),
                      SizedBox(height: 18 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24 * scale,
                          vertical: 12 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(18 * scale),
                          border: Border.all(
                            color: primaryBlue.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _weekday,
                              style: TextStyle(
                                fontSize: 40 * scale,
                                fontWeight: FontWeight.w900,
                                color: primaryBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 18 * scale,
                              ),
                              width: 1.5,
                              height: 26 * scale,
                              color: primaryBlue.withOpacity(0.18),
                            ),
                            Text(
                              _date,
                              style: TextStyle(
                                fontSize: 40 * scale,
                                fontWeight: FontWeight.w700,
                                color: darkNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24 * scale),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _statusIcon(),
                      size: 40 * scale,
                      color: _statusColor(),
                    ),
                    SizedBox(width: 10 * scale),
                    Flexible(
                      child: Text(
                        "MALAYSIAN STANDARD TIME",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25 * scale,
                          fontWeight: FontWeight.w800,
                          color: softNavy,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}