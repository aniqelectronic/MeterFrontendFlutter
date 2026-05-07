import 'dart:typed_data';

import 'im15_serial_manager.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_model/im15_response_parser.dart';
import '../im15_utils/im15_packet_builder.dart';
import '../im15_utils/im15_transaction_logger.dart';

class PaxIM15C500SettlementTransaction {
  /// Executes C500 Settlement (compact version)
  Future<IM15ResponseModel?> executeSettlement(
    String portName,
    String hostNo,
    IM15TransactionLogger logger,
  ) async {
    // Serial communication manager
    final serial = IM15SerialManager();

    // Parsed settlement result
    IM15ResponseModel? model;

    try {
      // ---------- OPEN SERIAL PORT ----------
      if (!serial.open(portName)) {
        logger.logInfo('Failed to open port: $portName');
        return null;
      }

      // ---------- SEND ENQ ----------
      // Ask terminal if it is ready
      serial.sendByte(IM15SerialManager.ENQ);
      logger.logSend('ENQ');

      // ---------- WAIT FOR ACK ----------
      final gotAckAfterEnq =
          await serial.waitForByte(IM15SerialManager.ACK, 5000);

      if (!gotAckAfterEnq) return null;
      logger.logRecv('ACK');

      // ---------- BUILD C500 PACKET ----------
      final Uint8List c500 = IM15PacketBuilder.buildC500Packet(hostNo, '');

      // ---------- SEND C500 PACKET ----------
      // Java: serial.sendPacket(c500, "C500 Packet", logger)
      serial.sendByte(IM15SerialManager.STX);
      logger.logSend('STX (C500)');
      serial.sendBytes(c500);
      logger.logSendBytes(c500, 'C500 Packet');

      // ---------- WAIT FOR ACK ----------
      final gotAckAfterC500 =
          await serial.waitForByte(IM15SerialManager.ACK, 3000);

      if (!gotAckAfterC500) return null;
      logger.logRecv('ACK');

      // ---------- SEND ACK ----------
      serial.sendByte(IM15SerialManager.ACK);
      logger.logSend('ACK');

      // ---------- READ R500 RESPONSE ----------
      // Terminal responds with settlement result
      final Uint8List response =
          await serial.readR500Packet(logger);

      // ---------- SEND ACK ----------
      serial.sendByte(IM15SerialManager.ACK);
      logger.logSend('ACK');

      // ---------- SEND ENQ ----------
      serial.sendByte(IM15SerialManager.ENQ);
      logger.logSend('ENQ');

      // ---------- WAIT FOR EOT ----------
      await serial.waitForByte(IM15SerialManager.EOT, 5000);
      logger.logRecv('EOT');

      // ---------- SEND EOT ----------
      serial.sendByte(IM15SerialManager.EOT);
      logger.logSend('EOT');

      // ---------- PARSE R500 RESPONSE ----------
      model =
          IM15ResponseParser.parseR500Response(response);
    } catch (e) {
      // ---------- ERROR HANDLING ----------
      logger.logInfo('C500 Settlement Error: $e');
    } finally {
      // ---------- CLOSE SERIAL PORT ----------
      serial.close();
    }

    return model;
  }
}
