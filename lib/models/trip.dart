class Trip {
  final String id;
  final DateTime date;
  final double distance;
  final double co2Saved;
  final String startLocation;
  final String endLocation;
  final int duration; // in minutes

  Trip({
    required this.id,
    required this.date,
    required this.distance,
    required this.co2Saved,
    required this.startLocation,
    required this.endLocation,
    required this.duration,
  });
}
