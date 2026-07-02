import 'dart:io';

import 'im15_native_serial_transport.dart';
import 'im15_serial_settings.dart';

class IM15PortDetector {
  static const int _probeTimeoutMs = 2000;

  static Future<String?> detect() async {
    print('[IM15PortDetector] Starting port detection...');

    // 1. Manual override from Linux env:
    // export IM15_PORT=/dev/ttyUSB5
    final envOverride = Platform.environment['IM15_PORT'];
    if (_isValid(envOverride)) {
      print('[IM15PortDetector] Checking ENV port: $envOverride');
      if (await _isOpenable(envOverride!)) {
        print('[IM15PortDetector] ✅ Using ENV port: $envOverride');
        return envOverride;
      }
    }

    // 2. Best method: stable USB serial symlink
    // Example:
    // /dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_D-if00-port0
    final byIdPort = await _detectById();
    if (byIdPort != null) {
      return byIdPort;
    }

    // 3. Fallback: scan ttyUSB/ttyACM but skip SIM7600 modem ports
    final scannedPort = await _scanSafeTtyPorts();
    if (scannedPort != null) {
      return scannedPort;
    }

    print('[IM15PortDetector] ❌ No IM15 serial port found');
    return null;
  }

  static Future<String?> _detectById() async {
    final byIdDir = Directory('/dev/serial/by-id');

    if (!byIdDir.existsSync()) {
      print('[IM15PortDetector] /dev/serial/by-id does not exist');
      return null;
    }

    print('[IM15PortDetector] Scanning /dev/serial/by-id...');

    final entries = byIdDir.listSync();

    for (final e in entries) {
      final path = e.path;
      final lower = path.toLowerCase();

      // Skip SIM7600 modem
      if (_isSimTechPath(lower)) {
        print('[IM15PortDetector] Skipping SIM7600 by-id: $path');
        continue;
      }

      // Prefer USB-RS232 adapter names
      final looksLikeUsbSerial =
          lower.contains('prolific') ||
          lower.contains('pl2303') ||
          lower.contains('ftdi') ||
          lower.contains('cp210') ||
          lower.contains('ch340') ||
          lower.contains('usb-serial') ||
          lower.contains('usb_serial') ||
          lower.contains('serial_controller');

      if (!looksLikeUsbSerial) {
        print('[IM15PortDetector] Skipping unknown by-id: $path');
        continue;
      }

      final resolvedPath = await _resolveSymlink(path);
      print('[IM15PortDetector] Candidate by-id: $path -> $resolvedPath');

      if (await _isOpenable(path)) {
        print('[IM15PortDetector] ✅ Using stable by-id port: $path');
        return path;
      }
    }

    return null;
  }

  static Future<String?> _scanSafeTtyPorts() async {
    final devDir = Directory('/dev');

    if (!devDir.existsSync()) {
      return null;
    }

    print('[IM15PortDetector] Scanning /dev safely...');

    final ports = devDir
        .listSync()
        .where((e) {
          final name = e.path.split('/').last;
          return name.startsWith('ttyUSB') || name.startsWith('ttyACM');
        })
        .map((e) => e.path)
        .toList()
      ..sort();

    for (final port in ports) {
      // Very important: skip SIM7600 ports
      if (await _isSimTechPort(port)) {
        print('[IM15PortDetector] Skipping SIM7600 modem port: $port');
        continue;
      }

      if (!await _isUsbSerialAdapter(port)) {
        print('[IM15PortDetector] Skipping non-IM15 serial port: $port');
        continue;
      }

      print('[IM15PortDetector] Testing possible IM15 port: $port');

      if (await _isOpenable(port)) {
        print('[IM15PortDetector] ✅ Using detected IM15 port: $port');
        return port;
      }
    }

    return null;
  }

  static Future<bool> _isUsbSerialAdapter(String port) async {
    final props = await _udevProps(port);
    final joined = props.toLowerCase();

    return joined.contains('prolific') ||
        joined.contains('pl2303') ||
        joined.contains('ftdi') ||
        joined.contains('cp210') ||
        joined.contains('ch340') ||
        joined.contains('usb-serial') ||
        joined.contains('usb_serial');
  }

  static Future<bool> _isSimTechPort(String port) async {
    final props = await _udevProps(port);
    return _isSimTechPath(props.toLowerCase());
  }

  static bool _isSimTechPath(String s) {
    return s.contains('simtech') ||
        s.contains('simcom') ||
        s.contains('1e0e') ||
        s.contains('9011') ||
        s.contains('qualcomm') ||
        s.contains('option');
  }

  static Future<String> _udevProps(String port) async {
    try {
      final result = await Process.run(
        'udevadm',
        ['info', '-q', 'property', '-n', port],
      );

      return '${result.stdout}\n${result.stderr}';
    } catch (e) {
      print('[IM15PortDetector] Failed udev check for $port: $e');
      return '';
    }
  }

  static Future<String> _resolveSymlink(String path) async {
    try {
      final result = await Process.run('readlink', ['-f', path]);
      return result.stdout.toString().trim();
    } catch (_) {
      return path;
    }
  }

  static bool _isValid(String? s) => s != null && s.trim().isNotEmpty;

  static Future<bool> _isOpenable(String portPath) async {
    try {
      if (!File(portPath).existsSync() && !Link(portPath).existsSync()) {
        print('[IM15PortDetector] ❌ Port does not exist: $portPath');
        return false;
      }

      print('[IM15PortDetector] Attempting to open: $portPath');

      final t = IM15NativeSerialTransport(
        portPath,
        IM15SerialSettings(openTimeoutMs: _probeTimeoutMs),
      );

      await t.ensureOpen();
      await t.close();

      await Future.delayed(const Duration(milliseconds: 300));

      print('[IM15PortDetector] ✅ Port openable: $portPath');
      return true;
    } catch (e) {
      print('[IM15PortDetector] ❌ Failed to open $portPath: $e');
      return false;
    }
  }
}