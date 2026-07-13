import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/recommended_activity.dart';
import 'reading_detail_dialog.dart';

/// "Tavsiye Edilenler" bölümündeki yatay kaydırmalı kart.
///
/// Esnek (flexible) tasarım: başlık ve açıklama ne kadar uzun olursa
/// olsun, kart taşmaz — description kısmı kalan alanı doldurur ve
/// gerekirse "..." ile kısaltır. Böylece Supabase'e eklenecek her yeni
/// içerik (kısa/uzun fark etmeksizin) hiçbir cihazda RenderFlex
/// overflow hatası vermez.
class RecommendedCard extends StatelessWidget {
  const RecommendedCard({super.key, required this.activity});

  final RecommendedActivity activity;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return GestureDetector(
      onTap: () => showReadingDetailDialog(context, activity: activity),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        // mainAxisSize.min: kart, dıştan gelen yüksekliği zorlamaz,
        // içeriği kadar yer kaplamaya çalışır — asıl taşma koruması
        // aşağıdaki Expanded'dan geliyor.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    activity.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSm(
                      color: mutedColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  activity.readTime,
                  style: AppTextStyles.labelSm(
                    color: mutedColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              activity.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd(color: textColor)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            // Expanded: kalan tüm dikey alanı bu metin doldurur.
            // Uzun açıklamalar taşmak yerine burada kesilir (ellipsis).
            Expanded(
              child: Text(
                activity.description,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd(color: mutedColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}