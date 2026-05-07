import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';

import '../im15_serial/im15_transport.dart';

/// ------------------------------------------------------------
/// IM15 C902 Echo Probe (Connectivity Check)
/// ------------------------------------------------------------
///
/// PURPOSE:
/// - Quickly check if IM15 terminal is alive
/// - Used before real transactions
/// - NOT a real payment / echo implementation
///
/// WARNING:
/// - This does NOT use real IM15 protocol framing
/// - This is a safe "ping-like" probe only
///
/// ------------------------------------------------------------
class IM15C902EchoProbe {
  // Prevent class instantiation
  IM15C902EchoProbe._();

  /// ----------------------------------------------------------
  /// Probe IM15 device using a minimal C902 echo request
  ///
  /// Returns:
  /// - true  → device responded (alive)
  /// - false → no response / timeout
  ///
  /// Throws:
  /// - Exception if transport layer fails
  /// ----------------------------------------------------------
  static Future<bool> probe(IM15Transport transport) async {
    // --------------------------------------------------------
    // Build a placeholder C902 packet
    // (Replace with real protocol frame if available)
    // --------------------------------------------------------
    final Uint8List request = _buildFakeC902();

    // --------------------------------------------------------
    // Send raw bytes to IM15 terminal
    // --------------------------------------------------------
    await transport.write(request);

    // --------------------------------------------------------
    // Prepare buffer to receive response
    // --------------------------------------------------------
    final Uint8List buffer = Uint8List(256);
    int totalBytesRead = 0;

    // --------------------------------------------------------
    // Set timeout deadline (10 seconds max)
    // --------------------------------------------------------
    final DateTime deadline =
        DateTime.now().add(const Duration(seconds: 10));

    // --------------------------------------------------------
    // Poll until response received or timeout reached
    // --------------------------------------------------------
    while (DateTime.now().isBefore(deadline)) {
      final int bytesRead = await transport.read(buffer);

      if (bytesRead > 0) {
        totalBytesRead = bytesRead;
        break; // Exit once any data arrives
      }

      // Small delay to avoid CPU busy loop
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // --------------------------------------------------------
    // If no response at all → device not responding
    // --------------------------------------------------------
    if (totalBytesRead <= 0) {
      return false;
    }

    // --------------------------------------------------------
    // Validate response (very naive check)
    // --------------------------------------------------------
    final Uint8List response =
        Uint8List.fromList(buffer.sublist(0, totalBytesRead));

    return _looksLikePositiveReply(response);
  }

  /// ----------------------------------------------------------
  /// Build FAKE C902 Echo Request
  ///
  /// WARNING:
  /// - This is NOT real IM15 framing
  /// - Used only as a harmless ping
  ///
  /// Replace this with:
  /// - STX + LEN + C902 + LRC + ETX
  /// if real protocol is required
  /// ----------------------------------------------------------
  static Uint8List _buildFakeC902() {
    const String fakeFrame = 'C902\r\n';

    return Uint8List.fromList(
      ascii.encode(fakeFrame),
    );
  }

  /// ----------------------------------------------------------
  /// Naive response validator
  ///
  /// Returns true if:
  /// - ACK (0x06) is found
  /// - OR any non-empty response exists
  ///
  /// Replace with:
  /// - Proper R902 parsing
  /// - LRC validation
  /// - Command code checking
  /// ----------------------------------------------------------
  static bool _looksLikePositiveReply(Uint8List response) {
    for (final byte in response) {
      // ASCII ACK = 0x06
      if (byte == 0x06) {
        return true;
      }
    }

    // Fallback: any data means device is alive
    return response.isNotEmpty;
  }
}
