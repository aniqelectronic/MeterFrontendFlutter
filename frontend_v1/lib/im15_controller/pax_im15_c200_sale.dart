import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';

import 'im15_native_serial_manager.dart';
import '../im15_model/im15_response_model.dart';
import '../im15_model/im15_response_parser.dart';
import '../im15_utils/im15_packet_builder.dart';
import '../im15_utils/im15_transaction_logger.dart';

class PaxIM15C200Sale {
  /// Executes a C200 SALE transaction using NATIVE serial manager
  /// Returns IM15ResponseModel if success, null if failed
  Future<IM15ResponseModel?> executeSale(
    String portName,
    String amountInCents,
    String transactionId,
    IM15TransactionLogger logger, {
    VoidCallback? onPINRequired,
    VoidCallback? onPINCompleted,
    Function(String)? onPINEntered, // New callback for when PIN is entered
  }) async {
    // Create NATIVE serial manager (avoids libserialport errno 22 issues)
    final serial = IM15NativeSerialManager();

    IM15ResponseModel? model;
    bool transactionStarted = false;

    try {
      // ---------- OPEN PORT ----------
      final opened = serial.open(portName);
      if (!opened) {
        logger.logInfo('Failed to open port: $portName');
        print('[PaxIM15C200Sale] ❌ Failed to open port: $portName');
        return null;
      }

      // ---------- STEP 1: ENQ ----------
      serial.sendByte(IM15NativeSerialManager.ENQ);
      logger.logSend('ENQ');
      transactionStarted = true;

      // ---------- WAIT FOR ACK OR ASCII R200 WITH TIMEOUT ----------
      // 60-second timeout for initial card tap detection
      final gotAckAfterEnq = await serial.waitForByte(
        IM15NativeSerialManager.ACK, 
        5000 //  seconds for card tap
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          logger.logInfo('Timeout waiting for card tap (60 seconds)');
          print('[PaxIM15C200Sale] ⏱️ TIMEOUT: No card detected after 60 seconds');
          return false;
        },
      );

      if (!gotAckAfterEnq) {
        // Check if card reader sent ASCII R200 instead of ACK
        print('[PaxIM15C200Sale] ⚠️ No ACK after ENQ, checking for ASCII R200...');
        logger.logInfo('No ACK after ENQ - checking for ASCII R200');
        
        // Try to read ASCII response that might have been sent instead of ACK
        final String possibleAsciiResponse = await serial.readAsciiResponse(2000, 200);
        
        if (possibleAsciiResponse.trim().isNotEmpty && possibleAsciiResponse.trim().startsWith('R200')) {
          // Card reader sent ASCII R200 immediately after ENQ
          final String trimmedResponse = possibleAsciiResponse.trim();
          print('[PaxIM15C200Sale] 📨 Received ASCII R200 immediately after ENQ: ${trimmedResponse.substring(0, 50)}...');
          logger.logInfo('Received ASCII R200 immediately after ENQ: ${trimmedResponse.substring(0, 50)}...');
          
          // Parse the ASCII R200 response
          model = parseAsciiR200Response(trimmedResponse);
          
          if (model != null) {
            print('[PaxIM15C200Sale] ✅ ASCII R200 parsed successfully!');
            print('[PaxIM15C200Sale] Status Code: ${model.statusCode}');
            print('[PaxIM15C200Sale] Card Number: ${model.cardNumber}');
            print('[PaxIM15C200Sale] Amount: ${model.amount}');
            logger.logInfo('Transaction SUCCESS - Status: ${model.statusCode}');
            
            // Send ENQ to continue protocol
            serial.sendByte(IM15NativeSerialManager.ENQ);
            logger.logSend('ENQ');
            
            // Wait for EOT
            final gotEot = await serial.waitForByte(IM15NativeSerialManager.EOT, 5000);
            if (gotEot) {
              logger.logRecv('EOT');
              serial.sendByte(IM15NativeSerialManager.EOT);
              logger.logSend('EOT');
            }
            
            // Transaction completed successfully with ASCII R200
            return model;
          } else {
            print('[PaxIM15C200Sale] ❌ Failed to parse ASCII R200 response');
            logger.logInfo('Failed to parse ASCII R200 response');
            return null;
          }
        } else {
          logger.logInfo('No ACK after ENQ - card reader not responding or timeout');
          print('[PaxIM15C200Sale] ❌ No ACK after ENQ - timeout or no card detected');
          return null;
        }
      }
      logger.logRecv('ACK');

      // ---------- BUILD C200 PACKET ----------
      final Uint8List c200 = IM15PacketBuilder.buildC200Packet(
        '01',                // Terminal ID
        '0',                 // Sale type
        amountInCents,       // Amount
        transactionId,       // Transaction ID
      );

      // ---------- SEND STX ----------
      serial.sendByte(IM15NativeSerialManager.STX);
      logger.logSend('STX (C200)');

      // ---------- SEND C200 PACKET ----------
      serial.sendBytes(c200);

      // ---------- WAIT FOR ACK AFTER C200 ----------
      final gotAckAfterC200 = await serial.waitForByte(IM15NativeSerialManager.ACK, 5000);

      if (!gotAckAfterC200) {
        logger.logInfo('No ACK after C200 Packet - transaction not accepted');
        print('[PaxIM15C200Sale] ❌ No ACK after C200 Packet');
        return null;
      }
      logger.logRecv('ACK');

      // ---------- SEND ACK ----------
      serial.sendByte(IM15NativeSerialManager.ACK);
      logger.logSend('ACK');

      // ---------- HANDLE PROMPTS (CARD/CLES/MAGS/SCAN, PIN, PEF) ----------
      bool pinRequested = false;
      bool pinCompleted = false;
      bool cardReadCompleted = false;
      
      // Track time for overall prompt handling timeout
      final promptStartTime = DateTime.now().millisecondsSinceEpoch;
      const maxPromptTimeoutMs = 6000; // 2 minutes for PIN entry
      
      // Buffer for accumulating bytes to detect "PIN" prompt
      String byteBuffer = '';
      
      while (!cardReadCompleted || (pinRequested && !pinCompleted)) {
        // Check for overall timeout
        if (DateTime.now().millisecondsSinceEpoch - promptStartTime > maxPromptTimeoutMs) {
          logger.logInfo('Prompt handling timeout after ${maxPromptTimeoutMs}ms');
          print('[PaxIM15C200Sale] ⏱️ TIMEOUT: PIN entry timeout after 2 minutes');
          return null; // Return null to indicate timeout failure
        }
        
        // Read prompt with timeout
        final int readTimeout = pinRequested && !pinCompleted ? 30000 : 5000;
        
        final String prompt = await Future.any([
          serial.readAsciiResponse(readTimeout, 100),
          Future.delayed(Duration(milliseconds: readTimeout), () => ''),
        ]);
        
        if (prompt.trim().isEmpty) {
          // No more prompts or timeout
          if (pinRequested && !pinCompleted) {
            logger.logInfo('PIN entry timeout - no PEF received');
            print('[PaxIM15C200Sale] ⏱️ TIMEOUT: PIN entry timeout - no PEF received');
            return null;
          }
          break;
        }
        
        final String trimmedPrompt = prompt.trim();
        logger.logRecv(trimmedPrompt);
        
        // Check prompt type - handle ASCII text responses
        if (trimmedPrompt == 'PIN') {
          pinRequested = true;
          print('[PaxIM15C200Sale] 🔐 PIN requested by terminal');
          logger.logInfo('PIN requested - waiting for user PIN entry');
          
          // Send ACK to terminal as per protocol
          serial.sendByte(IM15NativeSerialManager.ACK);
          logger.logSend('ACK (for PIN)');
          
          // Trigger PIN required callback if provided
          if (onPINRequired != null) {
            print('[PaxIM15C200Sale] 📞 Calling onPINRequired callback');
            onPINRequired();
          }
          
          // Wait for user to enter PIN on card reader
          print('[PaxIM15C200Sale] ⏳ Waiting for user to enter PIN on card reader...');
          logger.logInfo('Waiting for user PIN entry on card reader');
          
        } else if (trimmedPrompt == 'PEF') {
          pinCompleted = true;
          print('[PaxIM15C200Sale] ✅ PIN entry completed (PEF received)');
          logger.logInfo('PIN entry completed (PEF)');
          
          // Send ACK to terminal as per protocol
          serial.sendByte(IM15NativeSerialManager.ACK);
          logger.logSend('ACK (for PEF)');
          
          // Trigger PIN completed callback if provided
          if (onPINCompleted != null) {
            print('[PaxIM15C200Sale] 📞 Calling onPINCompleted callback');
            onPINCompleted();
          }
        } else if (trimmedPrompt == 'CARD' || trimmedPrompt == 'CLES' || 
                   trimmedPrompt == 'MAGS' || trimmedPrompt == 'SCAN' ||
                   trimmedPrompt == 'CLESC' || trimmedPrompt == 'LES') {
          // Handle variations: CLESC and LES should be treated as CLES
          cardReadCompleted = true;
          final String cardPrompt = (trimmedPrompt == 'CLESC' || trimmedPrompt == 'LES') ? 'CLES' : trimmedPrompt;
          print('[PaxIM15C200Sale] 💳 Card read: $cardPrompt (original: $trimmedPrompt)');
          logger.logInfo('Card read: $cardPrompt (original: $trimmedPrompt)');
          
          // Send ACK to terminal as per protocol
          serial.sendByte(IM15NativeSerialManager.ACK);
          logger.logSend('ACK (for $cardPrompt)');
          
        } else if (trimmedPrompt.startsWith('R200')) {
          // Card reader is sending R200 response as ASCII text instead of binary packet
          print('[PaxIM15C200Sale] 📨 Received R200 as ASCII text: ${trimmedPrompt.substring(0, 50)}...');
          logger.logInfo('Received R200 as ASCII text: ${trimmedPrompt.substring(0, 50)}...');
          
          // Parse the ASCII R200 response
          model = parseAsciiR200Response(trimmedPrompt);
          if (model != null) {
            print('[PaxIM15C200Sale] ✅ ASCII R200 parsed successfully!');
            print('[PaxIM15C200Sale] Status Code: ${model.statusCode}');
            print('[PaxIM15C200Sale] Card Number: ${model.cardNumber}');
            print('[PaxIM15C200Sale] Amount: ${model.amount}');
            logger.logInfo('Transaction SUCCESS - Status: ${model.statusCode}');
            
            // Acknowledge the R200 response
            serial.sendByte(IM15NativeSerialManager.ACK);
            logger.logSend('ACK');
            
            // Send ENQ to continue protocol
            serial.sendByte(IM15NativeSerialManager.ENQ);
            logger.logSend('ENQ');
            
            // Wait for EOT
            final gotEot = await serial.waitForByte(IM15NativeSerialManager.EOT, 3000);
            if (gotEot) {
              logger.logRecv('EOT');
              serial.sendByte(IM15NativeSerialManager.EOT);
              logger.logSend('EOT');
            }
            
            // Transaction completed successfully with ASCII R200
            return model;
          } else {
            print('[PaxIM15C200Sale] ❌ Failed to parse ASCII R200 response');
            logger.logInfo('Failed to parse ASCII R200 response');
          }
        } else {
          // Check if this is part of a "PIN" prompt coming as individual bytes
          byteBuffer += trimmedPrompt;
          if (byteBuffer.length > 10) {
            // Keep buffer reasonable size
            byteBuffer = byteBuffer.substring(byteBuffer.length - 10);
          }
          
          // Check if buffer contains "PIN" - handle concatenated "PINPINPIN"
          if (byteBuffer.contains('PIN') && !pinRequested) {
            pinRequested = true;
            print('[PaxIM15C200Sale] 🔐 PIN requested by terminal (detected in buffer: $byteBuffer)');
            logger.logInfo('PIN requested - detected in byte buffer: $byteBuffer');
            
            // Send ACK to terminal as per protocol
            serial.sendByte(IM15NativeSerialManager.ACK);
            logger.logSend('ACK (for PIN from buffer)');
            
            // Trigger PIN required callback if provided
            if (onPINRequired != null) {
              print('[PaxIM15C200Sale] 📞 Calling onPINRequired callback');
              onPINRequired();
            }
          } else {
            print('[PaxIM15C200Sale] ⚠️ Unknown prompt: $trimmedPrompt');
            logger.logInfo('Unknown prompt: $trimmedPrompt');
            
            // Still send ACK for unknown prompts to keep protocol flowing
            serial.sendByte(IM15NativeSerialManager.ACK);
            logger.logSend('ACK (for unknown prompt)');
          }
        }
        
        // If PIN was requested but not yet completed, wait a bit for user to enter PIN
        if (pinRequested && !pinCompleted) {
          print('[PaxIM15C200Sale] ⏳ Waiting for user to enter PIN...');
          // Longer delay when waiting for PIN entry
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      // Log prompt handling summary
      if (pinRequested) {
        if (pinCompleted) {
          logger.logInfo('PIN flow completed successfully');
          print('[PaxIM15C200Sale] ✅ PIN flow completed successfully');
        } else {
          logger.logInfo('PIN requested but PEF not received');
          print('[PaxIM15C200Sale] ⚠️ PIN requested but PEF not received');
          // If PIN was required but not completed, transaction should fail
          return null;
        }
      }

      // ---------- WAIT FOR ENQ OR PIN ----------
      print('[PaxIM15C200Sale] 🔍 Waiting for ENQ or PIN...');
      
      // Try to detect PIN first (since we know PIN is required for amounts > RM250)
      final pinDetected = await serial.waitForAscii('PIN', 2000);
      
      if (pinDetected) {
        print('[PaxIM15C200Sale] 🔐 PIN detected after card read');
        pinRequested = true;
        
        // Send ACK to terminal as per protocol
        serial.sendByte(IM15NativeSerialManager.ACK);
        logger.logSend('ACK (for PIN)');
        
        // Trigger PIN required callback if provided
        if (onPINRequired != null) {
          print('[PaxIM15C200Sale] 📞 Calling onPINRequired callback');
          onPINRequired();
        }
        
        // Now wait for PEF (PIN entry completed) with 120-second timeout
        print('[PaxIM15C200Sale] ⏳ Waiting for PEF after PIN...');
        final pefDetected = await Future.any([
          serial.waitForAscii('PEF', 5000), // 2 minutes for PIN entry
          Future.delayed(const Duration(seconds: 120), () => false),
        ]);
        
        if (pefDetected) {
          pinCompleted = true;
          print('[PaxIM15C200Sale] ✅ PIN entry completed (PEF received)');
          logger.logInfo('PIN entry completed (PEF)');
          
          // Send ACK to terminal as per protocol
          serial.sendByte(IM15NativeSerialManager.ACK);
          logger.logSend('ACK (for PEF)');
          
          // Trigger PIN completed callback if provided
          if (onPINCompleted != null) {
            print('[PaxIM15C200Sale] 📞 Calling onPINCompleted callback');
            onPINCompleted();
          }
        } else {
          logger.logInfo('PIN entry timeout - no PEF received after 120 seconds');
          print('[PaxIM15C200Sale] ⏱️ TIMEOUT: PIN entry timeout after 120 seconds');
          return null;
        }
      } else {
        // No PIN detected, wait for ENQ
        print('[PaxIM15C200Sale] 🔍 No PIN detected, waiting for ENQ...');
        final gotEnq = await serial.waitForByte(IM15NativeSerialManager.ENQ, 2000);
        
        if (gotEnq) {
          logger.logRecv('ENQ');
          serial.sendByte(IM15NativeSerialManager.ACK);
          logger.logSend('ACK');
        }
      }

      // ---------- WAIT FOR STX (R200) OR ASCII R200 ----------
      final String possibleResponse = await serial.readAsciiResponse(5000, 200);
      
      if (possibleResponse.trim().isNotEmpty) {
        final String trimmedResponse = possibleResponse.trim();
        logger.logRecv(trimmedResponse);
        
        if (trimmedResponse.startsWith('R200')) {
          // ASCII R200 response
          print('[PaxIM15C200Sale] 📨 Received ASCII R200: ${trimmedResponse.substring(0, 50)}...');
          
          // Parse the ASCII R200 response
          model = parseAsciiR200Response(trimmedResponse);
          
          // Acknowledge the R200 response
          serial.sendByte(IM15NativeSerialManager.ACK);
          logger.logSend('ACK');
          
          // Send ENQ to continue protocol
          serial.sendByte(IM15NativeSerialManager.ENQ);
          logger.logSend('ENQ');
          
          // Wait for EOT
          final gotEot = await serial.waitForByte(IM15NativeSerialManager.EOT, 3000);
          if (gotEot) {
            logger.logRecv('EOT');
            serial.sendByte(IM15NativeSerialManager.EOT);
            logger.logSend('EOT');
          }
        } else {
          // Might be binary STX - check first byte
          print('[PaxIM15C200Sale] ⚠️ Unexpected response: $trimmedResponse');
          logger.logInfo('Unexpected response: $trimmedResponse');
        }
      } else {
        // Try binary STX approach as fallback
        print('[PaxIM15C200Sale] 🔄 No ASCII response, trying binary STX...');
        final gotStx = await serial.waitForByte(IM15NativeSerialManager.STX, 3000);
        
        if (gotStx) {
          logger.logRecv('STX (R200)');

          // ---------- READ R200 PACKET ----------
          final Uint8List r200 = await serial.readR200Packet(logger);

          // ---------- ACK R200 ----------
          serial.sendByte(IM15NativeSerialManager.ACK);
          logger.logSend('ACK');

          // ---------- SEND ENQ ----------
          serial.sendByte(IM15NativeSerialManager.ENQ);
          logger.logSend('ENQ');

          // ---------- WAIT FOR EOT ----------
          final gotEot = await serial.waitForByte(IM15NativeSerialManager.EOT, 5000);

          if (gotEot) {
            logger.logRecv('EOT');
            serial.sendByte(IM15NativeSerialManager.EOT);
            logger.logSend('EOT');
          }

          // ---------- PARSE RESPONSE ----------
          print('[PaxIM15C200Sale] 📦 Parsing R200 response (${r200.length} bytes)...');
          model = IM15ResponseParser.parseR200Response(r200);
          
          if (model != null) {
            print('[PaxIM15C200Sale] ✅ Response parsed successfully!');
            print('[PaxIM15C200Sale] Status Code: ${model.statusCode}');
            print('[PaxIM15C200Sale] Card Number: ${model.cardNumber}');
            print('[PaxIM15C200Sale] Amount: ${model.amount}');
            logger.logInfo('Transaction SUCCESS - Status: ${model.statusCode}');
          } else {
            print('[PaxIM15C200Sale] ❌ Failed to parse R200 response');
            logger.logInfo('Failed to parse R200 response');
          }
        } else {
          logger.logInfo('No STX received - card reader did not send response');
          print('[PaxIM15C200Sale] ❌ No STX received for R200');
        }
      }
    } on TimeoutException catch (e) {
      // ---------- TIMEOUT ERROR HANDLING ----------
      logger.logInfo('Transaction timeout: $e');
      print('[PaxIM15C200Sale] ⏱️ Transaction timeout: $e');
      model = null;
    } catch (e) {
      // ---------- ERROR HANDLING ----------
      logger.logInfo('Transaction Error: $e');
      print('[PaxIM15C200Sale] ❌ Transaction Error: $e');
      model = null;
    } finally {
      // ---------- SEND EOT TO RESET CARD READER ON FAILURE ----------
      if (transactionStarted && model == null) {
        try {
          logger.logInfo('Sending EOT to reset card reader after failure/timeout');
          print('[PaxIM15C200Sale] 🔄 Sending EOT to reset card reader');
          serial.sendByte(IM15NativeSerialManager.EOT);
          logger.logSend('EOT (cleanup)');
          
          // Give card reader time to process EOT
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          logger.logInfo('Error sending cleanup EOT: $e');
          print('[PaxIM15C200Sale] ⚠️ Error sending cleanup EOT: $e');
        }
      }
      
      // ---------- ALWAYS CLOSE PORT ----------
      try {
        serial.close();
        logger.logInfo('Serial port closed');
        print('[PaxIM15C200Sale] 🔒 Serial port closed');
      } catch (e) {
        logger.logInfo('Error closing port: $e');
        print('[PaxIM15C200Sale] ⚠️ Error closing port: $e');
      }
    }

    print('[PaxIM15C200Sale] 📤 Returning model: ${model != null ? "SUCCESS" : "NULL"}');
    return model;
  }

  /// Parse ASCII R200 response
  IM15ResponseModel? parseAsciiR200Response(String asciiResponse) {
    try {
      print('[PaxIM15C200Sale] 🔍 Parsing ASCII R200: ${asciiResponse.substring(0, 50)}...');
      
      // Remove "R200" prefix if present
      String response = asciiResponse;
      if (response.startsWith('R200')) {
        response = response.substring(4);
      }
      
      // Create response model
      final model = IM15ResponseModel();
      
      // Extract fields based on expected positions
      int pos = 0;
      
      // Card Number (19 chars)
      if (response.length >= pos + 19) {
        model.cardNumber = response.substring(pos, pos + 19).trim();
        pos += 19;
      } else {
        model.cardNumber = 'XXXXXX';
      }
      
      // Expire Date (4 chars)
      if (response.length >= pos + 4) {
        model.expireDate = response.substring(pos, pos + 4).trim();
        pos += 4;
      }
      
      // Status Code (2 chars) - R200 indicates success
      if (response.length >= pos + 2) {
        model.statusCode = response.substring(pos, pos + 2).trim();
        pos += 2;
      } else {
        model.statusCode = '00'; // Default to approved
      }
      
      // Approval Code (6 chars)
      if (response.length >= pos + 6) {
        model.approvalCode = response.substring(pos, pos + 6).trim();
        pos += 6;
      }
      
      // RRN (12 chars)
      if (response.length >= pos + 12) {
        model.rrn = response.substring(pos, pos + 12).trim();
        pos += 12;
      }
      
      // Trace No (6 chars)
      if (response.length >= pos + 6) {
        model.traceNo = response.substring(pos, pos + 6).trim();
        pos += 6;
      }
      
      // Batch No (6 chars)
      if (response.length >= pos + 6) {
        model.batchNo = response.substring(pos, pos + 6).trim();
        pos += 6;
      }
      
      // Host No (2 chars)
      if (response.length >= pos + 2) {
        model.hostNo = response.substring(pos, pos + 2).trim();
        pos += 2;
      }
      
      // Terminal ID (8 chars)
      if (response.length >= pos + 8) {
        model.terminalId = response.substring(pos, pos + 8).trim();
        pos += 8;
      } else {
        model.terminalId = '01'; // Default terminal ID
      }
      
      // Merchant ID (15 chars)
      if (response.length >= pos + 15) {
        model.merchantId = response.substring(pos, pos + 15).trim();
        pos += 15;
      }
      
      // AID (14 chars) - Try to extract card type from the response
      if (response.length >= pos + 14) {
        model.aid = response.substring(pos, pos + 14).trim();
        pos += 14;
      } else {
        // Try to detect card type from the response
        if (asciiResponse.contains('Debit Mastercard')) {
          model.aid = 'Debit Mastercard';
        } else if (asciiResponse.contains('Credit Mastercard')) {
          model.aid = 'Credit Mastercard';
        } else if (asciiResponse.contains('Visa')) {
          model.aid = 'Visa';
        } else {
          model.aid = 'Unknown';
        }
      }
      
      // Amount (12 chars) - Try to extract from the response
      if (response.length >= pos + 12) {
        model.amount = response.substring(pos, pos + 12).trim();
      } else {
        // Try to find amount pattern in the response
        final amountMatch = RegExp(r'(\d{12})').firstMatch(asciiResponse);
        if (amountMatch != null) {
          model.amount = amountMatch.group(1)!;
        } else {
          // Look for amount in cents pattern (e.g., 00002700 = RM27.00)
          final amountPattern = RegExp(r'(\d{8})');
          final matches = amountPattern.allMatches(asciiResponse);
          for (final match in matches) {
            final potentialAmount = match.group(1)!;
            // Check if it looks like an amount (ends with "00" for cents)
            if (potentialAmount.endsWith('00') && potentialAmount.length == 8) {
              model.amount = potentialAmount;
              break;
            }
          }
          
          if (model.amount == null || model.amount!.isEmpty) {
            model.amount = '0';
          }
        }
      }
      
      // Debug logging
      print('[PaxIM15C200Sale] ✅ ASCII R200 parsed:');
      print('[PaxIM15C200Sale]   Card: ${model.cardNumber}');
      print('[PaxIM15C200Sale]   Status: ${model.statusCode}');
      print('[PaxIM15C200Sale]   Amount: ${model.amount}');
      print('[PaxIM15C200Sale]   AID: ${model.aid}');
      
      return model;
    } catch (e) {
      print('[PaxIM15C200Sale] ❌ Error parsing ASCII R200: $e');
      print('[PaxIM15C200Sale] ❌ Full response: $asciiResponse');
      return null;
    }
  }
}