import 'dart:typed_data'; // Provides Uint8List for byte array handling
import 'dart:async';      // Supports Future and async/await

import 'im15_serial_manager.dart';              // Serial port communication manager
import '../im15_model/im15_response_model.dart';     // Response data model
import '../im15_model/im15_response_parser.dart';    // Parses R902 response
import '../im15_utils/im15_packet_builder.dart';     // Builds C902 request packet
import '../im15_utils/im15_transaction_logger.dart'; // Logging utility

class PaxIM15C902EchoTestTransaction {
  /// Executes C902 Echo Test transaction
  Future<IM15ResponseModel?> executeEcho(
    String portName,                 // Serial port name
    IM15TransactionLogger logger,     // Logger instance
  ) async {
    final serial = IM15SerialManager(); // Create serial manager
    IM15ResponseModel? model;           // Holds parsed response

    try {
      if (!serial.open(portName)) {     // Attempt to open serial port
        logger.logInfo('Failed to open port: $portName'); // Log failure
        return null;                    // Abort if port cannot be opened
      }

      serial.sendByte(                 // Send ENQ to start handshake
        IM15SerialManager.ENQ,
      );
      logger.logSend('ENQ');            // Log ENQ sent

      if (!await serial.waitForByte(    // Wait for ACK from terminal
        IM15SerialManager.ACK,
        5000,
      )) {
        return null;                    // Abort if ACK not received
      }

      final Uint8List c902 =            // Build C902 Echo Test packet
          IM15PacketBuilder.buildC902Packet();

      serial.sendPacket(               // Send C902 packet to terminal
        c902,
        'C902 Packet',
        logger,
      );

      if (!await serial.waitForByte(    // Wait for ACK after packet send
        IM15SerialManager.ACK,
        3000,
      )) {
        return null;                    // Abort if no ACK
      }

      serial.sendByte(                 // Send ACK before reading response
        IM15SerialManager.ACK,
      );
      logger.logSend('ACK');            // Log ACK

      final Uint8List response =        // Read R902 response packet
          await serial.readR902Packet(logger);

      serial.sendByte(                 // Acknowledge response received
        IM15SerialManager.ACK,
      );
      logger.logSend('ACK');            // Log ACK

      serial.sendByte(                 // Send ENQ to request EOT
        IM15SerialManager.ENQ,
      );
      logger.logSend('ENQ');            // Log ENQ

      await serial.waitForByte(         // Wait for EOT from terminal
        IM15SerialManager.EOT,
        5000,
      );

      serial.sendByte(                 // Send EOT to complete session
        IM15SerialManager.EOT,
      );
      logger.logSend('EOT');            // Log EOT

      model = IM15ResponseParser       // Parse R902 response into model
          .parseR902Response(response);
    } catch (e) {
      logger.logInfo(                  // Log any runtime exception
        'C902 Echo Test Error: $e',
      );
    } finally {
      serial.close();                  // Always close serial port
    }

    return model;                      // Return parsed response (or null)
  }
}
