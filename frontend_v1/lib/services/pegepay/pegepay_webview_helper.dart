import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/services/pegepay/pegepay_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:frontend_v1/services/kiosk/linux_kiosk_service.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:frontend_v1/services/api/api_hmac_helper.dart';

class PegePayWebViewHelper {
  static Webview? _currentWebview;
  static Timer? _statusTimer;

  /// Every newly opened QR receives a different session ID.
  ///
  /// This prevents an old WebView's delayed onClose callback
  /// from cancelling a newly opened payment.
  static int _activeSessionId = 0;

  /// Session currently being closed by Flutter.
  ///
  /// When onClose fires for this session, it must not call
  /// onCancel again.
  static int? _programmaticClosingSessionId;

  static bool _isClosing = false;
  static Future<void>? _closingOperation;
  static final Set<int> _intentionalCloseSessions = <int>{};
  // Tracks a Windows native QR window that has been asked to close.
  static Future<void>? _pendingWindowsClose;

  static DateTime? _lastWebViewClosedAt;
  static const Duration _webViewCooldown = Duration(seconds: 3);
  static int? _restoredSessionId;

  // ============================================================
  // OPEN PEGEpay QR WEBVIEW
  // ============================================================

  static Future<void> open({
    required String iframeUrl,
    required String orderNo,
    required Function(Map<String, dynamic>) onSuccess,
    required Function onCancel,
    FutureOr<void> Function()? onPaymentDetected,
    FutureOr<void> Function()? onQrWindowOpened,
    FutureOr<void> Function(String message)? onError,
  }) async {
    print('[PegePay] Opening QR for order: $orderNo');

    Future<void> reportOpenError(String message) async {
      print('[PegePay] OPEN ERROR: $message');
      try {
        if (onError != null) {
          await onError(message);
        } else {
          // Backwards compatibility for other payment pages.
          await Future<void>.sync(() => onCancel());
        }
      } catch (error) {
        print('[PegePay] Error callback failed: $error');
      }
    }

    /*
     * Invalidate every callback belonging to the previous WebView
     * before closing that previous window.
     */
    // Complete any in-flight teardown before starting a new session.
    if (_closingOperation != null) {
      try {
        await _closingOperation!.timeout(const Duration(seconds: 10));
      } catch (error) {
        print('[PegePay] Previous teardown still pending: $error');
      }
    }

    _intentionalCloseSessions.removeWhere((id) => id < _activeSessionId);
    final int sessionId = ++_activeSessionId;

    // Pause the Linux kiosk focus guard before creating the
    // separate native PegePay QR window.
    if (Platform.isLinux) {
      LinuxKioskService.allowSecondaryWindow();
    }

    currentRouteName = '/payment';

try {
  await _closeOldWebView();
  await _waitForWebViewCooldown();

  if (Platform.isWindows && _pendingWindowsClose != null) {
    try {
      await _pendingWindowsClose!.timeout(const Duration(seconds: 8));
    } on TimeoutException {
      print('[PegePay] Clearing stale Windows close wait');
      _pendingWindowsClose = null;
    }
  }
} catch (e) {
  print('[PegePay] Previous QR window is not ready: $e');

  if (sessionId == _activeSessionId) {
    await _restoreFlutterWindow(sessionId: sessionId);

    try {
      await reportOpenError('Previous QR window is not ready: $e');
    } catch (error) {
      print('[PegePay] Failed to cancel pending QR: $error');
    }
  }

  return;
}

    /*
     * Another open() might have started while cleanup was running.
     */
    if (sessionId != _activeSessionId) {
      print('[PegePay] Open request superseded by a newer session');
      return;
    }

    bool finished = false;
    bool cancelCallbackCalled = false;

    // WINDOWS ONLY: fetch the authenticated page before opening a native window.
    // Linux retains its existing creation/download/launch order.
    String? windowsWrapperUrl;
    if (Platform.isWindows) {
      try {
        windowsWrapperUrl = await _prepareWindowsWrapper(iframeUrl, sessionId);
      } catch (error) {
        if (sessionId == _activeSessionId) {
          await _restoreFlutterWindow(sessionId: sessionId);
          await reportOpenError('Cannot load QR wrapper: $error');
        }
        return;
      }
    }

    late final Webview webview;

    try {
      webview = await WebviewWindow.create(
        configuration: const CreateConfiguration(
          /*
           * Initial Linux window title.
           *
           * After the webpage loads, Linux may change this to:
           * "PegePay QR Payment"
           */
          title: 'PegePayQR',

          /*
           * Temporary size only.
           * The Linux commands below force fullscreen afterward.
           */
          windowWidth: 800,
          windowHeight: 1280,
          windowPosX: 0,
          windowPosY: 0,
          useWindowPositionAndSize: true,
          openMaximized: true,
        ),
      );

      if (sessionId != _activeSessionId) {
        try {
          webview.close();
        } catch (_) {}

        return;
      }

      _currentWebview = webview;
    } catch (e) {
      print('[PegePay] Failed to create WebView: $e');

      if (sessionId == _activeSessionId) {
        finished = true;
        await _restoreFlutterWindow(sessionId: sessionId);

        if (!cancelCallbackCalled) {
          cancelCallbackCalled = true;
          await reportOpenError('Failed to create QR window: $e');
        }
      }

      return;
    }

    // ==========================================================
    // WEBVIEW WINDOW CLOSED
    // ==========================================================

    unawaited(webview.onClose.then<void>((_) async {
      print(
        '[PegePay] onClose received for session $sessionId',
      );


      /*
       * Very important:
       *
       * Ignore onClose events from old WebViews. Previously, an old
       * delayed callback could cancel the newly opened QR screen.
       */
      if (sessionId != _activeSessionId) {
        _intentionalCloseSessions.remove(sessionId);
        print(
          '[PegePay] Ignoring old onClose event '
          'for session $sessionId',
        );
        return;
      }

      _statusTimer?.cancel();
      _statusTimer = null;


      if (identical(_currentWebview, webview)) {
        _currentWebview = null;
      }

      _lastWebViewClosedAt = DateTime.now();

      await _restoreFlutterWindow(sessionId: sessionId);

      /*
       * Flutter intentionally closed this window because:
       * - Cancel was pressed
       * - payment succeeded
       * - close() was called
       */
      if (_intentionalCloseSessions.remove(sessionId) ||
          _programmaticClosingSessionId == sessionId || finished) {
        print(
          '[PegePay] Programmatic close completed '
          'for session $sessionId',
        );
        return;
      }

      /*
       * The user manually pressed the Linux X button.
       */
      print('[PegePay] User pressed X');

      finished = true;

      if (!cancelCallbackCalled) {
        cancelCallbackCalled = true;

        try {
          await Future<void>.sync(() => onCancel());
        } catch (e) {
          print(
            '[PegePay] onCancel failed after X close: $e',
          );
        }
      }
    }).catchError((Object error, StackTrace trace) {
      print('[PegePay] onClose callback error: $error');
    }));

    // ==========================================================
    // CANCEL BUTTON FROM THE BACKEND WRAPPER
    // ==========================================================

    webview.addOnUrlRequestCallback((url) {
      print('[PegePay] URL request: $url');

      if (!url.startsWith('app://cancelPayment')) {
        return;
      }

      if (sessionId != _activeSessionId) {
        print('[PegePay] Ignoring cancel from old session');
        return;
      }

      if (finished || _isClosing) {
        print('[PegePay] Cancel already being processed');
        return;
      }

      print('[PegePay] Cancel button pressed');

      finished = true;

      unawaited(
        _handleCancel(
          sessionId: sessionId,
          onCancel: () async {
            if (cancelCallbackCalled) {
              return;
            }

            cancelCallbackCalled = true;
            await Future<void>.sync(() => onCancel());
          },
        ),
      );
    });

    // ==========================================================
    // AUTHENTICATED WRAPPER REQUEST
    // ==========================================================

    final wrapperUri = Uri.parse(
      '${Config.apiBaseUrl}/pegepay/iframe-wrapper',
    ).replace(
      queryParameters: {
        'iframe_url': iframeUrl,
      },
    );

    print('[PegePay] Wrapper URL: $wrapperUri');

    String localWrapperUrl;

    try {
      if (Platform.isWindows && windowsWrapperUrl != null) {
        localWrapperUrl = windowsWrapperUrl;
      } else {
      final wrapperResponse = await http
          .get(
            wrapperUri,
            headers: ApiHmacHelper.createHeaders(
              method: 'GET',
              uri: wrapperUri,
              body: '',
              accept: 'text/html',
            ),
          )
          .timeout(
            const Duration(seconds: 20),
          );

      print(
        '[PegePay] Wrapper response status: '
        '${wrapperResponse.statusCode}',
      );

      if (wrapperResponse.statusCode != 200) {
        throw Exception(
          'Failed to load PegePay wrapper: '
          '${wrapperResponse.statusCode} '
          '${wrapperResponse.body}',
        );
      }

      final temporaryDirectory =
          await getTemporaryDirectory();

      final wrapperFile = File(
        '${temporaryDirectory.path}'
        '${Platform.pathSeparator}'
        'pegepay_wrapper_$sessionId.html',
      );

      await wrapperFile.writeAsString(
        wrapperResponse.body,
        encoding: utf8,
        flush: true,
      );

      localWrapperUrl = wrapperFile.uri.toString();

      print(
        '[PegePay] Local wrapper URL: '
        '$localWrapperUrl',
      );
      }
    } catch (e) {
      print(
        '[PegePay] Failed to download wrapper HTML: $e',
      );

      if (sessionId == _activeSessionId) {
        finished = true;

        await _closeCurrentWebView(
          sessionId: sessionId,
        );

        if (!cancelCallbackCalled) {
          cancelCallbackCalled = true;
          await reportOpenError('Failed to download QR wrapper: $e');
        }
      }

      return;
    }

    // Do not launch into a window closed while its wrapper was downloading.
    if (sessionId != _activeSessionId || finished ||
        !identical(_currentWebview, webview)) {
      return;
    }

    // ==========================================================
    // LAUNCH LOCAL AUTHENTICATED HTML
    // ==========================================================

    try {
      if (Platform.isWindows) {
        // Future.sync works with both void and Future-returning plugin versions.
        await Future<void>.sync(() => webview.launch(localWrapperUrl));
      } else {
        // Original Linux launch sequence is intentionally unchanged.
        webview.launch(localWrapperUrl);
      }
    } catch (e) {
      print('[PegePay] Failed to launch WebView: $e');

      if (sessionId == _activeSessionId && !finished) {
        finished = true;

        await _closeCurrentWebView(
          sessionId: sessionId,
        );

        if (!cancelCallbackCalled) {
          cancelCallbackCalled = true;
          await reportOpenError('Failed to launch QR content: $e');
        }
      }

      return;
    }

    /*
     * Run fullscreen detection in the background.
     *
     * It checks both possible Linux window titles:
     * - PegePayQR
     * - PegePay QR Payment
     */
      if (Platform.isLinux) {
        unawaited(
          _makeWebViewFullscreen(
            sessionId: sessionId,
            onQrWindowOpened: onQrWindowOpened,
          ),
        );
      } else if (Platform.isWindows) {
        if (onQrWindowOpened != null) {
          try {
            await onQrWindowOpened();
          } catch (error) {
            print('[PegePay] Opening overlay callback failed: $error');
          }
        }
      }
    // The opening overlay is closed only after the native QR window
    // is found and brought to the front. Minimize monitoring is not
    // used in this flow. If the QR window is minimized, the next QR
    // attempt closes the old WebView before opening a fresh one.


    // ==========================================================
    // CHECK PAYMENT STATUS
    // ==========================================================

    _statusTimer?.cancel();

    bool statusRequestRunning = false;

    _statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        if (sessionId != _activeSessionId || finished) {
          timer.cancel();
          return;
        }

        /*
         * Prevent overlapping HTTP status requests if one request
         * takes longer than two seconds.
         */
        if (statusRequestRunning) {
          return;
        }

        statusRequestRunning = true;

        try {
          // One authoritative result for this exact order, rather than a true
          // first response followed by unchecked/failed details from a second.
          final paymentResult = await PegePayService.checkStatusDetails(orderNo)
              .timeout(const Duration(seconds: 10));
          if (sessionId != _activeSessionId || finished) return;

          final confirmedOrder = paymentResult['order_no']?.toString().trim();
          if (paymentResult['success'] != true || confirmedOrder != orderNo) {
            // False, timeout and incomplete details are NOT payment approval.
            return;
          }
          print('[PegePay] VERIFIED payment for $orderNo');
          finished = true;
          timer.cancel();
          _statusTimer = null;

          /*
           * Update the Flutter transition overlay before closing
           * the native QR window. The overlay is behind the WebView,
           * so when Flutter becomes visible it already shows success.
           */
          if (onPaymentDetected != null) {
            try {
              await onPaymentDetected();
            } catch (e) {
              print(
                '[PegePay] onPaymentDetected callback failed: $e',
              );
            }
          }

          /*
           * Keep the existing safe Linux close/restore sequence.
           */
          await _closeCurrentWebView(
            sessionId: sessionId,
          );

          try {
            await Future<void>.sync(() => onSuccess(paymentResult));
          } catch (e) {
            print(
              '[PegePay] onSuccess callback failed: $e',
            );
          }
        } catch (e) {
          print('[PegePay] Status check error: $e');
        } finally {
          statusRequestRunning = false;
        }
      },
    );
  }

  static Future<String> _prepareWindowsWrapper(
    String iframeUrl,
    int sessionId,
  ) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/pegepay/iframe-wrapper').replace(
      queryParameters: {'iframe_url': iframeUrl},
    );
    print('[PegePay] Windows wrapper fetch: ${uri.origin}${uri.path}');
    final response = await http.get(
      uri,
      headers: ApiHmacHelper.createHeaders(
        method: 'GET',
        uri: uri,
        body: '',
        accept: 'text/html',
      ),
    ).timeout(const Duration(seconds: 20));
    print('[PegePay] Windows wrapper HTTP ${response.statusCode}');
    if (response.statusCode != 200 || response.body.trim().isEmpty) {
      throw StateError('QR wrapper HTTP ${response.statusCode} or empty body.');
    }
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}'
      'pegepay_wrapper_${sessionId}_${DateTime.now().microsecondsSinceEpoch}.html',
    );
    await file.writeAsString(response.body, encoding: utf8, flush: true);
    return file.uri.toString();
  }

  // ============================================================
  // HANDLE CANCEL
  // ============================================================

  static Future<void> _handleCancel({
    required int sessionId,
    required FutureOr<void> Function() onCancel,
  }) async {
    if (sessionId != _activeSessionId) {
      return;
    }

    await _closeCurrentWebView(
      sessionId: sessionId,
    );

    if (sessionId != _activeSessionId) {
      return;
    }

    try {
      await onCancel();
    } catch (e) {
      print('[PegePay] onCancel callback failed: $e');
    }
  }

  // ============================================================
  // PUBLIC MANUAL CLOSE
  // ============================================================

  static Future<void> close() async {
    final sessionId = _activeSessionId;

    print(
      '[PegePay] Manual close requested '
      'for session $sessionId',
    );

    await _closeCurrentWebView(
      sessionId: sessionId,
    );
  }

  // ============================================================
  // CLOSE CURRENT QR WEBVIEW
  // ============================================================


  static Future<void> _closeCurrentWebView({
    required int sessionId,
  }) async {
    if (sessionId != _activeSessionId) return;

    // Concurrent close requests must wait for the same teardown.
    if (_closingOperation != null) {
      await _closingOperation;
      return;
    }

    final operation = _performClose(sessionId);
    _closingOperation = operation;
    try {
      await operation;
    } finally {
      if (identical(_closingOperation, operation)) {
        _closingOperation = null;
      }
    }
  }

  static Future<void> _performClose(int sessionId) async {
    _isClosing = true;
    _programmaticClosingSessionId = sessionId;
    _intentionalCloseSessions.add(sessionId);
    _statusTimer?.cancel();
    _statusTimer = null;

    final webview = _currentWebview;
    _currentWebview = null;

    try {
      if (webview != null) {
        final closeCompleted = webview.onClose;
        if (Platform.isWindows) {
          _pendingWindowsClose = closeCompleted;
          // Avoid leaving a permanently blocked retry if the native
          // plugin never emits onClose after close().
          unawaited(
            closeCompleted.whenComplete(() {
              if (identical(_pendingWindowsClose, closeCompleted)) {
                _pendingWindowsClose = null;
              }
            }).catchError((Object error, StackTrace trace) {
              print('[PegePay] Windows QR close notification error: $error');
            }),
          );
        }

        try {
          webview.close();
          await closeCompleted.timeout(
            Duration(seconds: Platform.isWindows ? 8 : 1),
          );
          print('[PegePay] Native QR WebView closed');
        } on TimeoutException {
          print('[PegePay] Native QR close timed out');
          if (Platform.isLinux) {
            await _forceClosePegePayWindows();
          } else {
            // The plugin may fail to complete onClose on Windows.
            // Clear the stale wait so a subsequent QR attempt can retry.
            if (identical(_pendingWindowsClose, closeCompleted)) {
              _pendingWindowsClose = null;
            }
          }
        } catch (error) {
          print('[PegePay] Native QR close error: $error');
          if (Platform.isLinux) {
            await _forceClosePegePayWindows();
          } else if (identical(_pendingWindowsClose, closeCompleted)) {
            _pendingWindowsClose = null;
          }
        }
      }

      _lastWebViewClosedAt = DateTime.now();
      await _restoreFlutterWindow(sessionId: sessionId);
    } finally {
      _isClosing = false;
      if (_programmaticClosingSessionId == sessionId) {
        _programmaticClosingSessionId = null;
      }
    }
  }

  // ============================================================
  // CLOSE PREVIOUS WEBVIEW BEFORE OPENING A NEW ONE
  // ============================================================


