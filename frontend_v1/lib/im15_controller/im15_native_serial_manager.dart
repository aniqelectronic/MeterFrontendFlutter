import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:frontend_v1/im15_utils/im15_transaction_logger.dart';
import '../im15_serial/native_serial_port.dart';
import 'dart:typed_data';

/// Native Serial Manager using BLOCKING reads (like Java implementation)
/// This ensures no bytes are missed during critical handshake moments
class IM15NativeSerialManager {
  static const int STX = 0x02;
  static const int ETX = 0x03;
  static const int ENQ = 0x05;
  static const int ACK = 0x06;
  static const int EOT = 0x04;

  NativeSerialPort? _port;

  // ---------- PORT SETUP ----------
  bool open(String portName) {
    try {
      print('[IM15NativeSerialManager] Opening port: $portName');
      _port = NativeSerialPort(portName);
      
      final opened = _port!.open(
        baudRate: 9600,
        dataBits: 8,
        stopBits: 1,
        parity: 0, // No parity
      );
      
      if (!opened) {
        print('[IM15NativeSerialManager] Failed to open port');
        return false;
      }
      
      print('[IM15NativeSerialManager] ✅ Port opened successfully');
      return true;
    } catch (e) {
      print('[IM15NativeSerialManager] ❌ Error opening port: $e');
      return false;
    }
  }

  void close() {
    _port?.close();
    _port = null;
    print('[IM15NativeSerialManager] Port closed');
  }

  void sendAbort() {
  sendBytes(Uint8List.fromList('ABORT'.codeUnits));
}

  /// CRITICAL FIX: Force reset card reader by sending multiple EOT bytes
  Future<void> forceReset() async {
    print('[IM15NativeSerialManager] 🔄 FORCE RESET: Sending multiple EOT bytes...');
    try {
      if (_port?.isOpen == true) {
        // Send EOT 5 times with delays to ensure card reader receives it
        for (int i = 0; i < 5; i++) {
          _port!.write(Uint8List.fromList([EOT]));
          print('[IM15NativeSerialManager] 📤 Sent EOT #${i + 1}');
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        // Give card reader time to process
        await Future.delayed(const Duration(milliseconds: 500));
        print('[IM15NativeSerialManager] ✅ Force reset completed');
      } else {
        print('[IM15NativeSerialManager] ⚠️ Port not open, cannot force reset');
      }
    } catch (e) {
      print('[IM15NativeSerialManager] ❌ Error during force reset: $e');
    }
  }

  // ---------- SEND METHODS ----------
  void sendByte(int byte) {
    if (_port?.isOpen == true) {
      _port!.write(Uint8List.fromList([byte]));
      print('[IM15NativeSerialManager] Sent: ${_printable(byte)} (0x${byte.toRadixString(16).padLeft(2, '0')})');
    }
  }

  void sendBytes(Uint8List bytes, {String label = 'Packet'}) {
    if (_port?.isOpen == true) {
      _port!.write(bytes);
      print('[IM15NativeSerialManager] Sent: $label (${bytes.length} bytes)');
    }
  }

  void sendPacket(Uint8List packet, String label, [IM15TransactionLogger? logger]) {
    sendByte(STX);
    logger?.logSend('STX ($label)');
    traceableSend(packet, label, logger);
  }

  void traceableSend(Uint8List bytes, String label, [IM15TransactionLogger? logger]) {
    sendBytes(bytes, label: label);
    if (logger != null) {
      final hexStr = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      logger.logInfo('$label HEX: $hexStr');
    }
  }

  // ---------- BLOCKING WAIT FOR BYTE (like Java) ----------
  Future<bool> waitForByte(int expected, int timeoutMillis) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    
    while (DateTime.now().millisecondsSinceEpoch - start < timeoutMillis) {
      // Check if data is available (blocking read with small timeout)
        final _t0 = DateTime.now();
        final data = _port!.read(1, timeoutMs: 20);
        final _elapsed = DateTime.now().difference(_t0).inMilliseconds;
        if (_elapsed > 25) {
          print('[TIMING] ⚠️ waitForByte read() took ${_elapsed}ms');
        }
      
      if (data != null && data.isNotEmpty) {
        final received = data[0];
        print('[IM15NativeSerialManager] Received: ${_printable(received)} (0x${received.toRadixString(16).padLeft(2, '0')})');
        
        if (received == expected) {
          return true;
        } else {
          // Received unexpected byte, log it but continue waiting
          print('[IM15NativeSerialManager] ⚠️ Expected ${_printable(expected)} but got ${_printable(received)}');
        }
      }
      
      // Small delay between checks (like Java's Thread.sleep(20))
      await Future.delayed(const Duration(milliseconds: 20));
    }
    
    print('[IM15NativeSerialManager] ⏱️ Timeout waiting for ${_printable(expected)}');
    return false;
  }

