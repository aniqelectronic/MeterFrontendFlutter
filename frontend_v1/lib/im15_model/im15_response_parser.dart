import 'dart:convert';          // ASCII decoding
import 'dart:typed_data';       // Uint8List support
import 'im15_response_model.dart';

class IM15ResponseParser {
  // ---------------- R200 (SALE / QUERY) ----------------
  static IM15ResponseModel? parseR200Response(Uint8List data) {
    final raw = _cleanAscii(data);               // Remove control chars
    if (raw.length < 130) return null;            // Validate minimum length

    final model = IM15ResponseModel();
    int pos = 4;                                 // Skip STX + LEN + CMD

    model.cardNumber  = raw.substring(pos, pos += 19);
    model.expireDate  = raw.substring(pos, pos += 4);
    model.statusCode  = raw.substring(pos, pos += 2);
    model.approvalCode= raw.substring(pos, pos += 6);
    model.rrn         = raw.substring(pos, pos += 12);
    model.traceNo     = raw.substring(pos, pos += 6);
    model.batchNo     = raw.substring(pos, pos += 6);
    model.hostNo      = raw.substring(pos, pos += 2);
    model.terminalId  = raw.substring(pos, pos += 8);
    model.merchantId  = raw.substring(pos, pos += 15);
    model.aid         = raw.substring(pos, pos += 14);
    model.amount      = raw.substring(pos, pos + 12);

    return model;
  }

  // ---------------- R201 (VOID) ----------------
  static IM15ResponseModel? parseR201Response(Uint8List data) {
    final raw = _cleanAscii(data);
    if (raw.length < 60) return null;

    final model = IM15ResponseModel();
    int pos = 4;

    try {
      model.amount      = raw.substring(pos, pos += 12);
      model.statusCode  = raw.substring(pos, pos += 2);
      model.approvalCode= raw.substring(pos, pos += 6);
      model.rrn         = raw.substring(pos, pos += 12);
      model.traceNo     = raw.substring(pos, pos += 6);
      model.batchNo     = raw.substring(pos, pos += 6);
      model.hostNo      = raw.substring(pos, pos += 2);
    } catch (_) {
      return null;
    }

    return model;
  }

  // ---------------- Q290 (QUERY) ----------------
  static IM15ResponseModel? parseQ290Response(Uint8List data) {
    final raw = _cleanAscii(data);
    if (raw.length < 80) return null;

    final model = IM15ResponseModel();
    int pos = 4;

    try {
      model.statusCode  = raw.substring(pos, pos += 2);
      model.approvalCode= raw.substring(pos, pos += 6);
      model.rrn         = raw.substring(pos, pos += 12);
      model.traceNo     = raw.substring(pos, pos += 6);
      model.batchNo     = raw.substring(pos, pos += 6);
      model.hostNo      = raw.substring(pos, pos += 2);
      model.terminalId  = raw.substring(pos, pos += 8);
      model.merchantId  = raw.substring(pos, pos + 15);
    } catch (_) {
      return null;
    }

    return model;
  }

  // ---------------- R500 (SETTLEMENT) ----------------
  static IM15ResponseModel? parseR500Response(Uint8List data) {
    final raw = _cleanAscii(data);
    if (raw.length < 29) return null;

    final model = IM15ResponseModel();
    int pos = 4;

    try {
      model.hostNo       = raw.substring(pos, pos += 2);
      model.statusCode   = raw.substring(pos, pos += 2);
      model.batchNo      = raw.substring(pos, pos += 6);
      model.batchCount   = raw.substring(pos, pos += 3);
      model.batchAmount  = raw.substring(pos, pos + 12);
    } catch (_) {
      return null;
    }

    return model;
  }

  // ---------------- R902 (ECHO TEST) ----------------
  static IM15ResponseModel? parseR902Response(Uint8List data) {
    final raw = _cleanAscii(data);
    if (raw.length < 6) return null;

    final model = IM15ResponseModel();
    model.statusCode = raw.substring(4, 6); // Only status code exists
    return model;
  }

  // ---------------- R208 (QUERY SAME AS R200) ----------------
  static IM15ResponseModel? parseR208Response(Uint8List data) {
    return parseR200Response(data);
  }

  // ---------------- UTIL: CLEAN ASCII ----------------
  static String _cleanAscii(Uint8List data) {
    return ascii
        .decode(data, allowInvalid: true)
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '');
  }

  // ---------------- UTIL: HEX DUMP ----------------
  static String bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  }

  static void printDebug(IM15ResponseModel model) {
  print('--- IM15 Response Debug ---');
  print('Card Number : ${model.cardNumber}');
  print('Expire Date : ${model.expireDate}');
  print('Status Code : ${model.statusCode}');
  print('Approval Code : ${model.approvalCode}');
  print('RRN : ${model.rrn}');
  print('Trace No : ${model.traceNo}');
  print('Batch No : ${model.batchNo}');
  print('Host No : ${model.hostNo}');
  print('Terminal Id : ${model.terminalId}');
  print('Merchant Id : ${model.merchantId}');
  print('AID : ${model.aid}');
  print('Amount : ${model.amount}');
  print('Batch Count : ${model.batchCount}');
  print('Batch Amount : ${model.batchAmount}');
  print('---------------------------');
}

}
