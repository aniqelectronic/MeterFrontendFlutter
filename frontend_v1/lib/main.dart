import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:frontend_v1/pages/p1.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:io';
import 'package:frontend_v1/services/internet_guard.dart';
import 'package:frontend_v1/services/iot_hub_services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1080, 1920),
    minimumSize: Size(1080, 1920),
    maximumSize: Size(1080, 1920),
    center: true,
    backgroundColor: Colors.black,
    titleBarStyle: TitleBarStyle.hidden,
    skipTaskbar: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setFullScreen(true);
  });

  await windowManager.setPreventClose(true);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final _AppState? state = context.findAncestorStateOfType<_AppState>();
    state?.setLocale(locale);
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // ================= IDLE CONFIG =================
  static const Duration dimDuration = Duration(minutes: 1);
  static const Duration warningDuration = Duration(minutes: 3);
  static const int countdownSeconds = 60;

  // ================= LOW POWER =================
  static const Duration hibernateDuration = Duration(minutes: 5);

  static const double normalBrightness = 1.0;
  static const double dimBrightness = 0.3;
  static const double deepDimBrightness = 0.05;
  static const double offlineDimBrightness = 0.5;

  Timer? _hibernateTimer;
  Timer? _dimTimer;
  Timer? _warningTimer;
  Timer? _countdownTimer;
  Timer? _offlineDimTimer;

  bool _screenOff = false;
  bool _warningShown = false;
  bool _dimmed = false;
  bool _internetOffline = false;
  bool _isRestoringBrightness = false;

  int _remainingSeconds = countdownSeconds;

  // ================= ROUTES =================
  static const String routeHome = '/p1';
  static const String routePayment = '/payment';
  static const String routeReceipt = '/receipt';

  Locale _locale = const Locale('en');

  final iotService = IoTHubService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      InternetGuard().start(
        navigatorKey,
        onOffline: _handleInternetOffline,
        onOnline: _handleInternetOnline,
      );

      _resetIdleTimers();

      iotService.connect().then((_) {
        iotService.startSending();
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        _resetHibernateTimer();
      });
    });
  }

  @override
  void dispose() {
    _hibernateTimer?.cancel();
    _dimTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();
    _offlineDimTimer?.cancel();
    super.dispose();
  }

  // ================= ROUTE =================
  String? _getCurrentRoute() {
    final nav = navigatorKey.currentState;
    if (nav == null) return null;

    return ModalRoute.of(nav.context)?.settings.name;
  }

  // ================= BRIGHTNESS =================
  Future<void> _setBrightness(double value) async {
    try {
      final safeValue = value.clamp(0.05, 1.0);

      final command = '''
export DISPLAY=:0
export XAUTHORITY=/home/orin_nano/.Xauthority
OUTPUT=\$(xrandr | grep " connected" | awk '{print \$1}' | head -n 1)
xrandr --output "\$OUTPUT" --brightness $safeValue
''';

      final result = await Process.run(
        'bash',
        ['-c', command],
      );

      if (result.stderr.toString().isNotEmpty) {
        print("Brightness stderr: ${result.stderr}");
      }

      _dimmed = safeValue < normalBrightness;

      print("Brightness set to $safeValue");
    } catch (e) {
      print("Failed to set brightness: $e");
    }
  }

  // ================= SCREEN OFF =================
  Future<void> _turnScreenOff() async {
    try {
      await _setBrightness(deepDimBrightness);

      _screenOff = true;
      _dimmed = true;

      print("Screen deep dimmed");
    } catch (e) {
      print("Failed to deep dim screen: $e");
    }
  }

  // ================= SCREEN ON =================
  Future<void> _turnScreenOn() async {
    if (_isRestoringBrightness) return;

    _isRestoringBrightness = true;

    try {
      await _setBrightness(1.0);

      await Future.delayed(const Duration(milliseconds: 200));

      await _setBrightness(1.0);

      await Future.delayed(const Duration(milliseconds: 200));

      await _setBrightness(1.0);

      _screenOff = false;
      _dimmed = false;

      print("Screen restored");
    } catch (e) {
      print("Failed to restore screen: $e");
    } finally {
      _isRestoringBrightness = false;
    }
  }

  // ================= INTERNET OFFLINE =================
  void _handleInternetOffline() {
    _internetOffline = true;

    _dimTimer?.cancel();
    _warningTimer?.cancel();
    _hibernateTimer?.cancel();
    _countdownTimer?.cancel();
    _offlineDimTimer?.cancel();

    _screenOff = false;
    _dimmed = false;

    _setBrightness(normalBrightness);

    _offlineDimTimer = Timer(const Duration(minutes: 3), () {
      if (_internetOffline) {
        _setBrightness(offlineDimBrightness);

        _screenOff = false;
        _dimmed = true;
      }
    });
  }

  // ================= INTERNET ONLINE =================
  void _handleInternetOnline() {
    _internetOffline = false;

    _offlineDimTimer?.cancel();

    _screenOff = false;
    _dimmed = false;

    _setBrightness(normalBrightness);

    _resetIdleTimers();
    _resetHibernateTimer();
  }

  // ================= HIBERNATE =================
  void _resetHibernateTimer() {
    _hibernateTimer?.cancel();

    if (_internetOffline) return;

    final routeName = _getCurrentRoute();

    if (routeName == null || routeName != routeHome) return;

    _hibernateTimer = Timer(hibernateDuration, () async {
      if (_internetOffline) return;

      final currentRoute = _getCurrentRoute();

      if (currentRoute == routeHome) {
        await _turnScreenOff();
      }
    });
  }

  // ================= RESET TIMERS =================
  void _resetIdleTimers() {
    if (_internetOffline) return;

    _dimTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();

    _remainingSeconds = countdownSeconds;

    final currentRouteName = _getCurrentRoute();

    if (currentRouteName == routePayment ||
        currentRouteName == routeReceipt) {
      return;
    }

    _dimTimer = Timer(dimDuration, () {
      if (_internetOffline) return;

      final routeName = _getCurrentRoute();

      if (routeName == routePayment || routeName == routeReceipt) return;

      _setBrightness(dimBrightness);
    });

    _warningTimer = Timer(warningDuration, () {
      if (_internetOffline) return;

      final routeName = _getCurrentRoute();

      if (routeName == routeHome ||
          routeName == routePayment ||
          routeName == routeReceipt) {
        return;
      }

      _showIdleWarning();
    });
  }

  // ================= GO HOME =================
