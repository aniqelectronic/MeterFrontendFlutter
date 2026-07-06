import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_v1/pages/p1bentong.dart';
import 'package:window_manager/window_manager.dart';
import 'package:frontend_v1/pages/p1.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:io';
import 'package:frontend_v1/services/internet_guard.dart';
import 'package:frontend_v1/services/iot_hub_services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

String currentRouteName = '/p1';

class AppRouteObserver extends NavigatorObserver {
  final VoidCallback onRouteChanged;

  AppRouteObserver({required this.onRouteChanged});

  void _updateRoute(Route<dynamic>? route) {
    if (route == null) return;

    // Ignore dialog / popup routes
    if (route is PopupRoute) {
      print("IGNORED POPUP ROUTE");
      return;
    }

    final name = route.settings.name;

    if (name != null && name.isNotEmpty) {
      currentRouteName = name;
    } else {
      currentRouteName = 'NORMAL_PAGE';
    }

    print("CURRENT ROUTE: $currentRouteName");
    onRouteChanged();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _updateRoute(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    if (route is PopupRoute) {
      print("POPUP CLOSED, KEEP ROUTE: $currentRouteName");
      return;
    }

    _updateRoute(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateRoute(newRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);

    if (route is PopupRoute) return;

    _updateRoute(previousRoute);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    // size: Size(1080, 1920),
    // minimumSize: Size(1080, 1920),
    // maximumSize: Size(1080, 1920),
    size: Size(800, 1280),
    minimumSize: Size(800, 1280),
    maximumSize: Size(800, 1280),
    center: false,
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

  // ================= HOME DIM CONFIG =================
  static const Duration homeDimDuration = Duration(minutes: 5);

  static const double normalBrightness = 1.0;
  static const double dimBrightness = 0.3;
  static const double homeDimBrightness = 0.05;

  Timer? _dimTimer;
  Timer? _warningTimer;
  Timer? _countdownTimer;
  Timer? _homeDimTimer;

  int _remainingSeconds = countdownSeconds;

  bool _warningShown = false;
  bool _dimmed = false;
  bool _restoringBrightness = false;

  // ================= ROUTES =================
  static const String routeHome = '/p1';
  static const String routePayment = '/payment';
  static const String routeReceipt = '/receipt';

  Locale _locale = const Locale('en');

  late final AppRouteObserver _routeObserver;

// ================= IOT HUB =================
  final IoTHubService iotHubService = IoTHubService();

  @override
  void initState() {
    super.initState();

    _routeObserver = AppRouteObserver(
      onRouteChanged: _onRouteChanged,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetGuard().start(navigatorKey);

       iotHubService.connect();

      currentRouteName = routeHome;
      _resetIdleTimers();
    });
  }

  @override
  void dispose() {
    _dimTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();
    _homeDimTimer?.cancel();

    iotHubService.stop();
    super.dispose();
  }

  // ================= ROUTE CHANGE =================
  void _onRouteChanged() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      if (_warningShown) return;

      _resetIdleTimers();
    });
  }

  String _getCurrentRoute() {
    return currentRouteName;
  }

  bool _isHomePage() {
    return _getCurrentRoute() == routeHome;
  }

  bool _isBlockedWarningPage() {
    final route = _getCurrentRoute();

    return route == routeHome ||
        route == routePayment ||
        route == routeReceipt;
  }

  // ================= BRIGHTNESS =================
  Future<void> _setBrightness(double value) async {
    try {
      final safeValue = value.clamp(0.0, 1.0);

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

  Future<void> _restoreBrightness() async {
    if (_restoringBrightness) return;
    if (!_dimmed) return;   

    _restoringBrightness = true;

    try {
      await _setBrightness(normalBrightness);
      await Future.delayed(const Duration(milliseconds: 150));
      await _setBrightness(normalBrightness);

      _dimmed = false;
    } finally {
      _restoringBrightness = false;
    }
  }

  // ================= RESET TIMERS =================
  void _resetIdleTimers() {
    _dimTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();
    _homeDimTimer?.cancel();

    _remainingSeconds = countdownSeconds;

    print("RESET TIMER ON ROUTE: ${_getCurrentRoute()}");

    if (_warningShown) return;

    // ================= HOME PAGE =================
    if (_isHomePage()) {
      print("HOME PAGE: warning disabled, home dim enabled");

      _homeDimTimer = Timer(homeDimDuration, () {
        if (_isHomePage() && !_warningShown) {
          _setBrightness(homeDimBrightness);
        }
      });

      return;
    }

    // ================= PAYMENT / RECEIPT =================
    if (_isBlockedWarningPage()) {
      print("WARNING BLOCKED ON PAYMENT / RECEIPT");
      return;
    }

    // ================= NORMAL PAGE =================
    print("NORMAL PAGE: dim + warning enabled");

    _dimTimer = Timer(dimDuration, () {
      if (_isBlockedWarningPage()) return;

      _setBrightness(dimBrightness);
    });

    _warningTimer = Timer(warningDuration, () {
      if (_isBlockedWarningPage()) return;

      _showIdleWarning();
    });
  }

  // ================= GO HOME =================
  void _goHome() {
    _dimTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();
    _homeDimTimer?.cancel();

    _warningShown = false;
    _dimmed = false;

    currentRouteName = routeHome;

    _setBrightness(normalBrightness);

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.pushNamedAndRemoveUntil(routeHome, (route) => false);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      currentRouteName = routeHome;
      _resetIdleTimers();
    });
  }

  // ================= WARNING DIALOG =================
  void _showIdleWarning() {
    if (_warningShown) return;
    if (_isBlockedWarningPage()) return;

    final overlayContext = navigatorKey.currentState?.overlay?.context;
    if (overlayContext == null) return;

    final loc = AppLocalizations.of(overlayContext);
    if (loc == null) return;

    _warningShown = true;

    _restoreBrightness();

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
              if (_isBlockedWarningPage()) {
                timer.cancel();

                _warningShown = false;

                if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                }

                return;
              }

              if (_remainingSeconds <= 0) {
                timer.cancel();

                if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                }

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

                          if (Navigator.of(dialogContext, rootNavigator: true)
                              .canPop()) {
                            Navigator.of(dialogContext, rootNavigator: true)
                                .pop();
                          }

                          _warningShown = false;

                          _restoreBrightness();
                          _resetIdleTimers();
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

                          if (Navigator.of(dialogContext, rootNavigator: true)
                              .canPop()) {
                            Navigator.of(dialogContext, rootNavigator: true)
                                .pop();
                          }

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
    ).then((_) {
      _countdownTimer?.cancel();
      _warningShown = false;
    });
  }

  // ================= TOUCH =================
  void _handleUserTouch() {
    _restoreBrightness();

    if (!_warningShown) {
      _resetIdleTimers();
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
      navigatorObservers: [_routeObserver],
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
        routeHome: (context) => const P1BentongPage(),
      },
      // builder: (context, child) {
      //   final mediaQuery = MediaQuery.of(context);

      //   return Listener(
      //     behavior: HitTestBehavior.translucent,
      //     onPointerDown: (_) {
      //       _handleUserTouch();
      //     },
      //     onPointerMove: (_) {
      //       _handleUserTouch();
      //     },
      //     child: MediaQuery(
      //       data: mediaQuery.copyWith(textScaleFactor: 1.3),
      //       child: OnscreenKeyboard(child: child!),
      //     ),
      //   );
      // },

builder: (context, child) {
  final realMediaQuery = MediaQuery.of(context);

  const Size designSize = Size(1080, 1920);

  return Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: (_) => _handleUserTouch(),
    onPointerMove: (_) => _handleUserTouch(),
    child: SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: designSize.width,
          height: designSize.height,
          child: MediaQuery(
            data: realMediaQuery.copyWith(
              size: designSize,
              textScaleFactor: 1.0,
            ),
            child: OnscreenKeyboard(child: child!),
          ),
        ),
      ),
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