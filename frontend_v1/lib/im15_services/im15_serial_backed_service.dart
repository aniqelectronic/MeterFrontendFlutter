import '../im15_serial/im15_serial_connection_manager.dart';
import '../im15_serial/im15_transport.dart';

/// Base class for services backed by an IM15 serial connection
/// Handles opening, ensuring, and closing the transport
abstract class IM15SerialBackedService {
  final IM15SerialConnectionManager connMgr;
  IM15Transport? transport;

  IM15SerialBackedService(this.connMgr);

  /// Ensure the transport is opened before use
  Future<void> ensureTransport() async {
    if (transport == null || !transport!.isOpen) {
      transport = await connMgr.detectAndOpen();
    }
  }

  /// Close transport safely
  Future<void> close() async {
    if (transport != null) {
      await connMgr.close(); // let manager own lifecycle
      transport = null;
    }
  }
}
