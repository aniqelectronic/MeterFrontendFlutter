import 'dart:io';

class LogUtils {
  static const String logDir = 'logs/payment/';

  static void ensureLogDir() {
    final dir = Directory(logDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }
}
