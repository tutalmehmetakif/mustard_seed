import 'package:equatable/equatable.dart';

import '../../domain/entities/recommended_activity.dart';
import '../../domain/entities/verse_of_the_day.dart';

class HomeState extends Equatable {
  const HomeState({
    required this.verses,
    required this.recommended,
    this.currentVerseIndex = 0,
  });

  final List<VerseOfTheDay> verses;
  final List<RecommendedActivity> recommended;
  final int currentVerseIndex;

  VerseOfTheDay get currentVerse => verses[currentVerseIndex];

  HomeState copyWith({int? currentVerseIndex}) {
    return HomeState(
      verses: verses,
      recommended: recommended,
      currentVerseIndex: currentVerseIndex ?? this.currentVerseIndex,
    );
  }

  @override
  List<Object?> get props => [verses, recommended, currentVerseIndex];
}