import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/models/study_session.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/providers/stats_provider.dart';
import 'package:panda_study_buddy/repositories/firestore_session_repository.dart';
import 'package:uuid/uuid.dart';

/// Current active session state
class ActiveSessionState {
  final StudySession? session;
  final bool isActive;

  ActiveSessionState({
    this.session,
    this.isActive = false,
  });

  ActiveSessionState copyWith({
    StudySession? session,
    bool? isActive,
  }) {
    return ActiveSessionState(
      session: session,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Session repository provider
final sessionRepositoryProvider = Provider<FirestoreSessionRepository>((ref) {
  return FirestoreSessionRepository();
});

/// Session notifier
class SessionNotifier extends StateNotifier<ActiveSessionState> {
  final FirestoreSessionRepository firestoreRepository;
  final Ref ref;

  SessionNotifier(this.firestoreRepository, this.ref) : super(ActiveSessionState());

  /// Start a new focus session
  void startFocusSession() {
    final user = ref.read(authProvider);
    if (user == null) return;

    final session = StudySession.focus(
      id: const Uuid().v4(),
      userId: user.id,
      startTime: DateTime.now(),
      partnerId: user.partnerId,
    );

    state = ActiveSessionState(
      session: session,
      isActive: true,
    );
  }

  /// Complete the current session early
  Future<void> completeCurrentSessionEarly(int actualDurationSeconds) async {
    if (state.session == null) return;

    final session = state.session!;

    session.durationSeconds = actualDurationSeconds;
    session.complete();

    // Clear state immediately so UI updates
    state = ActiveSessionState();

    try {
      // Save to Firestore
      await firestoreRepository.saveSession(session);

      // Update stats
      final statsNotifier = ref.read(statsProvider.notifier);
      await statsNotifier.addCompletedSession(
        session.durationSeconds,
        session.bambooEarned,
      );

      // Update user's last session date and bamboo
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.updateAfterSession(session.bambooEarned);
    } catch (e) {
      // Log error but don't prevent completion
      print('Warning: Failed to save session data: $e');
      // The session is still marked as complete in the UI
    }
  }

  /// Complete the current session
  Future<void> completeCurrentSession() async {
    if (state.session == null) return;

    final session = state.session!;
    session.complete();

    try {
      await firestoreRepository.saveSession(session);

      // Update stats
      final statsNotifier = ref.read(statsProvider.notifier);
      await statsNotifier.addCompletedSession(
        session.durationSeconds,
        session.bambooEarned,
      );

      // Update user's last session date and bamboo
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.updateAfterSession(session.bambooEarned);
    } catch (e) {
      // Log error but don't prevent completion
      print('Warning: Failed to save session data: $e');
      // The session is still marked as complete in the UI
    }
    
    // Clear state AFTER all async operations complete
    // This prevents race conditions where providers rebuild before Firestore save completes
    state = ActiveSessionState();
  }

  /// Cancel the current session
  void cancelSession() {
    state = ActiveSessionState();
  }

  /// Get today's sessions
  Future<List<StudySession>> getTodaySessions() async {
    final user = ref.read(authProvider);
    if (user == null) return [];
    return await firestoreRepository.getTodaySessions(user.id);
  }

  /// Get today's focus sessions
  Future<List<StudySession>> getTodayFocusSessions() async {
    final user = ref.read(authProvider);
    if (user == null) return [];
    return await firestoreRepository.getTodayFocusSessions(user.id);
  }
}

/// Session provider
final sessionProvider =
    StateNotifierProvider<SessionNotifier, ActiveSessionState>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return SessionNotifier(repository, ref);
});

/// Today's sessions provider
final todaySessionsProvider = FutureProvider<List<StudySession>>((ref) async {
  final repository = ref.watch(sessionRepositoryProvider);
  // Trigger rebuild when session state changes
  ref.watch(sessionProvider);
  final user = ref.read(authProvider);
  if (user == null) return [];
  return await repository.getTodaySessions(user.id);
});

/// Today's focus time provider
final todayFocusTimeProvider = FutureProvider<Duration>((ref) async {
  final repository = ref.watch(sessionRepositoryProvider);
  ref.watch(sessionProvider); // Rebuild when session changes
  final user = ref.read(authProvider);
  if (user == null) return Duration.zero;
  return await repository.getTodayFocusTime(user.id);
});

/// Today's bamboo provider
final todayBambooProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(sessionRepositoryProvider);
  ref.watch(sessionProvider); // Rebuild when session changes
  final user = ref.read(authProvider);
  if (user == null) return 0;
  return await repository.getTodayBamboo(user.id);
});

/// Today's session count provider
final todaySessionCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(sessionRepositoryProvider);
  ref.watch(sessionProvider); // Rebuild when session changes
  final user = ref.read(authProvider);
  if (user == null) return 0;
  return await repository.getTodayCompletedCount(user.id);
});

