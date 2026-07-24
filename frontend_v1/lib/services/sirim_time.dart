import 'package:flutter/foundation.dart';
import 'package:ntp/ntp.dart';

class SirimTime {
  SirimTime._();

  static Duration _offset = Duration.zero;
  static bool _hasSynced = false;

  static const List<String> _hosts = [
    'ntp1.sirim.my',
    'ntp2.sirim.my',
  ];

  static Future<bool> sync() async {
    _hasSynced = false;

    for (final host in _hosts) {
      try {
        debugPrint(
          '[SirimTime] Connecting to $host...',
        );

        final offsetMilliseconds =
            await NTP.getNtpOffset(
          lookUpAddress: host,
          timeout: const Duration(seconds: 3),
        );

        _offset = Duration(
          milliseconds: offsetMilliseconds,
        );

        _hasSynced = true;

        debugPrint(
          '[SirimTime] Sync successful through $host. '
          'Offset: ${offsetMilliseconds}ms',
        );

        return true;
      } catch (error) {
        debugPrint(
          '[SirimTime] Sync failed through $host: $error',
        );
      }
    }

    _hasSynced = false;

    debugPrint(
      '[SirimTime] Unable to synchronize with SIRIM.',
    );

    return false;
  }

  /// Use SirimTime.now() instead of DateTime.now().
  static DateTime now() {
    return DateTime.now().add(_offset);
  }

  static bool get hasSynced => _hasSynced;

  static Duration get offset => _offset;
}