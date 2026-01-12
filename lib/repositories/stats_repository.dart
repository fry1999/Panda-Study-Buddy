import 'package:hive/hive.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';
import 'package:panda_study_buddy/models/daily_stats.dart';
import 'package:panda_study_buddy/repositories/session_repository.dart';

/// Repository for managing daily statistics
class FirestoreStatsRepository {
  static const String _boxName = 'stats';
  
  final FirestoreSessionRepository _sessionRepository;
  
  FirestoreStatsRepository(this._sessionRepository);
  
  /// Get the stats box
  Box<DailyStats> get _box => Hive.box<DailyStats>(_boxName);
  
  /// Save daily stats
  Future<void> saveStats(DailyStats stats) async {
    await _box.put(stats.id, stats);
  }
  
  /// Get stats by ID
  DailyStats? getStats(String id) {
    return _box.get(id);
  }
  
  /// Get stats for a specific date
  DailyStats? getStatsByDate(DateTime date) {
    final dateKey = _getDateKey(date);
    return _box.values.firstWhere(
      (stats) => _getDateKey(stats.date) == dateKey,
      orElse: () => DailyStats(
        id: dateKey,
        date: date,
        userId: 'current_user',
      ),
    );
  }
  
  /// Get or create today's stats
  DailyStats getTodayStats(String userId, int currentStreak) {
    final today = DateTime.now();
    final dateKey = _getDateKey(today);
    
    DailyStats? stats = _box.get(dateKey);
    stats ??= DailyStats.today(
      id: dateKey,
      userId: userId,
      streakCount: currentStreak,
    );
    
    return stats;
  }
  
  /// Update today's stats with a completed session
  Future<void> updateTodayStats(
    String userId,
    int durationSeconds,
    int bambooEarned,
    int currentStreak,
  ) async {
    final stats = getTodayStats(userId, currentStreak);
    stats.addSession(durationSeconds, bambooEarned);
    await saveStats(stats);
  }
  
  /// Get stats for the last N days
  List<DailyStats> getRecentStats(int days) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    return _box.values.where((stats) {
      return stats.date.isAfter(cutoffDate);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }
  
  /// Get stats for a date range
  List<DailyStats> getStatsInRange(DateTime start, DateTime end) {
    return _box.values.where((stats) {
      return stats.date.isAfter(start) && stats.date.isBefore(end);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  /// Calculate total focus time for the week
  Duration getWeeklyFocusTime() {
    final stats = getRecentStats(7);
    int totalSeconds = 0;
    
    for (var stat in stats) {
      totalSeconds += stat.totalFocusTimeSeconds;
    }
    
    return Duration(seconds: totalSeconds);
  }
  
  /// Calculate total sessions for the week
  int getWeeklySessionCount() {
    final stats = getRecentStats(7);
    int total = 0;
    
    for (var stat in stats) {
      total += stat.sessionsCompleted;
    }
    
    return total;
  }
  
  /// Calculate total bamboo for the week
  int getWeeklyBamboo() {
    final stats = getRecentStats(7);
    int total = 0;
    
    for (var stat in stats) {
      total += stat.bambooEarned;
    }
    
    return total;
  }
  
  /// Check if daily goal is met today
  bool isDailyGoalMet() {
    final sessions = _sessionRepository.getTodayFocusSessions();
    
    return sessions.length == 1;
  }
  
  /// Get current streak
  int getCurrentStreak() {
    final recentStats = getRecentStats(365); // Check last year
    if (recentStats.isEmpty) return 0;
    
    int streak = 0;
    final today = DateTime.now();
    DateTime checkDate = today;
    
    // Count consecutive days with completed sessions
    for (int i = 0; i < 365; i++) {
      final dateKey = _getDateKey(checkDate);
      final stats = _box.get(dateKey);
      
      if (stats != null && stats.sessionsCompleted > 0) {
        streak++;
      } else if (!TimeFormatter.isSameDay(checkDate, today)) {
        // Allow today to not have sessions yet
        break;
      }
      
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
  
  /// Delete stats
  Future<void> deleteStats(String id) async {
    await _box.delete(id);
  }
  
  /// Delete all stats
  Future<void> deleteAllStats() async {
    await _box.clear();
  }
  
  /// Helper to generate date key (YYYY-MM-DD)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

