import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_details.dart';
import 'steps_service.dart';

class DataService extends ChangeNotifier {
  static const String _tripsKey = 'saved_trips';
  final StepsService _stepsService = StepsService();
  int _totalSteps = 0;
  List<TripDetails> _trips = [];
  double _totalDistance = 0;
  double _totalCO2Saved = 0;

  List<TripDetails> get trips => _trips;
  double get totalDistance => _totalDistance;
  int get totalSteps => _totalSteps;
  double get totalCO2Saved => _totalCO2Saved;
  int get totalTrips => _trips.length;

  Stream<int> get stepsStream => _stepsService.stepsStream;

  DataService() {
    _initializeStepTracking();
    _loadTrips();
  }

  void _initializeStepTracking() {
    _stepsService.startTracking();
    _stepsService.stepsStream.listen((steps) {
      _totalSteps = steps;
      notifyListeners();
    });
  }

  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = prefs.getStringList(_tripsKey) ?? [];
    _trips = tripsJson
        .map((json) => TripDetails.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = _trips
        .map((trip) => jsonEncode(trip.toJson()))
        .toList();
    await prefs.setStringList(_tripsKey, tripsJson);
  }

  Future<void> addTrip(TripDetails trip) async {
    _trips.insert(0, trip);
    await _saveTrips();
    _updateStats();
    notifyListeners();
  }

  void deleteTrip(String tripId) {
    _trips.removeWhere((trip) => trip.id == tripId);
    _updateStats();
    notifyListeners();
    _saveTrips(); // If you're using local storage
  }

  void _updateStats() {
    _totalDistance = _trips.fold(0, (sum, trip) => sum + trip.distance);
    _totalCO2Saved = _trips.fold(0, (sum, trip) => sum + trip.co2Saved);
  }

  @override
  void dispose() {
    _stepsService.dispose();
    super.dispose();
  }
}
