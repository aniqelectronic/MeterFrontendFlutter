import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScannerService {
  final StreamController<String> _controller = StreamController<String>.broadcast();
  Stream<String> get scans => _controller.stream;

  final StringBuffer _buffer = StringBuffer();
  Timer? _timeout;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    HardwareKeyboard.instance.addHandler(_handleKey);
    debugPrint('SCANNER: Listener started');
  }

  bool _handleKey(KeyEvent event) {
    if (!_started || event is! KeyDownEvent) return false;

    final key = event.logicalKey;
    final char = event.character;

    debugPrint('SCANNER KEY: ${key.keyLabel}, CHAR: $char');

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _submit();
      return false;
    }

    if (char == null || char.isEmpty) return false;
    if (char.runes.length != 1) return false;

    final code = char.runes.first;
    if (code < 32 || code == 127) return false;

    if (_buffer.length >= 256) {
      _clear();
      return false;
    }

    _buffer.write(char);

    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 3), () {
      debugPrint('SCANNER: Input timeout');
      _clear();
    });

    return false;
  }

  void _submit() {
    final value = _buffer.toString().trim();
    _clear();

    if (value.isEmpty) return;

    debugPrint('SCANNER RESULT: $value');

    if (!_controller.isClosed) {
      _controller.add(value);
    }
  }

  void _clear() {
    _timeout?.cancel();
    _timeout = null;
    _buffer.clear();
  }

  void stop() {
    if (!_started) return;
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _started = false;
    _clear();
    debugPrint('SCANNER: Listener stopped');
  }

  void dispose() {
    stop();
    _controller.close();
  }
}