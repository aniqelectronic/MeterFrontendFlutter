import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_v1/model/weather/weather_forecast.dart';

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

class WeatherServiceIpoh {
  WeatherServiceIpoh._();

  static final WeatherServiceIpoh instance = WeatherServiceIpoh._();

  static const String _baseUrl =
      'https://api.data.gov.my/weather/forecast';

  // Official district forecast containing Ipoh.
  // Ds032 = Kinta district, Perak.
  static const String _ipohLocationId = 'Ds032';

  // Separate cache keys prevent Bentong data from mixing with Ipoh data.
  static const String _cacheJsonKey =
      'weather_ipoh_kinta_ds032_cache_json_v1';

  static const String _cacheTimeKey =
      'weather_ipoh_kinta_ds032_cache_time_v1';

  static const Duration cacheDuration = Duration(hours: 6);

  static const Duration manualRefreshCooldown =
      Duration(minutes: 2);

  WeatherResult? _memoryCache;
  Future<WeatherResult>? _inFlightRequest;
  DateTime? _lastNetworkAttempt;

  Future<WeatherResult> getIpohForecast({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    // 1. Use valid memory cache.
    if (!forceRefresh) {
      final memory = _memoryCache;

      if (memory != null &&
          now.difference(memory.fetchedAt) < cacheDuration) {
        return WeatherResult(
          forecasts: memory.forecasts,
          fetchedAt: memory.fetchedAt,
          isFromCache: true,
        );
      }

      // 2. Use valid persistent cache.
      final stored = await _readPersistentCache();

      if (stored != null &&
          now.difference(stored.fetchedAt) < cacheDuration) {
        _memoryCache = stored;

        return WeatherResult(
          forecasts: stored.forecasts,
          fetchedAt: stored.fetchedAt,
          isFromCache: true,
        );
      }
    }

    // 3. Reuse an active network request.
    final existingRequest = _inFlightRequest;

    if (existingRequest != null) {
      return existingRequest;
    }

    // 4. Prevent refresh button spam.
    if (forceRefresh &&
        _lastNetworkAttempt != null &&
        now.difference(_lastNetworkAttempt!) <
            manualRefreshCooldown) {
      final fallback =
          _memoryCache ?? await _readPersistentCache();

      if (fallback != null) {
        return WeatherResult(
          forecasts: fallback.forecasts,
          fetchedAt: fallback.fetchedAt,
          isFromCache: true,
        );
      }
    }

    _lastNetworkAttempt = now;

    final request = _fetchFromNetwork();
    _inFlightRequest = request;

    try {
      return await request;
    } finally {
      _inFlightRequest = null;
    }
  }

  Future<WeatherResult> _fetchFromNetwork() async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'contains': '$_ipohLocationId@location__location_id',
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
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final rawList = _extractList(decoded);

        final parsedForecasts = rawList
            .whereType<Map>()
            .map(
              (item) => WeatherForecast.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where(
              (item) => item.locationId == _ipohLocationId,
            )
            .toList();

        // Keep one record for each forecast date.
        final Map<String, WeatherForecast> uniqueByDate = {};

        for (final forecast in parsedForecasts) {
          final dateKey =
              forecast.date.toIso8601String().split('T').first;

          uniqueByDate[dateKey] = forecast;
        }

        final forecasts = uniqueByDate.values.toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        if (forecasts.isEmpty) {
          throw const FormatException(
            'No Kinta district weather records returned for Ipoh.',
          );
        }

        final result = WeatherResult(
          forecasts: forecasts,
          fetchedAt: DateTime.now(),
          isFromCache: false,
        );

        _memoryCache = result;
        await _savePersistentCache(result);

        return result;
      }

      if (response.statusCode == 429) {
        return await _fallbackOrThrow(
          'Weather API rate limit reached.',
        );
      }

      return await _fallbackOrThrow(
        'Weather API returned HTTP ${response.statusCode}.',
      );
    } on TimeoutException {
      return await _fallbackOrThrow(
        'Weather request timed out.',
      );
    } catch (error) {
      return await _fallbackOrThrow(error.toString());
    }
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic> &&
        decoded['data'] is List) {
      return decoded['data'] as List<dynamic>;
    }

    throw const FormatException(
      'Unexpected weather response format.',
    );
  }

  Future<WeatherResult> _fallbackOrThrow(
    String message,
  ) async {
    final fallback =
        _memoryCache ?? await _readPersistentCache();

    if (fallback != null && fallback.forecasts.isNotEmpty) {
      _memoryCache = fallback;

      return WeatherResult(
        forecasts: fallback.forecasts,
        fetchedAt: fallback.fetchedAt,
        isFromCache: true,
      );
    }

    throw WeatherServiceException(message);
  }

  Future<void> _savePersistentCache(
    WeatherResult result,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonText = jsonEncode(
      result.forecasts.map((item) => item.toJson()).toList(),
    );

    await prefs.setString(_cacheJsonKey, jsonText);
    await prefs.setString(
      _cacheTimeKey,
      result.fetchedAt.toIso8601String(),
    );
  }

  Future<WeatherResult?> _readPersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonText = prefs.getString(_cacheJsonKey);
      final savedAtText = prefs.getString(_cacheTimeKey);

      if (jsonText == null || savedAtText == null) {
        return null;
      }

      final savedAt = DateTime.tryParse(savedAtText);
      final decoded = jsonDecode(jsonText);

      if (savedAt == null || decoded is! List) {
        return null;
      }

      final parsedForecasts = decoded
          .whereType<Map>()
          .map(
            (item) => WeatherForecast.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (item) => item.locationId == _ipohLocationId,
          )
          .toList();

      final Map<String, WeatherForecast> uniqueByDate = {};

      for (final forecast in parsedForecasts) {
        final dateKey =
            forecast.date.toIso8601String().split('T').first;

        uniqueByDate[dateKey] = forecast;
      }

      final forecasts = uniqueByDate.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

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
}

class WeatherServiceException implements Exception {
  final String message;

  const WeatherServiceException(this.message);

  @override
  String toString() => message;
}
