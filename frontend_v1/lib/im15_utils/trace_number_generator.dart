class TraceNumberGenerator {
  static int _counter = 1;

  static String generate(String prefix) {
    final number = _counter++;
    return '$prefix${number.toString().padLeft(7, '0')}';
  }

  static void reset() => _counter = 1;
}
