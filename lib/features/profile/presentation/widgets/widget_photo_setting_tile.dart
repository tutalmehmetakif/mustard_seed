import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/data/widget_service.dart';

/// Profil sayfasına eklenecek "Widget Fotoğrafı" ayar bölümü.
/// Kullanıcı galeriden bir fotoğraf seçtiğinde, "Fotoğraflı" widget
/// stilinin arka planı olarak kaydedilir (bkz. WidgetService.saveUserPhoto).
class WidgetPhotoSettingTile extends StatefulWidget {
  const WidgetPhotoSettingTile({super.key});

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
          content: Text(
            'Widget fotoğrafı güncellendi. Widget\'ı "Fotoğraflı" '
            'stiline geçirmeyi unutma.',
          ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WIDGET FOTOĞRAFI',
            style: AppTextStyles.labelSm(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ana ekran widget\'ında "Fotoğraflı" stili seçtiğinde '
            'arka planda görünecek fotoğraf.',
            style: AppTextStyles.bodyMd(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _photoPath != null
                    ? Image.file(
                        File(_photoPath!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: AppColors.background,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                _photoPath != null
                                    ? 'Fotoğrafı Değiştir'
                                    : 'Fotoğraf Seç',
                                style: AppTextStyles.labelSm(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    if (_photoPath != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading ? null : _removePhoto,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Fotoğrafı Kaldır',
                          style: AppTextStyles.labelSm(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}