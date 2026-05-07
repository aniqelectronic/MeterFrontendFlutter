import 'dart:async';
import 'dart:io';
import 'im15_native_serial_transport.dart';
import 'im15_serial_settings.dart';
import 'im15_port_detector.dart';
import 'im15_transport.dart';

class IM15SerialConnectionManager {
  final IM15SerialSettings cfg;
  IM15Transport? _transport;

  IM15SerialConnectionManager(this.cfg);

  factory IM15SerialConnectionManager.fromPropertiesMap(
      Map<String, String> props) {
    return IM15SerialConnectionManager(
      IM15SerialSettings.fromMap(props),
    );
  }

  // ============================================================
  // NOW USING NATIVE SERIAL TRANSPORT
  // ============================================================
  Future<IM15Transport> detectAndOpen() async {
    print('[IM15ConnectionManager] Starting detectAndOpen (NATIVE MODE)...');
    await close();

    final rawPath = await _detectStablePort();
    final resolvedPath = _resolvePath(rawPath);

    print('[IM15ConnectionManager] Using serial port: $resolvedPath');

    final transport = IM15NativeSerialTransport(resolvedPath, cfg);
    await transport.ensureOpen();

    _transport = transport;
    print('[IM15ConnectionManager] ✅ Serial port opened successfully');
    return transport;
  }

  Future<String> _detectStablePort() async {
    print('[IM15ConnectionManager] Detecting stable port...');
    
    // 1️⃣ Explicit port
    if (cfg.explicitPort != null && cfg.explicitPort!.isNotEmpty) {
      final p = cfg.explicitPort!;
      print('[IM15ConnectionManager] Using explicit port: $p');
      
      for (int i = 0; i < 20; i++) {
        if (File(p).existsSync()) {
          print('[IM15ConnectionManager] ✅ Explicit port found: $p');
          return p;
        }
        print('[IM15ConnectionManager] Waiting for explicit port (attempt ${i + 1}/20)...');
        await Future.delayed(const Duration(milliseconds: 300));
      }
      throw StateError('Explicit port not found after 6s: $p');
    }

    // 2️⃣ Use IM15PortDetector for automatic detection
    print('[IM15ConnectionManager] Running automatic port detection...');
    final detectedPort = await IM15PortDetector.detect();
    
    if (detectedPort != null) {
      print('[IM15ConnectionManager] ✅ Auto-detected port: $detectedPort');
      return detectedPort;
    }

    // 3️⃣ Fallback: Wait for ttyUSB0
    print('[IM15ConnectionManager] Fallback: Waiting for /dev/ttyUSB0...');
    const ttyUsb0 = '/dev/ttyUSB0';
    
    for (int i = 0; i < 20; i++) {
      if (File(ttyUsb0).existsSync()) {
        print('[IM15ConnectionManager] ✅ Found ttyUSB0 on attempt ${i + 1}');
        return ttyUsb0;
      }
      print('[IM15ConnectionManager] ttyUSB0 not found (attempt ${i + 1}/20)');
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // 4️⃣ Last resort: Check /dev/serial/by-id
    print('[IM15ConnectionManager] Checking /dev/serial/by-id...');
    final byId = Directory('/dev/serial/by-id');
    
    for (int i = 0; i < 20; i++) {
      if (byId.existsSync()) {
        final entries = byId.listSync();
        if (entries.isNotEmpty) {
          final foundPort = entries.first.path;
          print('[IM15ConnectionManager] ✅ Found by-id port: $foundPort');
          return foundPort;
        }
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }

    throw StateError('IM15 not detected - no valid serial port found after all attempts');
  }

  String _resolvePath(String path) {
    try {
      final resolved = File(path).resolveSymbolicLinksSync();
      print('[IM15ConnectionManager] Resolved: $path -> $resolved');
      return resolved;
    } catch (e) {
      print('[IM15ConnectionManager] Path already resolved: $path');
      return path;
    }
  }

  IM15Transport getTransport() {
    if (_transport == null) {
      throw StateError('Transport not opened');
    }
    return _transport!;
  }

  Future<void> close() async {
    if (_transport != null) {
      print('[IM15ConnectionManager] Closing transport...');
      await _transport?.close();
      _transport = null;
    }
  }
}