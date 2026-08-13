import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/services/openmap/open_map_api_service.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class PMAPGOOGLEPAGE extends StatefulWidget {
  const PMAPGOOGLEPAGE({super.key});

  @override
  State<PMAPGOOGLEPAGE> createState() => _PMAPGOOGLEPAGEState();
}

class _PMAPGOOGLEPAGEState extends State<PMAPGOOGLEPAGE>
    with SingleTickerProviderStateMixin {
  final OpenMapApiService _openMap = OpenMapApiService.instance;
  final MapController _mapController = MapController();
  final GlobalKey _mapKey = GlobalKey();

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocus = FocusNode();
  Timer? _autocompleteTimer;
  int _autocompleteRequestId = 0;

  double _currentZoom = 14;

  LatLng? _selectedDestination;

  OpenPlaceResult? _selectedPlace;

  List<LatLng> _routePoints = [];

  LatLng _currentPosition = LatLng(Data.latitudedemo, Data.longitudedemo);
  late LatLng _searchOrigin;

  late AnimationController _pulseController;

  List<OpenPlaceResult> _searchResults = [];

  OpenRouteResult? _route;

  String? _mapError;

  bool _isSearching = false;
  bool _showNoResult = false;
  bool _showKeyboard = false;
  bool shiftEnabled = false;

  final VirtualKeyboardType _keyboardType = VirtualKeyboardType.Alphanumeric;

  @override
  void initState() {
    super.initState();
    _searchOrigin = _currentPosition;
    _searchController.addListener(_handleSearchTextChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _tryGetCurrentLocation();
  }

  @override
  void dispose() {
    _autocompleteTimer?.cancel();
    _pulseController.dispose();
    _searchController.removeListener(_handleSearchTextChanged);
    _searchController.dispose();
    _searchFocus.dispose();

    super.dispose();
  }

  // ==========================================================================
  // VIRTUAL KEYBOARD INPUT
  // ==========================================================================
  void _handleSearchTextChanged() {
    if (_showKeyboard) {
      _scheduleLiveSuggestions();
    }
  }

  void _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Shift:
          shiftEnabled = !shiftEnabled;
          break;

        case VirtualKeyboardKeyAction.Return:
          _autocompleteTimer?.cancel();
          _autocompleteRequestId++;
          setState(() {
            _showKeyboard = false;
          });
          _searchLocation(_searchController.text);
          break;

        default:
          break;
      }
    }

    setState(() {});
  }

  void _scheduleLiveSuggestions() {
    _autocompleteTimer?.cancel();
    final query = _searchController.text.trim();
    final requestId = ++_autocompleteRequestId;

    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _showNoResult = false;
      _mapError = null;
    });

    _autocompleteTimer = Timer(const Duration(milliseconds: 420), () async {
      if (!mounted || !_showKeyboard) return;
      try {
        final center = _mapController.camera.center;
        final results = await _openMap.autocompletePlaces(
          query: query,
          near: center,
          zoom: _mapController.camera.zoom,
          languageCode: Localizations.localeOf(context).languageCode,
        );
        if (!mounted || requestId != _autocompleteRequestId) return;

        setState(() {
          _searchOrigin = center;
          _searchResults = results.toList();
        });
      } catch (error) {
        if (!mounted || requestId != _autocompleteRequestId) return;
        debugPrint('Live suggestions unavailable: $error');
      }
    });
  }

  // ==========================================================================
  // GET CURRENT LOCATION
  // ==========================================================================
  Future<void> _tryGetCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng newLocation = LatLng(position.latitude, position.longitude);

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = newLocation;
        _searchOrigin = newLocation;

        if (_routePoints.length > 2) {
          _currentZoom = 12;
        }
      });

      _mapController.move(newLocation, 16);
    } catch (error) {
      debugPrint('Location not available: $error');
    }
  }

  // ==========================================================================
  // SEARCH LOCATION
  // ==========================================================================
  Future<void> _searchLocation(String query) async {
    final String text = query.trim();
    if (text.length < 2 || _isSearching) return;
    final searchCenter = _mapController.camera.center;
    _autocompleteTimer?.cancel();
    _autocompleteRequestId++;

    setState(() {
      _searchOrigin = searchCenter;
      _showKeyboard = false;
      _isSearching = true;
      _showNoResult = false;
      _mapError = null;
      _searchResults.clear();
    });

    try {
      final results = (await _openMap.searchPlaces(
        query: text,
        near: searchCenter,
        languageCode: Localizations.localeOf(context).languageCode,
      )).toList();
      if (!mounted) return;

      results.sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          searchCenter.latitude,
          searchCenter.longitude,
          a.position.latitude,
          a.position.longitude,
        );
        final distanceB = Geolocator.distanceBetween(
          searchCenter.latitude,
          searchCenter.longitude,
          b.position.latitude,
          b.position.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      setState(() {
        _searchResults = results;
        _isSearching = false;
        _showNoResult = results.isEmpty;
      });
    } on OpenMapApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _showNoResult = true;
        _mapError = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _showNoResult = true;
        _mapError = error.toString();
      });
    }
  }

  // ==========================================================================
  // GET ROUTE
  // ==========================================================================
  Future<void> _getRoute(LatLng destination) async {
    try {
      final double distance = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        destination.latitude,
        destination.longitude,
      );

      if (distance < 20) {
        debugPrint('Destination is too close.');

        return;
      }

      final route = await _openMap.computeDrivingRoute(
        origin: _currentPosition,
        destination: destination,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _route = route;
        _routePoints = route.points;
      });

      await Future.delayed(const Duration(milliseconds: 200));

      if (route.points.isEmpty) return;

      final LatLngBounds bounds = LatLngBounds.fromPoints(route.points);

      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(110)),
      );
    } on OpenMapApiException catch (error) {
      if (mounted) {
        setState(() => _mapError = error.message);
      }
    } catch (error) {
      debugPrint('Route error: $error');
    }
  }

  // ==========================================================================
  // SELECT SEARCH RESULT
  // ==========================================================================
  void _selectPlace(OpenPlaceResult place) {
    _autocompleteTimer?.cancel();
    _autocompleteRequestId++;
    final LatLng point = place.position;

    setState(() {
      _selectedDestination = point;
      _selectedPlace = place;
      _searchResults.clear();
      _showNoResult = false;

      _searchController.text = place.address.isEmpty
          ? place.name
          : place.address;

      _showKeyboard = false;
    });

    _mapController.move(point, 14);

    _getRoute(point);
  }

  // ==========================================================================
  // RESET MAP
  // ==========================================================================
  void _resetMapSearch() {
    _autocompleteTimer?.cancel();
    _autocompleteRequestId++;
    setState(() {
      _searchController.clear();
      _searchResults.clear();
      _showNoResult = false;
      _isSearching = false;
      _selectedDestination = null;
      _selectedPlace = null;
      _route = null;
      _routePoints.clear();
      _mapError = null;
      _showKeyboard = false;
      _currentZoom = 16;
      _searchOrigin = _currentPosition;
    });

    _mapController.move(_currentPosition, 16);
  }

  // ==========================================================================
  // CHANGE ZOOM
  // ==========================================================================
  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(4, 18).toDouble();
    });

    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(4, 18).toDouble();
    });

    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================
          Positioned.fill(
            child: Image.asset('lib/images/pnew.png', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.08)),
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
              badgeText: loc.mapInteractiveBadge,
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
                borderRadius: BorderRadius.circular(38),
                border: Border.all(color: const Color(0xFF223B58), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Stack(
                  children: [
                    // ==========================================================
                    // OPEN STREET MAP
                    // ==========================================================
                    FlutterMap(
                      key: _mapKey,
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
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.frontend_v1.kiosk',
                          tileProvider: NetworkTileProvider(),
                        ),

                        // ======================================================
                        // CURRENT LOCATION AND DESTINATION PINS
                        // ======================================================
                        MarkerLayer(
                          markers: [
                            // Current-location pin.
                            Marker(
                              point: _currentPosition,
                              width: 110,
                              height: 110,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width:
                                            45 + (45 * _pulseController.value),
                                        height:
                                            45 + (45 * _pulseController.value),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3478C9)
                                              .withValues(
                                                alpha:
                                                    1 - _pulseController.value,
                                              ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),

                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF245F9D),
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.18,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.my_location_rounded,
                                          color: Color(0xFF245F9D),
                                          size: 33,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            // Destination pin.
                            if (_selectedDestination != null)
                              Marker(
                                point: _selectedDestination!,
                                width: 75,
                                height: 75,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF168A50),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.flag_rounded,
                                    color: Color(0xFF168A50),
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
                          polylines: _routePoints.isEmpty
                              ? []
                              : [
                                  Polyline(
                                    points: _routePoints,
                                    strokeWidth: 8,
                                    color: const Color(0xFF246FBD),
                                    borderStrokeWidth: 3,
                                    borderColor: Colors.white,
                                  ),
                                ],
                        ),
                      ],
                    ),

                    Positioned(
                      left: 14,
                      bottom: 12,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '© OpenStreetMap contributors',
                            style: TextStyle(
                              color: Color(0xFF405368),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_route != null && _selectedPlace != null)
                      Positioned(
                        left: 16,
                        right: 115,
                        bottom: 52,
                        child: _RouteSummary(
                          place: _selectedPlace!,
                          route: _route!,
                        ),
                      ),

                    if (_mapError != null)
                      Positioned(
                        left: 18,
                        right: 115,
                        top: 78,
                        child: _MapErrorBanner(message: _mapError!),
                      ),

                    // ==========================================================
                    // DRAG MAP BADGE
                    // ==========================================================
                    Positioned(
                      left: 20,
                      top: 20,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF253A53,
                            ).withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.touch_app_rounded,
                                color: Colors.white,
                                size: 23,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                loc.dragText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
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
                      child: _PremiumZoomControls(
                        zoom: _currentZoom.toInt(),
                        resetLabel: loc.mapReset,
                        onZoomIn: _zoomIn,
                        onZoomOut: _zoomOut,
                        onReset: _resetMapSearch,
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
              controller: _searchController,
              searchHint: loc.searchMap,
              currentPosition: _searchOrigin,
              searchResults: _showKeyboard ? const [] : _searchResults,
              isSearching: _isSearching,
              showNoResult: _showNoResult,
              noResultText: _mapError ?? loc.errorMapSearch,
              searchingText: loc.mapSearchingLocation,
              distanceAwayText: loc.mapDistanceAway,
              onSearchTap: () {
                setState(() {
                  _showKeyboard = true;
                });
                if (_searchController.text.trim().isNotEmpty) {
                  _scheduleLiveSuggestions();
                }
              },
              onSearch: () => _searchLocation(_searchController.text),
              onClear: _resetMapSearch,
              onSelectPlace: _selectPlace,
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
                  MaterialPageRoute(builder: (_) => const PTOURISTPAGE()),
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF26364A),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // ==================================================================
          // KEYBOARD DISMISS LAYER
          // ==================================================================
          if (_showKeyboard)
            Positioned(
              top: 410,
              left: 0,
              right: 0,
              bottom: 650,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showKeyboard = false;
                  });
                },
                child: Container(color: Colors.black.withValues(alpha: 0.08)),
              ),
            ),

          if (_showKeyboard && _searchResults.isNotEmpty)
            Positioned(
              top: 402,
              left: 55,
              right: 55,
              child: _LiveSuggestionPanel(
                results: _searchResults,
                currentPosition: _searchOrigin,
                distanceAwayText: loc.mapDistanceAway,
                scrollHint: loc.scrolldown,
                onSelectPlace: _selectPlace,
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
                height: 650,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(34),
                  ),
                  border: Border.all(color: const Color(0xFFBFC8D2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, -12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 75,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB4BCC5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.keyboard_rounded,
                          color: Color(0xFF33485F),
                          size: 28,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          loc.mapKeyboardTitle,
                          style: const TextStyle(
                            color: Color(0xFF33485F),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const Spacer(),

                        FilledButton.icon(
                          onPressed: _isSearching
                              ? null
                              : () => _searchLocation(_searchController.text),
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('SEARCH'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(150, 56),
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showKeyboard = false;
                            });
                          },
                          icon: const Icon(
                            Icons.keyboard_hide_rounded,
                            color: Color(0xFF33485F),
                            size: 32,
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      child: VirtualKeyboard(
                        height: 520,
                        textColor: Colors.black,
                        type: _keyboardType,
                        fontSize: 38,
                        textController: _searchController,
                        defaultLayouts: const [
                          VirtualKeyboardDefaultLayouts.English,
                        ],
                        postKeyPress: _onKeyPress,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFFC7A34B).withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_rounded, color: Color(0xFF9A7628), size: 25),

              const SizedBox(width: 9),

              Text(
                badgeText,
                style: const TextStyle(
                  color: Color(0xFF8A6A2A),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Color(0xFF223A55), Color(0xFF70869B)],
            ).createShader(bounds);
          },
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 65,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4DCE4), width: 1.5),
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF536273),
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveSuggestionPanel extends StatefulWidget {
  const _LiveSuggestionPanel({
    required this.results,
    required this.currentPosition,
    required this.distanceAwayText,
    required this.scrollHint,
    required this.onSelectPlace,
  });

  final List<OpenPlaceResult> results;
  final LatLng currentPosition;
  final String Function(String distance) distanceAwayText;
  final String scrollHint;
  final ValueChanged<OpenPlaceResult> onSelectPlace;

  @override
  State<_LiveSuggestionPanel> createState() => _LiveSuggestionPanelState();
}

