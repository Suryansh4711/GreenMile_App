import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  Widget _buildChallengeCard(BuildContext context, String title, String description, String progress, IconData icon, {String? badgeImagePath}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                badgeImagePath != null
                    ? Image.asset(
                        badgeImagePath,
                        width: 24,
                        height: 24,
                      )
                    : Icon(icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: double.parse(progress.replaceAll('%', '')) / 100,
              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              progress,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, LeaderboardEntry entry, int rank) {
    final theme = Theme.of(context);
    final List<String> names = [
      'Alex Green', 'Sam Echo', 'Chris Miles',
      'Jordan Rivers', 'Taylor Woods', 'Morgan Parks',
      'Casey Grove', 'Riley Forest', 'Quinn Nature',
      'Jamie Earth'
    ];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          names[rank - 1][0],
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3 ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            names[rank - 1],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${entry.steps} steps • ${entry.distance.toStringAsFixed(1)} km',
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${entry.greenScore} pts',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Challenges'),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Daily Challenges'),
              Tab(text: 'Leaderboard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Daily Challenges Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildChallengeCard(
                  context,
                  'Step Master',
                  'Walk 10,000 steps today',
                  '65%',
                  Icons.directions_walk,
                ),
                const SizedBox(height: 12),
                _buildChallengeCard(
                  context,
                  'Green Commuter',
                  'Complete 5 eco-friendly trips',
                  '40%',
                  Icons.eco,
                ),
                const SizedBox(height: 12),
                _buildChallengeCard(
                  context,
                  'Distance Champion',
                  'Travel 20km using green transport',
                  '75%',
                  Icons.map,
                ),
              ],
            ),
            // Leaderboard Tab
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 10, // Example data
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final entry = LeaderboardEntry(
                  userId: 'user$index',
                  userName: 'User ${index + 1}',
                  steps: (10000 - (index * 500)).clamp(0, 10000),
                  distance: (20.0 - (index * 1.5)).clamp(0, 20),
                  greenScore: (100 - (index * 8)).clamp(0, 100),
                );
                return _buildLeaderboardItem(context, entry, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
