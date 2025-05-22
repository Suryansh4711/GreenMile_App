import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNewUser(String uid) async {
    final userData = UserData(uid: uid);
    await _firestore.collection('users').doc(uid).set(userData.toMap());
  }

  Future<UserData?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserData.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserCarbonSaved(String uid, double amount) async {
    await _firestore.collection('users').doc(uid).update({
      'totalCarbonSaved': FieldValue.increment(amount),
      'totalTrips': FieldValue.increment(1),
    });
  }

  Future<void> addBadge(String uid, String badge) async {
    await _firestore.collection('users').doc(uid).update({
      'badges': FieldValue.arrayUnion([badge]),
    });
  }

  Stream<UserData> userDataStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserData.fromMap(doc.data()!));
  }
}
