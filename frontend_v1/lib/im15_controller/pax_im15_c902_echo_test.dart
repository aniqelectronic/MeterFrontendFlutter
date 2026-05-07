import 'dart:typed_data';
import 'dart:async';

import 'im15_native_serial_manager.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_model/im15_response_parser.dart';
import '../im15_utils/im15_packet_builder.dart';
import '../im15_utils/im15_transaction_logger.dart';

class PaxIM15C902EchoTest {
  /// Executes C902 Echo Test using NATIVE serial manager
  /// Used to verify terminal communication
  Future<IM15ResponseModel?> executeEchoTest(
    String portName,
    IM15TransactionLogger logger,
  ) async {
    // NATIVE Serial communication handler
    final serial = IM15NativeSerialManager();

    // Parsed echo response
    IM15ResponseModel? model;

    try {
      // ---------- OPEN SERIAL PORT ----------
      if (!serial.open(portName)) {
        logger.logInfo('Failed to open port.');
        return null;
      }

      // ---------- SEND ENQ ----------
      // Ask terminal if it is ready
      serial.sendByte(IM15NativeSerialManager.ENQ);
      logger.logSend('ENQ');

      // ---------- WAIT FOR ACK ----------
      final gotAck =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 3000);

      if (!gotAck) {
        logger.logInfo('No ACK after ENQ.');
        return null;
      }

      // ---------- BUILD C902 PACKET ----------
      // Echo test request
      final Uint8List c902 =
          IM15PacketBuilder.buildC902Packet();

      // ---------- SEND STX ----------
      serial.sendByte(IM15NativeSerialManager.STX);
      logger.logSend('STX (C902)');

      // ---------- SEND C902 PACKET ----------
      // Send packet + hex trace
      serial.traceableSend(c902, 'C902', logger);

      // ---------- WAIT FOR ACK ----------
      final gotAckAfterC902 =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 3000);

      if (!gotAckAfterC902) {
        logger.logInfo('No ACK after sending C902 packet.');
        return null;
      }

      // ---------- SMALL DELAY ----------
      // Give terminal time to prepare response
      await Future.delayed(const Duration(milliseconds: 150));

      // ---------- SEND ENQ ----------
      serial.sendByte(IM15NativeSerialManager.ENQ);
      logger.logSend('ENQ');

      bool sawSTX = false;
      Uint8List? response;

      // ---------- RETRY LOOP ----------
      // Try up to 6 times to receive valid R902
      for (int i = 0; i < 6; i++) {
        // Read full response packet
        final Uint8List buffer =
            await serial.readResponsePacket(logger);

        // Check if packet starts with STX
        if (buffer.isNotEmpty &&
            buffer[0] == IM15NativeSerialManager.STX) {
          sawSTX = true;
          response = buffer;
          break;
        }

        // Delay before retry
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // ---------- VALID RESPONSE RECEIVED ----------
      if (sawSTX && response != null) {
        logger.logRecvBytes(response, 'R902 Raw Packet');

        // ---------- SEND ACK ----------
        serial.sendByte(IM15NativeSerialManager.ACK);
        logger.logSend('ACK');

        // Small delay before next handshake
        await Future.delayed(const Duration(milliseconds: 100));

        // ---------- SEND ENQ ----------
        serial.sendByte(IM15NativeSerialManager.ENQ);
        logger.logSend('ENQ');

        // ---------- WAIT FOR EOT ----------
        final gotEot =
            await serial.waitForByte(IM15NativeSerialManager.EOT, 2000);

        if (gotEot) {
          // ---------- SEND EOT ----------
          serial.sendByte(IM15NativeSerialManager.EOT);
          logger.logSend('EOT');
        }

        // ---------- PARSE R902 RESPONSE ----------
        model =
            IM15ResponseParser.parseR902Response(response);
      } else {
        logger.logInfo('No valid R902 response.');
      }
    } catch (e) {
      // ---------- ERROR HANDLING ----------
      logger.logInfo('Echo Test Exception: $e');
    } finally {
      // ---------- FINAL CLEANUP ----------
      await Future.delayed(const Duration(milliseconds: 200));
      serial.close();
    }

    return model;
  }

  
}