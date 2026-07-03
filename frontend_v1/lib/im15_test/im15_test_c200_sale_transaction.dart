import 'dart:convert';
import 'dart:typed_data'; // <-- needed for Uint8List
import '../im15_serial/im15_serial_connection_manager.dart';
import '../im15_services/c200_sale_service.dart';
import '../im15_serial/im15_serial_settings.dart';

/// Flutter equivalent of Java IM15TestC200SaleTransaction
Future<void> main() async {
  // Load serial config manually (replace with your real config)
  final cfg = IM15SerialSettings(
    explicitPort: '/dev/ttyUSB5', // change to your port
    baudRate: 9600,
    dataBits: 8,
    stopBits: 1,
    parity: 0,
    readTimeoutMs: 1000,
    writeTimeoutMs: 1000,
    openTimeoutMs: 300,
  );

  final mgr = IM15SerialConnectionManager(cfg);

  // Open service
  final svc = C200SaleService(mgr);

  try {
    // Build your actual C200 SALE frame
    final c200Frame = buildYourC200FrameExample();

    // Run sale
    final resp = await svc.runSale(c200Frame);

    print('C200 response length = ${resp.length}');
    print('Raw response bytes: $resp');

    // TODO: parse bytes to R200 structure
  } catch (e) {
    print('C200 transaction failed: $e');
  } finally {
    await svc.close();
  }
}

/// Build a placeholder C200 frame (convert to Uint8List for serial)
Uint8List buildYourC200FrameExample() {
  // Replace with your real frame builder (amount/source/type/CRC, etc.)
  return Uint8List.fromList(utf8.encode('C200,065\r\n')); // convert List<int> to Uint8List
}
