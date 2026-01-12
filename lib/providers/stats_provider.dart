import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/models/daily_stats.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';
import 'package:panda_study_buddy/repositories/firestore_stats_repository.dart';

/// Stats repository provider
final statsRepositoryProvider = Provider<FirestoreStatsRepository>((ref) {
  return FirestoreStatsRepository();
});

/// Stats notifier
class StatsNotifier extends StateNotifier<DailyStats?> {
  final FirestoreStatsRepository firestoreRepository;
  final Ref ref;

  StatsNotifier(this.firestoreRepository, this.ref) : super(null) {
    _loadTodayStats();
  }

  /// Load today's stats
  Future<void> _loadTodayStats() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    try {
      final stats = await firestoreRepository.getTodayStats(user.id, user.currentStreak);
      state = stats;
    } catch (e) {
      print('Warning: Failed to load stats from Firestore: $e');
      // Keep existing state or create a default one
      state ??= DailyStats.today(
          id: _getTodayDateKey(),
          userId: user.id,
          streakCount: user.currentStreak,
        );
    }
  }

  /// Add a completed session to today's stats
  Future<void> addCompletedSession(int durationSeconds, int bambooEarned) async {
    final user = ref.read(authProvider);
    if (user == null) return;

    try {
      await firestoreRepository.updateTodayStats(
        user.id,
        durationSeconds,
        bambooEarned,
        user.currentStreak,
      );

      // Check if we should update streak
      final goalMet = await firestoreRepository.isDailyGoalMet();
      if (goalMet) {
        final authNotifier = ref.read(authProvider.notifier);
        await authNotifier.updateStreak(user.currentStreak + 1);
      }

      await _loadTodayStats();
    } catch (e) {
      print('Warning: Failed to update stats in Firestore: $e');
      // Update local state optimistically
      if (state != null) {
        // Modify existing state
        state!.addSession(durationSeconds, bambooEarned);
        // Trigger UI update by reassigning
        state = state;
      } else {
        // Create new local state
        final newStats = DailyStats.today(
          id: _getTodayDateKey(),
          userId: user.id,
          streakCount: user.currentStreak,
        );
        newStats.addSession(durationSeconds, bambooEarned);
        state = newStats;
      }
    }
  }

  /// Helper to generate today's date key
  String _getTodayDateKey() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  /// Refresh stats
  void refresh() {
    _loadTodayStats();
  }
}

/// Stats provider
final statsProvider = StateNotifierProvider<StatsNotifier, DailyStats?>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return StatsNotifier(repository, ref);
});

/// Is daily goal met provider
final isDailyGoalMetProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  ref.watch(sessionProvider); // Rebuild when sessions change
  return await repository.isDailyGoalMet();
});

/// Current streak provider
final currentStreakProvider = Provider<int>((ref) {
  final user = ref.watch(authProvider);
  return user?.currentStreak ?? 0;
});

// TODO: Implement weekly stats providers when repository methods are ready
// /// Weekly stats provider
// final weeklyFocusTimeProvider = Provider<Duration>((ref) {
//   final repository = ref.watch(statsRepositoryProvider);
//   ref.watch(sessionProvider);
//   return repository.getWeeklyFocusTime();
// });
//
// final weeklySessionCountProvider = Provider<int>((ref) {
//   final repository = ref.watch(statsRepositoryProvider);
//   ref.watch(sessionProvider);
//   return repository.getWeeklySessionCount();
// });
//
// final weeklyBambooProvider = Provider<int>((ref) {
//   final repository = ref.watch(statsRepositoryProvider);
//   ref.watch(sessionProvider);
//   return repository.getWeeklyBamboo();
// });

