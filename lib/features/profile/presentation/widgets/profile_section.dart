import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Profil sayfasındaki "Hesap / Tercihler / Güvenlik" gibi gruplanmış
/// ayar listelerini saran kart.
///
/// Başlığı üstte gösterir, [children] arasına otomatik ayraç (divider)
/// ekler; kartın arka planı ve kenarlığı [isDarkMode] durumuna göre
/// seçilir.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.children,
  });

  final String title;
  final bool isDarkMode;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Dark modda koyu-üstü-koyu bir kenarlık (ör. Colors.black26) kart
    // arka planına neredeyse hiç fark atmıyor; kartın sınırının görünür
    // olması için açık tonlu, düşük opaklıklı bir çizgi kullanılıyor.
    final dividerColor = isDarkMode
        ? AppColors.textSecondaryDark.withValues(alpha: 0.16)
        : AppColors.outlineVariant.withValues(alpha: 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSm(
              color: (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary)
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            // Tam opaklıkta kullanılıyor: %40 gibi düşük bir alpha,
            // neredeyse siyah olan backgroundDark üzerinde kartı sayfadan
            // ayırt edilemez hale getiriyordu (bkz. HESAP/GÜVENLİK
            // gruplarının kaybolması).
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: dividerColor),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
