import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recommended_activity.dart';
import '../../domain/repositories/verse_repository.dart';
import '../event/home_event.dart';
import '../state/home_state.dart';

/// Ana ekranın "Günün Ayeti" ve "Tavsiye Edilenler" içeriğini yönetir.
///
/// Ayet/hadis artık [VerseRepository] üzerinden Supabase'den geliyor —
/// hem ilk açılışta hem "Sonraki" ile her defasında veritabanına gidip
/// rastgele bir satır çekiyor.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required VerseRepository verseRepository})
      : _verseRepository = verseRepository,
        super(const HomeState()) {
    on<HomeStarted>(_onLoadVerse);
    on<HomeVerseRotateRequested>(_onLoadVerse);
  }

  final VerseRepository _verseRepository;

  // TODO(icerik): Şu an sabit — ileride Supabase'den dinamik çekilecek.
  static const List<RecommendedActivity> _mockRecommended = [
    RecommendedActivity(
      category: 'Tefekkür',
      title: 'Sabır ve Şükür',
      description:
          'Zorluk anlarında sabrın, bolluk anlarında şükrün anlamı '
          'üzerine kısa bir okuma.',
      readTime: '3 dk',
    ),
    RecommendedActivity(
      category: 'Ayet',
      title: 'Kolaylık Üzerine',
      description:
          'Her zorluğun yanında bir kolaylık olduğuna dair ayetler ve '
          'kısa açıklaması.',
      readTime: '2 dk',
    ),
  ];

  Future<void> _onLoadVerse(HomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final verse = await _verseRepository.fetchRandomVerse();
      emit(state.copyWith(
        status: HomeStatus.loaded,
        verse: verse,
        recommended: _mockRecommended,
      ));
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }
}