import 'package:home_widget/home_widget.dart';

import '../../../core/utils/hijri_date.dart';
import '../../../core/utils/moon_phase.dart';
import '../domain/daily_verse_source.dart';

/// Android ana ekran widget'ına ve iOS kilit ekranı/ana ekran widget'ına
/// veri gönderen köprü.
///
/// `home_widget` paketi, buradan yazılan veriyi native tarafın
/// okuyabileceği paylaşımlı bir depoya yazar (Android: SharedPreferences,
/// iOS: App Group UserDefaults). Native widget kodu (Kotlin/Swift) bu
/// depodaki anahtarları okuyup ekrana basar:
/// - Android: android/app/src/main/kotlin/.../VerseWidgetProvider.kt
/// - iOS: ios/VerseWidget/VerseWidget.swift (Xcode'da ayrı bir "Widget
///   Extension" hedefi olarak eklenir, bkz. README)
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

  /// Günün ayetini, Hicri tarihi ve ay evresini widget'a yazıp
  /// yenilenmesini tetikler.
  static Future<void> syncDailyVerse() async {
    final now = DateTime.now();
    final verse = DailyVerseSource.verseForDate(now);
    final hijri = HijriDate.fromGregorian(now);
    final moonPhase = MoonPhaseCalculator.calculate(now);

    await HomeWidget.saveWidgetData<String>('verse_text', verse.text);
    await HomeWidget.saveWidgetData<String>(
      'verse_reference',
      verse.reference,
    );
    await HomeWidget.saveWidgetData<String>('hijri_date', hijri.toString());
    await HomeWidget.saveWidgetData<String>('moon_phase', moonPhase.label);

    await HomeWidget.updateWidget(
      androidName: _androidWidgetProviderName,
      iOSName: _iOSWidgetKind,
    );
  }
}