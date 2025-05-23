import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';

class ProfileDropdown extends StatelessWidget {
  const ProfileDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<ProfileService>(context);
    
    return PopupMenuButton(
      offset: const Offset(0, 50),
      child: CircleAvatar(
        backgroundImage: profileService.profileImagePath != null
            ? FileImage(File(profileService.profileImagePath!))
            : null,
        child: profileService.profileImagePath == null
            ? Text(profileService.userName[0].toUpperCase())
            : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(profileService.userName),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          ),
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
          onTap: () {
            // Handle logout
          },
        ),
      ],
    );
  }
}
