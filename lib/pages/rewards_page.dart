import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  Widget _buildBadgeCard(BuildContext context, String title, String description, IconData icon, bool isUnlocked) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isUnlocked ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black : Colors.grey,
              ),
            ),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, String title, String code, String expiry) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.local_offer, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Code: $code',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Expires: $expiry',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
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
          title: const Text('Rewards'),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Badges'),
              Tab(text: 'Coupons'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Badges Tab
            GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildBadgeCard(
                  context,
                  'Early Bird',
                  'Complete 5 morning trips',
                  Icons.wb_sunny,
                  true,
                ),
                _buildBadgeCard(
                  context,
                  'Green Guardian',
                  'Save 100kg CO₂',
                  Icons.eco,
                  true,
                ),
                _buildBadgeCard(
                  context,
                  'Marathon Walker',
                  'Walk 100,000 steps',
                  Icons.directions_walk,
                  false,
                ),
                _buildBadgeCard(
                  context,
                  'Earth Saver',
                  'Complete 50 green trips',
                  Icons.public,
                  false,
                ),
              ],
            ),
            // Coupons Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCouponCard(
                  context,
                  'Free Bus Ride',
                  'GOGREEN23',
                  '31 Dec 2023',
                ),
                const SizedBox(height: 12),
                _buildCouponCard(
                  context,
                  '50% Off Bike Share',
                  'BIKE50',
                  '15 Dec 2023',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
