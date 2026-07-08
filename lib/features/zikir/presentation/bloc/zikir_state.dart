// Değişiklik: ZikirModu 3'lü yapıya çevrildi (sessiz/titresim/sesli).
// sayac, tamamlandiMi, tamamlananTurSayisi artık şablon bazlı Map'lerden
// okunan getter'lar; her zikir şablonunun ilerlemesi bağımsız tutulur.
import 'package:flutter/foundation.dart' show immutable;

import '../../domain/entities/zikir_template.dart';

/// Sesli / sessiz / titreşim mod seçimi.
enum ZikirModu { sessiz, titresim, sesli }

/// ================== ZIKIR STATE (DURUM) ==================
/// State, ekranın o anki "anlık fotoğrafıdır". View bu sınıfı DİNLER
/// (BlocBuilder ile) ve her değiştiğinde kendini yeniden çizer.
/// State immutable'dır (değiştirilemez) — her güncellemede copyWith ile
/// YENİ bir State nesnesi üretilir, var olan nesne mutate edilmez.
/// Bu, BLoC/MVVM'de state yönetiminin öngörülebilir olmasını sağlar.
@immutable
class ZikirState {
  final List<ZikirTemplate> sablonlar; // hazır + kullanıcı tanımlı zikirler
  final int seciliSablonIndex;
  final ZikirModu mod;

  /// Her zikir şablonunun bağımsız sayaç, tamamlanma ve tur durumu.
  final Map<int, int> sablonSayaclari;       // key: şablon index, value: sayaç
  final Map<int, bool> sablonTamamlandiMi;    // key: şablon index, value: tamamlandı mı
  final Map<int, int> sablonTurSayilari;      // key: şablon index, value: tur sayısı

  const ZikirState({
    required this.sablonlar,
    required this.seciliSablonIndex,
    required this.mod,
    required this.sablonSayaclari,
    required this.sablonTamamlandiMi,
    required this.sablonTurSayilari,
  });

  /// Uygulama ilk açıldığında Bloc'un başlayacağı durum.
  factory ZikirState.baslangic() => const ZikirState(
        sablonlar: defaultZikirTemplates,
        seciliSablonIndex: 0,
        mod: ZikirModu.sessiz,
        sablonSayaclari: {},
        sablonTamamlandiMi: {},
        sablonTurSayilari: {},
      );

  /// Aktif şablonun sayacı (Map'ten okunur, yoksa 0).
  int get sayac => sablonSayaclari[seciliSablonIndex] ?? 0;

  /// Aktif şablonun tamamlanma durumu (Map'ten okunur, yoksa false).
  bool get tamamlandiMi => sablonTamamlandiMi[seciliSablonIndex] ?? false;

  /// Aktif şablonun tamamlanan tur sayısı (Map'ten okunur, yoksa 0).
  int get tamamlananTurSayisi => sablonTurSayilari[seciliSablonIndex] ?? 0;

  /// O an ekranda gösterilen aktif zikir şablonu (React'teki activeTemplate).
  ZikirTemplate get aktifSablon => sablonlar[seciliSablonIndex];

  /// Dairesel ilerleme çubuğu için 0.0 - 1.0 arası oran.
  double get ilerlemeOrani =>
      (sayac / aktifSablon.target).clamp(0.0, 1.0).toDouble();

  ZikirState copyWith({
    List<ZikirTemplate>? sablonlar,
    int? seciliSablonIndex,
    ZikirModu? mod,
    Map<int, int>? sablonSayaclari,
    Map<int, bool>? sablonTamamlandiMi,
    Map<int, int>? sablonTurSayilari,
  }) {
    return ZikirState(
      sablonlar: sablonlar ?? this.sablonlar,
      seciliSablonIndex: seciliSablonIndex ?? this.seciliSablonIndex,
      mod: mod ?? this.mod,
      sablonSayaclari: sablonSayaclari ?? this.sablonSayaclari,
      sablonTamamlandiMi: sablonTamamlandiMi ?? this.sablonTamamlandiMi,
      sablonTurSayilari: sablonTurSayilari ?? this.sablonTurSayilari,
    );
  }
}