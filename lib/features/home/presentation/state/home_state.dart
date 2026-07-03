import 'package:equatable/equatable.dart';

import '../../domain/entities/recommended_activity.dart';
import '../../domain/entities/verse_of_the_day.dart';

enum HomeStatus { loading, loaded, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.verse,
    this.recommended = const [],
  });

  final HomeStatus status;
  final VerseOfTheDay? verse;
  final List<RecommendedActivity> recommended;

  bool get isLoading => status == HomeStatus.loading;

  HomeState copyWith({
    HomeStatus? status,
    VerseOfTheDay? verse,
    List<RecommendedActivity>? recommended,
  }) {
    return HomeState(
      status: status ?? this.status,
      verse: verse ?? this.verse,
      recommended: recommended ?? this.recommended,
    );
  }

  @override
  List<Object?> get props => [status, verse, recommended];
}