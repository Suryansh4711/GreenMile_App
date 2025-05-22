import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import '../models/trip_details.dart';

class DataService extends ChangeNotifier {
  List<TripDetails> _trips = [];
  double _totalDistance = 0;
  int _totalSteps = 0;
  double _totalCO2Saved = 0;

  List<TripDetails> get trips => _trips;
  double get totalDistance => _totalDistance;
  int get totalSteps => _totalSteps;
  double get totalCO2Saved => _totalCO2Saved;
  int get totalTrips => _trips.length;

  final _stepsController = StreamController<int>.broadcast();
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;

  DataService() {
    _initializeMockData();
    initPedometer();
  }

  void _initializeMockData() {
    _trips = [
      TripDetails(
        id: '1',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        distance: 3.8,
        co2Saved: 0.76,
        startLocation: 'Home, Jubilee Hills',
        endLocation: 'Hitech City Metro Station',
        duration: 22,
        transportMode: TransportMode.walking,
        calories: 187,
        averageSpeed: 4.5,
        emissions: {
          'NOx': 8.2,
          'SO₂': 5.1,
        },
      ),
      TripDetails(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        distance: 12.5,
        co2Saved: 2.85,
        startLocation: 'Office, Mindspace',
        endLocation: 'Gachibowli Stadium',
        duration: 45,
        transportMode: TransportMode.cycling,
        calories: 425,
        averageSpeed: 16.7,
        emissions: {
          'NOx': 15.3,
          'SO₂': 9.8,
        },
      ),
    ];
    _updateStats();
  }

  void addTrip(TripDetails trip) {
    _trips.insert(0, trip);
    _updateStats();
    notifyListeners();
  }

  void _updateStats() {
    _totalDistance = _trips.fold(0, (sum, trip) => sum + trip.distance);
    _totalCO2Saved = _trips.fold(0, (sum, trip) => sum + trip.co2Saved);
  }

  void initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountSubscription = _stepCountStream?.listen(
      (StepCount event) {
        _totalSteps = event.steps;
        _stepsController.add(_totalSteps);
        notifyListeners();
      },
      onError: (error) {
        print("Error getting step count: $error");
      },
    );
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    _stepsController.close();
    super.dispose();
  }
}
