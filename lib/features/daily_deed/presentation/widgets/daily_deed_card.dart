import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/daily_deed_bloc.dart';
import '../state/daily_deed_state.dart';

class DailyDeedCard extends StatelessWidget {
  const DailyDeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<DailyDeedBloc, DailyDeedState>(
      builder: (context, state) {
        if (state.status != DailyDeedStatus.loaded) {
          return const SizedBox.shrink();
        }

        final completedToday =
            state.deeds.where((d) => d.completedToday).length;
        final total = state.deeds.length;

        return GestureDetector(
          onTap: () => context.go('/daily-deed'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_outlined, color: AppColors.goldBright, size: 26),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOHUM DEFTERİ',
                        style: AppTextStyles.labelSm(color: AppColors.goldBright),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        total == 0
                            ? 'En küçük şey bile görülür.'
                            : 'Bugün $completedToday/$total amel tamamlandı.',
                        style: AppTextStyles.bodyMd(
                          color: isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}