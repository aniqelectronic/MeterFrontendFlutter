import 'im15_serial_backed_service.dart';
import '../im15_protocol/im15_c902_echo_probe.dart';
import '../im15_serial/im15_serial_connection_manager.dart';

/// Service to perform C902 Echo Test (ping the terminal)
class C902EchoTestService extends IM15SerialBackedService {
  C902EchoTestService(IM15SerialConnectionManager mgr) : super(mgr);

  /// Returns true if terminal responds to C902 echo
  Future<bool> echo() async {
    await ensureTransport();
    final t = transport!;
    return IM15C902EchoProbe.probe(t);
  }
}
