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

  static bool _completed = false;
  static bool _isClosing = false;

  // True when Flutter closes the WebView itself.
  // Prevents onClose from calling onCancel again.
  static bool _programmaticClose = false;

  // ============================================================
  // OPEN PEGEpay QR WEBVIEW
  // ============================================================

  static Future<void> open({
    required String iframeUrl,
    required String orderNo,
    required Function(Map<String, dynamic>) onSuccess,
    required Function onCancel,
  }) async {
    print('[PegePay] Opening QR WebView for order: $orderNo');

    // Close an old QR window before opening another one.
    await _closeOldWebView();

    _completed = false;
    _isClosing = false;
    _programmaticClose = false;

    late final Webview webview;

    try {
      webview = await WebviewWindow.create(
        configuration: const CreateConfiguration(
          title: 'PegePayQR',

          // These are only initial values.
          // Linux wmctrl will make it fullscreen afterward.
          windowWidth: 800,
          windowHeight: 1320,
          windowPosX: 0,
          windowPosY: 0,

          useWindowPositionAndSize: true,
          openMaximized: false,
        ),
      );

      _currentWebview = webview;
    } catch (e) {
      print('[PegePay] Failed to create WebView: $e');

      await _restoreFlutterWindow();

      if (!_completed) {
        _completed = true;
        onCancel();
      }

      return;
    }

    // ==========================================================
    // USER PRESSES X ON THE WEBVIEW WINDOW
    // ==========================================================

    webview.onClose.whenComplete(() async {
      print('[PegePay] WebView onClose triggered');

      _statusTimer?.cancel();
      _statusTimer = null;

      if (identical(_currentWebview, webview)) {
        _currentWebview = null;
      }

      await _restoreFlutterWindow();

      // The WebView was closed because:
      // - payment succeeded
      // - Cancel button was pressed
      // - close() was called manually
      //
      // Do not call onCancel again.
      if (_programmaticClose || _completed) {
        print('[PegePay] Programmatic WebView close completed');
        return;
      }

      // The user manually pressed the Linux X button.
      print('[PegePay] User pressed WebView X');

      _completed = true;

      try {
        onCancel();
      } catch (e) {
        print('[PegePay] onCancel error after X close: $e');
      }
    });

    // ==========================================================
    // CANCEL/BACK BUTTON FROM THE HTML WRAPPER
    // ==========================================================

    webview.addOnUrlRequestCallback((url) {
      print('[PegePay] URL request: $url');

      if (!url.startsWith('app://cancelPayment')) {
        return;
      }

      if (_completed || _isClosing) {
        return;
      }

      print('[PegePay] Cancel requested from wrapper page');

      _completed = true;

      unawaited(
        _cancelPayment(
          onCancel: onCancel,
        ),
      );
    });

    // ==========================================================
    // BUILD WRAPPER URL
    // ==========================================================

    final wrapperUrl = Uri.parse(
      '${Config.baseUrl}/pegepay/iframe-wrapper',
    ).replace(
      queryParameters: {
        'iframe_url': iframeUrl,

        // Prevent reuse of the old wrapper page.
        'timestamp':
            DateTime.now().millisecondsSinceEpoch.toString(),
      },
    ).toString();

    // ==========================================================
    // LAUNCH WEBVIEW
    // ==========================================================

    try {
      webview.launch(wrapperUrl);
    } catch (e) {
      print('[PegePay] Failed to launch wrapper URL: $e');

      if (!_completed) {
        _completed = true;

        await _closeCurrentWebView();
        await _restoreFlutterWindow();

        onCancel();
      }

      return;
    }

    // Fullscreen after Linux creates the actual window.
    unawaited(_makeWebViewFullscreen());

    // ==========================================================
    // CHECK PAYMENT STATUS EVERY 2 SECONDS
    // ==========================================================

    _statusTimer?.cancel();

    _statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        if (_completed) {
          timer.cancel();
          return;
        }

        try {
          final paid = await PegePayService.checkStatus(
            orderNo,
          );

          if (!paid || _completed) {
            return;
          }

          print(
            '[PegePay] Payment successful for order: $orderNo',
          );

          _completed = true;

          timer.cancel();
          _statusTimer = null;

          final paymentResult =
              await PegePayService.checkStatusDetails(
            orderNo,
          );

          // Close the QR window before displaying success UI.
          await _closeCurrentWebView();

          // Bring the main Flutter application forward.
          await _restoreFlutterWindow();

          try {
            onSuccess(paymentResult);
          } catch (e) {
            print('[PegePay] onSuccess callback error: $e');
          }
        } catch (e) {
          // Do not close the QR screen because of one temporary
          // status-check error.
          print('[PegePay] Status check error: $e');
        }
      },
    );
  }

  // ============================================================
  // CANCEL PAYMENT FROM WRAPPER BUTTON
  // ============================================================

  static Future<void> _cancelPayment({
    required Function onCancel,
  }) async {
    await _closeCurrentWebView();
    await _restoreFlutterWindow();

    try {
      onCancel();
    } catch (e) {
      print('[PegePay] onCancel callback error: $e');
    }
  }

  // ============================================================
  // PUBLIC MANUAL CLOSE
  // ============================================================

  static Future<void> close() async {
    print('[PegePay] Manual close requested');

    _completed = true;

    await _closeCurrentWebView();
    await _restoreFlutterWindow();
  }

  // ============================================================
  // CLOSE CURRENT WEBVIEW
  // ============================================================

  static Future<void> _closeCurrentWebView() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;
    _programmaticClose = true;

    _statusTimer?.cancel();
    _statusTimer = null;

    final webview = _currentWebview;
    _currentWebview = null;

    if (webview != null) {
      try {
        print('[PegePay] Calling webview.close()');

        // This closes only the separate QR WebView window.
        // It does not close the main Flutter application.
        webview.close();
      } catch (e) {
        print('[PegePay] webview.close() failed: $e');
      }
    }

    // Give desktop_webview_window time to close normally.
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    // Remove any window that did not close properly.
    await _forceClosePegePayWindows();

    _isClosing = false;
  }

  // ============================================================
  // CLOSE ANY PREVIOUS WEBVIEW
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
        const Duration(milliseconds: 300),
      );
    }

    await _forceClosePegePayWindows();
  }

  // ============================================================
  // MAKE WEBVIEW FULLSCREEN
  // ============================================================

  static Future<void> _makeWebViewFullscreen() async {
    // Retry because the Linux window may not exist immediately
    // after webview.launch().
    for (int attempt = 1; attempt <= 15; attempt++) {
      try {
        final result = await Process.run(
          'bash',
          [
            '-c',
            '''
export DISPLAY=:0
export XAUTHORITY=/home/orin_nano/.Xauthority

WIN_ID=\$(xdotool search --name "PegePayQR" 2>/dev/null | tail -n 1)

if [ -n "\$WIN_ID" ]; then
  xprop -id "\$WIN_ID" \
    -f _MOTIF_WM_HINTS 32c \
    -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"

  wmctrl -ir "\$WIN_ID" \
    -b remove,maximized_vert,maximized_horz

  wmctrl -ir "\$WIN_ID" \
    -b add,fullscreen

  xdotool windowactivate --sync "\$WIN_ID"
  xdotool windowraise "\$WIN_ID"

  echo "FOUND"
else
  echo "NOT_FOUND"
fi
''',
          ],
        );

        final output = result.stdout.toString();

        if (output.contains('FOUND')) {
          print(
            '[PegePay] WebView fullscreen enabled',
          );
          return;
        }
      } catch (e) {
        print(
          '[PegePay] Fullscreen attempt '
          '$attempt failed: $e',
        );
      }

      await Future.delayed(
        const Duration(milliseconds: 200),
      );
    }

    print(
      '[PegePay] Unable to find QR window for fullscreen',
    );
  }

  // ============================================================
  // FORCE CLOSE LEFTOVER PEGEpay WINDOWS
  // ============================================================

  static Future<void> _forceClosePegePayWindows() async {
    try {
      await Process.run(
        'bash',
        [
          '-c',
          '''
export DISPLAY=:0
export XAUTHORITY=/home/orin_nano/.Xauthority

for WIN_ID in \$(xdotool search --name "PegePayQR" 2>/dev/null); do
  wmctrl -ir "\$WIN_ID" \
    -b remove,fullscreen 2>/dev/null

  xdotool windowkill "\$WIN_ID" 2>/dev/null
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
  // RESTORE MAIN FLUTTER KIOSK WINDOW
  // ============================================================

  static Future<void> _restoreFlutterWindow() async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 200),
      );

      await windowManager.show();

      // Ensure the main application is fullscreen again.
      await windowManager.setFullScreen(true);

      // Temporarily bring it above the WebView.
      await windowManager.setAlwaysOnTop(true);
      await windowManager.focus();

      await Future.delayed(
        const Duration(milliseconds: 250),
      );

      await windowManager.focus();

      // Return to normal after focus is restored.
      await windowManager.setAlwaysOnTop(false);

      currentRouteName = '/payment';

      print('[PegePay] Main Flutter window restored');
    } catch (e) {
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