static Future<void> _closeOldWebView() async {
  _statusTimer?.cancel();
  _statusTimer = null;

  // Never create another Windows QR window while the
  // previous native window is still being destroyed.
  if (Platform.isWindows && _pendingWindowsClose != null) {
    print('[PegePay] Waiting for previous Windows QR to close');

    try {
      await _pendingWindowsClose!.timeout(const Duration(seconds: 8));
    } on TimeoutException {
      print('[PegePay] Clearing stale Windows close wait');
      _pendingWindowsClose = null;
    }
  }

  final oldWebview = _currentWebview;

  if (oldWebview == null) {
    return;
  }

  _isClosing = true;

  try {
    print('[PegePay] Closing previous QR WebView');

    final closeCompleted = oldWebview.onClose;

    if (Platform.isWindows) {
      _pendingWindowsClose = closeCompleted;

      unawaited(
        closeCompleted.whenComplete(() {
          if (identical(_pendingWindowsClose, closeCompleted)) {
            _pendingWindowsClose = null;
          }
        }).catchError((Object error, StackTrace trace) {
          print('[PegePay] Previous Windows QR close notification error: $error');
        }),
      );
    }

    oldWebview.close();

    await closeCompleted.timeout(
      Duration(
        seconds: Platform.isWindows ? 10 : 5,
      ),
    );

    print('[PegePay] Previous QR WebView closed');

    if (identical(_currentWebview, oldWebview)) {
      _currentWebview = null;
    }

    _lastWebViewClosedAt = DateTime.now();
  } on TimeoutException {
    print('[PegePay] Previous WebView close timed out');

    if (Platform.isLinux) {
      await _forceClosePegePayWindows();

      if (identical(_currentWebview, oldWebview)) {
        _currentWebview = null;
      }

      _lastWebViewClosedAt = DateTime.now();
    } else {
      // The Windows plugin may not complete onClose even after close().
      // Release the stale handle to allow the next QR attempt.
      if (identical(_currentWebview, oldWebview)) {
        _currentWebview = null;
      }
      _pendingWindowsClose = null;
      _lastWebViewClosedAt = DateTime.now();
    }
  } catch (e) {
    print('[PegePay] Failed to close previous WebView: $e');

    if (Platform.isWindows) {
      rethrow;
    }
  } finally {
    _isClosing = false;
  }
}


  // ============================================================
  // WAIT FOR WEBKIT/GTK TO FINISH NATIVE WINDOW TEARDOWN
  // ============================================================

  static Future<void> _waitForWebViewCooldown() async {
    final lastClosed = _lastWebViewClosedAt;

    if (lastClosed == null) {
      return;
    }

    final elapsed = DateTime.now().difference(lastClosed);
    final remaining = _webViewCooldown - elapsed;

    if (remaining > Duration.zero) {
      print(
        '[PegePay] Waiting ${remaining.inMilliseconds}ms '
        'for WebKit teardown',
      );

      await Future<void>.delayed(remaining);
    }
  }

  // ============================================================
  // MAKE LINUX WEBVIEW FULLSCREEN
  // ============================================================

  static Future<void> _makeWebViewFullscreen({
    required int sessionId,
    FutureOr<void> Function()? onQrWindowOpened,
  }) async {
    /*
     * Retry for approximately eight seconds because:
     * - the native window may appear late
     * - the title may change after HTML loads
     */
    for (int attempt = 1; attempt <= 40; attempt++) {
      if (sessionId != _activeSessionId || _isClosing) {
        return;
      }

      try {
        final result = await Process.run(
          'bash',
          [
            '-c',
            r'''
export DISPLAY=:0
export XAUTHORITY=/home/orin_nano/.Xauthority

# The initial native title is "PegePayQR".
WIN_ID=$(xdotool search --name "^PegePayQR$" 2>/dev/null | tail -n 1)

# After the HTML page loads, the title can change to this.
if [ -z "$WIN_ID" ]; then
  WIN_ID=$(xdotool search --name "PegePay QR Payment" 2>/dev/null | tail -n 1)
fi

# Fallback: find either title from wmctrl.
if [ -z "$WIN_ID" ]; then
  WIN_ID=$(wmctrl -l 2>/dev/null \
    | grep -E "PegePayQR|PegePay QR Payment" \
    | tail -n 1 \
    | awk '{print $1}')
fi

if [ -n "$WIN_ID" ]; then
  # Remove native border/title decoration.
  xprop -id "$WIN_ID" \
    -f _MOTIF_WM_HINTS 32c \
    -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0" \
    2>/dev/null

  # Remove previous states first.
  wmctrl -ir "$WIN_ID" \
    -b remove,maximized_vert,maximized_horz \
    2>/dev/null

  # Move it to the top-left before fullscreen.
  xdotool windowmove "$WIN_ID" 0 0 2>/dev/null

  # Apply real Linux fullscreen.
  wmctrl -ir "$WIN_ID" \
    -b add,fullscreen \
    2>/dev/null

  # Activate and raise it above the Flutter window.
  wmctrl -ia "$WIN_ID" 2>/dev/null
  xdotool windowactivate --sync "$WIN_ID" 2>/dev/null
  xdotool windowraise "$WIN_ID" 2>/dev/null

  echo "FOUND:$WIN_ID"
else
  echo "NOT_FOUND"
fi
''',
          ],
        );

        final output = result.stdout.toString().trim();

        if (output.startsWith('FOUND:')) {
          print(
            '[PegePay] Linux WebView fullscreen enabled: '
            '$output',
          );

          /*
           * Apply fullscreen again after a short delay because
           * some Linux window managers replace the state when the
           * web page title changes.
           */
          await Future.delayed(
            const Duration(milliseconds: 500),
          );

          if (sessionId != _activeSessionId || _isClosing) {
            return;
          }

          await _reapplyFullscreen();

          if (sessionId != _activeSessionId || _isClosing) {
            return;
          }

          if (onQrWindowOpened != null) {
            try {
              await onQrWindowOpened();
              print('[PegePay] QR window visible - opening overlay closed');
            } catch (e) {
              print('[PegePay] onQrWindowOpened callback failed: $e');
            }
          }

          return;
        }

        if (attempt == 1 || attempt % 5 == 0) {
          print(
            '[PegePay] Waiting for Linux QR window '
            '(attempt $attempt)',
          );
        }
      } catch (e) {
        print(
          '[PegePay] Fullscreen attempt $attempt failed: $e',
        );
      }

      await Future.delayed(
        const Duration(milliseconds: 200),
      );
    }

    print(
      '[PegePay] QR window was not found for fullscreen. '
      'Check xdotool, wmctrl, DISPLAY and XAUTHORITY.',
    );
  }

  // ============================================================
  // REAPPLY FULLSCREEN AFTER PAGE TITLE CHANGES
  // ============================================================

