import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_v1/services/internet_guard.dart';
import 'package:frontend_v1/services/sirim_time.dart';

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
  String _time = '--:--';
  String _date = '-- -- ----';
  String _weekday = '';

  Timer? _ticker;
  Timer? _resyncTimer;

  bool _hasInternet = true;
  bool _syncInProgress = false;

  int _syncStatus = 1;

  // 0 = green  = SIRIM synchronized
  // 1 = yellow = synchronizing
  // 2 = red    = no internet or synchronization failed

  /// After a successful sync, check again after 15 minutes.
  static const Duration _resyncInterval =
      Duration(minutes: 15);

  /// If NTP synchronization fails, retry every 5 seconds.
  static const Duration _retryInterval =
      Duration(seconds: 5);

  @override
  void initState() {
    super.initState();

    _hasInternet = InternetGuard().hasInternet;

    InternetGuard().internetAvailable.addListener(
      _handleInternetStatusChanged,
    );

    _startClock();
  }

  Future<void> _startClock() async {
    _updateTime();

    // Update the displayed clock every second.
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _updateTime();
      },
    );

    if (!_hasInternet) {
      _showUnavailableTime();
      return;
    }

    await _synchronizeAndSchedule();
  }

  void _handleInternetStatusChanged() {
    if (!mounted) return;

    final hasInternet = InternetGuard().hasInternet;

    if (_hasInternet == hasInternet) {
      return;
    }

    setState(() {
      _hasInternet = hasInternet;
    });

    if (!hasInternet) {
      debugPrint(
        '[ClockCard] Internet lost. Hiding clock.',
      );

      // Stop all pending NTP retry timers.
      _resyncTimer?.cancel();
      _resyncTimer = null;

      setState(() {
        _syncStatus = 2;
      });

      _showUnavailableTime();
    } else {
      debugPrint(
        '[ClockCard] Internet restored. '
        'Synchronizing with SIRIM immediately.',
      );

      setState(() {
        _syncStatus = 1;
      });

      _updateTime();

      // Synchronize immediately after internet returns.
      _synchronizeAndSchedule();
    }
  }

  Future<void> _synchronizeAndSchedule() async {
    if (!mounted || !_hasInternet) {
      return;
    }

    final success = await _syncWithSirim();

    if (!mounted || !_hasInternet) {
      return;
    }

    _scheduleNextSync(success: success);
  }

  Future<bool> _syncWithSirim() async {
    if (!mounted || !_hasInternet) {
      return false;
    }

    // Prevent multiple NTP requests from running together.
    if (_syncInProgress) {
      debugPrint(
        '[ClockCard] SIRIM synchronization already running.',
      );

      return SirimTime.hasSynced;
    }

    _syncInProgress = true;

    setState(() {
      _syncStatus = 1;
    });

    bool success = false;

    try {
      success = await SirimTime.sync();
    } catch (error) {
      debugPrint(
        '[ClockCard] Unexpected SIRIM error: $error',
      );

      success = false;
    } finally {
      _syncInProgress = false;
    }

    if (!mounted) {
      return success;
    }

    // Internet may have disconnected while waiting for NTP.
    if (!_hasInternet) {
      setState(() {
        _syncStatus = 2;
      });

      _showUnavailableTime();

      return false;
    }

    setState(() {
      _syncStatus = success ? 0 : 2;
    });

    _updateTime();

    if (success) {
      debugPrint(
        '[ClockCard] SIRIM time synchronized successfully.',
      );
    } else {
      debugPrint(
        '[ClockCard] SIRIM synchronization failed. '
        'Retrying in 5 seconds.',
      );
    }

    return success;
  }

  void _scheduleNextSync({
    required bool success,
  }) {
    _resyncTimer?.cancel();
    _resyncTimer = null;

    if (!mounted || !_hasInternet) {
      return;
    }

    final interval = success
        ? _resyncInterval
        : _retryInterval;

    debugPrint(
      success
          ? '[ClockCard] Next SIRIM sync in 15 minutes.'
          : '[ClockCard] Retrying SIRIM sync in 5 seconds.',
    );

    _resyncTimer = Timer(
      interval,
      () async {
        if (!mounted || !_hasInternet) {
          return;
        }

        await _synchronizeAndSchedule();
      },
    );
  }

  void _updateTime() {
    if (!mounted) return;

    // Hide all time information when internet is unavailable.
    if (!_hasInternet) {
      _showUnavailableTime();
      return;
    }

    final currentTime = SirimTime.now();

    setState(() {
      _time =
          '${_twoDigits(currentTime.hour)}:'
          '${_twoDigits(currentTime.minute)}';

      _date =
          '${_twoDigits(currentTime.day)} '
          '${_monthName(currentTime.month)} '
          '${currentTime.year}';

      _weekday = _weekdayName(
        currentTime.weekday,
      );
    });
  }

  void _showUnavailableTime() {
    if (!mounted) return;

    setState(() {
      _time = '--:--';
      _date = '-- -- ----';
      _weekday = '';
    });
  }

  String _twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  String _monthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAC',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'OGOS',
      'SEPT',
      'OKT',
      'NOV',
      'DIS',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      'ISNIN',
      'SELASA',
      'RABU',
      'KHAMIS',
      'JUMAAT',
      'SABTU',
      'AHAD',
    ];

    if (weekday < 1 || weekday > 7) {
      return '';
    }

    return weekdays[weekday - 1];
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
  void dispose() {
    InternetGuard().internetAvailable.removeListener(
      _handleInternetStatusChanged,
    );

    _ticker?.cancel();
    _resyncTimer?.cancel();

    super.dispose();
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
        borderRadius: BorderRadius.circular(
          38 * scale,
        ),
        child: Container(
          width: 620 * scale,
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              38 * scale,
            ),
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
              borderRadius: BorderRadius.circular(
                32 * scale,
              ),
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
                    borderRadius: BorderRadius.circular(
                      28 * scale,
                    ),
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
                          color:
                              Colors.white.withOpacity(0.85),
                          borderRadius:
                              BorderRadius.circular(
                            18 * scale,
                          ),
                          border: Border.all(
                            color: primaryBlue.withOpacity(
                              0.15,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _weekday,
                              style: TextStyle(
                                fontSize: 40 * scale,
                                fontWeight:
                                    FontWeight.w900,
                                color: primaryBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.symmetric(
                                horizontal: 18 * scale,
                              ),
                              width: 1.5,
                              height: 26 * scale,
                              color:
                                  primaryBlue.withOpacity(
                                0.18,
                              ),
                            ),
                            Text(
                              _date,
                              style: TextStyle(
                                fontSize: 36 * scale,
                                fontWeight:
                                    FontWeight.w700,
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
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      _statusIcon(),
                      size: 40 * scale,
                      color: _statusColor(),
                    ),
                    SizedBox(width: 10 * scale),
                    Flexible(
                      child: Text(
                        'MALAYSIAN STANDARD TIME',
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