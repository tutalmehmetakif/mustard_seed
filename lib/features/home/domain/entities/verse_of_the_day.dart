import 'package:equatable/equatable.dart';

/// Ana ekrandaki "Günün Ayeti" kartında gösterilen içerik.
///
/// TODO(quran-api): Şu an [HomeBloc] içinde sabit (mock) bir listeden
/// dönüyor. İleride quran.com/Al-Quran Cloud API'sinden ya da Supabase'deki
/// bir "gunluk_icerikler" tablosundan, günün tarihine göre seçilen gerçek
/// bir ayetle değiştirilecek.
class VerseOfTheDay extends Equatable {
  const VerseOfTheDay({
    required this.text,
    required this.reference,
  });

  final String text;
  final String reference;

  @override
  List<Object?> get props => [text, reference];
}