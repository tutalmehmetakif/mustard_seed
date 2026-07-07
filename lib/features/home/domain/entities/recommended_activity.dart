import 'package:equatable/equatable.dart';

/// Ana ekrandaki "Tavsiye Edilenler" bölümünde gösterilen kısa içerik
/// kartı. Supabase'deki `recommended_activities` tablosundan geliyor.
class RecommendedActivity extends Equatable {
  const RecommendedActivity({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.readTime,
    required this.content,
    this.verseRef,
  });

  final String id;
  final String category;
  final String title;

  /// Kartta gösterilen kısa özet (2 satırla sınırlı).
  final String description;
  final String readTime;

  /// "Okuma" detay diyaloğunda gösterilen tam metin.
  final String content;

  /// Varsa, "Ayet Olarak Paylaş" ile Tefekkür Modu'na taşınacak referans.
  final String? verseRef;

  @override
  List<Object?> get props =>
      [id, category, title, description, readTime, content, verseRef];
}