import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart';

class StepsService {
  static const String _stepsKey = 'daily_steps';
  static const double _stepThreshold = 12.0; // Accelerometer threshold for step
  static const int _debounceMs = 250; // Minimum time between steps
  
  int _steps = 0;
  DateTime? _lastStepTime;
  final _stepsController = StreamController<int>.broadcast();
  StreamSubscription? _accelerometerSubscription;

  Stream<int> get stepsStream => _stepsController.stream;

  StepsService() {
    _loadSteps();
    _initStepTracking();
  }

  Future<void> _loadSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('last_step_date');
    
    // Reset steps if it's a new day
    if (lastDate != DateTime.now().toIso8601String().split('T')[0]) {
      await prefs.setInt(_stepsKey, 0);
      await prefs.setString('last_step_date', DateTime.now().toIso8601String().split('T')[0]);
    }
    
    _steps = prefs.getInt(_stepsKey) ?? 0;
    _stepsController.add(_steps);
  }

  void _initStepTracking() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      // Calculate magnitude of acceleration
      final magnitude = Vector3(event.x, event.y, event.z).length;
      final now = DateTime.now();

      // Check if it's a step based on magnitude and time since last step
      if (magnitude > _stepThreshold && 
          (_lastStepTime == null || 
           now.difference(_lastStepTime!).inMilliseconds > _debounceMs)) {
        _lastStepTime = now;
        _steps++;
        _stepsController.add(_steps);
        _saveSteps();
      }
    });
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepsKey, _steps);
  }

  void resetSteps() {
    _steps = 0;
    _stepsController.add(_steps);
    _saveSteps();
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _stepsController.close();
  }
}
