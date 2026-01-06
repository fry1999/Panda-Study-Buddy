import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:panda_study_buddy/core/constants/app_constants.dart';

part 'study_session.g.dart';

@HiveType(typeId: 0)
class StudySession extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  DateTime startTime;
  
  @HiveField(3)
  DateTime? endTime;
  
  @HiveField(4)
  int durationSeconds; // Duration in seconds
  
  @HiveField(5)
  String sessionType; // 'focus', 'break', 'longBreak'
  
  @HiveField(6)
  int bambooEarned;
  
  @HiveField(7)
  bool completed;
  
  @HiveField(8)
  String? partnerId;

  StudySession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.sessionType,
    this.bambooEarned = 0,
    this.completed = false,
    this.partnerId,
  });
  
  /// Get duration as Duration object
  Duration get duration => Duration(seconds: durationSeconds);
  
  /// Get session type enum
  SessionType get type {
    switch (sessionType) {
      case 'focus':
        return SessionType.focus;
      case 'shortBreak':
        return SessionType.shortBreak;
      case 'longBreak':
        return SessionType.longBreak;
      default:
        return SessionType.focus;
    }
  }
  
  /// Check if session is from today
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }
  
  /// Create a focus session
  factory StudySession.focus({
    required String id,
    required String userId,
    required DateTime startTime,
    String? partnerId,
  }) {
    return StudySession(
      id: id,
      userId: userId,
      startTime: startTime,
      durationSeconds: AppConstants.focusDurationMinutes * 60,
      sessionType: 'focus',
      bambooEarned: AppConstants.bambooPerSession,
      partnerId: partnerId,
    );
  }
  
  /// Create a break session
  factory StudySession.breakSession({
    required String id,
    required String userId,
    required DateTime startTime,
  }) {
    return StudySession(
      id: id,
      userId: userId,
      startTime: startTime,
      durationSeconds: AppConstants.breakDurationMinutes * 60,
      sessionType: 'shortBreak',
      bambooEarned: 0,
    );
  }
  
  /// Complete the session
  void complete() {
    completed = true;
    endTime = DateTime.now();
  }
  
  @override
  String toString() {
    return 'StudySession(id: $id, type: $sessionType, duration: ${duration.inMinutes}m, completed: $completed)';
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationSeconds': durationSeconds,
      'sessionType': sessionType,
      'bambooEarned': bambooEarned,
      'completed': completed,
      'partnerId': partnerId,
    };
  }

  /// Create from Firestore document
  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      userId: json['userId'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null ? (json['endTime'] as Timestamp).toDate() : null,
      durationSeconds: json['durationSeconds'],
      sessionType: json['sessionType'],
      bambooEarned: json['bambooEarned'],
      completed: json['completed'],
      partnerId: json['partnerId'],
    );
  }
}

