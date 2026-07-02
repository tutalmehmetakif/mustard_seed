import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/recommended_activity.dart';

/// "Tavsiye Edilenler" bölümündeki yatay kaydırmalı kart.
class RecommendedCard extends StatelessWidget {
  const RecommendedCard({super.key, required this.activity});

  final RecommendedActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                activity.category.toUpperCase(),
                style: AppTextStyles.labelSm(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              Text(
                activity.readTime,
                style: AppTextStyles.labelSm(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            activity.title,
            style: AppTextStyles.bodyMd(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            activity.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd(),
          ),
        ],
      ),
    );
  }
}