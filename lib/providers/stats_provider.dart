import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/models/daily_stats.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';
import 'package:panda_study_buddy/repositories/stats_repository.dart';

/// Stats repository provider
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return StatsRepository(sessionRepository);
});

/// Stats notifier
class StatsNotifier extends StateNotifier<DailyStats?> {
  final StatsRepository repository;
  final Ref ref;

  StatsNotifier(this.repository, this.ref) : super(null) {
    _loadTodayStats();
  }

  /// Load today's stats
  void _loadTodayStats() {
    final user = ref.read(authProvider);
    if (user == null) return;

    final stats = repository.getTodayStats(user.id, user.currentStreak);
    state = stats;
  }

  /// Add a completed session to today's stats
  Future<void> addCompletedSession(int durationSeconds, int bambooEarned) async {
    final user = ref.read(authProvider);
    if (user == null) return;

    await repository.updateTodayStats(
      user.id,
      durationSeconds,
      bambooEarned,
      user.currentStreak,
    );

    // Check if we should update streak
    if (repository.isDailyGoalMet()) {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.updateStreak(user.currentStreak + 1);
    }

    _loadTodayStats();
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
final isDailyGoalMetProvider = Provider<bool>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  ref.watch(sessionProvider); // Rebuild when sessions change
  return repository.isDailyGoalMet();
});

/// Current streak provider
final currentStreakProvider = Provider<int>((ref) {
  final user = ref.watch(authProvider);
  return user?.currentStreak ?? 0;
});

/// Weekly stats provider
final weeklyFocusTimeProvider = Provider<Duration>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  ref.watch(sessionProvider);
  return repository.getWeeklyFocusTime();
});

final weeklySessionCountProvider = Provider<int>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  ref.watch(sessionProvider);
  return repository.getWeeklySessionCount();
});

final weeklyBambooProvider = Provider<int>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  ref.watch(sessionProvider);
  return repository.getWeeklyBamboo();
});

