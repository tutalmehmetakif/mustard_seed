import '../entities/app_user.dart';

/// Auth işlemlerinin soyut sözleşmesi.
///
/// Presentation katmanı (AuthBloc) bu arayüze bağımlıdır, doğrudan
/// Supabase'e değil. Böylece:
/// - İleride "email ile kayıt ol / giriş yap" eklenince sadece bu arayüze
///   yeni metodlar eklenir, Bloc ve UI tarafında minimal değişiklik gerekir.
/// - Test yazarken gerçek Supabase'e bağlanmadan sahte (fake/mock) bir
///   implementasyon verilebilir.
abstract class AuthRepository {
  /// Oturum durumu değiştiğinde (giriş yapıldı / çıkış yapıldı) yayın yapar.
  /// Kullanıcı giriş yapmamışsa `null` yayınlar.
  Stream<AppUser?> get authStateChanges;

  /// Google OAuth akışını başlatır (tarayıcı/deep link üzerinden).
  /// Sonuç senkron dönmez — [authStateChanges] üzerinden takip edilir.
  Future<void> signInWithGoogle();

  /// Apple OAuth akışını başlatır.
  Future<void> signInWithApple();

  /// Email + şifre ile yeni hesap oluşturur.
  ///
  /// Dönüş değeri `true` ise, Supabase projesinde email doğrulama açık
  /// demektir — kullanıcı gelen maildeki linke tıklamadan oturum açılmaz.
  /// `false` ise session hemen oluşur, [authStateChanges] üzerinden
  /// otomatik olarak `authenticated` durumuna geçilir.
  ///
  /// Başarısız olursa (örn. email zaten kayıtlı, şifre çok kısa)
  /// [AuthFailure] fırlatır.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Email + şifre ile mevcut hesaba giriş yapar.
  ///
  /// Başarısız olursa (örn. hatalı şifre) [AuthFailure] fırlatır.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Backend'e bağlanmadan "misafir" olarak devam edilmesini işaretler.
  Future<void> continueAsGuest();

  /// Aktif oturumu (varsa) kapatır.
  Future<void> signOut();
}