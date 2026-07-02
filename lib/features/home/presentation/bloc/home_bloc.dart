import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recommended_activity.dart';
import '../../domain/entities/verse_of_the_day.dart';
import '../event/home_event.dart';
import '../state/home_state.dart';

/// Ana ekranın "Günün Ayeti" ve "Tavsiye Edilenler" içeriğini yönetir.
///
/// TODO(quran-api): [_mockVerses] şu an sabit — Kur'an API entegrasyonu
/// yapılınca günün tarihine göre gerçek bir ayetle değiştirilecek.
/// TODO(icerik): [_mockRecommended] de aynı şekilde Supabase'den
/// dinamik olarak çekilecek.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
      : super(
          const HomeState(
            verses: _mockVerses,
            recommended: _mockRecommended,
          ),
        ) {
    on<HomeVerseRotateRequested>(_onVerseRotateRequested);
  }

  static const List<VerseOfTheDay> _mockVerses = [
    VerseOfTheDay(
      text: 'Şüphesiz her zorlukla beraber bir kolaylık vardır.',
      reference: 'İnşirah Suresi, 6. Ayet',
    ),
    VerseOfTheDay(
      text: 'Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz '
          'Allah sabredenlerle beraberdir.',
      reference: 'Bakara Suresi, 153. Ayet',
    ),
    VerseOfTheDay(
      text: "Kalpler ancak Allah'ı anmakla huzur bulur.",
      reference: "Ra'd Suresi, 28. Ayet",
    ),
  ];

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