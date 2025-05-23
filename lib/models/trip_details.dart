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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'distance': distance,
      'co2Saved': co2Saved,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'duration': duration,
      'transportMode': transportMode.toString(),
      'calories': calories,
      'averageSpeed': averageSpeed,
      'emissions': emissions,
    };
  }

  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
      id: json['id'],
      date: DateTime.parse(json['date']),
      distance: json['distance'],
      co2Saved: json['co2Saved'],
      startLocation: json['startLocation'],
      endLocation: json['endLocation'],
      duration: json['duration'],
      transportMode: TransportMode.values.firstWhere(
        (e) => e.toString() == json['transportMode']
      ),
      calories: json['calories'],
      averageSpeed: json['averageSpeed'],
      emissions: Map<String, double>.from(json['emissions']),
    );
  }
}
