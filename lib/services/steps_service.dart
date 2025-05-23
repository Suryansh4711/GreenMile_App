import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class StepsService {
  final _stepsController = StreamController<int>.broadcast();
  StreamSubscription? _accelerometerSubscription;
  int _steps = 0;
  DateTime? _lastStepTime;
  List<double> _accelValues = [];
  static const int ACCEL_RING_SIZE = 50;
  static const double STEP_THRESHOLD = 1.0; // Lower threshold
  static const double ALPHA = 0.8; // Low-pass filter constant
  double _lastFilteredValue = 0;
  bool _isStepUp = false;

  Stream<int> get stepsStream => _stepsController.stream;
  int get steps => _steps;

  void startTracking() {
    try {
      _accelerometerSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _processAccelerometerData(event);
        },
        onError: (error) {
          print('Error reading accelerometer: $error');
        },
      );
    } catch (e) {
      print('Failed to initialize accelerometer: $e');
    }
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    final double magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );

    // Apply low-pass filter
    _lastFilteredValue = ALPHA * _lastFilteredValue + (1 - ALPHA) * magnitude;

    if (_lastFilteredValue > STEP_THRESHOLD && !_isStepUp) {
      _isStepUp = true;
    } else if (_lastFilteredValue < STEP_THRESHOLD && _isStepUp) {
      _isStepUp = false;
      final now = DateTime.now();
      if (_lastStepTime == null || 
          now.difference(_lastStepTime!).inMilliseconds > 250) {
        _steps++;
        _lastStepTime = now;
        _stepsController.add(_steps);
      }
    }
  }

  void resetSteps() {
    _steps = 0;
    _stepsController.add(_steps);
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _stepsController.close();
  }
}
