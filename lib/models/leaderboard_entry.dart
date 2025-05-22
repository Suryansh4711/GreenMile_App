class LeaderboardEntry {
  final String userId;
  final String userName;
  final String avatarUrl;
  final int steps;
  final double distance;
  final int greenScore;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.avatarUrl = '',
    required this.steps,
    required this.distance,
    required this.greenScore,
  });
}
