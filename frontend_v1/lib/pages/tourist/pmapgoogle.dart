import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class PMAPGOOGLEPAGE extends StatefulWidget {
  const PMAPGOOGLEPAGE({super.key});

  @override
  State<PMAPGOOGLEPAGE> createState() => _PMAPGOOGLEPAGEState();
}

class _PMAPGOOGLEPAGEState extends State<PMAPGOOGLEPAGE>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
Timer? _debounce;
  double _currentZoom = 14;
  final double _defaultZoom = 16;

  LatLng? _selectedDestination;
  final GlobalKey _mapKey = GlobalKey();

  List<LatLng> _routePoints = [];

  LatLng _currentPosition = LatLng(Data.latitudedemo, Data.longitudedemo);

  late AnimationController _pulseController;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _showNoResult = false;

  // 🆕 KEYBOARD CONTROL
bool _showKeyboard = false;
VirtualKeyboardType _keyboardType = VirtualKeyboardType.Alphanumeric;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _tryGetCurrentLocation();

  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // 🆕 KEYBOARD INPUT HANDLER
bool shiftEnabled = false;

void _onKeyPress(VirtualKeyboardKey key) {
  // keyboard already updates controller automatically

  if (key.keyType == VirtualKeyboardKeyType.Action) {
    switch (key.action) {
      case VirtualKeyboardKeyAction.Shift:
        shiftEnabled = !shiftEnabled;
        break;

      case VirtualKeyboardKeyAction.Return:
        setState(() {
          _showKeyboard = false;
        });
        break;

      default:
        break;
    }
  }

  _searchLocation(_searchController.text);

  setState(() {});
}

  Future<void> _tryGetCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = newLocation;
        if (_routePoints.length > 2) {
        _currentZoom = 12; // Waze-like zoom out feel
      }
      });

      _mapController.move(newLocation, 16);
    } catch (e) {
      debugPrint("Location not available: $e");
    }
  }

Future<void> _searchLocation(String query) async {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(const Duration(milliseconds: 500), () async {
    final text = query.trim();

    if (text.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
        _showNoResult = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showNoResult = false;
    });

    try {
      /// 🔥 SEARCH AREA AROUND USER (nearby first)
      final lat = _currentPosition.latitude;
      final lon = _currentPosition.longitude;

      final url = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': text,
          'format': 'jsonv2',
          'limit': '40',
          'addressdetails': '1',
          'countrycodes': 'my',

          /// bias to nearby area
          // 'viewbox':
          //     '${lon - 0.08},${lat + 0.08},${lon + 0.08},${lat - 0.08}',

          // /// prioritize inside box first
          // 'bounded': '1',

          /// extra details
          'extratags': '1',
          'namedetails': '1',
        },
      );

      final response = await http.get(
        url,
        headers: {
          "User-Agent": "frontend_v1_kiosk_app",
          "Accept-Language": "en",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        /// 🔥 sort nearest
        data.sort((a, b) {
          final latA = double.tryParse(a["lat"] ?? "0") ?? 0;
          final lonA = double.tryParse(a["lon"] ?? "0") ?? 0;

          final latB = double.tryParse(b["lat"] ?? "0") ?? 0;
          final lonB = double.tryParse(b["lon"] ?? "0") ?? 0;

          final distA = Geolocator.distanceBetween(
            lat,
            lon,
            latA,
            lonA,
          );

          final distB = Geolocator.distanceBetween(
            lat,
            lon,
            latB,
            lonB,
          );

          return distA.compareTo(distB);
        });

        /// keep nearest 20 only
        final results = data.take(20).toList();

        setState(() {
          _searchResults = results;
          _isSearching = false;
          _showNoResult = results.isEmpty;
        });
      } else {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
          _showNoResult = true;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
        _showNoResult = true;
      });
    }
  });
}

