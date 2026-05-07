import 'package:flutter/services.dart';
import '../im15_services/c902_echo_test_service.dart';
import '../im15_serial/im15_serial_connection_manager.dart';

/// Test C902 Echo Transaction
Future<void> main() async {
  // 1. Load properties from asset
  final props = await loadPropertiesFromAsset('assets/im15.properties');

  // 2. Create Serial Manager from properties
  final mgr = IM15SerialConnectionManager.fromPropertiesMap(props);

  // 3. Create C902EchoTestService
  final svc = C902EchoTestService(mgr);

  try {
    final ok = await svc.echo();
    print(ok ? 'C902 ECHO: OK' : 'C902 ECHO: FAIL');
  } finally {
    await mgr.close();
  }
}

/// Load properties from Flutter asset (im15.properties)
Future<Map<String, String>> loadPropertiesFromAsset(String assetPath) async {
  final data = await rootBundle.loadString(assetPath);
  final Map<String, String> map = {};
  for (var line in data.split('\n')) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final idx = line.indexOf('=');
    if (idx > 0) {
      final key = line.substring(0, idx).trim();
      final value = line.substring(idx + 1).trim();
      map[key] = value;
    }
  }
  return map;
}
