import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  runApp(const HardalTanesiApp());
}

class HardalTanesiApp extends StatelessWidget {
  const HardalTanesiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hardal Tanesi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // Karanlık mod şimdilik pasif.
      home: const _RootFlow(),
    );
  }
}

/// Splash -> Onboarding akışını yönetir.
/// İleride auth durumuna göre (giriş yapılmışsa direkt ana ekrana,
/// yapılmamışsa onboarding'e) yönlendirme eklenmek istenirse bu widget
/// genişletilebilir.
class _RootFlow extends StatelessWidget {
  const _RootFlow();

  @override
  Widget build(BuildContext context) {
    return SplashPage(
      onCompleted: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OnboardingPage(
              onCompleted: () {
                // TODO: Auth / ana ekran akışı bağlanınca burası güncellenecek.
                debugPrint(
                  'Onboarding tamamlandı — sıradaki ekrana yönlendirilecek.',
                );
              },
            ),
          ),
        );
      },
    );
  }
}