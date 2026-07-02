import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Kullanıcı "Google ile Giriş Yap" butonuna bastı.
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Kullanıcı "Apple ile Giriş Yap" butonuna bastı.
class AuthAppleSignInRequested extends AuthEvent {
  const AuthAppleSignInRequested();
}

/// Kullanıcı "Hesapsız devam et" linkine bastı.
class AuthGuestContinueRequested extends AuthEvent {
  const AuthGuestContinueRequested();
}

/// Kullanıcı email/şifre formunda "Kayıt Ol"a bastı.
class AuthEmailSignUpRequested extends AuthEvent {
  const AuthEmailSignUpRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Kullanıcı email/şifre formunda "Giriş Yap"a bastı.
class AuthEmailSignInRequested extends AuthEvent {
  const AuthEmailSignInRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Kullanıcı profil ekranında "Çıkış Yap"a bastı.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Repository'deki `authStateChanges` stream'inden gelen dahili event.
/// Doğrudan UI tarafından tetiklenmez, OAuth akışı tamamlanınca
/// AuthBloc kendi içinde tetikler.
class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final AppUser? user;

  @override
  List<Object?> get props => [user];
}

/// `authStateChanges` stream'i bir hata (örn. süresi dolmuş deep-link)
/// yayınladığında tetiklenir. Doğrudan UI tarafından tetiklenmez.
class AuthStreamErrorReceived extends AuthEvent {
  const AuthStreamErrorReceived(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}