Future<void> _getRoute(LatLng destination) async {
  try {
      final start = _currentPosition;

  // 🚨 BLOCK SAME POINT ROUTE
  final distance = Geolocator.distanceBetween(
    start.latitude,
    start.longitude,
    destination.latitude,
    destination.longitude,
  );

  if (distance < 20) {
    debugPrint("❌ Destination too close to current position");
    return;
  }

    debugPrint("START: $start");
    debugPrint("DEST: $destination");

    final url =
        "https://router.project-osrm.org/route/v1/driving/"
        "${start.longitude},${start.latitude};"
        "${destination.longitude},${destination.latitude}"
        "?overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(url));

    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    if (response.statusCode != 200) return;

    final data = jsonDecode(response.body);

    final routes = data["routes"];
    if (routes == null || routes.isEmpty) {
      debugPrint("NO ROUTES FOUND");
      return;
    }

    final coords = routes[0]["geometry"]["coordinates"];

    final List<LatLng> points =
        coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();

    debugPrint("POINTS: ${points.length}");

    setState(() {
      _routePoints = List<LatLng>.from(points);
    });

    Future.delayed(const Duration(milliseconds: 50), () {
  _mapController.move(points.first, 16);
});

    await Future.delayed(const Duration(milliseconds: 200));

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(100),
      ),
    );

  } catch (e) {
    debugPrint("Route error: $e");
  }
}

void _selectPlace(dynamic place) {
  final lat = double.parse(place["lat"]);
  final lon = double.parse(place["lon"]);

  final newPoint = LatLng(lat, lon);

  setState(() {
    _selectedDestination = newPoint;
    _searchResults.clear();
    _showNoResult = false;
    _searchController.text = place["display_name"];

    // close keyboard after choose place
    _showKeyboard = false;
  });

  _mapController.move(newPoint, 14);

  // auto open route
  _getRoute(newPoint);
}

