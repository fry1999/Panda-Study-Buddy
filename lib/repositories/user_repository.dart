import 'package:hive/hive.dart';
import 'package:panda_study_buddy/models/user.dart';

/// Repository for managing user data
class UserRepository {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'current_user_id';
  
  /// Get the users box
  Box<User> get _box => Hive.box<User>(_boxName);
  
  /// Get the app data box for storing current user ID
  Box get _appDataBox => Hive.box('app_data');
  
  /// Save a user
  Future<void> saveUser(User user) async {
    await _box.put(user.id, user);
  }
  
  /// Get a user by ID
  User? getUser(String id) {
    return _box.get(id);
  }
  
  /// Get all users
  List<User> getAllUsers() {
    return _box.values.toList();
  }
  
  /// Get current user ID
  String? getCurrentUserId() {
    return _appDataBox.get(_currentUserKey) as String?;
  }
  
  /// Set current user ID
  Future<void> setCurrentUserId(String userId) async {
    await _appDataBox.put(_currentUserKey, userId);
  }
  
  /// Get current user
  User? getCurrentUser() {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    return getUser(userId);
  }
  
  /// Create or update current user
  Future<User> createOrUpdateCurrentUser({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    User? currentUser = getCurrentUser();
    
    if (currentUser == null) {
      // Create new user
      currentUser = User(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name ?? 'User',
        email: email ?? '',
        createdAt: DateTime.now(),
        photoUrl: photoUrl,
      );
      await saveUser(currentUser);
      await setCurrentUserId(currentUser.id);
    } else {
      // Update existing user
      if (name != null) currentUser.name = name;
      if (email != null) currentUser.email = email;
      await currentUser.save();
    }
    
    return currentUser;
  }
  
  /// Update user's bamboo count
  Future<void> updateBamboo(String userId, int bambooToAdd) async {
    final user = getUser(userId);
    if (user != null) {
      user.addBamboo(bambooToAdd);
      await user.save();
    }
  }
  
  /// Update user's streak
  Future<void> updateStreak(String userId, int newStreak) async {
    final user = getUser(userId);
    if (user != null) {
      user.currentStreak = newStreak;
      await user.save();
    }
  }
  
  /// Increment user's streak
  Future<void> incrementStreak(String userId) async {
    final user = getUser(userId);
    if (user != null) {
      user.incrementStreak();
      await user.save();
    }
  }
  
  /// Reset user's streak
  Future<void> resetStreak(String userId) async {
    final user = getUser(userId);
    if (user != null) {
      user.resetStreak();
      await user.save();
    }
  }
  
  /// Set user's partner
  Future<void> setPartner(String userId, String? partnerId, String? roomCode) async {
    final user = getUser(userId);
    if (user != null) {
      user.partnerId = partnerId;
      user.roomCode = roomCode;
      await user.save();
    }
  }
  
  /// Update last session date
  Future<void> updateLastSessionDate(String userId, DateTime date) async {
    final user = getUser(userId);
    if (user != null) {
      user.lastSessionDate = date;
      await user.save();
    }
  }
  
  /// Delete a user
  Future<void> deleteUser(String id) async {
    await _box.delete(id);
  }
  
  /// Clear current user (logout)
  Future<void> clearCurrentUser() async {
    await _appDataBox.delete(_currentUserKey);
  }
  
  /// Check if user is logged in
  bool isLoggedIn() {
    return getCurrentUserId() != null;
  }
}
