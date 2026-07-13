import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/profile_menu_item_data.dart';

/// [ProfileSection] içinde tek bir satırı (ikon + başlık + sağdaki etiket
/// ve ok işareti) çizer.
///
/// [ProfileMenuItemData.onTap] null ise satır pasif sayılır: imleç
/// `not-allowed` olur, dokunma tepkisi vermez. Dolu ise imleç `pointer`
/// (click) olur ve dokunulabilir.
///
/// Pasif satırlarda başlık fontu KASITLI olarak soluklaştırılmıyor —
/// tüm satırların (aktif/pasif) font ağırlığı ve netliği aynı kalır,
/// pasiflik sadece sağdaki "Yakında" etiketiyle ve imleçle belli olur.
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.data,
    required this.isDarkMode,
  });

  final ProfileMenuItemData data;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final enabled = data.isEnabled;
    final textColor = isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(data.icon, size: 18, color: data.iconColor ?? textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.title,
              style: AppTextStyles.bodyMd(color: textColor)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            data.trailingLabel,
            style: AppTextStyles.bodyMd(color: mutedColor)
                .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: mutedColor.withValues(alpha: 0.6)),
        ],
      ),
    );

    // Not: MouseRegion'ı burada InkWell'in DIŞINA sarmak bilinçli — InkWell
    // kendi iç MouseRegion'ını yalnızca `enabled` durumda kuruyor, böylece
    // pasif satırlarda iç/dış cursor çakışması olmadan `forbidden` net
    // şekilde uygulanıyor.
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: enabled ? InkWell(onTap: data.onTap, child: row) : row,
    );
  }
}
