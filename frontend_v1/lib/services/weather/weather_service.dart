import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_v1/model/weather/weather_forecast.dart';
import 'package:frontend_v1/pages/data.dart';

// ============================================================================
// WEATHER RESULT
// ============================================================================
// This is used by weather_page.dart.
//
// IMPORTANT:
// weather_page.dart must import THIS weather_service.dart file.
// ============================================================================
class WeatherResult {
  final List<WeatherForecast> forecasts;
  final DateTime fetchedAt;
  final bool isFromCache;

  const WeatherResult({
    required this.forecasts,
    required this.fetchedAt,
    required this.isFromCache,
  });
}

// ============================================================================
// WEATHER SERVICE
// ============================================================================
//
// ONE service for all locations.
//
// Location is controlled from:
//
// Data.weatherPlaceName
// Data.weatherLocationId
//
// Example Putrajaya:
// Data.weatherPlaceName = "Putrajaya";
// Data.weatherLocationId = "Tn088";
//
// Example Bentong:
// Data.weatherPlaceName = "Bentong";
// Data.weatherLocationId = "Ds059";
//
// ============================================================================
class WeatherService {
  WeatherService._();

  static final WeatherService instance =
      WeatherService._();

  static const String _baseUrl =
      'https://api.data.gov.my/weather/forecast';

  // ============================================================
  // CACHE SETTINGS
  // ============================================================
  static const Duration cacheDuration =
      Duration(hours: 6);

  static const Duration manualRefreshCooldown =
      Duration(minutes: 2);

  WeatherResult? _memoryCache;

  String? _memoryCacheLocationId;

  Future<WeatherResult>? _inFlightRequest;

  String? _inFlightLocationId;

  DateTime? _lastNetworkAttempt;

  String? _lastNetworkAttemptLocationId;

  // ==========================================================================
  // DYNAMIC CACHE KEYS
  // ==========================================================================
  //
  // Each location gets its own cache.
  //
  // Example:
  // weather_Tn088_cache_json_v1
  // weather_Ds059_cache_json_v1
  //
  // This prevents Putrajaya from accidentally showing Bentong cached data.
  // ==========================================================================
  String get _cacheJsonKey =>
      'weather_${Data.weatherLocationId}_cache_json_v1';

  String get _cacheTimeKey =>
      'weather_${Data.weatherLocationId}_cache_time_v1';

