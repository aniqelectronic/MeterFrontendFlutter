import 'dart:async';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:frontend_v1/services/pegepay_service.dart';
import 'package:frontend_v1/pages/config.dart';

class PegePayWebViewHelper {

  // ✅ GLOBAL instance (only ONE webview allowed)
  static Webview? _currentWebview;

  static Future<void> open({
    required String iframeUrl,
    required String orderNo,
    required Function onSuccess,
    required Function onCancel,
  }) async {

    // ✅ STEP 1: CLOSE OLD WEBVIEW FIRST
    if (_currentWebview != null) {
      try {
        _currentWebview!.close();
      } catch (_) {}
      _currentWebview = null;
    }

    // ✅ STEP 2: CREATE NEW WEBVIEW
    final webview = await WebviewWindow.create(
      configuration: const CreateConfiguration(
        title: "",
        windowWidth: 1080,
        windowHeight: 1920,
        windowPosX: 0,
        windowPosY: 0,
        useWindowPositionAndSize: true,
        openMaximized: true, // fullscreen
      ),
    );

    // ✅ SAVE INSTANCE
    _currentWebview = webview;

    bool completed = false;

    // ✅ Detect ❌ window close
    webview.onClose.whenComplete(() {
      if (!completed) {
        completed = true;
        _currentWebview = null;
        onCancel();
      }
    });

    // ✅ Detect cancel from webpage
    webview.addOnUrlRequestCallback((url) {
      if (url.startsWith("app://cancelPayment")) {
        if (!completed) {
          completed = true;

          _currentWebview?.close();
          _currentWebview = null;

          onCancel();
        }
      }
    });

    // ✅ Poll payment status
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

          _currentWebview?.close();
          _currentWebview = null;

          onSuccess();
        }
      } catch (_) {}
    });

    // ✅ Launch QR page
    webview.launch(
      "${Config.baseUrl}/pegepay/iframe-wrapper?iframe_url=${Uri.encodeComponent(iframeUrl)}",
    );
  }
}