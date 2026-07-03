import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/verse_of_the_day.dart';
import '../../domain/repositories/verse_repository.dart';

/// Widget'a (kilit ekranı/ana ekran) dokununca açılan ekran.
/// Doküman: "Ayete dokunulduğunda: kısa ruhsal açıklama açılır (meal değil)".
///
/// Tek seferlik, basit bir veri çekme işlemi olduğu için burada tam bir
/// Bloc/Cubit kurmak yerine `FutureBuilder` kullanıldı — proje genelinde
/// tekrar kullanılan/karmaşık bir ekran değil, bilinçli bir sadelik tercihi.
class VerseDetailPage extends StatelessWidget {
  const VerseDetailPage({super.key, required this.verseId});

  final String verseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<VerseOfTheDay>(
        future: context.read<VerseRepository>().fetchVerseById(verseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.goldBright),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalMargin,
                ),
                child: Text(
                  'Ayet yüklenemedi. Lütfen tekrar dene.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd(),
                ),
              ),
            );
          }

          final verse = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalMargin,
              vertical: 24,
            ),
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
                      'GÜNÜN AYETİ',
                      style: AppTextStyles.labelSm(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '"${verse.text}"',
                  style: AppTextStyles.headlineMd(color: AppColors.goldBright)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                Text(
                  '— ${verse.reference}',
                  style: AppTextStyles.labelSm(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                if (verse.explanation != null &&
                    verse.explanation!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TEFEKKÜR',
                          style: AppTextStyles.labelSm(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          verse.explanation!,
                          style: AppTextStyles.bodyMd(
                            color: AppColors.textPrimary,
                          ).copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}