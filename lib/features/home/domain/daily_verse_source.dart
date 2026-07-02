import 'package:mustard_seed/features/home/domain/entities/verse_of_the_day.dart';


/// Ayet listesini ve "bugün hangi ayet gösterilecek" mantığını tek yerde
/// tutar. Hem uygulama içi Ana Sayfa (HomeBloc) hem de kilit ekranı/ana
/// ekran widget'ı (WidgetService) aynı kaynaktan okuduğu için, kullanıcı
/// widget'ta gördüğü ayetle uygulama içinde ilk açılışta gördüğü ayet
/// birebir aynı olur.
///
/// TODO(quran-api): Bu sabit liste, Kur'an API entegrasyonu yapılınca
/// gerçek bir veri kaynağıyla (quran.com/Al-Quran Cloud API ya da
/// Supabase'deki bir tablo) değiştirilecek — bu dosya değişse bile
/// HomeBloc ve WidgetService'in geri kalanı aynı kalabilir.
class DailyVerseSource {
  DailyVerseSource._();

  static const List<VerseOfTheDay> verses = [
    VerseOfTheDay(
      text: 'Şüphesiz her zorlukla beraber bir kolaylık vardır.',
      reference: 'İnşirah Suresi, 6. Ayet',
    ),
    VerseOfTheDay(
      text: 'Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz '
          'Allah sabredenlerle beraberdir.',
      reference: 'Bakara Suresi, 153. Ayet',
    ),
    VerseOfTheDay(
      text: "Kalpler ancak Allah'ı anmakla huzur bulur.",
      reference: "Ra'd Suresi, 28. Ayet",
    ),
  ];

  /// Verilen tarihe göre deterministik bir ayet seçer — aynı gün içinde
  /// her çağrıldığında aynı sonucu döner (yılın kaçıncı günü olduğuna
  /// göre listede döngüsel bir indeks hesaplanır).
  static VerseOfTheDay verseForDate(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays;
    final index = dayOfYear % verses.length;
    return verses[index];
  }
}