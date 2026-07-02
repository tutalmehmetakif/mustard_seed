import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/supabase_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  // Yakalanmamış asenkron hataları (örn. bir stream'den beklenmedik bir
  // hata gelmesi) burada güvenli bir şekilde loglar — böylece uygulama
  // sessizce çökmek yerine en azından konsola düzgün bir iz bırakır.
  // AuthBloc kendi stream hatalarını zaten yakalayıp kullanıcıya gösteriyor
  // (bkz. AuthStreamErrorReceived); bu sadece son bir güvenlik ağı.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Supabase projesi: mustard-seed
      await Supabase.initialize(
        url: 'https://smdtadmonbyxrklhiyxf.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZHRhZG1vbmJ5eHJrbGhpeXhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5NzUxMTQsImV4cCI6MjA5ODU1MTExNH0.fffwQXvwCindm3UfqFyWqK_vTqWr_2It3vnv9uMxf9c',
      );

      runApp(const HardalTanesiApp());
    },
    (error, stackTrace) {
      debugPrint('Yakalanmamış hata: $error');
    },
  );
}

class HardalTanesiApp extends StatelessWidget {
  const HardalTanesiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => SupabaseAuthRepository(),
      child: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: MaterialApp(
          title: 'Hardal Tanesi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light, // Karanlık mod şimdilik pasif.
          home: const _RootFlow(),
        ),
      ),
    );
  }
}

/// Splash -> Onboarding akışını yönetir.
/// İleride oturum durumuna göre (giriş yapılmışsa direkt ana ekrana)
/// yönlendirme eklenmek istenirse bu widget genişletilebilir.
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
                // TODO: Auth tamamlandı — ana ekran akışı bağlanınca
                // burası güncellenecek.
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