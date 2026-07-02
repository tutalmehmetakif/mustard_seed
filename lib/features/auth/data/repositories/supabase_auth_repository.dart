import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/exceptions/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

/// [AuthRepository]'nin Supabase Auth ile konuşan implementasyonu.
///
/// OAuth redirect adresi `io.supabase.mustardseed://login-callback/` olarak
/// ayarlı. Bunun çalışması için 3 yerde eşleşmesi gerekiyor:
/// 1. Buradaki `redirectTo` değeri (✅ ayarlandı)
/// 2. Supabase Dashboard > Authentication > URL Configuration >
///    Redirect URLs (ve Site URL) listesine aynı adresin eklenmesi
/// 3. Android (AndroidManifest.xml) ve iOS (Info.plist) tarafında bu
///    custom URL scheme'in tanımlanması (README'de adımlar var)
///
/// Supabase'e özel hatalar (`AuthException`) burada yakalanıp
/// [AuthFailure] olarak, kullanıcıya gösterilebilir Türkçe mesajlarla
/// yeniden fırlatılıyor — üst katmanlar Supabase'i hiç bilmiyor.
///
/// Deep-link ile gelen hatalar (örn. süresi dolmuş email/OAuth linki)
/// Supabase paketi tarafından `authStateChanges` stream'ine bir hata
/// (error event) olarak düşer, normal `try/catch` ile yakalanamaz —
/// bu yüzden aşağıda ayrıca `handleError` ile map'leniyor.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Stream<AppUser?> get authStateChanges {
    return _client.auth.onAuthStateChange
        .map((data) {
          final user = data.session?.user;
          if (user == null) return null;

          return AppUser(
            id: user.id,
            email: user.email,
            displayName: user.userMetadata?['full_name'] as String?,
            avatarUrl: user.userMetadata?['avatar_url'] as String?,
          );
        })
        .handleError((Object error, StackTrace stackTrace) {
          // Örn. süresi dolmuş/geçersiz bir deep-link (mail linki, OAuth
          // callback'i) buraya düşer. Ham Supabase hatasını AuthFailure'a
          // çevirip yeniden fırlatıyoruz ki dinleyen taraf (AuthBloc)
          // Supabase'i hiç bilmesin.
          throw _mapError(error);
        });
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.mustardseed://login-callback/',
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.mustardseed://login-callback/',
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      // Supabase'de "Confirm email" açıksa, kayıt başarılı olsa bile
      // session hemen oluşmaz — kullanıcı maildeki linke tıklamalı.
      return response.session == null;
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> continueAsGuest() async {
    // Şimdilik backend'e dokunmuyoruz, sadece "misafir" olarak devam
    // edildiğini işaretliyoruz. İleride gerçek anonim oturum istenirse:
    // await _client.auth.signInAnonymously();
  }

  /// Supabase'in `AuthException`'ını (ve beklenmeyen diğer hataları),
  /// kullanıcıya gösterilebilir Türkçe [AuthFailure] mesajına çevirir.
  AuthFailure _mapError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      final code = error.code?.toLowerCase() ?? '';

      if (code == 'otp_expired' ||
          msg.contains('expired') ||
          msg.contains('invalid or has expired')) {
        return const AuthFailure(
          'Doğrulama linki geçersiz veya süresi dolmuş. Lütfen yeni bir '
          'link iste ve sadece bir kez, doğrudan telefonundan tıkla.',
        );
      }
      if (msg.contains('already registered') ||
          msg.contains('already exists') ||
          msg.contains('user_already_exists')) {
        return const AuthFailure(
          'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı dene.',
        );
      }
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid_credentials')) {
        return const AuthFailure('E-posta veya şifre hatalı.');
      }
      if (msg.contains('password') &&
          (msg.contains('least') || msg.contains('6'))) {
        return const AuthFailure('Şifre en az 6 karakter olmalı.');
      }
      if (msg.contains('email') && msg.contains('invalid')) {
        return const AuthFailure('Geçerli bir e-posta adresi gir.');
      }
      if (msg.contains('provider is not enabled') ||
          msg.contains('unsupported provider')) {
        return const AuthFailure(
          'Bu giriş yöntemi şu an aktif değil. Lütfen daha sonra tekrar dene.',
        );
      }

      return AuthFailure(error.message);
    }

    return const AuthFailure('Bir hata oluştu. Lütfen tekrar deneyin.');
  }
}