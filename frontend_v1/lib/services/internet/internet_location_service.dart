import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class InternetLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String region;
  final String country;
  final String isp;
  final String ipAddress;
  final String source;
  final DateTime obtainedAt;

  const InternetLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.region,
    required this.country,
    required this.isp,
    required this.ipAddress,
    required this.source,
    required this.obtainedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'region': region,
      'country': country,
      'isp': isp,
      'ip_address': ipAddress,
      'location_source': source,
      'location_obtained_at': obtainedAt.toUtc().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'InternetLocation('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'city: $city, '
        'region: $region, '
        'country: $country, '
        'isp: $isp, '
        'ip: $ipAddress'
        ')';
  }
}

class InternetLocationService {
  InternetLocationService._();

  static final InternetLocationService instance =
      InternetLocationService._();

  static const Duration _requestTimeout = Duration(seconds: 10);

  // Do not request the location on every telemetry transmission.
  // Reuse it for six hours because IP location normally does not change often.
  static const Duration _cacheDuration = Duration(hours: 6);

  InternetLocation? _cachedLocation;
  DateTime? _lastSuccessfulLookup;

  bool _isRequesting = false;
  Future<InternetLocation?>? _activeRequest;

  /// Returns a cached location when it is still valid.
  ///
  /// Otherwise, obtains an approximate coordinate based on the Jetson's
  /// current public internet IP address.
  Future<InternetLocation?> getLocation({
    bool forceRefresh = false,
  }) {
    final now = DateTime.now();

    final cacheIsValid = !forceRefresh &&
        _cachedLocation != null &&
        _lastSuccessfulLookup != null &&
        now.difference(_lastSuccessfulLookup!) < _cacheDuration;

    if (cacheIsValid) {
      return Future.value(_cachedLocation);
    }

    // Prevent several simultaneous API requests.
    if (_isRequesting && _activeRequest != null) {
      return _activeRequest!;
    }

    _isRequesting = true;
    _activeRequest = _requestLocation();

    return _activeRequest!.whenComplete(() {
      _isRequesting = false;
      _activeRequest = null;
    });
  }

  Future<InternetLocation?> _requestLocation() async {
    // First provider.
    final primaryLocation = await _requestFromIpWhoIs();

    if (primaryLocation != null) {
      _saveToCache(primaryLocation);
      return primaryLocation;
    }

    print(
      '⚠️ Primary IP location provider failed. '
      'Trying backup provider...',
    );

    // Backup provider.
    final backupLocation = await _requestFromIpApi();

    if (backupLocation != null) {
      _saveToCache(backupLocation);
      return backupLocation;
    }

    print('❌ Unable to determine internet location');

    // Return the previous value, even if expired, when both services fail.
    // This prevents latitude and longitude from suddenly disappearing.
    if (_cachedLocation != null) {
      print('📍 Using previously cached internet location');
      return _cachedLocation;
    }

    return null;
  }

  Future<InternetLocation?> _requestFromIpWhoIs() async {
    try {
      print('🌐 Requesting IP-based location...');

      final response = await http
          .get(
            Uri.parse('https://ipwho.is/'),
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'VistaMeter-Jetson/1.0',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        print(
          '❌ IP location HTTP error: ${response.statusCode}',
        );
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        print('❌ Unexpected IP location response');
        return null;
      }

      if (decoded['success'] == false) {
        print(
          '❌ IP location API error: '
          '${decoded['message'] ?? 'unknown error'}',
        );
        return null;
      }

      final latitude = _toDouble(decoded['latitude']);
      final longitude = _toDouble(decoded['longitude']);

      if (!_isValidCoordinate(latitude, longitude)) {
        print('❌ IP location returned invalid coordinates');
        return null;
      }

      final connection = decoded['connection'];

      String isp = '';

      if (connection is Map<String, dynamic>) {
        isp = connection['isp']?.toString() ??
            connection['org']?.toString() ??
            '';
      }

      final location = InternetLocation(
        latitude: latitude!,
        longitude: longitude!,
        city: decoded['city']?.toString() ?? '',
        region: decoded['region']?.toString() ?? '',
        country: decoded['country']?.toString() ?? '',
        isp: isp,
        ipAddress: decoded['ip']?.toString() ?? '',
        source: 'ipwho.is',
        obtainedAt: DateTime.now().toUtc(),
      );

      print('✅ Internet location received');
      print('📍 Latitude: ${location.latitude}');
      print('📍 Longitude: ${location.longitude}');
      print('📍 City: ${location.city}');
      print('📍 Region: ${location.region}');
      print('📍 ISP: ${location.isp}');

      return location;
    } on TimeoutException {
      print('❌ IP location request timed out');
      return null;
    } on FormatException catch (e) {
      print('❌ Invalid IP location JSON: $e');
      return null;
    } catch (e) {
      print('❌ IP location request exception: $e');
      return null;
    }
  }

  Future<InternetLocation?> _requestFromIpApi() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://ip-api.com/json/'
              '?fields=status,message,country,regionName,city,lat,lon,'
              'isp,org,query',
            ),
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'VistaMeter-Jetson/1.0',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        print(
          '❌ Backup location HTTP error: ${response.statusCode}',
        );
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      if (decoded['status'] != 'success') {
        print(
          '❌ Backup location API error: '
          '${decoded['message'] ?? 'unknown error'}',
        );
        return null;
      }

      final latitude = _toDouble(decoded['lat']);
      final longitude = _toDouble(decoded['lon']);

      if (!_isValidCoordinate(latitude, longitude)) {
        return null;
      }

      final isp = decoded['isp']?.toString().trim() ?? '';
      final organisation = decoded['org']?.toString().trim() ?? '';

      return InternetLocation(
        latitude: latitude!,
        longitude: longitude!,
        city: decoded['city']?.toString() ?? '',
        region: decoded['regionName']?.toString() ?? '',
        country: decoded['country']?.toString() ?? '',
        isp: isp.isNotEmpty ? isp : organisation,
        ipAddress: decoded['query']?.toString() ?? '',
        source: 'ip-api.com',
        obtainedAt: DateTime.now().toUtc(),
      );
    } on TimeoutException {
      print('❌ Backup IP location request timed out');
      return null;
    } catch (e) {
      print('❌ Backup IP location exception: $e');
      return null;
    }
  }

  void _saveToCache(InternetLocation location) {
    _cachedLocation = location;
    _lastSuccessfulLookup = DateTime.now();
  }

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  bool _isValidCoordinate(
    double? latitude,
    double? longitude,
  ) {
    if (latitude == null || longitude == null) {
      return false;
    }

    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  void clearCache() {
    _cachedLocation = null;
    _lastSuccessfulLookup = null;
  }
}