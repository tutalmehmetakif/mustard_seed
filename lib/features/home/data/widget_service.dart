import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/utils/hijri_date.dart';
import '../../../core/utils/moon_phase.dart';
import '../domain/repositories/verse_repository.dart';

/// Android ana ekran widget'ına ve iOS kilit ekranı/ana ekran widget'ına
/// veri gönderen köprü.
///
/// `home_widget` paketi, buradan yazılan veriyi native tarafın
/// okuyabileceği paylaşımlı bir depoya yazar (Android: SharedPreferences,
/// iOS: App Group UserDefaults). Native widget kodu (Kotlin/Swift) bu
/// depodaki anahtarları okuyup ekrana basar.
///
/// [syncVerse] her çağrıldığında [VerseRepository] üzerinden Supabase'den
/// RASTGELE bir ayet/hadis çeker — main.dart'ta uygulama her ön plana
/// geldiğinde (kullanıcı telefonu her açtığında) bu çağrılıyor, böylece
/// widget da uygulama içi Ana Sayfa da her seferinde farklı içerik
/// gösterebiliyor.
class WidgetService {
  WidgetService._();

  static const String _androidWidgetProviderName = 'VerseWidgetProvider';
  static const String _iOSWidgetKind = 'VerseWidget';

  /// iOS'ta ana uygulama ile widget extension'ının aynı veriyi
  /// paylaşabilmesi için Xcode'da her iki hedefte de aktif edilmesi
  /// gereken App Group kimliği.
  static const String iOSAppGroupId = 'group.io.supabase.mustardseed';

  /// Uygulama açılışında bir kez çağrılmalı (main.dart).
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(iOSAppGroupId);
  }

  /// Rastgele bir ayet/hadis çekip Hicri tarih ve ay evresiyle birlikte
  /// widget'a yazar, yenilenmesini tetikler.
  static Future<void> syncVerse(VerseRepository verseRepository) async {
    final now = DateTime.now();
    final verse = await verseRepository.fetchRandomVerse();
    final hijri = HijriDate.fromGregorian(now);
    final moonPhase = MoonPhaseCalculator.calculate(now);

    debugPrint(
      '[WidgetService] Yazılacak veri -> verse: "${verse.text}", '
      'ref: "${verse.reference}", hijri: "$hijri", moon: "${moonPhase.label}"',
    );

    final r1 = await HomeWidget.saveWidgetData<String>('verse_id', verse.id);
    final r2 = await HomeWidget.saveWidgetData<String>('verse_text', verse.text);
    final r3 = await HomeWidget.saveWidgetData<String>(
      'verse_reference',
      verse.reference,
    );
    final r4 =
        await HomeWidget.saveWidgetData<String>('hijri_date', hijri.toString());
    final r5 =
        await HomeWidget.saveWidgetData<String>('moon_phase', moonPhase.label);

    debugPrint(
      '[WidgetService] saveWidgetData sonuçları -> '
      'verse_id: $r1, verse_text: $r2, verse_reference: $r3, '
      'hijri_date: $r4, moon_phase: $r5',
    );

    final updateResult = await HomeWidget.updateWidget(
      androidName: _androidWidgetProviderName,
      iOSName: _iOSWidgetKind,
    );

    debugPrint('[WidgetService] updateWidget sonucu: $updateResult');
  }
}