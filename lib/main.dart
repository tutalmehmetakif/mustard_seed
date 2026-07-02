import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:mustard_seed/features/home/data/widget_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/supabase_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';


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

      // Kilit ekranı / ana ekran widget'ına günün ayetini gönderiyoruz.
      // TODO(widget-refresh): Şu an sadece uygulama açılışında
      // senkronize ediyor. Gün değiştiğinde widget'ın otomatik
      // güncellenmesi için ileride Android'de WorkManager, iOS'ta
      // Timeline (WidgetKit'in kendi mekanizması) ile periyodik
      // yenileme eklenmesi gerekecek.
      await WidgetService.init();
      await WidgetService.syncDailyVerse();

      runApp(const HardalTanesiApp());
    },
    (error, stackTrace) {
      debugPrint('Yakalanmamış hata: $error');
    },
  );
}

class HardalTanesiApp extends StatefulWidget {
  const HardalTanesiApp({super.key});

  @override
  State<HardalTanesiApp> createState() => _HardalTanesiAppState();
}

class _HardalTanesiAppState extends State<HardalTanesiApp> {
  // Router bir kez oluşturulur — build() içinde yeniden oluşturulursa
  // her rebuild'de navigasyon durumu sıfırlanabilir.
  late final GoRouter _router = buildAppRouter();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => SupabaseAuthRepository(),
      child: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: MaterialApp.router(
          title: 'Hardal Tanesi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light, // Karanlık mod şimdilik pasif.
          routerConfig: _router,
        ),
      ),
    );
  }
}