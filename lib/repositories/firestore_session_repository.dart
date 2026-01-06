import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';
import 'package:panda_study_buddy/models/study_session.dart';

class FirestoreSessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _sessionsCollection = 'sessions';

  /// Get the sessions collection reference
  CollectionReference<Map<String, dynamic>> get _sessionsRef => _firestore.collection(_sessionsCollection);

  /// Save a study session
  Future<void> saveSession(StudySession session) async {
    try {
      await _sessionsRef.doc(session.id).set(session.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  /// Get a session by ID
  Future<StudySession?> getSession(String id) async {
    try {
      final doc = await _sessionsRef.doc(id).get();
      if (!doc.exists) return null;
      return StudySession.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  /// Get all sessions for a user
  Future<List<StudySession>> getAllSessions(String userId) async {
    try {
      final querySnapshot = await _sessionsRef
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
        .get();
      return querySnapshot.docs.map((doc) => StudySession.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get all sessions: $e');
    }
  }

  /// Get sessions for a specitfic date
  Future<List<StudySession>> getSessionsByDate(String userId, DateTime date) async {
    try {
      final startOfDay = TimeFormatter.getStartOfDay(date);
      final endOfDay = TimeFormatter.getEndOfDay(date);
      final querySnapshot = await _sessionsRef
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThanOrEqualTo: endOfDay)
        .orderBy('startTime', descending: true)
        .get();
      return querySnapshot.docs.map((doc) => StudySession.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get sessions by date: $e');
    }
  }

  /// Get today's sessions
  Future<List<StudySession>> getTodaySessions(String userId) async {
    return getSessionsByDate(userId, DateTime.now());
  }

  /// Get focus sessions for today
  Future<List<StudySession>> getTodayFocusSessions(String userId) async {
    final sessions = await getTodaySessions(userId);
    return sessions.where((session) => session.sessionType == 'focus' && session.completed).toList();
  }

  /// Get total focus time for today
  Future<Duration> getTodayFocusTime(String userId) async {
    final sessions = await getTodayFocusSessions(userId);
    int totalSeconds = 0;
    for (var session in sessions) {
      totalSeconds += session.durationSeconds;
    }
    return Duration(seconds: totalSeconds);
  }

  /// Get completed sessions count for today
  Future<int> getTodayCompletedCount(String userId) async {
    final sessions = await getTodayFocusSessions(userId);
    return sessions.length;
  }

  /// Get total bamboo earned today
  Future<int> getTodayBamboo(String userId) async {
    final sessions = await getTodayFocusSessions(userId);
    int totalBamboo = 0;
    for (var session in sessions) {
      totalBamboo += session.bambooEarned;
    }
    return totalBamboo;
  }

  /// Check if user studied today
  Future<bool> hasStudiedToday(String userId) async {
    final sessions = await getTodayFocusSessions(userId);
    return sessions.isNotEmpty;
  }

  /// Stream user sessions (real-time updates)
  Stream<List<StudySession>> streamUserSessions(String userId) {
    return _sessionsRef
      .where('userId', isEqualTo: userId)
      .orderBy('startTime', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => StudySession.fromJson(doc.data())).toList());
  }
  
}