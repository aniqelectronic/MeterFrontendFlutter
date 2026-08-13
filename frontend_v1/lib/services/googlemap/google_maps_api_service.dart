import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GooglePlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;

  const GooglePlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });

  factory GooglePlacePrediction.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> prediction = Map<String, dynamic>.from(
      json['placePrediction'] ?? const {},
    );

    final Map<String, dynamic> text = Map<String, dynamic>.from(
      prediction['text'] ?? const {},
    );

    final Map<String, dynamic> structuredFormat = Map<String, dynamic>.from(
      prediction['structuredFormat'] ?? const {},
    );

    final Map<String, dynamic> mainTextData = Map<String, dynamic>.from(
      structuredFormat['mainText'] ?? const {},
    );

    final Map<String, dynamic> secondaryTextData = Map<String, dynamic>.from(
      structuredFormat['secondaryText'] ?? const {},
    );

    return GooglePlacePrediction(
      placeId: prediction['placeId']?.toString() ?? '',
      mainText:
          mainTextData['text']?.toString() ?? text['text']?.toString() ?? '',
      secondaryText: secondaryTextData['text']?.toString() ?? '',
      fullText: text['text']?.toString() ?? '',
    );
  }
}

class GooglePlaceDetails {
  final String placeId;
  final String displayName;
  final String formattedAddress;
  final LatLng position;

  const GooglePlaceDetails({
    required this.placeId,
    required this.displayName,
    required this.formattedAddress,
    required this.position,
  });

  factory GooglePlaceDetails.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> location = Map<String, dynamic>.from(
      json['location'] ?? const {},
    );

    final Map<String, dynamic> displayNameData = Map<String, dynamic>.from(
      json['displayName'] ?? const {},
    );

    return GooglePlaceDetails(
      placeId: json['id']?.toString() ?? '',
      displayName: displayNameData['text']?.toString() ?? '',
      formattedAddress: json['formattedAddress']?.toString() ?? '',
      position: LatLng(
        (location['latitude'] as num?)?.toDouble() ?? 0,
        (location['longitude'] as num?)?.toDouble() ?? 0,
      ),
    );
  }
}

class GoogleRouteResult {
  final List<LatLng> points;
  final int distanceMeters;
  final Duration duration;
  final String encodedPolyline;

  const GoogleRouteResult({
    required this.points,
    required this.distanceMeters,
    required this.duration,
    required this.encodedPolyline,
  });
}

class GoogleMapsApiException implements Exception {
  final String message;
  final int? statusCode;

  const GoogleMapsApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'GoogleMapsApiException: $message'
        '${statusCode == null ? '' : ' ($statusCode)'}';
  }
}

class GoogleMapsApiService {
  GoogleMapsApiService._();

  static final GoogleMapsApiService instance = GoogleMapsApiService._();

  static const String _apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  static const Duration _timeout = Duration(seconds: 15);

  void _checkApiKey() {
    if (_apiKey.trim().isEmpty) {
      throw const GoogleMapsApiException(
        'GOOGLE_MAPS_API_KEY is missing. Build with '
        '--dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY',
      );
    }
  }