class _LiveSuggestionPanelState extends State<_LiveSuggestionPanel> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  @override
  void didUpdateWidget(covariant _LiveSuggestionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.results != widget.results) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.jumpTo(0);
        _updateScrollHint();
      });
    }
  }

  void _updateScrollHint() {
    if (!_scrollController.hasClients || !mounted) return;
    final shouldShow =
        _scrollController.position.maxScrollExtent > 4 &&
        _scrollController.offset <
            _scrollController.position.maxScrollExtent - 8;
    if (_showScrollHint != shouldShow) {
      setState(() => _showScrollHint = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollHint);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 32,
      shadowColor: Colors.black.withValues(alpha: 0.30),
      borderRadius: BorderRadius.circular(25),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 410),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFB8C9DA), width: 2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              thickness: 7,
              radius: const Radius.circular(10),
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  right: 12,
                  bottom: _showScrollHint ? 38 : 0,
                ),
                shrinkWrap: true,
                itemCount: widget.results.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 88,
                  color: Color(0xFFDCE4EC),
                ),
                itemBuilder: (context, index) {
                  final place = widget.results[index];
                  final distance =
                      Geolocator.distanceBetween(
                        widget.currentPosition.latitude,
                        widget.currentPosition.longitude,
                        place.position.latitude,
                        place.position.longitude,
                      ) /
                      1000;

                  return InkWell(
                    onTap: () => widget.onSelectPlace(place),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF2FC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF1769D3),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF20364D),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${place.address} · '
                                  '${widget.distanceAwayText(distance.toStringAsFixed(1))}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF718195),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.north_west_rounded,
                            color: Color(0xFF526A82),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_showScrollHint)
              Positioned(
                left: 0,
                right: 10,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F6FC),
                      border: Border(top: BorderSide(color: Color(0xFFD5E2EF))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.scrollHint.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF365A7D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_double_arrow_down_rounded,
                          color: Color(0xFF1769D3),
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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

  final String Function(String distance) distanceAwayText;

  final LatLng currentPosition;

  final List<OpenPlaceResult> searchResults;

  final bool isSearching;
  final bool showNoResult;

  final VoidCallback onSearchTap;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  final ValueChanged<OpenPlaceResult> onSelectPlace;

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
    required this.onSearch,
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
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: const Color(0xFF2E4B69), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
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
                color: Color(0xFF24374A),
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: searchHint,
                hintStyle: const TextStyle(
                  color: Color(0xFF8693A1),
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Container(
                  width: 64,
                  margin: const EdgeInsets.all(11),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8EFF6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 34,
                    color: Color(0xFF315F8C),
                  ),
                ),
                suffixIcon: SizedBox(
                  width: controller.text.isNotEmpty ? 122 : 68,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (controller.text.isNotEmpty)
                        IconButton(
                          onPressed: onClear,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 32,
                            color: Color(0xFF687786),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: const Color(0xFF315F8C),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: onSearch,
                            borderRadius: BorderRadius.circular(16),
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 29,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
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
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5DF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),

                  const SizedBox(width: 13),

                  Text(
                    searchingText,
                    style: const TextStyle(
                      color: Color(0xFF25394D),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
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
              margin: const EdgeInsets.only(top: 10),
              constraints: const BoxConstraints(maxHeight: 340),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF8FA3B7), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE0E5EA),
                  ),
                  itemBuilder: (context, index) {
                    final OpenPlaceResult item = searchResults[index];

                    final double distance =
                        Geolocator.distanceBetween(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          item.position.latitude,
                          item.position.longitude,
                        ) /
                        1000;

                    return Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          onSelectPlace(item);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 17,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFECEC),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFFD33A3A),
                                  size: 35,
                                ),
                              ),

                              const SizedBox(width: 17),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF24374A),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      item.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF657588),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      distanceAwayText(
                                        distance.toStringAsFixed(2),
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF798796),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Color(0xFF8793A0),
                                size: 27,
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
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE36A6A), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.13),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFC62828),
                    size: 30,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      noResultText,
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
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

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.place, required this.route});

  final OpenPlaceResult place;
  final OpenRouteResult route;

  @override
  Widget build(BuildContext context) {
    final distance = route.distanceMeters / 1000;
    final minutes = route.duration.inMinutes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Color(0xFF1769D3),
              size: 40,
            ),
          ),
          const SizedBox(width: 19),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF20364D),
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${distance.toStringAsFixed(1)} km  •  $minutes min',
                  style: const TextStyle(
                    color: Color(0xFF627286),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
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

class _MapErrorBanner extends StatelessWidget {
  const _MapErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0B4AF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFC43D35)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF96322C),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
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
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFCBD4DD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Zoom in button.
          _ZoomButton(icon: Icons.add_rounded, onTap: onZoomIn),

          // Current zoom display.
          Container(
            width: 62,
            margin: const EdgeInsets.symmetric(vertical: 7),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF293E55),
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              '${zoom}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          // Zoom out button.
          _ZoomButton(icon: Icons.remove_rounded, onTap: onZoomOut),

          const SizedBox(height: 8),

          // Reset map button.
          Tooltip(
            message: resetLabel,
            child: _ZoomButton(
              icon: Icons.center_focus_strong_rounded,
              onTap: onReset,
              backgroundColor: const Color(0xFFB58A33),
              foregroundColor: Colors.white,
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
    this.backgroundColor = const Color(0xFFF1F4F7),
    this.foregroundColor = const Color(0xFF2C435A),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: foregroundColor, size: 32),
        ),
      ),
    );
  }
}
