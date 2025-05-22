import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/trip_details.dart';

class TripTrackingService {
  StreamController<Position> _locationController = StreamController<Position>.broadcast();
  StreamController<double> _distanceController = StreamController<double>.broadcast();
  StreamController<int> _durationController = StreamController<int>.broadcast();
  
  bool _isTracking = false;
  Timer? _durationTimer;
  double _currentDistance = 0;
  int _duration = 0;
  Position? _lastPosition;
  DateTime? _startTime;

  Stream<Position> get locationStream => _locationController.stream;
  Stream<double> get distanceStream => _distanceController.stream;
  Stream<int> get durationStream => _durationController.stream;
  bool get isTracking => _isTracking;

  Future<void> startTrip() async {
    if (_isTracking) return;

    _isTracking = true;
    _startTime = DateTime.now();
    _currentDistance = 0;
    _duration = 0;
    _lastPosition = null;

    // Start location tracking
    Geolocator.getPositionStream().listen(_handleNewPosition);

    // Start duration timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration++;
      _durationController.add(_duration);
    });
  }

  void _handleNewPosition(Position position) {
    if (!_isTracking) return;

    _locationController.add(position);

    if (_lastPosition != null) {
      final newDistance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      _currentDistance += newDistance;
      _distanceController.add(_currentDistance);
    }

    _lastPosition = position;
  }

  Future<TripDetails> stopTrip() async {
    _isTracking = false;
    _durationTimer?.cancel();

    final tripDetails = TripDetails(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _startTime ?? DateTime.now(),
      distance: _currentDistance / 1000, // Convert to kilometers
      co2Saved: _calculateCO2Saved(_currentDistance),
      startLocation: 'Current Location', // You might want to use geocoding here
      endLocation: 'Destination',
      duration: _duration ~/ 60, // Convert to minutes
      transportMode: TransportMode.walking,
      calories: _calculateCalories(_currentDistance, _duration),
      averageSpeed: (_currentDistance / 1000) / (_duration / 3600),
      emissions: {
        'NOx': 0.0,
        'SO₂': 0.0,
      },
    );

    _resetTracking();
    return tripDetails;
  }

  void _resetTracking() {
    _currentDistance = 0;
    _duration = 0;
    _lastPosition = null;
    _startTime = null;
  }

  double _calculateCO2Saved(double distanceInMeters) {
    // Simple calculation - can be made more sophisticated
    return (distanceInMeters / 1000) * 0.2;
  }

  double _calculateCalories(double distanceInMeters, int durationInSeconds) {
    // Simple calculation - can be made more sophisticated
    return (distanceInMeters / 1000) * 60;
  }

  void dispose() {
    _locationController.close();
    _distanceController.close();
    _durationController.close();
    _durationTimer?.cancel();
  }
}
