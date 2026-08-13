import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OpenPlaceResult {
  const OpenPlaceResult({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
    required this.category,
  });

  final String id;
  final String name;
  final String address;
  final LatLng position;
  final String category;

  factory OpenPlaceResult.fromJson(Map<String, dynamic> json) {
    final displayName = json['display_name']?.toString() ?? '';
    final namedetails = Map<String, dynamic>.from(
      json['namedetails'] as Map? ?? const {},
    );
    final address = Map<String, dynamic>.from(
      json['address'] as Map? ?? const {},
    );

    final name =
        namedetails['name']?.toString() ??
        json['name']?.toString() ??
        displayName.split(',').first;

    final locality =
        [
              address['road'],
              address['suburb'],
              address['town'] ?? address['city'] ?? address['village'],
              address['state'],
              address['postcode'],
            ]
            .where((part) => part != null && part.toString().trim().isNotEmpty)
            .map((part) => part.toString())
            .toSet()
            .join(', ');

    return OpenPlaceResult(
      id: '${json['osm_type'] ?? ''}:${json['osm_id'] ?? ''}',
      name: name,
      address: locality.isEmpty ? displayName : locality,
      position: LatLng(
        double.tryParse(json['lat']?.toString() ?? '') ?? 0,
        double.tryParse(json['lon']?.toString() ?? '') ?? 0,
      ),
      category: json['type']?.toString().replaceAll('_', ' ') ?? '',
    );
  }

  factory OpenPlaceResult.fromPhotonJson(Map<String, dynamic> json) {
    final properties = Map<String, dynamic>.from(
      json['properties'] as Map? ?? const {},
    );
    final geometry = Map<String, dynamic>.from(
      json['geometry'] as Map? ?? const {},
    );
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? const [];

    final name =
        properties['name']?.toString() ??
        properties['street']?.toString() ??
        properties['city']?.toString() ??
        'Unnamed place';

    final street = [properties['housenumber'], properties['street']]
        .where((part) => part != null && part.toString().trim().isNotEmpty)
        .map((part) => part.toString())
        .join(' ');

    final address =
        [
              if (street.isNotEmpty) street,
              properties['district'],
              properties['city'] ?? properties['town'] ?? properties['village'],
              properties['county'],
              properties['state'],
              properties['postcode'],
              properties['country'],
            ]
            .where((part) => part != null && part.toString().trim().isNotEmpty)
            .map((part) => part.toString())
            .toSet()
            .join(', ');

    return OpenPlaceResult(
      id: '${properties['osm_type'] ?? ''}:${properties['osm_id'] ?? ''}',
      name: name,
      address: address,
      position: LatLng(
        coordinates.length > 1 ? (coordinates[1] as num).toDouble() : 0,
        coordinates.isNotEmpty ? (coordinates[0] as num).toDouble() : 0,
      ),
      category: properties['osm_value']?.toString().replaceAll('_', ' ') ?? '',
    );
  }
}

class OpenRouteResult {
  const OpenRouteResult({
    required this.points,
    required this.distanceMeters,
    required this.duration,
  });

  final List<LatLng> points;
  final int distanceMeters;
  final Duration duration;
}

