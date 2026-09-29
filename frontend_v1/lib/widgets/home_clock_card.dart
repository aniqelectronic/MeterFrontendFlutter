import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_v1/services/internet/internet_guard.dart';
import 'package:frontend_v1/services/sirim/sirim_time.dart';

class HomeClockCard extends StatefulWidget {
  final double width;
  final double height;

  const HomeClockCard({
    super.key,
    this.width = 360,
    this.height = 180,
  });

  @override
  State<HomeClockCard> createState() => _HomeClockCardState();
}

class _HomeClockCardState extends State<HomeClockCard> {
  String _time = '--:--';
  String _date = '-- -- ----';
  String _weekday = '';

  Timer? _ticker;
  Timer? _resyncTimer;

  bool _hasInternet = true;
  bool _syncInProgress = false;

  // 0 = SIRIM synchronized
  // 1 = synchronizing
  // 2 = no internet / synchronization failed
  int _syncStatus = 1;

  static const Duration _resyncInterval = Duration(
    minutes: 15,
  );

  static const Duration _retryInterval = Duration(
    seconds: 5,
  );

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
        '[HomeClockCard] Internet lost.',
      );

      _resyncTimer?.cancel();
      _resyncTimer = null;

      setState(() {
        _syncStatus = 2;
      });

      _showUnavailableTime();
    } else {
      debugPrint(
        '[HomeClockCard] Internet restored. Synchronizing...',
      );

      setState(() {
        _syncStatus = 1;
      });

      _updateTime();

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

    _scheduleNextSync(
      success: success,
    );
  }

  Future<bool> _syncWithSirim() async {
    if (!mounted || !_hasInternet) {
      return false;
    }

    if (_syncInProgress) {
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
        '[HomeClockCard] SIRIM error: $error',
      );

      success = false;
    } finally {
      _syncInProgress = false;
    }

    if (!mounted) {
      return success;
    }

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
    return number.toString().padLeft(
      2,
      '0',
    );
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
        return const Color(0xFF20B76A);

      case 1:
        return const Color(0xFFFFB800);

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
    InternetGuard()
        .internetAvailable
        .removeListener(
          _handleInternetStatusChanged,
        );

    _ticker?.cancel();
    _resyncTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF071D49);
    const blue = Color(0xFF0878F9);
    const secondaryText = Color(0xFF586B86);

    return Container(
      width: widget.width,
      height: widget.height,

      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        10,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: Colors.white.withOpacity(0.95),
          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// ======================================================
          /// TIME + DAY/DATE
          ///
          /// 16:19   │ SELASA
          ///         │ 29 SEPT 2026
          /// ======================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// TIME
              SizedBox(
                width: 115,

                child: FittedBox(
                  fit: BoxFit.scaleDown,

                  child: Text(
                    _time,
                    maxLines: 1,

                    style: const TextStyle(
                      fontSize: 50,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      color: navy,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// DIVIDER
              Container(
                width: 1.5,
                height: 67,
                color: const Color(0xFFD8E7F7),
              ),

              const SizedBox(width: 16),

              /// DAY + DATE
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    /// DAY
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFEAF4FF),

                        borderRadius:
                            BorderRadius.circular(7),
                      ),

                      child: Text(
                        _weekday,
                        maxLines: 1,

                        style: const TextStyle(
                          color: blue,
                          fontSize: 25,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    /// DATE
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment:
                          Alignment.centerLeft,

                      child: Text(
                        _date,
                        maxLines: 1,

                        style: const TextStyle(
                          color: navy,
                          fontSize: 25,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ======================================================
          /// MALAYSIA STANDARD TIME
          /// ======================================================
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Icon(
                  _statusIcon(),
                  size: 17,
                  color: _statusColor(),
                ),

                const SizedBox(width: 7),

                const Text(
                  'MALAYSIA STANDARD TIME',
                  maxLines: 1,

                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}