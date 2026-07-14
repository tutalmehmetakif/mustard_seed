import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:mustard_seed/features/auth/data/event/auth_event.dart';
import 'package:mustard_seed/features/auth/data/state/auth_state.dart';
import 'package:mustard_seed/features/profile/presentation/widgets/widget_photo_setting_tile.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/utils/responsive.dart';
import '../models/profile_menu_item_data.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_section.dart';

/// Profil sekmesi. Kullanıcı bilgisini [AuthBloc]'tan okur, "Çıkış Yap"
/// tetiklenince onboarding'e geri döner.
///
<<<<<<< HEAD
/// TODO(profil): İsim değiştirme, ayarlar, premium yönetimi gibi
/// özellikler bir "profiles" tablosu kurulunca buraya eklenecek.
/// NOT: Bu sayfa geçici/basit halde — nihai tasarım ayrı olarak
/// yapılacak. [WidgetPhotoSettingTile] test amacıyla buraya eklendi,
/// nihai tasarıma taşınırken aynı widget kullanılabilir.
=======
/// Karanlık mod anahtarı ([ThemeCubit]) main.dart'ta kök seviyede
/// sağlanıyor ve MaterialApp.themeMode'a bağlı — yani burada okunan
/// [isDarkMode] durumu uygulama genelindeki gerçek tema tercihidir.
///
/// ÖNEMLİ SINIR: Bu ekranın kendi widget'ları (ProfileSection,
/// ProfileMenuItem vb.) [AppColors]'u [isDarkMode]'a göre elle seçiyor.
/// Diğer sekmeler (Ana Sayfa, Zikir, Kur'an'a Sor) ve HomeShellPage'in
/// AppBar/BottomNav'ı ise [AppColors] sabitlerini [Theme.of(context)]'ten
/// bağımsız, doğrudan çağırıyor — dolayısıyla karanlık mod şu an SADECE
/// bu ekranda görünür etki yapıyor. Uygulama genelinde etkili olması için
/// o ekranların da aynı deseni (isDarkMode'a göre renk seçimi) benimsemesi
/// gerekir; bu, ilgili ekranların sahibi olan takım arkadaşlarının işi.
///
/// TODO(profil): İsim değiştirme, bildirim/dil ayarları ve premium
/// yönetimi gibi özellikler bir "profiles" tablosu ve premium akışı
/// (bkz. home_shell_page.dart'taki TODO(premium)) kurulunca buraya
/// eklenecek; o zamana kadar ilgili satırlar bilinçli olarak pasif
/// ("Yakında") gösteriliyor.
>>>>>>> main
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state;
    final backgroundColor = isDarkMode ? AppColors.backgroundDark : AppColors.background;
    final textColor = isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
<<<<<<< HEAD
      color: AppColors.background,
=======
      color: backgroundColor,
>>>>>>> main
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
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
<<<<<<< HEAD
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
=======
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileHeader(
                  name: name,
                  email: email,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                const SizedBox(height: 32),
                ProfileSection(
                  title: 'Hesap',
                  isDarkMode: isDarkMode,
                  children: [
                    ProfileMenuItem(
                      isDarkMode: isDarkMode,
                      data: const ProfileMenuItemData(
                        icon: Icons.workspace_premium_outlined,
                        title: 'Abonelik',
                        trailingLabel: 'Yakında',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ProfileSection(
                  title: 'Tercihler',
                  isDarkMode: isDarkMode,
                  children: [
                    _DarkModeSwitchRow(isDarkMode: isDarkMode, textColor: textColor),
                    ProfileMenuItem(
                      isDarkMode: isDarkMode,
                      data: const ProfileMenuItemData(
                        icon: Icons.notifications_outlined,
                        title: 'Bildirimler',
                        trailingLabel: 'Yakında',
                      ),
                    ),
                    ProfileMenuItem(
                      isDarkMode: isDarkMode,
                      data: const ProfileMenuItemData(
                        icon: Icons.language_outlined,
                        title: 'Dil',
                        trailingLabel: 'Yakında',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ProfileSection(
                  title: 'Güvenlik',
                  isDarkMode: isDarkMode,
                  children: [
                    ProfileMenuItem(
                      isDarkMode: isDarkMode,
                      data: const ProfileMenuItemData(
                        icon: Icons.lock_outline,
                        title: 'Gizlilik Sözleşmesi',
                        trailingLabel: 'Yakında',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: _LogoutButton(
                    isDarkMode: isDarkMode,
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthSignOutRequested()),
>>>>>>> main
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

/// Üstteki avatar + isim + e-posta bloğu.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.textColor,
    required this.mutedColor,
  });

  final String name;
  final String email;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.goldBright,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: AppTextStyles.headlineMd(color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMd(color: textColor)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(email, textAlign: TextAlign.center, style: AppTextStyles.bodyMd(color: mutedColor)),
      ],
    );
  }
}

/// "Görünüm (Karanlık Mod)" satırı — [ProfileMenuItem]'dan farklı olarak
/// sağda chevron yerine gerçek bir [Switch] barındırdığı için ayrı tutuldu.
class _DarkModeSwitchRow extends StatelessWidget {
  const _DarkModeSwitchRow({required this.isDarkMode, required this.textColor});

  final bool isDarkMode;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Görünüm (Karanlık Mod)',
              style: AppTextStyles.bodyMd(color: textColor)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Switch.adaptive(
              value: isDarkMode,
              activeThumbColor: AppColors.goldBright,
              onChanged: (_) => context.read<ThemeCubit>().toggle(),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Çıkış Yap" butonu.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.isDarkMode, required this.onPressed});

  final bool isDarkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout, size: 16, color: AppColors.error),
        label: Text('Çıkış Yap', style: AppTextStyles.labelSm(color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          // Koyu-üstü-koyu kenarlık (ör. Colors.black38) neredeyse siyah
          // olan backgroundDark üzerinde görünmüyordu; ProfileSection'daki
          // kart kenarlığıyla aynı açık tonlu çözüm kullanılıyor.
          side: BorderSide(
            color: isDarkMode
                ? AppColors.textSecondaryDark.withValues(alpha: 0.25)
                : AppColors.outlineVariant,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}