void _goHome() {
  _dimTimer?.cancel();
  _warningTimer?.cancel();
  _countdownTimer?.cancel();

  _warningShown = false;

  _setBrightness(normalBrightness);

  final nav = navigatorKey.currentState;
  if (nav == null) return;

  nav.pushNamedAndRemoveUntil(routeHome, (route) => false);

  Future.delayed(const Duration(milliseconds: 300), () {
    if (!_internetOffline) {
      _resetHibernateTimer();
      _resetIdleTimers();
    }
  });
}

  // ================= WARNING DIALOG =================
  void _showIdleWarning() {
    if (_internetOffline) return;
    if (_warningShown) return;

    final overlayContext = navigatorKey.currentState?.overlay?.context;
    if (overlayContext == null) return;

    final loc = AppLocalizations.of(overlayContext);
    if (loc == null) return;

    _warningShown = true;

    _turnScreenOn();

    _remainingSeconds = countdownSeconds;

    showDialog(
      context: overlayContext,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            _countdownTimer?.cancel();

            _countdownTimer =
                Timer.periodic(const Duration(seconds: 1), (timer) {
              if (_remainingSeconds <= 0) {
                timer.cancel();

                Navigator.of(dialogContext, rootNavigator: true).pop();

                _goHome();
              } else {
                setDialogState(() {
                  _remainingSeconds--;
                });
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 600,
                height: 600,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.idleTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.idleMessage(_remainingSeconds),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 25),
                    ),
                    const SizedBox(height: 100),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(fontSize: 26),
                        ),
                        onPressed: () {
                          _countdownTimer?.cancel();

                          Navigator.of(dialogContext, rootNavigator: true)
                              .pop();

                          _warningShown = false;

                          _turnScreenOn();

                          _resetIdleTimers();
                          _resetHibernateTimer();
                        },
                        child: Text(loc.idleContinue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton(
                        onPressed: () {
                          _countdownTimer?.cancel();

                          Navigator.of(dialogContext, rootNavigator: true)
                              .pop();

                          _warningShown = false;

                          _goHome();
                        },
                        child: Text(
                          loc.idleGoHome,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= TOUCH =================
  Future<void> _handleUserTouch() async {
    await _turnScreenOn();

    if (_internetOffline) {
      _offlineDimTimer?.cancel();

      _offlineDimTimer = Timer(const Duration(minutes: 3), () {
        if (_internetOffline) {
          _setBrightness(offlineDimBrightness);

          _screenOff = false;
          _dimmed = true;
        }
      });

      return;
    }

    if (!_warningShown) {
      _resetIdleTimers();
      _resetHibernateTimer();
    }
  }

  // ================= LOCALE =================
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: routeHome,
      routes: {
        routeHome: (context) => const P1Page(),
      },
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            _handleUserTouch();
          },
          onPointerMove: (_) {
            _handleUserTouch();
          },
          child: MediaQuery(
            data: mediaQuery.copyWith(textScaleFactor: 1.3),
            child: OnscreenKeyboard(child: child!),
          ),
        );
      },
      theme: ThemeData(
        visualDensity: VisualDensity.standard,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 22),
          bodyMedium: TextStyle(fontSize: 20),
          titleLarge: TextStyle(fontSize: 28),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(260, 80),
            textStyle: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        iconTheme: const IconThemeData(size: 32),
      ),
    );
  }
}