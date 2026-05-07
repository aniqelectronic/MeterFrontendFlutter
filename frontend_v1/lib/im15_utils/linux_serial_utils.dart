import 'dart:io';

class LinuxSerialUtils {
  LinuxSerialUtils._();

  static bool isLinux() {
    return Platform.isLinux;
  }

  // Since Flutter/Dart doesn't have real /dev access cross-platform,
  // we just return empty map. Implement only if using on Linux with dart:io access.
  static Map<String, String> listStableSerialLinks() {
    if (!isLinux()) return {};
    return {}; // TODO: optionally implement using Directory('/dev/serial/by-id') etc.
  }

  static String? findStableAliasFor(String? realDevice) {
    if (realDevice == null) return null;
    return listStableSerialLinks().entries
        .firstWhere(
          (e) => e.value == realDevice.trim(),
          orElse: () => MapEntry('', ''),
        )
        .key
        .isEmpty
        ? null
        : listStableSerialLinks().entries
            .firstWhere((e) => e.value == realDevice.trim())
            .key;
  }
}
