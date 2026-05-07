import 'dart:typed_data';

import 'im15_native_serial_manager.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_model/im15_response_parser.dart';
import '../im15_utils/im15_packet_builder.dart';
import '../im15_utils/im15_transaction_logger.dart';

class PaxIM15C500Settlement {
  /// Executes C500 SETTLEMENT transaction using NATIVE serial manager
  Future<IM15ResponseModel?> executeSettlement(
    String portName,
    String hostNo,
  ) async {
    // Create NATIVE serial communication manager
    final serial = IM15NativeSerialManager();

    // Will store parsed settlement result
    IM15ResponseModel? model;

    // Create logger session for C500
    final logger = IM15TransactionLogger('C500 Settlement');

    try {
      // ---------- OPEN SERIAL PORT ----------
      if (!serial.open(portName)) {
        logger.logInfo('Failed to open port: $portName');
        return null;
      }

      // ---------- SEND ENQ ----------
      // Ask terminal if it is ready
      logger.logSend('ENQ');
      serial.sendByte(IM15NativeSerialManager.ENQ);

      // ---------- WAIT FOR ACK ----------
      // Terminal must acknowledge ENQ
      final gotAckAfterEnq =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 3000);

      if (!gotAckAfterEnq) {
        logger.logInfo('No ACK after ENQ');
        return null;
      }
      logger.logRecv('ACK');

      // ---------- BUILD C500 PACKET ----------
      // Build settlement request packet
       final Uint8List c500 = IM15PacketBuilder.buildC500Packet(hostNo, '');


      // ---------- SEND STX ----------
      // Start of C500 packet
      logger.logSend('STX (C500)');
      serial.sendByte(IM15NativeSerialManager.STX);

      // ---------- SEND C500 DATA ----------
      // Send packet bytes + hex logging
      serial.traceableSend(c500, 'C500', logger);

      // ---------- WAIT FOR ACK ----------
      // Terminal confirms it received C500
      final gotAckAfterC500 =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 3000);

      if (!gotAckAfterC500) {
        logger.logInfo('No ACK after sending C500 packet');
        return null;
      }
      logger.logRecv('ACK');

      // ---------- SEND ENQ ----------
      // Ask terminal to send response
      logger.logSend('ENQ');
      serial.sendByte(IM15NativeSerialManager.ENQ);

      // ---------- WAIT FOR STX (R500) ----------
      // Terminal begins response packet
      final gotStx =
          await serial.waitForByte(IM15NativeSerialManager.STX, 3000);

      if (gotStx) {
        logger.logRecv('STX (R500)');

        // ---------- READ R500 RESPONSE ----------
        final Uint8List response =
            await serial.readR500Packet(logger);

        logger.logRecvBytes(response, 'R500 Packet');

        // ---------- SEND ACK ----------
        // Confirm R500 packet received
        serial.sendByte(IM15NativeSerialManager.ACK);
        logger.logSend('ACK');

        // ---------- SEND ENQ ----------
        serial.sendByte(IM15NativeSerialManager.ENQ);
        logger.logSend('ENQ');

        // ---------- WAIT FOR EOT ----------
        // Terminal ends transaction
        final gotEot =
            await serial.waitForByte(IM15NativeSerialManager.EOT, 2000);

        if (gotEot) {
          logger.logRecv('EOT');

          // ---------- SEND EOT ----------
          serial.sendByte(IM15NativeSerialManager.EOT);
          logger.logSend('EOT');
        }

        // ---------- PARSE R500 RESPONSE ----------
        model =
            IM15ResponseParser.parseR500Response(response);
      } else {
        logger.logInfo('Timeout waiting for STX (R500)');
      }
    } catch (e) {
      // ---------- ERROR HANDLING ----------
      logger.logInfo('Settlement Error: $e');
    } finally {
      // ---------- END LOGGER + CLOSE PORT ----------
      logger.endSession();
      serial.close();
    }

    return model;
  }
}