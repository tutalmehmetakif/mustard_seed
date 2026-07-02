import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// TODO: Kur'an'a Sor (RAG tabanlı soru-cevap, bkz. ürün dokümanı Aşama 2)
/// burada geliştirilecek. Şimdilik yer tutucu.
class AskPage extends StatelessWidget {
  const AskPage({super.key});

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
            Icons.auto_awesome_outlined,
            size: 40,
            color: AppColors.gold,
          ),
          const SizedBox(height: 16),
          Text(
            "Kur'an'a Sor",
            style: AppTextStyles.headlineMd(),
          ),
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