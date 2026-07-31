import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class LinuxKioskService {
  LinuxKioskService._();

  static Timer? _windowGuardTimer;
  static Timer? _popupGuardTimer;

  static bool _isRestoringWindow = false;
  static bool _allowSecondaryWindow = false;

  /// Call this before opening the PegePay QR WebView.
  static void allowSecondaryWindow() {
    _allowSecondaryWindow = true;
  }

  /// Call this after the PegePay QR WebView closes.
  static Future<void> restoreFlutterWindow() async {
    _allowSecondaryWindow = false;
    await _restoreWindow();
  }

  static Future<void> initialize() async {
    if (!Platform.isLinux) {
      return;
    }

    await _applyGnomeKioskSettings();
    await _closeLinuxPopups();
    await _configureFlutterWindow();

    _startWindowGuard();
    _startPopupGuard();
  }

  static Future<void> _configureFlutterWindow() async {
    try {
      await windowManager.setSkipTaskbar(true);
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setFullScreen(true);
      await windowManager.show();
      await windowManager.focus();

      // Give GNOME time to finish creating the window.
      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      await windowManager.setFullScreen(true);
      await windowManager.focus();
    } catch (error, stackTrace) {
      debugPrint(
        '[KIOSK] Initial window configuration failed: '
        '$error\n$stackTrace',
      );
    }
  }

  static Future<void> _applyGnomeKioskSettings() async {
    const commands = <List<String>>[
      // Disable notification banners.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.notifications',
        'show-banners',
        'false',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.notifications',
        'show-in-lock-screen',
        'false',
      ],

      // Disable hot corner.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.interface',
        'enable-hot-corners',
        'false',
      ],

      // Disable dynamic workspaces.
      [
        'gsettings',
        'set',
        'org.gnome.mutter',
        'dynamic-workspaces',
        'false',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.preferences',
        'num-workspaces',
        '1',
      ],

      // Disable Activities overview shortcuts.
      [
        'gsettings',
        'set',
        'org.gnome.shell.keybindings',
        'toggle-overview',
        '[]',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.shell.keybindings',
        'toggle-application-view',
        '[]',
      ],

      // Disable application switching.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'switch-applications',
        '[]',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'switch-applications-backward',
        '[]',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'switch-windows',
        '[]',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'switch-windows-backward',
        '[]',
      ],

      // Disable workspace switching.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'switch-to-workspace-left',
        '[]',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'switch-to-workspace-right',
        '[]',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'switch-to-workspace-up',
        '[]',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'switch-to-workspace-down',
        '[]',
      ],

      // Disable showing desktop.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'show-desktop',
        '[]',
      ],

      // Disable Alt+F2.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'panel-run-dialog',
        '[]',
      ],

      // Disable window closing and minimizing shortcuts.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'close',
        '[]',
      ],
      [
        'gsettings',
        'set',
        'org.gnome.desktop.wm.keybindings',
        'minimize',
        '[]',
      ],

      // Disable screen locking.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.lockdown',
        'disable-lock-screen',
        'true',
      ],

      // Disable screen blanking.
      [
        'gsettings',
        'set',
        'org.gnome.desktop.session',
        'idle-delay',
        'uint32 0',
      ],

      // Disable automatic suspend while plugged in.
      [
        'gsettings',
        'set',
        'org.gnome.settings-daemon.plugins.power',
        'sleep-inactive-ac-type',
        'nothing',
      ],

      // Disable automatic suspend on battery.
      [
        'gsettings',
        'set',
        'org.gnome.settings-daemon.plugins.power',
        'sleep-inactive-battery-type',
        'nothing',
      ],
    ];

    for (final command in commands) {
      try {
        final result = await Process.run(
          command.first,
          command.sublist(1),
          environment: _linuxEnvironment,
        );

        if (result.exitCode != 0) {
          debugPrint(
            '[KIOSK] Command failed: ${command.join(' ')}\n'
            '${result.stderr}',
          );
        }
      } catch (error) {
        debugPrint(
          '[KIOSK] Could not run ${command.join(' ')}: $error',
        );
      }
    }
  }

  static Map<String, String> get _linuxEnvironment {
    final environment = Map<String, String>.from(
      Platform.environment,
    );

    environment['DISPLAY'] = ':0';
    environment['XAUTHORITY'] =
        '/run/user/1000/gdm/Xauthority';
    environment['DBUS_SESSION_BUS_ADDRESS'] =
        'unix:path=/run/user/1000/bus';

    return environment;
  }

  static void _startWindowGuard() {
    _windowGuardTimer?.cancel();

    _windowGuardTimer = Timer.periodic(
      const Duration(milliseconds: 700),
      (_) async {
        if (_allowSecondaryWindow) {
          return;
        }

        await _restoreWindow();
      },
    );
  }

  static Future<void> _restoreWindow() async {
    if (_isRestoringWindow || !Platform.isLinux) {
      return;
    }

    _isRestoringWindow = true;

    try {
      final isVisible = await windowManager.isVisible();
      final isFullScreen = await windowManager.isFullScreen();
      final isFocused = await windowManager.isFocused();

      if (!isVisible) {
        await windowManager.show();
      }

      if (!isFullScreen) {
        await windowManager.setFullScreen(true);
      }

      if (!isFocused) {
        await windowManager.setAlwaysOnTop(true);
        await windowManager.show();
        await windowManager.focus();
      }

      await windowManager.setSkipTaskbar(true);
    } catch (error) {
      debugPrint(
        '[KIOSK] Window guard failed: $error',
      );
    } finally {
      _isRestoringWindow = false;
    }
  }

  static void _startPopupGuard() {
    _popupGuardTimer?.cancel();

    _popupGuardTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _closeLinuxPopups(),
    );
  }

  static Future<void> _closeLinuxPopups() async {
    if (!Platform.isLinux) {
      return;
    }

    const processNames = <String>[
      'update-manager',
      'software-properties-gtk',
      'gnome-software',
      'snap-store',
      'apport-gtk',
      'system-config-printer',
    ];

    for (final processName in processNames) {
      try {
        await Process.run(
          'pkill',
          <String>['-f', processName],
          environment: _linuxEnvironment,
        );
      } catch (error) {
        debugPrint(
          '[KIOSK] Could not close $processName: $error',
        );
      }
    }
  }

  static void dispose() {
    _windowGuardTimer?.cancel();
    _popupGuardTimer?.cancel();

    _windowGuardTimer = null;
    _popupGuardTimer = null;
  }
}