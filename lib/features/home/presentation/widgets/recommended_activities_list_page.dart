import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/recommended_activity.dart';
import 'reading_detail_dialog.dart';

/// "Tümünü Gör" ile açılan, tüm tavsiye edilen içeriklerin listelendiği
/// tam ekran sayfa. Bir karta dokununca "Okuma" detay diyaloğu açılır.
class RecommendedActivitiesListPage extends StatelessWidget {
  const RecommendedActivitiesListPage({
    super.key,
    required this.activities,
  });

  final List<RecommendedActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text('Tavsiye Edilenler', style: AppTextStyles.headlineMd()),
      ),
      body: activities.isEmpty
          ? Center(
              child: Text(
                'Henüz içerik eklenmedi.',
                style: AppTextStyles.bodyMd(),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _ActivityListTile(activity: activity);
              },
            ),
    );
  }
}

class _ActivityListTile extends StatelessWidget {
  const _ActivityListTile({required this.activity});

  final RecommendedActivity activity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showReadingDetailDialog(context, activity: activity),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
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
            const SizedBox(height: 8),
            Text(
              activity.title,
              style: AppTextStyles.bodyLg(color: AppColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              activity.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Oku',
                  style: AppTextStyles.labelSm(color: AppColors.gold)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.gold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}