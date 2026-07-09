import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../zikir/presentation/bloc/zikir_bloc.dart';
import '../../../zikir/presentation/bloc/zikir_event.dart';
import '../../../zikir/presentation/bloc/zikir_state.dart';
import '../../../zikir/presentation/widgets/zikir_counter_ring.dart';

/// Ana sayfadaki "Hızlı Zikir Sayacı" kartı.
///
/// ARTIK gerçek [ZikirBloc]'a bağlı — Zikir sekmesiyle TAMAMEN AYNI bloc
/// instance'ını kullanıyor (bloc, app_router.dart'ta ShellRoute seviyesinde
/// sağlanıyor). Bu yüzden burada +1'e basılırsa Zikir sekmesinde de,
/// Zikir sekmesinde artırılırsa burada da anında güncellenir — ayrıca
/// yerel bir state tutmuyoruz, tek gerçek kaynak (source of truth)
/// ZikirBloc.
class QuickZikirCounterCard extends StatelessWidget {
  const QuickZikirCounterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikirBloc, ZikirState>(
      builder: (context, state) {
        final template = state.aktifSablon;
        final progress = state.ilerlemeOrani; // 0.0 - 1.0

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
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'HIZLI ZİKİR SAYACI',
                        style: AppTextStyles.labelSm(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go('/zikir'),
                    child: Row(
                      children: [
                        Text(
                          'Tam Ekran',
                          style: AppTextStyles.labelSm(
                            color: AppColors.gold,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Icon(Icons.chevron_right,
                            size: 14, color: AppColors.gold),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                template.phrase,
                style: AppTextStyles.bodyLg(color: AppColors.textPrimary)
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Dokununca gerçek ZikirBloc'a event gönderiyor —
                  // yerel setState YOK.
                  GestureDetector(
                    onTap: () => context
                        .read<ZikirBloc>()
                        .add(const ZikirSayacArttirildi()),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Arkadaşının yazdığı gerçek ring painter'ı
                          // kullanıyoruz — Zikir sekmesindeki mantıkla
                          // birebir aynı çizim.
                          CustomPaint(
                            size: const Size(56, 56),
                            painter: ZikirCounterRing(
                              progressPercent: progress * 100,
                              isCompleted: state.tamamlandiMi,
                            ),
                          ),
                          Text(
                            '+1',
                            style: AppTextStyles.labelSm(color: AppColors.gold)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${state.sayac}',
                              style: AppTextStyles.headlineMd(
                                color: AppColors.goldBright,
                              ).copyWith(fontSize: 20, height: 1),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '/ ${template.target}',
                                style: AppTextStyles.labelSm(
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor:
                                AppColors.outlineVariant.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.goldBright,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          template.translation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSm(
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ).copyWith(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.goldBright.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sıfırlamak veya değiştirmek için',
                      style: AppTextStyles.labelSm(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ).copyWith(fontWeight: FontWeight.w400),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/zikir'),
                      child: Text(
                        'Tıklayın',
                        style: AppTextStyles.labelSm(color: AppColors.gold)
                            .copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}