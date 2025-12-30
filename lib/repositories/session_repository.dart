import 'package:hive/hive.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';
import 'package:panda_study_buddy/models/study_session.dart';

/// Repository for managing study sessions
class SessionRepository {
  static const String _boxName = 'sessions';
  
  /// Get the sessions box
  Box<StudySession> get _box => Hive.box<StudySession>(_boxName);
  
  /// Save a study session
  Future<void> saveSession(StudySession session) async {
    await _box.put(session.id, session);
  }
  
  /// Get a session by ID
  StudySession? getSession(String id) {
    return _box.get(id);
  }
  
  /// Get all sessions
  List<StudySession> getAllSessions() {
    return _box.values.toList();
  }
  
  /// Get sessions for a specific date
  List<StudySession> getSessionsByDate(DateTime date) {
    final startOfDay = TimeFormatter.getStartOfDay(date);
    final endOfDay = TimeFormatter.getEndOfDay(date);
    
    return _box.values.where((session) {
      return session.startTime.isAfter(startOfDay) &&
          session.startTime.isBefore(endOfDay);
    }).toList();
  }
  
  /// Get sessions for today
  List<StudySession> getTodaySessions() {
    return getSessionsByDate(DateTime.now());
  }
  
  /// Get focus sessions for today
  List<StudySession> getTodayFocusSessions() {
    return getTodaySessions()
        .where((session) => session.sessionType == 'focus' && session.completed)
        .toList();
  }
  
  /// Get recent sessions (last N days)
  List<StudySession> getRecentSessions(int days) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    return _box.values.where((session) {
      return session.startTime.isAfter(cutoffDate);
    }).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
  }
  
  /// Get sessions in a date range
  List<StudySession> getSessionsInRange(DateTime start, DateTime end) {
    return _box.values.where((session) {
      return session.startTime.isAfter(start) &&
          session.startTime.isBefore(end);
    }).toList();
  }
  
  /// Delete a session
  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }
  
  /// Delete all sessions
  Future<void> deleteAllSessions() async {
    await _box.clear();
  }
  
  /// Get total focus time for today
  Duration getTodayFocusTime() {
    final sessions = getTodayFocusSessions();
    int totalSeconds = 0;
    
    for (var session in sessions) {
      totalSeconds += session.durationSeconds;
    }
    
    return Duration(seconds: totalSeconds);
  }
  
  /// Get completed sessions count for today
  int getTodayCompletedCount() {
    return getTodayFocusSessions().length;
  }
  
  /// Get total bamboo earned today
  int getTodayBamboo() {
    final sessions = getTodayFocusSessions();
    int totalBamboo = 0;
    
    for (var session in sessions) {
      totalBamboo += session.bambooEarned;
    }
    
    return totalBamboo;
  }
  
  /// Check if user studied today
  bool hasStudiedToday() {
    return getTodayFocusSessions().isNotEmpty;
  }
}

