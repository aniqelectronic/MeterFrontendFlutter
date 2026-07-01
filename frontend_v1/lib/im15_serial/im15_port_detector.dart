import 'dart:io';
import 'im15_native_serial_transport.dart';
import 'im15_serial_settings.dart';

class IM15PortDetector {
  static const List<String> _keywords = [
    'pax',
    'im15',
    'reader',
    'payment',
    'usb',
    'serial',
    'ftdi',
    'cp210',
    'ch340',
    'acm',
    'pl2303',
    'prolific',
    'usb-serial',
  ];

  static const int _probeTimeoutMs = 2000;

  /// Main detect method - NOW USING NATIVE SERIAL
  static Future<String?> detect() async {
    print('[IM15PortDetector] Starting port detection (NATIVE MODE)...');
    
    // 1️⃣ ENV override (IM15_PORT)
    final envOverride = Platform.environment['IM15_PORT'];
    if (_isValid(envOverride)) {
      print('[IM15PortDetector] Checking ENV override: $envOverride');
      if (await _isOpenable(envOverride!)) {
        print('[IM15PortDetector] ✅ Using ENV port: $envOverride');
        return envOverride;
      }
    }

    // 2️⃣ Direct Jetson / Linux fallback - CHECK FILE EXISTS FIRST
    const fallbackPorts = [
  '/dev/ttyUSB5',
  '/dev/ttyUSB0',
  '/dev/ttyUSB1',
  '/dev/ttyUSB2',
  '/dev/ttyUSB3',
  '/dev/ttyUSB4',
  '/dev/ttyACM0',
];
    for (final port in fallbackPorts) {
      print('[IM15PortDetector] Checking fallback port: $port');
      
      // First check if file exists
      if (!File(port).existsSync()) {
        print('[IM15PortDetector] ❌ Port does not exist: $port');
        continue;
      }
      
      print('[IM15PortDetector] ✓ Port file exists: $port, testing if openable...');
      if (await _isOpenable(port)) {
        print('[IM15PortDetector] ✅ Using fallback port: $port');
        return port;
      }
    }

    final List<_Candidate> candidates = [];

    // 3️⃣ Stable aliases: /dev/serial/by-id
    final byIdDir = Directory('/dev/serial/by-id');
    if (byIdDir.existsSync()) {
      print('[IM15PortDetector] Scanning /dev/serial/by-id...');
      for (final e in byIdDir.listSync()) {
        final path = e.path;
        final lower = path.toLowerCase();
        int score = 90;
        
        // Boost score for Prolific devices
        if (lower.contains('prolific')) score += 20;
        
        print('[IM15PortDetector] Found by-id device: $path (score: $score)');
        candidates.add(_Candidate(path: path, score: score));
      }
    }

    // 4️⃣ Scan tty devices
    final devDir = Directory('/dev');
    if (devDir.existsSync()) {
      print('[IM15PortDetector] Scanning /dev for tty devices...');
      for (final e in devDir.listSync()) {
        final name = e.path.split('/').last;
        if (name.startsWith('ttyUSB') || name.startsWith('ttyACM')) {
          int score = 50;
          final lower = name.toLowerCase();
          if (_containsKeyword(lower)) score += 40;
          print('[IM15PortDetector] Found tty device: ${e.path} (score: $score)');
          candidates.add(_Candidate(path: e.path, score: score));
        }
      }
    }

    // 5️⃣ Sort by score
    candidates.sort((a, b) => b.score.compareTo(a.score));

    // 6️⃣ Probe ports
    print('[IM15PortDetector] Probing ${candidates.length} candidate ports...');
    for (final c in candidates) {
      print('[IM15PortDetector] Testing candidate: ${c.path}');
      if (await _isOpenable(c.path)) {
        print('[IM15PortDetector] ✅ Successfully opened: ${c.path}');
        return c.path;
      }
    }

    print('[IM15PortDetector] ❌ No valid port found');
    return null;
  }

  static bool _isValid(String? s) => s != null && s.trim().isNotEmpty;

  static bool _containsKeyword(String s) {
    for (final k in _keywords) {
      if (s.contains(k)) return true;
    }
    return false;
  }

  static Future<bool> _isOpenable(String portPath) async {
    try {
      print('[IM15PortDetector] Attempting to open (NATIVE): $portPath');
      
      // Use native serial transport
      final t = IM15NativeSerialTransport(
        portPath, 
        IM15SerialSettings(openTimeoutMs: 2000)
      );
      
      await t.ensureOpen();
      print('[IM15PortDetector] Port opened successfully: $portPath');
      
      await t.close();
      print('[IM15PortDetector] Port closed successfully: $portPath');
      
      // Delay after close
      await Future.delayed(const Duration(milliseconds: 800));
      
      return true;
    } catch (e) {
      print('[IM15PortDetector] ❌ Failed to open $portPath: $e');
      return false;
    }
  }
}

class _Candidate {
  final String path;
  final int score;

  _Candidate({required this.path, required this.score});
}