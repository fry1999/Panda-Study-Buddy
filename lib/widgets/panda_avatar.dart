import 'package:flutter/material.dart';
import 'package:panda_study_buddy/core/constants/app_constants.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';

/// Panda avatar widget - displays panda in different states
class PandaAvatar extends StatelessWidget {
  final PandaState state;
  final double size;

  const PandaAvatar({
    super.key,
    required this.state,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.white,
      ),
      child: Center(
        child: _getPandaWidget(),
      ),
    );
  }

  Widget _getPandaWidget() {
    // For now, use emoji as placeholder
    // In production, use actual panda illustrations or Rive animations
    String emoji = _getEmoji();
    String caption = _getCaption();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: size * 0.6),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  String _getEmoji() {
    switch (state) {
      case PandaState.happy:
        return '🐼';
      case PandaState.neutral:
        return '🐼';
      case PandaState.hungry:
        return '😢';
      case PandaState.resting:
        return '😴';
      case PandaState.studying:
        return '📚';
    }
  }

  String _getCaption() {
    switch (state) {
      case PandaState.happy:
        return 'Happy!';
      case PandaState.neutral:
        return 'Ready';
      case PandaState.hungry:
        return 'Hungry...';
      case PandaState.resting:
        return 'Resting';
      case PandaState.studying:
        return 'Focusing';
    }
  }
}

/// Panda peeking widget - for timer screen
class PandaPeeking extends StatelessWidget {
  const PandaPeeking({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Center(
        child: Text(
          '🐼',
          style: TextStyle(fontSize: 80),
        ),
      ),
    );
  }
}

