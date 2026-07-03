import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Ana Sayfa ilk açıldığında tetiklenir, Supabase'den rastgele bir
/// ayet/hadis çeker.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Kullanıcı ayet kartındaki "Sonraki" butonuna bastı — yeniden rastgele
/// bir ayet/hadis çeker (yerel bir listede gezinmiyor, her seferinde
/// veritabanına gidiyor).
class HomeVerseRotateRequested extends HomeEvent {
  const HomeVerseRotateRequested();
}