void _resetMapSearch() {
  setState(() {
    _searchController.clear();
    _searchResults.clear();
    _showNoResult = false;
    _isSearching = false;
    _selectedDestination = null;
    _routePoints.clear();
    _showKeyboard = false;
  });

  _mapController.move(_currentPosition, 16);
}

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

        Widget _kioskZoomButton(
      IconData icon,
      String label,
      VoidCallback onTap, {
      Color? color,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 38,
                color: color != null
                    ? Colors.white
                    : Colors.black,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color != null
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// TITLE
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                loc.maptitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// SUBTITLE
          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                loc.mapsubtitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 62, 62, 62),
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// MAP
          Positioned(
            top: 450,
            left: 60,
            right: 60,
            bottom: 380,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.blue.shade900,
                  width: 6,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: FlutterMap(
                  key: _mapKey, // 🔥 IMPORTANT FIX
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition,
                    initialZoom: _currentZoom,
                    minZoom: 4,
                    maxZoom: 18,
                    onPositionChanged: (position, hasGesture) {
                      if (position.zoom != null) {
                        setState(() {
                          _currentZoom = position.zoom!;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: "com.frontend_v1.kiosk",
                    tileProvider: NetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        /// CURRENT LOCATION MARKER
                        Marker(
                          point: _currentPosition,
                          width: 120,
                          height: 120,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 40 * _pulseController.value + 40,
                                    height: 40 * _pulseController.value + 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withOpacity(
                                        1 - _pulseController.value,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.location_on,
                                    size: 60,
                                    color: Colors.red,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        /// DESTINATION MARKER (🔥 ADD THIS)
                        if (_selectedDestination != null)
                          Marker(
                            point: _selectedDestination!,
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.flag,
                              color: Colors.green,
                              size: 50,
                            ),
                          ),
                      ],
                    ),

                PolylineLayer(
                  polylines: _routePoints.isEmpty
                      ? []
                      : [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 6,
                            color: Colors.blue,
                          ),
                        ],
                ),
                  ],
                ),
              ),
            ),
          ),

          /// SEARCH BAR + SUGGESTION (ABOVE MAP)
          Positioned(
            top: 330,
            left: 60,
            right: 60,
            child: Material(
              color: Colors.transparent,
              elevation: 50,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.shade900,
                              width: 4,
                            ),
                          ),
                          child: TextField(
                          controller: _searchController,
                          readOnly: true,
                          showCursor: true,
                          autofocus: false,
                          onTap: () {
                            setState(() {
                              _showKeyboard = true;
                            });
                          },
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: loc.searchMap,
                            prefixIcon: const Icon(Icons.search, size: 35),

                            suffixIcon: _searchController.text.isNotEmpty
                                ? Padding(
                             padding: const EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                    onTap: () {
                                       _resetMapSearch();
                                      setState(() {
                                        _searchController.clear();
                                        _searchResults.clear();
                                        _showNoResult = false;
                                        _selectedDestination = null;
                                        _routePoints.clear();
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  )
                                )
                                : null,

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                        ),
                        ),
                      ),

                      const SizedBox(width: 10),
                    //       SizedBox(
                    //   height: 75,
                    //   width: 90,
                    //   child: ElevatedButton(
                    //     onPressed: _resetMapSearch,
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.red,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(18),
                    //       ),
                    //     ),
                    //     child: const Icon(
                    //       Icons.refresh,
                    //       size: 34,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                    ],
                  ),

                  if (_isSearching)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child:
                          const CircularProgressIndicator(),
                    ),

                  if (_searchResults.isNotEmpty)
                    Container(
                      margin:
                          const EdgeInsets.only(top: 8),
                      constraints:
                          const BoxConstraints(
                        maxHeight: 320,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            _searchResults.length,
                        itemBuilder:
                            (context, index) {
                          final item =
                              _searchResults[index];

                          return InkWell(
                            onTap: () =>
                                _selectPlace(item),
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(
                                      16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color:
                                        Colors.red,
                                  ),
                                  const SizedBox(
                                      width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["display_name"],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            "${(Geolocator.distanceBetween(
                                              _currentPosition.latitude,
                                              _currentPosition.longitude,
                                              double.parse(item["lat"]),
                                              double.parse(item["lon"]),
                                            ) / 1000).toStringAsFixed(2)} km away",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  if (_showNoResult)
                    Container(
                      margin:
                          const EdgeInsets.only(top: 8),
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              loc.errorMapSearch,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// BACK BUTTON
          Positioned(
            bottom: 200,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PTOURISTPAGE(),
                  ),
                );
              },
            ),
          ),

          /// DRAG TEXT BADGE
          Positioned(
            bottom: 400,
            left: 80,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.dragText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ZOOM CONTROLS
            Positioned(
              right: 80,
              bottom: 430,
              child: Column(
                children: [

                  /// ZOOM IN
                  _kioskZoomButton(
                    Icons.add,
                    "IN",
                    () {
                      setState(() {
                        _currentZoom = (_currentZoom + 1).clamp(4, 18);
                        _mapController.move(
                          _mapController.camera.center,
                          _currentZoom,
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  /// CURRENT ZOOM
                  Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${_currentZoom.toInt()}x",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// ZOOM OUT
                  _kioskZoomButton(
                    Icons.remove,
                    "OUT",
                    () {
                      setState(() {
                        _currentZoom = (_currentZoom - 1).clamp(4, 18);
                        _mapController.move(
                          _mapController.camera.center,
                          _currentZoom,
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  /// RESET
                  _kioskZoomButton(
                    Icons.center_focus_strong,
                    "RESET",
                    () {
                      _resetMapSearch();
                    },
                    color: Colors.blue.shade800,
                  ),
                ],
              ),
            ),

          /// FOOTER
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child:  Center(
              child: Text(
                Data.copyrightText,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          if (_showKeyboard)
  Positioned.fill(
    child: GestureDetector(
      onTap: () {
        setState(() {
          _showKeyboard = false;
        });
      },
      child: Container(
        color: Colors.transparent,
      ),
    ),
  ),

          // 🆕 VIRTUAL KEYBOARD (BOTTOM)
if (_showKeyboard)
  Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Container(
      height: 450,
      color: Colors.grey[200],
      child: VirtualKeyboard(
  height: 320,
  textColor: Colors.black,
  type: _keyboardType,
  fontSize: 22,

  textController: _searchController,

  defaultLayouts: const [
    VirtualKeyboardDefaultLayouts.English,
  ],

  postKeyPress: _onKeyPress,
)
    ),
  ),
        ],
      ),
    );
  }
}