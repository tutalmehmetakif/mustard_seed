import '../entities/verse_of_the_day.dart';

/// Ayet/hadis içeriğinin nereden geldiğini soyutlar (şu an Supabase,
/// ileride farklı bir kaynak olabilir — üst katmanlar bunu bilmez).
abstract class VerseRepository {
  /// Veritabanından rastgele bir ayet/hadis çeker. Hem uygulama açılışında
  /// (Ana Sayfa) hem de kilit ekranı/ana ekran widget'ını senkronize
  /// ederken kullanılır — böylece ikisi de aynı kaynaktan besleniyor.
  Future<VerseOfTheDay> fetchRandomVerse();

  /// Widget'a dokunulunca açılan "Ayet Açıklaması" ekranı için, belirli
  /// bir ayeti kimliğine (id) göre çeker.
  Future<VerseOfTheDay> fetchVerseById(String id);
}