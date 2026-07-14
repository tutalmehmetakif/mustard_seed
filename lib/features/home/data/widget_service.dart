import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  static const String _userPhotoFileName = 'widget_user_photo.jpg';

  /// iOS tarafında App Group container'ına dosya yazmak için
  /// AppDelegate.swift'teki native köprü. Android'de widget aynı process
  /// içinde çalıştığı için buna gerek yok — Android orada doğrudan
  /// path_provider ile dosya sistemi kullanıyor.
  static const MethodChannel _iOSPhotoChannel =
      MethodChannel('com.hardaltanesi.app/widget_photo');

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
  /// fotoğrafı kalıcı bir konuma kaydeder.
  ///
  /// Android: uygulamanın kalıcı belgeler klasörüne kopyalanır, yolu
  /// home_widget'ın paylaşımlı deposuna (user_photo_path) yazılır —
  /// widget aynı process içinde çalıştığı için bu dosyaya erişebilir.
  ///
  /// iOS: widget extension AYRI bir process'te çalıştığı ve ana
  /// uygulamanın Documents klasörüne erişemediği için, bayt verisi
  /// native MethodChannel üzerinden doğrudan App Group container'ına
  /// yazılır (bkz. AppDelegate.swift).
  static Future<bool> saveUserPhoto(String sourcePath) async {
    try {
      if (Platform.isIOS) {
        final bytes = await File(sourcePath).readAsBytes();
        final success = await _iOSPhotoChannel.invokeMethod<bool>(
          'savePhoto',
          {'bytes': Uint8List.fromList(bytes)},
        );
        debugPrint('[WidgetService] iOS fotoğraf kaydı sonucu: $success');

        if (success == true) {
          final updateResult = await HomeWidget.updateWidget(
            androidName: _androidWidgetProviderName,
            iOSName: _iOSWidgetKind,
          );
          await HomeWidget.saveWidgetData<String>('ios_has_user_photo', 'true');
          debugPrint('[WidgetService] Fotoğraf sonrası updateWidget: $updateResult');
        }
        return success ?? false;
      }

      // Android yolu — değişmedi.
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

  static Future<void> clearUserPhoto() async {
    try {
      if (Platform.isIOS) {
        await _iOSPhotoChannel.invokeMethod<bool>('clearPhoto');
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        final file = File('${appDir.path}/$_userPhotoFileName');
        if (await file.exists()) {
          await file.delete();
        }
        await HomeWidget.saveWidgetData<String>('user_photo_path', '');
        await HomeWidget.saveWidgetData<String>('ios_has_user_photo', 'false');
      }

      await HomeWidget.updateWidget(
        androidName: _androidWidgetProviderName,
        iOSName: _iOSWidgetKind,
      );
    } catch (error) {
      debugPrint('[WidgetService] Fotoğraf temizleme HATASI: $error');
    }
  }

  /// Şu an kayıtlı widget fotoğrafının yolunu döner (varsa) — Android'de
  /// gerçek dosya yolu, iOS'ta ise sadece "var/yok" bilgisini taşıyan
  /// sabit bir gösterge döner (App Group içindeki dosyaya Flutter
  /// tarafından doğrudan Image.file ile erişilemez, o yüzden burada UI
  /// önizlemesi için iOS'ta ayrı bir çözüm gerekir — bkz. not aşağıda).
  static Future<String?> getUserPhotoPath() async {
    if (Platform.isIOS) {
      // NOT: iOS'ta App Group container yolu Flutter tarafından normal
      // Image.file ile okunabilir çünkü aynı cihazdaki bir dosya sistemi
      // yolu — sandboxing sadece OTOMATİK klasörler (Documents vb.) için
      // geçerli, App Group container'ı paylaşılan bir yol olduğu için
      // Flutter (ana uygulama süreci) bu dosyayı okuyabilir. Container
      // yolunu native taraftan almak gerekir; basitlik için burada şimdilik
      // "var mı yok mu" bilgisini home_widget üzerinden ayrıca saklıyoruz.
      final hasPhoto = await HomeWidget.getWidgetData<String>('ios_has_user_photo');
      return (hasPhoto == 'true') ? 'ios_photo_placeholder' : null;
    }

    final path = await HomeWidget.getWidgetData<String>('user_photo_path');
    if (path == null || path.isEmpty) return null;
    final exists = await File(path).exists();
    return exists ? path : null;
  }
}