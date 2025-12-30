import 'package:hive/hive.dart';

part 'daily_stats.g.dart';

@HiveType(typeId: 2)
class DailyStats extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  DateTime date;
  
  @HiveField(2)
  int totalFocusTimeSeconds;
  
  @HiveField(3)
  int sessionsCompleted;
  
  @HiveField(4)
  int bambooEarned;
  
  @HiveField(5)
  int streakCount;
  
  @HiveField(6)
  String userId;
  
  @HiveField(7)
  String? partnerId;
  
  @HiveField(8)
  int? partnerFocusTimeSeconds;

  DailyStats({
    required this.id,
    required this.date,
    this.totalFocusTimeSeconds = 0,
    this.sessionsCompleted = 0,
    this.bambooEarned = 0,
    this.streakCount = 0,
    required this.userId,
    this.partnerId,
    this.partnerFocusTimeSeconds,
  });
  
  /// Get total focus time as Duration
  Duration get totalFocusTime => Duration(seconds: totalFocusTimeSeconds);
  
  /// Get partner focus time as Duration
  Duration? get partnerFocusTime => 
      partnerFocusTimeSeconds != null ? Duration(seconds: partnerFocusTimeSeconds!) : null;
  
  /// Get combined focus time (user + partner)
  Duration get combinedFocusTime {
    final userTime = totalFocusTimeSeconds;
    final partnerTime = partnerFocusTimeSeconds ?? 0;
    return Duration(seconds: userTime + partnerTime);
  }
  
  /// Check if daily goal is met
  bool get isGoalMet => sessionsCompleted >= 3 || totalFocusTimeSeconds >= 90 * 60;
  
  /// Check if this is today's stats
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  
  /// Add a completed session
  void addSession(int durationSeconds, int bamboo) {
    totalFocusTimeSeconds += durationSeconds;
    sessionsCompleted++;
    bambooEarned += bamboo;
  }
  
  /// Create stats for today
  factory DailyStats.today({
    required String id,
    required String userId,
    int streakCount = 0,
  }) {
    return DailyStats(
      id: id,
      date: DateTime.now(),
      userId: userId,
      streakCount: streakCount,
    );
  }
  
  @override
  String toString() {
    return 'DailyStats(date: ${date.toIso8601String().split('T')[0]}, sessions: $sessionsCompleted, time: ${totalFocusTime.inMinutes}m, bamboo: $bambooEarned)';
  }
}

