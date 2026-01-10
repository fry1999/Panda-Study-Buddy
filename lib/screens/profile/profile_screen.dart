import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';
import 'package:panda_study_buddy/providers/stats_provider.dart';
import 'package:panda_study_buddy/screens/recap/recap_screen.dart';
import 'package:panda_study_buddy/screens/welcome_screen.dart';

/// Profile screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final focusTime = ref.watch(todayFocusTimeProvider);
    final sessionCount = ref.watch(todaySessionCountProvider);
    final streak = ref.watch(currentStreakProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Settings screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Profile card
              CircleAvatar(
                radius: 54,
                backgroundImage: NetworkImage(user.photoUrl ?? ''),

              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: AppTextStyles.headlineMedium,
              ),
              Text(
                user.email,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.eco,
                      iconColor: AppColors.bamboo,
                      label: 'Total Bamboo',
                      value: '${user.totalBamboo}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      iconColor: AppColors.streak,
                      label: 'Streak',
                      value: '$streak Days',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer,
                      iconColor: AppColors.primary,
                      label: 'Today',
                      value: focusTime.when(
                        data: (duration) => TimeFormatter.formatDurationText(duration),
                        loading: () => '--:--',
                        error: (error, stack) => '--:--',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      iconColor: AppColors.success,
                      label: 'Sessions',
                      value: sessionCount.when(
                        data: (count) => '$count',
                        loading: () => '--',
                        error: (_, __) => '--',
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Menu items
              _MenuItem(
                icon: Icons.nightlight_outlined,
                title: 'Today\'s Recap',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecapScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.favorite_outline,
                title: 'Partner',
                subtitle: user.hasPartner
                    ? 'Connected'
                    : 'Not connected',
                onTap: () {
                  // TODO: Partner management
                },
              ),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.forest_outlined,
                title: 'My Forest',
                subtitle: 'Coming soon',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.logout,
                title: 'Log Out',
                titleColor: AppColors.error,
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (titleColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: titleColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

