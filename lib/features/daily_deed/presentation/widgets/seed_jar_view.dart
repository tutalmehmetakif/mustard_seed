import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'seed_jar.dart';

class SeedJarView extends StatelessWidget {
  const SeedJarView({
    super.key,
    required this.seedCount,
    required this.targetCount,
  });

  final int seedCount;
  final int targetCount;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final monthLabel = DateFormat('MMMM y', 'tr_TR').format(DateTime.now());
    

    return LayoutBuilder(
      builder: (context, constraints) {
        // Kavanoz, ayrılan alanın büyük çoğunluğunu kaplasın —
        // üstte ay etiketi + alt metin için yer bırakılıyor.
        final jarSize = constraints.maxHeight * 0.55;

        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthLabel.toUpperCase(),
                    style: AppTextStyles.labelSm(color: AppColors.goldBright),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Her iyilik, bıraktığın bir iz.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: jarSize * 1.3,
                    height: jarSize * 1.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.goldBright.withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  SeedJar(
                    seedCount: seedCount,
                    targetCount: targetCount,
                    size: jarSize,
                  ),
                ],
              ),
              Text(
                'Bu ay $seedCount hardal tanesi. Hiçbiri kaybolmadı.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}