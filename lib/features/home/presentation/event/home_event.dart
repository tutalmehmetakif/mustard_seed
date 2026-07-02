import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Kullanıcı ayet kartındaki "Sonraki" butonuna bastı.
class HomeVerseRotateRequested extends HomeEvent {
  const HomeVerseRotateRequested();
}