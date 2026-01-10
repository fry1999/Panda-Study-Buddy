import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';
import 'package:panda_study_buddy/providers/partner_provider.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';
import 'package:panda_study_buddy/providers/stats_provider.dart';
import 'package:panda_study_buddy/providers/timer_provider.dart';
import 'package:panda_study_buddy/widgets/custom_button.dart';

/// Success screen - shown after completing a study session
class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).session;
    final focusTime = ref.watch(todayFocusTimeProvider);
    final streak = ref.watch(currentStreakProvider);
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text('Success'),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                
                // Happy panda with bamboo
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.pandaBackground,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      // Bamboo earned badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🌿', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 4),
                              Text(
                                '+${session?.bambooEarned ?? 12}',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.bamboo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Panda
                      Center(
                        child: Image.asset(
                          'assets/images/success_panda.png',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Yummy Success!',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You just fed Po ${session?.bambooEarned ?? 12} bamboo shoots!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer_outlined,
                        iconColor: AppColors.primary,
                        label: 'FOCUS TIME',
                        value: focusTime.when(
                          data: (duration) => TimeFormatter.formatDurationText(duration),
                          loading: () => '--:--',
                          error: (error, stack) => '--:--',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_outlined,
                        iconColor: AppColors.streak,
                        label: 'STREAK',
                        value: '$streak Days',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Partner info (if connected)
                if (partnerStatus != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.partnerBlue.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.partnerBlue.withValues(alpha: 0.2),
                          child: Text(
                            partnerStatus.partnerName[0],
                            style: AppTextStyles.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partnerStatus.partnerName,
                                style: AppTextStyles.titleMedium,
                              ),
                              Text(
                                partnerStatus.statusText,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.favorite,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                // Claim rewards button
                CustomButton(
                  text: 'Claim Rewards',
                  icon: Icons.check_circle_outline,
                  onPressed: () async {
                    // Complete the session
                    await ref.read(timerProvider.notifier).complete();
                    
                    if (context.mounted) {
                      // Go back to deep focus
                      Navigator.pop(context);
                      
                      // Optionally start break
                      // ref.read(timerProvider.notifier).startBreak();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BreakScreen(),
                      //   ),
                      // );
                    }
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Back to forest link
                TextButton(
                  onPressed: () async {
                    await ref.read(timerProvider.notifier).complete();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Back to Forest',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

