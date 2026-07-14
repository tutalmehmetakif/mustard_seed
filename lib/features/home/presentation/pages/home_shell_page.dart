import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:mustard_seed/features/auth/data/state/auth_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Alt navigasyonlu (bottom nav) 4 sekmeyi (Ana Sayfa, Kur'an'a Sor, Zikir,
/// Profil) saran kabuk (shell) widget'ı.
///
/// go_router'ın `StatefulShellRoute.indexedStack` deseni kullanılıyor —
/// her sekmenin kendi navigasyon geçmişi ayrı ayrı korunuyor, sekmeler
/// arası geçişte state kaybolmuyor (örn. Zikir'de bir sayaç ortasındayken
/// Ana Sayfa'ya geçip geri dönmek, sayacı sıfırlamaz).
class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: _buildAppBar(context, isDarkMode),
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        isDarkMode: isDarkMode,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Zaten seçili sekmeye tekrar basılırsa, o sekmenin kendi
          // navigasyon geçmişini başa sarar (örn. bir detay sayfasından
          // sekme köküne döner).
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      title: Text(
        'Hardal Tanesi',
        style: AppTextStyles.headlineMd(
          color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      actions: [
        // TODO(premium): Premium rozeti/butonu buraya eklenecek
        // (premium akışı kurulunca — bkz. ürün dokümanındaki Aşama 4).
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final initial = _avatarInitial(state);
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () => context.go('/profile'),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.goldBright,
                  child: Text(
                    initial,
                    style: AppTextStyles.bodyMd(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _avatarInitial(AuthState state) {
    final name = state.user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name[0].toUpperCase();
    final email = state.user?.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.isDarkMode,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = isDarkMode
        ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
        : AppColors.textSecondary.withValues(alpha: 0.4);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      selectedItemColor: isDarkMode ? AppColors.goldBright : AppColors.gold,
      unselectedItemColor: unselectedColor,
      selectedLabelStyle: AppTextStyles.labelSm(
        color: isDarkMode ? AppColors.goldBright : AppColors.gold,
      ),
      unselectedLabelStyle: AppTextStyles.labelSm(color: unselectedColor),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Ana Sayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          label: "Kur'an'a Sor",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.circle_outlined),
          label: 'Zikir',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}