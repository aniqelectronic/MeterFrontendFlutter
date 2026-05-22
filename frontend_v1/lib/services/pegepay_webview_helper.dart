import 'dart:async';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:frontend_v1/services/pegepay_service.dart';
import 'package:frontend_v1/pages/config.dart';

class PegePayWebViewHelper {
  static Webview? _currentWebview;

  static Future<void> open({
    required String iframeUrl,
    required String orderNo,
    required Function(Map<String, dynamic>) onSuccess,
    required Function onCancel,
  }) async {
    if (_currentWebview != null) {
      try {
        _currentWebview!.close();
      } catch (_) {}
      _currentWebview = null;
    }

    final webview = await WebviewWindow.create(
      configuration: const CreateConfiguration(
        title: "",
        windowWidth: 1080,
        windowHeight: 1920,
        windowPosX: 0,
        windowPosY: 0,
        useWindowPositionAndSize: true,
        openMaximized: true,
      ),
    );

    _currentWebview = webview;

    bool completed = false;

    webview.onClose.whenComplete(() {
      if (!completed) {
        completed = true;
        _currentWebview = null;
        onCancel();
      }
    });

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

          _currentWebview?.close();
          _currentWebview = null;

          onSuccess(paymentResult);
        }
      } catch (_) {}
    });

    webview.launch(
      "${Config.baseUrl}/pegepay/iframe-wrapper?iframe_url=${Uri.encodeComponent(iframeUrl)}",
    );
  }
}