import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../models/trip_details.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];
  double _distance = 0;
  String _duration = "00:00:00";
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  DateTime? _startTime;

  final Set<Marker> _markers = {};
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _endIcon;
  MapType _currentMapType = MapType.normal;

  CameraPosition _defaultLocation = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 15,
  );

  bool _isTracking = false;
  TransportMode? _selectedMode;
  String _startLocation = '';
  String _endLocation = '';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('Location permissions are permanently denied');
        return;
      }

      _getCurrentLocation();
    } catch (e) {
      developer.log('Error requesting location permission: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _defaultLocation = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );
      });

      if (_controller.isCompleted) {
        final controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(_defaultLocation));
      }

      developer.log('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      developer.log('Error getting location: $e');
    }
  }

  Future<void> _loadCustomMarkers() async {
    _startIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/start_marker.png',
    );
    _endIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/end_marker.png',
    );
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _startTime = DateTime.now();
    });

    // Start duration timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final duration = DateTime.now().difference(_startTime!);
        setState(() {
          _duration = _formatDuration(duration);
        });
      }
    });

    // Start location tracking
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        if (_routePoints.isNotEmpty) {
          _distance += Geolocator.distanceBetween(
            _routePoints.last.latitude,
            _routePoints.last.longitude,
            point.latitude,
            point.longitude,
          );
        }
        _routePoints.add(point);
        _updatePolylines();
      });
    });
  }

  void _stopTracking() async {
    _positionStream?.cancel();
    _timer?.cancel();
    setState(() => _isTracking = false);

    // Get end location
    final locationService = Provider.of<LocationService>(context, listen: false);
    final endLoc = await locationService.getCurrentLocation(context);
    _endLocation = endLoc['description'] ?? '';

    // Calculate duration
    final duration = DateTime.now().difference(_startTime!);
    final intDuration = duration.inMinutes;

    // Show transport mode selection
    _showTransportModeDialog(intDuration);
  }

  void _showTransportModeDialog(int duration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Select Transport Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TransportMode.values.map((mode) =>
            ListTile(
              leading: Icon(_getTransportIcon(mode)),
              title: Text(_getTransportName(mode)),
              onTap: () {
                _selectedMode = mode;
                _saveTrip(duration);
                Navigator.pop(context);
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

  Future<void> _saveTrip(int duration) async {
    if (_selectedMode == null) return;

    // Calculate emissions
    final emissions = _calculateEmissions(_selectedMode!, _distance);
    
    final co2Saved = _selectedMode == TransportMode.walking || 
                     _selectedMode == TransportMode.cycling ? 
                     (_distance / 1000) * 0.2 : 0.0; // 0.2 kg CO2 per km saved

    final trip = TripDetails(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _startTime ?? DateTime.now(),
      distance: _distance / 1000, // Convert to kilometers
      co2Saved: co2Saved,
      startLocation: _startLocation,
      endLocation: _endLocation,
      duration: duration,
      transportMode: _selectedMode!,
      calories: _selectedMode == TransportMode.walking ? duration * 4 :
               _selectedMode == TransportMode.cycling ? duration * 7 : 0.0,
      averageSpeed: duration > 0 ? (_distance / 1000) / (duration / 60) : 0.0,
      emissions: emissions,
    );

    final dataService = Provider.of<DataService>(context, listen: false);
    await dataService.addTrip(trip);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Map<String, double> _calculateEmissions(TransportMode mode, double distance) {
    // Emission factors in g/km
    final emissionFactors = {
      TransportMode.car: {'co2': 120.0, 'nox': 0.4, 'so2': 0.1},
      TransportMode.bus: {'co2': 80.0, 'nox': 0.3, 'so2': 0.08},
      TransportMode.train: {'co2': 40.0, 'nox': 0.1, 'so2': 0.05},
      TransportMode.walking: {'co2': 0.0, 'nox': 0.0, 'so2': 0.0},
      TransportMode.cycling: {'co2': 0.0, 'nox': 0.0, 'so2': 0.0},
    };

    final factors = emissionFactors[mode] ?? {'co2': 0.0, 'nox': 0.0, 'so2': 0.0};
    return {
      'NOx': factors['nox']! * (distance / 1000), // Convert to km
      'SO₂': factors['so2']! * (distance / 1000),
    };
  }

  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return Icons.directions_walk;
      case TransportMode.cycling:
        return Icons.directions_bike;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.train:
        return Icons.train;
      case TransportMode.car:
        return Icons.directions_car;
    }
  }

  String _getTransportName(TransportMode mode) {
    return mode.toString().split('.').last[0].toUpperCase() +
           mode.toString().split('.').last.substring(1);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _updatePolylines() {
    setState(() {
      _polylines.clear();
      _markers.clear();

      if (_routePoints.isNotEmpty) {
        // Add start marker
        _markers.add(Marker(
          markerId: const MarkerId('start'),
          position: _routePoints.first,
          icon: _startIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Start Point'),
        ));

        // Add end marker for current position
        _markers.add(Marker(
          markerId: const MarkerId('current'),
          position: _routePoints.last,
          icon: _endIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Current Position',
            snippet: 'Distance: ${(_distance / 1000).toStringAsFixed(2)} km',
          ),
        ));

        // Add route polyline
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          points: _routePoints,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _defaultLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              developer.log('Map created');
              if (!_controller.isCompleted) {
                _controller.complete(controller);
                _getCurrentLocation();
              }
            },
            polylines: _polylines,
            markers: _markers,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Distance', '${(_distance / 1000).toStringAsFixed(2)} km'),
                        _buildStatColumn('Duration', _duration),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () {
                            setState(() {
                              _currentMapType = _currentMapType == MapType.normal
                                  ? MapType.satellite
                                  : MapType.normal;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildTrackingButton(),
    );
  }

  Widget _buildTrackingButton() {
    return FloatingActionButton.extended(
      onPressed: _isTracking ? _stopTracking : _startTracking,
      label: Text(
        _isTracking ? 'Stop Tracking' : 'Start Tracking',
        style: const TextStyle(color: Color.fromARGB(255, 17, 7, 7)),
      ),
      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
      backgroundColor: _isTracking
          ? Colors.red.withOpacity(0.9)
          : Colors.green.withOpacity(0.9),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
