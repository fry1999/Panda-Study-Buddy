import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/constants/app_constants.dart';
import 'package:panda_study_buddy/providers/music_provider.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';

/// Timer state
class TimerState {
  final Duration remaining;
  final Duration total;
  final bool isRunning;
  final bool isPaused;
  final SessionType sessionType;
  final DateTime? startTime;

  TimerState({
    required this.remaining,
    required this.total,
    this.isRunning = false,
    this.isPaused = false,
    required this.sessionType,
    this.startTime,
  });

  TimerState copyWith({
    Duration? remaining,
    Duration? total,
    bool? isRunning,
    bool? isPaused,
    SessionType? sessionType,
    DateTime? startTime,
  }) {
    return TimerState(
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      sessionType: sessionType ?? this.sessionType,
      startTime: startTime ?? this.startTime,
    );
  }

  double get progress {
    if (total.inSeconds == 0) return 0;
    return 1 - (remaining.inSeconds / total.inSeconds);
  }

  bool get isCompleted => remaining.inSeconds <= 0;
}

/// Timer provider
class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final Ref ref;

  TimerNotifier(this.ref)
      : super(TimerState(
          remaining: const Duration(minutes: AppConstants.focusDurationMinutes),
          total: const Duration(minutes: AppConstants.focusDurationMinutes),
          sessionType: SessionType.focus,
        ));

  /// Start the timer
  void start() {
    if (state.isRunning) return;

    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      startTime: DateTime.now(),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    
    // Start music if enabled
    ref.read(musicProvider.notifier).play();
  }

  /// Pause the timer
  void pause() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isPaused: true,
    );
    
    // Pause music
    ref.read(musicProvider.notifier).pause();
  }

  /// Resume the timer
  void resume() {
    if (!state.isPaused) return;
    
    // Don't call start() because it would overwrite startTime
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      // Keep the original startTime!
    );

    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    
    // Resume music
    ref.read(musicProvider.notifier).resume();
  }

  /// Reset the timer
  void reset() {
    _timer?.cancel();
    final duration = _getDurationForType(state.sessionType);
    state = TimerState(
      remaining: duration,
      total: duration,
      sessionType: state.sessionType,
    );
    
    // Stop music
    ref.read(musicProvider.notifier).stop();
  }

  /// Stop and complete the session
  Future<void> complete() async {
    _timer?.cancel();
    
    // Stop music
    ref.read(musicProvider.notifier).stop();

    // Only save focus sessions
    if (state.sessionType == SessionType.focus) {
      final sessionNotifier = ref.read(sessionProvider.notifier);
      await sessionNotifier.completeCurrentSession();
    }

    // Reset to focus mode
    final duration = const Duration(minutes: AppConstants.focusDurationMinutes);
    state = TimerState(
      remaining: duration,
      total: duration,
      sessionType: SessionType.focus,
    );
  }

  /// Stop and complete the session early
  Future<void> completeEarly() async {
    _timer?.cancel();
    
    // Stop music
    ref.read(musicProvider.notifier).stop();

    // Reset to focus mode first (so UI updates even if save fails)
    final duration = const Duration(minutes: AppConstants.focusDurationMinutes);
    state = TimerState(
      remaining: duration,
      total: duration,
      sessionType: SessionType.focus,
    );

    // Only save focus sessions
    if (state.sessionType == SessionType.focus && state.startTime != null) {
      final actualDuration = DateTime.now().difference(state.startTime!);
      final sessionNotifier = ref.read(sessionProvider.notifier);

      // Complete with actual duration - let errors propagate to caller
      await sessionNotifier.completeCurrentSessionEarly(actualDuration.inSeconds);
    }
  }

  /// Switch to break mode
  void startBreak() {
    _timer?.cancel();
    final duration = const Duration(minutes: AppConstants.breakDurationMinutes);
    state = TimerState(
      remaining: duration,
      total: duration,
      sessionType: SessionType.shortBreak,
    );
    start();
  }

  /// Switch to focus mode
  void startFocus() {
    _timer?.cancel();
    final duration = const Duration(minutes: AppConstants.focusDurationMinutes);
    state = TimerState(
      remaining: duration,
      total: duration,
      sessionType: SessionType.focus,
    );
  }

  /// Skip break and go back to focus
  void skipBreak() {
    startFocus();
  }

  void _tick(Timer timer) {
    if (state.remaining.inSeconds > 0) {
      final newRemaining = state.remaining - const Duration(seconds: 1);
      
      // If we're about to hit 0, stop the timer and update state atomically
      if (newRemaining.inSeconds <= 0) {
        _timer?.cancel();
        state = state.copyWith(
          remaining: Duration.zero,
          isRunning: false,
        );
      } else {
        // Normal countdown
        state = state.copyWith(remaining: newRemaining);
      }
    } else {
      // This should not happen anymore, but keep for safety
      _timer?.cancel();
      state = state.copyWith(isRunning: false);
    }
  }

  Duration _getDurationForType(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return const Duration(minutes: AppConstants.focusDurationMinutes);
      case SessionType.shortBreak:
        return const Duration(minutes: AppConstants.breakDurationMinutes);
      case SessionType.longBreak:
        return const Duration(minutes: AppConstants.longBreakDurationMinutes);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Timer provider
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

