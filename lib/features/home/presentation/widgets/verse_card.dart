import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/home_bloc.dart';
import '../event/home_event.dart';
import '../state/home_state.dart';
import 'reflection_bottom_sheet.dart';

/// "Günün Ayeti" kartı — Supabase'den gelen güncel ayeti gösterir,
/// "Sonraki" ile veritabanından yeni bir tane çeker.
/// Karta dokununca "Tefekkür Modu" alttan açılır.
class VerseCard extends StatelessWidget {
  const VerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final canOpenReflection =
            !state.isLoading && state.verse != null;

        return GestureDetector(
          onTap: canOpenReflection
              ? () => showReflectionBottomSheet(
                    context,
                    text: state.verse!.text,
                    reference: state.verse!.reference,
                  )
              : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
                            color: AppColors.goldBright,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'GÜNÜN AYETİ',
                          style: AppTextStyles.labelSm(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: state.isLoading
                          ? null
                          : () => context
                              .read<HomeBloc>()
                              .add(const HomeVerseRotateRequested()),
                      child: Row(
                        children: [
                          Text(
                            'Sonraki',
                            style: AppTextStyles.labelSm(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.isLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.goldBright,
                    ),
                  )
                else if (state.status == HomeStatus.failure ||
                    state.verse == null)
                  Text(
                    'Ayet yüklenemedi, tekrar dene.',
                    style: AppTextStyles.bodyMd(),
                  )
                else ...[
                  Text(
                    '"${state.verse!.text}"',
                    style: AppTextStyles.bodyLg(color: AppColors.goldBright)
                        .copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '— ${state.verse!.reference}',
                    style: AppTextStyles.labelSm(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}