import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetGuard {
  static final InternetGuard _instance = InternetGuard._internal();

  factory InternetGuard() => _instance;

  InternetGuard._internal();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _timer;

  bool _offline = false;
  bool _checking = false;

  BuildContext? _dialogContext;

  VoidCallback? _onOffline;
  VoidCallback? _onOnline;

  /// Other widgets can listen to this value.
  ///
  /// true  = internet available
  /// false = internet unavailable
  final ValueNotifier<bool> internetAvailable =
      ValueNotifier<bool>(true);

  /// Simple current internet status getter.
  bool get hasInternet => internetAvailable.value;

  void start(
    GlobalKey<NavigatorState> navigatorKey, {
    VoidCallback? onOffline,
    VoidCallback? onOnline,
  }) {
    _onOffline = onOffline;
    _onOnline = onOnline;

    // Check immediately when the application starts.
    _checkInternet(navigatorKey);

    // Continue checking every 10 seconds.
    _timer ??= Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        _checkInternet(navigatorKey);
      },
    );

    // Check immediately whenever the network connection changes.
    _subscription ??=
        _connectivity.onConnectivityChanged.listen((results) {
      _checkInternet(navigatorKey);
    });
  }

  Future<void> _checkInternet(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    if (_checking) return;

    _checking = true;

    try {
      final hasInternet =
          await InternetConnection().hasInternetAccess;

      _updateInternetNotifier(hasInternet);

      if (!hasInternet && !_offline) {
        _offline = true;

        _onOffline?.call();

        _showDialog(navigatorKey);
      } else if (hasInternet && _offline) {
        _offline = false;

        _closeDialog();

        _onOnline?.call();
      }
    } catch (error) {
      debugPrint(
        '[InternetGuard] Internet check failed: $error',
      );

      _updateInternetNotifier(false);

      if (!_offline) {
        _offline = true;

        _onOffline?.call();

        _showDialog(navigatorKey);
      }
    } finally {
      _checking = false;
    }
  }

  void _updateInternetNotifier(bool hasInternet) {
    if (internetAvailable.value == hasInternet) {
      return;
    }

    internetAvailable.value = hasInternet;

    debugPrint(
      hasInternet
          ? '[InternetGuard] Internet is available.'
          : '[InternetGuard] Internet is unavailable.',
    );
  }

  void _showDialog(
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final context = navigatorKey.currentContext;

    if (context == null) return;

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/p1',
      (route) => false,
    );

    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        final newContext = navigatorKey.currentContext;

        if (newContext == null ||
            !_offline ||
            _dialogContext != null) {
          return;
        }

        showDialog(
          context: newContext,
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
                  height: 450,
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          'PERKHIDMATAN TIDAK TERSEDIA\n'
                          'SERVICE TEMPORARILY UNAVAILABLE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Kiosk ini tidak dapat digunakan buat sementara waktu.\n'
                          'Sila cuba sebentar lagi.\n\n'
                          'This kiosk is temporarily unavailable.\n'
                          'Please try again later.\n\n'
                          'Untuk bantuan / For assistance:\n'
                          '📞 ${Data.telefonNo}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white70,
                            height: 1.5,
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
      },
    );
  }

  void _closeDialog() {
    if (_dialogContext == null) return;

    try {
      Navigator.of(
        _dialogContext!,
        rootNavigator: true,
      ).pop();
    } catch (error) {
      debugPrint(
        '[InternetGuard] Unable to close dialog: $error',
      );
    } finally {
      _dialogContext = null;
    }
  }

  void stop() {
    _subscription?.cancel();
    _timer?.cancel();

    _subscription = null;
    _timer = null;

    _offline = false;
    _checking = false;

    _dialogContext = null;

    _onOffline = null;
    _onOnline = null;
  }
}