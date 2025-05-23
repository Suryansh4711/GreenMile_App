import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static const String _nameKey = 'user_name';
  static const String _imageKey = 'profile_image';

  String _userName = 'User';
  String? _profileImagePath;

  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;

  ProfileService() {
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString(_nameKey) ?? 'User';
      _profileImagePath = prefs.getString(_imageKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> updateName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, name);
      _userName = name;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating name: $e');
    }
  }

  Future<void> updateProfileImage(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_imageKey, path);
      _profileImagePath = path;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile image: $e');
    }
  }
}
