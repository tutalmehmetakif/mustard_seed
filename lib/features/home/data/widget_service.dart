import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/hijri_date.dart';
import '../../../core/utils/moon_phase.dart';
import '../domain/repositories/verse_repository.dart';

class WidgetService {
  WidgetService._();

  static const String _androidWidgetProviderName = 'VerseWidgetProvider';
  static const String _iOSWidgetKind = 'VerseWidget';
  static const String iOSAppGroupId = 'group.io.supabase.mustardseed';

  /// "Fotoğraflı" widget stilinin arka planında kullanılacak fotoğrafın
  /// diskteki sabit dosya adı. Her yeni seçimde bu dosyanın üzerine
  /// yazılır — böylece eski fotoğraflar birikip yer kaplamaz ve widget
  /// hep aynı yoldan (user_photo_path) okuyabilir.
  static const String _userPhotoFileName = 'widget_user_photo.jpg';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(iOSAppGroupId);
  }

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

  /// Kullanıcının "Fotoğraflı" widget stili için galeriden seçtiği
  /// fotoğrafı kalıcı bir konuma kopyalar ve widget'ın okuyabileceği
  /// paylaşımlı depoya (home_widget) yolunu yazar.
  ///
  /// [sourcePath], image_picker'ın döndürdüğü geçici dosya yoludur —
  /// image_picker'ın kendi cache'i sistem tarafından temizlenebildiği
  /// için, burada uygulamanın kalıcı belgeler klasörüne KOPYALIYORUZ.
  /// Widget her zaman bu kalıcı kopyayı okur.
  ///
  /// Android'de: VerseWidgetProvider.kt, widgetData.getString("user_photo_path")
  /// ile bu yolu okuyup BitmapFactory.decodeFile() ile yüklüyor.
  /// iOS'ta: widget extension, App Group container'ı içindeki dosyayı
  /// aynı isimle okuyor (bkz. loadUserPhoto in VerseWidget.swift).
  static Future<bool> saveUserPhoto(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final destinationPath = '${appDir.path}/$_userPhotoFileName';

      final sourceFile = File(sourcePath);
      await sourceFile.copy(destinationPath);

      final saveResult = await HomeWidget.saveWidgetData<String>(
        'user_photo_path',
        destinationPath,
      );

      debugPrint(
        '[WidgetService] Fotoğraf kaydedildi -> $destinationPath, '
        'saveWidgetData sonucu: $saveResult',
      );

      final updateResult = await HomeWidget.updateWidget(
        androidName: _androidWidgetProviderName,
        iOSName: _iOSWidgetKind,
      );

      debugPrint('[WidgetService] Fotoğraf sonrası updateWidget: $updateResult');

      return saveResult == true;
    } catch (error) {
      debugPrint('[WidgetService] Fotoğraf kaydetme HATASI: $error');
      return false;
    }
  }

  /// Kullanıcı widget fotoğrafını kaldırmak isterse (örn. başka bir
  /// stile geçmeden önce temizlemek için) çağrılabilir.
  static Future<void> clearUserPhoto() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_userPhotoFileName');
      if (await file.exists()) {
        await file.delete();
      }
      await HomeWidget.saveWidgetData<String>('user_photo_path', '');
      await HomeWidget.updateWidget(
        androidName: _androidWidgetProviderName,
        iOSName: _iOSWidgetKind,
      );
    } catch (error) {
      debugPrint('[WidgetService] Fotoğraf temizleme HATASI: $error');
    }
  }

  /// Şu an kayıtlı widget fotoğrafının yolunu döner (varsa), Profil
  /// sayfasında önizleme göstermek için kullanılır.
  static Future<String?> getUserPhotoPath() async {
    final path = await HomeWidget.getWidgetData<String>('user_photo_path');
    if (path == null || path.isEmpty) return null;
    final exists = await File(path).exists();
    return exists ? path : null;
  }
}