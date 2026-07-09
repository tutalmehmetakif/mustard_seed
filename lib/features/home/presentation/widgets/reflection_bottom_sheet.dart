import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "Tefekkür Modu" — bir ayete dokununca alttan açılan sayfa.
/// Ayetin kendisini büyük, sakin bir şekilde gösterir; paylaş/kaydet/indir
/// aksiyonları şimdilik yer tutucu (edge functions bağlanınca doldurulacak).
Future<void> showReflectionBottomSheet(
  BuildContext context, {
  required String text,
  required String reference,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ReflectionSheet(text: text, reference: reference),
  );
}

class _ReflectionSheet extends StatelessWidget {
  const _ReflectionSheet({required this.text, required this.reference});

  final String text;
  final String reference;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      'TEFEKKÜR MODU',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSm(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // back butonuyla dengelemek için
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'GÜNLÜK TEFEKKÜR',
                style: AppTextStyles.labelSm(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '"$text"',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMd(color: AppColors.goldBright)
                    .copyWith(fontStyle: FontStyle.italic, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                reference.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSm(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.goldBright.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleIconButton(
                    icon: Icons.ios_share_outlined,
                    onTap: () {
                      // TODO(edge-function): paylaşım entegrasyonu
                    },
                  ),
                  const SizedBox(width: 16),
                  _CircleIconButton(
                    icon: Icons.bookmark_border,
                    onTap: () {
                      // TODO(edge-function): kaydetme entegrasyonu
                    },
                  ),
                  const SizedBox(width: 16),
                  _CircleIconButton(
                    icon: Icons.file_download_outlined,
                    onTap: () {
                      // TODO(edge-function): indirme entegrasyonu
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}