import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'im15_native_serial_manager.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_utils/im15_packet_builder.dart';
import '../im15_utils/im15_transaction_logger.dart';

class PaxIM15C200Sale {
  Future<IM15ResponseModel?> executeSale(
    String portName,
    String amountInCents,
    String transactionId,
    IM15TransactionLogger logger, {
    VoidCallback? onPINRequired,
    VoidCallback? onPINCompleted,
    Function(String)? onPINEntered,
  }) async {
    final serial = IM15NativeSerialManager();

    IM15ResponseModel? model;
    bool transactionStarted = false;

    try {
      final opened = serial.open(portName);
      if (!opened) {
        print('[PaxIM15C200Sale] ❌ Failed to open port: $portName');
        logger.logInfo('Failed to open port: $portName');
        return null;
      }

      // 1. PC sends ENQ, terminal replies ACK.
      serial.sendByte(IM15NativeSerialManager.ENQ);
      logger.logSend('ENQ');
      transactionStarted = true;

      final gotAckAfterEnq =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 8000);

      if (!gotAckAfterEnq) {
        print('[PaxIM15C200Sale] ❌ No ACK after ENQ');
        logger.logInfo('No ACK after ENQ');
        return null;
      }

      print('[PaxIM15C200Sale] ✅ ACK after ENQ');
      logger.logRecv('ACK');

      // 2. Build and send C200 sale packet.
      final Uint8List c200 = IM15PacketBuilder.buildC200Packet(
        '00',          // Host No
        '0',           // Account Type: 0 = card
        amountInCents, // Amount from kiosk
        transactionId, // Transaction ID / order reference
      );

      serial.sendByte(IM15NativeSerialManager.STX);
      logger.logSend('STX');

      serial.sendBytes(c200);
      logger.logSend('C200 packet (${c200.length} bytes)');

      // 3. Terminal should ACK the C200 packet.
      final gotAckAfterC200 =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 8000);

      if (!gotAckAfterC200) {
        print('[PaxIM15C200Sale] ❌ No ACK after C200');
        logger.logInfo('No ACK after C200');
        return null;
      }

      print('[PaxIM15C200Sale] ✅ ACK after C200');
      logger.logRecv('ACK');

      // 4. Wait for prompts or final R200.
      model = await _waitForTerminalResponse(
        serial,
        logger,
        amountInCents,
        onPINRequired: onPINRequired,
        onPINCompleted: onPINCompleted,
      );

      if (model == null) {
        print('[PaxIM15C200Sale] ❌ No valid R200 model');
        logger.logInfo('No valid R200 model');
        return null;
      }

