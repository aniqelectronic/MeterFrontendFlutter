import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:window_manager/window_manager.dart';
import 'package:frontend_v1/pages/home/p1.dart';
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

// ============================================================
// UBUNTU KIOSK SHELL SETTINGS
// ============================================================
//
// This does not change the Flutter layout or screen scaling.
//
// It:
// - disables the Ubuntu side dock;
// - prevents notification banners;
// - disables the top-left hot corner;
// - disables lock-screen notifications;
// - prevents screen blanking and automatic suspend.
//
// The Flutter fullscreen window will cover the GNOME top panel.

Future<void> enableUbuntuKioskShell() async {
  try {
    const String command = r'''
export DISPLAY=:0
export XAUTHORITY=/home/orin_nano/.Xauthority

# Required when Flutter starts through systemd.
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

echo "[KIOSK] Applying Ubuntu kiosk settings..."

# ------------------------------------------------------------
# 1. Disable notification popup banners.
# ------------------------------------------------------------
gsettings set org.gnome.desktop.notifications show-banners false 2>/dev/null || true

# Do not show notifications on the lock screen.
gsettings set org.gnome.desktop.notifications show-in-lock-screen false 2>/dev/null || true

# ------------------------------------------------------------
# 2. Disable the top-left Activities hot corner.
# ------------------------------------------------------------
gsettings set org.gnome.desktop.interface enable-hot-corners false 2>/dev/null || true

# ------------------------------------------------------------
# 3. Disable the Ubuntu side dock completely.
#
# Different Ubuntu versions may use either extension ID.
# Commands safely continue when one ID is unavailable.
# ------------------------------------------------------------
if command -v gnome-extensions >/dev/null 2>&1; then
  gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
  gnome-extensions disable dash-to-dock@micxgx.gmail.com 2>/dev/null || true
fi

# ------------------------------------------------------------
# 4. Disable screen blanking and automatic suspend.
# ------------------------------------------------------------
gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' 2>/dev/null || true

# ------------------------------------------------------------
# 5. Disable screen locking.
# ------------------------------------------------------------
gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false 2>/dev/null || true

echo "[KIOSK] Ubuntu kiosk settings applied."
''';

    final result = await Process.run(
      'bash',
      ['-c', command],
    );

    final stdoutText = result.stdout.toString().trim();
    final stderrText = result.stderr.toString().trim();

    if (stdoutText.isNotEmpty) {
      print(stdoutText);
    }

    if (stderrText.isNotEmpty) {
      print('[KIOSK] Shell warning: $stderrText');
    }

    print(
      '[KIOSK] Ubuntu shell command exit code: '
      '${result.exitCode}',
    );
  } catch (e) {
    print('[KIOSK] Failed to configure Ubuntu shell: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  // Hide Ubuntu dock, notification banners, hot corner,
  // screen locking and automatic suspend.
  //
  // This runs before Flutter is displayed, reducing the chance
  // that the Ubuntu dock appears briefly.
  await enableUbuntuKioskShell();

  const windowOptions = WindowOptions(
    // Physical screen/window size.
    //
    // Your pages remain designed at 1080 x 1920 and continue
    // using the existing FittedBox builder.
    size: Size(800, 1280),
    minimumSize: Size(800, 1280),
    maximumSize: Size(800, 1280),

    center: false,
    backgroundColor: Colors.black,
    titleBarStyle: TitleBarStyle.hidden,

    // Hides the Flutter application's own taskbar entry.
    skipTaskbar: true,
  );

  windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      // Keep the existing physical size configuration.
      await windowManager.setSize(
        const Size(800, 1280),
      );

      await windowManager.setMinimumSize(
        const Size(800, 1280),
      );

      await windowManager.setMaximumSize(
        const Size(800, 1280),
      );

      // Prevent resizing.
      await windowManager.setResizable(false);

      // Remove the native Linux title bar and buttons.
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );

      // Keep the app out of the Ubuntu taskbar.
      await windowManager.setSkipTaskbar(true);

      await windowManager.show();

      // Fullscreen covers the Ubuntu top panel containing:
      // clock, Wi-Fi, power and settings.
      await windowManager.setFullScreen(true);

      await windowManager.focus();
    },
  );

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

  // ============================================================
// UBUNTU KIOSK SHELL SETTINGS
// ============================================================
//
// This does not change the Flutter layout or screen scaling.
//
// It:
// - disables the Ubuntu side dock;
// - prevents notification banners;
// - disables the top-left hot corner;
// - disables lock-screen notifications;
// - prevents screen blanking and automatic suspend.
//
// The Flutter fullscreen window will cover the GNOME top panel.

