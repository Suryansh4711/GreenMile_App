class UserData {
  final String uid;
  final double totalCarbonSaved;
  final List<String> badges;
  final int totalTrips;
  final List<String> achievements;

  UserData({
    required this.uid,
    this.totalCarbonSaved = 0.0,
    this.badges = const [],
    this.totalTrips = 0,
    this.achievements = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'totalCarbonSaved': totalCarbonSaved,
      'badges': badges,
      'totalTrips': totalTrips,
      'achievements': achievements,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      uid: map['uid'] ?? '',
      totalCarbonSaved: map['totalCarbonSaved']?.toDouble() ?? 0.0,
      badges: List<String>.from(map['badges'] ?? []),
      totalTrips: map['totalTrips']?.toInt() ?? 0,
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }
}
