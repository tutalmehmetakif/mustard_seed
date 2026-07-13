import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:mustard_seed/features/auth/data/event/auth_event.dart';
import 'package:mustard_seed/features/auth/data/state/auth_state.dart';
import 'package:mustard_seed/features/profile/presentation/widgets/widget_photo_setting_tile.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

/// Profil sekmesi. Kullanıcı bilgisini [AuthBloc]'tan okur, "Çıkış Yap"
/// tetiklenince onboarding'e geri döner.
///
/// TODO(profil): İsim değiştirme, ayarlar, premium yönetimi gibi
/// özellikler bir "profiles" tablosu kurulunca buraya eklenecek.
/// NOT: Bu sayfa geçici/basit halde — nihai tasarım ayrı olarak
/// yapılacak. [WidgetPhotoSettingTile] test amacıyla buraya eklendi,
/// nihai tasarıma taşınırken aynı widget kullanılabilir.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            context.go('/onboarding');
          }
        },
        builder: (context, state) {
          final displayName = state.user?.displayName?.trim();
          final name = (displayName != null && displayName.isNotEmpty)
              ? displayName
              : (state.user?.email?.split('@').first ?? 'Misafir');
          final email = state.user?.email ?? 'Hesapsız devam ediliyor';

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalMargin,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profil', style: AppTextStyles.headlineLg()),
                const SizedBox(height: 28),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.goldBright,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTextStyles.headlineMd(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: AppTextStyles.bodyMd(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(email, style: AppTextStyles.bodyMd()),
                const SizedBox(height: 28),
                const WidgetPhotoSettingTile(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthSignOutRequested()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Çıkış Yap',
                      style: AppTextStyles.bodyMd(color: AppColors.error)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}