  // ---------- NEW: WAIT FOR ASCII STRING ----------
  /// Waits for a specific ASCII string (e.g., "PIN", "PEF", "CARD")
  Future<bool> waitForAscii(String expected, int timeoutMillis) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    
    while (DateTime.now().millisecondsSinceEpoch - start < timeoutMillis) {
      final data = _port!.read(1, timeoutMs: 20);
      
      if (data != null && data.isNotEmpty) {
        final byte = data[0];
        
        // Only process printable ASCII characters
        if (byte >= 0x20 && byte <= 0x7E) {
          final char = String.fromCharCode(byte);
          buffer.write(char);
          print('[IM15NativeSerialManager] Received ASCII: \'$char\' (0x${byte.toRadixString(16).padLeft(2, '0')})');
          
          // Check if buffer contains the expected string
          final currentBuffer = buffer.toString();
          if (currentBuffer.contains(expected)) {
            print('[IM15NativeSerialManager] ✅ Detected ASCII string: "$expected"');
            return true;
          }
          
          // Keep buffer reasonable size (max 10 chars)
          if (currentBuffer.length > 10) {
            buffer.clear();
            buffer.write(currentBuffer.substring(currentBuffer.length - 10));
          }
        } else {
          // Non-printable byte, log it
          print('[IM15NativeSerialManager] Received non-printable: ${_printable(byte)}');
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 20));
    }
    
