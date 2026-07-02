import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Alt kısımdaki adım göstergesi noktaları.
/// Aktif nokta genişçe altın renginde, diğerleri küçük ve soluk.
class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.onDotTap,
  });

  final int totalSteps;
  final int currentStep;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final step = index + 1;
        final isActive = step == currentStep;
        return GestureDetector(
          onTap: () => onDotTap(step),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 8,
              width: isActive ? 24 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.gold
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}