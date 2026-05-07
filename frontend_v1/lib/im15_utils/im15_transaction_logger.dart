import 'dart:io';

class IM15TransactionLogger {
  final String logFilePath;
  final StringBuffer sessionLog = StringBuffer();

  IM15TransactionLogger(String testName)
      : logFilePath = 'logs/${testName}_${DateTime.now().toIso8601String()}.log' {
    logHeader(testName);
  }

  void logSend(String data) => sessionLog.writeln(' send: $data');
  void logRecv(String data) => sessionLog.writeln(' recv: $data');
  void logInfo(String msg) => sessionLog.writeln(' info: $msg');

  void logSendBytes(List<int> data, String label) {
    sessionLog.writeln(' send: $label [${data.length} bytes]');
    sessionLog.writeln(_formatHexBlock(data));
  }

  void logRecvBytes(List<int> data, String label) {
    sessionLog.writeln(' recv: $label [${data.length} bytes]');
    sessionLog.writeln(_formatHexBlock(data));
  }

  String _formatHexBlock(List<int> data) {
    StringBuffer sb = StringBuffer('      ');
    for (int i = 0; i < data.length; i++) {
      sb.write(data[i].toRadixString(16).padLeft(2, '0').toUpperCase() + ' ');
      if ((i + 1) % 16 == 0) sb.writeln('      ');
    }
    return sb.toString().trimRight();
  }

  void logHeader(String testName) => sessionLog.writeln('\n ---- Transaction Start : $testName ----');

  void endSession() {
    sessionLog.writeln('\n ---- Transaction End ----');
    try {
      // Ensure logs directory exists
      Directory('logs').createSync(recursive: true);
      File(logFilePath).writeAsStringSync(sessionLog.toString());
      print('Log saved successfully to: $logFilePath');
    } catch (e) {
      // Log the error but don't crash
      print('Failed to save log file: $e');
      print('Log content (not saved): ${sessionLog.toString()}');
      // You could also add this to sessionLog if needed
    }
  }

  void saveAs(String newPath) {
    try {
      File(newPath).writeAsStringSync(sessionLog.toString());
      print('Log saved successfully to: $newPath');
    } catch (e) {
      print('Failed to save log file to $newPath: $e');
    }
  }

  String getLogPreview() => sessionLog.toString();
  void appendCustomLine(String line) => sessionLog.writeln(line);
  
  void removeLineContaining(String keyword) {
    var lines = sessionLog.toString().split('\n');
    sessionLog.clear();
    for (var l in lines) {
      if (!l.contains(keyword)) sessionLog.writeln(l);
    }
  }

  void replace(String target, String replacement) {
    String s = sessionLog.toString();
    sessionLog.clear();
    sessionLog.write(s.replaceAll(target, replacement));
  }
}
