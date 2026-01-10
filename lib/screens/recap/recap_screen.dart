import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';
import 'package:panda_study_buddy/providers/partner_provider.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';
import 'package:panda_study_buddy/providers/stats_provider.dart';

/// Today's Recap screen
class RecapScreen extends ConsumerWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusTime = ref.watch(todayFocusTimeProvider);
    final bambooEarned = ref.watch(todayBambooProvider);
    final streak = ref.watch(currentStreakProvider);
    final hasPartner = ref.watch(hasPartnerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Today\'s Recap'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Title
              const Text(
                'Sweet Dreams!',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You both did a great job growing your bamboo\nforest today.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Forest illustration
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8F5E9),
                      Color(0xFFF1F8F4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    // Moon icon
                    const Positioned(
                      top: 20,
                      left: 20,
                      child: Text('🌙', style: TextStyle(fontSize: 40)),
                    ),
                    // Forest
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '🌲',
                                  style: TextStyle(
                                    fontSize: 32 + (index % 2) * 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Zzz... Resting for tomorrow',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Small leaf decorations
                    const Positioned(
                      bottom: 20,
                      left: 30,
                      child: Text('🍃', style: TextStyle(fontSize: 24)),
                    ),
                    const Positioned(
                      bottom: 30,
                      right: 40,
                      child: Text('🍃', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Total couple focus time
              if (hasPartner) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL COUPLE FOCUS',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Icon(
                            Icons.favorite,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        focusTime.when(
                          data: (duration) => TimeFormatter.formatDurationText(duration),
                          loading: () => '--:--',
                          error: (error, stack) => '--:--',
                        ),
                        style: AppTextStyles.displayLarge,
                      ),
                      const SizedBox(height: 16),
                      // Progress bar showing split
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 12,
                                color: AppColors.userGreen,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 12,
                                color: AppColors.partnerBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.userGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('You (3h)', style: AppTextStyles.bodySmall),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.partnerBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Buddy (2.5h)', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Individual stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.person_outline,
                      iconColor: AppColors.userGreen,
                      title: 'Your Focus',
                      value: focusTime.when(
                        data: (duration) => TimeFormatter.formatDurationText(duration),
                        loading: () => '--:--',
                        error: (_, __) => '--:--',
                      ),
                      subtitle: '+$streak Stalks',
                      subtitleColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.favorite_outline,
                      iconColor: AppColors.partnerBlue,
                      title: 'Buddy\'s Focus',
                      value: '2h 15m',
                      subtitle: '+5 Stalks',
                      subtitleColor: AppColors.info,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Bamboo earned
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.bamboo.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: AppColors.bamboo,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bamboo Earned',
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            bambooEarned.when(
                              data: (bamboo) => 'Forest grew +${bamboo ~/ 10}cm today!',
                              loading: () => 'Loading...',
                              error: (_, __) => 'Forest grew today!',
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.grey400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final Color subtitleColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

