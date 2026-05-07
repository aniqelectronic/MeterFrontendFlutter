import 'dart:typed_data';
import 'dart:convert';

class IM15PacketBuilder {
  static const int ETX = 0x03;

  // ---------- GENERIC PACKET BUILDER ----------
  static Uint8List buildPacket(Uint8List dataBytes) {
    Uint8List packet = Uint8List(dataBytes.length + 2);
    packet.setAll(0, dataBytes);
    packet[packet.length - 2] = ETX; // Add ETX before LRC
    packet[packet.length - 1] = calculateLRC(packet, 0, packet.length - 1);
    return packet;
  }

  // ---------- LRC CALCULATION ----------
  static int calculateLRC(Uint8List data, int offset, int length) {
    int lrc = 0;
    for (int i = offset; i < offset + length; i++) {
      lrc ^= data[i];
    }
    return lrc;
  }

  // ---------- STRING PAD HELPERS ----------
  static String padLeft(String input, int length) => input.padLeft(length, '0');
  static String padRight(String input, int length) => input.padRight(length, ' ');

  // ---------- PACKETS ----------

  // C200 Sale
  static Uint8List buildC200Packet(String hostNo, String accountType, String amount, String additionalData) {
    String data = "C200" +
        padLeft(hostNo, 2) +
        accountType +
        padLeft(amount, 12) +
        padRight(additionalData, 24);
    return buildPacket(Uint8List.fromList(utf8.encode(data)));
  }

  // C201 Void
  static Uint8List buildC201Packet(String hostNo, String amount, String traceNo, String refNo) {
    String data = "C201" +
        padLeft(hostNo, 2) +
        padLeft(amount, 12) +
        padLeft(traceNo, 7) +
        padRight(refNo, 12);
    return buildPacket(Uint8List.fromList(utf8.encode(data)));
  }

  // C208 Refund (full version with 4 params)
  static Uint8List buildC208Packet(String hostNo, String amount, String traceNo, String refNo) {
    String data = "C208" +
        padLeft(hostNo, 2) +
        padLeft(amount, 12) +
        padLeft(traceNo, 7) +
        padRight(refNo, 12);
    return buildPacket(Uint8List.fromList(utf8.encode(data)));
  }

  // ---------- C208 QUERY (2 params) ----------
  static Uint8List buildC208QueryPacket(String hostNo, String transactionId) {
    String data = "C208" +
        padLeft(hostNo, 2) +
        padRight(transactionId, 24);
    return buildPacket(Uint8List.fromList(utf8.encode(data)));
  }

  // C500 Balance/Inquiry
  static Uint8List buildC500Packet(String hostNo, String additionalData) {
    String data = "C500" +
        padLeft(hostNo, 2) +
        padRight(additionalData, 24);
    return buildPacket(Uint8List.fromList(utf8.encode(data)));
  }

  // C290 Terminal-specific
  static Uint8List buildC290Packet(String hostNo, String additionalData) {
    String data = "C290" +
        padLeft(hostNo, 2) +
        padRight(additionalData, 24);
    return buildPacket(Uint8List.fromList(utf8.encode(data)));
  }

  // C902 Test / Debug
  static Uint8List buildC902Packet() {
    return buildPacket(Uint8List.fromList(utf8.encode("C902")));
  }
}
