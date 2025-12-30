import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/models/user.dart';
import 'package:panda_study_buddy/repositories/user_repository.dart';
import 'package:uuid/uuid.dart';

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Auth notifier
class AuthNotifier extends StateNotifier<User?> {
  final UserRepository repository;
  final Ref ref;

  AuthNotifier(this.repository, this.ref) : super(null) {
    _loadCurrentUser();
  }

  /// Load current user from storage
  void _loadCurrentUser() {
    final user = repository.getCurrentUser();
    state = user;
  }

  /// Login with email and password (placeholder)
  Future<bool> login(String email, String password) async {
    // Placeholder login logic
    // In a real app, this would authenticate with a backend
    
    // For now, create or get a user
    final user = await repository.createOrUpdateCurrentUser(
      email: email,
      name: email.split('@')[0],
    );
    
    state = user;
    return true;
  }

  /// Sign up with email and password (placeholder)
  Future<bool> signup(String name, String email, String password) async {
    // Placeholder signup logic
    
    final user = await repository.createOrUpdateCurrentUser(
      id: const Uuid().v4(),
      name: name,
      email: email,
    );
    
    state = user;
    return true;
  }

  /// Logout
  Future<void> logout() async {
    await repository.clearCurrentUser();
    state = null;
  }

  /// Create guest user
  Future<void> createGuestUser() async {
    final user = User.guest(id: const Uuid().v4());
    await repository.saveUser(user);
    await repository.setCurrentUserId(user.id);
    state = user;
  }

  /// Update after session completion
  Future<void> updateAfterSession(int bambooEarned) async {
    if (state == null) return;

    await repository.updateBamboo(state!.id, bambooEarned);
    await repository.updateLastSessionDate(state!.id, DateTime.now());
    
    // Reload user to get updated data
    _loadCurrentUser();
  }

  /// Update streak
  Future<void> updateStreak(int newStreak) async {
    if (state == null) return;

    await repository.updateStreak(state!.id, newStreak);
    _loadCurrentUser();
  }

  /// Set partner
  Future<void> setPartner(String? partnerId, String? roomCode) async {
    if (state == null) return;

    await repository.setPartner(state!.id, partnerId, roomCode);
    _loadCurrentUser();
  }

  /// Check if logged in
  bool get isLoggedIn => state != null;
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AuthNotifier(repository, ref);
});

/// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

