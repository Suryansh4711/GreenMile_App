import 'package:firebase_auth/firebase_auth.dart';

class UserDetails {
  final String uid;
  final String email;
  final String? displayName;

  const UserDetails({
    required this.uid,
    required this.email,
    this.displayName,
  });

  factory UserDetails.fromFirebaseUser(User user) {
    return UserDetails(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }
}
