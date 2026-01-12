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

  /// Ensure user has all required fields (for migration of existing users)
  Future<void> ensureUserFields(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) return;
      
      final data = doc.data();
      if (data == null) return;
      
      final Map<String, dynamic> updates = {};
      
      // Ensure currentStreak exists
      if (!data.containsKey('currentStreak')) {
        updates['currentStreak'] = 0;
      }
      
      // Ensure totalBamboo exists
      if (!data.containsKey('totalBamboo')) {
        updates['totalBamboo'] = 0;
      }
      
      if (updates.isNotEmpty) {
        await _usersRef.doc(userId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to ensure user fields: $e');
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

  /// Stream user data (real-time updates)
  Stream<User?> streamUser(String id) {
    return _usersRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return User.fromJson(doc.data()!);
    });
  }

  /// Update user's bamboo count
  Future<void> updateBambooCount(String id, int bambooToAdd) async {
    try {
      await _usersRef.doc(id).update({
        'totalBamboo': FieldValue.increment(bambooToAdd),
      });
    } catch (e) {
      throw Exception('Failed to update bamboo count: $e');
    }
  }

  /// Update user's streak
  Future<void> updateStreak(String id, int newStreak) async {
    try {
      await _usersRef.doc(id).update({
        'currentStreak': newStreak,
      });
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }

  /// Increment user's streak
  Future<void> incrementStreak(String id) async {
    try {
      await _usersRef.doc(id).update({
        'currentStreak': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment streak: $e');
    }
  }

  /// Reset user's streak
  Future<void> resetStreak(String userId) async {
    try {
      await _usersRef.doc(userId).update({
        'currentStreak': 0,
      });
    } catch (e) {
      throw Exception('Failed to reset streak: $e');
    }
  }

  /// Set user's partner
  Future<void> setPartner(String userId, String? partnerId, String? roomCode) async {
    try {
      await _usersRef.doc(userId).update({
        'partnerId': partnerId,
        'roomCode': roomCode,
      });
    } catch (e) {
      throw Exception('Failed to set partner: $e');
    }
  }

  /// Update last session date
  Future<void> updateLastSessionDate(String userId, DateTime date) async {
    try {
      await _usersRef.doc(userId).update({
        'lastSessionDate': Timestamp.fromDate(date),
      });
    } catch (e) {
      throw Exception('Failed to update last session date: $e');
    }
  }

  /// Get partner info
  Future<User?> getPartnerInfo(String partnerId) async {
    return await getUser(partnerId);
  }

  /// Stream partner info
  Stream<User?> streamPartner(String partnerId) {
    return streamUser(partnerId);
  }
}