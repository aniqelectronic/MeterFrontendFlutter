import 'dart:io';

/// Loads a simple Java-style properties file (key=value) into a Map
class Properties {
  final Map<String, String> _data = {};

  Properties();

  /// Load from file path
  Future<void> loadFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final lines = await file.readAsLines();
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue; // skip comments
      final split = line.split('=');
      if (split.length >= 2) {
        _data[split[0].trim()] = split.sublist(1).join('=').trim();
      }
    }
  }

  /// Get value with optional default
  String? getProperty(String key, [String? defaultValue]) {
    return _data[key] ?? defaultValue;
  }

  /// Set or override a property
  void setProperty(String key, String value) {
    _data[key] = value;
  }
}
