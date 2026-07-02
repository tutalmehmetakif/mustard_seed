import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/daily_verse_source.dart';
import '../../domain/entities/recommended_activity.dart';
import '../event/home_event.dart';
import '../state/home_state.dart';

/// Ana ekranın "Günün Ayeti" ve "Tavsiye Edilenler" içeriğini yönetir.
///
/// Başlangıç ayeti [DailyVerseSource.verseForDate] ile bugünün tarihine
/// göre seçilir — bu, kilit ekranı/ana ekran widget'ının gösterdiği
/// ayetle aynıdır (bkz. WidgetService). Kullanıcı "Sonraki" ile listede
/// gezinebilir, bu widget'ı etkilemez.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
      : super(
          HomeState(
            verses: DailyVerseSource.verses,
            recommended: _mockRecommended,
            currentVerseIndex: DailyVerseSource.verses.indexOf(
              DailyVerseSource.verseForDate(DateTime.now()),
            ),
          ),
        ) {
    on<HomeVerseRotateRequested>(_onVerseRotateRequested);
  }

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

  void _onVerseRotateRequested(
    HomeVerseRotateRequested event,
    Emitter<HomeState> emit,
  ) {
    final nextIndex = (state.currentVerseIndex + 1) % state.verses.length;
    emit(state.copyWith(currentVerseIndex: nextIndex));
  }
}