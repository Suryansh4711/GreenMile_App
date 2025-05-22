enum TransportMode {
  walking,
  cycling,
  bus,
  train,
  car
}

class TripDetails {
  final String id;
  final DateTime date;
  final double distance;
  final double co2Saved;
  final String startLocation;
  final String endLocation;
  final int duration;
  final TransportMode transportMode;
  final double calories;
  final double averageSpeed;
  final Map<String, double> emissions;

  TripDetails({
    required this.id,
    required this.date,
    required this.distance,
    required this.co2Saved,
    required this.startLocation,
    required this.endLocation,
    required this.duration,
    required this.transportMode,
    required this.calories,
    required this.averageSpeed,
    required this.emissions,
  });
}
