import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/supabase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/daily_deed/data/repositories/supabase_daily_deed_repository.dart';
import '../../features/daily_deed/domain/repositories/daily_deed_repository.dart';
import '../../features/home/domain/repositories/recommended_activity_repository.dart';
import '../../features/home/domain/repositories/verse_repository.dart';

/// Uygulama genelinde kullanılan tüm repository'leri tek bir yerden
/// widget ağacına sağlar (dependency injection).
///
/// Yeni bir repository eklendiğinde SADECE burası değişir —
/// main.dart'a dokunmaya gerek kalmaz.
class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.verseRepository,
    required this.recommendedActivityRepository,
    required this.child,
  });

  /// main.dart'ta önceden yaratılmış tekil (singleton) örnekler —
  /// bu yüzden .value ile alınıyor, burada yeniden yaratılmıyor.
  final VerseRepository verseRepository;
  final RecommendedActivityRepository recommendedActivityRepository;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => SupabaseAuthRepository(),
        ),
        RepositoryProvider<VerseRepository>.value(value: verseRepository),
        RepositoryProvider<RecommendedActivityRepository>.value(
          value: recommendedActivityRepository,
        ),
        RepositoryProvider<DailyDeedRepository>(
          create: (_) => SupabaseDailyDeedRepository(Supabase.instance.client),
        ),
      ],
      child: child,
    );
  }
}