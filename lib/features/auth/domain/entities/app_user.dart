import 'package:equatable/equatable.dart';

/// Uygulama genelinde kullanılan, backend'den (Supabase) bağımsız
/// kullanıcı modeli. Presentation katmanı Supabase'in kendi User
/// sınıfını değil, bunu görür — böylece ileride backend değişse
/// (örn. Firebase'e geçilse) sadece data katmanındaki mapping değişir.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl];
}