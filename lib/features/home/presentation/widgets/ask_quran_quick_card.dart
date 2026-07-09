import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Ana sayfadaki "Kur'an'a Sor" hızlı erişim kartı.
/// Kullanıcı bir soru yazıp gönderdiğinde Ask sekmesine yönlendirir.
class AskQuranQuickCard extends StatefulWidget {
  const AskQuranQuickCard({super.key});

  @override
  State<AskQuranQuickCard> createState() => _AskQuranQuickCardState();
}

class _AskQuranQuickCardState extends State<AskQuranQuickCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    // TODO(ask-entegrasyonu): Ask sayfası bloc'u bağlanınca `query`
    // buradan prefilled soru olarak taşınacak.
    _controller.clear();
    context.go('/ask');
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.goldBright,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HUZURA AÇILAN KAPI',
                          style: AppTextStyles.labelSm(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Kur'an'a Sor",
                      style: AppTextStyles.bodyLg(color: AppColors.textPrimary)
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.goldBright.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onSubmitted: (_) => _handleSubmit(),
            style: AppTextStyles.bodyMd(color: AppColors.textPrimary)
                .copyWith(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Zihnini meşgul eden konuyu buraya fısılda...',
              hintStyle: AppTextStyles.bodyMd(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ).copyWith(fontSize: 13),
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(6),
                child: Material(
                  color: AppColors.gold,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _handleSubmit,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.chevron_right,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '*Örn: "Kararsız kaldığımda ne yapmalıyım?", '
            '"Ruhumu nasıl sakinleştiririm?"',
            style: AppTextStyles.labelSm(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ).copyWith(fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}