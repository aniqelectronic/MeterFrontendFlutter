import 'dart:typed_data';

import 'im15_native_serial_manager.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_model/im15_response_parser.dart';
import '../im15_utils/im15_packet_builder.dart';
import '../im15_utils/im15_transaction_logger.dart';

class PaxIM15C208QueryTransaction {
  /// Executes a C208 QUERY TRANSACTION using NATIVE serial manager
  /// Uses R200 response format
  Future<IM15ResponseModel?> executeQuery(
    String portName,
    String hostNo,
    String transactionId,
    IM15TransactionLogger logger,
  ) async {
    // Create NATIVE serial manager (same as Java)
    final serial = IM15NativeSerialManager();

    IM15ResponseModel? model;

    try {
      // ---------- OPEN PORT ----------
      if (!serial.open(portName)) {
        logger.logInfo('Failed to open port: $portName');
        return null;
      }

      // ---------- SEND ENQ ----------
      serial.sendByte(IM15NativeSerialManager.ENQ);
      logger.logSend('ENQ');

      // ---------- WAIT FOR ACK ----------
      final gotAckAfterEnq =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 5000);

      if (!gotAckAfterEnq) return null;
      logger.logRecv('ACK');

      // ---------- BUILD C208 PACKET ----------
      // Java: IM15PacketBuilder.buildC208Packet(...)
      final Uint8List c208 =
          IM15PacketBuilder.buildC208QueryPacket(hostNo, transactionId);

      // ---------- SEND STX + C208 ----------
      // Java: serial.sendPacket(c208, "C208 Packet", logger)
      serial.sendByte(IM15NativeSerialManager.STX);
      logger.logSend('STX (C208)');
      serial.sendBytes(c208);
      logger.logSendBytes(c208, 'C208 Packet');

      // ---------- WAIT FOR ACK ----------
      final gotAckAfterC208 =
          await serial.waitForByte(IM15NativeSerialManager.ACK, 3000);

      if (!gotAckAfterC208) return null;
      logger.logRecv('ACK');

      // ---------- SEND ACK ----------
      serial.sendByte(IM15NativeSerialManager.ACK);
      logger.logSend('ACK');

      // ---------- READ R200 RESPONSE ----------
      // Java comment: // Same format as R200
      final Uint8List response =
          await serial.readR200Packet(logger);

      // ---------- SEND ACK ----------
      serial.sendByte(IM15NativeSerialManager.ACK);
      logger.logSend('ACK');

      // ---------- SEND ENQ ----------
      serial.sendByte(IM15NativeSerialManager.ENQ);
      logger.logSend('ENQ');

      // ---------- WAIT FOR EOT ----------
      await serial.waitForByte(IM15NativeSerialManager.EOT, 5000);
      logger.logRecv('EOT');

      // ---------- SEND EOT ----------
      serial.sendByte(IM15NativeSerialManager.EOT);
      logger.logSend('EOT');

      // ---------- PARSE RESPONSE ----------
      model =
          IM15ResponseParser.parseR200Response(response);
    } catch (e) {
      // ---------- ERROR HANDLING ----------
      logger.logInfo('C208 Query Error: $e');
    } finally {
      // ---------- ALWAYS CLOSE PORT ----------
      serial.close();
    }

    return model;
  }
}