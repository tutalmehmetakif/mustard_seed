import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mustard_seed/core/di/app_providers.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:mustard_seed/features/home/data/supabase_recommended_activity_repository.dart';
import 'package:mustard_seed/features/home/domain/repositories/recommended_activity_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'features/auth/data/repositories/supabase_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/home/data/supabase_verse_repository.dart';
import 'features/home/data/widget_service.dart';
import 'features/home/domain/repositories/verse_repository.dart';

void main() {
  // Yakalanmamış asenkron hataları (örn. bir stream'den beklenmedik bir
  // hata gelmesi) burada güvenli bir şekilde loglar — böylece uygulama
  // sessizce çökmek yerine en azından konsola düzgün bir iz bırakır.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Supabase projesi: mustard-seed
      await Supabase.initialize(
        url: 'https://smdtadmonbyxrklhiyxf.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZHRhZG1vbmJ5eHJrbGhpeXhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5NzUxMTQsImV4cCI6MjA5ODU1MTExNH0.fffwQXvwCindm3UfqFyWqK_vTqWr_2It3vnv9uMxf9c',
      );

      await WidgetService.init();

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

class _HardalTanesiAppState extends State<HardalTanesiApp>
    with WidgetsBindingObserver {
  // Router bir kez oluşturulur — build() içinde yeniden oluşturulursa
  // her rebuild'de navigasyon durumu sıfırlanabilir.
  late final GoRouter _router = buildAppRouter();
  late final VerseRepository _verseRepository = SupabaseVerseRepository();
  late final RecommendedActivityRepository _recommendedActivityRepository =
    SupabaseRecommendedActivityRepository();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncWidgetVerse(); // Soğuk açılışta bir kez senkronize et.
    _listenForWidgetTaps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kullanıcı uygulamayı her açtığında (resumed) VE her kapattığında/
    // arka plana attığında (paused — genelde telefonu kilitlediği an)
    // widget'a YENİ, rastgele bir ayet/hadis gönderiyoruz.
    //
    // ÖNEMLİ SINIR: Uygulama hiç çalışmıyorken (tamamen kapalıyken)
    // telefonun kilitlenip açılması bizim tarafımızdan tespit edilemez —
    // iOS/Android hiçbir üçüncü parti uygulamaya böyle bir bildirim
    // vermiyor. Widget'ın "kendiliğinden" değişmesi o durumda tamamen
    // iOS'un kendi arka plan yenileme takvimine (WidgetKit timeline)
    // bağlı, üzerinde tam kontrolümüz yok.
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused) {
      _syncWidgetVerse();
    }
  }

  Future<void> _syncWidgetVerse() async {
    try {
      await WidgetService.syncVerse(_verseRepository);
    } catch (error) {
      // Widget senkronizasyonu başarısız olsa da uygulama çalışmaya
      // devam etmeli — sadece logluyoruz.
      debugPrint('Widget senkronizasyonu başarısız: $error');
    }
  }

  /// Widget'a (kilit ekranı/ana ekran) dokununca gelen
  /// "io.supabase.mustardseed://verse-detail?id=..." linkini yakalayıp
  /// go_router üzerinden Ayet Açıklaması ekranına yönlendirir.
  ///
  /// NOT: Bu URL şeması aynı zamanda Supabase OAuth (Google/Apple) geri
  /// dönüşü için de kullanılıyor ("login-callback" host'u ile) — o
  /// linkler zaten Supabase'in kendi dinleyicisi tarafından ayrıca
  /// işleniyor, burada sadece "verse-detail" host'unu ele alıyoruz.
  Future<void> _listenForWidgetTaps() async {
    Future<void> handleUri(Uri uri) async {
      debugPrint('[DeepLink] Gelen URI: $uri (host: "${uri.host}")');
      if (uri.host != 'verse-detail') {
        debugPrint('[DeepLink] Host "verse-detail" değil, görmezden geliniyor.');
        return;
      }
      final id = uri.queryParameters['id'];
      debugPrint('[DeepLink] Yakalanan id: "$id"');
      if (id == null || id.isEmpty) {
        debugPrint('[DeepLink] id boş, yönlendirme yapılmıyor.');
        return;
      }
      debugPrint('[DeepLink] /verse-detail/$id adresine yönlendiriliyor.');
      _router.go('/verse-detail/$id');
    }

    try {
      final initialUri = await _appLinks.getInitialLink();
      debugPrint('[DeepLink] getInitialLink() sonucu: $initialUri');
      if (initialUri != null) await handleUri(initialUri);
    } catch (error) {
      debugPrint('İlk deep link okunamadı: $error');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[DeepLink] uriLinkStream üzerinden geldi: $uri');
        handleUri(uri);
      },
      onError: (Object error) => debugPrint('Deep link hatası: $error'),
    );
  }

 @override
Widget build(BuildContext context) {
  return AppProviders(
    verseRepository: _verseRepository,
    recommendedActivityRepository: _recommendedActivityRepository,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        // Karanlık mod anahtarı artık kök seviyede sağlanıyor ki
        // MaterialApp.themeMode'a bağlanabilsin (bkz. ThemeCubit yorumu).
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDarkMode) {
          return MaterialApp.router(
            title: 'Hardal Tanesi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    ),
  );
}
}