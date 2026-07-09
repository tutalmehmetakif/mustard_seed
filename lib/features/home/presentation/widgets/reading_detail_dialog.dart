import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/recommended_activity.dart';
import 'reflection_bottom_sheet.dart';

/// "Tavsiye Edilenler" kartına dokununca açılan detay diyaloğu ("Okuma").
Future<void> showReadingDetailDialog(
  BuildContext context, {
  required RecommendedActivity activity,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) => _ReadingDetailDialog(activity: activity),
  );
}

class _ReadingDetailDialog extends StatelessWidget {
  const _ReadingDetailDialog({required this.activity});

  final RecommendedActivity activity;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close,
                        size: 20, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activity.title,
                style: AppTextStyles.headlineMd(color: AppColors.goldBright)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: AppColors.goldBright.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Text(
                  activity.content,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg(color: AppColors.textPrimary)
                      .copyWith(fontStyle: FontStyle.italic, height: 1.6),
                ),
              ),
              if (activity.verseRef != null) ...[
                const SizedBox(height: 16),
                Text(
                  '— ${activity.verseRef!}'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (activity.verseRef != null) {
                      showReflectionBottomSheet(
                        context,
                        text: activity.content,
                        reference: activity.verseRef!,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Ayet Olarak Paylaş',
                    style: AppTextStyles.labelSm(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}