    print('[IM15NativeSerialManager] ⏱️ Timeout waiting for ASCII: "$expected"');
    return false;
  }

  // ---------- BLOCKING READ UNTIL (like Java) ----------
  Future<String> readUntil(int stopByte, [bool onlyPrintable = true]) async {
    return readUntilWithTimeout(stopByte, 5000, onlyPrintable);
  }

  // ---------- BLOCKING READ UNTIL WITH CUSTOM TIMEOUT ----------
  Future<String> readUntilWithTimeout(int stopByte, int timeoutMillis, [bool onlyPrintable = true]) async {
    final List<int> buffer = [];
    final start = DateTime.now().millisecondsSinceEpoch;
    
    while (DateTime.now().millisecondsSinceEpoch - start < timeoutMillis) {
      final data = _port!.read(1, timeoutMs: 20);
      
      if (data != null && data.isNotEmpty) {
        final byte = data[0];
        
        if (byte == stopByte) {
          break;
        }
        
        if (!onlyPrintable || (byte >= 0x20 && byte <= 0x7E)) {
          buffer.add(byte);
        }
      } else {
        // No data available, wait a bit
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }
    
    final result = ascii.decode(buffer);
    if (result.isNotEmpty) {
      print('[IM15NativeSerialManager] Read until ${_printable(stopByte)}: $result (timeout: ${timeoutMillis}ms)');
    } else if (DateTime.now().millisecondsSinceEpoch - start >= timeoutMillis) {
      print('[IM15NativeSerialManager] ⏱️ Timeout reading until ${_printable(stopByte)} after ${timeoutMillis}ms');
    }
    return result;
  }

  // ---------- NEW: READ ASCII RESPONSE WITHOUT NEWLINE ----------
  /// Reads ASCII response that may not end with newline
  /// Stops when no data is received for [silenceTimeout] milliseconds
  Future<String> readAsciiResponse(int maxTimeoutMillis, int silenceTimeout) async {
    final List<int> buffer = [];
    final start = DateTime.now().millisecondsSinceEpoch;
    int lastDataTime = DateTime.now().millisecondsSinceEpoch;
    
    while (DateTime.now().millisecondsSinceEpoch - start < maxTimeoutMillis) {
        final _t0 = DateTime.now();
        final data = _port!.read(1, timeoutMs: 20);
        final _elapsed = DateTime.now().difference(_t0).inMilliseconds;
        if (_elapsed > 25) {
          print('[TIMING] ⚠️ readAsciiResponse read() took ${_elapsed}ms');
        }
      
      if (data != null && data.isNotEmpty) {
        final byte = data[0];
        lastDataTime = DateTime.now().millisecondsSinceEpoch;
        
        // Only add printable ASCII characters
        if (byte >= 0x20 && byte <= 0x7E) {
          buffer.add(byte);
        }
        
        // Check if we have a complete R200 response (ends with 'T')
        if (byte == 0x54 && buffer.length > 50) { // 'T' character
          final response = ascii.decode(buffer);
          if (response.contains('R200')) {
            print('[IM15NativeSerialManager] 🔍 Detected end of R200 response (ends with T)');
            break;
          }
        }
        
        // Check if we have a complete prompt (PIN, PEF, CARD, etc.)
        if (buffer.length >= 3) {
          final response = ascii.decode(buffer);
          if (response.endsWith('PIN') || response.endsWith('PEF') || 
              response.endsWith('CARD') || response.endsWith('CLES') || 
              response.endsWith('MAGS') || response.endsWith('SCAN')) {
            print('[IM15NativeSerialManager] 🔍 Detected complete prompt');
            break;
          }
        }
      } else {
        // No data received, check if we've been silent too long
        if (DateTime.now().millisecondsSinceEpoch - lastDataTime > silenceTimeout) {
          print('[IM15NativeSerialManager] ⏱️ No data for ${silenceTimeout}ms, stopping read');
          break;
        }
        
        // Small delay between checks
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
    
    final result = ascii.decode(buffer);
    if (result.isNotEmpty) {
      print('[IM15NativeSerialManager] 📨 Read ASCII response (${buffer.length} bytes): ${result.length > 50 ? result.substring(0, 50) + '...' : result}');
    }
    
    return result;
  }

  // ---------- BLOCKING READ RESPONSE PACKET (like Java) ----------
  Future<Uint8List> readResponsePacket([IM15TransactionLogger? logger]) async {
    final List<int> buffer = [];
    bool etxReceived = false;

    while (true) {
      final data = _port!.read(1, timeoutMs: 20);
      
      if (data != null && data.isNotEmpty) {
        final byte = data[0];
        buffer.add(byte);
        
        if (logger != null) {
          logger.logRecvBytes(Uint8List.fromList([byte]), 'Response Packet');
        }
        
        if (byte == ETX) {
          etxReceived = true;
          continue; // next byte is LRC
        }
        
        // After ETX, the next byte is LRC, then stop
        if (etxReceived && buffer.length >= 2) {
          break;
        }
      } else {
        // No data available, wait a bit (like Java's Thread.sleep(10))
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    if (logger != null) {
      logger.logRecvBytes(Uint8List.fromList(buffer), 'Full Response Packet');
    }
    
    print('[IM15NativeSerialManager] Read response packet (${buffer.length} bytes)');
    return Uint8List.fromList(buffer);
  }

  Future<Uint8List> readR200Packet([IM15TransactionLogger? logger]) async {
    return readResponsePacket(logger);
  }

  Future<Uint8List> readR201Packet([IM15TransactionLogger? logger]) async {
    return readResponsePacket(logger);
  }

  Future<Uint8List> readR500Packet([IM15TransactionLogger? logger]) async {
    return readResponsePacket(logger);
  }

  Future<Uint8List> readR902Packet([IM15TransactionLogger? logger]) async {
    return readResponsePacket(logger);
  }

  Future<Uint8List> readR208Packet([IM15TransactionLogger? logger]) async {
    return readResponsePacket(logger);
  }

  Future<Uint8List> readQ290Packet([IM15TransactionLogger? logger]) async {
    return readResponsePacket(logger);
  }

  // ---------- UTILS ----------
  String _printable(int byte) {
    switch (byte) {
      case STX:
        return 'STX';
      case ETX:
        return 'ETX';
      case ENQ:
        return 'ENQ';
      case ACK:
        return 'ACK';
      case EOT:
        return 'EOT';
      default:
        if (byte >= 0x20 && byte <= 0x7E) {
          return "'${String.fromCharCode(byte)}'";
        }
        return '0x${byte.toRadixString(16).padLeft(2, '0')}';
    }
  }
}