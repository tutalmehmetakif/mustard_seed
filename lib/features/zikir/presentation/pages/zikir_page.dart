import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// TODO: Kişisel zikir kurma/sayma özelliği (bkz. ürün dokümanı Aşama 3)
/// burada geliştirilecek. Şimdilik yer tutucu.
class ZikirPage extends StatelessWidget {
  const ZikirPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle_outlined,
            size: 40,
            color: AppColors.gold,
          ),
          const SizedBox(height: 16),
          Text('Zikir', style: AppTextStyles.headlineMd()),
          const SizedBox(height: 8),
          Text(
            'Yakında burada olacak.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(),
          ),
        ],
      ),
    );
  }
}