      print('[PaxIM15C200Sale] ✅ Returning model');
      print('[PaxIM15C200Sale] Status: ${model.statusCode}');
      print('[PaxIM15C200Sale] Bank Trx/RRN: ${model.rrn}');
      logger.logInfo('Transaction completed with status ${model.statusCode}');
      return model;
    } catch (e) {
      print('[PaxIM15C200Sale] ❌ Error: $e');
      logger.logInfo('Error: $e');
      return null;
    } finally {
      if (transactionStarted && model == null) {
        try {
          serial.sendByte(IM15NativeSerialManager.EOT);
          logger.logSend('EOT cleanup');
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (_) {}
      }

      try {
        serial.close();
        print('[PaxIM15C200Sale] 🔒 Serial closed');
        logger.logInfo('Serial closed');
      } catch (_) {}
    }
  }

  Future<IM15ResponseModel?> _waitForTerminalResponse(
    IM15NativeSerialManager serial,
    IM15TransactionLogger logger,
    String amountInCents, {
    VoidCallback? onPINRequired,
    VoidCallback? onPINCompleted,
  }) async {
    final start = DateTime.now();
    const totalTimeout = Duration(minutes: 2);

    bool pinRequested = false;
    final buffer = StringBuffer();

    while (DateTime.now().difference(start) < totalTimeout) {
      final chunk = await serial.readAsciiResponse(3000, 512);

      if (chunk.isEmpty) {
        continue;
      }

      buffer.write(chunk);

      final cleaned = _cleanControlChars(buffer.toString());
      print('[PaxIM15C200Sale] RX: $cleaned');
      logger.logRecv(cleaned);

      final r200Text = _extractR200(cleaned);
      if (r200Text != null) {
        final parsed = parseAsciiR200Response(r200Text, amountInCents);

        if (parsed != null) {
          serial.sendByte(IM15NativeSerialManager.ACK);
          logger.logSend('ACK for R200');

          await _finishProtocol(serial, logger);
          return parsed;
        }
      }

      if (_containsAny(cleaned, ['CARD', 'CLES', 'MAGS', 'SCAN', 'CLESC', 'LES'])) {
        print('[PaxIM15C200Sale] 💳 Card prompt detected');
        serial.sendByte(IM15NativeSerialManager.ACK);
        logger.logSend('ACK for card prompt');
        buffer.clear();
        continue;
      }

      if (cleaned.contains('PIN') && !pinRequested) {
        pinRequested = true;
        print('[PaxIM15C200Sale] 🔐 PIN requested');
        serial.sendByte(IM15NativeSerialManager.ACK);
        logger.logSend('ACK for PIN');
        onPINRequired?.call();
        buffer.clear();
        continue;
      }

      if (cleaned.contains('PEF')) {
        print('[PaxIM15C200Sale] ✅ PIN completed');
        serial.sendByte(IM15NativeSerialManager.ACK);
        logger.logSend('ACK for PEF');
        onPINCompleted?.call();
        buffer.clear();
        continue;
      }

      if (buffer.length > 1500) {
        final tail = buffer.toString().substring(buffer.length - 500);
        buffer
          ..clear()
          ..write(tail);
      }
    }

    print('[PaxIM15C200Sale] ⏱️ Timeout waiting for R200');
    logger.logInfo('Timeout waiting for R200');
    return null;
  }

  Future<void> _finishProtocol(
    IM15NativeSerialManager serial,
    IM15TransactionLogger logger,
  ) async {
    final gotEot = await serial.waitForByte(IM15NativeSerialManager.EOT, 3000);

    if (gotEot) {
      print('[PaxIM15C200Sale] ✅ EOT received');
      logger.logRecv('EOT');
      return;
    }

    serial.sendByte(IM15NativeSerialManager.ENQ);
    logger.logSend('ENQ after R200');

    final gotEotAfterEnq =
        await serial.waitForByte(IM15NativeSerialManager.EOT, 3000);

    if (gotEotAfterEnq) {
      print('[PaxIM15C200Sale] ✅ EOT received after ENQ');
      logger.logRecv('EOT');
    }
  }

  IM15ResponseModel? parseAsciiR200Response(
    String asciiResponse,
    String amountInCents,
  ) {
    try {
      final r200 = _extractR200(asciiResponse);
      if (r200 == null) {
        print('[PaxIM15C200Sale] ❌ No R200 found');
        return null;
      }

      print('[PaxIM15C200Sale] 🔍 Parsing R200: ${_safePreview(r200)}');

      final response = r200.substring(4); // remove R200
      final model = IM15ResponseModel();

      int pos = 0;

      model.cardNumber = _readField(response, pos, 19).trim();
      pos += 19;

      model.expireDate = _readField(response, pos, 4).trim();
      pos += 4;

      model.statusCode = _readField(response, pos, 2).trim();
      pos += 2;

      model.approvalCode = _readField(response, pos, 6).trim();
      pos += 6;

      // Use this as bank_trx_no.
      model.rrn = _readField(response, pos, 12).trim();
      pos += 12;

      model.traceNo = _readField(response, pos, 6).trim();
      pos += 6;

      model.batchNo = _readField(response, pos, 6).trim();
      pos += 6;

      model.hostNo = _readField(response, pos, 2).trim();
      pos += 2;

      model.terminalId = _readField(response, pos, 8).trim();
      pos += 8;

      model.merchantId = _readField(response, pos, 15).trim();
      pos += 15;

      model.aid = _readField(response, pos, 14).trim();
      pos += 14;

      // TC - 16 chars, skipped if model has no field.
      pos += 16;

      // Cardholder Name - 26 chars, skipped if model has no field.
      pos += 26;

      // Card Type - 2 chars, skipped if model has no field.
      pos += 2;

      // Card Application Label - 16 chars.
      final appLabel = _readField(response, pos, 16).trim();
      if ((model.aid == null || model.aid!.isEmpty) && appLabel.isNotEmpty) {
        model.aid = appLabel;
      }

      // R200 does not return amount in your spec, so use request amount.
      model.amount = amountInCents;

      if (model.statusCode == null || model.statusCode!.isEmpty) {
        model.statusCode = 'TA';
      }

      final bankTrxNo =
          model.rrn != null && model.rrn!.isNotEmpty ? model.rrn : model.traceNo;

      // Debug logging
      print('[PaxIM15C200Sale] ✅ ASCII R200 parsed:');
      print('[PaxIM15C200Sale]   Card: ${model.cardNumber}');
      print('[PaxIM15C200Sale]   Status: ${model.statusCode}');
      print('[PaxIM15C200Sale]   Amount: ${model.amount}');
      print('[PaxIM15C200Sale]   AID: ${model.aid}');
      print('[PaxIM15C200Sale]   Approval Code: ${model.approvalCode}');
      print('[PaxIM15C200Sale]   RRN / Bank Trx No: $bankTrxNo');
      print('[PaxIM15C200Sale]   Trace No: ${model.traceNo}');
      print('[PaxIM15C200Sale]   Batch No: ${model.batchNo}');
      print('[PaxIM15C200Sale]   Terminal ID: ${model.terminalId}');
      print('[PaxIM15C200Sale]   Merchant ID: ${model.merchantId}');

      return model;
    } catch (e) {
      print('[PaxIM15C200Sale] ❌ Parse R200 error: $e');
      print('[PaxIM15C200Sale] Full response: $asciiResponse');
      return null;
    }
  }

  String _cleanControlChars(String input) {
    return input.replaceAll(RegExp(r'[\x00-\x1F]'), '');
  }

  String? _extractR200(String input) {
    final cleaned = _cleanControlChars(input);
    final index = cleaned.indexOf('R200');
    if (index == -1) return null;
    return cleaned.substring(index);
  }

  String _readField(String s, int start, int length) {
    if (start >= s.length) return '';
    final end = start + length;
    if (end > s.length) return s.substring(start);
    return s.substring(start, end);
  }

  bool _containsAny(String input, List<String> tokens) {
    for (final token in tokens) {
      if (input.contains(token)) return true;
    }
    return false;
  }

  String _safePreview(String s) {
    if (s.length <= 80) return s;
    return '${s.substring(0, 80)}...';
  }
}