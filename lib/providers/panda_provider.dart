import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/constants/app_constants.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';
import 'package:panda_study_buddy/providers/stats_provider.dart';
import 'package:panda_study_buddy/providers/timer_provider.dart';

/// Panda state provider
final pandaStateProvider = Provider<PandaState>((ref) {
  // Watch timer state
  final timerState = ref.watch(timerProvider);
  
  // Watch if daily goal is met
  final isGoalMetAsync = ref.watch(isDailyGoalMetProvider);
  
  // Watch if user has studied today
  final sessionCountAsync = ref.watch(todaySessionCountProvider);
  
  // Determine panda state
  if (timerState.isRunning && timerState.sessionType == SessionType.focus) {
    return PandaState.studying;
  }
  
  // Handle async values
  final isGoalMet = isGoalMetAsync.value ?? false;
  final sessionCount = sessionCountAsync.value ?? 0;
  
  if (isGoalMet) {
    return PandaState.resting;
  }
  
  if (sessionCount > 0) {
    return PandaState.happy;
  }
  
  // Check if it's past noon and no sessions
  final now = DateTime.now();
  if (now.hour >= AppConstants.streakWarningHour && sessionCount == 0) {
    return PandaState.hungry;
  }
  
  return PandaState.neutral;
});

/// Panda image asset provider (placeholder)
final pandaImageProvider = Provider<String>((ref) {
  final state = ref.watch(pandaStateProvider);
  
  switch (state) {
    case PandaState.happy:
      return 'assets/images/panda_happy.png';
    case PandaState.neutral:
      return 'assets/images/panda_neutral.png';
    case PandaState.hungry:
      return 'assets/images/panda_hungry.png';
    case PandaState.resting:
      return 'assets/images/panda_resting.png';
    case PandaState.studying:
      return 'assets/images/panda_studying.png';
  }
});

