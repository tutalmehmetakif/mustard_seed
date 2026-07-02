import 'package:equatable/equatable.dart';

sealed class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Splash ekranı build edildiğinde tetiklenir, 2.8 saniyelik
/// otomatik geçiş zamanlayıcısını başlatır.
class SplashStarted extends SplashEvent {
  const SplashStarted();
}

/// Kullanıcı ekrana dokunduğunda (erken geçiş) ya da zamanlayıcı
/// dolduğunda tetiklenir.
class SplashSkipped extends SplashEvent {
  const SplashSkipped();
}