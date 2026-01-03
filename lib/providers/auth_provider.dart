import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/models/user.dart';
import 'package:panda_study_buddy/repositories/firestore_user_repository.dart';
import 'package:panda_study_buddy/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

/// Create provider for Firestore repository
final firestoreUserRepositoryProvider = Provider<FirestoreUserRepository>((ref) {
  return FirestoreUserRepository();
});

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Google sign in instance
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

/// Firebase auth instance
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

/// Auth notifier
class AuthNotifier extends StateNotifier<User?> {
  
  final FirestoreUserRepository _firestoreRepo;
  final UserRepository repository;
  final GoogleSignIn _googleSignIn;
  final firebase_auth.FirebaseAuth _firebaseAuth;


  AuthNotifier(this._firestoreRepo,
  this.repository,
  this._googleSignIn,
  this._firebaseAuth,
  ) : super(null) {
    _initAuth();
    _listenToAuthChanges();
  }

  /// Initialize authentication from Firestore 
  Future<void> _initAuth() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // Load user form Firestore
      final user = await _firestoreRepo.getUser(firebaseUser.uid);
      if (user != null) {
        state = user;
      }
      else {
        // Create new user in Firestore if doesn't exist 
        final newUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          photoUrl: firebaseUser.photoURL,
        );
        await _firestoreRepo.saveUser(newUser);
        state = newUser;
      }
    }
  }

  /// Listen to Firebase auth state changes
  void _listenToAuthChanges() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        User? user;
        try {
          user = await _firestoreRepo.getUser(firebaseUser.uid);
        } catch (e) {
          print('Firestore getUser error (continuing anyway): $e');
          user = null;
        }
        
        if (user != null) {
          state = user;
        }
        else {
          // Create new user (try Firestore, but continue even if it fails)
          final newUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? '',
            createdAt: DateTime.now(),
            photoUrl: firebaseUser.photoURL,
          );
          
          try {
            await _firestoreRepo.saveUser(newUser);
          } catch (e) {
            print('Firestore saveUser error (continuing anyway): $e');
          }
          
          state = newUser;
        }
      }
      else {
        // User signed out - clear local state
        state = null;
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


  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      // Sign out first to clear any cached/corrupted state
      await _googleSignIn.signOut();
      
      // Trigger the Google sign in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

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
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
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
      if (_firebaseAuth.currentUser != null) {
        // Firebase auth succeeded - wait for authStateChanges listener to try syncing
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // If state is still null (e.g., Firestore error), create user manually
        if (state == null && _firebaseAuth.currentUser != null) {
          try {
            final firebaseUser = _firebaseAuth.currentUser!;
            final newUser = User(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'User',
              email: firebaseUser.email ?? '',
              createdAt: DateTime.now(),
              photoUrl: firebaseUser.photoURL,
            );
            
            // Try to save to Firestore, but don't fail if it doesn't work
            try {
              await _firestoreRepo.saveUser(newUser);
            } catch (firestoreError) {
              print('Firestore save failed (continuing anyway): $firestoreError');
            }
            
            state = newUser;
          } catch (userCreationError) {
            print('Failed to create user: $userCreationError');
          }
        }
        
        // Return true if Firebase auth succeeded, regardless of Firestore status
        return _firebaseAuth.currentUser != null;
      }
      
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Auth state listener will handle syncing
        await Future.delayed(const Duration(milliseconds: 500));
        return state != null;
      }
    } catch (e) {
      print('Error signing in with email and password: $e');
      return false;
    }
    return false;
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailPassword(String name,String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user in Firestore
        final newUser = User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          photoUrl: userCredential.user!.photoURL,
        );
        await _firestoreRepo.saveUser(newUser);
        state = newUser;
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing up with email and password: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      state = null;
    } catch (e) {
      print('Error logging out: $e');
    }
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
  final firestoreRepo = ref.watch(firestoreUserRepositoryProvider);
  final repository = ref.watch(userRepositoryProvider);
  final googleSignIn = GoogleSignIn();
  final firebaseAuth = firebase_auth.FirebaseAuth.instance;
  return AuthNotifier(firestoreRepo, repository, googleSignIn, firebaseAuth);
});

/// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

