import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_details.dart';
import '../pages/login_page.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserDetails?> signIn(String email, String password) async {
    try {
      // Set language code to handle locale warning
      await _auth.setLanguageCode(WidgetsBinding.instance.window.locale.languageCode);

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;
      print('Login result: ${user?.uid}'); // Debug print

      if (user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Login failed - no user returned',
        );
      }

      return UserDetails.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}'); // Debug print
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    // Navigate to login page and remove all previous routes
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
