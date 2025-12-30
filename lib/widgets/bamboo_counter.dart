import 'package:flutter/material.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';

/// Bamboo counter widget
class BambooCounter extends StatelessWidget {
  final int count;
  final String label;

  const BambooCounter({
    super.key,
    required this.count,
    this.label = 'Bamboo Shoots',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco,
              color: AppColors.bamboo,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TODAY\'S HARVEST',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textLight,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count $label',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple bamboo icon with count
class BambooIcon extends StatelessWidget {
  final int count;

  const BambooIcon({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.eco,
          color: AppColors.bamboo,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '+$count',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.bamboo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

