import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late Stream<StepCount> _stepCountStream;
  
  double _totalDistance = 0.0;
  int _initialSteps = 0;
  int _currentSteps = 0;
  bool _isFirstStepCount = true;
  Position? _lastPosition;
  
  final _distanceController = StreamController<double>.broadcast();
  final _stepsController = StreamController<int>.broadcast();
  
  Stream<double> get distanceStream => _distanceController.stream;
  Stream<int> get stepsStream => _stepsController.stream;
  
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
      // Reset counters
      _currentSteps = 0;
      _totalDistance = 0.0;
      _lastResetDate = now;
      
      // Update stored reset date
      await prefs.setString(_lastResetKey, now.toIso8601String());
      
      // Notify listeners of reset
      _stepsController.add(_currentSteps);
      _distanceController.add(_totalDistance);
    }
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

    _initPedometer();
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

  void _initPedometer() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _pedestrianStatusStream.listen(
      (PedestrianStatus status) {
        // Handle walking status changes
        print('Walking status: ${status.status}');
      },
      onError: (error) {
        print('Pedometer status error: $error');
      },
    );

    _stepCountStream.listen(
      (StepCount event) {
        if (_isFirstStepCount) {
          _isFirstStepCount = false;
          _initialSteps = event.steps;
        }
        _currentSteps = event.steps - _initialSteps;
        _stepsController.add(_currentSteps);
      },
      onError: (error) {
        print('Pedometer count error: $error');
      },
    );
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

  void dispose() {
    _positionStream?.cancel();
    _distanceController.close();
    _stepsController.close();
  }
}
