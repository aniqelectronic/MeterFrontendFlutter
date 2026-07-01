import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/data.dart';

class InternetGuard {
  static final InternetGuard _instance = InternetGuard._internal();
  factory InternetGuard() => _instance;
  InternetGuard._internal();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _timer;

  bool _offline = false;
  BuildContext? _dialogContext;

  VoidCallback? _onOffline;
  VoidCallback? _onOnline;

  void start(
    GlobalKey<NavigatorState> navigatorKey, {
    VoidCallback? onOffline,
    VoidCallback? onOnline,
  }) {
    _onOffline = onOffline;
    _onOnline = onOnline;

    // Check immediately
    _checkInternet(navigatorKey);

    // Check every 10 seconds
    _timer ??= Timer.periodic(const Duration(seconds: 10), (_) {
      _checkInternet(navigatorKey);
    });

    // Also check when network changes
    _subscription ??=
        _connectivity.onConnectivityChanged.listen((results) {
      _checkInternet(navigatorKey);
    });
  }

  Future<void> _checkInternet(GlobalKey<NavigatorState> navigatorKey) async {
    final hasInternet = await _hasRealInternet();

    if (!hasInternet && !_offline) {
      _offline = true;
      _onOffline?.call();
      _showDialog(navigatorKey);
    } else if (hasInternet && _offline) {
      _offline = false;
      _closeDialog();
      _onOnline?.call();
    }
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showDialog(GlobalKey<NavigatorState> navigatorKey) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/p1',
      (route) => false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _dialogContext = ctx;

        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.black,
            title: const Center(
              child: Icon(
                Icons.wifi_off,
                color: Colors.orange,
                size: 100,
              ),
            ),
            content: SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'NO INTERNET CONNECTION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'This kiosk is temporarily unavailable.\n'
                      'Please check the SIM card, topup, or network signal.\n\n'
                      'For assistance, please contact:\n'
                      '📞 ${Data.telefonNo}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _closeDialog() {
    if (_dialogContext != null) {
      Navigator.of(_dialogContext!, rootNavigator: true).pop();
      _dialogContext = null;
    }
  }

  void stop() {
    _subscription?.cancel();
    _timer?.cancel();

    _subscription = null;
    _timer = null;
    _offline = false;
    _dialogContext = null;
    _onOffline = null;
    _onOnline = null;
  }
}