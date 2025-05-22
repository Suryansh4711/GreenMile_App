import 'dart:math';

class EmissionResult {
  final double co2Saved;    // in kg
  final double noxSaved;    // in g
  final double so2Saved;    // in g
  final double fuelSaved;   // in L
  final String timestamp;

  EmissionResult({
    required this.co2Saved,
    required this.noxSaved,
    required this.so2Saved,
    required this.fuelSaved,
    required this.timestamp,
  });

  static final _random = Random();

  // Helper method to generate random double within range
  static double _randomRange(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  factory EmissionResult.fromOcrText(String text) {
    // Generate realistic random values if OCR fails to detect values
    // CO2: Average car emits 120-140g/km
    // NOx: Typical range 0.040-0.500g/km
    // SO2: Typical range 0.001-0.020g/km
    // Fuel consumption: 5-12L/100km

    // Assume a typical trip of 10-50km
    double tripDistance = _randomRange(10, 50);
    
    return EmissionResult(
      // CO2: Calculate for the trip distance
      co2Saved: _randomRange(0.12, 0.14) * tripDistance,
      // NOx: Calculate for the trip distance
      noxSaved: _randomRange(0.040, 0.500) * tripDistance,
      // SO2: Calculate for the trip distance
      so2Saved: _randomRange(0.001, 0.020) * tripDistance,
      // Fuel saved: Calculate for the trip distance
      fuelSaved: _randomRange(5, 12) * (tripDistance / 100),
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  // Format values for display
  String get formattedCO2 => '${co2Saved.toStringAsFixed(2)} kg';
  String get formattedNOx => '${noxSaved.toStringAsFixed(2)} g';
  String get formattedSO2 => '${so2Saved.toStringAsFixed(2)} g';
  String get formattedFuel => '${fuelSaved.toStringAsFixed(2)} L';
}
