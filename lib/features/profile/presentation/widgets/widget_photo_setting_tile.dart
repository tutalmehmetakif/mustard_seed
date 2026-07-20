import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/data/widget_service.dart';

/// Profil sayfasındaki "Widget Fotoğrafı" ayar bölümü.
/// Kullanıcı galeriden bir fotoğraf seçtiğinde, ana ekran widget'ının
/// "Fotoğraflı" stilinin arka planı olarak kaydedilir (bkz.
/// WidgetService.saveUserPhoto).
class WidgetPhotoSettingTile extends StatefulWidget {
  const WidgetPhotoSettingTile({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  State<WidgetPhotoSettingTile> createState() =>
      _WidgetPhotoSettingTileState();
}

class _WidgetPhotoSettingTileState extends State<WidgetPhotoSettingTile> {
  String? _photoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPhoto();
  }

  Future<void> _loadCurrentPhoto() async {
    final path = await WidgetService.getUserPhotoPath();
    if (mounted) setState(() => _photoPath = path);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isLoading = true);
    final success = await WidgetService.saveUserPhoto(picked.path);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      await _loadCurrentPhoto();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Widget fotoğrafı güncellendi.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf kaydedilemedi, tekrar dene.')),
      );
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _isLoading = true);
    await WidgetService.clearUserPhoto();
    setState(() {
      _isLoading = false;
      _photoPath = null;
    });
  }

  /// iOS'ta gerçek bir dosya yolu değil, "var/yok" bilgisini taşıyan
  /// sabit bir gösterge ('ios_photo_placeholder') döndüğü için
  /// Image.file ile açılamaz — sadece Android'de gerçek yol varken
  /// önizleme gösterilir, iOS'ta "seçili" ikonu gösterilir.
  Widget _buildPreview(Color backgroundColor, Color mutedColor) {
    final hasPhoto = _photoPath != null;
    final canShowRealImage = hasPhoto && !Platform.isIOS;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 56,
        height: 56,
        child: canShowRealImage
            ? Image.file(
                File(_photoPath!),
                fit: BoxFit.cover,
              )
            : Container(
                color: backgroundColor,
                alignment: Alignment.center,
                child: Icon(
                  hasPhoto ? Icons.check_circle : Icons.brightness_2_outlined,
                  color: AppColors.goldBright,
                  size: 24,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        widget.isDarkMode ? AppColors.surfaceDark : AppColors.surface;
    final backgroundColor =
        widget.isDarkMode ? AppColors.backgroundDark : AppColors.background;
    final mutedColor = widget.isDarkMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode
              ? AppColors.textSecondaryDark.withValues(alpha: 0.15)
              : AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WIDGET FOTOĞRAFI',
            style: AppTextStyles.labelSm(color: mutedColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Ana ekran widget\'ında arka planda görünecek fotoğraf. '
            'Fotoğraf seçmezsen, o günün gerçek ay görünümü otomatik '
            'gösterilir.',
            style: AppTextStyles.bodyMd(color: mutedColor),
          ),
          const SizedBox(height: 16),
          // Row yerine Column — dar ekranlarda (iOS/Android fark etmeksizin)
          // önizleme ve butonlar yatayda sıkışıp taşma riski YOK, her
          // zaman tam genişlikte, dikey sıralanıyor.
          _buildPreview(backgroundColor, mutedColor),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _pickPhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      _photoPath != null ? 'Fotoğrafı Değiştir' : 'Fotoğraf Seç',
                      style: AppTextStyles.labelSm(color: Colors.white),
                    ),
            ),
          ),
          if (_photoPath != null) ...[
            const SizedBox(height: 8),
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton(
                  onPressed: _isLoading ? null : _removePhoto,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Kaldır ve Ay\'a Geri Dön',
                    style: AppTextStyles.labelSm(color: mutedColor)
                        .copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}