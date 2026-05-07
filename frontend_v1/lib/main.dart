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

// ✅ GLOBAL NAVIGATOR KEY
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

  // ---------------- IDLE CONFIG ----------------
  static const Duration dimDuration = Duration(minutes: 1);
  static const Duration warningDuration = Duration(minutes: 3);
  static const int countdownSeconds = 60;

  // ---------------- HIBERNATE CONFIG ----------------
  static const Duration hibernateDuration = Duration(minutes: 5);
  Timer? _hibernateTimer;
  bool _screenOff = false;

  // ---------------- SCREEN POWER ----------------
  Future<void> _turnScreenOff() async {
    try {
    await Process.run(
      'bash',
      ['-c', 'DISPLAY=:0 xset +dpms && DISPLAY=:0 xset dpms force off'],
    );
  
      _screenOff = true;
      print("Screen turned OFF");
    } catch (e) {
      print("Failed to turn screen off: $e");
    }
  }
 
  Future<void> _turnScreenOn() async {
    try {
    await Process.run(
      'bash',
      ['-c', 'DISPLAY=:0 xset +dpms && DISPLAY=:0 xset dpms force on'],
    );
  
      _screenOff = false;
      print("Screen turned ON");
    } catch (e) {
      print("Failed to turn screen on: $e");
    }
  }

 void _resetHibernateTimer() {

  _hibernateTimer?.cancel();

  final routeName = _getCurrentRoute();

  // Only active on HOME page
  if (routeName == null || routeName != routeHome) return;

  _hibernateTimer = Timer(hibernateDuration, () async {

    final currentRoute = _getCurrentRoute();

    if (currentRoute == routeHome) {
      await _turnScreenOff();
    }

  });
}

  Timer? _dimTimer;
  Timer? _warningTimer;
  Timer? _countdownTimer;

  int _remainingSeconds = countdownSeconds;
  bool _warningShown = false;
  bool _dimmed = false;

  // ---------------- ROUTING ----------------
  static const String routeHome = '/p1';
  static const String routePayment = '/payment';
  static const String routeReceipt = '/receipt';

  Locale _locale = const Locale('en');

  final iotService = IoTHubService();

  @override
  void initState() {
    super.initState();
  
    WidgetsBinding.instance.addPostFrameCallback((_) async{
  
      InternetGuard().start(navigatorKey);
  
      _resetIdleTimers();

    iotService.connect().then((_) {
      iotService.startSending();
    });
  
      // delay so navigator route exists
      Future.delayed(const Duration(milliseconds: 500), () {
        _resetHibernateTimer();
      });
  
    });
  }

  // ---------------- ROUTE HELPER ----------------
  String? _getCurrentRoute() {
    final nav = navigatorKey.currentState;
    if (nav == null) return null;
  
    return ModalRoute.of(nav.context)?.settings.name;
  }

  // ---------------- BRIGHTNESS ----------------
  void _setBrightness(double value) async {
    try {
      final result = await Process.run(
        'bash',
        ['-c', 'DISPLAY=:0 xrandr']
      );
      final outputLine = result.stdout
          .toString()
          .split('\n')
          .firstWhere((line) => line.contains(" connected"), orElse: () => '');

      if (outputLine.isEmpty) return;

      final outputName = outputLine.split(' ')[0];

      await Process.run(
          'xrandr', ['--output', outputName, '--brightness', value.toString()]);

      _dimmed = value < 1.0;
      print("Brightness set to $value on $outputName");
    } catch (e) {
      print("Failed to set brightness: $e");
    }
  }

  // ---------------- RESET TIMERS ----------------
  void _resetIdleTimers() {

    if (_warningShown) return;

    _dimTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();

    if (_dimmed) {
      _setBrightness(1.0);
      _dimmed = false;
    }

    _remainingSeconds = countdownSeconds;

    final currentRouteName = _getCurrentRoute();

    // Only skip payment and receipt
    if (currentRouteName == routePayment || currentRouteName == routeReceipt) {
      return;
    }

    // ---------------- DIM TIMER ----------------
    _dimTimer = Timer(dimDuration, () {

      final routeName = _getCurrentRoute();

      if (routeName == routePayment || routeName == routeReceipt) return;

      _setBrightness(0.1);
    });

    // ---------------- WARNING TIMER ----------------
    _warningTimer = Timer(warningDuration, () {

      final routeName = _getCurrentRoute();

      if (routeName == routeHome ||
          routeName == routePayment ||
          routeName == routeReceipt) return;

      _showIdleWarning();
    });
  }

  // ---------------- GO HOME ----------------
  void _goHome() {

    _dimTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();

    _warningShown = false;
    _dimmed = false;

    _setBrightness(1.0);

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.pushNamedAndRemoveUntil(routeHome, (route) => false);

    _resetHibernateTimer();

    _dimTimer = Timer(dimDuration, () {

      final routeName = _getCurrentRoute();

      if (routeName == routePayment || routeName == routeReceipt) return;

      _setBrightness(0.1);
    });
  }

  // ---------------- IDLE DIALOG ----------------
  void _showIdleWarning() {

    if (_warningShown) return;

    final overlayContext = navigatorKey.currentState?.overlay?.context;
    if (overlayContext == null) return;

    final loc = AppLocalizations.of(overlayContext);
    if (loc == null) return;

    _warningShown = true;

    if (_dimmed) {
      _setBrightness(1.0);
    }

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
              }
              else {
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
                          fontWeight: FontWeight.bold),
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

                          Navigator.of(dialogContext,
                                  rootNavigator: true)
                              .pop();

                          _warningShown = false;

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

                          Navigator.of(dialogContext,
                                  rootNavigator: true)
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

  // ---------------- LOCALE ----------------
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // ---------------- BUILD ----------------
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

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) async {
          
            if (_screenOff) {
            
              await _turnScreenOn();
            
              if (_dimmed) {
                _setBrightness(1.0);
              }
            
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                routeHome,
                (route) => false,
              );
            
              _resetHibernateTimer();
              return;
            }
          
            if (!_warningShown) {
              _resetIdleTimers();
              _resetHibernateTimer();
            }
          },
          
           onPanDown: (_) async {
           
             if (_screenOff) {
             
               await _turnScreenOn();
             
               if (_dimmed) {
                 _setBrightness(1.0);
               }
                            
               navigatorKey.currentState?.pushNamedAndRemoveUntil(
                 routeHome,
                 (route) => false,
               );
             
               _resetHibernateTimer();
               return;
             }
           
             if (!_warningShown) {
               _resetIdleTimers();
               _resetHibernateTimer();
             }
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