  // ==========================================================================
  // GET FORECAST
  // ==========================================================================
  Future<WeatherResult> getForecast({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    final locationId =
        Data.weatherLocationId.trim();

    if (locationId.isEmpty) {
      throw const WeatherServiceException(
        'Weather location ID is empty.',
      );
    }

    // ============================================================
    // 1. USE MEMORY CACHE
    // ============================================================
    if (!forceRefresh) {
      final memory = _memoryCache;

      if (memory != null &&
          _memoryCacheLocationId == locationId &&
          now.difference(memory.fetchedAt) <
              cacheDuration) {
        return WeatherResult(
          forecasts: memory.forecasts,
          fetchedAt: memory.fetchedAt,
          isFromCache: true,
        );
      }

      // ==========================================================
      // 2. USE SAVED CACHE
      // ==========================================================
      final stored =
          await _readPersistentCache(
        locationId: locationId,
      );

      if (stored != null &&
          now.difference(stored.fetchedAt) <
              cacheDuration) {
        _memoryCache = stored;
        _memoryCacheLocationId = locationId;

        return WeatherResult(
          forecasts: stored.forecasts,
          fetchedAt: stored.fetchedAt,
          isFromCache: true,
        );
      }
    }

    // ============================================================
    // 3. REUSE ACTIVE REQUEST
    // ============================================================
    //
    // Only reuse it if it belongs to the SAME location.
    // ============================================================
    final existingRequest = _inFlightRequest;

    if (existingRequest != null &&
        _inFlightLocationId == locationId) {
      return existingRequest;
    }

    // ============================================================
    // 4. PREVENT REFRESH BUTTON SPAM
    // ============================================================
    if (forceRefresh &&
        _lastNetworkAttempt != null &&
        _lastNetworkAttemptLocationId ==
            locationId &&
        now.difference(_lastNetworkAttempt!) <
            manualRefreshCooldown) {
      WeatherResult? fallback;

      if (_memoryCache != null &&
          _memoryCacheLocationId ==
              locationId) {
        fallback = _memoryCache;
      } else {
        fallback =
            await _readPersistentCache(
          locationId: locationId,
        );
      }

      if (fallback != null) {
        return WeatherResult(
          forecasts: fallback.forecasts,
          fetchedAt: fallback.fetchedAt,
          isFromCache: true,
        );
      }
    }

    _lastNetworkAttempt = now;
    _lastNetworkAttemptLocationId =
        locationId;

    final request = _fetchFromNetwork(
      locationId: locationId,
    );

    _inFlightRequest = request;
    _inFlightLocationId = locationId;

    try {
      return await request;
    } finally {
      if (_inFlightLocationId ==
          locationId) {
        _inFlightRequest = null;
        _inFlightLocationId = null;
      }
    }
  }

  // ==========================================================================
  // FETCH DATA FROM DATA.GOV.MY
  // ==========================================================================
  Future<WeatherResult> _fetchFromNetwork({
    required String locationId,
  }) async {
    // ============================================================
    // Exact location filter.
    //
    // Example:
    // Tn088@location__location_id
    // Ds059@location__location_id
    // ============================================================
    final uri = Uri.parse(
      _baseUrl,
    ).replace(
      queryParameters: {
        'contains':
            '$locationId@location__location_id',
      },
    );

    try {
      final response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'TIP-Kiosk/1.0',
            },
          )
          .timeout(
            const Duration(
              seconds: 15,
            ),
          );

      // ==========================================================
      // SUCCESS
      // ==========================================================
      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(response.body);

        final rawList =
            _extractList(decoded);

        final parsedForecasts = rawList
            .whereType<Map>()
            .map(
              (item) =>
                  WeatherForecast.fromJson(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            )
            // ====================================================
            // Extra protection.
            //
            // Even if API returns multiple locations,
            // accept ONLY our selected location.
            // ====================================================
            .where(
              (item) =>
                  item.locationId ==
                  locationId,
            )
            .toList();

        // ========================================================
        // REMOVE DUPLICATE DATES
        // ========================================================
        final Map<String, WeatherForecast>
            uniqueByDate = {};

        for (final forecast
            in parsedForecasts) {
          final dateKey = forecast.date
              .toIso8601String()
              .split('T')
              .first;

          uniqueByDate[dateKey] =
              forecast;
        }

        final forecasts =
            uniqueByDate.values.toList()
              ..sort(
                (a, b) =>
                    a.date.compareTo(
                  b.date,
                ),
              );

        if (forecasts.isEmpty) {
          throw FormatException(
            'No weather records returned for '
            '${Data.weatherPlaceName} '
            '($locationId).',
          );
        }

        final result =
            WeatherResult(
          forecasts: forecasts,
          fetchedAt: DateTime.now(),
          isFromCache: false,
        );

        _memoryCache = result;
        _memoryCacheLocationId =
            locationId;

        await _savePersistentCache(
          result,
          locationId: locationId,
        );

        return result;
      }

      // ==========================================================
      // RATE LIMIT
      // ==========================================================
      if (response.statusCode == 429) {
        return await _fallbackOrThrow(
          'Weather API rate limit reached.',
          locationId: locationId,
        );
      }

      // ==========================================================
      // OTHER HTTP ERROR
      // ==========================================================
      return await _fallbackOrThrow(
        'Weather API returned HTTP '
        '${response.statusCode}.',
        locationId: locationId,
      );
    } on TimeoutException {
      return await _fallbackOrThrow(
        'Weather request timed out.',
        locationId: locationId,
      );
    } catch (error) {
      return await _fallbackOrThrow(
        error.toString(),
        locationId: locationId,
      );
    }
  }

  // ==========================================================================
  // EXTRACT API LIST
  // ==========================================================================
  List<dynamic> _extractList(
    dynamic decoded,
  ) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded
            is Map<String, dynamic> &&
        decoded['data'] is List) {
      return decoded['data']
          as List<dynamic>;
    }

    throw const FormatException(
      'Unexpected weather response format.',
    );
  }

  // ==========================================================================
  // FALLBACK TO CACHE
  // ==========================================================================
  Future<WeatherResult>
      _fallbackOrThrow(
    String message, {
    required String locationId,
  }) async {
    WeatherResult? fallback;

    if (_memoryCache != null &&
        _memoryCacheLocationId ==
            locationId) {
      fallback = _memoryCache;
    } else {
      fallback =
          await _readPersistentCache(
        locationId: locationId,
      );
    }

    if (fallback != null &&
        fallback.forecasts.isNotEmpty) {
      _memoryCache = fallback;
      _memoryCacheLocationId =
          locationId;

      return WeatherResult(
        forecasts: fallback.forecasts,
        fetchedAt: fallback.fetchedAt,
        isFromCache: true,
      );
    }

    throw WeatherServiceException(
      message,
    );
  }

  // ==========================================================================
  // SAVE CACHE
  // ==========================================================================
  Future<void> _savePersistentCache(
    WeatherResult result, {
    required String locationId,
  }) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final jsonText =
        jsonEncode(
      result.forecasts
          .map(
            (item) =>
                item.toJson(),
          )
          .toList(),
    );

    final jsonKey =
        'weather_${locationId}_cache_json_v1';

    final timeKey =
        'weather_${locationId}_cache_time_v1';

    await prefs.setString(
      jsonKey,
      jsonText,
    );

    await prefs.setString(
      timeKey,
      result.fetchedAt
          .toIso8601String(),
    );
  }

  // ==========================================================================
  // READ CACHE
  // ==========================================================================
  Future<WeatherResult?>
      _readPersistentCache({
    required String locationId,
  }) async {
    try {
      final prefs =
          await SharedPreferences
              .getInstance();

      final jsonKey =
          'weather_${locationId}_cache_json_v1';

      final timeKey =
          'weather_${locationId}_cache_time_v1';

      final jsonText =
          prefs.getString(
        jsonKey,
      );

      final savedAtText =
          prefs.getString(
        timeKey,
      );

      if (jsonText == null ||
          savedAtText == null) {
        return null;
      }

      final savedAt =
          DateTime.tryParse(
        savedAtText,
      );

      final decoded =
          jsonDecode(jsonText);

      if (savedAt == null ||
          decoded is! List) {
        return null;
      }

      final parsedForecasts = decoded
          .whereType<Map>()
          .map(
            (item) =>
                WeatherForecast.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .where(
            (item) =>
                item.locationId ==
                locationId,
          )
          .toList();

      // ==========================================================
      // REMOVE DUPLICATE DATES FROM CACHE
      // ==========================================================
      final Map<String, WeatherForecast>
          uniqueByDate = {};

      for (final forecast
          in parsedForecasts) {
        final dateKey = forecast.date
            .toIso8601String()
            .split('T')
            .first;

        uniqueByDate[dateKey] =
            forecast;
      }

      final forecasts =
          uniqueByDate.values.toList()
            ..sort(
              (a, b) =>
                  a.date.compareTo(
                b.date,
              ),
            );

      if (forecasts.isEmpty) {
        return null;
      }

      return WeatherResult(
        forecasts: forecasts,
        fetchedAt: savedAt,
        isFromCache: true,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================================
  // CLEAR CURRENT LOCATION CACHE
  // ==========================================================================
  Future<void> clearCurrentLocationCache()
      async {
    final locationId =
        Data.weatherLocationId.trim();

    _memoryCache = null;
    _memoryCacheLocationId = null;

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.remove(
      'weather_${locationId}_cache_json_v1',
    );

    await prefs.remove(
      'weather_${locationId}_cache_time_v1',
    );
  }

  // ==========================================================================
  // CLEAR MEMORY CACHE ONLY
  // ==========================================================================
  void clearMemoryCache() {
    _memoryCache = null;
    _memoryCacheLocationId = null;
  }
}

// ============================================================================
// WEATHER SERVICE EXCEPTION
// ============================================================================
class WeatherServiceException
    implements Exception {
  final String message;

  const WeatherServiceException(
    this.message,
  );

  @override
  String toString() => message;
}