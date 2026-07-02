/// Auth işlemleri sırasında oluşan, kullanıcıya doğrudan gösterilebilir
/// hataları temsil eder.
///
/// Data katmanı (örn. [SupabaseAuthRepository]), backend'e özel hata
/// tiplerini (örn. Supabase'in `AuthException`'ı) bu sınıfa çevirerek
/// fırlatır. Böylece Bloc ve UI katmanları hangi backend'in kullanıldığını
/// hiç bilmek zorunda kalmaz — sadece [AuthFailure.message]'ı okur.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}