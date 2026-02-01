/// App-wide constants
class AppConstants {
  // Timer durations
  static const int focusDurationMinutes = 25;
  static const int breakDurationMinutes = 5;
  static const int longBreakDurationMinutes = 15;
  
  // Study goals
  static const int dailyGoalSessions = 3;
  static const int dailyGoalMinutes = 90;
  
  // Bamboo rewards
  static const int bambooPerSession = 12;
  
  // Room code
  static const int roomCodeLength = 6;
  
  // Streak thresholds
  static const int streakWarningHour = 12; // Noon
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Storage keys
  static const String userBoxKey = 'user';
  static const String sessionsBoxKey = 'sessions';
  static const String statsBoxKey = 'stats';
  static const String appDataBoxKey = 'app_data';
  
  // User data keys
  static const String currentUserKey = 'current_user';
  static const String isLoggedInKey = 'is_logged_in';
  static const String roomCodeKey = 'room_code';
  static const String partnerIdKey = 'partner_id';
  
  // Music settings
  static const String focusMusicPath = 'assets/sounds/focus_music.mp3';
  static const String musicEnabledKey = 'music_enabled';
  static const double defaultMusicVolume = 1;
}

/// Session types
enum SessionType {
  focus,
  shortBreak,
  longBreak,
}

/// Panda states
enum PandaState {
  happy,      // Completed daily goal
  neutral,    // Normal state
  hungry,     // No session today
  resting,    // Resting after goal
  studying,   // Currently in session
}

/// Partner status
enum PartnerStatus {
  online,
  offline,
  studying,
  onBreak,
  resting,
}

