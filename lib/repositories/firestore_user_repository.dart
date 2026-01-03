import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_study_buddy/models/user.dart';

class FirestoreUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _usersCollection = 'users';

  /// Gets users collection reference
  CollectionReference<Map<String, dynamic>> get _usersRef => _firestore.collection(_usersCollection);
  
  Future<void> saveUser(User user) async {
    try {
      await _usersRef.doc(user.id).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User?> getUser(String id) async {
    try {
      final doc = await _usersRef.doc(id).get();
      if (!doc.exists) return null;
      return User.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

}