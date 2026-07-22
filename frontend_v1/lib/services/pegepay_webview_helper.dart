import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/services/pegepay_service.dart';
import 'package:window_manager/window_manager.dart';

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

  // ============================================================
  // OPEN PEGEpay QR WEBVIEW
  // ============================================================

  static Future<void> open({
    required String iframeUrl,
    required String orderNo,
    required Function(Map<String, dynamic>) onSuccess,
    required Function onCancel,
  }) async {
    print('[PegePay] Opening QR for order: $orderNo');

    // ============================================================
    // PREPARE FLUTTER WINDOW FOR EXTERNAL QR WINDOW
    // ============================================================
    //
    // Do not hide the Flutter window here.
    //
    // Hiding Flutter before the native QR WebView is ready causes
    // the Linux desktop/background to flash briefly.
    //
    // Instead:
    // 1. Pause the kiosk fullscreen guard.
    // 2. Remove Flutter's always-on-top state.
    // 3. Keep Flutter visible behind the QR WebView.
    // 4. Raise the QR WebView after it has been created.

    isExternalPaymentWindowOpen = true;
    currentRouteName = '/payment';

    try {
      await windowManager.setAlwaysOnTop(false);

      // Keep Flutter visible as the background while the QR native
      // window is being created. This prevents desktop flashing.
      await windowManager.show();

      print(
        '[PegePay] Flutter kept visible behind QR window',
      );
    } catch (e) {
      print(
        '[PegePay] Failed to prepare Flutter window: $e',
      );
    }

    /*
     * Invalidate every callback belonging to the previous WebView
     * before closing that previous window.
     */
    final int sessionId = ++_activeSessionId;

    await _closeOldWebView();

    /*
     * Another open() might have started while cleanup was running.
     */
    if (sessionId != _activeSessionId) {
      print('[PegePay] Open request superseded by a newer session');
      return;
    }

    bool finished = false;
    bool cancelCallbackCalled = false;

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

      // Creation failed, so immediately release the kiosk guard pause.
      isExternalPaymentWindowOpen = false;

      if (sessionId == _activeSessionId) {
        finished = true;
        await _restoreFlutterWindow();

        if (!cancelCallbackCalled) {
          cancelCallbackCalled = true;
          onCancel();
        }
      }

      return;
    }

    // ==========================================================
    // WEBVIEW WINDOW CLOSED
    // ==========================================================

    webview.onClose.whenComplete(() async {
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

      await _restoreFlutterWindow();

      /*
       * Flutter intentionally closed this window because:
       * - Cancel was pressed
       * - payment succeeded
       * - close() was called
       */
      if (_programmaticClosingSessionId == sessionId || finished) {
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
          onCancel();
        } catch (e) {
          print(
            '[PegePay] onCancel failed after X close: $e',
          );
        }
      }
    });

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
          onCancel: () {
            if (cancelCallbackCalled) {
              return;
            }

            cancelCallbackCalled = true;
            onCancel();
          },
        ),
      );
    });

    // ==========================================================
    // WRAPPER URL
    // ==========================================================

    final wrapperUrl = Uri.parse(
      '${Config.baseUrl}/pegepay/iframe-wrapper',
    ).replace(
      queryParameters: {
        'iframe_url': iframeUrl,
      },
    ).toString();

    // ==========================================================
    // LAUNCH WEBVIEW
    // ==========================================================

    try {
      webview.launch(wrapperUrl);
    } catch (e) {
      print('[PegePay] Failed to launch WebView: $e');

      if (sessionId == _activeSessionId && !finished) {
        finished = true;

        await _closeCurrentWebView(
          sessionId: sessionId,
        );

        await _restoreFlutterWindow();

        if (!cancelCallbackCalled) {
          cancelCallbackCalled = true;
          onCancel();
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
    unawaited(
      _makeWebViewFullscreen(
        sessionId: sessionId,
      ),
    );

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
          final paid = await PegePayService.checkStatus(
            orderNo,
          );

          if (sessionId != _activeSessionId || finished) {
            return;
          }

          if (!paid) {
            return;
          }

          print(
            '[PegePay] Payment successful for $orderNo',
          );

          finished = true;

          timer.cancel();
          _statusTimer = null;

          final paymentResult =
              await PegePayService.checkStatusDetails(
            orderNo,
          );

          if (sessionId != _activeSessionId) {
            return;
          }

          /*
           * Close only the QR WebView.
           */
          await _closeCurrentWebView(
            sessionId: sessionId,
          );

          await _restoreFlutterWindow();

          try {
            onSuccess(paymentResult);
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

  // ============================================================
  // HANDLE CANCEL
  // ============================================================

  static Future<void> _handleCancel({
    required int sessionId,
    required void Function() onCancel,
  }) async {
    if (sessionId != _activeSessionId) {
      return;
    }

    await _closeCurrentWebView(
      sessionId: sessionId,
    );

    await _restoreFlutterWindow();

    if (sessionId != _activeSessionId) {
      return;
    }

    try {
      onCancel();
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

    await _restoreFlutterWindow();
  }

  // ============================================================
  // CLOSE CURRENT QR WEBVIEW
  // ============================================================

  static Future<void> _closeCurrentWebView({
    required int sessionId,
  }) async {
    if (sessionId != _activeSessionId) {
      print('[PegePay] Refusing to close an old session');
      return;
    }

    if (_isClosing) {
      return;
    }

    _isClosing = true;
    _programmaticClosingSessionId = sessionId;

    _statusTimer?.cancel();
    _statusTimer = null;

    final webview = _currentWebview;
    _currentWebview = null;

    if (webview != null) {
      try {
        print(
          '[PegePay] Calling webview.close() '
          'for session $sessionId',
        );

        /*
         * This closes only the separate QR WebView window.
         * It does not close the Flutter application.
         */
        webview.close();
      } catch (e) {
        print('[PegePay] webview.close() failed: $e');
      }
    }

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    /*
     * Remove any Linux QR window that failed to close normally.
     */
    await _forceClosePegePayWindows();

    _isClosing = false;

    /*
     * Keep the programmatic-close marker briefly because onClose
     * may be delivered slightly later.
     */
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (_programmaticClosingSessionId == sessionId) {
      _programmaticClosingSessionId = null;
    }
  }

  // ============================================================
  // CLOSE PREVIOUS WEBVIEW BEFORE OPENING A NEW ONE
  // ============================================================

  static Future<void> _closeOldWebView() async {
    _statusTimer?.cancel();
    _statusTimer = null;

    final oldWebview = _currentWebview;
    _currentWebview = null;

    if (oldWebview != null) {
      try {
        print('[PegePay] Closing previous QR WebView');
        oldWebview.close();
      } catch (e) {
        print(
          '[PegePay] Failed to close previous WebView: $e',
        );
      }

      await Future.delayed(
        const Duration(milliseconds: 400),
      );
    }

    await _forceClosePegePayWindows();
  }

  // ============================================================
  // MAKE LINUX WEBVIEW FULLSCREEN
  // ============================================================

  static Future<void> _makeWebViewFullscreen({
    required int sessionId,
  }) async {
    /*
     * Retry for approximately eight seconds because:
     * - the native window may appear late
     * - the title may change after HTML loads
     */
    for (int attempt = 1; attempt <= 40; attempt++) {
      if (sessionId != _activeSessionId) {
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
            const Duration(milliseconds: 1000),
          );

          if (sessionId == _activeSessionId) {
            await _reapplyFullscreen();
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

  static Future<void> _restoreFlutterWindow() async {
    try {
      // The native QR window is now closed. Allow the main.dart kiosk
      // guard to protect the Flutter window again.
      isExternalPaymentWindowOpen = false;
      currentRouteName = '/payment';

      await Future.delayed(
        const Duration(milliseconds: 250),
      );

      // Restore the main kiosk window only after the QR WebView closes.
      await windowManager.show();

      final bool minimized = await windowManager.isMinimized();
      if (minimized) {
        await windowManager.restore();
      }

      await windowManager.setFullScreen(true);

      // Raise Flutter once after payment closes, then remove always-on-top
      // so a future PegePay WebView can appear above it normally.
      await windowManager.setAlwaysOnTop(true);
      await windowManager.focus();

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      await windowManager.setAlwaysOnTop(false);
      await windowManager.focus();

      print('[PegePay] Flutter window restored');
    } catch (e) {
      // Never leave the kiosk guard permanently paused, even when a
      // Linux window-manager command fails.
      isExternalPaymentWindowOpen = false;

      print(
        '[PegePay] Failed to restore Flutter window: $e',
      );
    }
  }
}



// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
// import 'package:desktop_webview_window/desktop_webview_window.dart';
// import 'package:frontend_v1/main.dart';
// import 'package:frontend_v1/services/pegepay_service.dart';
// import 'package:frontend_v1/pages/config.dart';
// import 'package:window_manager/window_manager.dart';

// class PegePayWebViewHelper {
//   static Webview? _currentWebview;

// static Future<void> _removeWebViewDecoration() async {
//   await Future.delayed(const Duration(milliseconds: 50));

//   try {
//     await Process.run('bash', [
//       '-c',
//       '''
//       export DISPLAY=:0
//       export XAUTHORITY=/home/orin_nano/.Xauthority

//       WIN_ID=\$(xdotool search --name "PegePayQR" | tail -n 1)

//       if [ ! -z "\$WIN_ID" ]; then
//         xprop -id \$WIN_ID -f _MOTIF_WM_HINTS 32c \
//         -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"

//         wmctrl -ir \$WIN_ID -b add,fullscreen
//       fi
//       '''
//     ]);
//   } catch (e) {
//     print("Failed to remove WebView decoration: $e");
//   }
// }

// static Future<void> _cleanupOldWebViews() async {
//   try {
//     await Process.run('bash', [
//       '-c',
//       '''
//       export DISPLAY=:0
//       export XAUTHORITY=/home/orin_nano/.Xauthority

//       for WIN_ID in \$(xdotool search --name "PegePayQR" 2>/dev/null); do
//         wmctrl -ir \$WIN_ID -b remove,fullscreen
//         xdotool windowkill \$WIN_ID
//       done
//       '''
//     ]);
//   } catch (e) {
//     print("Failed to cleanup old WebViews: $e");
//   }
// }


//   static Future<void> open({
//     required String iframeUrl,
//     required String orderNo,
//     required Function(Map<String, dynamic>) onSuccess,
//     required Function onCancel,
//   }) async {
//     if (_currentWebview != null) {
//       try {
//         _currentWebview!.close();
//       } catch (_) {}
//       _currentWebview = null;
//     }

//     final screenSize = await windowManager.getSize();

//    // await _cleanupOldWebViews();

//     final webview = await WebviewWindow.create(
//       configuration: const CreateConfiguration(
//         title: "PegePayQR",
//         windowWidth: 800,
//         windowHeight: 1320,
//         windowPosX: 0,
//         windowPosY: -40,
//         useWindowPositionAndSize: true,
//         openMaximized: false,
//       ),
//     );

//     _currentWebview = webview;
//     Future.delayed(const Duration(milliseconds: 500), () {
//   _removeWebViewDecoration();
//     });

//     bool completed = false;

//     webview.onClose.whenComplete(() {
//       print("WEBVIEW CLOSED BY X");

//       currentRouteName = '/payment';

//       completed = true;
//       _currentWebview = null;

//       // Future.delayed(const Duration(milliseconds: 300), () {
//       //   onCancel();
//       // });
//     });

//     // webview.addOnUrlRequestCallback((url) {
//     //   if (url.startsWith("app://cancelPayment")) {
//     //     if (!completed) {
//     //       completed = true;
//     //       _currentWebview?.close();
//     //       _currentWebview = null;
//     //       onCancel();
//     //     }
//     //   }
//     // });

// webview.addOnUrlRequestCallback((url) {
//   if (url.startsWith("app://cancelPayment")) {
//     if (!completed) {
//       completed = true;

//       _currentWebview = null;

//       Future.delayed(const Duration(milliseconds: 300), ()async  {
//         await windowManager.show();
//         await windowManager.focus();
//         await windowManager.setFullScreen(true);
//         onCancel();
//       });
//     }
//   }
// });

//     Timer.periodic(const Duration(seconds: 2), (timer) async {
//       if (completed) {
//         timer.cancel();
//         return;
//       }

//       try {
//         final paid = await PegePayService.checkStatus(orderNo);

//         if (paid) {
//           completed = true;
//           timer.cancel();

//           final paymentResult =
//               await PegePayService.checkStatusDetails(orderNo);

//           // _currentWebview?.close();

//           _currentWebview = null;


//           await windowManager.show();
//           await windowManager.focus();
//           await windowManager.setFullScreen(true);


//           onSuccess(paymentResult);
//         }
//       } catch (_) {}
//     });

//     webview.launch(
//       "${Config.baseUrl}/pegepay/iframe-wrapper?iframe_url=${Uri.encodeComponent(iframeUrl)}",
//     );
//   }
  
// }


