import 'package:equatable/equatable.dart';

/// Ana ekrandaki "Günün Ayeti" kartında ve widget'ta gösterilen içerik.
class VerseOfTheDay extends Equatable {
  const VerseOfTheDay({
    required this.id,
    required this.text,
    required this.reference,
    this.explanation,
  });

  final String id;
  final String text;
  final String reference;

  /// Kısa ruhsal açıklama (meal değil) — widget'a dokununca açılan
  /// "Ayet Açıklaması" ekranında gösterilir. Bazı satırlarda henüz
  /// girilmemiş olabilir, bu yüzden null olabilir.
  final String? explanation;

  @override
  List<Object?> get props => [id, text, reference, explanation];
}