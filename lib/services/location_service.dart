import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'steps_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;
  final StepsService _stepsService = StepsService();
  
  double _totalDistance = 0.0;
  int _currentSteps = 0;
  Position? _lastPosition;
  
  final _distanceController = StreamController<double>.broadcast();
  
  Stream<double> get distanceStream => _distanceController.stream;
  Stream<int> get stepsStream => _stepsService.stepsStream;
  
  static const String _lastResetKey = 'last_reset_date';
  DateTime _lastResetDate = DateTime.now();
  
  Future<void> _checkAndResetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString(_lastResetKey);
    
    if (lastResetStr != null) {
      _lastResetDate = DateTime.parse(lastResetStr);
    }
    
    final now = DateTime.now();
    if (now.day != _lastResetDate.day || now.month != _lastResetDate.month || now.year != _lastResetDate.year) {
      await _resetCounters(now, prefs);
    }
  }

  Future<void> _resetCounters(DateTime now, SharedPreferences prefs) async {
    _currentSteps = 0;
    _totalDistance = 0.0;
    _lastResetDate = now;
    
    await prefs.setString(_lastResetKey, now.toIso8601String());
    
    _stepsService.resetSteps();
    _distanceController.add(_totalDistance);
  }

  Future<void> startTracking() async {
    await _checkPermissions();
    await _checkAndResetDaily();
    
    // Set up periodic check for day change
    Timer.periodic(const Duration(minutes: 1), (_) => _checkAndResetDaily());
    
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_onPositionUpdate);

    _stepsService.startTracking();
  }
  
  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }
  }

  void _onPositionUpdate(Position position) {
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      _totalDistance += distance;
      _distanceController.add(_totalDistance);
    }
    _lastPosition = position;
  }

  Future<double> calculateDistance(String origin, String destination) async {
    const apiKey = 'AIzaSyAuMBKZbvqPDnOJraNHj5DugOGu9QEb8Gg';
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?'
        'origins=${Uri.encodeComponent(origin)}&'
        'destinations=${Uri.encodeComponent(destination)}&'
        'mode=driving&key=$apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final element = data['rows'][0]['elements'][0];
          if (element['status'] == 'OK') {
            final distance = element['distance']['value'];
            return distance / 1000;
          }
        }
      }
      throw Exception('Invalid response from Distance Matrix API');
    } catch (e) {
      throw Exception('Failed to calculate distance: $e');
    }
  }

  Future<List<Map<String, String>>> searchPlaces(String query) async {
    const apiKey = 'AIzaSyAuMBKZbvqPDnOJraNHj5DugOGu9QEb8Gg';
    if (query.isEmpty) return [];
    
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=${Uri.encodeComponent(query)}&key=$apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['predictions'] as List).map((prediction) {
            return {
              'placeId': prediction['place_id'] as String,
              'description': prediction['description'] as String,
            };
          }).toList();
        }
        if (data['status'] == 'ZERO_RESULTS') {
          return [];
        }
        throw Exception('Places API error: ${data['status']}');
      }
      throw Exception('Failed to fetch places: ${response.statusCode}');
    } catch (e) {
      throw Exception('Places search failed: $e');
    }
  }

  Future<Map<String, String>> getCurrentLocation(BuildContext context) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      const apiKey = 'AIzaSyAuMBKZbvqPDnOJraNHj5DugOGu9QEb8Gg';
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?'
        'latlng=${position.latitude},${position.longitude}&'
        'key=$apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final address = data['results'][0]['formatted_address'];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current location detected'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          return {
            'placeId': data['results'][0]['place_id'],
            'description': address,
          };
        }
      }
      throw Exception('Failed to get address');
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  Future<Map<String, String>> getAddressFromLatLng(double lat, double lng) async {
    const apiKey = 'AIzaSyAuMBKZbvqPDnOJraNHj5DugOGu9QEb8Gg';
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?'
        'latlng=$lat,$lng&key=$apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final address = data['results'][0]['formatted_address'];
          return {
            'placeId': data['results'][0]['place_id'],
            'description': address,
          };
        }
      }
      throw Exception('Failed to get address');
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }

  void dispose() {
    _positionStream?.cancel();
    _distanceController.close();
    _stepsService.dispose();
  }
}
