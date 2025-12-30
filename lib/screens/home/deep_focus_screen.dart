import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';
import 'package:panda_study_buddy/providers/partner_provider.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';
import 'package:panda_study_buddy/providers/timer_provider.dart';
import 'package:panda_study_buddy/screens/home/success_screen.dart';
import 'package:panda_study_buddy/widgets/bamboo_counter.dart';
import 'package:panda_study_buddy/widgets/circular_timer.dart';
import 'package:panda_study_buddy/widgets/partner_status_card.dart';

/// Deep focus screen - main timer screen
class DeepFocusScreen extends ConsumerWidget {
  const DeepFocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final partnerStatus = ref.watch(partnerStatusProvider);
    final bambooCount = ref.watch(todayBambooProvider);

    // Check if timer completed
    ref.listen<TimerState>(timerProvider, (previous, current) {
      if (previous != null &&
          !previous.isCompleted &&
          current.isCompleted &&
          !current.isRunning) {
        // Timer just completed - save the session first
        ref.read(timerProvider.notifier).complete().then((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SuccessScreen(),
            ),
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Deep Focus'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Open settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [              
              // Timer with panda peeking
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.only(
                          top: 40,
                          bottom: 40,
                          left: 20,
                          right: 20,
                        ),
                        child: CircularTimer(
                          timeText: TimeFormatter.formatTimer(timerState.remaining),
                          progress: timerState.progress,
                        ),
                      ),
                    ],
                  ),
                  // Panda peeking
                  // const PandaPeeking(),
                ],
              ),
              
              const SizedBox(height: 18),
              
              // Bamboo counter
              BambooCounter(count: bambooCount),
              
              const SizedBox(height: 18),
              // Partner status (if connected)
              if (partnerStatus != null) ...[
                PartnerStatusCard(partner: partnerStatus),
                const SizedBox(height: 24),
              ],
              
              const SizedBox(height: 16),
              
              // Start/Pause button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    if (!timerState.isRunning && !timerState.isPaused) {
                      // Start new session
                      ref.read(sessionProvider.notifier).startFocusSession();
                      ref.read(timerProvider.notifier).start();
                    } else if (timerState.isRunning) {
                      // Pause
                      ref.read(timerProvider.notifier).pause();
                    } else if (timerState.isPaused) {
                      // Resume
                      ref.read(timerProvider.notifier).resume();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: timerState.isRunning
                        ? AppColors.warning
                        : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        timerState.isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timerState.isRunning
                            ? 'Pause Session'
                            : timerState.isPaused
                                ? 'Resume Session'
                                : 'Start Session',
                        style: AppTextStyles.button.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Cancel button (if session is active)
              if (timerState.isRunning || timerState.isPaused) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Session?'),
                        content: const Text(
                          'Are you sure you want to cancel this study session? Progress will not be saved.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(timerProvider.notifier).reset();
                              ref.read(sessionProvider.notifier).cancelSession();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Yes, Cancel',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Cancel Session',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],

              // Complete Early button (if session is active)
              if (timerState.isRunning || timerState.isPaused) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hoàn thành sớm?'),
                          content: const Text(
                            'Bạn có chắc muốn hoàn thành session này sớm? Bạn vẫn sẽ nhận đủ 12 bamboo!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Không'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await ref.read(timerProvider.notifier).completeEarly();
                                Navigator.pop(context);
                                // Navigate to success screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SuccessScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Hoàn thành',
                                style: TextStyle(color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.success, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 24,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hoàn thành sớm',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