  Future<List<GooglePlacePrediction>> autocomplete({
    required String query,
    required LatLng currentPosition,
    String languageCode = 'en',
  }) async {
    _checkApiKey();

    final String cleanQuery = query.trim();

    if (cleanQuery.length < 2) {
      return [];
    }

    final Uri uri = Uri.parse(
      'https://places.googleapis.com/v1/'
      'places:autocomplete',
    );

    final Map<String, dynamic> requestBody = {
      'input': cleanQuery,
      'languageCode': languageCode,
      'regionCode': 'MY',
      'includedRegionCodes': ['my'],
      'locationBias': {
        'circle': {
          'center': {
            'latitude': currentPosition.latitude,
            'longitude': currentPosition.longitude,
          },
          'radius': 50000.0,
        },
      },
    };

    final http.Response response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'suggestions.placePrediction.placeId,'
                'suggestions.placePrediction.text,'
                'suggestions.placePrediction.structuredFormat',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      debugPrint(
        'Google autocomplete failed: '
        '${response.statusCode} ${response.body}',
      );

      throw GoogleMapsApiException(
        _readGoogleError(response.body),
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> body = Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    final List<dynamic> suggestions =
        body['suggestions'] as List<dynamic>? ?? const [];

    return suggestions
        .whereType<Map<String, dynamic>>()
        .where((item) => item['placePrediction'] != null)
        .map(GooglePlacePrediction.fromJson)
        .where((item) => item.placeId.isNotEmpty)
        .take(15)
        .toList();
  }

  Future<GooglePlaceDetails> getPlaceDetails({
    required String placeId,
    String languageCode = 'en',
  }) async {
    _checkApiKey();

    final Uri uri = Uri.parse(
      'https://places.googleapis.com/v1/'
      'places/$placeId?languageCode=$languageCode',
    );

    final http.Response response = await http
        .get(
          uri,
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
          },
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      debugPrint(
        'Google place details failed: '
        '${response.statusCode} ${response.body}',
      );

      throw GoogleMapsApiException(
        _readGoogleError(response.body),
        statusCode: response.statusCode,
      );
    }

    return GooglePlaceDetails.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  Future<GoogleRouteResult> computeDrivingRoute({
    required LatLng origin,
    required LatLng destination,
    String languageCode = 'en-US',
  }) async {
    _checkApiKey();

    final Uri uri = Uri.parse(
      'https://routes.googleapis.com/'
      'directions/v2:computeRoutes',
    );

    final Map<String, dynamic> requestBody = {
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
        },
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          },
        },
      },
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE',
      'computeAlternativeRoutes': false,
      'languageCode': languageCode,
      'units': 'METRIC',
      'polylineQuality': 'HIGH_QUALITY',
      'polylineEncoding': 'ENCODED_POLYLINE',
    };

    final http.Response response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'routes.distanceMeters,'
                'routes.duration,'
                'routes.polyline.encodedPolyline',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      debugPrint(
        'Google route failed: '
        '${response.statusCode} ${response.body}',
      );

      throw GoogleMapsApiException(
        _readGoogleError(response.body),
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> body = Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    final List<dynamic> routes = body['routes'] as List<dynamic>? ?? const [];

    if (routes.isEmpty) {
      throw const GoogleMapsApiException('Google did not return a route.');
    }

    final Map<String, dynamic> route = Map<String, dynamic>.from(routes.first);

    final Map<String, dynamic> polyline = Map<String, dynamic>.from(
      route['polyline'] ?? const {},
    );

    final String encodedPolyline =
        polyline['encodedPolyline']?.toString() ?? '';

    if (encodedPolyline.isEmpty) {
      throw const GoogleMapsApiException(
        'Google returned an empty route polyline.',
      );
    }

    return GoogleRouteResult(
      points: _decodePolyline(encodedPolyline),
      distanceMeters: (route['distanceMeters'] as num?)?.toInt() ?? 0,
      duration: _parseGoogleDuration(route['duration']?.toString()),
      encodedPolyline: encodedPolyline,
    );
  }

  Uri staticMapUri({
    required LatLng center,
    required int zoom,
    required int width,
    required int height,
    required String languageCode,
    LatLng? currentPosition,
    LatLng? destination,
    String? encodedRoute,
  }) {
    _checkApiKey();

    final Map<String, String> parameters = {
      'center': '${center.latitude},${center.longitude}',
      'zoom': zoom.clamp(3, 20).toString(),
      'size': '${width.clamp(180, 640)}x${height.clamp(180, 640)}',
      'scale': '2',
      'maptype': 'roadmap',
      'language': languageCode,
      'region': 'MY',
      'key': _apiKey,
    };

    final List<String> queryParts = parameters.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value)}',
        )
        .toList();

    if (currentPosition != null) {
      queryParts.add(
        'markers=${Uri.encodeQueryComponent('size:mid|color:0x1769D3|label:A|'
        '${currentPosition.latitude},${currentPosition.longitude}')}',
      );
    }

    if (destination != null) {
      queryParts.add(
        'markers=${Uri.encodeQueryComponent('size:mid|color:0xD84B3E|label:B|'
        '${destination.latitude},${destination.longitude}')}',
      );
    }

    if (encodedRoute != null && encodedRoute.isNotEmpty) {
      queryParts.add(
        'path=${Uri.encodeQueryComponent('weight:6|color:0x1769D3FF|enc:$encodedRoute')}',
      );
    }

    return Uri.parse(
      'https://maps.googleapis.com/maps/api/staticmap?'
      '${queryParts.join('&')}',
    );
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);

      latitude += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      result = 0;
      shift = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);

      longitude += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }

    return points;
  }

  static Duration _parseGoogleDuration(String? value) {
    if (value == null || value.isEmpty) {
      return Duration.zero;
    }

    final double seconds = double.tryParse(value.replaceAll('s', '')) ?? 0;

    return Duration(milliseconds: (seconds * 1000).round());
  }

  static String _readGoogleError(String responseBody) {
    try {
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(responseBody),
      );

      final Map<String, dynamic> error = Map<String, dynamic>.from(
        body['error'] ?? const {},
      );

      return error['message']?.toString() ?? 'Google Maps request failed.';
    } catch (_) {
      return 'Google Maps request failed.';
    }
  }
}
