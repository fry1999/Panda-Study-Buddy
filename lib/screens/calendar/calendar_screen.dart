import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/providers/session_provider.dart';
import 'package:panda_study_buddy/core/utils/time_formatter.dart';

/// Calendar screen - shows study history
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(todaySessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month selector (placeholder)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {},
                    ),
                    Text(
                      TimeFormatter.formatDateLong(DateTime.now()),
                      style: AppTextStyles.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Calendar grid placeholder
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 64,
                        color: AppColors.grey400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Calendar View',
                        style: AppTextStyles.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Coming soon!',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Today's sessions
              Text(
                'Today\'s Sessions',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 12),
              
              sessions.when(
                data: (sessionsList) {
                  if (sessionsList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              '🐼',
                              style: TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No sessions yet today',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: sessionsList.map((session) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Focus Session',
                                    style: AppTextStyles.titleSmall,
                                  ),
                                  Text(
                                    TimeFormatter.formatTime(session.startTime),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              TimeFormatter.formatDurationText(session.duration),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Error loading sessions',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

