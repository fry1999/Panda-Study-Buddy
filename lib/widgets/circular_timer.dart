import 'dart:math';
import 'package:flutter/material.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';

/// Circular timer widget with progress ring
class CircularTimer extends StatelessWidget {
  final String timeText;
  final double progress; // 0.0 to 1.0
  final VoidCallback? onTap;
  final Widget? child;

  const CircularTimer({
    super.key,
    required this.timeText,
    required this.progress,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _CircularTimerPainter(progress: progress),
        child: SizedBox(
          width: 280,
          height: 280,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (child != null) child!,
                const SizedBox(height: 16),
                Text(
                  timeText,
                  style: AppTextStyles.timer.copyWith(fontSize: 56),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus Time',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
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

class _CircularTimerPainter extends CustomPainter {
  final double progress;

  _CircularTimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.grey200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

