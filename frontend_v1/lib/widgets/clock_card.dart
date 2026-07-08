import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

/// Sync status for the small indicator dot.
enum _SyncStatus {
  synced,     // green  - time is following SIRIM NTP
  connecting, // yellow - currently trying to reach SIRIM
  fallback,   // red    - could not reach SIRIM, using this device's own clock
}

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

  _SyncStatus _status = _SyncStatus.connecting;

  // mst.sirim.my is SIRIM's *web* clock (plain HTTP/HTTPS) — it does not
  // speak the NTP protocol, so calling NTP.getNtpOffset against it always
  // times out and silently falls back to the device clock. The actual
  // Stratum-1 NTP hosts SIRIM publishes are ntp1.sirim.my / ntp2.sirim.my.
  static const List<String> _sirimNtpHosts = [
    "ntp1.sirim.my",
    "ntp2.sirim.my",
  ];

  // How often to re-sync once we're successfully following SIRIM.
  static const Duration _resyncInterval = Duration(minutes: 15);

  // If we're in fallback (using kiosk's own clock), retry sooner so we
  // recover automatically once network/NTP is available again.
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
    final interval =
        _status == _SyncStatus.synced ? _resyncInterval : _retryInterval;
    _resyncTimer = Timer(interval, () async {
      await _syncWithSirim();
      _scheduleNextSync();
    });
  }

  Future<void> _syncWithSirim() async {
    if (!mounted) return;
    setState(() => _status = _SyncStatus.connecting);

    for (final host in _sirimNtpHosts) {
      try {
        final offsetMs = await NTP.getNtpOffset(
          lookUpAddress: host,
          timeout: const Duration(seconds: 3),
        );

        if (!mounted) return;

        setState(() {
          _ntpOffset = Duration(milliseconds: offsetMs);
          _status = _SyncStatus.synced;
        });

        debugPrint("SIRIM Sync OK via $host (offset ${offsetMs}ms)");
        return; // success — no need to try the next host
      } catch (e) {
        debugPrint("SIRIM Sync failed via $host: $e");
        // fall through and try the next host
      }
    }

    // Every host failed -> fall back to this kiosk's own device clock.
    if (!mounted) return;
    setState(() {
      _ntpOffset = Duration.zero;
      _status = _SyncStatus.fallback;
    });
    debugPrint("SIRIM Sync failed on all hosts, using kiosk's own clock");
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

    return days[d - 1];
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _resyncTimer?.cancel();
    super.dispose();
  }

  Color _statusColor() {
    switch (_status) {
      case _SyncStatus.synced:
        return const Color(0xFF2ECC71); // green - following SIRIM
      case _SyncStatus.connecting:
        return const Color(0xFFF1C40F); // yellow - connecting to SIRIM
      case _SyncStatus.fallback:
        return const Color(0xFFE74C3C); // red - own device/kiosk time
    }
  }

  String _statusLabel() {
    switch (_status) {
      case _SyncStatus.synced:
        return "SIRIM";
      case _SyncStatus.connecting:
        return "MENYAMBUNG";
      case _SyncStatus.fallback:
        return "KIOSK";
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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
                  // ---- Status row: small dot + label, top-left ----
                  Row(
                    children: [
                      Container(
                        width: 14 * scale,
                        height: 14 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor(),
                          boxShadow: [
                            BoxShadow(
                              color: _statusColor().withOpacity(0.6),
                              blurRadius: 8 * scale,
                              spreadRadius: 1 * scale,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        _statusLabel(),
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: softNavy,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  SizedBox(height: 22 * scale),

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
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
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
                        Icons.verified_rounded,
                        size: 40 * scale,
                        color: primaryBlue,
                      ),
                      SizedBox(width: 8 * scale),
                      Flexible(
                        child: Text(
                          "MASA STANDARD MALAYSIA SIRIM",
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
      ),
    );
  }
}