class OpenMapApiException implements Exception {
  const OpenMapApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class OpenMapApiService {
  OpenMapApiService._();

  static final OpenMapApiService instance = OpenMapApiService._();
  static const Duration _timeout = Duration(seconds: 15);
  static const Duration _minimumSearchInterval = Duration(milliseconds: 1100);
  static const Duration _minimumAutocompleteInterval = Duration(
    milliseconds: 550,
  );

  final Map<String, List<OpenPlaceResult>> _searchCache = {};
  final Map<String, List<OpenPlaceResult>> _autocompleteCache = {};
  DateTime? _lastSearchAt;
  DateTime? _lastAutocompleteAt;

  Future<List<OpenPlaceResult>> autocompletePlaces({
    required String query,
    required LatLng near,
    required double zoom,
    String languageCode = 'en',
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];
    // The public Photon instance rejects some kiosk locales such as `ms`.
    // It still returns local Malaysian OSM names when queried in English.
    const photonLanguageCode = 'en';

    final areaLat = (near.latitude * 10).round();
    final areaLon = (near.longitude * 10).round();
    final cacheKey =
        '$photonLanguageCode:'
        '${cleanQuery.toLowerCase()}:$areaLat:$areaLon';
    final cached = _autocompleteCache[cacheKey];
    if (cached != null) return List.unmodifiable(cached);

    final lastAutocompleteAt = _lastAutocompleteAt;
    if (lastAutocompleteAt != null) {
      final elapsed = DateTime.now().difference(lastAutocompleteAt);
      if (elapsed < _minimumAutocompleteInterval) {
        await Future<void>.delayed(_minimumAutocompleteInterval - elapsed);
      }
    }
    _lastAutocompleteAt = DateTime.now();

    final uri = Uri.https('photon.komoot.io', '/api', {
      'q': cleanQuery,
      'limit': '10',
      'lat': near.latitude.toString(),
      'lon': near.longitude.toString(),
      'zoom': zoom.clamp(4, 18).round().toString(),
      'location_bias_scale': '0.15',
      'countrycode': 'MY',
      'lang': photonLanguageCode,
      'dedupe': '1',
    });

    final response = await http
        .get(
          uri,
          headers: const {
            'User-Agent': 'VistaBentongPublicKiosk/1.0',
            'Accept': 'application/geo+json, application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw OpenMapApiException(
        'Live place suggestions are temporarily unavailable.',
        statusCode: response.statusCode,
      );
    }

    final body = Map<String, dynamic>.from(jsonDecode(response.body));
    final features = body['features'] as List<dynamic>? ?? const [];
    final results = features
        .whereType<Map<String, dynamic>>()
        .map(OpenPlaceResult.fromPhotonJson)
        .where(
          (place) =>
              place.position.latitude != 0 || place.position.longitude != 0,
        )
        .toList();

    _autocompleteCache[cacheKey] = results;
    if (_autocompleteCache.length > 80) {
      _autocompleteCache.remove(_autocompleteCache.keys.first);
    }
    return List.unmodifiable(results);
  }

  Future<List<OpenPlaceResult>> searchPlaces({
    required String query,
    required LatLng near,
    String languageCode = 'en',
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    final areaLat = (near.latitude * 10).round();
    final areaLon = (near.longitude * 10).round();
    final cacheKey =
        '${languageCode.toLowerCase()}:'
        '${cleanQuery.toLowerCase()}:$areaLat:$areaLon';
    final cached = _searchCache[cacheKey];
    if (cached != null) return List.unmodifiable(cached);

    final nearbyResults = await _requestPlaces(
      query: cleanQuery,
      near: near,
      languageCode: languageCode,
      bounded: true,
    );

    final results = nearbyResults.isNotEmpty
        ? nearbyResults
        : await _requestPlaces(
            query: cleanQuery,
            near: near,
            languageCode: languageCode,
            bounded: false,
          );

    _searchCache[cacheKey] = results;
    if (_searchCache.length > 40) {
      _searchCache.remove(_searchCache.keys.first);
    }
    return List.unmodifiable(results);
  }

  Future<List<OpenPlaceResult>> _requestPlaces({
    required String query,
    required LatLng near,
    required String languageCode,
    required bool bounded,
  }) async {
    final lastSearchAt = _lastSearchAt;
    if (lastSearchAt != null) {
      final elapsed = DateTime.now().difference(lastSearchAt);
      if (elapsed < _minimumSearchInterval) {
        await Future<void>.delayed(_minimumSearchInterval - elapsed);
      }
    }
    _lastSearchAt = DateTime.now();

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '20',
      'addressdetails': '1',
      'namedetails': '1',
      'countrycodes': 'my',
      'viewbox':
          '${near.longitude - 0.35},${near.latitude + 0.30},'
          '${near.longitude + 0.35},${near.latitude - 0.30}',
      'bounded': bounded ? '1' : '0',
      'accept-language': languageCode,
    });

    final response = await http
        .get(
          uri,
          headers: const {
            'User-Agent': 'VistaBentongPublicKiosk/1.0',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw OpenMapApiException(
        'Place search is temporarily unavailable.',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    final results = decoded
        .whereType<Map<String, dynamic>>()
        .map(OpenPlaceResult.fromJson)
        .where(
          (place) =>
              place.position.latitude != 0 || place.position.longitude != 0,
        )
        .toList();

    return results;
  }

  Future<OpenRouteResult> computeDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}',
      {'overview': 'full', 'geometries': 'geojson', 'steps': 'false'},
    );

    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw OpenMapApiException(
        'Driving directions are temporarily unavailable.',
        statusCode: response.statusCode,
      );
    }

    final body = Map<String, dynamic>.from(jsonDecode(response.body));
    final routes = body['routes'] as List<dynamic>? ?? const [];
    if (routes.isEmpty) {
      throw const OpenMapApiException('No driving route was found.');
    }

    final route = Map<String, dynamic>.from(routes.first as Map);
    final geometry = Map<String, dynamic>.from(route['geometry'] as Map);
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? const [];

    return OpenRouteResult(
      points: coordinates.map((coordinate) {
        final pair = coordinate as List<dynamic>;
        return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
      }).toList(),
      distanceMeters: ((route['distance'] as num?) ?? 0).round(),
      duration: Duration(seconds: ((route['duration'] as num?) ?? 0).round()),
    );
  }
}
