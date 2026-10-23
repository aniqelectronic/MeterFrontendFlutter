
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Config {
  // BACKEND
  static late String baseUrl;
  static late String apiVersion;
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  static late String apiPublicBaseUrl;
  static late String apiKey;
  static late String hmacSecret;

  // QR PAYMENT
  static late String terminalId;
  static late String storeId;
  static late String shiftId;
  static late int qrValidity;

  // COMPOUND
  static late String forcifyEndpoint;
  static late String forcifyToken;
  static late String compoundPrefix1;

  // MAP
  static late double latitude;
  static late double longitude;

  // PRAYER TIMES
  static late String waktusolatplace;
  static late String waktusolaturl;

  // AZURE IOT HUB
  static late String iotHubSharedAccessKey;

  // BRANCH
  static late String branchId;
  static late String branchName;

  // PBT AREA
  static late String pbtArea;

  // WEATHER
  static late String weatherPlaceName;
  static late String weatherLocationId;

  static bool isLoaded = false;

  // ============================================================
  // WINDOWS SIMULATION
  // ============================================================
  static Future<void> loadHQ() async {
    await _loadAsset('config/hq.json');
  }

  static Future<void> loadMelaka() async {
    await _loadAsset('config/melaka.json');
  }

  static Future<void> loadBentong() async {
    await _loadAsset('config/bentong.json');
  }

  static Future<void> loadPerak() async {
  await _loadAsset('config/perak.json');
}

  // ============================================================
  // JETSON LINUX - EXTERNAL CONFIGURATION
  // ============================================================
  static Future<void> loadJetson() async {
    const path = '/etc/tip/terminal.json';
    final file = File(path);

    if (!await file.exists()) {
      throw FileSystemException(
        'Jetson configuration not found',
        path,
      );
    }

    final jsonString = await file.readAsString();
    _applyJson(jsonString, path);
  }

  // ============================================================
  // LOAD FLUTTER ASSET
  // ============================================================
  static Future<void> _loadAsset(String path) async {
    final jsonString = await rootBundle.loadString(path);
    _applyJson(jsonString, path);
  }

  // ============================================================
  // SHARED CONFIGURATION PARSER
  // ============================================================
  static void _applyJson(String jsonString, String source) {
    isLoaded = false;

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      String requiredString(String key) {
        final value = data[key];
        if (value is! String || value.trim().isEmpty) {
          throw FormatException('Missing or empty configuration: $key');
        }
        return value;
      }

      num requiredNumber(String key) {
        final value = data[key];
        if (value is! num) {
          throw FormatException('Invalid numeric configuration: $key');
        }
        return value;
      }

      // BACKEND
      baseUrl = requiredString('baseUrl');
      apiVersion = requiredString('apiVersion');
      apiPublicBaseUrl = requiredString('apiPublicBaseUrl');
      apiKey = requiredString('apiKey');
      hmacSecret = requiredString('hmacSecret');

      // QR PAYMENT
      terminalId = requiredString('terminalId');
      storeId = requiredString('storeId');
      shiftId = requiredString('shiftId');
      qrValidity = requiredNumber('qrValidity').toInt();

      // COMPOUND
      forcifyEndpoint = requiredString('forcifyEndpoint');
      forcifyToken = requiredString('forcifyToken');
      compoundPrefix1 = requiredString('compoundPrefix1');

      // MAP
      latitude = requiredNumber('latitude').toDouble();
      longitude = requiredNumber('longitude').toDouble();

      // PRAYER TIMES
      waktusolatplace = requiredString('waktusolatplace');
      waktusolaturl = requiredString('waktusolaturl');

      // PBT AREA
      pbtArea = requiredString('pbtArea');

      // WEATHER
      weatherPlaceName = requiredString('weatherPlaceName');
      weatherLocationId = requiredString('weatherLocationId');

      // AZURE IOT HUB
      iotHubSharedAccessKey = requiredString('iotHubSharedAccessKey');

      // BRANCH
      branchId = requiredString('branchId');
      branchName = requiredString('branchName');

      isLoaded = true;

      debugPrint('================================');
      debugPrint('TIP CONFIGURATION LOADED');
      debugPrint('Source: $source');
      debugPrint('Branch: $branchName');
      debugPrint('Branch ID: $branchId');
      debugPrint('Terminal: $terminalId');
      debugPrint('API: $apiBaseUrl');
      debugPrint('PBT Area: $pbtArea');
      debugPrint('Weather: $weatherPlaceName');
      debugPrint('Prayer: $waktusolatplace');
      debugPrint('================================');
    } catch (e) {
      debugPrint('FAILED TO LOAD CONFIGURATION');
      debugPrint('Source: $source');
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
