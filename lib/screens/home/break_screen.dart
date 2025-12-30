import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';
import 'package:panda_study_buddy/providers/partner_provider.dart';
import 'package:panda_study_buddy/providers/timer_provider.dart';
import 'package:panda_study_buddy/widgets/custom_button.dart';

/// Break/recharge screen
class BreakScreen extends ConsumerWidget {
  const BreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final partnerStatus = ref.watch(partnerStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Partner status at top (if connected)
              if (partnerStatus != null) ...[
                ConnectionStatusBadge(
                  isConnected: true,
                  text: partnerStatus.statusText,
                ),
                const SizedBox(height: 24),
              ],
              
              const Spacer(),
              
              // Panda with tea
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8F5E9),
                      Color(0xFFF1F8F4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🐼',
                        style: TextStyle(fontSize: 140),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '☕',
                        style: TextStyle(fontSize: 48),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Recharging...',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Timer display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Text(
                          TimeFormatter.formatTimer(timerState.remaining)
                              .split(':')[0],
                          style: AppTextStyles.timer.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'HOURS',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: AppTextStyles.timer.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          TimeFormatter.formatTimer(timerState.remaining)
                              .split(':')[1],
                          style: AppTextStyles.timer.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'MINUTES',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: AppTextStyles.timer.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          timerState.remaining.inSeconds.remainder(60)
                              .toString()
                              .padLeft(2, '0'),
                          style: AppTextStyles.timer.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'SECONDS',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Wellness tip
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.spa_outlined,
                      color: AppColors.bamboo,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Take a deep breath. Drink some water.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Skip break button
              CustomButton(
                text: 'I\'m ready to study now',
                icon: Icons.play_arrow_rounded,
                isPrimary: false,
                onPressed: () {
                  ref.read(timerProvider.notifier).skipBreak();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Connection status badge for break screen
class ConnectionStatusBadge extends StatelessWidget {
  final bool isConnected;
  final String text;

  const ConnectionStatusBadge({
    super.key,
    required this.isConnected,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.lightGreen,
            child: const Text('🐼', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CONNECTED',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

