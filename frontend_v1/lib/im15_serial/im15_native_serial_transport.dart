import 'dart:typed_data';
import 'dart:async';
import 'native_serial_port.dart';
import 'im15_serial_settings.dart';
import 'im15_transport.dart';

class IM15NativeSerialTransport implements IM15Transport {
  final String portPath;
  final IM15SerialSettings cfg;

  NativeSerialPort? _port;

  IM15NativeSerialTransport(this.portPath, this.cfg);

  @override
  Future<void> ensureOpen() async {
    if (_port?.isOpen == true) {
      print('[IM15NativeTransport] Port already open: $portPath');
      return;
    }

    Object? lastError;

    // Retry logic for Jetson Nano
    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        print('[IM15NativeTransport] Attempt $attempt/5 - opening $portPath');
        
        // Small delay between attempts
        if (attempt > 1) {
          await Future.delayed(Duration(milliseconds: 300 * attempt));
        }
        
        final port = NativeSerialPort(portPath);
        
        final opened = port.open(
          baudRate: cfg.baudRate,
          dataBits: cfg.dataBits,
          stopBits: cfg.stopBits,
          parity: cfg.parity,
        );
        
        if (!opened) {
          throw StateError('Failed to open port');
        }

        // Settling time
        await Future.delayed(const Duration(milliseconds: 500));
        
        _port = port;
        print('[IM15NativeTransport] ✅ Port opened successfully on attempt $attempt');
        return;
        
      } catch (e) {
        print('[IM15NativeTransport] ❌ Attempt $attempt failed: $e');
        lastError = e;
        
        try {
          _port?.close();
        } catch (_) {}
        _port = null;
      }
    }

    throw StateError(
      'Failed to open serial port after 5 retries ($portPath): $lastError',
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
    final deadline = DateTime.now().add(Duration(milliseconds: cfg.readTimeoutMs));

    while (DateTime.now().isBefore(deadline)) {
      final chunk = _port!.read(buffer.length, timeoutMs: 100);
      if (chunk != null && chunk.isNotEmpty) {
        for (int i = 0; i < chunk.length && i < buffer.length; i++) {
          buffer[i] = chunk[i];
        }
        return chunk.length;
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }

    return -1;
  }

  @override
  bool get isOpen => _port?.isOpen ?? false;

  @override
  Future<void> close() async {
    try {
      if (_port?.isOpen == true) {
        print('[IM15NativeTransport] Closing port: $portPath');
        _port?.close();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } finally {
      _port = null;
    }
  }
}