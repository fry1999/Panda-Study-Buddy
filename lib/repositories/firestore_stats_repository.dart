import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_study_buddy/models/daily_stats.dart';

class FirestoreStatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _statsCollection = 'daily_stats';

  ///  Get stats collection reference
  CollectionReference get _statsRef => _firestore.collection(_statsCollection);

  
  /// Get stats by ID
  Future<DailyStats?> getStats(String id) async {
    try {
      final doc = await _statsRef.doc(id).get();
      if(!doc.exists) return null;
      return DailyStats.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  /// Save daily stats
  Future<void> saveStats(DailyStats stats) async {
    try {
      await _statsRef.doc(stats.id).set(stats.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save stats: $e');
    }
  }

  /// Get or create today's stats
  Future<DailyStats> getTodayStats(String userId, int currentStreak) async {
    final today = DateTime.now();
    final dateKey = _getDateKey(today);
    DailyStats? stats = await getStats(dateKey);
    if(stats == null) {
      stats = DailyStats.today(
        id: dateKey,
        userId: userId,
        streakCount: currentStreak,
      );
      await saveStats(stats);
    }
    return stats;
  }

  /// Update today's stats with a completed session
  Future<void> updateTodayStats(
    String userId,
    int durationSeconds,
    int bambooEarned,
    int currentStreak,
  ) async {
    try {
      final today = DateTime.now();
      final dateKey = _getDateKey(today);

      // Try to get existing stats
      final existingStats = await getStats(dateKey);

      if(existingStats != null) {
        // Update existing stats
        await _statsRef.doc(dateKey).update({
          'totalFocusTimeSeconds': FieldValue.increment(durationSeconds),
          'sessionsCompleted': FieldValue.increment(1),
          'bambooEarned': FieldValue.increment(bambooEarned),
          'streakCount': currentStreak,
        });
      } else {
        // Create new stats
        final newStats = DailyStats.today(
          id: dateKey,
          userId: userId,
          streakCount: currentStreak,
        );
        newStats.addSession(durationSeconds, bambooEarned);
        await saveStats(newStats);
      }
    } catch (e) {
      throw Exception('Failed to update today\'s stats: $e');
    }
  }

  /// Check if daily goal is met
  Future<bool> isDailyGoalMet() async {
    final today = DateTime.now();
    final dateKey = _getDateKey(today);
    final stats = await getStats(dateKey);
    if(stats == null) return false;
    return stats.sessionsCompleted >= 3 || stats.totalFocusTimeSeconds >= 90 * 60;
  }


  /// Helper to generate date key (YYYY-MM-DD)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

}