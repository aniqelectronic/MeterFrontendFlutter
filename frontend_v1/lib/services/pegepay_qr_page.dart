import 'dart:async';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/services/pegepay_service.dart';

class PegePayQRPageDesktopWebView extends StatefulWidget {
  final String iframeUrl;
  final String orderNo;
  final VoidCallback onSuccess;

  const PegePayQRPageDesktopWebView({
    super.key,
    required this.iframeUrl,
    required this.orderNo,
    required this.onSuccess,
  });

  @override
  State<PegePayQRPageDesktopWebView> createState() =>
      _PegePayQRPageDesktopWebViewState();
}

class _PegePayQRPageDesktopWebViewState
    extends State<PegePayQRPageDesktopWebView> {
  Webview? _webview;
  Timer? _timer;

  bool _completed = false;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();

    _openWebView();
    _startPolling();
  }

  // ============================================================
  // OPEN WEBVIEW
  // ============================================================

  Future<void> _openWebView() async {
    try {
      _webview = await WebviewWindow.create(
        configuration: const CreateConfiguration(
          title: "",
          windowWidth: 1080,
          windowHeight: 1920,
          windowPosX: 0,
          windowPosY: 0,
          useWindowPositionAndSize: true,
          openMaximized: false,
        ),
      );

      if (!mounted || _completed) {
        try {
          _webview?.close();
        } catch (_) {}

        return;
      }

      _webview?.addOnUrlRequestCallback((url) {
        if (url.startsWith("app://cancelPayment")) {
          _cancelPayment();
        }
      });

      _webview?.setOnHistoryChangedCallback(
        (canBack, canForward) {
          if (!mounted) return;

          setState(() {
            _canGoBack = canBack;
          });
        },
      );

      final wrapperUrl = Uri.parse(
        "${Config.apiPublicBaseUrl}/pegepay/iframe-wrapper",
      ).replace(
        queryParameters: {
          "iframe_url": widget.iframeUrl,
        },
      );

      _webview?.launch(
        wrapperUrl.toString(),
      );
    } catch (e) {
      debugPrint(
        "Unable to open PegePay WebView: $e",
      );

      _cancelPayment();
    }
  }

  // ============================================================
  // PAYMENT STATUS POLLING
  // ============================================================

  void _startPolling() {
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        if (!mounted || _completed) {
          return;
        }

        try {
          final paid = await PegePayService.checkStatus(
            widget.orderNo,
          );

          if (paid) {
            _completePayment();
          }
        } catch (e) {
          debugPrint(
            "PegePay polling error: $e",
          );
        }
      },
    );
  }

  // ============================================================
  // PAYMENT SUCCESS
  // ============================================================

  void _completePayment() {
    if (_completed) return;

    _completed = true;
    _cleanup();

    try {
      _webview?.close();
    } catch (_) {}

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    widget.onSuccess();
  }

  // ============================================================
  // BACK / CANCEL
  // ============================================================

  Future<void> _onBackPressed() async {
    if (_completed) return;

    if (_canGoBack) {
      await _webview?.back();
      return;
    }

    _cancelPayment();
  }

  void _cancelPayment() {
    if (_completed) return;

    _completed = true;
    _cleanup();

    try {
      _webview?.close();
    } catch (_) {}

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _cleanup() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cleanup();

    try {
      _webview?.close();
    } catch (_) {}

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Scan QR Code to Complete Payment",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Please complete the payment using your banking app.",
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 60,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canGoBack ? Colors.orange : Colors.red,
                  minimumSize: const Size(
                    double.infinity,
                    90,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                onPressed: _onBackPressed,
                child: Text(
                  _canGoBack
                      ? "BACK"
                      : "BATAL / CANCEL",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}