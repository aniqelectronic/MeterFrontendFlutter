import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/services/pegepay_service.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:window_manager/window_manager.dart';

class PegePayWebViewHelper {
  static Webview? _currentWebview;

static Future<void> _removeWebViewDecoration() async {
  await Future.delayed(const Duration(milliseconds: 700));

  try {
    await Process.run('bash', [
      '-c',
      '''
      export DISPLAY=:0
      export XAUTHORITY=/home/orin_nano/.Xauthority

      WIN_ID=\$(xdotool search --name "PegePayQR" | tail -n 1)

      if [ ! -z "\$WIN_ID" ]; then
        xprop -id \$WIN_ID -f _MOTIF_WM_HINTS 32c \
        -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"

        wmctrl -ir \$WIN_ID -b add,fullscreen
      fi
      '''
    ]);
  } catch (e) {
    print("Failed to remove WebView decoration: $e");
  }
}

static Future<void> _cleanupOldWebViews() async {
  try {
    await Process.run('bash', [
      '-c',
      '''
      export DISPLAY=:0
      export XAUTHORITY=/home/orin_nano/.Xauthority

      for WIN_ID in \$(xdotool search --name "PegePayQR" 2>/dev/null); do
        wmctrl -ir \$WIN_ID -b remove,fullscreen
        xdotool windowkill \$WIN_ID
      done
      '''
    ]);
  } catch (e) {
    print("Failed to cleanup old WebViews: $e");
  }
}


  static Future<void> open({
    required String iframeUrl,
    required String orderNo,
    required Function(Map<String, dynamic>) onSuccess,
    required Function onCancel,
  }) async {
    if (_currentWebview != null) {
      // try {
      //   _currentWebview!.close();
      // } catch (_) {}
      _currentWebview = null;
    }

    final screenSize = await windowManager.getSize();

    await _cleanupOldWebViews();

    final webview = await WebviewWindow.create(
      configuration: const CreateConfiguration(
        title: "PegePayQR",
        windowWidth: 800,
        windowHeight: 1320,
        windowPosX: 0,
        windowPosY: -40,
        useWindowPositionAndSize: true,
        openMaximized: false,
      ),
    );

    _currentWebview = webview;
    Future.delayed(const Duration(milliseconds: 500), () {
  _removeWebViewDecoration();
    });

    bool completed = false;

    webview.onClose.whenComplete(() {
      print("WEBVIEW CLOSED BY X");

      currentRouteName = '/payment';

      completed = true;
      _currentWebview = null;

      // Future.delayed(const Duration(milliseconds: 300), () {
      //   onCancel();
      // });
    });

    // webview.addOnUrlRequestCallback((url) {
    //   if (url.startsWith("app://cancelPayment")) {
    //     if (!completed) {
    //       completed = true;
    //       _currentWebview?.close();
    //       _currentWebview = null;
    //       onCancel();
    //     }
    //   }
    // });

webview.addOnUrlRequestCallback((url) {
  if (url.startsWith("app://cancelPayment")) {
    if (!completed) {
      completed = true;

      _currentWebview = null;

      Future.delayed(const Duration(milliseconds: 300), ()async  {
        await _cleanupOldWebViews();
        onCancel();
      });
    }
  }
});

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (completed) {
        timer.cancel();
        return;
      }

      try {
        final paid = await PegePayService.checkStatus(orderNo);

        if (paid) {
          completed = true;
          timer.cancel();

          final paymentResult =
              await PegePayService.checkStatusDetails(orderNo);

          // _currentWebview?.close();

          _currentWebview = null;

           await _cleanupOldWebViews();

          await windowManager.show();
          await windowManager.focus();
          await windowManager.setFullScreen(true);


          onSuccess(paymentResult);
        }
      } catch (_) {}
    });

    webview.launch(
      "${Config.baseUrl}/pegepay/iframe-wrapper?iframe_url=${Uri.encodeComponent(iframeUrl)}",
    );
  }
  
}

