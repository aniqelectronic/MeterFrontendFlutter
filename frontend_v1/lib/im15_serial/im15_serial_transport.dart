import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'im15_serial_settings.dart';
import 'im15_transport.dart';

class IM15SerialTransport implements IM15Transport {
  final String portPath;
  final IM15SerialSettings cfg;

  SerialPort? _port;

  IM15SerialTransport(this.portPath, this.cfg);

  // ============================================================
  // FIXED: The issue is that SerialPort needs to be created
  // AFTER the config is set, not before
  // ============================================================
  @override
  Future<void> ensureOpen() async {
    if (_port?.isOpen == true) {
      print('[IM15Transport] Port already open: $portPath');
      return;
    }

    Object? lastError;

    // Resolve symlinks (important for /dev/serial/by-id)
    String actualPath;
    try {
      actualPath = File(portPath).resolveSymbolicLinksSync();
      print('[IM15Transport] Resolved path: $portPath -> $actualPath');
    } catch (e) {
      actualPath = portPath;
      print('[IM15Transport] Using direct path: $portPath');
    }

    // Verify file exists and is accessible
    if (!File(actualPath).existsSync()) {
      throw StateError('Serial port file does not exist: $actualPath');
    }

    // Check if we can read the file (basic permission check)
    try {
      final stat = File(actualPath).statSync();
      print('[IM15Transport] Port file stat: ${stat.modeString()}');
    } catch (e) {
      print('[IM15Transport] Warning: Cannot stat file: $e');
    }

    // Increased retries for Jetson Nano USB stability
    for (int attempt = 1; attempt <= 8; attempt++) {
      try {
        // Progressive delay - Jetson Nano needs more time between attempts
        final delayMs = 300 + (attempt * 200);
        print('[IM15Transport] Attempt $attempt/8 - waiting ${delayMs}ms before open...');
        await Future.delayed(Duration(milliseconds: delayMs));
        
        // CRITICAL FIX: Create SerialPort instance fresh each time
        final port = SerialPort(actualPath);
        
        // Check if port is available before trying to open
        final availablePorts = SerialPort.availablePorts;
        print('[IM15Transport] Available ports: $availablePorts');
        
        if (!availablePorts.contains(actualPath)) {
          // Try to find the port by name
          final portName = actualPath.split('/').last;
          final matchingPort = availablePorts.firstWhere(
            (p) => p.contains(portName),
            orElse: () => '',
          );
          
          if (matchingPort.isEmpty) {
            print('[IM15Transport] Port not in available ports list, trying anyway...');
          } else {
            print('[IM15Transport] Found matching port: $matchingPort');
          }
        }
        
        print('[IM15Transport] Configuring port settings...');
        
        // CRITICAL: Get config BEFORE modifying it
        final config = SerialPortConfig();
        config.baudRate = cfg.baudRate;
        config.bits = cfg.dataBits;
        config.stopBits = cfg.stopBits;
        config.parity = cfg.parity;
        
        // Set flow control to none (important for Jetson)
        config.rts = SerialPortRts.off;
        config.cts = SerialPortCts.ignore;
        config.dsr = SerialPortDsr.ignore;
        config.dtr = SerialPortDtr.off;
        
        // Apply config BEFORE opening
        port.config = config;

        print('[IM15Transport] Opening port with openReadWrite()...');
        
        // Try to open the port
        final opened = port.openReadWrite();
        
        if (!opened) {
          final error = SerialPort.lastError;
          final errorCode = error?.errorCode ?? -1;
          final errorMessage = error?.message ?? 'Unknown error';
          print('[IM15Transport] openReadWrite returned false');
          print('[IM15Transport] Error code: $errorCode');
          print('[IM15Transport] Error message: $errorMessage');
          
          // Clean up
          try {
            port.close();
          } catch (_) {}
          
          throw StateError('openReadWrite returned false - Error $errorCode: $errorMessage');
        }

        // Additional settling time after successful open
        await Future.delayed(const Duration(milliseconds: 500));
        
        _port = port;
        print('[IM15Transport] ✅ Port opened successfully on attempt $attempt');
        return;
        
      } catch (e, stackTrace) {
        print('[IM15Transport] ❌ Attempt $attempt failed: $e');
        print('[IM15Transport] Stack trace: $stackTrace');
        lastError = e;
        
        try {
          _port?.close();
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (closeError) {
          print('[IM15Transport] Error closing port: $closeError');
        }
        _port = null;
      }
    }

    throw StateError(
      'Failed to open serial port after 8 retries ($portPath -> $actualPath): $lastError',
    );
  }

  @override
  Future<void> write(List<int> data) async {
    await ensureOpen();
    final written = _port!.write(Uint8List.fromList(data));
    if (written != data.length) {
      throw StateError('Write incomplete ($written/${data.length})');
    }
  }

  @override
  Future<int> read(List<int> buffer) async {
    await ensureOpen();
    final deadline =
        DateTime.now().add(Duration(milliseconds: cfg.readTimeoutMs));

    while (DateTime.now().isBefore(deadline)) {
      final chunk = _port!.read(buffer.length);
      if (chunk.isNotEmpty) {
        buffer.setAll(0, chunk);
        return chunk.length;
      }
      await Future.delayed(const Duration(milliseconds: 5));
    }

    return -1;
  }

  @override
  bool get isOpen => _port?.isOpen ?? false;

  @override
  Future<void> close() async {
    try {
      if (_port?.isOpen == true) {
        print('[IM15Transport] Closing port: $portPath');
        _port?.close();
        // Add delay after close for Jetson stability
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } finally {
      _port = null;
    }
  }
}