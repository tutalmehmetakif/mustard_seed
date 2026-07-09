// Yeni dosya: Odak Modu (Focus Mode) sayfası.
// Tam ekran, minimalist, koyu arka planlı sayaç ekranı.
// BlocProvider oluşturmaz — parent ShellRoute'tan ZikirBloc'u alır.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/zikir_bloc.dart';
import '../bloc/zikir_event.dart';
import '../bloc/zikir_state.dart';

/// Odak Modu — kullanıcının dikkat dağıtıcı öğeler olmadan sadece sayacına
/// odaklanabildiği tam ekran sayfa. Aynı [ZikirBloc] instance'ını kullanır,
/// böylece ana sayfa ile state senkron kalır.
class ZikirFocusPage extends StatelessWidget {
  const ZikirFocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Android geri tuşuna basıldığında normal zikir sayfasına dön.
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: BlocBuilder<ZikirBloc, ZikirState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // Üst çıkış butonu
                  _ustCikisButonu(context),
                  // Ana sayaç alanı — tüm kalan alanı kaplar ve dokunmayla
                  // sayaç artırır
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context
                          .read<ZikirBloc>()
                          .add(const ZikirSayacArttirildi()),
                      child: Center(
                        child: _sayacAlani(state),
                      ),
                    ),
                  ),
                  // Alt bilgi satırı
                  _altBilgi(state),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _ustCikisButonu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppColors.textSecondaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  'Odak Modundan Çık',
                  style: AppTextStyles.labelSm(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sayacAlani(ZikirState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Büyük dairesel sayaç
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dış daire zemini
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceDark.withValues(alpha: 0.6),
                ),
              ),
              // Dairesel ilerleme çizgisi
              SizedBox(
                width: 300,
                height: 300,
                child: CircularProgressIndicator(
                  value: state.ilerlemeOrani,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    state.tamamlandiMi
                        ? AppColors.goldBright
                        : AppColors.gold,
                  ),
                ),
              ),
              // Orta metin bloğu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.sayac}',
                      style: AppTextStyles.displayHero(
                        color: AppColors.textPrimaryDark,
                      ).copyWith(fontSize: 72),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.aktifSablon.phrase,
                      style: AppTextStyles.bodyLg(
                        color: AppColors.goldBright,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.aktifSablon.translation,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSm(
                        color: AppColors.textSecondaryDark,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Dokunma ipucu
        Text(
          state.tamamlandiMi
              ? 'BAŞA DÖNMEK İÇİN DOKUNUN'
              : 'DOKUNARAK DEVAM ET',
          style: AppTextStyles.labelSm(
            color: AppColors.textSecondaryDark,
          ).copyWith(fontSize: 10, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _altBilgi(ZikirState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _bilgiKutusu(
            'Yapılan',
            '${state.sayac} / ${state.aktifSablon.target}',
          ),
          const SizedBox(width: 32),
          _bilgiKutusu(
            'Tur',
            '${state.tamamlananTurSayisi}',
          ),
        ],
      ),
    );
  }

  Widget _bilgiKutusu(String baslik, String deger) {
    return Column(
      children: [
        Text(
          baslik,
          style: AppTextStyles.labelSm(
            color: AppColors.textSecondaryDark,
          ).copyWith(fontSize: 10, letterSpacing: 1.5),
        ),
        const SizedBox(height: 4),
        Text(
          deger,
          style: AppTextStyles.headlineMd(
            color: AppColors.goldBright,
          ),
        ),
      ],
    );
  }
}
