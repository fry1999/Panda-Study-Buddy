import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/models/study_session.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/providers/stats_provider.dart';
import 'package:panda_study_buddy/repositories/session_repository.dart';
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
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

/// Session notifier
class SessionNotifier extends StateNotifier<ActiveSessionState> {
  final SessionRepository repository;
  final Ref ref;

  SessionNotifier(this.repository, this.ref) : super(ActiveSessionState());

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

    await repository.saveSession(session);

    // Update stats
    final statsNotifier = ref.read(statsProvider.notifier);
    await statsNotifier.addCompletedSession(
      session.durationSeconds,
      session.bambooEarned,
    );

    // Update user's last session date and bamboo
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.updateAfterSession(session.bambooEarned);

    state = ActiveSessionState();
  }

  /// Complete the current session
  Future<void> completeCurrentSession() async {
    if (state.session == null) return;

    final session = state.session!;
    session.complete();
    
    await repository.saveSession(session);

    // Update stats
    final statsNotifier = ref.read(statsProvider.notifier);
    await statsNotifier.addCompletedSession(
      session.durationSeconds,
      session.bambooEarned,
    );

    // Update user's last session date and bamboo
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.updateAfterSession(session.bambooEarned);

    state = ActiveSessionState();
  }

  /// Cancel the current session
  void cancelSession() {
    state = ActiveSessionState();
  }

  /// Get today's sessions
  List<StudySession> getTodaySessions() {
    return repository.getTodaySessions();
  }

  /// Get today's focus sessions
  List<StudySession> getTodayFocusSessions() {
    return repository.getTodayFocusSessions();
  }
}

/// Session provider
final sessionProvider =
    StateNotifierProvider<SessionNotifier, ActiveSessionState>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return SessionNotifier(repository, ref);
});

/// Today's sessions provider
final todaySessionsProvider = Provider<List<StudySession>>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  // Trigger rebuild when session state changes
  ref.watch(sessionProvider);
  return repository.getTodaySessions();
});

/// Today's focus time provider
final todayFocusTimeProvider = Provider<Duration>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  ref.watch(sessionProvider); // Rebuild when session changes
  return repository.getTodayFocusTime();
});

/// Today's bamboo provider
final todayBambooProvider = Provider<int>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  ref.watch(sessionProvider); // Rebuild when session changes
  return repository.getTodayBamboo();
});

/// Today's session count provider
final todaySessionCountProvider = Provider<int>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  ref.watch(sessionProvider); // Rebuild when session changes
  return repository.getTodayCompletedCount();
});

