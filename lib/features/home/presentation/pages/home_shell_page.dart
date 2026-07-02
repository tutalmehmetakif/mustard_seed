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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      title: Text('Hardal Tanesi', style: AppTextStyles.headlineMd()),
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
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.textSecondary.withValues(alpha: 0.4),
      selectedLabelStyle: AppTextStyles.labelSm(),
      unselectedLabelStyle: AppTextStyles.labelSm(),
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