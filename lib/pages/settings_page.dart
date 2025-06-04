import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _darkMode = false; // Add dark mode state
  bool _locationEnabled = true;
  String _measurementUnit = 'Metric';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const textStyle = TextStyle(color: Colors.white);
    const subtitleStyle = TextStyle(color: Colors.white70);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: textStyle),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Privacy'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // General Settings Tab
          ListView(
            children: [
              ListTile(
                title: const Text('Dark Mode', style: textStyle),
                leading: const Icon(Icons.dark_mode, color: Colors.white),
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
              ),
              ListTile(
                title: const Text('Measurement Unit', style: textStyle),
                subtitle: Text(_measurementUnit, style: subtitleStyle),
                leading: const Icon(Icons.straighten, color: Colors.white),
                trailing: DropdownButton<String>(
                  value: _measurementUnit,
                  items: ['Metric', 'Imperial']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _measurementUnit = value);
                  },
                ),
              ),
            ],
          ),
          // Privacy Settings Tab
          ListView(
            children: [
              ListTile(
                title: const Text('Enable Notifications', style: textStyle),
                subtitle: const Text('Receive updates and reminders',
                    style: subtitleStyle),
                leading: const Icon(Icons.notifications, color: Colors.white),
                trailing: Switch(
                  value: _locationEnabled,
                  onChanged: (value) => setState(() => _locationEnabled = value),
                ),
              ),
              ListTile(
                title: const Text('Location Services', style: textStyle),
                subtitle: const Text('Track trips and calculate emissions',
                    style: subtitleStyle),
                leading: const Icon(Icons.location_on, color: Colors.white),
                trailing: Switch(
                  value: _locationEnabled,
                  onChanged: (value) => setState(() => _locationEnabled = value),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Privacy Policy', style: textStyle),
                leading: const Icon(Icons.security, color: Colors.white),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Terms of Service', style: textStyle),
                leading: const Icon(Icons.description, color: Colors.white),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
          // About Tab
          ListView(
            children: [
              const ListTile(
                title: Text('Version', style: textStyle),
                subtitle: Text('1.0.0', style: subtitleStyle),
                leading: Icon(Icons.info, color: Colors.white),
              ),
              const ListTile(
                title: Text('Developer', style: textStyle),
                subtitle: Text('GreenMile Team', style: subtitleStyle),
                leading: Icon(Icons.code, color: Colors.white),
              ),
              const Divider(),
              ListTile(
                title: const Text('Check for Updates', style: textStyle),
                leading: const Icon(Icons.update, color: Colors.white),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Send Feedback', style: textStyle),
                leading: const Icon(Icons.feedback, color: Colors.white),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Rate App', style: textStyle),
                leading: const Icon(Icons.star, color: Colors.white),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
