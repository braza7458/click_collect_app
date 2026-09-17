import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads and writes a signed-in user's profile document
/// (`users/{uid}`) — name, contact info, favorite restaurant, consents, and
/// loyalty point balance. Guests never get one of these: they have no
/// account to attach it to.
class UserRepository {
  const UserRepository._();

  static Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return snapshot.data();
  }

  static Future<void> createProfile(String uid, Map<String, dynamic> data) =>
      FirebaseFirestore.instance.collection('users').doc(uid).set(data);

  static Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      FirebaseFirestore.instance.collection('users').doc(uid).set(data, SetOptions(merge: true));

  /// Atomically adds [delta] to the user's point balance (negative to
  /// spend) and returns the resulting balance.
  static Future<int> adjustPoints(String uid, int delta) {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    return FirebaseFirestore.instance.runTransaction<int>((tx) async {
      final snapshot = await tx.get(ref);
      final current = (snapshot.data()?['points'] as num?)?.toInt() ?? 0;
      final next = current + delta;
      tx.update(ref, {'points': next});
      return next;
    });
  }
}
