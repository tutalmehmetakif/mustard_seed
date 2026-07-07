import 'package:equatable/equatable.dart';

/// Ana sayfadaki "Hızlı Zikir Sayacı" widget'ında gösterilen zikir şablonu.
///
/// NOT: Bu, gerçek Zikir sekmesinin veri modeliyle aynı olmayabilir —
/// arkadaşının zikir sayfası bloc'u paylaşıldığında bu dosya kaldırılıp
/// oradaki gerçek entity ile değiştirilmeli.
class QuickZikirTemplate extends Equatable {
  const QuickZikirTemplate({
    required this.phrase,
    required this.translation,
    required this.target,
  });

  final String phrase;
  final String translation;
  final int target;

  @override
  List<Object?> get props => [phrase, translation, target];
}