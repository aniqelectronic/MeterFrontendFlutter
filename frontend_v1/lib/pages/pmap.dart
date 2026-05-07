import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/pothers3.dart';

class PMAPPAGE extends StatefulWidget {
  const PMAPPAGE({super.key});

  @override
  State<PMAPPAGE> createState() => _PMAPPAGEState();
}

class _PMAPPAGEState extends State<PMAPPAGE> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  double _currentZoom = 14;
  final double _defaultZoom = 16;
  LatLng _currentPosition = LatLng(Config.latitude, Config.longitude);

  // For the pulse animation on the marker
  late AnimationController _pulseController;

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
    super.dispose();
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
      });

      _mapController.move(newLocation, 16);
    } catch (e) {
      debugPrint("Location not available: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          /// ================= BACKGROUND =================
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

          /// ================= TITLE =================
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.maptitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// ================= SUBTITLE =================
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.mapsubtitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 62, 62, 62),
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// ================= MAP CONTAINER =================
          Positioned(
            top: 380,
            left: 60,
            right: 60,
            bottom: 380,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.blue.shade900, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Stack(
                  children: [
                    FlutterMap(
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
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.frontend_v1.kiosk',
                        ),
                        MarkerLayer(
                          markers: [
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
                                      // Pulsing Ring
                                      Container(
                                        width: 40 * _pulseController.value + 40,
                                        height: 40 * _pulseController.value + 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue.withOpacity(1 - _pulseController.value),
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
                          ],
                        ),
                      ],
                    ),
                    
                    // "Touch to Explore" Indicator
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(loc.dragText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ================= ENHANCED ZOOM CONTROLS =================
          Positioned(
            right: 80,
            bottom: 450,
            child: Column(
              children: [
                _kioskZoomButton(Icons.add, "IN", () {
                  setState(() {
                    _currentZoom = (_currentZoom + 1).clamp(4, 18);
                    _mapController.move(_mapController.center, _currentZoom);
                  });
                }),
                const SizedBox(height: 15),
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
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                _kioskZoomButton(Icons.remove, "OUT", () {
                  setState(() {
                    _currentZoom = (_currentZoom - 1).clamp(4, 18);
                    _mapController.move(_mapController.center, _currentZoom);
                  });
                }),
                const SizedBox(height: 30),
                _kioskZoomButton(Icons.center_focus_strong, "RESET", () {
                  setState(() {
                    _currentZoom = _defaultZoom;
                    _mapController.move(_currentPosition, _defaultZoom);
                  });
                }, color: Colors.blue.shade800),
              ],
            ),
          ),

          /// ================= BACK BUTTON (Original) =================
          Positioned(
            bottom: 200,
            left: 300,
            right: 300,
            child: SizedBox(
              width: 300,
              height: 120,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const POTHERS3PAGE(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: Text(
                  AppLocalizations.of(context)!.backText,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          /// ================= FOOTER (Original) =================
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
        ],
      ),
    );
  }

  /// ================= KIOSK STYLE ZOOM BUTTON =================
  Widget _kioskZoomButton(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color != null ? Colors.white : Colors.black),
            Text(label, style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600,
              color: color != null ? Colors.white : Colors.black
            )),
          ],
        ),
      ),
    );
  }
}