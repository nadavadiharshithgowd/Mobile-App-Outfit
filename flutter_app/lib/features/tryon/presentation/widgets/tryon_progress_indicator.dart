import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class TryOnProgressIndicatorWidget extends StatelessWidget {
  final int progress;
  final String step;

  const TryOnProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated progress circle
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 6,
                      backgroundColor: AppColors.surface,
                      color: AppColors.accent,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$progress%',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Generating Try-On',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              step,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Step indicators
            _StepRow(
              label: 'Analyzing body pose',
              isActive: progress >= 10,
              isComplete: progress >= 30,
            ),
            _StepRow(
              label: 'Preparing garment',
              isActive: progress >= 30,
              isComplete: progress >= 50,
            ),
            _StepRow(
              label: 'Generating try-on',
              isActive: progress >= 50,
              isComplete: progress >= 80,
            ),
            _StepRow(
              label: 'Finishing up',
              isActive: progress >= 80,
              isComplete: progress >= 100,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isComplete;

  const _StepRow({
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isComplete
                  ? AppColors.success
                  : isActive
                      ? AppColors.accent
                      : AppColors.surface,
              border: Border.all(
                color: isComplete
                    ? AppColors.success
                    : isActive
                        ? AppColors.accent
                        : AppColors.divider,
                width: 2,
              ),
            ),
            child: isComplete
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : isActive
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textHint,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