static Future<void> _reapplyFullscreen() async {
  try {
    final result = await Process.run(
      'bash',
      [
        '-c',
        r'''
export DISPLAY=:0
export XAUTHORITY=/home/orin_nano/.Xauthority

WIN_ID=$(xdotool search --name "PegePay QR Payment" 2>/dev/null | tail -n 1)

if [ -z "$WIN_ID" ]; then
  WIN_ID=$(xdotool search --name "PegePayQR" 2>/dev/null | tail -n 1)
fi

if [ -n "$WIN_ID" ]; then
  # Get the actual screen resolution, for example 800x1280.
  SCREEN_SIZE=$(xrandr \
    | grep ' connected primary' \
    | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+' \
    | head -n 1 \
    | cut -d'+' -f1)

  if [ -z "$SCREEN_SIZE" ]; then
    SCREEN_SIZE=$(xrandr \
      | grep '\*' \
      | head -n 1 \
      | awk '{print $1}')
  fi

  SCREEN_WIDTH=$(echo "$SCREEN_SIZE" | cut -d'x' -f1)
  SCREEN_HEIGHT=$(echo "$SCREEN_SIZE" | cut -d'x' -f2)

  # Remove the Linux title bar and window border.
  xprop -id "$WIN_ID" \
    -f _MOTIF_WM_HINTS 32c \
    -set _MOTIF_WM_HINTS "2, 0, 0, 0, 0"

  # Clear existing window states first.
  wmctrl -ir "$WIN_ID" \
    -b remove,fullscreen,maximized_vert,maximized_horz

  sleep 0.2

  # Force the WebView to cover the complete physical screen.
  xdotool windowmove "$WIN_ID" 0 0
  xdotool windowsize "$WIN_ID" "$SCREEN_WIDTH" "$SCREEN_HEIGHT"

  # Apply fullscreen again.
  wmctrl -ir "$WIN_ID" -b add,fullscreen
  wmctrl -ir "$WIN_ID" -b add,above

  xdotool windowactivate --sync "$WIN_ID"
  xdotool windowraise "$WIN_ID"

  echo "Fullscreen applied: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
fi
''',
      ],
    );

    print(
      '[PegePay] ${result.stdout.toString().trim()}',
    );
  } catch (e) {
    print('[PegePay] Fullscreen reapply failed: $e');
  }
}

  // ============================================================
  // FORCE-CLOSE LEFTOVER QR WINDOWS
  // ============================================================

  static Future<void> _forceClosePegePayWindows() async {
    try {
      await Process.run(
        'bash',
        [
          '-c',
          r'''
export DISPLAY=:0
export XAUTHORITY=/home/orin_nano/.Xauthority

{
  xdotool search --name "PegePayQR" 2>/dev/null
  xdotool search --name "PegePay QR Payment" 2>/dev/null
} | sort -u | while read -r WIN_ID; do
  if [ -n "$WIN_ID" ]; then
    wmctrl -ir "$WIN_ID" -b remove,fullscreen 2>/dev/null
    xdotool windowclose "$WIN_ID" 2>/dev/null
  fi
done
''',
        ],
      );

      print('[PegePay] Leftover QR windows cleaned');
    } catch (e) {
      print(
        '[PegePay] Failed to clean leftover windows: $e',
      );
    }
  }

  // ============================================================
  // RESTORE MAIN FLUTTER WINDOW
  // ============================================================

  static Future<void> _restoreFlutterWindow({
    required int sessionId,
  }) async {
    if (_restoredSessionId == sessionId) {
      print(
        '[PegePay] Flutter window already restored '
        'for session $sessionId',
      );
      return;
    }

    _restoredSessionId = sessionId;

    try {
      await Future<void>.delayed(
        const Duration(milliseconds: 200),
      );

      currentRouteName = '/payment';

      // Re-enable the kiosk guard and restore the main Flutter
      // window only after the PegePay QR window has closed.
      if (Platform.isLinux) {
        await LinuxKioskService.restoreFlutterWindow();
      } else if (Platform.isWindows) {
        await windowManager.show();
        await windowManager.focus();
      }

      print('[PegePay] Flutter window restored');
    } catch (e) {
      print(
        '[PegePay] Failed to restore Flutter window: $e',
      );
    }
  }
}
