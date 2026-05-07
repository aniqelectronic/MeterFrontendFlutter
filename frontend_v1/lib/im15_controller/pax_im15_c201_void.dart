import 'dart:typed_data';

import 'im15_native_serial_manager.dart';
import '../im15_utils/im15_packet_builder.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_utils/im15_transaction_logger.dart';
import '../im15_model/im15_response_parser.dart';

class PaxIM15C201Void {
  /// Executes a C201 VOID transaction using NATIVE serial manager
  /// Returns IM15ResponseModel if success, null if failed
  Future<IM15ResponseModel?> executeVoid(
    String portName,
    String hostNo,
    String amount,
    String traceNo,
    String refNo,
    IM15TransactionLogger logger,
  ) async {
    // Same as: IM15SerialManager serial = new IM15SerialManager();
    final serial = IM15NativeSerialManager();

    IM15ResponseModel? model;

    try {
      // ---------- OPEN PORT ----------
      if (!serial.open(portName)) {
        logger.logInfo('Failed to open port: $portName');
        return null;
      }

      // ---------- SEND ENQ ----------
      logger.logSend('ENQ');
      serial.sendByte(IM15NativeSerialManager.ENQ);

      // ---------- WAIT FOR ACK ----------
      final gotAckAfterEnq =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 3000);

      if (!gotAckAfterEnq) {
        logger.logInfo('No ACK after ENQ');
        return null;
      }
      logger.logRecv('ACK');

      // ---------- BUILD C201 PACKET ----------
      // Java: IM15PacketBuilder.buildC201Packet(...)
      final Uint8List c201 = IM15PacketBuilder.buildC201Packet(
        hostNo,
        amount,
        traceNo,
        refNo,
      );

      // ---------- SEND STX ----------
      logger.logSend('STX (C201)');
      serial.sendByte(IM15NativeSerialManager.STX);

      // ---------- SEND C201 WITH HEX TRACE ----------
      // Java: serial.traceableSend(...)
      serial.traceableSend(c201, 'C201', logger);

      // ---------- WAIT FOR ACK AFTER C201 ----------
      final gotAckAfterC201 =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 5000);

      if (!gotAckAfterC201) {
        logger.logInfo('No ACK after C201 packet');
        return null;
      }
      logger.logRecv('ACK');

      // ---------- SEND ENQ ----------
      logger.logSend('ENQ');
      serial.sendByte(IM15NativeSerialManager.ENQ);

      // ---------- WAIT FOR STX (R201) ----------
      final gotStx =
          await serial.waitForByte(IM15NativeSerialManager.STX, 5000);

      if (gotStx) {
        logger.logRecv('STX (R201)');

        // ---------- READ R201 RESPONSE ----------
        final Uint8List response =
            await serial.readR201Packet(logger);

        logger.logRecvBytes(response, 'R201 Packet');

        // ---------- SEND ACK ----------
        serial.sendByte(IM15NativeSerialManager.ACK);
        logger.logSend('ACK');

        // ---------- SEND ENQ ----------
        serial.sendByte(IM15NativeSerialManager.ENQ);
        logger.logSend('ENQ');

        // ---------- WAIT FOR EOT ----------
        final gotEot =
            await serial.waitForByte(IM15NativeSerialManager.EOT, 2000);

        if (gotEot) {
          logger.logRecv('EOT');
          serial.sendByte(IM15NativeSerialManager.EOT);
          logger.logSend('EOT');
        }

        // ---------- PARSE R201 RESPONSE ----------
        model =
            IM15ResponseParser.parseR201Response(response);
      } else {
        // ---------- STX TIMEOUT ----------
        logger.logInfo('Timeout waiting for STX (R201)');
      }
    } catch (e) {
      // ---------- ERROR HANDLING ----------
      logger.logInfo('Void Transaction Error: $e');
      print('Void Transaction Error: $e');
    } finally {
      // ---------- CLEANUP ----------
      logger.endSession(); // Same as Java
      serial.close();      // Always close port
    }

    return model;
  }
}