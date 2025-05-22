import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _buildStatCard(String title, String value, IconData icon, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person_outline, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Guest User',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null
                      ? Text(
                          user.displayName?[0].toUpperCase() ?? user.email![0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName ?? user.email ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Green Warrior',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildStatCard('Total Trips', '156', Icons.directions_car, theme),
                _buildStatCard('CO₂ Saved', '423kg', Icons.eco, theme),
                _buildStatCard('Green Score', '92', Icons.stars, theme),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Account Settings'),
            leading: const Icon(Icons.settings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            title: const Text('My Achievements'),
            leading: const Icon(Icons.emoji_events),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Trip History'),
            leading: const Icon(Icons.history),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: user != null
          ? _buildUserProfile(context, user, theme)
          : _buildGuestView(context, theme),
    );
  }
}
