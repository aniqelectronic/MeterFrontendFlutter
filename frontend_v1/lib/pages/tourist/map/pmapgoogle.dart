import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class PMAPGOOGLEPAGE extends StatefulWidget {
  const PMAPGOOGLEPAGE({
    super.key,
  });

  @override
  State<PMAPGOOGLEPAGE> createState() =>
      _PMAPGOOGLEPAGEState();
}

class _PMAPGOOGLEPAGEState extends State<PMAPGOOGLEPAGE>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final GlobalKey _mapKey = GlobalKey();

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;

  double _currentZoom = 14;

  LatLng? _selectedDestination;

  List<LatLng> _routePoints = [];

  LatLng _currentPosition = LatLng(
    Data.latitudedemo,
    Data.longitudedemo,
  );

  late AnimationController _pulseController;

  List<dynamic> _searchResults = [];

  bool _isSearching = false;
  bool _showNoResult = false;
  bool _showKeyboard = false;
  bool shiftEnabled = false;

  final VirtualKeyboardType _keyboardType =
      VirtualKeyboardType.Alphanumeric;

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
    _debounce?.cancel();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();

    super.dispose();
  }

  // ==========================================================================
  // VIRTUAL KEYBOARD INPUT
  // ==========================================================================
  void _onKeyPress(
    VirtualKeyboardKey key,
  ) {
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

    _searchLocation(
      _searchController.text,
    );

    setState(() {});
  }

  // ==========================================================================
  // GET CURRENT LOCATION
  // ==========================================================================
  Future<void> _tryGetCurrentLocation() async {
    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng newLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = newLocation;

        if (_routePoints.length > 2) {
          _currentZoom = 12;
        }
      });

      _mapController.move(
        newLocation,
        16,
      );
    } catch (error) {
      debugPrint(
        'Location not available: $error',
      );
    }
  }

  // ==========================================================================
  // SEARCH LOCATION
  // ==========================================================================
  Future<void> _searchLocation(
    String query,
  ) async {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        final String text = query.trim();

        if (text.isEmpty) {
          if (!mounted) {
            return;
          }

          setState(() {
            _searchResults.clear();
            _isSearching = false;
            _showNoResult = false;
          });

          return;
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _isSearching = true;
          _showNoResult = false;
        });

        try {
          final double lat =
              _currentPosition.latitude;

          final double lon =
              _currentPosition.longitude;

          final Uri url = Uri.https(
            'nominatim.openstreetmap.org',
            '/search',
            {
              'q': text,
              'format': 'jsonv2',
              'limit': '40',
              'addressdetails': '1',
              'countrycodes': 'my',
              'extratags': '1',
              'namedetails': '1',
            },
          );

          final http.Response response =
              await http.get(
            url,
            headers: {
              'User-Agent':
                  'frontend_v1_kiosk_app',
              'Accept-Language': 'en',
            },
          );

          if (!mounted) {
            return;
          }

          if (response.statusCode == 200) {
            final List<dynamic> data =
                jsonDecode(response.body);

            data.sort(
              (a, b) {
                final double latA =
                    double.tryParse(
                          a['lat'] ?? '0',
                        ) ??
                        0;

                final double lonA =
                    double.tryParse(
                          a['lon'] ?? '0',
                        ) ??
                        0;

                final double latB =
                    double.tryParse(
                          b['lat'] ?? '0',
                        ) ??
                        0;

                final double lonB =
                    double.tryParse(
                          b['lon'] ?? '0',
                        ) ??
                        0;

                final double distA =
                    Geolocator.distanceBetween(
                  lat,
                  lon,
                  latA,
                  lonA,
                );

                final double distB =
                    Geolocator.distanceBetween(
                  lat,
                  lon,
                  latB,
                  lonB,
                );

                return distA.compareTo(distB);
              },
            );

            final List<dynamic> results =
                data.take(20).toList();

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
        } catch (error) {
          if (!mounted) {
            return;
          }

          setState(() {
            _searchResults.clear();
            _isSearching = false;
            _showNoResult = true;
          });

          debugPrint(
            'Map search error: $error',
          );
        }
      },
    );
  }

  // ==========================================================================
  // GET ROUTE
  // ==========================================================================
  Future<void> _getRoute(
    LatLng destination,
  ) async {
    try {
      final LatLng start =
          _currentPosition;

      final double distance =
          Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        destination.latitude,
        destination.longitude,
      );

      if (distance < 20) {
        debugPrint(
          'Destination is too close.',
        );

        return;
      }

      final String url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson';

      final http.Response response =
          await http.get(
        Uri.parse(url),
      );

      if (response.statusCode != 200) {
        return;
      }

      final dynamic data =
          jsonDecode(response.body);

      final dynamic routes =
          data['routes'];

      if (routes == null || routes.isEmpty) {
        return;
      }

      final dynamic coordinates =
          routes[0]['geometry']['coordinates'];

      final List<LatLng> points =
          coordinates
              .map<LatLng>(
                (coordinate) => LatLng(
                  coordinate[1],
                  coordinate[0],
                ),
              )
              .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _routePoints =
            List<LatLng>.from(points);
      });

      await Future.delayed(
        const Duration(milliseconds: 200),
      );

      final LatLngBounds bounds =
          LatLngBounds.fromPoints(points);

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(110),
        ),
      );
    } catch (error) {
      debugPrint(
        'Route error: $error',
      );
    }
  }

  // ==========================================================================
  // SELECT SEARCH RESULT
  // ==========================================================================
  void _selectPlace(
    dynamic place,
  ) {
    final double lat =
        double.parse(place['lat']);

    final double lon =
        double.parse(place['lon']);

    final LatLng point =
        LatLng(lat, lon);

    setState(() {
      _selectedDestination = point;
      _searchResults.clear();
      _showNoResult = false;

      _searchController.text =
          place['display_name'];

      _showKeyboard = false;
    });

    _mapController.move(
      point,
      14,
    );

    _getRoute(point);
  }

  // ==========================================================================
  // RESET MAP
  // ==========================================================================
  void _resetMapSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
      _showNoResult = false;
      _isSearching = false;
      _selectedDestination = null;
      _routePoints.clear();
      _showKeyboard = false;
      _currentZoom = 16;
    });

    _mapController.move(
      _currentPosition,
      16,
    );
  }

  // ==========================================================================
  // CHANGE ZOOM
  // ==========================================================================
  void _zoomIn() {
    setState(() {
      _currentZoom =
          (_currentZoom + 1)
              .clamp(4, 18)
              .toDouble();
    });

    _mapController.move(
      _mapController.camera.center,
      _currentZoom,
    );
  }

  void _zoomOut() {
    setState(() {
      _currentZoom =
          (_currentZoom - 1)
              .clamp(4, 18)
              .toDouble();
    });

    _mapController.move(
      _mapController.camera.center,
      _currentZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          // ==================================================================
          // HEADER
          // ==================================================================
          Positioned(
            top: 55,
            left: 55,
            right: 55,
            child: _PremiumMapHeader(
              title: loc.maptitle,
              subtitle: loc.mapsubtitle,
              badgeText:
                  loc.mapInteractiveBadge,
            ),
          ),

          // ==================================================================
          // MAP CONTAINER
          //
          // IMPORTANT:
          // Map is placed before the search area so search suggestions appear
          // on top of the map.
          // ==================================================================
          Positioned(
            top: 425,
            left: 55,
            right: 55,
            bottom: 370,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(38),
                border: Border.all(
                  color: const Color(
                    0xFF223B58,
                  ),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.18),
                    blurRadius: 30,
                    offset:
                        const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(34),
                child: Stack(
                  children: [
                    // ==========================================================
                    // OPEN STREET MAP
                    // ==========================================================
                    FlutterMap(
                      key: _mapKey,
                      mapController:
                          _mapController,
                      options: MapOptions(
                        initialCenter:
                            _currentPosition,
                        initialZoom:
                            _currentZoom,
                        minZoom: 4,
                        maxZoom: 18,
                        onPositionChanged:
                            (
                          position,
                          hasGesture,
                        ) {
                          if (position.zoom != null) {
                            setState(() {
                              _currentZoom =
                                  position.zoom!;
                            });
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.frontend_v1.kiosk',
                          tileProvider:
                              NetworkTileProvider(),
                        ),

                        // ======================================================
                        // CURRENT LOCATION AND DESTINATION PINS
                        // ======================================================
                        MarkerLayer(
                          markers: [
                            // Current-location pin.
                            Marker(
                              point:
                                  _currentPosition,
                              width: 110,
                              height: 110,
                              child:
                                  AnimatedBuilder(
                                animation:
                                    _pulseController,
                                builder: (
                                  context,
                                  child,
                                ) {
                                  return Stack(
                                    alignment:
                                        Alignment.center,
                                    children: [
                                      Container(
                                        width:
                                            45 +
                                                (45 *
                                                    _pulseController.value),
                                        height:
                                            45 +
                                                (45 *
                                                    _pulseController.value),
                                        decoration:
                                            BoxDecoration(
                                          color: const Color(
                                            0xFF3478C9,
                                          ).withOpacity(
                                            1 -
                                                _pulseController.value,
                                          ),
                                          shape:
                                              BoxShape.circle,
                                        ),
                                      ),

                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors.white,
                                          shape:
                                              BoxShape.circle,
                                          border:
                                              Border.all(
                                            color:
                                                const Color(
                                              0xFF245F9D,
                                            ),
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors
                                                  .black
                                                  .withOpacity(
                                                0.18,
                                              ),
                                              blurRadius:
                                                  10,
                                            ),
                                          ],
                                        ),
                                        child:
                                            const Icon(
                                          Icons
                                              .my_location_rounded,
                                          color:
                                              Color(
                                            0xFF245F9D,
                                          ),
                                          size: 33,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            // Destination pin.
                            if (_selectedDestination !=
                                null)
                              Marker(
                                point:
                                    _selectedDestination!,
                                width: 75,
                                height: 75,
                                child: Container(
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.white,
                                    shape:
                                        BoxShape.circle,
                                    border:
                                        Border.all(
                                      color:
                                          const Color(
                                        0xFF168A50,
                                      ),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                          0.18,
                                        ),
                                        blurRadius:
                                            10,
                                      ),
                                    ],
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .flag_rounded,
                                    color:
                                        Color(
                                      0xFF168A50,
                                    ),
                                    size: 42,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // ======================================================
                        // ROUTE LINE
                        // ======================================================
                        PolylineLayer(
                          polylines:
                              _routePoints.isEmpty
                                  ? []
                                  : [
                                      Polyline(
                                        points:
                                            _routePoints,
                                        strokeWidth:
                                            8,
                                        color:
                                            const Color(
                                          0xFF246FBD,
                                        ),
                                        borderStrokeWidth:
                                            3,
                                        borderColor:
                                            Colors.white,
                                      ),
                                    ],
                        ),
                      ],
                    ),

                    // ==========================================================
                    // DRAG MAP BADGE
                    // ==========================================================
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: IgnorePointer(
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFF253A53,
                            ).withOpacity(0.90),
                            borderRadius:
                                BorderRadius
                                    .circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                  0.16,
                                ),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons
                                    .touch_app_rounded,
                                color:
                                    Colors.white,
                                size: 23,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Text(
                                loc.dragText,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ==========================================================
                    // ZOOM +, -, CURRENT ZOOM AND RESET
                    // ==========================================================
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child:
                          _PremiumZoomControls(
                        zoom:
                            _currentZoom.toInt(),
                        resetLabel:
                            loc.mapReset,
                        onZoomIn:
                            _zoomIn,
                        onZoomOut:
                            _zoomOut,
                        onReset:
                            _resetMapSearch,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================================
          // SEARCH AREA
          //
          // IMPORTANT:
          // This is after the map in the Stack. Therefore suggestions appear
          // above the map instead of behind it.
          // ==================================================================
          Positioned(
            top: 300,
            left: 55,
            right: 55,
            child: _PremiumSearchArea(
              controller:
                  _searchController,
              searchHint:
                  loc.searchMap,
              currentPosition:
                  _currentPosition,
              searchResults:
                  _searchResults,
              isSearching:
                  _isSearching,
              showNoResult:
                  _showNoResult,
              noResultText:
                  loc.errorMapSearch,
              searchingText:
                  loc.mapSearchingLocation,
              distanceAwayText:
                  loc.mapDistanceAway,
              onSearchTap: () {
                setState(() {
                  _showKeyboard = true;
                });
              },
              onClear:
                  _resetMapSearch,
              onSelectPlace:
                  _selectPlace,
            ),
          ),

          // ==================================================================
          // BACK BUTTON
          // ==================================================================
          Positioned(
            bottom: 185,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PTOURISTPAGE(),
                  ),
                );
              },
            ),
          ),

          // ==================================================================
          // FOOTER
          // ==================================================================
          Positioned(
            bottom: 85,
            left: 30,
            right: 30,
            child: Text(
              Data.copyrightText,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color:
                    Color(0xFF26364A),
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          // ==================================================================
          // KEYBOARD DISMISS LAYER
          // ==================================================================
          if (_showKeyboard)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showKeyboard = false;
                  });
                },
                child: Container(
                  color:
                      Colors.black.withOpacity(
                    0.08,
                  ),
                ),
              ),
            ),

          // ==================================================================
          // VIRTUAL KEYBOARD
          // ==================================================================
          if (_showKeyboard)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 520,
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  15,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF4F6F8,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(34),
                  ),
                  border: Border.all(
                    color:
                        const Color(
                      0xFFBFC8D2,
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.25),
                      blurRadius: 30,
                      offset:
                          const Offset(0, -12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 75,
                      height: 6,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFB4BCC5,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(20),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .keyboard_rounded,
                          color:
                              Color(
                            0xFF33485F,
                          ),
                          size: 28,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Text(
                          loc.mapKeyboardTitle,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF33485F,
                            ),
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        const Spacer(),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showKeyboard = false;
                            });
                          },
                          icon: const Icon(
                            Icons
                                .keyboard_hide_rounded,
                            color:
                                Color(
                              0xFF33485F,
                            ),
                            size: 32,
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      child: VirtualKeyboard(
                        height: 400,
                        textColor:
                            Colors.black,
                        type:
                            _keyboardType,
                        fontSize: 32,
                        textController:
                            _searchController,
                        defaultLayouts:
                            const [
                          VirtualKeyboardDefaultLayouts
                              .English,
                        ],
                        postKeyPress:
                            _onKeyPress,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// PREMIUM MAP HEADER
// ============================================================================
class _PremiumMapHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;

  const _PremiumMapHeader({
    required this.title,
    required this.subtitle,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(0.88),
            borderRadius:
                BorderRadius.circular(100),
            border: Border.all(
              color:
                  const Color(
                0xFFC7A34B,
              ).withOpacity(0.45),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.map_rounded,
                color:
                    Color(
                  0xFF9A7628,
                ),
                size: 25,
              ),

              const SizedBox(width: 9),

              Text(
                badgeText,
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF8A6A2A,
                  ),
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        ShaderMask(
          blendMode:
              BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF223A55),
                Color(0xFF70869B),
              ],
            ).createShader(bounds);
          },
          child: Text(
            title,
            textAlign:
                TextAlign.center,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 65,
              fontWeight:
                  FontWeight.w900,
              height: 1.05,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(0.90),
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
              color:
                  const Color(
                0xFFD4DCE4,
              ),
              width: 1.5,
            ),
          ),
          child: Text(
            subtitle,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              color:
                  Color(
                0xFF536273,
              ),
              fontSize: 26,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PREMIUM SEARCH AREA
// ============================================================================
class _PremiumSearchArea extends StatelessWidget {
  final TextEditingController controller;

  final String searchHint;
  final String noResultText;
  final String searchingText;

  final String Function(String distance)
      distanceAwayText;

  final LatLng currentPosition;

  final List<dynamic> searchResults;

  final bool isSearching;
  final bool showNoResult;

  final VoidCallback onSearchTap;
  final VoidCallback onClear;

  final ValueChanged<dynamic> onSelectPlace;

  const _PremiumSearchArea({
    required this.controller,
    required this.searchHint,
    required this.noResultText,
    required this.searchingText,
    required this.distanceAwayText,
    required this.currentPosition,
    required this.searchResults,
    required this.isSearching,
    required this.showNoResult,
    required this.onSearchTap,
    required this.onClear,
    required this.onSelectPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      // High elevation keeps the dropdown above the map.
      elevation: 50,

      child: Column(
        children: [
          // ==================================================================
          // SEARCH BOX
          // ==================================================================
          Container(
            height: 92,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.98),
              borderRadius:
                  BorderRadius.circular(27),
              border: Border.all(
                color:
                    const Color(
                  0xFF2E4B69,
                ),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.16),
                  blurRadius: 22,
                  offset:
                      const Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              readOnly: true,
              showCursor: true,
              autofocus: false,
              onTap: onSearchTap,
              style: const TextStyle(
                color:
                    Color(
                  0xFF24374A,
                ),
                fontSize: 27,
                fontWeight:
                    FontWeight.w700,
              ),
              decoration: InputDecoration(
                border:
                    InputBorder.none,
                hintText:
                    searchHint,
                hintStyle:
                    const TextStyle(
                  color:
                      Color(
                    0xFF8693A1,
                  ),
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w600,
                ),
                prefixIcon:
                    Container(
                  width: 64,
                  margin:
                      const EdgeInsets.all(
                    11,
                  ),
                  decoration:
                      const BoxDecoration(
                    color:
                        Color(
                      0xFFE8EFF6,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Icon(
                    Icons.search_rounded,
                    size: 34,
                    color:
                        Color(
                      0xFF315F8C,
                    ),
                  ),
                ),
                suffixIcon:
                    controller.text.isNotEmpty
                        ? Padding(
                            padding:
                                const EdgeInsets.only(
                              right: 12,
                            ),
                            child:
                                IconButton(
                              onPressed:
                                  onClear,
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                                size: 37,
                                color:
                                    Color(
                                  0xFF687786,
                                ),
                              ),
                            ),
                          )
                        : null,
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 25,
                ),
              ),
            ),
          ),

          // ==================================================================
          // SEARCHING INDICATOR
          // ==================================================================
          if (isSearching)
            Container(
              margin:
                  const EdgeInsets.only(
                top: 10,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color:
                      const Color(
                    0xFFCBD5DF,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.14),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),

                  const SizedBox(
                    width: 13,
                  ),

                  Text(
                    searchingText,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF25394D,
                      ),
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

          // ==================================================================
          // SEARCH SUGGESTIONS
          // ==================================================================
          if (searchResults.isNotEmpty)
            Container(
              margin:
                  const EdgeInsets.only(
                top: 10,
              ),
              constraints:
                  const BoxConstraints(
                maxHeight: 340,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(25),
                border: Border.all(
                  color:
                      const Color(
                    0xFF8FA3B7,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.28),
                    blurRadius: 30,
                    offset:
                        const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(23),
                child: ListView.separated(
                  padding:
                      EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount:
                      searchResults.length,
                  separatorBuilder:
                      (context, index) =>
                          const Divider(
                    height: 1,
                    thickness: 1,
                    color:
                        Color(
                      0xFFE0E5EA,
                    ),
                  ),
                  itemBuilder:
                      (context, index) {
                    final dynamic item =
                        searchResults[index];

                    final double distance =
                        Geolocator
                                .distanceBetween(
                          currentPosition
                              .latitude,
                          currentPosition
                              .longitude,
                          double.parse(
                            item['lat'],
                          ),
                          double.parse(
                            item['lon'],
                          ),
                        ) /
                            1000;

                    return Material(
                      color:
                          Colors.white,
                      child: InkWell(
                        onTap: () {
                          onSelectPlace(item);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 17,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Color(
                                    0xFFFFECEC,
                                  ),
                                  shape:
                                      BoxShape.circle,
                                ),
                                child:
                                    const Icon(
                                  Icons
                                      .location_on_rounded,
                                  color:
                                      Color(
                                    0xFFD33A3A,
                                  ),
                                  size: 31,
                                ),
                              ),

                              const SizedBox(
                                width: 15,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      item[
                                          'display_name'],
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF24374A,
                                        ),
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    Text(
                                      distanceAwayText(
                                        distance
                                            .toStringAsFixed(
                                          2,
                                        ),
                                      ),
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF798796,
                                        ),
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons
                                    .arrow_forward_ios_rounded,
                                color:
                                    Color(
                                  0xFF8793A0,
                                ),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // ==================================================================
          // NO RESULT MESSAGE
          // ==================================================================
          if (showNoResult)
            Container(
              margin:
                  const EdgeInsets.only(
                top: 10,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 17,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(
                  0xFFFFEEEE,
                ),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color:
                      const Color(
                    0xFFE36A6A,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.13),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .warning_amber_rounded,
                    color:
                        Color(
                      0xFFC62828,
                    ),
                    size: 30,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      noResultText,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFFC62828,
                        ),
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// PREMIUM ZOOM CONTROLS
// ============================================================================
class _PremiumZoomControls extends StatelessWidget {
  final int zoom;
  final String resetLabel;

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const _PremiumZoomControls({
    required this.zoom,
    required this.resetLabel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.96),
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color:
              const Color(
            0xFFCBD4DD,
          ),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Zoom in button.
          _ZoomButton(
            icon:
                Icons.add_rounded,
            onTap:
                onZoomIn,
          ),

          // Current zoom display.
          Container(
            width: 62,
            margin:
                const EdgeInsets.symmetric(
              vertical: 7,
            ),
            padding:
                const EdgeInsets.symmetric(
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF293E55,
              ),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            alignment:
                Alignment.center,
            child: Text(
              '${zoom}x',
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          // Zoom out button.
          _ZoomButton(
            icon:
                Icons.remove_rounded,
            onTap:
                onZoomOut,
          ),

          const SizedBox(
            height: 8,
          ),

          // Reset map button.
          Tooltip(
            message:
                resetLabel,
            child: _ZoomButton(
              icon: Icons
                  .center_focus_strong_rounded,
              onTap:
                  onReset,
              backgroundColor:
                  const Color(
                0xFFB58A33,
              ),
              foregroundColor:
                  Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  final Color backgroundColor;
  final Color foregroundColor;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor =
        const Color(0xFFF1F4F7),
    this.foregroundColor =
        const Color(0xFF2C435A),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          Colors.transparent,
      child: InkWell(
        onTap:
            onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color:
                backgroundColor,
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color:
                foregroundColor,
            size: 32,
          ),
        ),
      ),
    );
  }
}