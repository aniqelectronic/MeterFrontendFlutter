import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:frontend_v1/im15_utils/im15_transaction_logger.dart';

class IM15SerialManager {
  static const int STX = 0x02;
  static const int ETX = 0x03;
  static const int ENQ = 0x05;
  static const int ACK = 0x06;
  static const int EOT = 0x04;

  late SerialPort _port;
  late SerialPortReader _reader;
  final StreamController<int> _rxController = StreamController<int>.broadcast();

  // ---------- PORT SETUP ----------
  bool open(String portName) {
    _port = SerialPort(portName);
    if (!_port.openReadWrite()) return false;

    _port.config = SerialPortConfig()
      ..baudRate = 9600
      ..bits = 8
      ..stopBits = 1
      ..parity = SerialPortParity.none;

    _reader = SerialPortReader(_port);
    _reader.stream.listen((Uint8List data) {
      for (final byte in data) {
        _rxController.add(byte);
      }
    });

    return true;
  }

  void close() {
    _reader.close();
    _port.close();
  }

  // ---------- SEND METHODS ----------
  void sendByte(int byte) => _port.write(Uint8List.fromList([byte]));
  void sendBytes(Uint8List bytes, {String label = 'Packet'}) => _port.write(bytes);

  void sendPacket(Uint8List packet, String label, [IM15TransactionLogger? logger]) {
    sendByte(STX);
    logger?.logSend('STX ($label)');
    traceableSend(packet, label, logger);
  }

  void traceableSend(Uint8List bytes, String label, [IM15TransactionLogger? logger]) {
    sendBytes(bytes);
    if (logger != null) {
      final hexStr = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      logger.logInfo('$label HEX: $hexStr');
    }
  }

  // ---------- WAIT FOR BYTE ----------
  Future<bool> waitForByte(int expected, int timeoutMillis) async {
    final completer = Completer<bool>();
    late StreamSubscription sub;

    sub = _rxController.stream.listen((int received) {
      if (received == expected) {
        sub.cancel();
        completer.complete(true);
      }
    });

    Future.delayed(Duration(milliseconds: timeoutMillis), () {
      if (!completer.isCompleted) {
        sub.cancel();
        completer.complete(false);
      }
    });

    return completer.future;
  }

  // ---------- READ PACKETS ----------
  Future<Uint8List> _readPacket(IM15TransactionLogger? logger, String label) async {
    final List<int> buffer = [];
    bool etxReceived = false;

    while (true) {
      final int byte = await _rxController.stream.first;
      buffer.add(byte);

      if (logger != null) {
        logger.logRecvBytes(Uint8List.fromList([byte]), label);
      }

      if (byte == ETX) {
        etxReceived = true;
        continue; // next byte is LRC
      }

      if (etxReceived && buffer.length >= 2) break;
    }

    if (logger != null) {
      logger.logRecvBytes(Uint8List.fromList(buffer), label);
      logger.logInfo('Received $label (${buffer.length} bytes)');
    }

    return Uint8List.fromList(buffer);
  }

  Future<Uint8List> readR200Packet([IM15TransactionLogger? logger]) =>
      _readPacket(logger, 'R200 Packet');

  Future<Uint8List> readR201Packet([IM15TransactionLogger? logger]) =>
      _readPacket(logger, 'R201 Packet');

  Future<Uint8List> readR500Packet([IM15TransactionLogger? logger]) =>
      _readPacket(logger, 'R500 Packet');

  Future<Uint8List> readR902Packet([IM15TransactionLogger? logger]) =>
      _readPacket(logger, 'R902 Packet');

  // Optional generic read until a stop byte (like ETX)
  Future<String> readUntil(int stopByte, [bool onlyPrintable = true]) async {
    final List<int> buffer = [];
    while (true) {
      final int byte = await _rxController.stream.first;
      if (byte == stopByte) break;
      if (!onlyPrintable || (byte >= 0x20 && byte <= 0x7E)) buffer.add(byte);
    }
    return ascii.decode(buffer);
  }

  Future<Uint8List> readResponsePacket([IM15TransactionLogger? logger]) async {
  final List<int> buffer = [];
  bool etxReceived = false;

  while (true) {
    final int byte = await _rxController.stream.first;
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
  }

  if (logger != null) {
    logger.logRecvBytes(Uint8List.fromList(buffer), 'Full Response Packet');
  }

  return Uint8List.fromList(buffer);
}



}
