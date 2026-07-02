import 'package:equatable/equatable.dart';

/// Ana ekrandaki "Tavsiye Edilenler" bölümünde gösterilen kısa içerik
/// kartı. Şu an [HomeBloc] içinde sabit (mock) veriyle geliyor —
/// ileride Supabase'den dinamik olarak çekilecek.
class RecommendedActivity extends Equatable {
  const RecommendedActivity({
    required this.category,
    required this.title,
    required this.description,
    required this.readTime,
  });

  final String category;
  final String title;
  final String description;
  final String readTime;

  @override
  List<Object?> get props => [category, title, description, readTime];
}