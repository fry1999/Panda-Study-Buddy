import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/models/user.dart';
import 'package:panda_study_buddy/repositories/user_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Auth notifier
class AuthNotifier extends StateNotifier<User?> {
  final UserRepository repository;
  final GoogleSignIn googleSignIn;
  final firebase_auth.FirebaseAuth firebaseAuth;
  final Ref ref;

  AuthNotifier(
    this.repository,
    this.googleSignIn,
    this.firebaseAuth,
    this.ref
  ) : super(null) {
    _loadCurrentUser();

    // Listen to Firebase auth state changes
    firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _syncFirebaseUser(firebaseUser);
      }
    });
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

  /// Sync Firebase user with local storage
  Future<void> _syncFirebaseUser(firebase_auth.User firebaseUser) async {
    try {
      final user = await repository.createOrUpdateCurrentUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
        photoUrl: firebaseUser.photoURL,
      );

      state = user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      // Sign out first to clear any cached/corrupted state
      await googleSignIn.signOut();
      
      // Trigger the Google sign in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign in
        return false;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      
      // Don't call _syncFirebaseUser manually - the authStateChanges listener will handle it
      // This prevents double calls and race conditions
      if (userCredential.user != null) {
        // Wait a moment for the authStateChanges listener to trigger and sync the user
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      }

      return false;
    }
    catch (e) {
      print('Error signing in with Google: $e');
      
      // Check if Firebase auth succeeded despite the google_sign_in error
      // This handles the Pigeon type cast bug where google_sign_in throws but Firebase succeeds
      if (firebaseAuth.currentUser != null) {
        // Wait for authStateChanges listener to sync
        await Future.delayed(const Duration(milliseconds: 500));
        return state != null; // Return true if user was synced
      }
      
      return false;
    }
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
  final googleSignIn = GoogleSignIn();
  final firebaseAuth = firebase_auth.FirebaseAuth.instance;
  return AuthNotifier(repository, googleSignIn, firebaseAuth, ref);
});

/// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