Future<void> enableUbuntuKioskShell() async {
  try {
    const String command = r'''
export DISPLAY=:0
export XAUTHORITY=/home/orin_nano/.Xauthority

# Required when Flutter starts through systemd.
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

echo "[KIOSK] Applying Ubuntu kiosk settings..."

# ------------------------------------------------------------
# 1. Disable notification popup banners.
# ------------------------------------------------------------
gsettings set org.gnome.desktop.notifications show-banners false 2>/dev/null || true

# Do not show notifications on the lock screen.
gsettings set org.gnome.desktop.notifications show-in-lock-screen false 2>/dev/null || true

# ------------------------------------------------------------
# 2. Disable the top-left Activities hot corner.
# ------------------------------------------------------------
gsettings set org.gnome.desktop.interface enable-hot-corners false 2>/dev/null || true

# ------------------------------------------------------------
# 3. Disable the Ubuntu side dock completely.
#
# Different Ubuntu versions may use either extension ID.
# Commands safely continue when one ID is unavailable.
# ------------------------------------------------------------
if command -v gnome-extensions >/dev/null 2>&1; then
  gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
  gnome-extensions disable dash-to-dock@micxgx.gmail.com 2>/dev/null || true
fi

# ------------------------------------------------------------
# 4. Disable screen blanking and automatic suspend.
# ------------------------------------------------------------
gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' 2>/dev/null || true

# ------------------------------------------------------------
# 5. Disable screen locking.
# ------------------------------------------------------------
gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false 2>/dev/null || true

echo "[KIOSK] Ubuntu kiosk settings applied."
''';

    final result = await Process.run(
      'bash',
      ['-c', command],
    );

    final stdoutText = result.stdout.toString().trim();
    final stderrText = result.stderr.toString().trim();

    if (stdoutText.isNotEmpty) {
      print(stdoutText);
    }

    if (stderrText.isNotEmpty) {
      print('[KIOSK] Shell warning: $stderrText');
    }

    print(
      '[KIOSK] Ubuntu shell command exit code: '
      '${result.exitCode}',
    );
  } catch (e) {
    print('[KIOSK] Failed to configure Ubuntu shell: $e');
  }
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
 //   if (!_dimmed) return;   

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

    // Darkens the background so the warning is easy to notice.
    barrierColor: Colors.black.withOpacity(0.65),

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
                Navigator.of(
                  dialogContext,
                  rootNavigator: true,
                ).pop();
              }

              return;
            }

            if (_remainingSeconds <= 0) {
              timer.cancel();

              if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
                Navigator.of(
                  dialogContext,
                  rootNavigator: true,
                ).pop();
              }

              _goHome();
            } else {
              setDialogState(() {
                _remainingSeconds--;
              });
            }
          });

          final double countdownProgress =
              (_remainingSeconds / countdownSeconds)
                  .clamp(0.0, 1.0)
                  .toDouble();

          final bool isUrgent = _remainingSeconds <= 10;

          final Color countdownColor = isUrgent
              ? Colors.red
              : const Color.fromARGB(255, 3, 89, 210);

          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 80,
              vertical: 80,
            ),
            child: Container(
              width: 760,
              padding: const EdgeInsets.fromLTRB(
                42,
                40,
                42,
                36,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 35,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ================= WARNING ICON =================
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        255,
                        246,
                        225,
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 52,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= TITLE =================
                  Text(
                    loc.idleTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 44,
                      height: 1.15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: 75,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        3,
                        89,
                        210,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ================= COUNTDOWN =================
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: countdownProgress,
                            strokeWidth: 14,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              countdownColor,
                            ),
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration:
                                  const Duration(milliseconds: 250),
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                "$_remainingSeconds",
                                key: ValueKey<int>(_remainingSeconds),
                                style: TextStyle(
                                  fontSize: 62,
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                  color: countdownColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Icon(
                              Icons.timer_outlined,
                              size: 30,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ================= MESSAGE =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        245,
                        248,
                        253,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      loc.idleMessage(_remainingSeconds),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 29,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 38),

                  // ================= CONTINUE BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 90,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          3,
                          89,
                          210,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        _countdownTimer?.cancel();

                        if (Navigator.of(
                          dialogContext,
                          rootNavigator: true,
                        ).canPop()) {
                          Navigator.of(
                            dialogContext,
                            rootNavigator: true,
                          ).pop();
                        }

                        _warningShown = false;

                        _restoreBrightness();
                        _resetIdleTimers();
                      },
                      icon: const Icon(
                        Icons.touch_app_rounded,
                        size: 38,
                      ),
                      label: Text(
                        loc.idleContinue,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ================= HOME BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 82,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.grey.shade50,
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        _countdownTimer?.cancel();

                        if (Navigator.of(
                          dialogContext,
                          rootNavigator: true,
                        ).canPop()) {
                          Navigator.of(
                            dialogContext,
                            rootNavigator: true,
                          ).pop();
                        }

                        _warningShown = false;

                        _goHome();
                      },
                      icon: const Icon(
                        Icons.home_outlined,
                        size: 35,
                      ),
                      label: Text(
                        loc.idleGoHome,
                        style: const TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                        ),
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