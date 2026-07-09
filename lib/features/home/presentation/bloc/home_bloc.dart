import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/recommended_activity_repository.dart';
import '../../domain/repositories/verse_repository.dart';
import '../event/home_event.dart';
import '../state/home_state.dart';

/// Ana ekranın "Günün Ayeti" ve "Tavsiye Edilenler" içeriğini yönetir.
///
/// İkisi de Supabase'den geliyor: ayet/hadis [VerseRepository] üzerinden
/// rastgele, tavsiyeler [RecommendedActivityRepository] üzerinden
/// `sort_order`'a göre sıralı çekiliyor.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required VerseRepository verseRepository,
    required RecommendedActivityRepository recommendedActivityRepository,
  })  : _verseRepository = verseRepository,
        _recommendedActivityRepository = recommendedActivityRepository,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeVerseRotateRequested>(_onVerseRotateRequested);
  }

  final VerseRepository _verseRepository;
  final RecommendedActivityRepository _recommendedActivityRepository;

Future<void> _onStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final verseFuture = _verseRepository.fetchRandomVerse();
      final recommendedFuture =
          _recommendedActivityRepository.fetchRecommendedActivities();

      final verse = await verseFuture;
      final recommended = await recommendedFuture;

      emit(state.copyWith(
        status: HomeStatus.loaded,
        verse: verse,
        recommended: recommended,
      ));
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  Future<void> _onVerseRotateRequested(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final verse = await _verseRepository.fetchRandomVerse();
      emit(state.copyWith(status: HomeStatus.loaded, verse: verse));
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }
}