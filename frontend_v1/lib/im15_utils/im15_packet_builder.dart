import 'dart:convert';
import 'dart:typed_data';

class IM15PacketBuilder {
  static const int ETX = 0x03;

  // =========================================================
  // GENERIC PACKET BUILDER
  // Output: MSG + ETX + LRC
  // NOTE: STX is sent separately in PaxIM15C200Sale
  // LRC excludes STX and includes ETX
  // =========================================================
  static Uint8List buildPacket(Uint8List dataBytes) {
    final packet = Uint8List(dataBytes.length + 2);

    packet.setAll(0, dataBytes);
    packet[packet.length - 2] = ETX;
    packet[packet.length - 1] = calculateLRC(packet, 0, packet.length - 1);

    return packet;
  }

  static int calculateLRC(Uint8List data, int offset, int length) {
    int lrc = 0;
    for (int i = offset; i < offset + length; i++) {
      lrc ^= data[i];
    }
    return lrc;
  }

  // =========================================================
  // FIXED LENGTH HELPERS
  // Important: pad AND trim to exact length
  // =========================================================
  static String fixedNumeric(String input, int length) {
    final clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    final padded = clean.padLeft(length, '0');
    return padded.length > length
        ? padded.substring(padded.length - length)
        : padded;
  }

  static String fixedText(String input, int length) {
    final padded = input.padRight(length, ' ');
    return padded.length > length ? padded.substring(0, length) : padded;
  }

  static String fixedOne(String input, {String fallback = '0'}) {
    if (input.isEmpty) return fallback;
    return input.substring(0, 1);
  }

  static Uint8List _asciiPacket(String data, String name) {
    final packet = buildPacket(Uint8List.fromList(ascii.encode(data)));

    print('[IM15PacketBuilder] $name="$data"');
    print('[IM15PacketBuilder] $name data length=${data.length}');
    print('[IM15PacketBuilder] $name packet length=${packet.length}');
    print(
      '[IM15PacketBuilder] $name LRC=0x${packet.last.toRadixString(16).padLeft(2, '0').toUpperCase()}',
    );

    return packet;
  }

  // =========================================================
  // C200 SALE
  // Format:
  // C200 + HostNo(2) + AccountType(1) + Amount(12) + AdditionalData(24)
  // Data length must be 43, packet length must be 45
  // =========================================================
  static Uint8List buildC200Packet(
    String hostNo,
    String accountType,
    String amount,
    String additionalData,
  ) {
    final h = fixedNumeric(hostNo, 2);
    final acc = fixedOne(accountType);
    final amt = fixedNumeric(amount, 12);
    final add = fixedText(additionalData, 24);

    final data = 'C200$h$acc$amt$add';

    return _asciiPacket(data, 'C200');
  }

  // =========================================================
  // C201 VOID
  // Spec:
  // C201 + HostNo(2) + Amount(12) + TraceNo(6)
  // =========================================================
  static Uint8List buildC201Packet(
    String hostNo,
    String amount,
    String traceNo, [
    String refNo = '',
  ]) {
    final data = 'C201'
        '${fixedNumeric(hostNo, 2)}'
        '${fixedNumeric(amount, 12)}'
        '${fixedNumeric(traceNo, 6)}';

    return _asciiPacket(data, 'C201');
  }

  // =========================================================
  // C208 QUERY SALE TRANSACTION
  // Spec:
  // C208 + HostNo(2) + TransactionId(24)
  // =========================================================
  static Uint8List buildC208QueryPacket(
    String hostNo,
    String transactionId,
  ) {
    final data = 'C208'
        '${fixedNumeric(hostNo, 2)}'
        '${fixedText(transactionId, 24)}';

    return _asciiPacket(data, 'C208_QUERY');
  }

  // Kept for compatibility with old calls
  static Uint8List buildC208Packet(
    String hostNo,
    String amount,
    String traceNo,
    String refNo,
  ) {
    return buildC208QueryPacket(hostNo, refNo.isNotEmpty ? refNo : traceNo);
  }

  // =========================================================
  // C500 SETTLEMENT
  // Spec:
  // C500 + HostNo(2)
  // =========================================================
  static Uint8List buildC500Packet(
    String hostNo, [
    String additionalData = '',
  ]) {
    final data = 'C500${fixedNumeric(hostNo, 2)}';
    return _asciiPacket(data, 'C500');
  }

  // =========================================================
  // C902 ECHO TEST
  // Spec:
  // C902
  // =========================================================
  static Uint8List buildC902Packet() {
    return _asciiPacket('C902', 'C902');
  }

  // =========================================================
  // C903 HOST AVAILABILITY
  // Spec:
  // C903 + HostNo(2)
  // =========================================================
  static Uint8List buildC903Packet(String hostNo) {
    final data = 'C903${fixedNumeric(hostNo, 2)}';
    return _asciiPacket(data, 'C903');
  }

  // =========================================================
  // C904 GET TID & MID
  // Spec:
  // C904 + HostNo(2)
  // =========================================================
  static Uint8List buildC904Packet(String hostNo) {
    final data = 'C904${fixedNumeric(hostNo, 2)}';
    return _asciiPacket(data, 'C904');
  }

  // =========================================================
  // C906 SCAN COMMAND
  // Spec:
  // C906
  // =========================================================
  static Uint8List buildC906Packet() {
    return _asciiPacket('C906', 'C906');
  }

  // =========================================================
  // C910 READ CARD
  // Spec:
  // C910
  // =========================================================
  static Uint8List buildC910Packet() {
    return _asciiPacket('C910', 'C910');
  }

  // =========================================================
  // C911 GET TOKEN
  // Spec:
  // C911
  // =========================================================
  static Uint8List buildC911Packet() {
    return _asciiPacket('C911', 'C911');
  }

  // =========================================================
  // C912 GET FAST TOKEN
  // Spec:
  // C912
  // =========================================================
  static Uint8List buildC912Packet() {
    return _asciiPacket('C912', 'C912');
  }

  // =========================================================
  // C920 TIME SYNC GET
  // Spec:
  // C920
  // =========================================================
  static Uint8List buildC920Packet() {
    return _asciiPacket('C920', 'C920');
  }

  // =========================================================
  // C921 TIME SYNC SET
  // Spec:
  // C921 + yyMMddhhmmss(12)
  // =========================================================
  static Uint8List buildC921Packet(String dateTimeYYMMDDhhmmss) {
    final data = 'C921${fixedNumeric(dateTimeYYMMDDhhmmss, 12)}';
    return _asciiPacket(data, 'C921');
  }

  // =========================================================
  // C290 QR / EWALLET SALE
  // Basic builder:
  // C290 + HostNo(2) + Amount(12) + QrcodeID(2)
  // + QrcodeNo(LLLL + value) + AdditionalData(24)
  // =========================================================
  static Uint8List buildC290Packet(
    String hostNo,
    String amount,
    String qrcodeId,
    String qrcodeNo,
    String additionalData,
  ) {
    final qrValue = qrcodeNo;
    final qrLength = fixedNumeric(qrValue.length.toString(), 4);

    final data = 'C290'
        '${fixedNumeric(hostNo, 2)}'
        '${fixedNumeric(amount, 12)}'
        '${fixedNumeric(qrcodeId, 2)}'
        '$qrLength'
        '$qrValue'
        '${fixedText(additionalData, 24)}';

    return _asciiPacket(data, 'C290');
  }
}