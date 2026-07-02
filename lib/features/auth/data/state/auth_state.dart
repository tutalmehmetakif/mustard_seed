import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

enum AuthStatus {
  /// Henüz giriş yapılmadı, "misafir" de seçilmedi.
  unauthenticated,

  /// Google/Apple OAuth akışı ya da email işlemi sürüyor, buton loading
  /// göstermeli.
  authenticating,

  /// Google, Apple ya da email ile başarıyla giriş yapıldı.
  authenticated,

  /// "Hesapsız devam et" seçildi.
  guest,

  /// Kayıt başarılı oldu ama Supabase'de email doğrulama açık olduğu için
  /// oturum henüz açılmadı — kullanıcı [pendingEmail] adresine gelen linke
  /// tıklamalı.
  emailConfirmationRequired,

  /// Giriş/kayıt denemesi başarısız oldu.
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
    this.pendingEmail,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  /// [AuthStatus.emailConfirmationRequired] durumunda, doğrulama maili
  /// gönderilen adres.
  final String? pendingEmail;

  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
    String? pendingEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, pendingEmail];
}