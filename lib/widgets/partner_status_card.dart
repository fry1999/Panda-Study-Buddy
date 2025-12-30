import 'package:flutter/material.dart';
import 'package:panda_study_buddy/core/constants/app_constants.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/models/partner_status.dart';

/// Partner status card widget
class PartnerStatusCard extends StatelessWidget {
  final PartnerStatusModel partner;

  const PartnerStatusCard({
    super.key,
    required this.partner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: _getStatusColor().withOpacity(0.1),
            child: Text(
              partner.partnerName[0].toUpperCase(),
              style: AppTextStyles.titleLarge.copyWith(
                color: _getStatusColor(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.partnerName,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  partner.statusText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (partner.status) {
      case PartnerStatus.online:
        return AppColors.success;
      case PartnerStatus.offline:
        return AppColors.grey400;
      case PartnerStatus.studying:
        return AppColors.primary;
      case PartnerStatus.onBreak:
        return AppColors.warning;
      case PartnerStatus.resting:
        return AppColors.info;
    }
  }
}

/// Connection status badge
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  letterSpacing: 0.5,
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

