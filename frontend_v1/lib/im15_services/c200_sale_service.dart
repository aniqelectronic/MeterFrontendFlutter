import 'im15_serial_backed_service.dart';
import '../im15_serial/im15_serial_connection_manager.dart';
import 'dart:typed_data';

/// Service to perform generic C200 Sale transaction
class C200SaleService extends IM15SerialBackedService {
  C200SaleService(IM15SerialConnectionManager mgr) : super(mgr);

  /// Run a C200 sale transaction.
  /// Sends the framed C200 packet and returns the raw response bytes.
  Future<Uint8List> runSale(Uint8List c200Frame) async {
    // Ensure transport is opened
    await ensureTransport();
    final t = transport!;

    // Write the fully-framed C200 bytes
    await t.write(c200Frame);

    // Prepare buffer and read response
    final buffer = Uint8List(1024);       // max buffer size
    final n = await t.read(buffer);

   if (n <= 0) {
     throw Exception("No response to C200 transaction");
   }

    // Return only the filled portion of the buffer
    return buffer.sublist(0, n);
  }
}
