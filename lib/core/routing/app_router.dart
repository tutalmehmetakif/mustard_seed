// Değişiklik: Zikir branch'ine ShellRoute eklendi — BlocProvider<ZikirBloc>
// artık burada oluşturuluyor. /zikir/focus alt route'u eklendi.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mustard_seed/features/auth/domain/presentation/pages/email_auth_page.dart';

import '../../features/ask/presentation/pages/ask_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/home/presentation/pages/home_tab_page.dart';
import '../../features/home/presentation/pages/verse_detail_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/zikir/presentation/bloc/zikir_bloc.dart';
import '../../features/zikir/presentation/pages/zikir_focus_page.dart';
import '../../features/zikir/presentation/pages/zikir_page.dart';

/// Uygulamanın tüm sayfa/route tanımları burada toplanır.
///
/// go_router kullanıyoruz çünkü:
/// - Alt navigasyon (bottom nav) için `StatefulShellRoute` ile her sekmenin
///   kendi navigasyon geçmişini bağımsız koruyabiliyoruz (Navigator.push
///   zincirleriyle bunu yönetmek çok daha karmaşık olurdu).
/// - URL/path tabanlı yapı, test edilmesi ve yeni sayfa eklemesi
///   (create_feature.sh ile üretilen her yeni feature'ı buraya tek satır
///   eklemek yeterli) çok daha kolay.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // OAuth/email onay linkleri, işletim sistemi tarafından
      // "io.supabase.mustardseed://login-callback/?code=..." şeklinde
      // uygulamaya iletiliyor. Supabase bu linki zaten kendi iç dinleyicisi
      // (authStateChanges) üzerinden işliyor — ama go_router de bunu
      // "eşleşmeyen bir sayfa" olarak görüp "no routes for location"
      // hatası veriyor. Bu URI'yi go_router'ın route eşleştirmesine hiç
      // sokmadan, güvenli bir sayfaya yönlendiriyoruz.
      if (state.uri.scheme == 'io.supabase.mustardseed') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashPage(
          onCompleted: () => context.go('/onboarding'),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(
          onCompleted: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/email-auth',
        builder: (context, state) => const EmailAuthPage(),
      ),
      GoRoute(
        path: '/verse-detail/:id',
        builder: (context, state) => VerseDetailPage(
          verseId: state.pathParameters['id']!,
        ),
      ),
      // Odak Modu — StatefulShellRoute DIŞINDA, tam ekran (AppBar/BottomNav yok).
      // ZikirBloc instance'ı GoRouter'ın extra parametresiyle aktarılır.
      GoRoute(
        path: '/zikir/focus',
        builder: (context, state) => BlocProvider.value(
          value: state.extra! as ZikirBloc,
          child: const ZikirFocusPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeTabPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ask',
                builder: (context, state) => const AskPage(),
              ),
            ],
          ),
          // Zikir branch'i: ShellRoute ile BlocProvider<ZikirBloc> sarılıyor.
          StatefulShellBranch(
            routes: [
              ShellRoute(
                builder: (context, state, child) => BlocProvider(
                  create: (_) => ZikirBloc(),
                  child: child,
                ),
                routes: [
                  GoRoute(
                    path: '/zikir',
                    builder: (context, state) => const ZikirView(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}